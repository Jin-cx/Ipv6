unit UdoDDAPI.Topo.Broker;

interface

uses
  Classes, SysUtils, Windows,
  puer.System, puer.Json.JsonDataObjects,
  UPrDbConnInter,
  UDDDataInter, UDDTopoCacheInter, UDDCommInter, UDDModelsInter,
  UdoDDCache.Topo,
  UDDBrokerModelData, UDDGatewayModelData,
  UDDTopologyData, UDDBrokerData, UDDGatewayData, UDDDeviceData,
  UDDDeviceModelData, UDDCommData, UDDFieldData, UDDOffLineDeviceData,
  UOnLineData, UBrokerInfoData,
  UMyConfig;

// 获取 Broker 型号列表
procedure doGetBrokerModelList(const aModelList: TBrokerModelDataList); stdcall;
// 获取 Broker 列表
function doGetBrokerList(const aBrokerList: TBrokerDataList;
                         var aErrorInfo: string): Boolean; stdcall;
// 获取 Broker 详情
function doGetBrokerInfo(const aBrokerId: RInteger;
                         const aBrokerData: TBrokerData;
                         var aErrorInfo: string): Boolean; stdcall;
// 添加 Broker
function doAddBroker(const aBrokerData: TBrokerData;
                     var aErrorInfo: string): Boolean; stdcall;
// 编辑 Broker
function doUpdateBroker(const aBrokerData: TBrokerData;
                        var aErrorInfo: string): Boolean; stdcall;
// 删除 Broker
function doDeleteBroker(const aBrokerId: RInteger;
                        var aErrorInfo: string): Boolean; stdcall;
// Broker 排序
function doSortBrokers(const aBrokerIdList: TArray<RInteger>;
                       var aErrorInfo: string): Boolean; stdcall;


// 取采集器信息列表
function doGetBrokerInfoList(const aBrokerInfoList: TBrokerInfoDataList;
                             var aErrorInfo: string): Boolean; stdcall;

function doGetBrokerOnLineInfo(const aDevId: RInteger;
                               const aBrokerInfo: TBrokerInfoData;
                               var aErrorInfo: string): Boolean; stdcall;

exports
  doGetBrokerModelList,
  doGetBrokerList,
  doGetBrokerInfo,
  doAddBroker,
  doUpdateBroker,
  doDeleteBroker,
  doSortBrokers,
  doGetBrokerInfoList,
  doGetBrokerOnLineInfo;

implementation

uses
  UdoDDAPI.Topo.Gateway;

procedure doGetBrokerModelList(const aModelList: TBrokerModelDataList);
begin
  _DDModelsInter._doGetBrokerModelList(aModelList);
end;

function doGetBrokerList(const aBrokerList: TBrokerDataList;
                         var aErrorInfo: string): Boolean;
var
  aBroker: TBrokerData;
  aQuery: TPrADOQuery;
  aOnLineCount: Integer;
begin
  Result := True;

  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aQuery.ProcName := 'proc_GetBrokerList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aBroker := TBrokerData.Create;
      aBroker.id := aQuery.ReadFieldAsRInteger('devId');
      aBroker.parentId := aQuery.ReadFieldAsRInteger('parentId');
      aBroker.name := aQuery.ReadFieldAsRString('devName');
      aBroker.note := aQuery.ReadFieldAsRString('devNote');
      aBroker.devId := aQuery.ReadFieldAsRString('devNo');
      aBroker.devModel := aQuery.ReadFieldAsRString('devModel');
      aBroker.devModelName := aQuery.ReadFieldAsRString('devModelName');
      aBroker.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
      aBroker.devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
      if aQuery.ReadFieldAsRBoolean('onLine').IsTrue then
        aBroker.commState := csOnLine
      else
        aBroker.commState := csOffLine;
      aBroker.todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');
      aBroker.brokerHost := aQuery.ReadFieldAsRString('brokerHost');
      aBroker.brokerPort := aQuery.ReadFieldAsRInteger('brokerPort');
      aBroker.useTLS := aQuery.ReadFieldAsRBoolean('useTLS');
      aBroker.userName := aQuery.ReadFieldAsRString('userName');
      aBroker.password := aQuery.ReadFieldAsRString('password');
      aBroker.hasGateway := aQuery.ReadFieldAsRBoolean('hasGateway');

      aBroker.isDebug := aQuery.ReadFieldAsRBoolean('isDebug');
      aBroker.debugInfo := aQuery.ReadFieldAsRString('debugInfo');

      aBroker.sortIndex := aQuery.ReadFieldAsRInteger('sortIndex');

      aBroker.allGatewayCount := aQuery.ReadFieldAsRInteger('allGatewayCount', 0);
      aBroker.onLineGatewayCount := aQuery.ReadFieldAsRInteger('onLineGatewayCount', 0);
      aBroker.debugGatewayCount := aQuery.ReadFieldAsRInteger('debugGatewayCount', 0);

      aOnLineCount := aBroker.onLineGatewayCount.Value + aBroker.debugGatewayCount.Value;
      if aOnLineCount > aBroker.allGatewayCount.Value then
        aBroker.allGatewayCount.Value := aOnLineCount;
      aBroker.offLineGatewayCount.Value := aBroker.allGatewayCount.Value - aOnLineCount;
      if aOnLineCount > 0 then
        aBroker.gatewayOnLineRate.Value := aOnLineCount/aBroker.allGatewayCount.Value
      else
        aBroker.gatewayOnLineRate.Value := 0;

      aBroker.allTerminalCount := aQuery.ReadFieldAsRInteger('allTerminalCount', 0);
      aBroker.onLineTerminalCount := aQuery.ReadFieldAsRInteger('onLineTerminalCount', 0);
      aBroker.debugTerminalCount := aQuery.ReadFieldAsRInteger('debugTerminalCount', 0);

      aOnLineCount := aBroker.onLineTerminalCount.Value + aBroker.debugTerminalCount.Value;
      if aOnLineCount > aBroker.allTerminalCount.Value then
        aBroker.allTerminalCount.Value := aOnLineCount;
      aBroker.offLineTerminalCount.Value := aBroker.allTerminalCount.Value - aOnLineCount;
      if aOnLineCount > 0 then
        aBroker.terminalOnLineRate.Value := aOnLineCount/aBroker.allTerminalCount.Value
      else
        aBroker.terminalOnLineRate.Value := 0;

      aBroker.UpdateData;
      aBrokerList.Add(aBroker);

      aQuery.Next;
    end;
  finally
    aQuery.Free;
  end;
end;

function doGetBrokerInfo(const aBrokerId: RInteger;
                         const aBrokerData: TBrokerData;
                         var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  Result := True;

  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aQuery.ProcName := 'proc_GetBrokerInfo';
    aQuery.AddParamI('brokerId', aBrokerId);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aBrokerData.id := aQuery.ReadFieldAsRInteger('devId');
      aBrokerData.parentId := aQuery.ReadFieldAsRInteger('parentId');
      aBrokerData.name := aQuery.ReadFieldAsRString('devName');
      aBrokerData.note := aQuery.ReadFieldAsRString('devNote');
      aBrokerData.devId := aQuery.ReadFieldAsRString('devNo');
      aBrokerData.devModel := aQuery.ReadFieldAsRString('devModel');
      aBrokerData.devModelName := aQuery.ReadFieldAsRString('devModelName');
      aBrokerData.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
      aBrokerData.devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
      aBrokerData.lngLat := aQuery.ReadFieldAsRString('lngLat');
      if aQuery.ReadFieldAsRBoolean('onLine').IsTrue then
        aBrokerData.commState := csOnLine
      else
        aBrokerData.commState := csOffLine;
      aBrokerData.todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');
      aBrokerData.brokerHost := aQuery.ReadFieldAsRString('brokerHost');
      aBrokerData.brokerPort := aQuery.ReadFieldAsRInteger('brokerPort');
      aBrokerData.useTLS := aQuery.ReadFieldAsRBoolean('useTLS');
      aBrokerData.userName := aQuery.ReadFieldAsRString('userName');
      aBrokerData.password := aQuery.ReadFieldAsRString('password');
      aBrokerData.hasGateway := aQuery.ReadFieldAsRBoolean('hasGateway');

      aBrokerData.UpdateData;

      aQuery.Next;
    end;
  finally
    aQuery.Free;
  end;
end;

function doAddBroker(const aBrokerData: TBrokerData;
                     var aErrorInfo: string): Boolean;
var
  aBrokerModel: TBrokerModelData;
  aGatewayModel: string;
  aGateway: TGatewayData;
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  Result := False;

  // 判断合法性
  aBrokerModel := TBrokerModelData.Create;
  try
    if not _DDModelsInter._doFindBrokerModel(aBrokerData.devModel.AsString, aBrokerModel) then
    begin
      aErrorInfo := '指定的采集器型号不存在!';
      Exit;
    end;

    aGatewayModel := aBrokerModel.BindGatewayModel;
    aBrokerData.hasGateway.Value := aGatewayModel <> '';
  finally
    aBrokerModel.Free;
  end;

  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aQuery.ProcName := 'proc_AddBroker';
    aQuery.AddParamS('devName', aBrokerData.name);
    aQuery.AddParamS('devNote', aBrokerData.note);
    aQuery.AddParamS('devNo', aBrokerData.devId);
    aQuery.AddParamS('devModel', aBrokerData.devModel);
    aQuery.AddParamS('devFactoryNo', aBrokerData.devFactoryNo);
    aQuery.AddParamS('devInstallAddr', aBrokerData.devInstallAddr);
    aQuery.AddParamS('lngLat', aBrokerData.lngLat);
    aQuery.AddParamS('brokerHost', aBrokerData.brokerHost);
    aQuery.AddParamI('brokerPort', aBrokerData.brokerPort);
    aQuery.AddParamB('useTLS', aBrokerData.useTLS);
    aQuery.AddParamS('userName', aBrokerData.userName);
    aQuery.AddParamS('password', aBrokerData.password);
    aQuery.AddParamB('hasGateway', aBrokerData.hasGateway);
    aQuery.OpenProc;

    if aQuery.ReadSQLResult(aError) then
    begin
      aBrokerData.id := aQuery.ReadFieldAsRInteger('devId');

      Result := _DDTopoCacheInter._doAddBroker(aBrokerData, aErrorInfo)
                and
                _DDCommInter._RegBroker(aBrokerData.id.Value,
                                        aBrokerData.devId.AsString,
                                        aBrokerData.brokerHost.AsString,
                                        aBrokerData.brokerPort.Value,
                                        aBrokerData.useTLS.IsTrue,
                                        _MyConfig.BrokerCrt,
                                        aBrokerData.userName.AsString,
                                        aBrokerData.password.AsString,
                                        aErrorInfo);



      if Result then
      begin
        // 采集器自带网关, 自动创建网关节点
        if aBrokerData.hasGateway.IsTrue then
        begin
          aGateway := TGatewayData.Create;
          try
            aGateway.parentId := aBrokerData.id;
            aGateway.name := aBrokerData.name;
            aGateway.note.Value := '';
            aGateway.devId := aBrokerData.devId;
            aGateway.devModel.Value := aGatewayModel;
            Result := doAddGateway(aGateway, aErrorInfo);
          finally
            aGateway.Free;
          end;
        end;
      end;
    end
    else
      aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function doUpdateBroker(const aBrokerData: TBrokerData;
                        var aErrorInfo: string): Boolean;
begin
  Result := False;

  aBrokerData.UpdateData;

  if not _DDDataInter._doUpdateTopology(aBrokerData, aErrorInfo) then
    Exit;

  _DDCommInter._UnRegBroker(aBrokerData.id.Value);
  {if not _DDCommInter._UnRegBroker(aBrokerData.id.Value) then
  begin
    aErrorInfo := '注销报文服务失败';
    Exit;
  end;}


  _DDTopoCacheInter._doSetBrokerCommState(aBrokerData.id.Value, csOffLine);
  //_DDTopoCacheInter._doSetBrokerOffLine(aBrokerData.id.Value);
  _DDTopoCacheInter._doUpdateBroker(aBrokerData, aErrorInfo);
  _DDCommInter._RegBroker(aBrokerData.id.Value,
                          aBrokerData.devId.AsString,
                          aBrokerData.brokerHost.AsString,
                          aBrokerData.brokerPort.Value,
                          aBrokerData.useTLS.IsTrue,
                          _MyConfig.BrokerCrt,
                          aBrokerData.userName.AsString,
                          aBrokerData.password.AsString,
                          aErrorInfo);

  Result := True;
end;

function doDeleteBroker(const aBrokerId: RInteger;
                        var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doDeleteTopology(aBrokerId, aErrorInfo)
            and
            _DDTopoCacheInter._doDeleteBroker(aBrokerId, aErrorInfo);
  if Result then
    _DDCommInter._UnRegBroker(aBrokerId.Value);
end;

function doSortBrokers(const aBrokerIdList: TArray<RInteger>;
                       var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doSortTopologys(aBrokerIdList, aErrorInfo);
            //and
            //_DDTopoCacheInter._doSortBrokers(aBrokerIdList, aErrorInfo);
end;

function doGetBrokerInfoList(const aBrokerInfoList: TBrokerInfoDataList;
                             var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetBrokerInfoList(aBrokerInfoList, aErrorInfo);
end;

function doGetBrokerOnLineInfo(const aDevId: RInteger;
                               const aBrokerInfo: TBrokerInfoData;
                               var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetBrokerOnLineInfo(aDevId, aBrokerInfo, aErrorInfo);
end;

end.
