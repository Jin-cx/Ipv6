(*
 * 设备日在线率统计单元
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 * 说明:
 *       每5分钟
 *
 *       线程信息:  发布任务的主线程   x 1
 *                  执行任务的工作线程 x 1 ~ 4
 *
 *
 *       本单元随时可以剥离平台独立运行，只和数据库交互
 *
 *
 *
 *
 *
 * 修改:
 * 2017-06-01 (v0.1)
 *   + 第一次发布.
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
  CHECK_INTERVAL     = 60000;     // 毫秒 检查是否应该统计数据的间隔
  STATIS_INTERVAL    = 5;         // 分钟 统计周期

  DOSAGE_NIL         = -1;        // nil 数据
  DOSAGE_NORMAL      = 0;         // 正常数据
  DOSAGE_VIRTUAL     = 1;         // 模拟数据

  STATIS_DELAY_BUSY  = 80;       // 有任务时的间隔
  STATIS_DELAY_IDLE  = 1000;      // 无任务时的间隔

  //STATIS_DELAY_BUSY  = 5;       // 有任务时的间隔
  //STATIS_DELAY_IDLE  = 5;      // 无任务时的间隔

type
  TDDWorkOnLineRateStatisCtrl = class
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;
  end;

implementation

{
  TDeviceCacheList
     设备最后统计日期缓存


  TStatisMasterThread
     负责添加统计任务，每 5 分钟一次

}

type
  // 设备最后统计日期缓存
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

  // 任务详情
  TTaskData = record
    // 基础信息
    FDevId: Int64;       // 设备 ID
    FDevNo: string;      // 设备编号
  end;

  // 统计任务池
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

  // 发布任务的主线程
  TStatisMasterThread = class(TThread)
  private
    FEvent: TPrSimpleEvent;
    FLastStatisTime: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

  // 执行任务的工作线程
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
    // 取设备最后统计在线率的时间
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
        aErrorInfo := '[' + aTaskData.FDevNo + ']' + '[' + DateToStr(aBeginDate) + ']'  + Format('统计设备在线率失败, %s', [aErrorInfo]);
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
      aErrorInfo := '[' + aTaskData.FDevNo + ']' + Format('统计在线率异常, %s', [E.Message]);
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

    // 添加新任务
    doAddNewTasks;

    //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, '开始统计设备在线率 ' + IntToStr(FTaskList.Count));

    // 有任务了，调整工作线程等待时间
    _StatisDelay := STATIS_DELAY_BUSY;

    // 查看有无工作线程，没有就初始化
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
    // 没任务了，调整工作线程等待时间
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
  // 降低线程优先级
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
