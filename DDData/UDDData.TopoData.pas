unit UDDData.TopoData;

interface

uses
  Classes, SysUtils, Generics.Collections, DateUtils, Windows, ADODB,
  puer.System, puer.SyncObjs, puer.TTS, puer.Json.JsonDataObjects,
  UPrDbConnInter,
  UDDTopologyData, UDDTopologyDataJson,
  UDDBrokerData, UDDGatewayData, UDDDeviceData, UDDDeviceDataXml,
  UOnLineData, UDDDeviceRealData, UBrokerInfoData, UDDCommDataInfoData,
  UDDDeviceModelData,
  UDDData.Config;

const
  DEV_TYPE_DDIOT    = 3;
  DEV_TYPE_BROKER   = 0;
  DEV_TYPE_GATEWAY  = 1;
  DEV_TYPE_TERMINAL = 2;

// 取拓扑结构列表
procedure doGetTopologyList(const aTopologyDataList: TTopologyDataList); stdcall;
// 添加拓扑节点
function doAddTopology(const aTopologyData: TTopologyData;
                       var aErrorInfo: string): Boolean; stdcall;
// 添加网关如果设备编号不存在
function doAddGatewayIfDevIdNotExist(const aTopologyData: TTopologyData): Boolean; stdcall;
// 更新拓扑节点
function doUpdateTopology(const aTopologyData: TTopologyData;
                          var aErrorInfo: string): Boolean; stdcall;
// 删除拓扑节点 (单个)
function doDeleteTopology(const aTopologyId: RInteger;
                          var aErrorInfo: string): Boolean; stdcall;
// 删除拓扑节点 (批量)
function doDeleteTopologys(const aTopologyIdList: TArray<RInteger>;
                           var aErrorInfo: string): Boolean; stdcall;
// 排序拓扑节点
function doSortTopologys(const aTopologyIdList: TArray<RInteger>;
                         var aErrorInfo: string): Boolean; stdcall;
// 设置拓扑节点设备状态
procedure doSetTopoDevState(const aTopologyId: Int64;
                            const aDevState: TDeviceState); stdcall;
// 设置拓扑节点在线状态
procedure doSetTopoCommState(const aTopologyId: Int64;
                             const aCommState: TCommState;
                             const aStateInfo: string); stdcall;

// ------------ 网关 ------------
// 设置拓扑节点 IP
function doUpdateTopologyIp(const aTopologyId: Int64;
                            const aIp: string;
                            const aVersion: string;
                            const aDevModel: string;
                            var aErrorInfo: string): Boolean; stdcall;

// ------------ 设备 ------------
// 保存设备实时数据
function doSetDeviceRealData(const aTopologyId: Int64;
                             const aRealTime: TDateTime;
                             const aRealData: string;
                             const aMasterValue: string;
                             const aMeterValue: string;
                             var aErrorInfo: string): Boolean; stdcall;

function doSaveDeviceRealDataList(const aRealDataList: TList<TRealDataInfo>;
                                  var aErrorInfo: string): Boolean; stdcall;

// 取网关列表（分页）
function doGetAllGatewayList(const aParentId: RInteger;
                             const aIsOnLine: RBoolean;
                             const aFilter: RString;
                             var aPageInfo: RPageInfo;
                             const aGatewayList: TGatewayDataList;
                             var aErrorInfo: string): Boolean; stdcall;

// 取设备列表（分页）
function doGetAllDeviceList(const aParentId: RInteger;
                            const aOnLine: RBoolean;
                            const aIsMeter: RBoolean;
                            const aFilter: RString;
                            var aPageInfo: RPageInfo;
                            const aDeviceList: TDeviceDataList;
                            var aErrorInfo: string): Boolean; stdcall;

// 计算某时间范围内的在线率
function doCalcOnLineRate(const aTopologyId: Int64;
                          const aBeginTime: TDateTime;
                          const aEndTime: TDateTime;
                          var aOnLineRate: RDouble;
                          var aErrorInfo: string): Boolean; stdcall;

function doUpdateOnLineRate(const aTopologyId: Int64;
                            const aDate: TDateTime;
                            const aOnLineRate: RDouble;
                            const aIsStatis: Boolean;
                            var aErrorInfo: string): Boolean; stdcall;

function doGetDeviceLastOnLineRateStatisDate(const aTopologyId: Int64;
                                             var aDate: TDateTime;
                                             var aErrorInfo: string): Boolean; stdcall;

function doGetBrokerInfoList(const aBrokerInfoList: TBrokerInfoDataList;
                             var aErrorInfo: string): Boolean; stdcall;

function doGetBrokerOnLineInfo(const aDevId: RInteger;
                               const aBrokerInfo: TBrokerInfoData;
                               var aErrorInfo: string): Boolean; stdcall;

function doUpdateDevicesOfGateway(const aGatewayId: RInteger;
                                  const aRunState: RString;
                                  const aDeviceList: TDeviceDataList;
                                  var aErrorInfo: string): Boolean; stdcall;

// 获取设备自定义变量列表
function doGetDeviceCustomVarList(const aDevId: RInteger;
                                  const aVarList: TDeviceVarDataList;
                                  var aErrorInfo: string): Boolean; stdcall;



function doGetSubscribeTerminalList(const aUserId: RInteger;
                                    var aDevNoList: string;
                                    var aErrorInfo: string): Boolean; stdcall;
function doSubscribeTerminals(const aUserId: RInteger;
                              const aDevNoList: RString;
                              var aErrorInfo: string): Boolean; stdcall;
function doUnSubscribeTerminals(const aUserId: RInteger;
                                const aDevNoList: RString;
                                var aErrorInfo: string): Boolean; stdcall;

function doGetSubscribeTerminalUserList(const aDevUserCodeList: TStringList;
                                        var aErrorInfo: string): Boolean; stdcall;


exports
  doGetTopologyList,
  doAddTopology,
  doAddGatewayIfDevIdNotExist,
  doUpdateTopology,
  doDeleteTopology,
  doDeleteTopologys,
  doSortTopologys,
  doSetTopoDevState,
  doSetTopoCommState,
  doUpdateTopologyIp,
  doSetDeviceRealData,
  doSaveDeviceRealDataList,
  doGetAllGatewayList,
  doGetAllDeviceList,
  doCalcOnLineRate,
  doUpdateOnLineRate,
  doGetDeviceLastOnLineRateStatisDate,
  doGetBrokerInfoList,
  doGetBrokerOnLineInfo,
  doUpdateDevicesOfGateway,
  doGetDeviceCustomVarList,
  doGetSubscribeTerminalList,
  doSubscribeTerminals,
  doUnSubscribeTerminals,
  doGetSubscribeTerminalUserList;

implementation

procedure GetDDList(const aTopologyDataList: TTopologyDataList);
var
  aSQLStr: string;
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aSQLStr := ' select devId, devType, parentId, devName, devNo, devInstallDate, lngLat'
             + ' from tb_Devices '
             + ' where devType = ' + IntToStr(DEV_TYPE_DDIOT)
             + ' order by sortIndex';
    aQuery.SQL.Text := aSQLStr;
    aQuery.Open;
    aQuery.First;
    while not aQuery.Eof do
    begin
      with aTopologyDataList.Add do
      begin
        id := aQuery.ReadFieldAsRInteger('devId');
        deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
        parentId := aQuery.ReadFieldAsRInteger('parentId');
        name := aQuery.ReadFieldAsRString('devName');
        devId := aQuery.ReadFieldAsRString('devNo');
        devInstallDate := aQuery.ReadFieldAsRDateTime('devInstallDate');
        lngLat := aQuery.ReadFieldAsRString('lngLat');
      end;
      aQuery.Next;
    end;
  finally
    aQuery.Free;
  end;
end;

procedure GetBrokerList(const aTopologyDataList: TTopologyDataList);
var
  aBroker: TBrokerData;
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetBrokerList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aBroker := TBrokerData.Create;
      aBroker.id := aQuery.ReadFieldAsRInteger('devId');
      aBroker.deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
      aBroker.parentId := aQuery.ReadFieldAsRInteger('parentId');
      aBroker.name := aQuery.ReadFieldAsRString('devName');
      aBroker.note := aQuery.ReadFieldAsRString('devNote');
      aBroker.devId := aQuery.ReadFieldAsRString('devNo');
      aBroker.devModel := aQuery.ReadFieldAsRString('devModel');
      aBroker.devModelName := aQuery.ReadFieldAsRString('devModelName');
      aBroker.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
      aBroker.devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
      aBroker.lngLat := aQuery.ReadFieldAsRString('lngLat');
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

      aBroker.sortIndex := aQuery.ReadFieldAsRInteger('sortIndex');

      aBroker.UpdateData;
      aTopologyDataList.Add(aBroker);

      aQuery.Next;
    end;
  finally
    aQuery.Free;
  end;
end;

procedure GetGatewayList(const aTopologyDataList: TTopologyDataList);
var
  aQuery: TPrADOQuery;
  aGateway: TGatewayData;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetGatewayList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aGateway := TGatewayData.Create;
      aGateway.id := aQuery.ReadFieldAsRInteger('devId');
      aGateway.deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
      aGateway.parentId := aQuery.ReadFieldAsRInteger('parentId');
      aGateway.name := aQuery.ReadFieldAsRString('devName');
      aGateway.note := aQuery.ReadFieldAsRString('devNote');
      aGateway.devId := aQuery.ReadFieldAsRString('devNo');
      aGateway.devModel := aQuery.ReadFieldAsRString('devModel');
      aGateway.devModelName := aQuery.ReadFieldAsRString('devModelName');
      aGateway.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
      aGateway.devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
      if aQuery.ReadFieldAsRBoolean('onLine').IsTrue then
        aGateway.commState := csOnLine
      else
        aGateway.commState := csOffLine;
      aGateway.todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');

      aGateway.isTemp := aQuery.ReadFieldAsRBoolean('isTemp');
      aGateway.ip := aQuery.ReadFieldAsRString('ip');
      aGateway.runState := aQuery.ReadFieldAsRString('runState');
      aGateway.version := aQuery.ReadFieldAsRString('version');

      aGateway.sortIndex := aQuery.ReadFieldAsRInteger('sortIndex');

      aGateway.UpdateData;
      aTopologyDataList.Add(aGateway);

      aQuery.Next;
    end;
  finally
    aQuery.Free;
  end;
end;

procedure GetDeviceList(const aTopologyDataList: TTopologyDataList);
var
  aQuery: TPrADOQuery;
  aDevice: TDeviceData;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetTerminalList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aDevice := TDeviceData.Create;
      aDevice.id := aQuery.ReadFieldAsRInteger('devId');
      aDevice.deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
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

      aDevice.isReserve := aQuery.ReadFieldAsRBoolean('isReserve');

      aDevice.lastRealData.LoadFrom(aQuery.FieldByName('lastRealData').AsString);
      aDevice.lastValidRealData.LoadFrom(aQuery.FieldByName('lastValidRealData').AsString);

      aDevice.UpdateData;
      aTopologyDataList.Add(aDevice);

      aQuery.Next;
    end;
  finally
    aQuery.Free;
  end;
end;

procedure doGetTopologyList(const aTopologyDataList: TTopologyDataList);
begin
  GetDDList(aTopologyDataList);
  GetBrokerList(aTopologyDataList);
  GetGatewayList(aTopologyDataList);
  GetDeviceList(aTopologyDataList);
end;

function AddGateway(const aGatewayData: TGatewayData; var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  Result := False;

  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_AddGateway';
    aQuery.AddParamI('parentId', aGatewayData.parentId);
    aQuery.AddParamS('devName', aGatewayData.name);
    aQuery.AddParamS('devNote', aGatewayData.note);
    aQuery.AddParamS('devNo', aGatewayData.devId);
    aQuery.AddParamS('devModel', aGatewayData.devModel);
    aQuery.AddParamS('devFactoryNo', aGatewayData.devFactoryNo);
    aQuery.AddParamS('devInstallAddr', aGatewayData.devInstallAddr);
    aQuery.AddParamB('isTemp', aGatewayData.isTemp);
    aQuery.AddParamS('ip', aGatewayData.ip);
    aQuery.AddParamS('runState', aGatewayData.runState);

    aQuery.OpenProc;

    if aQuery.ReadSQLResult(aError) then
    begin
      aGatewayData.id := aQuery.ReadFieldAsRInteger('devId');

      Result := True;
    end
    else
      aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function AddDevice(const aDeviceData: TDeviceData; var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  Result := False;

  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_AddTerminal';
    aQuery.AddParamI('parentId', aDeviceData.parentId);
    aQuery.AddParamS('devName', aDeviceData.name);
    aQuery.AddParamS('devNote', aDeviceData.note);
    aQuery.AddParamS('devNo', aDeviceData.devId);
    aQuery.AddParamS('devModel', aDeviceData.devModel);
    aQuery.AddParamS('devFactoryNo', aDeviceData.devFactoryNo);
    aQuery.AddParamS('devInstallAddr', aDeviceData.devInstallAddr);
    aQuery.AddParamS('conn', aDeviceData.conn);
    aQuery.AddParamB('isMeter', aDeviceData.isMeter);
    aQuery.OpenProc;

    if aQuery.ReadSQLResult(aError) then
    begin
      aDeviceData.id := aQuery.ReadFieldAsRInteger('devId');

      Result := True;
    end
    else
      aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function doAddTopology(const aTopologyData: TTopologyData;
                       var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
  aDeviceData: TDeviceData;
begin
  Result := False;
  case aTopologyData.deviceType of
    dtGateway:
      begin
        aGatewayData := TGatewayData.Create;
        try
          aGatewayData.Assign(aTopologyData);
          aGatewayData.ParseData;

          Result := AddGateway(aGatewayData, aErrorInfo);
          if Result then
          begin
            aTopologyData.id.Value := aGatewayData.id.Value;
            aTopologyData.sortIndex.Value := aGatewayData.id.Value;
          end;
        finally
          aGatewayData.Free;
        end;
      end;
    dtDevice:
      begin
        aDeviceData := TDeviceData.Create;
        try
          aDeviceData.Assign(aTopologyData);
          aDeviceData.ParseData;

          Result := AddDevice(aDeviceData, aErrorInfo);
          if Result then
          begin
            aTopologyData.id.Value := aDeviceData.id.Value;
            aTopologyData.sortIndex.Value := aDeviceData.id.Value;
          end;
        finally
          aDeviceData.Free;
        end;
      end;
  end;
end;


/////////////////////////////////////
function doAddGatewayIfDevIdNotExist(const aTopologyData: TTopologyData): Boolean;
begin
  Result := False;
  //Result := _TopoDataMgr.AddGatewayIfDevIdNotExist(aTopologyData);
end;
//////////////////////////////////

function UpdateBroker(const aBrokerData: TBrokerData; var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_UpdateBroker';
    aQuery.AddParamI('devId', aBrokerData.id);
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

    Result := aQuery.ReadSQLResult(aError);
    if not Result then
      aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function UpdateGateway(const aGatewayData: TGatewayData; var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aSQLStr: string;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aSQLStr := ' update tb_Devices '
             + '   set devName = ' + QuotedStr(aGatewayData.name.AsString)
             + '     , devNote = ' + QuotedStr(aGatewayData.note.AsString)
             + '     , devNo = ' + QuotedStr(aGatewayData.devId.AsString)
             + '     , devModel = ' + QuotedStr(aGatewayData.devModel.AsString)
             //+ '     , devModelName = ' + QuotedStr(aGatewayData.devModelName.AsString)
             + '     , isTemp = ' + aGatewayData.isTemp.AsIntString
             + ' where devId = ' + aGatewayData.id.AsString;
    aQuery.SQL.Text := aSQLStr;
    aQuery.ExecSQL;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function UpdateDevice(const aDeviceData: TDeviceData; var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aSQLStr: string;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aSQLStr := ' update tb_Devices '
             + '   set devName = ' + QuotedStr(aDeviceData.name.AsString)
             + '     , devNote = ' + QuotedStr(aDeviceData.note.AsString)
             + '     , devNo = ' + QuotedStr(aDeviceData.devId.AsString)
             + '     , devModel = ' + QuotedStr(aDeviceData.devModel.AsString)
             //+ '     , devModelName = ' + QuotedStr(aDeviceData.devModelName.AsString)
             + '     , devFactoryNo = ' + QuotedStr(aDeviceData.devFactoryNo.AsString)
             + '     , devInstallAddr = ' + QuotedStr(aDeviceData.devInstallAddr.AsString)
             + ' where devId = ' + aDeviceData.id.AsString;
    aQuery.SQL.Text := aSQLStr;
    aQuery.ExecSQL;

    aSQLStr := ' update tb_Terminals '
             + '   set conn = ' + QuotedStr(aDeviceData.conn.AsString)
             + ' where devId = ' + aDeviceData.id.AsString;
    aQuery.SQL.Text := aSQLStr;
    aQuery.ExecSQL;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doUpdateTopology(const aTopologyData: TTopologyData;
                          var aErrorInfo: string): Boolean;
var
  aBrokerData: TBrokerData;
  aGatewayData: TGatewayData;
  aDeviceData: TDeviceData;
begin
  Result := False;
  case aTopologyData.deviceType of
    dtBroker:
      begin
        aBrokerData := TBrokerData.Create;
        try
          aBrokerData.Assign(aTopologyData);
          aBrokerData.ParseData;

          Result := UpdateBroker(aBrokerData, aErrorInfo);
        finally
          aBrokerData.Free;
        end;
      end;
    dtGateway:
      begin
        aGatewayData := TGatewayData.Create;
        try
          aGatewayData.Assign(aTopologyData);
          aGatewayData.ParseData;

          Result := UpdateGateway(aGatewayData, aErrorInfo);
        finally
          aGatewayData.Free;
        end;
      end;
    dtDevice:
      begin
        aDeviceData := TDeviceData.Create;
        try
          aDeviceData.Assign(aTopologyData);
          aDeviceData.ParseData;

          Result := UpdateDevice(aDeviceData, aErrorInfo);
        finally
          aDeviceData.Free;
        end;
      end;
  end;
end;

function doDeleteTopology(const aTopologyId: RInteger;
                          var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_DeleteDevice';
    aQuery.AddParamI('devId', aTopologyId);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    if not Result then
      aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function RIntegerArrayAsString(const aIntList: TArray<RInteger>): string;
var
  aInt: RInteger;
begin
  Result := '';

  for aInt in aIntList do
  begin
    if aInt.IsNull then
      Continue;

    if Result = '' then
      Result := aInt.AsString
    else
      Result := Result + ',' + aInt.AsString;
  end;
end;

function doDeleteTopologys(const aTopologyIdList: TArray<RInteger>;
                           var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_DeleteDevices';
    aQuery.AddParamS('devIdList', RIntegerArrayAsString(aTopologyIdList));
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    if not Result then
      aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function doSortTopologys(const aTopologyIdList: TArray<RInteger>;
                         var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_SortDevices';
    aQuery.AddParamS('devIdList', RIntegerArrayAsString(aTopologyIdList));
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    if not Result then
      aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

procedure doSetTopoDevState(const aTopologyId: Int64;
                            const aDevState: TDeviceState);
var
  aSQLStr: string;
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aSQLStr := ' update tb_Devices'
             + ' set devState = ' + IntToStr(Ord(aDevState))
             + ' where devId = ' + IntToStr(aTopologyId);
    aQuery.SQL.Text := aSQLStr;
    aQuery.ExecSQL;
  finally
    aQuery.Free;
  end;
end;

procedure doSetTopoCommState(const aTopologyId: Int64;
                             const aCommState: TCommState;
                             const aStateInfo: string);
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_SetDeviceOnLine';
    aQuery.AddParamI('devId', aTopologyId);
    aQuery.AddParamB('onLine', aCommState = csOnLine);
    aQuery.AddParamS('stateInfo', Copy(aStateInfo, 1, 64));
    aQuery.ExecProc;
  finally
    aQuery.Free;
  end;
end;

function doUpdateTopologyIp(const aTopologyId: Int64;
                            const aIp: string;
                            const aVersion: string;
                            const aDevModel: string;
                            var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aQuery: TPrADOQuery;
begin
  Result := True;

  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aSQLStr := ' update tb_Gateways'
             + ' set ip = ' + QuotedStr(aIp)
             + ' , version = ' + QuotedStr(aVersion)
             + ' where devId = ' + IntToStr(aTopologyId);
    aQuery.SQL.Text := aSQLStr;
    aQuery.ExecSQL;

    aSQLStr := ' update tb_Devices'
             + ' set devModel = ' + QuotedStr(aDevModel)
             + ' where devId = ' + IntToStr(aTopologyId);
    aQuery.SQL.Text := aSQLStr;
    aQuery.ExecSQL;
  finally
    aQuery.Free;
  end;
end;

function doSetDeviceRealData(const aTopologyId: Int64;
                             const aRealTime: TDateTime;
                             const aRealData: string;
                             const aMasterValue: string;
                             const aMeterValue: string;
                             var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_SaveDeviceRealData';
    aQuery.AddParamI('devId', aTopologyId);
    aQuery.AddParamT('lastRealTime', aRealTime);
    aQuery.AddParamS('realData', aRealData);
    aQuery.AddParamS('masterValue', aMasterValue);
    aQuery.AddParamS('meterValue', aMeterValue);
    aQuery.ExecProc;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doSaveDeviceRealDataList(const aRealDataList: TList<TRealDataInfo>;
                                  var aErrorInfo: string): Boolean;

  procedure doSaveByTable(const aQuery: TPrADOQuery; const aRealDataList: TList<TRealDataInfo>);
  var
    aTVPs: TPrTVPs;
    aRealData: TRealDataInfo;
    aLastRealData: string;
    aJson: TJsonObject;
    aJsonRealData: TJsonBaseObject;
  begin
    aTVPs := TPrTVPs.Create('RealDatas', 'TRealDataList', 'devId,realTime,realData,masterValue,meterValue,dataState,lastRealData');
    try
      for aRealData in aRealDataList do
      begin
        aJson := TJsonObject.Create;
        try
          aJson.S['realTime'] := DateTimeToStr(aRealData.RealTime);
          aJson.S['masterValue'] := aRealData.masterValue;
          aJson.S['meterValue'] := aRealData.MeterValue;
          aJson.I['dataState'] := aRealData.DataState;
          try
            aJsonRealData := TJsonBaseObject.Parse(aRealData.realData);
            if aJsonRealData is TJsonArray then
              aJson.A['realData'] := TJsonArray(aJsonRealData)
            else if aJsonRealData is TJsonObject then
              aJson.O['realData'] := TJsonObject(aJsonRealData);
          except
            aJson.O['realData'] := nil;
          end;

          aLastRealData := aJson.ToJSON(True);
        finally
          aJson.Free;
        end;

        with aTVPs.AddRecord do
        begin
          AddValue(aRealData.DevId);
          AddValue(aRealData.RealTime);
          AddValue(aRealData.realData);
          AddValue(aRealData.masterValue);
          AddValue(aRealData.MeterValue);
          AddValue(aRealData.DataState);
          AddValue(aLastRealData);
        end;
        if aTVPs.RecCount = 1000 then
          Break;
      end;

      aQuery.ProcName := 'proc_SaveDeviceRealDataList_A';
      aQuery.AddParamTVPs('RealDataList', aTVPs);
      aQuery.ExecProc;
    finally
      aTVPs.Free;
    end;
  end;

var
  aQuery: TPrADOQuery;
begin
  try
    aQuery := TPrADOQuery.Create(DB_METER);
    try
      //while aRealDataList.Count > 0 do
      //begin
        doSaveByTable(aQuery, aRealDataList);
        //aRealDataList.DeleteRange(0, 800);
      //end;

      Result := True;
    finally
      aQuery.Free;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := '保存实时数据异常: ' + E.Message;
      Result := False;
    end;
  end;
end;

function doGetAllGatewayList(const aParentId: RInteger;
                             const aIsOnLine: RBoolean;
                             const aFilter: RString;
                             var aPageInfo: RPageInfo;
                             const aGatewayList: TGatewayDataList;
                             var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aGateway: TGatewayData;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetGatewayListPage';
    aQuery.AddParamI('parentId', aParentId);
    aQuery.AddParamB('onLine', aIsOnLine);
    aQuery.AddParamS('filter', aFilter);
    aQuery.AddParamPage(aPageInfo);
    aQuery.OpenProc;

    aPageInfo := aQuery.ReadPageInfo;

    if aQuery.GotoNextRecordset then
    begin
      aQuery.First;
      while not aQuery.Eof do
      begin
        aGateway := TGatewayData.Create;
        aGateway.id := aQuery.ReadFieldAsRInteger('devId');
        aGateway.deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
        aGateway.parentId := aQuery.ReadFieldAsRInteger('parentId');
        aGateway.name := aQuery.ReadFieldAsRString('devName');
        aGateway.note := aQuery.ReadFieldAsRString('devNote');
        aGateway.devId := aQuery.ReadFieldAsRString('devNo');
        aGateway.devModel := aQuery.ReadFieldAsRString('devModel');
        aGateway.devModelName := aQuery.ReadFieldAsRString('devModelName');
        aGateway.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
        aGateway.devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
        if aQuery.ReadFieldAsRBoolean('onLine').IsTrue then
          aGateway.commState := csOnLine
        else
          aGateway.commState := csOffLine;
        aGateway.todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');

        aGateway.isTemp := aQuery.ReadFieldAsRBoolean('isTemp');
        aGateway.ip := aQuery.ReadFieldAsRString('ip');
        aGateway.runState := aQuery.ReadFieldAsRString('runState');
        aGateway.version := aQuery.ReadFieldAsRString('version');

        aGateway.isDebug := aQuery.ReadFieldAsRBoolean('isDebug');
        aGateway.debugInfo := aQuery.ReadFieldAsRString('debugInfo');


        aGateway.sortIndex := aQuery.ReadFieldAsRInteger('sortIndex');

        aGateway.UpdateData;
        aGatewayList.Add(aGateway);

        aQuery.Next;
      end;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetAllDeviceList(const aParentId: RInteger;
                            const aOnLine: RBoolean;
                            const aIsMeter: RBoolean;
                            const aFilter: RString;
                            var aPageInfo: RPageInfo;
                            const aDeviceList: TDeviceDataList;
                            var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aDevice: TDeviceData;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetTerminalListPage';
    aQuery.AddParamI('parentId', aParentId);
    aQuery.AddParamI('energyTypeId', RInteger.Null);
    aQuery.AddParamB('onLine', aOnLine);
    aQuery.AddParamB('isMeter', aIsMeter);
    aQuery.AddParamS('filter', aFilter);
    aQuery.AddParamPage(aPageInfo);
    aQuery.OpenProc;

    aPageInfo := aQuery.ReadPageInfo;

    if aQuery.GotoNextRecordset then
    begin
      aQuery.First;
      while not aQuery.Eof do
      begin
        aDevice := TDeviceData.Create;
        aDevice.id := aQuery.ReadFieldAsRInteger('devId');
        aDevice.deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
        aDevice.parentId := aQuery.ReadFieldAsRInteger('parentId');
        aDevice.name := aQuery.ReadFieldAsRString('devName');
        aDevice.note := aQuery.ReadFieldAsRString('devNote');
        aDevice.devId := aQuery.ReadFieldAsRString('devNo');
        aDevice.devModel := aQuery.ReadFieldAsRString('devModel');
        aDevice.devModelName := aQuery.ReadFieldAsRString('devModelName');
        aDevice.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
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

        aDevice.UpdateData;
        aDeviceList.Add(aDevice);

        aQuery.Next;
      end;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doCalcOnLineRate(const aTopologyId: Int64;
                          const aBeginTime: TDateTime;
                          const aEndTime: TDateTime;
                          var aOnLineRate: RDouble;
                          var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aQuery: TPrADOQuery;
  aTotalSeconds: Integer;  // 总秒数
  aOnLineSeconds: Integer; // 在线秒数
  aLastTime: TDateTime;
  aLastOnLine: Boolean;
  aCurTime: TDateTime;
  aCurOnLine: Boolean;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    // 总秒数
    aTotalSeconds := SecondsBetween(aBeginTime, aEndTime);
    aOnLineSeconds := 0;

    // 取开始状态
    aSQLStr := ' select top 1 datetime, onLine from tb_CommState'
             + ' where devId = ' + IntToStr(aTopologyId)
             + ' and datetime <= ''' + DateTimeToStr(aBeginTime) + ''''
             + ' order by datetime desc';
    aQuery.SQL.Text := aSQLStr;
    aQuery.Open;
    if aQuery.RecordCount = 0 then
    begin
      //aOnLineRate.Value := 0;
      //Exit(True);

      aSQLStr := ' select top 1 datetime, onLine from tb_CommState'
             + ' where devId = ' + IntToStr(aTopologyId)
             + ' and datetime >= ''' + DateTimeToStr(aBeginTime) + ''''
             + ' and datetime <= ''' + DateTimeToStr(aEndTime) + ''''
             + ' order by datetime';
      aQuery.Close;
      aQuery.SQL.Text := aSQLStr;
      aQuery.Open;
      if aQuery.RecordCount = 0 then
      begin
        aOnLineRate.Value := 0;
        Exit(True);
      end
      else
      begin
        aLastTime := aQuery.FieldByName('datetime').AsDateTime;
        aLastOnLine := aQuery.ReadFieldAsRBoolean('onLine').IsTrue;
        aTotalSeconds := SecondsBetween(aLastTime, aEndTime);
      end;
    end
    else
    begin
      aLastTime := aBeginTime;
      aLastOnLine := aQuery.ReadFieldAsRBoolean('onLine').IsTrue;
    end;

    if aTotalSeconds = 0 then
    begin
      if aLastOnLine then
        aOnLineRate.Value := 1
      else
        aOnLineRate.Value := 0;

      Exit(True);
    end;

    // 取范围内其他状态
    aSQLStr := ' select datetime, onLine from tb_CommState'
             + ' where devId = ' + IntToStr(aTopologyId)
             + ' and datetime > ''' + DateTimeToStr(aBeginTime) + ''''
             + ' and datetime <= ''' + DateTimeToStr(aEndTime) + ''''
             + ' order by datetime';
    aQuery.Close;
    aQuery.SQL.Text := aSQLStr;
    aQuery.Open;
    aQuery.First;
    while not aQuery.Eof do
    begin
      aCurTime := aQuery.FieldByName('datetime').AsDateTime;
      aCurOnLine := aQuery.ReadFieldAsRBoolean('onLine').IsTrue;

      if aLastOnLine <> aCurOnLine then
      begin

        if aLastOnLine then
          aOnLineSeconds := aOnLineSeconds + SecondsBetween(aCurTime, aLastTime);

        aLastTime := aCurTime;
        aLastOnLine := aCurOnLine;
      end;

      aQuery.Next;
    end;

    if aLastOnLine and (aEndTime > aLastTime) then
      aOnLineSeconds := aOnLineSeconds + SecondsBetween(aEndTime, aLastTime);

    aOnLineRate := RDouble.Parse(FormatFloat('0.0000', aOnLineSeconds/aTotalSeconds));

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doUpdateOnLineRate(const aTopologyId: Int64;
                            const aDate: TDateTime;
                            const aOnLineRate: RDouble;
                            const aIsStatis: Boolean;
                            var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  Result := True;

  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_UpdateOnLineRate';
    aQuery.AddParamI('devId', aTopologyId);
    aQuery.AddParamT('date', aDate);
    aQuery.AddParamD('onLineRate', aOnLineRate);
    aQuery.AddParamB('isStatis', aIsStatis);
    aQuery.ExecProc;
  finally
    aQuery.Free;
  end;
end;

function doGetDeviceLastOnLineRateStatisDate(const aTopologyId: Int64;
                                             var aDate: TDateTime;
                                             var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aResult: RResult;
begin
  Result := False;

  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetDeviceLastOnLineRateStatisDate';
    aQuery.AddParamI('devId', aTopologyId);
    aQuery.OpenProc;

    if not aQuery.ReadSQLResult(aResult) then
    begin
      aErrorInfo := aResult.Info;
      Exit;
    end;

    aDate := aQuery.FieldByName('date').AsDateTime;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetBrokerInfoList(const aBrokerInfoList: TBrokerInfoDataList;
                             var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetBrokerInfoList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aBrokerInfoList.Add do
      begin
        devId := aQuery.ReadFieldAsRInteger('devId');
        devName := aQuery.ReadFieldAsRString('devName');
        devNo := aQuery.ReadFieldAsRString('devNo');
        devModel := aQuery.ReadFieldAsRString('devModel');
        //devModelName := aQuery.ReadFieldAsRString('devModelName');
        devFactoryNo := aQuery.ReadFieldAsRString('devFactoryNo');
        devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
        lngLat := aQuery.ReadFieldAsRString('lngLat');
        onLine := aQuery.ReadFieldAsRBoolean('onLine');
        todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');
        gatewayCount := aQuery.ReadFieldAsRInteger('gatewayCount');
        gatewayOnLineCount := aQuery.ReadFieldAsRInteger('gatewayOnLineCount');
        gatewayOnLineRate := aQuery.ReadFieldAsRDouble('gatewayOnLineRate');
        gatewayTodayOnLineRate := aQuery.ReadFieldAsRDouble('gatewayTodayOnLineRate');
        terminalCount := aQuery.ReadFieldAsRInteger('terminalCount');
        terminalOnLineCount := aQuery.ReadFieldAsRInteger('terminalOnLineCount');
        terminalOnLineRate := aQuery.ReadFieldAsRDouble('terminalOnLineRate');
        terminalTodayOnLineRate := aQuery.ReadFieldAsRDouble('terminalTodayOnLineRate');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetBrokerOnLineInfo(const aDevId: RInteger;
                               const aBrokerInfo: TBrokerInfoData;
                               var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetBrokerOnLineInfo';
    aQuery.AddParamI('devId', aDevId);
    aQuery.OpenProc;

    aQuery.First;
    with aBrokerInfo do
    begin
      devId := aQuery.ReadFieldAsRInteger('devId');
      devName := aQuery.ReadFieldAsRString('devName');
      devNo := aQuery.ReadFieldAsRString('devNo');
      devModel := aQuery.ReadFieldAsRString('devModel');
      //devModelName := aQuery.ReadFieldAsRString('devModelName');
      devFactoryNo := aQuery.ReadFieldAsRString('devFactoryNo');
      devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
      onLine := aQuery.ReadFieldAsRBoolean('onLine');
      todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');
      gatewayCount := aQuery.ReadFieldAsRInteger('gatewayCount');
      gatewayOnLineCount := aQuery.ReadFieldAsRInteger('gatewayOnLineCount');
      gatewayOnLineRate := aQuery.ReadFieldAsRDouble('gatewayOnLineRate');
      gatewayTodayOnLineRate := aQuery.ReadFieldAsRDouble('gatewayTodayOnLineRate');
      terminalCount := aQuery.ReadFieldAsRInteger('terminalCount');
      terminalOnLineCount := aQuery.ReadFieldAsRInteger('terminalOnLineCount');
      terminalOnLineRate := aQuery.ReadFieldAsRDouble('terminalOnLineRate');
      terminalTodayOnLineRate := aQuery.ReadFieldAsRDouble('terminalTodayOnLineRate');
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doUpdateDevicesOfGateway(const aGatewayId: RInteger;
                                  const aRunState: RString;
                                  const aDeviceList: TDeviceDataList;
                                  var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aDevice: TDeviceData;
  aDeviceVar: TDeviceVarData;
  aIsFirst: Boolean;
  aSQLStr: string;
  aIndex: Integer;
  aResult: RResult;
  i: Integer;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.SQL.Clear;
    aQuery.SQL.Add('declare @tmpVarList as TDeviceVarList;');



    aSQLStr := '';
    aIsFirst := True;
    for aDevice in aDeviceList do
    begin
      aIndex := 1;
      for aDeviceVar in aDevice.deviceModel.VarList do
      begin
        if aIsFirst then
        begin
          aSQLStr := 'values ';
          aIsFirst := False;
        end
        else
          aSQLStr :=  aSQLStr + ', ';

        aSQLStr := aSQLStr + ' ( '+QuotedStr(aDevice.devId.AsString)
                              +','+QuotedStr(aDeviceVar.Code)
                              +','+QuotedStr(aDeviceVar.Name)
                              +','+IntToStr(Ord(aDeviceVar.VarType))
                              +','+QuotedStr('')
                              +','+IntToStr(aIndex)+')';

        aIndex := aIndex + 1;
      end;
    end;
    if aSQLStr <> '' then
    begin
      aQuery.SQL.Add('insert into @tmpVarList (devNo,varCode,varName,varType,varConn,sortIndex)');
      aQuery.SQL.Add(aSQLStr);
    end;

    aQuery.SQL.Add('exec proc_UpdateTerminalsOfGateway ');
    aQuery.SQL.Add('    @gatewayId = ' + aGatewayId.AsString + ',');
    aQuery.SQL.Add('    @runState =  N''' + aRunState.AsString + ''',');
    aQuery.SQL.Add('    @terminalList =  N''' + TDeviceDataListXml(aDeviceList).AsXml + ''',');
    aQuery.SQL.Add('    @varList = @tmpVarList ');
    aQuery.Open;

    //aQuery.ProcName := 'proc_UpdateTerminalsOfGateway';
    //aQuery.AddParamI('gatewayId', aGatewayId);
    //aQuery.AddParamS('runState', aRunState);
    //aQuery.AddParamS('terminalList', TDeviceDataListXml(aDeviceList).AsXml);
    //aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aResult);
    if Result then
    begin
      aQuery.GotoNextRecordset;

      for aDevice in aDeviceList do
      begin
        aQuery.Filtered := False;
        aQuery.Filter := 'devNo = '''+aDevice.devId.AsString+'''';
        aQuery.Filtered := True;

        if aQuery.RecordCount = 1 then
        begin
          aDevice.id := aQuery.ReadFieldAsRInteger('devId');
          aDevice.name := aQuery.ReadFieldAsRString('devName');
        end;
      end;

      for i := aDeviceList.Count - 1 downto 0 do
      begin
        if aDeviceList[i].id.IsNull then
          aDeviceList.Delete(i);
      end;
    end
    else
      aErrorInfo := aResult.Info;
  finally
    aQuery.Free;
  end;
end;

function doGetDeviceCustomVarList(const aDevId: RInteger;
                                  const aVarList: TDeviceVarDataList;
                                  var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetDeviceCustomVarList';
    aQuery.AddParamI('devId', aDevId);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aVarList.Add do
      begin
        varType := TVarType(aQuery.FieldByName('varType').AsInteger);
        code := aQuery.FieldByName('varCode').AsString;
        name := aQuery.FieldByName('varName').AsString;
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetSubscribeTerminalList(const aUserId: RInteger;
                                    var aDevNoList: string;
                                    var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetSubscribeTerminalList';
    aQuery.AddParamI('userId', aUserId);
    aQuery.OpenProc;

    aDevNoList := '';

    aQuery.First;
    while not aQuery.Eof do
    begin
      aDevNoList := aDevNoList + ',' + aQuery.FieldByName('devNo').AsString;
      aQuery.Next;
    end;

    if aDevNoList <> '' then
      Delete(aDevNoList, 1, 1);


    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetSubscribeTerminalUserList(const aDevUserCodeList: TStringList;
                                        var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aLine: string;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetSubscribeTerminalUserList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aLine := aQuery.FieldByName('userCodeList').AsString;
      if aLine <> '' then
      begin
        aLine := aQuery.FieldByName('devId').AsString + ',' + aLine;
        aDevUserCodeList.Add(aLine);
      end;

      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doSubscribeTerminals(const aUserId: RInteger;
                              const aDevNoList: RString;
                              var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_SubscribeTerminals';
    aQuery.AddParamI('userId', aUserId);
    aQuery.AddParamS('devNoList', aDevNoList);
    aQuery.ExecProc;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doUnSubscribeTerminals(const aUserId: RInteger;
                                const aDevNoList: RString;
                                var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_UnSubscribeTerminals';
    aQuery.AddParamI('userId', aUserId);
    aQuery.AddParamS('devNoList', aDevNoList);
    aQuery.ExecProc;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

end.
