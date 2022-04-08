(*
 * 通讯模块回调的处理单元
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 * 说明: 处理 DDComm 触发的回调 (收发报文和Broker在离线)
 *       线程信息:  获取网关IP的线程池     x 1 ~ 5
 *                  保存实时数据线程池     x 1 ~ 5
 *                  报文处理线程           x 2
 *
 *
 * 修改:
 * 2016-12-08 (v0.1)
 *   + 第一次发布.
 *)

unit UdoDDWork.CommIO;

interface

uses
  SysUtils, Classes, Windows, Generics.Collections, DateUtils,
  puer.System, puer.Json.JsonDataObjects, puer.SyncObjs,
  UPrLogInter,

  IdHTTP,
  CnThreadPool,
  UDDCommInter, UDDTopoCacheInter, UDDDataInter,
  UDDModelsInter,
  UDDTopologyData, UDDCommData, UDDMonitorData,
  UDDBrokerData, UDDGatewayData, UDDDeviceData,
  UDDDeviceRealData,
  UdoDDWork.Monitor, UdoDDWork.CommStatis, UdoDDCache.Topo;

const
  LOG_BROKER_CONNECT    = '报文服务『%s(%s)』连接成功';
  LOG_BROKER_DISCONNECT = '报文服务『%s(%s)』连接断开';

  COMM_DATA = '{"brokerId":%d,"brokerDevId":"%s","gatewayDevId":"%s","gatewayIp":"%s","data":%s,"time":"%s"}';

type
  TDDWorkCommIOCtrl = class
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;

    // Event
    class procedure ProcessRequest_SaveRealData(Sender: TCnThreadPool; aDataObj: TCnTaskDataObject; aThread: TCnPoolingThread);
    class procedure ProcessRequest_OnLine(Sender: TCnThreadPool; aDataObj: TCnTaskDataObject; aThread: TCnPoolingThread);


    class function GetRealDataTaskPoolInfo(var aAllPoolCount: Integer;
                                           var aUsePoolCount: Integer;
                                           var aErrorInfo: string): Boolean;

    class procedure ReceiveMQTTFromRest(const aBrokerId: Integer;
                                        const aTopic: string;
                                        const aPayload: string);
  end;

  // 通知推送操作
  TDebugCtrl = class
    // 设置报文监测启动
    class procedure SetCommMonitorActive(const aActive: Boolean);
    // 获取报文监测启动状态
    class function GetCommMonitorActive: Boolean;
    // 格式化报文(用于推送)
    class function FormatSendCommData(const aBrokerId: Integer; const aCommData: TCommDataInfo; var aBrokerDevNo: string): string;
    class function FormatReceiveCommData(const aBrokerId: Integer; const aCommData: TCommDataInfo; var aBrokerDevNo: string): string;
    // Broker 连接状态
    class procedure BrokerCommStateChanged(const aBrokerId: Integer;
                                           const aCommState: TCommState);
    // Broker 网关列表变化
    class procedure BrokerGatewayListChanged(const aBrokerId: Integer);
    // 网关在线离线状态
    class procedure GatewayCommStateChanged(const aGatewayId: Integer;
                                            const aCommState: TCommState;
                                            const aGatewayIp: string = '');
    // 网关收到主动上报的数据
    class procedure GatewayReceiveData(const aGatewayId: Integer);
  end;

  TOnlineData = class(TCnTaskDataObject)
  private
    FBrokerId: Integer;
    FTaskBeginTime: TDateTime;
    FCommDataInfo: TCommDataInfo;
  public
    constructor Create(const aBrokerId: Integer; const aCommDataInfo: TCommDataInfo);

    function Clone: TCnTaskDataObject; override;

    property BrokerId: Integer read FBrokerId;
    property CommDataInfo: TCommDataInfo read FCommDataInfo;
  end;

  //
  TCommCache = class
  private
    FCommList: TList<TCommDataInfo>;
    FLock: TPrRWLock;
    FCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddCommData(const aCommData: TCommDataInfo);
    function GetCommData(var aCommData: TCommDataInfo): Boolean;
  end;

  //
  TRealDataCache = class
  private
    FRealDataList: TList<TRealDataInfo>;
    FLock: TPrRWLock;
    FCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddRealData(const aRealData: TRealDataInfo);
    function GetRealData(var aRealData: TRealDataInfo): Boolean;

    procedure doSave(const aBeginTime: TDateTime);
  end;

  // 执行保存任务工作线程
  TSaveRealDataWork = class(TThread)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

  // 执行保存任务的主线程
  TSaveRealDataThread = class(TThread)
  private
    FEvent: TPrSimpleEvent;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

  // 执行任务的工作线程
  TWorkThread = class(TThread)
  private
    FEvent: TPrSimpleEvent;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

// ******************* DDComm 回调触发事件 ******************* //
// 发送消息
procedure OnSendEvent(const aCallbackId: Integer;
                      const aCommDataInfo: TCommDataInfo); stdcall;
// 收到消息
procedure OnReceiveEvent(const aCallbackId: Integer;
                         const aCommDataInfo: TCommDataInfo); stdcall;
// 连接到 Broker
procedure OnConnectEvent(const aCallbackId: Integer); stdcall;
// Broker断开连接
procedure OnDisconnectEvent(const aCallbackId: Integer); stdcall;

procedure doReceiveMQTTFromRest(const aBrokerId: Integer; const aTopic: string; const aPayload: string); stdcall;

exports
  doReceiveMQTTFromRest;

implementation

var
  _CommMonitorActive: Boolean;
  _CommCache: TCommCache;
  _RealDataCache: TRealDataCache;
  _WorkThreadArray: TArray<TWorkThread>;
  _SaveRealDataMasterThread: TSaveRealDataThread;
  _SaveRealDataWorkCount: Integer;
  _SaveRealDataThreadPool: TCnThreadPool;

  _OnLineThreadPool: TCnThreadPool;

  _QueryGatewayCount: Integer; // 查询网关

procedure doReceiveMQTTFromRest(const aBrokerId: Integer; const aTopic: string; const aPayload: string);
begin
  TDDWorkCommIOCtrl.ReceiveMQTTFromRest(aBrokerId, aTopic, aPayload);
end;

procedure AddTask_OnLine(const aBrokerId: Integer; const aCommDataInfo: TCommDataInfo);
var
  aOnlineData: TOnlineData;
begin
  aOnlineData := TOnlineData.Create(aBrokerId, aCommDataInfo);
  try
    _OnLineThreadPool.AddRequest(aOnlineData);
  except
    on E: Exception do
    begin
      aOnlineData.Free;
      TPrLogInter.WriteLogError('Add Online Task Error: ' + E.Message);
    end;
  end;
end;

function doParseDevice(const aReceiveTime: TDateTime;
                       const aJsonData: TJsonObject;
                       var aErrorInfo: string): Boolean;
var
  aDevId: string;
  aDevice: TDeviceData;
  aRealData: string;
  aMasterValue: string;
  aMeterValue: string;
  aDataState: Integer;
  aRealDataInfo: TRealDataInfo;
  aUserCode: string;
  aUserCodeList: TStringList;
  aTopic: string;
  aJson: TJsonObject;
  aMsg: string;
  aError: string;

  aRealDataTime: TDateTime;
begin
  Result := False;

  // 必须有设备编号，即算无效数据
  aDevId := aJsonData.S['_devid'];
  if aDevId = '' then
    Exit;

  aDevice := TDeviceData.Create;
  try
    if not _DDTopoCacheInter._doGetDeviceInfoByDevId(aDevId, aDevice) then
      Exit;
    if not _DDModelsInter._doGetDeviceModelInfo(aDevice.devModel.AsString, aDevice.deviceModel) then
      Exit;

    // 离线
    if SameText(aJsonData.S['_status'], 'offline') or aJsonData.Contains('error') then
    begin
      aError := Copy('设备离线,' + aJsonData.S['error'], 1, 64);

      if (aDevice.commState = csOnLine) or ((aDevice.commState = csOffLine) and (aDevice.doubtInfo.AsString <> aError)) then
      begin
        _DDTopoCacheInter._doSetDeviceOffLine(aDevice.id.Value, aError);
        _DDDataInter._doSetTopoCommState(aDevice.id.Value, csOffLine, aError);

        //
        if aDevice.parentId.AsInteger >= 863 then
        TDDMonitorCtrl.SendWarn(aDevice.name.AsString + ' (' + aDevice.devId.AsString + ')', '设备离线', FormatDateTime('YYYY-MM-DD hh:mm:ss', Now), aError);
      end;
      Exit;
    end;

    if aJsonData.Contains('_realDataTime') then
      aRealDataTime := aJsonData.RT['_realDataTime'].Value
    else
      aRealDataTime := aReceiveTime;

    // 在线
    if aDevice.deviceModel.ParseRealData_V3 then
    begin
      if not _DDModelsInter._doParseDeviceRealData_V3(aDevice.devModel.AsString,
                                                      aDevId,
                                                      aDevice.lastValidRealData.AsJsonStr,
                                                      aRealDataTime,
                                                      aJsonData.ToJson(True),
                                                      aRealData,
                                                      aMasterValue,
                                                      aMeterValue,
                                                      aDataState,
                                                      aErrorInfo) then
      begin
        if aDevice.commState = csOnLine then
        begin
          _DDTopoCacheInter._doSetDeviceOffLine(aDevice.id.Value, '解析设备数据异常');
          _DDDataInter._doSetTopoCommState(aDevice.id.Value, csOffLine, '解析设备数据异常');
        end;
        TPrLogInter.WriteLogError('ParseRealData_V3 异常,' + '['+aDevice.deviceModel.Model+']' + aErrorInfo);
        Exit;
      end;
    end
    else if aDevice.deviceModel.ParseRealData_V2 then
    begin
      if not _DDModelsInter._doParseDeviceRealData_V2(aDevice.devModel.AsString,
                                                      aDevId,
                                                      aDevice.lastValidRealData.AsJsonStr,
                                                      aJsonData.ToJson(True),
                                                      aRealData,
                                                      aMasterValue,
                                                      aMeterValue,
                                                      aDataState,
                                                      aErrorInfo) then
      begin
        if aDevice.commState = csOnLine then
        begin
          _DDTopoCacheInter._doSetDeviceOffLine(aDevice.id.Value, '解析设备数据异常');
          _DDDataInter._doSetTopoCommState(aDevice.id.Value, csOffLine, '解析设备数据异常');
        end;
        Exit;
      end;
    end
    else if aDevice.deviceModel.ParseRealData_V1 then
    begin
      if not _DDModelsInter._doParseDeviceRealData_V1(aDevice.devModel.AsString,
                                                      aJsonData.ToJson(True),
                                                      aRealData,
                                                      aMasterValue,
                                                      aMeterValue,
                                                      aDataState,
                                                      aErrorInfo) then
      begin
        if aDevice.commState = csOnLine then
        begin
          _DDTopoCacheInter._doSetDeviceOffLine(aDevice.id.Value, '解析设备数据异常');
          _DDDataInter._doSetTopoCommState(aDevice.id.Value, csOffLine, '解析设备数据异常');
        end;
        Exit;
      end;
    end
    else
    begin
      aDataState := 0;
      if not _DDModelsInter._doParseDeviceRealData(aDevice.devModel.AsString,
                                                   aJsonData.ToJson(True),
                                                   aRealData,
                                                   aMasterValue,
                                                   aMeterValue,
                                                   aErrorInfo) then
      begin
        if aDevice.commState = csOnLine then
        begin
          _DDTopoCacheInter._doSetDeviceOffLine(aDevice.id.Value, '解析设备数据异常');
          _DDDataInter._doSetTopoCommState(aDevice.id.Value, csOffLine, '解析设备数据异常');
        end;
        Exit;
      end;
    end;

    if aDataState = 99 then
      Exit(True);

    if aDevice.commState = csOffLine then
    begin
      _DDTopoCacheInter._doSetDeviceOnLine(aDevice.id.Value);
      _DDDataInter._doSetTopoCommState(aDevice.id.Value, csOnLine, '');
    end;

    if not _DDTopoCacheInter._doSetDeviceRealData(aDevice.id.Value,
                                                  FormatDateTime(FormatSettings.LongDateFormat + ' ' + FormatSettings.LongTimeFormat, aRealDataTime),
                                                  aRealData,
                                                  aMasterValue,
                                                  aMeterValue,
                                                  aDataState) then
    begin
      TPrLogInter.WriteLogError('设置实时数据到缓存异常');
    end;

    aRealDataInfo.DevId := aDevice.id.Value;
    aRealDataInfo.DevNo := aDevice.devId.Value;
    aRealDataInfo.RealTime := aRealDataTime;
    aRealDataInfo.RealData := aRealData;
    aRealDataInfo.MasterValue := aMasterValue;
    aRealDataInfo.MeterValue := aMeterValue;
    aRealDataInfo.DataState := aDataState;

    _RealDataCache.AddRealData(aRealDataInfo);

    // 检查订阅并推送
    //PushRealData(aRealDataInfo);
    aUserCodeList := TStringList.Create;
    aJson := TJsonObject.Create;
    try
      if TDDCacheTopoCtrl.GetTerminalUserList(aDevice.id.Value, aUserCodeList) then
      begin
        aJson.S['devNo'] := aRealDataInfo.DevNo;
        aJson.S['realTime'] := DateTimeToStr(aRealDataTime);
        aJson.O['realData'].FromJSON(aRealData);
        aMsg := aJson.ToJSON(True);

        for aUserCode in aUserCodeList do
        begin
          aTopic := LowerCase(aUserCode + '/realdata');
          TDDMonitorCtrl.SendNotice(aTopic, aMsg);
        end;
      end;
    finally
      aJson.Free;
      aUserCodeList.Free;
    end;
  finally
    aDevice.Free;
  end;

  Result := True;
end;

{
  ============ 收到网关数据 解析 流程 =====================

  1. 收到网关报文
        信息头: 网关编号、网关型号、网关设备列表版本
        消息体:

  2. 根据网关型号初步解析报文



}

function doParseUpData(const aBrokerId: Integer;
                       const aCommDataInfo: TCommDataInfo;
                       var aGatewayId: Int64): Boolean;
var
  aJsonArray: TJsonArray;
  aJsonItem: TJsonObject;
  aJsonBase: TJsonBaseObject;
  aGateway: TGatewayData;
  aErrorInfo: string;
  i: Integer;
begin
  Result := False;
  try
    // 判断网关存在
    aGateway := TGatewayData.Create;
    try
      if not _DDTopoCacheInter._doFindGatewayInfo(aBrokerId,
                                                  aCommDataInfo.From._devid,
                                                  aGateway,
                                                  aErrorInfo) then
        Exit;

      // 收到报文，网关也算在线
      if aGateway.commState = csOffLine then
        AddTask_OnLine(aBrokerId, aCommDataInfo);
        //TOnlineWork.Create(aBrokerId, aCommDataInfo);

      aGatewayId := aGateway.id.Value;

      // 判断置疑
      if aGateway.runState.AsString <> aCommDataInfo.From._runstate then
      begin
        aGateway.devState := dsDoubt;
        aGateway.doubtInfo.Value := '设备列表版本号不一致';
      end;
    finally
      aGateway.Free;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := aCommDataInfo.From._devid;
      TPrLogInter.WriteLogError(aErrorInfo+'解析数据异常: '+ E.Message);
      TPrLogInter.WriteLogError(aCommDataInfo.CommStr);
      Result := False;
      Exit;
    end;
  end;

  try
    try
      aJsonBase := TJsonBaseObject.Parse(aCommDataInfo.CmdData);
    except
      Exit;
    end;
    try
      if aJsonBase is TJsonArray then
      begin
        aJsonArray := aJsonBase as TJsonArray;
        if aJsonArray.Count = 0 then
          Exit;

        for i := 0 to aJsonArray.Count - 1 do
        begin
          aJsonItem := aJsonArray.O[i];
          doParseDevice(aCommDataInfo.ReceiveTime, aJsonItem, aErrorInfo);
        end;
      end
      else if aJsonBase is TJsonObject then
        doParseDevice(aCommDataInfo.ReceiveTime, aJsonBase as TJsonObject, aErrorInfo)
    finally
      aJsonBase.Free;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      aErrorInfo := aCommDataInfo.From._devid;
      TPrLogInter.WriteLogError(aErrorInfo+'解析数据异常: '  + E.Message);
      TPrLogInter.WriteLogError(aCommDataInfo.CommStr);
      Result := False;
    end;
  end;
end;

function GetGatewayIp(const aBrokerId: Integer; const aDevNo, aDevModel: string): string;
var
  aCmd, aCmdData: string;
  aIp: string;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode, aErrorInfo: string;
begin
  Result := '';

  if not _DDModelsInter._doCmd_GetIp(aDevModel, aCmd, aCmdData, aErrorInfo) then
  begin
    TPrLogInter.WriteLogError('获取 取IP命令失败 : ' + aErrorInfo);
    Exit;
  end;

  aSendCmdData.Cmd := aCmd;
  aSendCmdData.CmdData := aCmdData;
  if _DDCommInter._SendCmdSync(aBrokerId,
                               aDevNo,
                               aSendCmdData,
                               aReceiveCmdData,
                               5,
                               aErrorCode,
                               aErrorInfo) then
  begin
    if aReceiveCmdData.StatusCode <> '0' then
      Exit;

    if not _DDModelsInter._doParse_GetIp(aDevModel, aReceiveCmdData.ResponseData, aIp, aErrorInfo) then
      Exit;

    Result := aIp;
  end
  else
    TPrLogInter.WriteLogError('获取 ['+aDevModel+' '+aDevNo+'] IP失败 : ' + aErrorInfo);
end;

procedure doSetGatewayOffLine(const aBrokerId: Integer;
                              const aGatewayDevId: string);
var
  aGatewayId: Int64;
  aGateway: TGatewayData;
  aErrorInfo: string;
  aIsTemp: Boolean;
  aDeviceList: TDeviceDataList;
  aDevice: TDeviceData;
begin
  if _DDTopoCacheInter._doSetGatewayOffLine(aBrokerId,
                                            aGatewayDevId,
                                            '网关离线',
                                            aGatewayId,
                                            aIsTemp) then
  begin
    if aIsTemp then
    begin
      if _DDDataInter._doDeleteTopology(RInteger.Parse(aGatewayId), aErrorInfo)
         and
         _DDTopoCacheInter._doDeleteGateway(RInteger.Parse(aGatewayId), aErrorInfo) then
        TDebugCtrl.BrokerGatewayListChanged(aBrokerId);
    end
    else
    begin
      _DDDataInter._doSetTopoCommState(aGatewayId, csOffLine, '网关离线');

      TDebugCtrl.GatewayCommStateChanged(aGatewayId, csOffLine);

      //
      if aBrokerId > 413 then
      begin
        aGateway := TGatewayData.Create;
        try
          if _DDTopoCacheInter._doFindGatewayInfo(aBrokerId, aGatewayDevId, aGateway, aErrorInfo) then
            TDDMonitorCtrl.SendWarn(aGateway.name.AsString + ' (' + aGateway.devId.AsString + ')', '网关离线', FormatDateTime('YYYY-MM-DD hh:mm:ss', Now), '');
        finally
          aGateway.Free;
        end;
      end;

      aDeviceList := TDeviceDataList.Create;
      try
        if not _DDTopoCacheInter._doGetDeviceList(RInteger.Parse(aGatewayId),
                                                  aDeviceList,
                                                  aErrorInfo) then
          Exit;

        for aDevice in aDeviceList do
        begin
          if aDevice.commState = csOnLine then
          begin
            _DDTopoCacheInter._doSetDeviceOffLine(aDevice.id.Value, '网关离线');
            _DDDataInter._doSetTopoCommState(aDevice.id.Value,
                                             csOffLine,
                                             '网关离线');
          end;
        end;
      finally
        aDeviceList.Free;
      end;
    end;
  end;
end;

procedure doSetBrokerCommState(const aBrokerId: Integer; const aCommState: TCommState);
var
  aBrokerData: TBrokerData;
  aLogCode: string;
  aLogInfo: string;
  aErrorInfo: string;
begin
  aBrokerData := TBrokerData.Create;
  try
    if not _DDTopoCacheInter._doGetBrokerInfo(aBrokerId, aBrokerData, aErrorInfo) then
      Exit;

    // 状态一致，退出
    if aBrokerData.commState = aCommState then
      Exit;

    // 设置通讯状态 到 缓存
    if not _DDTopoCacheInter._doSetBrokerCommState(aBrokerId, aCommState) then
      Exit;

    // 设置通讯状态 到 数据
    _DDDataInter._doSetTopoCommState(aBrokerId, aCommState, '');

    // 写 RunLog
    aLogCode := '';
    if aCommState = csOnLine then
      aLogInfo := Format(LOG_BROKER_CONNECT, [aBrokerData.name.AsString, aBrokerData.devId.AsString])
    else
      aLogInfo := Format(LOG_BROKER_DISCONNECT, [aBrokerData.name.AsString, aBrokerData.devId.AsString]);
    _DDDataInter._doWriteLog(LOG_TYPE_RUN, LOG_KIND_INFO, aLogCode, aLogInfo, 0, '', '', '', aErrorInfo);

    // 发通知
    TDebugCtrl.BrokerCommStateChanged(aBrokerId, aCommState);
  finally
    aBrokerData.Free;
  end;
end;

{ TDDWorkCommIOCtrl }
class procedure TDDWorkCommIOCtrl.Open;
begin
  //_OnLineLock := TPrSemaphore.Create(5, 5);
  _QueryGatewayCount := 0;

  // 当前尚未保存的实时数据数量
  _SaveRealDataWorkCount := 0;

  _CommCache := TCommCache.Create;
  _RealDataCache := TRealDataCache.Create;

  // 处理报文的线程
  while Length(_WorkThreadArray) < 5 do
  begin
    SetLength(_WorkThreadArray, Length(_WorkThreadArray) + 1);
    _WorkThreadArray[Length(_WorkThreadArray) - 1] := TWorkThread.Create;
  end;
  TPrLogInter.WriteLogInfo('处理报文的线程: ' + IntToStr(_WorkThreadArray[0].ThreadID));
  TPrLogInter.WriteLogInfo('处理报文的线程: ' + IntToStr(_WorkThreadArray[1].ThreadID));

  // 保存实时数据
  _SaveRealDataThreadPool := TCnThreadPool.Create(nil);
  with _SaveRealDataThreadPool do
  begin
    OnProcessRequest := TDDWorkCommIOCtrl.ProcessRequest_SaveRealData;
    //AdjustInterval := 2 * 1000;
    //MinAtLeast := False;
    ThreadDeadTimeout := 10 * 1000;
    ThreadsMinCount := 1;
    ThreadsMaxCount := 5;
    uTerminateWaitTime := 500;
  end;
  _SaveRealDataMasterThread := TSaveRealDataThread.Create;

  _OnLineThreadPool := TCnThreadPool.Create(nil);
  with _OnLineThreadPool do
  begin
    OnProcessRequest := TDDWorkCommIOCtrl.ProcessRequest_OnLine;
    //AdjustInterval := 5 * 1000;
    //MinAtLeast := False;
    ThreadDeadTimeout := 10 * 1000;
    ThreadsMinCount := 1;
    ThreadsMaxCount := 5;
    uTerminateWaitTime := 500;
  end;

  _DDCommInter._SetCallBackEvent(@OnSendEvent, @OnReceiveEvent, @OnConnectEvent, @OnDisconnectEvent);
end;

class function TDDWorkCommIOCtrl.Active: Boolean;
begin
  Result := _CommCache <> nil;
end;

class procedure TDDWorkCommIOCtrl.Close;
var
  aWorkThread: TWorkThread;
  //aSaveRealDataThread: TSaveRealDataThread;
begin
  TPrLogInter.WriteLogInfo('开始关闭 CommIO');

  _DDCommInter._SetCallBackEvent(nil, nil, nil, nil);
  TPrLogInter.WriteLogInfo('取消回调');

  _SaveRealDataMasterThread.Free;

  TPrLogInter.WriteLogInfo('SaveRealDataMasterThread Free');

  for aWorkThread in _WorkThreadArray do
    aWorkThread.Free;
  TPrLogInter.WriteLogInfo('WorkThreadArray Free');

  while TPrInterLock.GetValue(_SaveRealDataWorkCount) > 0 do
    TPrSimpleEvent.Sleep(200);
  TPrLogInter.WriteLogInfo('SaveRealDataWorkCount 归0');

  _SaveRealDataThreadPool.Free;
  TPrLogInter.WriteLogInfo('SaveRealDataThreadPool Free');

  _OnLineThreadPool.Free;
  TPrLogInter.WriteLogInfo('OnLineThreadPool Free');

  _RealDataCache.Free;
  TPrLogInter.WriteLogInfo('RealDataCache Free');
  _CommCache.Free;
  TPrLogInter.WriteLogInfo('CommCache Free');

  //_OnLineLock.Free;
end;

class procedure TDDWorkCommIOCtrl.ProcessRequest_SaveRealData(Sender: TCnThreadPool; aDataObj: TCnTaskDataObject; aThread: TCnPoolingThread);
var
  aBeginTime: TDateTime;
begin
  aBeginTime := TOnlineData(aDataObj).FTaskBeginTime;
  _RealDataCache.doSave(aBeginTime);
end;

class procedure TDDWorkCommIOCtrl.ProcessRequest_OnLine(Sender: TCnThreadPool; aDataObj: TCnTaskDataObject; aThread: TCnPoolingThread);
var
  aTask: TOnlineData;
  aBrokerId: Integer;
  aDevNo: string;
  aDevModel: string;
  aGatewayId: Int64;
  aErrorInfo: string;
  aTmpGateway: TGatewayData;
  aGatewayIp, aVersion: string;
  aBroker: TBrokerData;
begin
  try
    aTask := TOnlineData(aDataObj);

    aBrokerId := aTask.BrokerId;
    aDevNo := aTask.CommDataInfo.From._devid;
    aDevModel := aTask.CommDataInfo.From._model;
    aVersion := aTask.CommDataInfo.From._version;

    aGatewayIp := GetGatewayIp(aBrokerId, aDevNo, aDevModel);
    if aGatewayIp = '' then
      Exit;

    if _DDTopoCacheInter._doSetGatewayOnLine(aBrokerId, aDevNo, aGatewayIp, aGatewayId) then
    begin
      _DDDataInter._doSetTopoCommState(aGatewayId, csOnLine, '');
      _DDDataInter._doUpdateTopologyIp(aGatewayId, aGatewayIp, aVersion, aDevModel, aErrorInfo);

      TDebugCtrl.GatewayCommStateChanged(aGatewayId, csOnLine, aGatewayIp);
    end
    else
    begin
      aBroker := TBrokerData.Create;
      try
        if _DDTopoCacheInter._doGetBrokerInfo(aBrokerId, aBroker, aErrorInfo) and
           not aBroker.hasGateway.IsTrue then
        begin
          // 添加临时设备
          aTmpGateway := TGatewayData.Create;
          try
            aTmpGateway.parentId.Value := aBrokerId;
            aTmpGateway.name.Value := aDevNo + '(未知)';
            aTmpGateway.devId.Value := aDevNo;
            aTmpGateway.devModel.Value := aDevModel;
            aTmpGateway.ip.Value := aGatewayIp;
            aTmpGateway.version.Value := aVersion;
            aTmpGateway.commState := csOnLine;
            aTmpGateway.isTemp.Value := True;
            aTmpGateway.UpdateData;

            if _DDDataInter._doAddTopology(aTmpGateway, aErrorInfo) and
               _DDTopoCacheInter._doAddGateway(aTmpGateway, aErrorInfo) then
            begin
              _DDDataInter._doSetTopoCommState(aTmpGateway.id.Value, csOnLine, '');
              TDebugCtrl.BrokerGatewayListChanged(aBrokerId);
            end;
          finally
            aTmpGateway.Free;
          end;
        end;
      finally
        aBroker.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := Format('网关在线检测异常, %s', [E.Message]);
      TPrLogInter.WriteLogError(aErrorInfo);
    end;
  end;
end;

class function TDDWorkCommIOCtrl.GetRealDataTaskPoolInfo(var aAllPoolCount: Integer;
  var aUsePoolCount: Integer; var aErrorInfo: string): Boolean;
begin
  Result := True;
  aAllPoolCount := _SaveRealDataThreadPool.ThreadCount;
  aUsePoolCount := _SaveRealDataThreadPool.TaskCount;
end;

class procedure TDDWorkCommIOCtrl.ReceiveMQTTFromRest(const aBrokerId: Integer;
  const aTopic: string; const aPayload: string);

  function GetSenderFromTopic(const aTopic: string): string;
  var
    aMarkIndex: Integer;
  begin
    aMarkIndex := Pos('/', aTopic);
    if aMarkIndex <> 0 then
      Result := Copy(aTopic, aMarkIndex + 1, MaxInt);
  end;

var
  aCommDataInfo: TCommDataInfo;
begin
  aCommDataInfo := UDDCommData._ParseCommData(aPayload);
  aCommDataInfo.BrokerId := aBrokerId;
  aCommDataInfo.Sender := GetSenderFromTopic(aTopic);
  aCommDataInfo.ReceiveTime := Now;
  OnReceiveEvent(aBrokerId, aCommDataInfo);
end;

{ TDebugCtrl }
class procedure TDebugCtrl.SetCommMonitorActive(const aActive: Boolean);
var
  aMsg: string;
begin
  _CommMonitorActive := aActive;

  if _CommMonitorActive then
    aMsg := 'open'
  else
    aMsg := 'close';
  TDDMonitorCtrl.SendNotice(MONITOR_TYPE_MONITOR_STATE, aMsg);
end;

class function TDebugCtrl.GetCommMonitorActive: Boolean;
begin
  Result := _CommMonitorActive;
end;

class function TDebugCtrl.FormatSendCommData(const aBrokerId: Integer; const aCommData: TCommDataInfo; var aBrokerDevNo: string): string;
var
  aBroker: TBrokerData;
  aBrokerDevId: string;
  aGatewayData: TGatewayData;
  aGatewayIp: string;
  aErrorInfo: string;
begin
  aBroker := TBrokerData.Create;
  try
    if _DDTopoCacheInter._doGetBrokerInfo(aBrokerId, aBroker, aErrorInfo) then
      aBrokerDevId := aBroker.devId.AsString;

    aBrokerDevNo := aBrokerDevId;

    aGatewayData := TGatewayData.Create;
    try
      if _DDTopoCacheInter._doFindGatewayInfo(aBrokerId, aCommData.Sender, aGatewayData, aErrorInfo) then
        aGatewayIp := aGatewayData.ip.AsString;
    finally
      aGatewayData.Free;
    end;
  finally
    aBroker.Free;
  end;

  Result := Format(COMM_DATA, [aBrokerId, aBrokerDevId, aCommData.Receiver, aGatewayIp, aCommData.CommStr,
                   FormatDateTime(FormatSettings.LongDateFormat + ' ' + FormatSettings.LongTimeFormat +'.zzz', Now)]);
end;

class function TDebugCtrl.FormatReceiveCommData(const aBrokerId: Integer; const aCommData: TCommDataInfo; var aBrokerDevNo: string): string;
var
  aBroker: TBrokerData;
  aBrokerDevId: string;
  aGatewayData: TGatewayData;
  aGatewayIp: string;
  aErrorInfo: string;
begin
  aBroker := TBrokerData.Create;
  try
    if _DDTopoCacheInter._doGetBrokerInfo(aBrokerId, aBroker, aErrorInfo) then
      aBrokerDevId := aBroker.devId.AsString;

    aBrokerDevNo := aBrokerDevId;

    aGatewayData := TGatewayData.Create;
    try
      if _DDTopoCacheInter._doFindGatewayInfo(aBrokerId, aCommData.Sender, aGatewayData, aErrorInfo) then
        aGatewayIp := aGatewayData.ip.AsString;
    finally
      aGatewayData.Free;
    end;
  finally
    aBroker.Free;
  end;

  Result := Format(COMM_DATA, [aBrokerId, aBrokerDevId, aCommData.Sender, aGatewayIp, aCommData.CommStr,
                   FormatDateTime(FormatSettings.LongDateFormat + ' ' + FormatSettings.LongTimeFormat +'.zzz', Now)]);
end;

class procedure TDebugCtrl.BrokerCommStateChanged(const aBrokerId: Integer;
                                                  const aCommState: TCommState);
var

  aJson: TJsonObject;
begin
  aJson := TJsonObject.Create;
  try
    aJson.S['changedType'] := 'BrokerCommStateChanged';
    aJson.I['brokerId'] := aBrokerId;
    aJson.I['commState'] := Ord(aCommState);

    TDDMonitorCtrl.SendNotice(MONITOR_TYPE_TOPO_CHANGED, aJson.ToJSON(True));
  finally
    aJson.Free;
  end;
end;

class procedure TDebugCtrl.BrokerGatewayListChanged(const aBrokerId: Integer);
var
  aJson: TJsonObject;
begin
  aJson := TJsonObject.Create;
  try
    aJson.S['changedType'] := 'BrokerGatewayListChanged';
    aJson.I['brokerId'] := aBrokerId;

    TDDMonitorCtrl.SendNotice(MONITOR_TYPE_TOPO_CHANGED, aJson.ToJSON(True));
  finally
    aJson.Free;
  end;
end;

class procedure TDebugCtrl.GatewayCommStateChanged(const aGatewayId: Integer;
                                                   const aCommState: TCommState;
                                                   const aGatewayIp: string);
var
  aJson: TJsonObject;
begin
  aJson := TJsonObject.Create;
  try
    aJson.S['changedType'] := 'GatewayCommStateChanged';
    aJson.I['gatewayId'] := aGatewayId;
    aJson.S['gatewayIp'] := aGatewayIp;
    aJson.I['commState'] := Ord(aCommState);

    TDDMonitorCtrl.SendNotice(MONITOR_TYPE_TOPO_CHANGED, aJson.ToJSON(True));
  finally
    aJson.Free;
  end;
end;

class procedure TDebugCtrl.GatewayReceiveData(const aGatewayId: Integer);
var
  aJson: TJsonObject;
begin
  aJson := TJsonObject.Create;
  try
    aJson.S['changedType'] := 'GatewayReceiveData';
    aJson.I['gatewayId'] := aGatewayId;

    TDDMonitorCtrl.SendNotice(MONITOR_TYPE_TOPO_CHANGED, aJson.ToJSON(True));
  finally
    aJson.Free;
  end;
end;

{ TCommCache }
constructor TCommCache.Create;
begin
  inherited;
  FLock := TPrRWLock.Create;
  FCommList := TList<TCommDataInfo>.Create;
  FCount := 0;
end;

destructor TCommCache.Destroy;
begin
  FLock.BeginWrite;
  try
    FCommList.Free;
  finally
    FLock.EndWrite;
    FLock.Free;
  end;
  inherited;
end;

procedure TCommCache.AddCommData(const aCommData: TCommDataInfo);
begin
  FLock.BeginWrite;
  try
    Inc(FCount);
    FCommList.Add(aCommData);
    //if FCount = 1000 then
    //begin
    //  OutputDebugString(PChar(' Comm Cache Count: ' + IntToStr(FCommList.Count)));
    //  FCount := 0;
    //end;
    if FCommList.Count > 10000 then
    begin
      TPrLogInter.WriteLogError('实时数据过多，舍弃下');
      FCommList.Clear;
    end;
  finally
    FLock.EndWrite;
  end;
end;

function TCommCache.GetCommData(var aCommData: TCommDataInfo): Boolean;
begin
  Result := False;

  FLock.BeginWrite;
  try
    if FCommList.Count = 0 then
      Exit;

    aCommData := FCommList[0];
    FCommList.Delete(0);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

{ TCommCache }
constructor TRealDataCache.Create;
begin
  inherited;
  FLock := TPrRWLock.Create;
  FRealDataList := TList<TRealDataInfo>.Create;
  FCount := 0;
end;

destructor TRealDataCache.Destroy;
begin
  FLock.BeginWrite;
  try
    FRealDataList.Free;
  finally
    FLock.EndWrite;
    FLock.Free;
  end;
  inherited;
end;

procedure TRealDataCache.doSave(const aBeginTime: TDateTime);
var
  aRealDataInfo: TRealDataInfo;
  aRealDataList: TList<TRealDataInfo>;
  aErrorInfo: string;

  aCount, aMSCount: Integer;
  aBeginTimet, aEndTime: TDateTime;
  aDebugStr: string;

  aUrl: string;
  aDataStr: string;
  aDataStream: TStringStream;
  aHTTP: TIdHTTP;
begin
  //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltError, '开始保存实时数据');

  aBeginTimet := Now;

  try
    aRealDataList := TList<TRealDataInfo>.Create;
    try
      FLock.BeginWrite;
      try
        aDataStr := '';
        aCount := 0;

        for aRealDataInfo in FRealDataList do
        begin
          //aDataStr := aDataStr + 'realdata' + IntToStr(aRealDataInfo.DevId) + ',state=' + IntToStr(aRealDataInfo.DataState) +
          //                       ' realdata="'+StringReplace(aRealDataInfo.RealData, '"', '\"', [rfReplaceAll])+'"' +
          //                       ' ' + IntToStr(SecondsBetween(25569, aRealDataInfo.RealTime)*1000 + MilliSecondOf(aRealDataInfo.RealTime)) + #10;
          aRealDataList.Add(aRealDataInfo);
          Inc(aCount);
        end;

        FRealDataList.Clear;
      finally
        FLock.EndWrite;
      end;

      //_DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltError, ' RealDataList Count: ' + IntToStr(aRealDataList.Count));

      if aRealDataList.Count = 0 then
        Exit;

      //if aDataStr = '' then
      //  Exit;

      //aCount := aRealDataList.Count;

     { aUrl := 'http://192.168.1.24:8086/write?db=ddiot&precision=ms';
      aDataStream := TStringStream.Create(aDataStr, TEncoding.UTF8);
      aHTTP := TIdHTTP.Create(nil);
      try
        aHTTP.Post(aUrl, aDataStream);
      finally
        aDataStream.Free;
        aHTTP.Free;
      end; }



      //TPrHttpClientInter.PostStream(,)

      //
      while True do
      begin
        if _DDDataInter._doSaveDeviceRealDataList(aRealDataList, aErrorInfo) then
        begin
          aEndTime := Now;
          aMSCount := MilliSecondsBetween(aBeginTimet, aEndTime);
          if aMSCount > 2000 then
          begin
            aDebugStr := Format('%s Save %d, Cast %d s.', [FormatDateTime('hh:mm:ss.zzz', aBeginTime), aCount, SecondsBetween(aBeginTimet, aEndTime)]);

            TPrLogInter.WriteLogWarn('实时数据存储耗时过多预警：' + aDebugStr);
          end
          else
            aDebugStr := Format('%s Save %d, Cast %d ms.', [FormatDateTime('hh:mm:ss.zzz', aBeginTime), aCount, aMSCount]);
          //OutputDebugString(PChar('[DD-RealData] ' + aDebugStr));
          Break;
        end
        else
        begin
          aErrorInfo := Format('保存实时数据失败, %s', [aErrorInfo]);
          TPrLogInter.WriteLogError(aErrorInfo);
        end;
      end;

      Sleep(2000);
    finally
      aRealDataList.Free;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := Format('保存实时数据异常, %s', [E.Message]);
      TPrLogInter.WriteLogError(aErrorInfo);
    end;
  end;
end;

procedure TRealDataCache.AddRealData(const aRealData: TRealDataInfo);
begin
  FLock.BeginWrite;
  try
    FRealDataList.Add(aRealData);
  finally
    FLock.EndWrite;
  end;
end;

function TRealDataCache.GetRealData(var aRealData: TRealDataInfo): Boolean;
begin
  Result := False;

  FLock.BeginWrite;
  try
    if FRealDataList.Count = 0 then
      Exit;

    aRealData := FRealDataList[0];
    FRealDataList.Delete(0);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

{ TSaveRealDataWork }
constructor TSaveRealDataWork.Create;
var
  aCount: Integer;
begin
  // 工作计数 + 1
  aCount := TPrInterLock.Inc(_SaveRealDataWorkCount);

  if aCount > 1 then
    TPrLogInter.WriteLogInfo('SaveRealDataWorkCount: ' + IntToStr(aCount));

  inherited Create(False);
end;

destructor TSaveRealDataWork.Destroy;
begin
  // 工作计数 - 1
  TPrInterLock.Dec(_SaveRealDataWorkCount);

  inherited;
end;

procedure TSaveRealDataWork.Execute;
begin
  inherited;

  FreeOnTerminate := True;

  try
    _RealDataCache.doSave(StrToDateTime('1983-11-12'));
  except
    on E: Exception do
      TPrLogInter.WriteLogError('SaveRealDataWork Error: ' + E.Message);
  end;
end;

{ TSaveRealDataThread }
constructor TSaveRealDataThread.Create;
begin
  inherited Create(False);
  FEvent := TPrSimpleEvent.Create;
end;

destructor TSaveRealDataThread.Destroy;
begin
  FEvent.SetEvent;
  Terminate;
  WaitFor;
  FEvent.Free;
  inherited;
end;

procedure TSaveRealDataThread.Execute;
var
  aTaskData: TOnlineData;//TCnTaskDataObject;
  aCommDataInfo: TCommDataInfo;
begin
  inherited;

  while not Terminated do
  begin
    if FEvent.WaitFor(2000) = wrSignaled then
      Exit;

    aTaskData := TOnlineData.Create(0, aCommDataInfo);
    try
      //TSaveRealDataWork.Create;
      //OutputDebugString(PChar('[DD-RealData] ' + '添加任务'));
      _SaveRealDataThreadPool.AddRequest(aTaskData);

    except
      on E: Exception do
      begin
        aTaskData.Free;
        TPrLogInter.WriteLogError('TSaveRealDataThread Error: ' + E.Message);
      end;
    end;
  end;
end;

{ TWorkThread }
constructor TWorkThread.Create;
begin
  inherited Create(False);
  FEvent := TPrSimpleEvent.Create;
end;

destructor TWorkThread.Destroy;
begin
  FEvent.SetEvent;
  Terminate;
  WaitFor;
  FEvent.Free;
  inherited;
end;

procedure TWorkThread.Execute;
var
  aCommDataInfo: TCommDataInfo;
  aGatewayId: Int64;
  aCommCmdType: TCommCmdType;
begin
  inherited;

  while not Terminated do
  begin
    try
      if _CommCache.GetCommData(aCommDataInfo) then
      begin
        // 报文处理 (只处理主动上报的报文)
        if aCommDataInfo.DataType = cdtUpdate then
        begin
          aCommCmdType := _DDModelsInter._doGetCommCmdType(aCommDataInfo.From._model, aCommDataInfo.Cmd, aCommDataInfo.CmdData);
          case aCommCmdType of
            // 在线
            cctOnLine:
              begin
                AddTask_OnLine(aCommDataInfo.BrokerId, aCommDataInfo);
                // 在线程中确认网关身份，并设置在线状态或添加未知网关
                //TOnlineWork.Create(aCommDataInfo.BrokerId, aCommDataInfo);
              end;
            // 离线
            cctOffLine:
              begin
                // 设置网关离线
                doSetGatewayOffLine(aCommDataInfo.BrokerId, aCommDataInfo.From._devid);
              end;
            // 上报数据
            cctData:
              begin
                if doParseUpData(aCommDataInfo.BrokerId, aCommDataInfo, aGatewayId) then
                  TDebugCtrl.GatewayReceiveData(aGatewayId);
              end;
          end;
        end;
      end;
    except
    end;

    if FEvent.WaitFor(1) = wrSignaled then
      Exit;
  end;
end;

procedure OnSendEvent(const aCallbackId: Integer;
                      const aCommDataInfo: TCommDataInfo);
begin
  // 更新发送报文统计信息(数量+大小)
  TDDWorkCommStatisCtrl.AddSendCommDataStatis(aCommDataInfo.Receiver, aCommDataInfo);
end;

procedure OnReceiveEvent(const aCallbackId: Integer;
                         const aCommDataInfo: TCommDataInfo);
begin
  // 更新接收报文统计信息(数量+大小)
  TDDWorkCommStatisCtrl.AddReceiveCommDataStatis(aCommDataInfo.From._devid, aCommDataInfo);

  _CommCache.AddCommData(aCommDataInfo);
end;

procedure OnConnectEvent(const aCallbackId: Integer);
begin
  doSetBrokerCommState(aCallbackId, csOnLine);
end;

procedure OnDisconnectEvent(const aCallbackId: Integer);
begin
  doSetBrokerCommState(aCallbackId, csOffLine);
end;

{ TOnlineData }
constructor TOnlineData.Create(const aBrokerId: Integer;
  const aCommDataInfo: TCommDataInfo);
begin
  FBrokerId := aBrokerId;
  FCommDataInfo := aCommDataInfo;
  FTaskBeginTime := Now;
end;

function TOnlineData.Clone: TCnTaskDataObject;
begin
  Result := TOnlineData.Create(FBrokerId, FCommDataInfo);
end;

end.
