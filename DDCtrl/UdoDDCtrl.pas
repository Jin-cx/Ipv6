(*
 * 采集平台总控单元
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 *
 *
 * 修改:
 * 2016-12-08 (v0.1)
 *   + 第一次发布.
 *)

unit UdoDDCtrl;

interface

uses
  SysUtils, Windows, Classes,
  { Comm 基础单元 }
  puer.System, puer.SyncObjs,
  { Puer平台接口单元 }
  UPrMsgInter, UPrDbConnInter, UPrLogInter,
  { 采集平台模块接口单元 }
  UdoDDAction,
  UDDCommInter, UDDDataInter, UDDTopoCacheInter, UDDModelsInter,
  { 业务单元 }
  UdoDDCache.Topo,                // 拓扑缓存
  UdoDDWork.CommIO,               // 报文处理
  UdoDDWork.CommStatis,           // 收发报文量化统计
  UdoDDWork.MeterStatisTask,      // 计量点用量统计
  UdoDDWork.OnLineRateStatisTask, // 设备在线率统计
  { Data }
  UDDTopologyData, UDDBrokerData, UDDDeviceData,
  UDDBrokerModelData, UDDGatewayModelData, UDDDeviceModelData,
  UMyConfig, UMyDebug, UdoQRCodeInter;

const
  ERROR_DIGGER_IS_OPEN          = '采集平台已启动';
  ERROR_DIGGER_IS_CLOSE         = '采集平台已关闭';
  ERROR_WAIT_FOR_CLOSE_TIME_OUT = '等待采集平台关闭超时';

// ******************* 采集平台启动关闭操作 ******************* //
// 设置中间件原文件路径
procedure doSetModuleFileName(const aModuleFileName: string); stdcall;
// 中间件初始化
procedure doInit; stdcall;
// 中间件释放
procedure doFree; stdcall;
// 初始化状态
function Active: Boolean; stdcall;

// 获取平台安装日期
function doGetDDInstallData: RDateTime; stdcall;
// 获取地图配置（中心点等信息）
function doGetMapConfig(var aMapConfig: RString; var aErrorInfo: string): Boolean; stdcall;
// 设置地图配置（中心点等信息）
function doSetMapConfig(const aMapConfig: RString; var aErrorInfo: string): Boolean; stdcall;
function doGetDD(const aDD: TTopologyData; var aErrorInfo: string): Boolean; stdcall;


{function doCreateQRCode(const aModel: string;
                        const aTitle: string;
                        const aCode: string;
                        const aQRCodeJPG: TMemoryStream;
                        var aError: string): Boolean; stdcall; external 'QRCode.dll';   }

exports
  doSetModuleFileName,
  doInit,
  doFree,
  Active,
  doGetDDInstallData,
  doGetMapConfig,
  doSetMapConfig,
  doGetDD;

implementation

uses
  UdoDDWork.Monitor;

var
  _ModuleState: TPrModuleState;    // 平台启用状态控制类

  _DDInstallData: RDateTime;       // 平台安装日期
  _MapConfig: RString;             // 平台地图配置

function doGetDDInstallData: RDateTime;
begin
  Result := _DDInstallData;
end;

function doGetMapConfig(var aMapConfig: RString; var aErrorInfo: string): Boolean;
begin
  aMapConfig := _MapConfig;
  Result := True;
end;

function doSetMapConfig(const aMapConfig: RString; var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aSQLStr := ' update tb_Devices set lngLat = ''' + aMapConfig.AsString + ''''
             + ' where devType = 3';
    aQuery.SQL.Text := aSQLStr;
    aQuery.ExecSQL;

    _MapConfig := aMapConfig;
    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetDD(const aDD: TTopologyData; var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aSQLStr := ' select devId, devType, parentId, devName, devNo, devInstallDate, lngLat from tb_Devices '
             + ' where devType = 3';
    aQuery.SQL.Text := aSQLStr;
    aQuery.Open;

    with aDD do
    begin
      id := aQuery.ReadFieldAsRInteger('devId');
      deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
      parentId := aQuery.ReadFieldAsRInteger('parentId');
      name := aQuery.ReadFieldAsRString('devName');
      devId := aQuery.ReadFieldAsRString('devNo');
      devInstallDate := aQuery.ReadFieldAsRDateTime('devInstallDate');
      lngLat := aQuery.ReadFieldAsRString('lngLat');
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

{procedure doQRCode();
var
  aStream: TMemoryStream;
  aError: string;
  aCount: Integer;
begin
  aCount := GetTickCount;
  aStream := TMemoryStream.Create;
  try
    //UdoQRCodeInter._doCreateQRCode

    doCreateQRCode(//'dd-iot\_do\qr\QRCode.dll',
                                   'D:\Puer_EMMS\htdocs\water\monitor\_do\QRCode.cfg',
                                   '物联感知平台DD',
                                   'http://192.168.1.24:8764/water/monitor/configuration/baseset',
                                   aStream,
                                   aError);


    aStream.SaveToFile('D:\QRCode.png');

  finally
    aStream.Free;
  end;

  TMyDebug.OutputDebug('CreateQRCode:' + IntToStr(GetTickCount - aCount));
end;}

procedure doSetModuleFileName(const aModuleFileName: string);
begin
  UMyConfig.doInitConfig(aModuleFileName);
  TMyDebug.OutputDebug('doSetModuleFileName');

  //doQRCode;
end;

procedure doInitTopoList;
const
  UNKNOWN_MODEL = '未知型号';
var
  aTopoList: TTopologyDataList;
  aTopo: TTopologyData;
  aBroker: TBrokerData;
  aErrorInfo: string;
begin
  aTopoList := TTopologyDataList.Create;
  try
    // 取 Topo 数据
    try
      _DDDataInter._doGetTopologyList(aTopoList);
    except
      on E: Exception do
      begin
        OutputDebugString(PChar('[DD-IoT] _doGetTopologyList, ' + E.Message));
        raise E;
      end;
    end;

    // 初始化 TopoCache
    try
      _DDTopoCacheInter._doInitTopoCache(aTopoList);
    except
      on E: Exception do
      begin
        OutputDebugString(PChar('[DD-IoT] _doInitTopoCache, ' + E.Message));
        raise E;
      end;
    end;

    // 注册 Broker
    for aTopo in aTopoList do
    begin
      if aTopo.deviceType = dtDD then
      begin
        _DDInstallData := aTopo.devInstallDate;
        _MapConfig := aTopo.lngLat;
      end
      else if aTopo.deviceType = dtBroker then
      begin
        aBroker := TBrokerData.Create;
        try
          aBroker.Assign(aTopo);

          if not _DDCommInter._RegBroker(aBroker.id.Value,
                                         aBroker.devId.AsString,
                                         aBroker.brokerHost.AsString,
                                         aBroker.brokerPort.Value,
                                         aBroker.useTLS.IsTrue,
                                         _MyConfig.BrokerCrt,
                                         aBroker.userName.AsString,
                                         aBroker.password.AsString,
                                         aErrorInfo) then
          begin
            OutputDebugString(PChar('lynch RegBroker error: ' + aErrorInfo));
          end;
        finally
          aBroker.Free;
        end;
      end;
    end;
    TPrLogInter.WriteLogInfo('doInitTopoList.RegBroker 完成');
  finally
    aTopoList.Free;
  end;
end;

function doOpenDigger(var aErrorInfo: string): Boolean;
begin
  // ************   DDAction   ************
  TDDAction.Open(_MyConfig.RootPath, _MyConfig.TmpPath);
  TMyDebug.OutputDebug('DDAction.Open');

  // ************ 通用基础模块 ************
  // 1. Log
  //_DDLogInter := TDDLogInter.Create(@_GetProcAddr);
  //_DDLogInter._Open(aErrorInfo);
  //_DDLogInter._RegLog(UDDLogInter.DD_LOG_NAME, _MyConfig.LogPath, aErrorInfo);

  // ************ 采集基础模块 ************
  // 1. Models     模板
  _DDModelsInter := TDDModelsInter.Create(@_GetProcAddr);
  _DDModelsInter._Open(nil, _MyConfig.RootPath, @_GetProcAddr);

  // 2. Data       数据
  _DDDataInter := TDDDataInter.Create(@_GetProcAddr);
  _DDDataInter._Open(nil, _MyConfig.ConfigPath, _MyConfig.DataPath);

  // 3. Comm       通讯
  //_DDDataInter._doCheckDoubtRequest(aErrorInfo);
  _DDCommInter := TDDCommInter.Create(@_GetProcAddr);
  _DDCommInter._Open(nil);

  // 5. TopoCache  拓扑实时状态数据缓存
  _DDTopoCacheInter := TDDTopoCacheInter.Create(@_GetProcAddr);
  _DDTopoCacheInter._Open(nil);

  // ************ 总控模块初始化 ************

  // 通知消息推送
  TDDMonitorCtrl.Open;

  // Topo 缓存
  TDDCacheTopoCtrl.Open;

  // 报文处理单元
  TDDWorkCommIOCtrl.Open;

  // 收发报文统计单元
  TDDWorkCommStatisCtrl.Open;

  TMyDebug.OutputDebug('doInitTopoList begin', True);

  // 初始化 Topo
  doInitTopoList;

  TMyDebug.OutputDebug('doInitTopoList end', True);

  // 计量点 用量 统计
  TDDWorkMeterStatisCtrl.Open;

  // 设备在线率统计
  TDDWorkOnLineRateStatisCtrl.Open;

  Result := True;
end;

function doBeforeCloseDigger(var aErrorInfo: string): Boolean;
begin
  Result := True;
end;

function doCloseDigger(var aErrorInfo: string): Boolean;
begin
  TPrLogInter.WriteLogInfo('开始关闭 DD-IoT');
  // 先停止所有 MQTT
  if _DDCommInter <> nil then
    _DDCommInter._Stop;

  TPrLogInter.WriteLogInfo('DDComm Stop');

  // ************ 总控模块各个任务关闭 ************
  if TDDWorkOnLineRateStatisCtrl.Active then
    TDDWorkOnLineRateStatisCtrl.Close;
  TPrLogInter.WriteLogInfo('DDWorkOnLineRateStatis Close');

  if TDDWorkCommIOCtrl.Active then
    TDDWorkCommIOCtrl.Close;
  TPrLogInter.WriteLogInfo('DDWorkCommIO Close');

  if TDDWorkCommStatisCtrl.Active then
    TDDWorkCommStatisCtrl.Close;
  TPrLogInter.WriteLogInfo('DDWorkCommStatis Close');

  if TDDWorkMeterStatisCtrl.Active then
    TDDWorkMeterStatisCtrl.Close;
  TPrLogInter.WriteLogInfo('DDWorkMeterStatis Close');

  if TDDCacheTopoCtrl.Active then
    TDDCacheTopoCtrl.Close;
  TPrLogInter.WriteLogInfo('DDCacheTopo Close');

  if TDDMonitorCtrl.Active then
    TDDMonitorCtrl.Close;
  TPrLogInter.WriteLogInfo('DDMonitor Close');

  // ************ 采集基础模块关闭 ************
  if _DDTopoCacheInter <> nil then
  begin
    _DDTopoCacheInter._Close;
    _DDTopoCacheInter.Free;
  end;
  TPrLogInter.WriteLogInfo('DDTopoCache Close');

  if _DDCommInter <> nil then
  begin
    _DDCommInter._Close;
    _DDCommInter.Free;
  end;
  TPrLogInter.WriteLogInfo('DDComm Close');

  if _DDDataInter <> nil then
  begin
    _DDDataInter._Close;
    _DDDataInter.Free;
  end;
  TPrLogInter.WriteLogInfo('DDData Close');

  if _DDModelsInter <> nil then
  begin
    _DDModelsInter._Close;
    _DDModelsInter.Free;
  end;
  TPrLogInter.WriteLogInfo('DDModels Close');

  // ************ 通用基础模块关闭 ************
  //if _DDLogInter <> nil then
  //begin
  //  _DDLogInter._Close(aErrorInfo);
  //  _DDLogInter.Free;
  //end;

  // 最后关闭 DDAction
  if TDDAction.Active then
  begin
    TDDAction.Close;
  end;
  TPrLogInter.WriteLogInfo('DDAction Close');

  Result := True;
end;

procedure doInit;
var
  aErrorInfo: string;
begin
  TMyDebug.OutputDebug('doInit');

  _ModuleState.Lock;
  try
    if _ModuleState.Active then
      raise Exception.Create(ERROR_DIGGER_IS_OPEN);

    try
      if not doOpenDigger(aErrorInfo) then
        raise Exception.Create(aErrorInfo);
    except
      on E: Exception do
      begin
        doCloseDigger(aErrorInfo);
        raise Exception.Create(E.Message);
      end;
    end;

    _ModuleState.SetActive(True);
  finally
    _ModuleState.UnLock;
  end;
end;

procedure doFree;
var
  aErrorInfo: string;
begin
  TMyDebug.OutputDebug('doFree');
  _ModuleState.Lock;
  try
    if not _ModuleState.Active then
      raise Exception.Create(ERROR_DIGGER_IS_CLOSE);

    _ModuleState.SetActive(False);

    if not doBeforeCloseDigger(aErrorInfo) then
    begin
      _ModuleState.SetActive(True);
      raise Exception.Create(aErrorInfo);
    end;

    if not _ModuleState.WaitFor(60*1000) then
    begin
      _ModuleState.SetActive(True);
      raise Exception.Create(ERROR_WAIT_FOR_CLOSE_TIME_OUT);
    end;

    if not doCloseDigger(aErrorInfo) then
    begin
      _ModuleState.SetActive(True);
      raise Exception.Create(aErrorInfo);
    end;
  finally
    _ModuleState.UnLock;
  end;
end;

function Active: Boolean;
begin
  Result := _ModuleState.Active;
end;

initialization
  _ModuleState := TPrModuleState.Create;

finalization
  _ModuleState.Free;

end.
