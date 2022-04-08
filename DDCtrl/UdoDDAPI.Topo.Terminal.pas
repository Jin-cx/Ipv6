unit UdoDDAPI.Topo.Terminal;

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

// 获取终端设备实时数据
function doGetDeviceRealData(const aDeviceId: RString;
                             const aDeviceData: TDeviceData;
                             var aErrorInfo: string): Boolean; stdcall;

// 获取某网关支持的终端设备型号列表
function doGetDeviceModelList(const aGatewayId: RInteger;
                              const aDevModelList: TDeviceModelDataList;
                              var aErrorInfo: string): Boolean; stdcall;

// 取某设备型号驱动信息
function doGetDeviceModelInfo(const aDeviceModelName: string;
                              const aDeviceModel: TDeviceModelData): Boolean; stdcall;

// 获取 Device 列表
function doGetDeviceList(const aGatewayId: RInteger;
                         const aDeviceList: TDeviceDataList;
                         var aErrorInfo: string): Boolean; stdcall;
// 获取 Device 列表 分页
function doGetAllDeviceList(const aParentId: RInteger;
                            const aIsOnLine: RBoolean;
                            const aIsMeter: RBoolean;
                            const aFilter: RString;
                            var aPageInfo: RPageInfo;
                            const aDeviceList: TDeviceDataList;
                            var aErrorInfo: string): Boolean; stdcall;
// 获取 Device 详情
function doGetDeviceInfo(const aDeviceId: RInteger;
                         const aDeviceData: TDeviceData;
                         var aErrorInfo: string): Boolean; stdcall;
function doGetDeviceInfoByDevId(const aDevId: RString;
                                const aDeviceData: TDeviceData;
                                var aErrorInfo: string): Boolean; stdcall;
// 添加 Device
function doAddDevice(const aDeviceData: TDeviceData;
                     var aErrorInfo: string): Boolean; stdcall;
// 编辑 Device
function doUpdateDevice(const aDeviceData: TDeviceData;
                        var aErrorInfo: string): Boolean; stdcall;
// 删除 Device
function doDeleteDevice(const aDeviceId: RInteger;
                        var aErrorInfo: string): Boolean; stdcall;

// 获取离线设备列表
function doGetOffLineDeviceList(const aOffLineDeviceList: TOffLineDeviceDataList;
                                var aErrorInfo: string): Boolean; stdcall;

function doSearchDeviceList(const aParentId: RInteger;
                            const aOnLine: RBoolean;
                            const aIsMeter: RBoolean;
                            const aFilter: RString;
                            var aPageInfo: RPageInfo;
                            const aDeviceList: TDeviceDataList;
                            var aErrorInfo: string): Boolean; stdcall;


// ================= 实时数据关注 =================
function doGetSubscribeTerminalList(const aUserId: RInteger;
                                    var aDevNoList: string;
                                    var aErrorInfo: string): Boolean; stdcall;
function doSubscribeTerminals(const aUserId: RInteger;
                              const aDevNoList: RString;
                              var aErrorInfo: string): Boolean; stdcall;
function doUnSubscribeTerminals(const aUserId: RInteger;
                                const aDevNoList: RString;
                                var aErrorInfo: string): Boolean; stdcall;

exports
  doGetDeviceRealData,
  doGetDeviceList,
  doGetAllDeviceList,
  doGetDeviceInfo,
  doGetDeviceInfoByDevId,
  doAddDevice,
  doUpdateDevice,
  doDeleteDevice,
  doGetDeviceModelList,
  doGetDeviceModelInfo,
  doGetOffLineDeviceList,
  doGetSubscribeTerminalList,
  doSubscribeTerminals,
  doUnSubscribeTerminals,
  doSearchDeviceList;

implementation

uses
  UdoDDAPI.Topo.Gateway;

function doGetDeviceModelList(const aGatewayId: RInteger;
                              const aDevModelList: TDeviceModelDataList;
                              var aErrorInfo: string): Boolean;
var
  aGateway: TGatewayData;
begin
  Result := False;

  aGateway := TGatewayData.Create;
  try
    if aGatewayId.IsNull or
       not _DDTopoCacheInter._doGetGatewayInfo(aGatewayId.Value, aGateway, aErrorInfo) then
    begin
      aErrorInfo := '指定的网关不存在';
      Exit;
    end;

    Result := _DDModelsInter._doGetDeviceModelList(aGateway.devModel.AsString, aDevModelList, aErrorInfo);
  finally
    aGateway.Free;
  end;
end;

function doGetDeviceModelInfo(const aDeviceModelName: string;
                              const aDeviceModel: TDeviceModelData): Boolean;
begin
  Result := _DDModelsInter._doGetDeviceModelInfo(aDeviceModelName, aDeviceModel);
end;

function doGetDeviceList(const aGatewayId: RInteger;
                         const aDeviceList: TDeviceDataList;
                         var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aDevice: TDeviceData;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetTerminalList';
    aQuery.AddParamI('gatewayId', aGatewayId);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aDevice := TDeviceData.Create;
      aDevice.id := aQuery.ReadFieldAsRInteger('devId');
      aDevice.parentId := aQuery.ReadFieldAsRInteger('parentId');
      aDevice.name := aQuery.ReadFieldAsRString('devName');
      aDevice.note := aQuery.ReadFieldAsRString('devNote');
      aDevice.devId := aQuery.ReadFieldAsRString('devNo');
      aDevice.devModel := aQuery.ReadFieldAsRString('devModel');
      aDevice.devModelName := aQuery.ReadFieldAsRString('devModelName');
      aDevice.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
      aDevice.doubtInfo := aQuery.ReadFieldAsRString('devStateInfo');
      aDevice.devFactoryNo := aQuery.ReadFieldAsRString('devFactoryNo');
      aDevice.devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
      if aQuery.ReadFieldAsRBoolean('onLine').IsTrue then
        aDevice.commState := csOnLine
      else
        aDevice.commState := csOffLine;
      aDevice.todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');

      aDevice.conn := aQuery.ReadFieldAsRString('conn');
      aDevice.isMeter := aQuery.ReadFieldAsRBoolean('isMeter');
      aDevice.meterCode := aQuery.ReadFieldAsRString('meterCode');

      aDevice.isDebug := aQuery.ReadFieldAsRBoolean('isDebug');
      aDevice.debugInfo := aQuery.ReadFieldAsRString('debugInfo');

      aDevice.lastRealTime := aQuery.ReadFieldAsRString('lastRealTime');
      aDevice.realData := aQuery.ReadFieldAsRString('realData');
      aDevice.masterValue := aQuery.ReadFieldAsRString('masterValue');
      aDevice.meterValue := aQuery.ReadFieldAsRString('meterValue');

      //aDevice.isReserve := aQuery.ReadFieldAsRBoolean('isReserve');

      aDevice.UpdateData;
      aDeviceList.Add(aDevice);

      aQuery.Next;
    end;
    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetDeviceRealData(const aDeviceId: RString;
                             const aDeviceData: TDeviceData;
                             var aErrorInfo: string): Boolean;
begin
  Result := _DDTopoCacheInter._doGetDeviceRealData(aDeviceId.AsString, aDeviceData, aErrorInfo);
end;

function doGetAllDeviceList(const aParentId: RInteger;
                            const aIsOnLine: RBoolean;
                            const aIsMeter: RBoolean;
                            const aFilter: RString;
                            var aPageInfo: RPageInfo;
                            const aDeviceList: TDeviceDataList;
                            var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetAllDeviceList(aParentId,
                                             aIsOnLine,
                                             aIsMeter,
                                             aFilter,
                                             aPageInfo,
                                             aDeviceList,
                                             aErrorInfo);
end;

function doGetDeviceInfo(const aDeviceId: RInteger;
                         const aDeviceData: TDeviceData;
                         var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
begin
  Result := False;

  if aDeviceId.IsNull then
  begin
    aErrorInfo := '指定的终端设备不存在';
    Exit;
  end;

  if _DDTopoCacheInter._doGetDeviceInfo(aDeviceId.Value, aDeviceData, aErrorInfo) and
     _DDModelsInter._doGetDeviceModelInfo(aDeviceData.devModel.AsString, aDeviceData.deviceModel) then
  begin
    if aDeviceData.isMeter.IsTrue then
      _DDDataInter._doGetMeterListByDevId(aDeviceData.devId, aDeviceData.meterList, aErrorInfo);

    aGatewayData := TGatewayData.Create;
    try
      if doGetGatewayInfo(aDeviceData.parentId, aGatewayData, aErrorInfo) then
        _DDModelsInter._doGetDeviceConnParams(aGatewayData.devModel.AsString,
                                              aDeviceData.devModel.AsString,
                                              aDeviceData.deviceModel.ConnParams,
                                              aErrorInfo);
    finally
      aGatewayData.Free;
    end;

    if SameText(aDeviceData.devModel.AsString, 'CustomDev') then
    begin
      _DDDataInter._doGetDeviceCustomVarList(aDeviceData.id, aDeviceData.deviceModel.VarList, aErrorInfo);
    end;

    Result := True;
  end
  else
    aErrorInfo := '指定的终端设备不存在';
end;

function doGetDeviceInfoByDevId(const aDevId: RString;
                                const aDeviceData: TDeviceData;
                                var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
begin
  Result := False;

  if aDevId.AsString = '' then
  begin
    aErrorInfo := '指定的终端设备不存在';
    Exit;
  end;

  if _DDTopoCacheInter._doGetDeviceInfoByDevId(aDevId.AsString, aDeviceData) and
     _DDModelsInter._doGetDeviceModelInfo(aDeviceData.devModel.AsString, aDeviceData.deviceModel) then
  begin
    if aDeviceData.isMeter.IsTrue then
      _DDDataInter._doGetMeterListByDevId(aDeviceData.devId, aDeviceData.meterList, aErrorInfo);

    aGatewayData := TGatewayData.Create;
    try
      if doGetGatewayInfo(aDeviceData.parentId, aGatewayData, aErrorInfo) then
        _DDModelsInter._doGetDeviceConnParams(aGatewayData.devModel.AsString,
                                              aDeviceData.devModel.AsString,
                                              aDeviceData.deviceModel.ConnParams,
                                              aErrorInfo);
    finally
      aGatewayData.Free;
    end;

    Result := True;
  end
  else
    aErrorInfo := '指定的终端设备不存在';
end;

function doAddDevice(const aDeviceData: TDeviceData;
                     var aErrorInfo: string): Boolean;
begin
  Result := False;

  if _DDModelsInter._doGetDeviceModelInfo(aDeviceData.devModel.AsString, aDeviceData.deviceModel) then
  begin
    aDeviceData.devModelName.Value := aDeviceData.deviceModel.ModelName;
    aDeviceData.isMeter.Value := aDeviceData.deviceModel.IsMeter;
  end
  else
  begin
    aErrorInfo := '指定的设备型号不存在';
    Exit;
  end;

  aDeviceData.UpdateData;

  Result := _DDDataInter._doAddTopology(aDeviceData, aErrorInfo)
            and
            _DDTopoCacheInter._doAddDevice(aDeviceData, aErrorInfo);

  if Result then
  begin
    // 设置网关状态为未下发
    _DDDataInter._doSetTopoDevState(aDeviceData.parentId.Value, dsUnIssue);
    _DDTopoCacheInter._doSetTopoDevState(aDeviceData.parentId.Value, dsUnIssue);
  end;
end;

function doUpdateDevice(const aDeviceData: TDeviceData;
                        var aErrorInfo: string): Boolean;
var
  aTmpDeviceData: TDeviceData;
  aMeterValue: TMeterValueData;
  aQuery: TPrADOQuery;
  aMeterName: string;
begin
  Result := False;

  if _DDModelsInter._doGetDeviceModelInfo(aDeviceData.devModel.AsString, aDeviceData.deviceModel) then
  begin
    aDeviceData.devModelName.Value := aDeviceData.deviceModel.ModelName;
    aDeviceData.isMeter.Value := aDeviceData.deviceModel.IsMeter;
  end
  else
  begin
    aErrorInfo := '指定的设备型号不存在';
    Exit;
  end;


  aTmpDeviceData := TDeviceData.Create;
  try
    if not _DDTopoCacheInter._doGetDeviceInfo(aDeviceData.id.Value, aTmpDeviceData, aErrorInfo) then
    begin
      aErrorInfo := '指定的终端设备不存在';
      Exit;
    end;

    aDeviceData.parentId := aTmpDeviceData.parentId;
  finally
    aTmpDeviceData.Free;
  end;


  aDeviceData.UpdateData;

  Result := _DDDataInter._doUpdateTopology(aDeviceData, aErrorInfo)
            and
            _DDTopoCacheInter._doUpdateDevice(aDeviceData, aErrorInfo);

  if Result then
  begin
    for aMeterValue in aDeviceData.deviceModel.MeterInfo.MeterValueList do
    begin
      if aDeviceData.deviceModel.MeterInfo.MeterValueList.Count = 1 then
        aMeterName := aDeviceData.name.AsString
      else
        aMeterName := aDeviceData.name.AsString + aMeterValue.MeterValueName;

      aQuery := TPrADOQuery.Create(DB_METER);
      try
        aQuery.SQL.Clear;
        aQuery.SQL.Add('UPDATE [tb_Meters]');
        aQuery.SQL.Add('SET [meterName] = ''' + aMeterName + '''');
        aQuery.SQL.Add('WHERE [devId] = ' + aDeviceData.id.AsString);
        aQuery.SQL.Add('AND [meterValueCode] = '''+aMeterValue.MeterValueCode+'''');
        aQuery.ExecSQL;

        Result := True;
      finally
        aQuery.Free;
      end;
    end;
  end;

  if Result then
  begin
    // 设置网关状态为未下发
    _DDDataInter._doSetTopoDevState(aDeviceData.parentId.Value, dsUnIssue);
    _DDTopoCacheInter._doSetTopoDevState(aDeviceData.parentId.Value, dsUnIssue);
  end;
end;


function doDeleteDevice(const aDeviceId: RInteger;
                        var aErrorInfo: string): Boolean;
var
  aDeviceData: TDeviceData;
begin
  Result := False;

  if not _DDDataInter._doDeleteTopology(aDeviceId, aErrorInfo) then
    Exit;

  aDeviceData := TDeviceData.Create;
  try
    if not _DDTopoCacheInter._doDeleteDevice(aDeviceId, aDeviceData, aErrorInfo) then
      Exit;

    // 设置网关状态为未下发
    _DDDataInter._doSetTopoDevState(aDeviceData.parentId.Value, dsUnIssue);
    _DDTopoCacheInter._doSetTopoDevState(aDeviceData.parentId.Value, dsUnIssue);

    Result := True;
  finally
    aDeviceData.Free;
  end;
end;

function doGetOffLineDeviceList(const aOffLineDeviceList: TOffLineDeviceDataList;
                                var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aDevice: TOffLineDeviceData;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'doGetOffLineTerminalList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aDevice := TOffLineDeviceData.Create;
      aDevice.id := aQuery.ReadFieldAsRInteger('devId');
      aDevice.parentId := aQuery.ReadFieldAsRInteger('parentId');
      aDevice.name := aQuery.ReadFieldAsRString('devName');
      aDevice.note := aQuery.ReadFieldAsRString('devNote');
      aDevice.devId := aQuery.ReadFieldAsRString('devNo');
      aDevice.devModel := aQuery.ReadFieldAsRString('devModel');
      aDevice.devModelName := aQuery.ReadFieldAsRString('devModelName');
      aDevice.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
      aDevice.doubtInfo := aQuery.ReadFieldAsRString('devStateInfo');
      aDevice.devFactoryNo := aQuery.ReadFieldAsRString('devFactoryNo');
      aDevice.devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
      if aQuery.ReadFieldAsRBoolean('onLine').IsTrue then
        aDevice.commState := csOnLine
      else
        aDevice.commState := csOffLine;
      aDevice.todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');

      aDevice.conn := aQuery.ReadFieldAsRString('conn');
      aDevice.isMeter := aQuery.ReadFieldAsRBoolean('isMeter');
      aDevice.meterCode := aQuery.ReadFieldAsRString('meterCode');

      aDevice.lastRealTime := aQuery.ReadFieldAsRString('lastRealTime');
      aDevice.realData := aQuery.ReadFieldAsRString('realData');
      aDevice.masterValue := aQuery.ReadFieldAsRString('masterValue');
      aDevice.meterValue := aQuery.ReadFieldAsRString('meterValue');

      aDevice.isReserve := aQuery.ReadFieldAsRBoolean('isReserve');

      aDevice.gatewayId := aQuery.ReadFieldAsRInteger('parentId');
      aDevice.gatewayDevId := aQuery.ReadFieldAsRString('gatewayNo');
      aDevice.gatewayName := aQuery.ReadFieldAsRString('gatewayName');
      aDevice.gatewayIp := aQuery.ReadFieldAsRString('gatewayIp');

      aDevice.gatewayModel := aQuery.ReadFieldAsRString('gatewayModel');
      aDevice.gatewayTodayOnLineRate := aQuery.ReadFieldAsRDouble('gatewayTodayOnLineRate');
      aDevice.gatewayState := TDeviceState(aQuery.ReadFieldAsRInteger('gatewayState').Value);
      aDevice.gatewayVersion := aQuery.ReadFieldAsRString('gatewayVersion');
      aDevice.gatewayOnLine := aQuery.ReadFieldAsRBoolean('gatewayOnLine');

      aOffLineDeviceList.Add(aDevice);

      aQuery.Next;
    end;
    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doSearchDeviceList(const aParentId: RInteger;
                            const aOnLine: RBoolean;
                            const aIsMeter: RBoolean;
                            const aFilter: RString;
                            var aPageInfo: RPageInfo;
                            const aDeviceList: TDeviceDataList;
                            var aErrorInfo: string): Boolean;
var
  aDevice: TDeviceData;
begin
  Result := _DDDataInter._doGetAllDeviceList(aParentId,
                                             aOnLine,
                                             aIsMeter,
                                             aFilter,
                                             aPageInfo,
                                             aDeviceList,
                                             aErrorInfo);
  if not Result then
    Exit;

  for aDevice in aDeviceList do
  begin
    if aDevice.isMeter.IsTrue then
      _DDDataInter._doGetMeterListByDevId(aDevice.devId, aDevice.meterList, aErrorInfo);
  end;
end;

function doGetSubscribeTerminalList(const aUserId: RInteger;
                                    var aDevNoList: string;
                                    var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetSubscribeTerminalList(aUserId, aDevNoList, aErrorInfo);
end;

function doSubscribeTerminals(const aUserId: RInteger;
                              const aDevNoList: RString;
                              var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doSubscribeTerminals(aUserId, aDevNoList, aErrorInfo);
  if Result then
    TDDCacheTopoCtrl.SetTerminalUsersCacheNeedUpdate;
end;

function doUnSubscribeTerminals(const aUserId: RInteger;
                                const aDevNoList: RString;
                                var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doUnSubscribeTerminals(aUserId, aDevNoList, aErrorInfo);
  if Result then
    TDDCacheTopoCtrl.SetTerminalUsersCacheNeedUpdate;
end;

end.
