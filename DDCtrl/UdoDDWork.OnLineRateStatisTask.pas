(*
 * �豸��������ͳ�Ƶ�Ԫ
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 * ˵��:
 *       ÿ5����
 *
 *       �߳���Ϣ:  ������������߳�   x 1
 *                  ִ������Ĺ����߳� x 1 ~ 4
 *
 *
 *       ����Ԫ��ʱ���԰���ƽ̨�������У�ֻ�����ݿ⽻��
 *
 *
 *
 *
 *
 * �޸�:
 * 2017-06-01 (v0.1)
 *   + ��һ�η���.
 *)

unit UdoDDWork.OnLineRateStatisTask;

interface

uses
  SysUtils, Classes, DateUtils, Generics.Collections, Windows,
  puer.System, puer.SyncObjs, puer.Json.JsonDataObjects, puer.Collections,
  UPrLogInter,
  UDDDataInter,
  UDDTopologyData,
  UDDDeviceData, UDDMeterData, UDDHourValueData, UDDHourDosageData;

const
  CHECK_INTERVAL     = 60000;     // ���� ����Ƿ�Ӧ��ͳ�����ݵļ��
  STATIS_INTERVAL    = 5;         // ���� ͳ������

  DOSAGE_NIL         = -1;        // nil ����
  DOSAGE_NORMAL      = 0;         // ��������
  DOSAGE_VIRTUAL     = 1;         // ģ������

  STATIS_DELAY_BUSY  = 80;       // ������ʱ�ļ��
  STATIS_DELAY_IDLE  = 1000;      // ������ʱ�ļ��

  //STATIS_DELAY_BUSY  = 5;       // ������ʱ�ļ��
  //STATIS_DELAY_IDLE  = 5;      // ������ʱ�ļ��

type
  TDDWorkOnLineRateStatisCtrl = class
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;
  end;

implementation

{
  TDeviceCacheList
     �豸���ͳ�����ڻ���


  TStatisMasterThread
     �������ͳ������ÿ 5 ����һ��

}

type
  // �豸���ͳ�����ڻ���
  TDeviceCacheList = class
  private
    FLastStatisDateDict: TDictionary<Int64, TDateTime>;
    FLock: TPrRWLock;
  public
    constructor Create;
    destructor Destroy; override;

    function GetLastStatisDate(const aDevId: Int64;
                               var aDate: TDateTime;
                               var aErrorInfo: string): Boolean;
    procedure SetLastStatisDate(const aDevId: Int64;
                                const aDate: TDateTime);
  end;

  // ��������
  TTaskData = record
    // ������Ϣ
    FDevId: Int64;       // �豸 ID
    FDevNo: string;      // �豸���
  end;

  // ͳ�������
  TStatisTaskPool = class
  private
    FTaskList: TList<TTaskData>;
    FLock: TPrRWLock;
    procedure doAddNewTasks;
    function doGetTask(var aTaskData: TTaskData): Boolean;
    procedure doStatis(aTaskData: TTaskData);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddNewTasks;

    procedure DoTask;

    procedure ClearTask;
  end;

  // ������������߳�
  TStatisMasterThread = class(TThread)
  private
    FEvent: TPrSimpleEvent;
    FLastStatisTime: TDateTime;
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
  _DeviceCacheList: TDeviceCacheList;
  _StatisTaskPool: TStatisTaskPool;
  _StatisMasterThread: TStatisMasterThread;
  _StatisWorkThreadArray: TArray<TStatisWorkThread>;
  _StatisDelay: Integer;

{ TDDWorkOnLineRateStatisCtrl }
class procedure TDDWorkOnLineRateStatisCtrl.Open;
begin
  _DeviceCacheList := TDeviceCacheList.Create;
  _StatisTaskPool := TStatisTaskPool.Create;
  _StatisMasterThread := TStatisMasterThread.Create;

  _StatisDelay := STATIS_DELAY_IDLE;

  while Length(_StatisWorkThreadArray) < 4 do
  begin
    SetLength(_StatisWorkThreadArray, Length(_StatisWorkThreadArray) + 1);
    _StatisWorkThreadArray[Length(_StatisWorkThreadArray) - 1] := TStatisWorkThread.Create;
  end;
end;

class function TDDWorkOnLineRateStatisCtrl.Active: Boolean;
begin
  Result := _DeviceCacheList <> nil;
end;

class procedure TDDWorkOnLineRateStatisCtrl.Close;
var
  aStatisWorkThread: TStatisWorkThread;
begin
  _StatisMasterThread.Free;
  _StatisTaskPool.ClearTask;

  for aStatisWorkThread in _StatisWorkThreadArray do
    aStatisWorkThread.Free;

  _StatisTaskPool.Free;

  _DeviceCacheList.Free;

end;

{ TDeviceCacheList }
constructor TDeviceCacheList.Create;
begin
  FLastStatisDateDict := TDictionary<Int64, TDateTime>.Create;
  FLock := TPrRWLock.Create;
end;

destructor TDeviceCacheList.Destroy;
begin
  FLock.BeginWrite;
  try
    FLastStatisDateDict.Free;
  finally
    FLock.EndWrite;
    FLock.Free;
  end;
  inherited;
end;

function TDeviceCacheList.GetLastStatisDate(const aDevId: Int64;
                                            var aDate: TDateTime;
                                            var aErrorInfo: string): Boolean;
begin
  Result := False;

  FLock.BeginRead;
  try
    if FLastStatisDateDict.TryGetValue(aDevId, aDate) then
      Exit(True);
  finally
    FLock.EndRead;
  end;

  if not _DDDataInter._doGetDeviceLastOnLineRateStatisDate(aDevId, aDate, aErrorInfo) then
    Exit;

  FLock.BeginWrite;
  try
    if FLastStatisDateDict.ContainsKey(aDevId) then
      Exit(True);

    FLastStatisDateDict.Add(aDevId, aDate);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

procedure TDeviceCacheList.SetLastStatisDate(const aDevId: Int64;
                                             const aDate: TDateTime);
begin
  FLock.BeginWrite;
  try
    FLastStatisDateDict.AddOrSetValue(aDevId, aDate);
  finally
    FLock.EndWrite;
  end;
end;

{ TStatisMasterThread }
constructor TStatisMasterThread.Create;
begin
  inherited Create(False);
  FEvent := TPrSimpleEvent.Create;
  FLastStatisTime := -1;
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
  aNow: TDateTime;
begin
  inherited;

  while not Terminated do
  begin
    aNow := Now;
    if MinutesBetween(aNow, FLastStatisTime) >= STATIS_INTERVAL then
    begin
      try
        _StatisTaskPool.AddNewTasks;
      except
      end;
      FLastStatisTime := aNow;
    end;

    if FEvent.WaitFor(CHECK_INTERVAL) = wrSignaled then
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

procedure TStatisTaskPool.doAddNewTasks;
var
  aTaskData: TTaskData;
  aDevice: TTopologyData;
  aDeviceList: TTopologyDataList;
begin
  aDeviceList := TTopologyDataList.Create;
  try
    _DDDataInter._doGetTopologyList(aDeviceList);

    for aDevice in aDeviceList do
    begin
      aTaskData.FDevId := aDevice.id.Value;
      aTaskData.FDevNo := aDevice.devId.AsString;
      FTaskList.Add(aTaskData);
    end;
  finally
    aDeviceList.Free;
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

function doGetLastStatisDate(const aDevId: Int64): TDateTime;
var
  aErrorInfo: string;
  aLastStatisDate: TDateTime;
begin
  if _DeviceCacheList.GetLastStatisDate(aDevId, aLastStatisDate, aErrorInfo) then
    Result := Trunc(aLastStatisDate)
  else
    Result := Trunc(Now) - 1;
end;

procedure TStatisTaskPool.doStatis(aTaskData: TTaskData);
var
  aDevId: Int64;
  aLastStatisDate: TDate;
  aBeginDate: TDate;
  aEndDate: TDate;

  aOnLineRate: RDouble;
  aErrorInfo: string;
begin
  aDevId := aTaskData.FDevId;
  try
    // ȡ�豸���ͳ�������ʵ�ʱ��
    aLastStatisDate := doGetLastStatisDate(aDevId);

    aBeginDate := Trunc(aLastStatisDate) + 1;
    aEndDate := Trunc(Now);

    while aBeginDate < aEndDate do
    begin
      if _DDDataInter._doCalcOnLineRate(aTaskData.FDevId, aBeginDate, aBeginDate + 1, aOnLineRate, aErrorInfo) then
      begin
        _DDDataInter._doUpdateOnLineRate(aTaskData.FDevId, aBeginDate, aOnLineRate, True, aErrorInfo);
        _DeviceCacheList.SetLastStatisDate(aTaskData.FDevId, aBeginDate);
      end
      else
      begin
        aErrorInfo := '[' + aTaskData.FDevNo + ']' + '[' + DateToStr(aBeginDate) + ']'  + Format('ͳ���豸������ʧ��, %s', [aErrorInfo]);
        TPrLogInter.WriteLogError(aErrorInfo);
        Exit;
      end;
      aBeginDate := aBeginDate + 1;
    end;

    if _DDDataInter._doCalcOnLineRate(aTaskData.FDevId, aBeginDate, Now, aOnLineRate, aErrorInfo) then
    begin
      _DDDataInter._doUpdateOnLineRate(aTaskData.FDevId, aBeginDate, aOnLineRate, False, aErrorInfo);
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := '[' + aTaskData.FDevNo + ']' + Format('ͳ���������쳣, %s', [E.Message]);
      TPrLogInter.WriteLogError(aErrorInfo);
    end;
  end;
end;

procedure TStatisTaskPool.AddNewTasks;
//var
//  aWorkThreadCount: Integer;
begin
  FLock.BeginWrite;
  try
    if FTaskList.Count > 0 then
      Exit;

    // ���������
    doAddNewTasks;

    //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, '��ʼͳ���豸������ ' + IntToStr(FTaskList.Count));

    // �������ˣ����������̵߳ȴ�ʱ��
    _StatisDelay := STATIS_DELAY_BUSY;

    // �鿴���޹����̣߳�û�оͳ�ʼ��
    {aWorkThreadCount := FTaskList.Count div 300;
    if aWorkThreadCount < 1 then
      aWorkThreadCount := 1;
    if aWorkThreadCount > 4 then
      aWorkThreadCount := 4;

    while Length(_StatisWorkThreadArray) < aWorkThreadCount do
    begin
      SetLength(_StatisWorkThreadArray, Length(_StatisWorkThreadArray) + 1);
      _StatisWorkThreadArray[Length(_StatisWorkThreadArray) - 1] := TStatisWorkThread.Create;
    end; }
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

  doStatis(aTaskData);
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

{ TStatisWorkThread }
constructor TStatisWorkThread.Create;
begin
  inherited Create(False);
  // �����߳����ȼ�
  //Self.Priority := tpLowest{tpLower};
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

end.
