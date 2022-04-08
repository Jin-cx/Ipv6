(*
 * ����������ͳ�Ƶ�Ԫ
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 * ˵��:
 *       �߳������
 *       ���̸߳�����������������
 *
 *       �߳���Ϣ:  ������������߳�   x 1
 *                  ִ������Ĺ����߳� x 1 ~ 4
 *
 *
 *       ����Ԫ��ʱ���԰���ƽ̨�������У�ֻ�����ݿ⽻��
 *
 *
 * �޸�:
 * 2017-06-01 (v0.1)
 *   + ��һ�η���.
 *)

unit UdoDDWork.MeterStatisTask;

interface

uses
  SysUtils, Classes, DateUtils, Generics.Collections, Windows,
  puer.System, puer.SyncObjs, puer.Json.JsonDataObjects, puer.Collections,
  puer.MSSQL,
  UPrDbConnInter, UPrHttpServerInter, UPrLogInter,
  UDDDataInter,
  UDDDeviceData, UDDMeterData, UDDHourValueData, UDDHourDosageData,
  UMyConfig;

const
  OUTPUT_STATIS_CAST = True;      // �����ʱͳ��
  CHECK_INTERVAL     = 60000;     // ����Ƿ�Ӧ��ͳ�����ݵļ��

  DOSAGE_NIL         = -1;        // nil ����
  DOSAGE_NORMAL      = 0;         // ��������
  DOSAGE_VIRTUAL     = 1;         // ģ������

  STATIS_DELAY_BUSY  = 80;        // ������ʱ�ļ��
  STATIS_DELAY_IDLE  = 1000;      // ������ʱ�ļ��

  //STATIS_DELAY_BUSY  = 5;        // ������ʱ�ļ��
  //STATIS_DELAY_IDLE  = 5;        // ������ʱ�ļ��

type
  TDDWorkMeterStatisCtrl = class
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;
  end;

implementation

uses
  UdoDDWork.CommIO;

type
  // ��ʱͳ��
  TStatisCast = record
    FBeginTime: TDateTime;
    FMeterCount: Integer;
    FDoCount: Integer;
    FUpdateMeterRealData: Int64;
    FQueryMeterLastHour: Int64;
    FQueryDeviceHourValueList: Int64;
    FCalcOnLineRate: Int64;
    FUpdateMeterHourData: Int64;
  public
    procedure Init(const aMeterCount: Integer);
    procedure DebugOut;
    procedure IncDoCount;

    procedure AddUpdateMeterRealData(const aCast: Int64);
    procedure AddQueryMeterLastHour(const aCast: Int64);
    procedure AddQueryDeviceHourValueList(const aCast: Int64);
    procedure AddCalcOnLineRate(const aCast: Int64);
    procedure AddUpdateMeterHourData(const aCast: Int64);
  end;

  TMeterCacheList = class
  private
    FMeterDict: TDictionary<Integer, THourDosageDataList>;
    FLock: TPrRWLock;
  public
    constructor Create;
    destructor Destroy; override;

    function GetMeterLastHourData(const aMeterId: Integer;
                                  const aDevId: Integer;
                                  const aHourDosageList: THourDosageDataList;
                                  var aErrorInfo: string): Boolean;
    procedure SetMeterLastHourData(const aMeterId: Integer;
                                   const aHourDosageList: THourDosageDataList);
  end;

  // ��������
  TTaskData = record
    // ������Ϣ
    FMeterId: RInteger;       // ������ ID
    FMeterCode: RString;      // ��������
    FDevId: RInteger;         // �豸ID
    FMeterValueCode: RString; // ����ֵ
    //FDeviceModel: RString;    // �豸�ͺ�
    FMeterRate: RDouble;      // �����㱶��
    FIsVirtual: RBoolean;     // �Ƿ���������
    // ��������ͳ������
    FDate: TDateTime;         // ͳ�ƽ�������
    FHour: Integer;           // ͳ�ƽ���Сʱ
    FIsStatis: Boolean        // ����ͳ�Ƶ�Сʱ�Ƿ������
  end;

  // ͳ�������
  TStatisTaskPool = class
  private
    FTaskList: TList<TTaskData>;
    FLock: TPrRWLock;
    FStatisCast: TStatisCast;
    procedure doAddNewTasks(const aDate: TDateTime;
                            const aHour: Integer;
                            const aIsStatis: Boolean);
    function doGetTask(var aTaskData: TTaskData): Boolean;
    procedure doMeterStatis(aTaskData: TTaskData);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddNewTasks(const aDate: TDateTime;
                          const aHour: Integer;
                          const aIsStatis: Boolean);

    procedure DoTask;

    procedure ClearTask;
  end;

  // ������������߳�
  TStatisMasterThread = class(TThread)
  private
    FEvent: TPrSimpleEvent;
    FLastHour: Integer;
    FLastMin: Integer;
    FLastBackupDate: TDate;
    function doCheckNeedStat_Hour(var aDate: TDateTime;
                                  var aHour: Integer): Boolean;
    function doCheckNeedStat_Min(var aDate: TDateTime;
                                 var aHour: Integer): Boolean;
    procedure doStat(const aDate: TDateTime;
                     const aHour: Integer;
                     const aIsStatis: Boolean);
    procedure doCheckAndBackupDB;
    procedure doInitLastBackupDate(const aQuery: TPrADOQuery; var aLastBackupDate: TDate);
    procedure doInitDBInfo(const aDBConn: string; var aBackupDir, aDBName: string);
    procedure doBackup(const aQuery: TPrADOQuery; const aBackupDir, aDBName: string; var aLastBackupDate: TDate);
    procedure doClearOldBackupFile(const aQuery: TPrADOQuery; const aBackupDir: string);
    procedure doClearOverRealDatas(const aQuery: TPrADOQuery);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

  // ִ������Ĺ����߳�
  TStatisWorkThread = class(TThread)
  private
    FEvent: TPrSimpleEvent;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

var
  _MeterCacheList: TMeterCacheList;
  _StatisTaskPool: TStatisTaskPool;
  _StatisMasterThread: TStatisMasterThread;
  _StatisWorkThreadArray: TArray<TStatisWorkThread>;
  _StatisDelay: Integer;

{ TDDWorkMeterStatisCtrl }
class procedure TDDWorkMeterStatisCtrl.Open;
begin
  _MeterCacheList := TMeterCacheList.Create;
  _StatisTaskPool := TStatisTaskPool.Create;
  _StatisMasterThread := TStatisMasterThread.Create;

  _StatisDelay := STATIS_DELAY_IDLE;

  while Length(_StatisWorkThreadArray) < 4 do
  begin
    SetLength(_StatisWorkThreadArray, Length(_StatisWorkThreadArray) + 1);
    _StatisWorkThreadArray[Length(_StatisWorkThreadArray) - 1] := TStatisWorkThread.Create;
  end;
end;

class function TDDWorkMeterStatisCtrl.Active: Boolean;
begin
  Result := _MeterCacheList <> nil;
end;

class procedure TDDWorkMeterStatisCtrl.Close;
var
  aStatisWorkThread: TStatisWorkThread;
begin
  _StatisMasterThread.Free;

  _StatisTaskPool.ClearTask;

  for aStatisWorkThread in _StatisWorkThreadArray do
    aStatisWorkThread.Free;

  _StatisTaskPool.Free;

  _MeterCacheList.Free;
end;

{ TStatisCast }
procedure TStatisCast.Init(const aMeterCount: Integer);
begin
  FBeginTime := Now;
  FMeterCount := aMeterCount;
  FDoCount := 0;

  FUpdateMeterRealData := 0;
  FQueryMeterLastHour := 0;
  FQueryDeviceHourValueList := 0;
  FCalcOnLineRate := 0;
  FUpdateMeterHourData := 0;
end;

procedure TStatisCast.DebugOut;
begin
  TPrLogInter.WriteLogInfo('ͳ�Ƽ�����Сʱ����, ��ʼʱ��: ' + FormatDateTime(FormatSettings.LongDateFormat + ' ' + FormatSettings.LongTimeFormat + '.zzz', FBeginTime));
  TPrLogInter.WriteLogInfo('ͳ�Ƽ�����Сʱ����, ��������: ' + IntToStr(FMeterCount) + ' ��');
  TPrLogInter.WriteLogInfo('ͳ�Ƽ�����Сʱ����, �������: ' + IntToStr(FDoCount) + ' ��');
  if FMeterCount = 0 then
    Exit;

  TPrLogInter.WriteLogInfo('ͳ�Ƽ�����Сʱ����, ƽ����ʱ: ' + IntToStr(MilliSecondsBetween(FBeginTime, Now) div FDoCount) + ' ms');
  TPrLogInter.WriteLogInfo('���¼�����ʵʱ����, ƽ����ʱ ' + IntToStr(FUpdateMeterRealData div FDoCount) + ' ms');
  TPrLogInter.WriteLogInfo('ȡ���������ͳ��ʱ��, ƽ����ʱ ' + IntToStr(FQueryMeterLastHour div FDoCount) + ' ms');
  TPrLogInter.WriteLogInfo('ȡ�豸��ʷСʱʾ��, ƽ����ʱ ' + IntToStr(FQueryDeviceHourValueList div FDoCount) + ' ms');
  TPrLogInter.WriteLogInfo('����Сʱ������, ƽ����ʱ ' + IntToStr(FCalcOnLineRate div FDoCount) + ' ms');
  TPrLogInter.WriteLogInfo('����Сʱ����, ƽ����ʱ ' + IntToStr(FUpdateMeterHourData div FDoCount) + ' ms');
end;

procedure TStatisCast.IncDoCount;
begin
  if TPrInterLock.Inc(FDoCount) = FMeterCount then
    DebugOut;
end;

procedure TStatisCast.AddUpdateMeterRealData(const aCast: Int64);
begin
  FUpdateMeterRealData := FUpdateMeterRealData + aCast;
end;

procedure TStatisCast.AddQueryMeterLastHour(const aCast: Int64);
begin
  FQueryMeterLastHour := FQueryMeterLastHour + aCast;
end;

procedure TStatisCast.AddQueryDeviceHourValueList(const aCast: Int64);
begin
  FQueryDeviceHourValueList := FQueryDeviceHourValueList + aCast;
end;

procedure TStatisCast.AddCalcOnLineRate(const aCast: Int64);
begin
  FCalcOnLineRate := FCalcOnLineRate + aCast;
end;

procedure TStatisCast.AddUpdateMeterHourData(const aCast: Int64);
begin
  FUpdateMeterHourData := FUpdateMeterHourData + aCast;
end;

{ TStatisMasterThread }
constructor TStatisMasterThread.Create;
begin
  inherited Create(False);
  FEvent := TPrSimpleEvent.Create;
  FLastHour := -1;
  FLastMin := -1;

  FLastBackupDate := 0;
end;

destructor TStatisMasterThread.Destroy;
begin
  FEvent.SetEvent;
  Terminate;
  WaitFor;
  FEvent.Free;
  inherited;
end;

procedure TStatisMasterThread.Execute;
var
  aDate: TDateTime;
  aHour: Integer;
begin
  inherited;

  while not Terminated do
  begin
    doCheckAndBackupDB;

    try
      if doCheckNeedStat_Hour(aDate, aHour) then
        doStat(aDate, aHour, True)
      else
      if doCheckNeedStat_Min(aDate, aHour) then
        doStat(aDate, aHour, False);
    except
    end;

    if FEvent.WaitFor(CHECK_INTERVAL) = wrSignaled then
      Exit;
  end;
end;

function TStatisMasterThread.doCheckNeedStat_Hour(var aDate: TDateTime;
                                                  var aHour: Integer): Boolean;
var
  aNowTime: TDateTime;
begin
  Result := False;

  aNowTime := Now;

  aDate := aNowTime;
  aHour := HourOf(aNowTime);
  if aHour = 0 then
  begin
    aHour := 24;
    aDate := IncDay(aNowTime, -1);
  end;

  if aHour <> FLastHour then
  begin
    FLastHour := aHour;
    FLastMin := 0;
    Result := True;
  end;
end;

function TStatisMasterThread.doCheckNeedStat_Min(var aDate: TDateTime;
                                                 var aHour: Integer): Boolean;
var
  aNowTime: TDateTime;
  aMin: Integer;
begin
  Result := False;

  aNowTime := Now;

  aDate := aNowTime;
  aHour := HourOf(aNowTime) + 1;
  aMin  := MinuteOf(aNowTime);
  {if aHour = 0 then
  begin
    aHour := 24;
    aDate := IncDay(aNowTime, -1);
  end; }

  if (aMin - FLastMin) >= 5 then
  begin
    FLastMin := aMin;
    Result := True;
  end;
end;

procedure TStatisMasterThread.doStat(const aDate: TDateTime;
                                     const aHour: Integer;
                                     const aIsStatis: Boolean);
var
  aErrorInfo: string;
begin
  _StatisTaskPool.AddNewTasks(aDate, aHour, aIsStatis);
  _DDDataInter._doCheckDoubtRequest(aErrorInfo);
end;

procedure TStatisMasterThread.doInitLastBackupDate(const aQuery: TPrADOQuery; var aLastBackupDate: TDate);
begin
  aQuery.Close;
  aQuery.SQL.Text := 'select max(backup_finish_date) backup_finish_date from msdb.dbo.backupset where database_name = db_name() and type = ''D''';
  aQuery.Open;
  if aQuery.RecordCount = 0 then
    aLastBackupDate := Now - 1
  else
    aLastBackupDate := aQuery.FieldByName('backup_finish_date').AsDateTime;
end;

procedure TStatisMasterThread.doInitDBInfo(const aDBConn: string; var aBackupDir, aDBName: string);
var
  aFileDir, aFileName: string;
  aJson: TJsonObject;
begin
  aFileDir := UPrHttpServerInter.WebRootPath;
  if aFileDir[Length(aFileDir)] = '\' then
    aFileDir := ExtractFileDir(aFileDir);
  aFileDir := ExtractFileDir(aFileDir);
  aFileName := Format('%s\config\dbConn\%s.conn', [aFileDir, aDBConn]);

  aJson := TJsonObject.Create;
  try
    aJson.LoadFromFile(aFileName);
    aDBName := aJson.O['conn'].S['initialcatalog'];
    aBackupDir := aJson.O['backup'].S['backupdisk'];
    if aBackupDir[Length(aBackupDir)] = '\' then
      aBackupDir := aBackupDir + 'dd-iot\'
    else
      aBackupDir := aBackupDir + '\dd-iot\';
  finally
    aJson.Free;
  end;
end;

procedure TStatisMasterThread.doBackup(const aQuery: TPrADOQuery; const aBackupDir, aDBName: string; var aLastBackupDate: TDate);
var
  aBeginDate: TDateTime;
  aBackupFile: string;
  aErrorInfo: string;
begin
  aBeginDate := Now;

  TPrMSSQL.CheckAndCreateDir(aQuery.Connection, aBackupDir, aErrorInfo);

  aBackupFile := aBackupDir + aDBName + FormatDateTime('_yyyy_MM_dd_hh_mm_ss_', Now) + '[com].bak';
  aQuery.Close;
  aQuery.CommandTimeout := 3600*1000;
  aQuery.SQL.Text := 'BACKUP DATABASE ['+aDBName+'] TO DISK = N'''+aBackupFile+''' WITH COMPRESSION';
  aQuery.ExecSQL;

  aLastBackupDate := aBeginDate;
end;

procedure TStatisMasterThread.doClearOldBackupFile(const aQuery: TPrADOQuery; const aBackupDir: string);
begin
  aQuery.Close;
  aQuery.SQL.Text := 'master.dbo.xp_delete_file 0, N'''+aBackupDir+''', ''bak'', '''+FormatDateTime('yyyy-MM-dd', Now-3)+'''';
  aQuery.ExecSQL;
end;

procedure TStatisMasterThread.doClearOverRealDatas(const aQuery: TPrADOQuery);
begin
  aQuery.Close;
  aQuery.CommandTimeout := 3600*1000;
  aQuery.ProcName := 'proc_ClearOverRealDatas';
  aQuery.ExecProc;
end;

procedure TStatisMasterThread.doCheckAndBackupDB;
var
  aQuery: TPrADOQuery;
  aBackupDir: string;
  aDBName: string;
begin
  // ÿ�� 23:00 ��ʼ����һ��
  if (HourOf(Now) < 23) or (DaysBetween(Trunc(Now), Trunc(FLastBackupDate)) = 0) then
    Exit;

  try
    TPrLogInter.WriteLogInfo('��ʼ׼�����ݿⱸ��');

    aQuery := TPrADOQuery.Create(DB_METER);
    try
      // �ϴα���ʱ��δ֪�ͻ�ȡ���ٱȽ�
      if FLastBackupDate = 0 then
      begin
        doInitLastBackupDate(aQuery, FLastBackupDate);

        if DaysBetween(Trunc(Now), Trunc(FLastBackupDate)) = 0 then
          Exit;
      end;

      doInitDBInfo(DB_METER, aBackupDir, aDBName);

      doBackup(aQuery, aBackupDir, aDBName, FLastBackupDate);

      doClearOldBackupFile(aQuery, aBackupDir);
    finally
      aQuery.Free;
    end;

    TPrLogInter.WriteLogInfo('���ݿⱸ�����');
  except
    on E: Exception do
    begin
      TPrLogInter.WriteLogError('���ݿⱸ���쳣��' + E.Message);
    end;
  end;

  try
    TPrLogInter.WriteLogInfo('��ʼ�����޵���ʷ����');

    aQuery := TPrADOQuery.Create(DB_METER);
    try
      doClearOverRealDatas(aQuery);
    finally
      aQuery.Free;
    end;

    TPrLogInter.WriteLogInfo('�����޵���ʷ�������');
  except
    on E: Exception do
    begin
      TPrLogInter.WriteLogError('�����޵���ʷ�����쳣��' + E.Message);
    end;
  end;
end;

{ TStatisWorkThread }
constructor TStatisWorkThread.Create;
begin
  inherited Create(False);
  FEvent := TPrSimpleEvent.Create;
end;

destructor TStatisWorkThread.Destroy;
begin
  FEvent.SetEvent;
  Terminate;
  WaitFor;
  FEvent.Free;
  inherited;
end;

procedure TStatisWorkThread.Execute;
begin
  inherited;

  while not Terminated do
  begin
    try
      _StatisTaskPool.DoTask;
    except
    end;

    if FEvent.WaitFor(_StatisDelay) = wrSignaled then
      Exit;
  end;
end;

{ TStatisTaskPool }
constructor TStatisTaskPool.Create;
begin
  inherited;
  FLock := TPrRWLock.Create;
  FTaskList := TList<TTaskData>.Create;
end;

destructor TStatisTaskPool.Destroy;
begin
  FLock.BeginWrite;
  try
    FTaskList.Free;
  finally
    FLock.EndWrite;
    FLock.Free;
  end;
  inherited;
end;

procedure TStatisTaskPool.doAddNewTasks(const aDate: TDateTime;
                                        const aHour: Integer;
                                        const aIsStatis: Boolean);
var
  aTaskData: TTaskData;
  aMeter: TMeterData;
  aMeterList: TMeterDataList;
  aErrorInfo: string;
begin
  aMeterList := TMeterDataList.Create;
  try
    if not _DDDataInter._doGetAllMeterList(aMeterList, aErrorInfo) then
    begin
      TPrLogInter.WriteLogError('��ȡ�������б�ʧ�ܣ�'+aErrorInfo);
      Exit;
    end;

    //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, '��ʼ��Ӽ������� ' + IntToStr(aMeterList.Count));

    for aMeter in aMeterList do
    begin
      // �����豸����ʱ��ͳ��
      if aMeter.isVirtual.IsTrue then
        Continue;

      // ������Ϣ
      aTaskData.FMeterId := aMeter.meterId;
      aTaskData.FMeterCode := aMeter.meterCode;
      aTaskData.FDevId := aMeter.devId;
      aTaskData.FMeterValueCode := aMeter.meterValueCode;
      //aTaskData.FDeviceModel := aMeter.DeviceModel;
      aTaskData.FMeterRate := aMeter.meterRate;
      aTaskData.FIsVirtual := aMeter.isVirtual;
      // ��������ͳ������
      aTaskData.FDate := aDate;
      aTaskData.FHour := aHour;
      aTaskData.FIsStatis := aIsStatis;

      FTaskList.Add(aTaskData);
    end;
  finally
    aMeterList.Free;
  end;
end;

function TStatisTaskPool.doGetTask(var aTaskData: TTaskData): Boolean;
begin
  Result := False;

  FLock.BeginWrite;
  try
    if FTaskList.Count = 0 then
      Exit;

    aTaskData := FTaskList[0];
    FTaskList.Delete(0);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

procedure TStatisTaskPool.doMeterStatis(aTaskData: TTaskData);

  function FmtDateHour(const aDate: TDateTime; const aHour: Integer): RDateTime;
  var
    aTmpDate: TDateTime;
  begin
    aTmpDate := Trunc(aDate);
    aTmpDate := IncHour(aTmpDate, aHour - 1);
    Result.Value := aTmpDate;
  end;

  procedure NextHour(var aDate: TDateTime; var aHour: Integer);
  begin
    if aHour = 24 then
    begin
      aDate := IncDay(aDate, 1);
      aHour := 1;
    end
    else
      Inc(aHour);
  end;

  function SameDateHour(const aHourValue: THourValueData;
                        const aDate: TDateTime;
                        const aHour: Integer): Boolean;
  begin
    Result := (aHourValue <> nil) and
              (Trunc(aHourValue.Date) = Trunc(aDate)) and
              (aHourValue.Hour = aHour);
  end;

  function GetBeginDate(const aDate: TDateTime;
                        const aHour: Integer): TDateTime;
  begin
    Result := StrToDateTime(DateToStr(aDate));
    Result := IncHour(Result, aHour - 1);
  end;

  function GetEndDate(const aDate: TDateTime;
                        const aHour: Integer): TDateTime;
  begin
    Result := StrToDateTime(DateToStr(aDate));
    Result := IncHour(Result, aHour);
  end;

  // ��ʷȱʧ����ģ��
  {
  Сʱ��ֵģ��
  ��2����Ч���ݵ�������Сʱ�������ֵ
  ��ֵ����2λС������ߵı��������±��� 1.2367 ����Ϊ 1.23��
  ���һ��Сʱ������������������ǰ��ģ������������ܺ�
  }
  procedure doVirtualHourData(const aHourDosageList: THourDosageDataList);
  var
    aBeginIndex: Integer;
    aEndIndex: Integer;
    i: Integer;
    aTotalDosage: Double;
    aAvgDosage: Double;
    aValue: Double;
  begin
    aBeginIndex := 0;
    aEndIndex := aHourDosageList.Count - 1;
    for i := 0 to aEndIndex do
      if aHourDosageList[i].DataType = DOSAGE_NIL then
      begin
        aBeginIndex := i;
        Break;
      end;

    // ��ƽ������
    aTotalDosage := aHourDosageList[aEndIndex].EndValue.Value
                  - aHourDosageList[aBeginIndex].BeginValue.Value;

    aAvgDosage := aTotalDosage / (aEndIndex - aBeginIndex + 1);
    aAvgDosage := Trunc(aAvgDosage * 100)/100;
    if _MyConfig.MeterNotAvg then
      aAvgDosage := 0;

    aValue := aHourDosageList[aBeginIndex].BeginValue.Value;

    for i := aBeginIndex to aEndIndex - 1 do
    begin
      if i <> aBeginIndex then
      begin
        aHourDosageList[i].BeginValue.Value := aValue;
        aHourDosageList[i].BeginTime.Value := GetBeginDate(aHourDosageList[i].Date, aHourDosageList[i].Hour);
      end;

      aHourDosageList[i].Dosage.Value := aAvgDosage;
      aHourDosageList[i].DataType := DOSAGE_VIRTUAL;

      aValue := aValue + aAvgDosage;

      aHourDosageList[i].EndValue.Value := aValue;
      aHourDosageList[i].EndTime.Value := GetBeginDate(aHourDosageList[i].Date, aHourDosageList[i].Hour);
    end;

    aHourDosageList[aEndIndex].BeginValue.Value := aValue;
    aHourDosageList[aEndIndex].BeginTime.Value := GetBeginDate(aHourDosageList[aEndIndex].Date, aHourDosageList[aEndIndex].Hour);

    aHourDosageList[aEndIndex].Dosage.Value := aTotalDosage - aAvgDosage * (aEndIndex - aBeginIndex);
    aHourDosageList[aEndIndex].DataType := DOSAGE_VIRTUAL;
  end;

  // aNewHourDosageList �ĵ�һ���������Чͳ�Ƶ�һ��, ����ǰ��ɾ����
  procedure doFill(const aNewHourDosageList: THourDosageDataList;
                   const aHourValueList: THourValueDataList;
                   const aEndDate: TDateTime;
                   const aEndHour: Integer);
  var
    aLastHourDosage: THourDosageData;
    aHourDosage: THourDosageData;
    aHourValue: THourValueData;
    aValueIndex: Integer;
    aCurDate: TDateTime;
    aCurHour: Integer;
  begin
    aLastHourDosage := aNewHourDosageList[0];
    aCurDate := aLastHourDosage.Date;
    aCurHour := aLastHourDosage.Hour;

    aValueIndex := 0;

    while True do
    begin
      if (Trunc(aCurDate) = Trunc(aEndDate)) and (aCurHour = aEndHour) then
        Exit;

      NextHour(aCurDate, aCurHour);

      aHourDosage := aNewHourDosageList.Add;
      aHourDosage.Date := aCurDate;
      aHourDosage.Hour := aCurHour;
      aHourDosage.DevId := aLastHourDosage.DevId;
      if aLastHourDosage.EndValue.IsNull then
        aHourDosage.BeginValue := aLastHourDosage.EndValue
      else
        aHourDosage.BeginValue.Value := StrToFloat(FormatFloat('0.00', aLastHourDosage.EndValue.Value));
      aHourDosage.BeginTime := aLastHourDosage.EndTime;
      aHourDosage.isStatis.Value := True;

      if (aValueIndex >= 0) and (aValueIndex < aHourValueList.Count) then
        aHourValue := aHourValueList[aValueIndex]
      else
        aHourValue := nil;

      if SameDateHour(aHourValue, aCurDate, aCurHour) then
      begin
        aHourDosage.EndValue.Value := StrToFloat(FormatFloat('0.00', aHourValue.Value));
        aHourDosage.EndTime.Value := aHourValue.Time;
        if aHourDosage.BeginValue.IsNull then
        begin
          doVirtualHourData(aNewHourDosageList);
        end
        else
        begin
          aHourDosage.Dosage.Value := aHourDosage.EndValue.Value - aHourDosage.BeginValue.Value;
          aHourDosage.Dosage.Value := StrToFloat(FormatFloat('0.00', aHourDosage.Dosage.Value));
          {if aHourDosage.Dosage.Value < 0 then
          begin
            _DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltWarn, '���磬���ָ�������');
            _DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltWarn, 'begin: ' + aHourDosage.BeginValue.AsString);
            _DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltWarn, 'end: ' + aHourDosage.EndValue.AsString);
            _DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltWarn, 'dosage: ' + aHourDosage.Dosage.AsString);
          end;  }

          aHourDosage.DataType := DOSAGE_NORMAL;
        end;
        Inc(aValueIndex);
      end
      else
      begin
        aHourDosage.EndValue.Clear;
        aHourDosage.EndTime.Clear;
        aHourDosage.Dosage.Clear;
        aHourDosage.DataType := DOSAGE_NIL;
      end;

      aLastHourDosage := aHourDosage;
    end;
  end;

  procedure doCalcTenMinUse(const aMeterId: Integer;
                            const aMeterValueCode: string;
                            const aHourDosage: THourDosageData;
                            const aMeterRate: Double);
  var
    aAvgUse: Double;
    aErrorInfo: string;
    aDateHour: TDateTime;
    aHourValue: THourValueData;
    aHourValueList: THourValueDataList;
    aNewHourDosageList: THourDosageDataList;
  begin
    aHourDosage.dosage_Ten1.Clear;
    aHourDosage.dosage_Ten2.Clear;
    aHourDosage.dosage_Ten3.Clear;
    aHourDosage.dosage_Ten4.Clear;
    aHourDosage.dosage_Ten5.Clear;
    aHourDosage.dosage_Ten6.Clear;

    case aHourDosage.dataType of
      DOSAGE_NORMAL: //�������� (10��������ͨ�����ݼ���)
        begin
          // ȡĳ��Сʱ��10����ʾ��
          aDateHour := IncHour(Trunc(aHourDosage.Date), aHourDosage.Hour - 1);
          aHourValueList := THourValueDataList.Create;
          try
            if not _DDDataInter._doGetDeviceTenMinValueList(aHourDosage.devId,
                                                            aMeterValueCode,
                                                            aDateHour,
                                                            aHourValueList,
                                                            aErrorInfo) then
              Exit;

            if aMeterRate <> 1 then
              for aHourValue in aHourValueList do
                aHourValue.Value := StrToFloat(FormatFloat('0.00', aHourValue.Value * aMeterRate));

            aNewHourDosageList := THourDosageDataList.Create;
            try
              with aNewHourDosageList.Add do
              begin
                Date := aDateHour;
                Hour := 1;
                EndValue.Value := aHourDosage.beginValue.Value;
                EndTime.Value := aDateHour;
              end;

              for aHourValue in aHourValueList do
              begin
                aHourValue.Date := aDateHour;
                aHourValue.Hour := aHourValue.Hour + 1;
              end;

              doFill(aNewHourDosageList, aHourValueList, aDateHour, 7);

              aHourDosage.dosage_Ten1 := aNewHourDosageList[1].dosage;
              aHourDosage.dosage_Ten2 := aNewHourDosageList[2].dosage;
              aHourDosage.dosage_Ten3 := aNewHourDosageList[3].dosage;
              aHourDosage.dosage_Ten4 := aNewHourDosageList[4].dosage;
              aHourDosage.dosage_Ten5 := aNewHourDosageList[5].dosage;
              aHourDosage.dosage_Ten6 := aNewHourDosageList[6].dosage;

              //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, 'Ten1 ' + aHourDosage.dosage_Ten1.AsString);
              //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, 'Ten2 ' + aHourDosage.dosage_Ten2.AsString);
              //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, 'Ten3 ' + aHourDosage.dosage_Ten3.AsString);
              //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, 'Ten4 ' + aHourDosage.dosage_Ten4.AsString);
              //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, 'Ten5 ' + aHourDosage.dosage_Ten5.AsString);
              //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, 'Ten6 ' + aHourDosage.dosage_Ten6.AsString);
            finally
              aNewHourDosageList.Free;
            end;
          finally
            aHourValueList.Free;
          end;
        end;
      DOSAGE_VIRTUAL: //������� (10��������ȡ��ֵ)
        begin
          if aHourDosage.dosage.IsNull then
            Exit;

          aAvgUse := aHourDosage.dosage.Value / 6;
          aAvgUse := Trunc(aAvgUse * 100)/100;

          aHourDosage.dosage_Ten1.Value := aAvgUse;
          aHourDosage.dosage_Ten2.Value := aAvgUse;
          aHourDosage.dosage_Ten3.Value := aAvgUse;
          aHourDosage.dosage_Ten4.Value := aAvgUse;
          aHourDosage.dosage_Ten5.Value := aAvgUse;
          aHourDosage.dosage_Ten6.Value := aHourDosage.dosage.Value - aAvgUse*5;
        end;
    end;
  end;

var
  aMeterId, aDevId: Integer;
  aMeterCode, aMeterValueCode: string;
  aDebugHead, aErrorType: string;
  aHourDosageList: THourDosageDataList;
  aHourValue: THourValueData;
  aHourValueList: THourValueDataList;
  aNewHourDosageList, aTmpHourDosageList: THourDosageDataList;
  aLastHourDosage: THourDosageData;
  aBeginDate: RDateTime;
  aEndDate: RDateTime;
  aCast: Int64;
  i: Integer;
  aErrorInfo: string;
begin
  try
    // ��ʼ�����������
    aMeterId := aTaskData.FMeterId.Value;
    aDevId := aTaskData.FDevId.Value;
    aMeterCode := aTaskData.FMeterCode.AsString;
    aMeterValueCode := aTaskData.FMeterValueCode.AsString;
    aDebugHead := '[' + aMeterCode + '] ';

    aHourDosageList := THourDosageDataList.Create;
    try
      // �鿴���������ͳ�Ƶ�ʱ��
      aErrorType := '��ȡ���ͳ��Сʱ����';
      aCast := GetTickCount;
      if not _MeterCacheList.GetMeterLastHourData(aMeterId, aDevId, aHourDosageList, aErrorInfo) then
        raise Exception.Create(aErrorInfo);
      if OUTPUT_STATIS_CAST then
        FStatisCast.AddQueryMeterLastHour(GetTickCount - aCast);

      // �������
      case aHourDosageList.Count of
        // ����ûͳ�ƹ�
        0: aBeginDate.Clear;
        // �ϴ�������ͳ��
        1: aBeginDate := FmtDateHour(aHourDosageList[0].Date, aHourDosageList[0].Hour);
        // �ϴ�ͳ���� nil
        2: aBeginDate := FmtDateHour(aHourDosageList[1].Date, aHourDosageList[1].Hour);
      end;

      // ����ͳ�Ƶ��ڵ�ǰʱ��Ҫ�˳�
      // ���������������ʱ���ظ�һ��
      if (aHourDosageList.Count = 1) and
         (Trunc(aHourDosageList[0].Date) = Trunc(aTaskData.FDate)) and
         (aHourDosageList[0].Hour = aTaskData.FHour) then
        Exit;

      if not aBeginDate.IsNull then
        aBeginDate.Value := IncHour(aBeginDate.Value, 1);
      aEndDate := FmtDateHour(aTaskData.FDate, aTaskData.FHour);

      aHourValueList := THourValueDataList.Create;
      try
        aErrorType := '��ȡ��ʷСʱʾ��';
        aCast := GetTickCount;
        if not _DDDataInter._doGetDeviceHourValueList(aDevId, aMeterValueCode, aBeginDate, aEndDate, aHourValueList, aErrorInfo) then
          raise Exception.Create(aErrorInfo);
        if OUTPUT_STATIS_CAST then
          FStatisCast.AddQueryDeviceHourValueList(GetTickCount - aCast);

        if aTaskData.FMeterRate.Value <> 1 then
          for aHourValue in aHourValueList do
            aHourValue.Value := StrToFloat(FormatFloat('0.00', aHourValue.Value * aTaskData.FMeterRate.Value));

        aNewHourDosageList := THourDosageDataList.Create;
        aTmpHourDosageList := THourDosageDataList.Create;
        try
          aCast := GetTickCount;

          // ��ʼ�� aNewHourDosageList �ĵ�һ������, ����ǰ��ɾ��
          case aHourDosageList.Count of
            0: begin // ����ûͳ�ƹ�
                 if aHourValueList.Count < 2 then
                   Exit;
                 with aNewHourDosageList.Add do
                 begin
                   Date := aHourValueList[0].Date;
                   Hour := aHourValueList[0].Hour;
                   DevId := aDevId;
                   EndValue.Value := aHourValueList[0].Value;
                   EndTime.Value := aHourValueList[0].Time;
                 end;

                 aHourValueList.Delete(0);
               end;
            1: begin // �ϴ�������ͳ��
                 aNewHourDosageList.Add.Assign(aHourDosageList[0]);
               end;
            2: begin // �ϴ�ͳ���� nil
                 if aHourValueList.Count = 0 then
                   aNewHourDosageList.Add.Assign(aHourDosageList[0])
                 else
                   aNewHourDosageList.Add.Assign(aHourDosageList[1]);
               end;
          end;

          doFill(aNewHourDosageList, aHourValueList, aTaskData.FDate, aTaskData.FHour);

          if aNewHourDosageList.Count = 1 then
            Exit;

          for i := 1 to aNewHourDosageList.Count - 1 do
          begin
            // ���һ��Сʱ���ݴ���
            aLastHourDosage := aNewHourDosageList[i];
            // ���ݱ�ʶ��������ȫͳ��
            if i = (aNewHourDosageList.Count - 1) then
              aLastHourDosage.isStatis.Value := aTaskData.FIsStatis
            else
              aLastHourDosage.isStatis.Value := True;
            aLastHourDosage.devId := aDevId;

            if aLastHourDosage.isStatis.IsTrue then
            begin
              try
                doCalcTenMinUse(aMeterId, aMeterValueCode, aLastHourDosage, aTaskData.FMeterRate.Value);
              except
              end;
            end;
          end;

          // �������ͳ�Ƶ�Сʱ����
          aTmpHourDosageList.Assign(aNewHourDosageList);
          aNewHourDosageList.Delete(0);

          if OUTPUT_STATIS_CAST then
              FStatisCast.AddCalcOnLineRate(GetTickCount - aCast);

          try
            aCast := GetTickCount;
            if not _DDDataInter._doAddMeterHourDataList(aMeterId, aNewHourDosageList, aErrorInfo) then
            begin
              aErrorInfo := aDebugHead + '����Сʱ���������ݿ��쳣��' + aErrorInfo;
              TPrLogInter.WriteLogError(aErrorInfo);
              Exit;
            end;

            _MeterCacheList.SetMeterLastHourData(aMeterId, aTmpHourDosageList);

            if OUTPUT_STATIS_CAST then
              FStatisCast.AddUpdateMeterHourData(GetTickCount - aCast);
          except
            on E: Exception do
            begin
              aErrorInfo := aDebugHead + Format('����Сʱ���������ݿ��쳣, %s', [E.Message]);
              TPrLogInter.WriteLogError(aErrorInfo);
              Exit;
            end;
          end;

          //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, '����ͳ�Ƽ�����Сʱ����(' + aMeterCode + ') '+aErrorInfo);
        finally
          aNewHourDosageList.Free;
          aTmpHourDosageList.Free;
        end;
      finally
        aHourValueList.Free;
      end;
    finally
      aHourDosageList.Free;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := aDebugHead + aErrorType + Format('����������ͳ���쳣, %s', [E.Message]);
      TPrLogInter.WriteLogError(aErrorInfo);
    end;
  end;
end;

procedure TStatisTaskPool.AddNewTasks(const aDate: TDateTime;
                                      const aHour: Integer;
                                      const aIsStatis: Boolean);
//var
//  aWorkThreadCount: Integer;
begin
  FLock.BeginWrite;
  try
    if FTaskList.Count > 0 then
      Exit;

    // ���������
    doAddNewTasks(aDate, aHour, aIsStatis);

    // �������ˣ����������̵߳ȴ�ʱ��
    _StatisDelay := STATIS_DELAY_BUSY;

    {// �鿴���޹����̣߳�û�оͳ�ʼ��
    aWorkThreadCount := FTaskList.Count div 300;
    if aWorkThreadCount < 1 then
      aWorkThreadCount := 1;
    if aWorkThreadCount > 4 then
      aWorkThreadCount := 4;

    //aWorkThreadCount := 1;

    while Length(_StatisWorkThreadArray) < aWorkThreadCount do
    begin
      SetLength(_StatisWorkThreadArray, Length(_StatisWorkThreadArray) + 1);
      _StatisWorkThreadArray[Length(_StatisWorkThreadArray) - 1] := TStatisWorkThread.Create;
    end; }

    // ��ʼ����ʱͳ��
    if OUTPUT_STATIS_CAST then
      FStatisCast.Init(FTaskList.Count);
  finally
    FLock.EndWrite;
  end;
end;

procedure TStatisTaskPool.DoTask;
var
  aTaskData: TTaskData;
begin
  if not doGetTask(aTaskData) then
  begin
    // û�����ˣ����������̵߳ȴ�ʱ��
    _StatisDelay := STATIS_DELAY_IDLE;
    Exit;
  end;

  doMeterStatis(aTaskData);

  if OUTPUT_STATIS_CAST then
    FStatisCast.IncDoCount;
end;

procedure TStatisTaskPool.ClearTask;
begin
  FLock.BeginWrite;
  try
    if FTaskList.Count = 0 then
      Exit;

    FTaskList.Clear;
  finally
    FLock.EndWrite;
  end;
end;

{ TMeterCacheList }
constructor TMeterCacheList.Create;
begin
  FMeterDict := TDictionary<Integer, THourDosageDataList>.Create;
  FLock := TPrRWLock.Create;
end;

destructor TMeterCacheList.Destroy;
var
  aHourDosageDataList: THourDosageDataList;
begin
  FLock.BeginWrite;
  try
    for aHourDosageDataList in FMeterDict.Values do
      aHourDosageDataList.Free;
    FMeterDict.Free;
  finally
    FLock.EndWrite;
    FLock.Free;
  end;
  inherited;
end;

function TMeterCacheList.GetMeterLastHourData(const aMeterId: Integer;
                                              const aDevId: Integer;
                                              const aHourDosageList: THourDosageDataList;
                                              var aErrorInfo: string): Boolean;
var
  aTmpDataList: THourDosageDataList;
begin
  Result := False;

  FLock.BeginRead;
  try
    if FMeterDict.TryGetValue(aMeterId, aTmpDataList) then
    begin
      aHourDosageList.Assign(aTmpDataList);
      Exit(True);
    end;
  finally
    FLock.EndRead;
  end;

  if not _DDDataInter._doGetMeterLastHourData(aMeterId, aDevId, aHourDosageList, aErrorInfo) then
    Exit;

  FLock.BeginWrite;
  try
    if FMeterDict.ContainsKey(aMeterId) then
    begin
      aHourDosageList.Assign(aTmpDataList);
      Exit(True);
    end;

    aTmpDataList := THourDosageDataList.Create;
    aTmpDataList.Assign(aHourDosageList);
    FMeterDict.Add(aMeterId, aTmpDataList);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

procedure TMeterCacheList.SetMeterLastHourData(const aMeterId: Integer;
                                               const aHourDosageList: THourDosageDataList);
var
  aNewData, aTmpData: THourDosageData;
  aTmpDataList: THourDosageDataList;
  i: Integer;
begin
  FLock.BeginWrite;
  try
    if FMeterDict.TryGetValue(aMeterId, aTmpDataList) then
      aTmpDataList.Clear
    else
    begin
      aTmpDataList := THourDosageDataList.Create;
      FMeterDict.Add(aMeterId, aTmpDataList);
    end;

    for i := aHourDosageList.Count - 1 downto 0 do
    begin
      aTmpData := aHourDosageList[i];
      //if aTmpData.isStatis.IsTrue then
      if aTmpData.isStatis.IsTrue and (aTmpData.DataType >= 0) then
      begin
        aNewData := aTmpDataList.Add;
        aNewData.Assign(aTmpData);
        aNewData.Hour := aNewData.Hour;
        Break;
      end;
    end;

    if aTmpDataList.Count = 0 then
    begin
      aTmpDataList.Free;
      FMeterDict.Remove(aMeterId);
      Exit;
    end;

    if aTmpDataList[0].DataType <> -1 then
      Exit;

    for i := aHourDosageList.Count - 1 downto 0 do
    begin
      aTmpData := aHourDosageList[i];
      if aTmpData.isStatis.IsTrue and (aTmpData.DataType >= 0) then
      begin
        aNewData := aTmpDataList.Add;
        aNewData.Assign(aTmpData);
        aNewData.Hour := aNewData.Hour;
        Break;
      end;
    end;
  finally
    FLock.EndWrite;
  end;
end;

end.
