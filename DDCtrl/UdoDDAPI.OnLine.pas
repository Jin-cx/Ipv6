unit UdoDDAPI.OnLine;

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

// 设备日在线率
function doGetOnlineList(const aDevId: RInteger;
                         const aDevNo: RString;
                         const aDevType: RInteger;
                         const aBeginDay: RDateTime;
                         const aEndDay: RDateTime;
                         const aOnLineList: TOnLineDataList;
                         var aErrorInfo: string): Boolean; stdcall;
// 设备在线离线日志
function doGetDeviceOnLineLogList(const aDevId: RInteger;
                                  const aBeginDay: RDateTime;
                                  const aEndDay: RDateTime;
                                  var aPageInfo: RPageInfo;
                                  const aOnLineList: TOnLineDataList;
                                  var aErrorInfo: string): Boolean; stdcall;

// 取设备平均在线率
function doGetOnLineSum(const aDevId: RInteger;
                        const aDevType: RInteger;
                        const aBeginDay: RDateTime;
                        const aEndDay: RDateTime;
                        var aOnLineRate: RDouble;
                        var aErrorInfo: string): Boolean; stdcall;

// 按分类取近半小时每5分钟的在线情况
function doGetTopoOnLineInfoList(const aDevType: TDeviceType;
                                 const aBrokerId: RInteger;
                                 const aOnLineList: TOnLineDataList;
                                 var aErrorInfo: string): Boolean; stdcall;

// 取拓扑实时状态数量
function doGetTopoStateCountInfo(var aBrokerTotalCount: RInteger;
                                 var aBrokerOnLineCount: RInteger;
                                 var aBrokerOffLineCount: RInteger;
                                 var aBrokerDebugCount: RInteger;
                                 var aGatewayTotalCount: RInteger;
                                 var aGatewayOnLineCount: RInteger;
                                 var aGatewayOffLineCount: RInteger;
                                 var aGatewayDoubtCount: RInteger;
                                 var aGatewayDebugCount: RInteger;
                                 var aTerminalTotalCount: RInteger;
                                 var aTerminalOnLineCount: RInteger;
                                 var aTerminalOffLineCount: RInteger;
                                 var aTerminalDebugCount: RInteger;
                                 var aErrorInfo: string): Boolean; stdcall;

exports
  doGetOnlineList,
  doGetDeviceOnLineLogList,
  doGetOnLineSum,
  doGetTopoOnLineInfoList,
  doGetTopoStateCountInfo;

implementation

function doGetOnlineList(const aDevId: RInteger;
                         const aDevNo: RString;
                         const aDevType: RInteger;
                         const aBeginDay: RDateTime;
                         const aEndDay: RDateTime;
                         const aOnLineList: TOnLineDataList;
                         var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aQuery.ProcName := 'proc_GetOnLineList';
    aQuery.AddParamI('devId', aDevId);
    aQuery.AddParamS('devNo', aDevNo);
    aQuery.AddParamI('devType', aDevType);
    aQuery.AddParamT('beginDay', aBeginDay);
    aQuery.AddParamT('endDay', aEndDay);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aOnLineList.Add do
      begin
        date := aQuery.ReadFieldAsRDateTime('date');
        onLineRate := aQuery.ReadFieldAsRDouble('onLineRate');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetDeviceOnLineLogList(const aDevId: RInteger;
                                  const aBeginDay: RDateTime;
                                  const aEndDay: RDateTime;
                                  var aPageInfo: RPageInfo;
                                  const aOnLineList: TOnLineDataList;
                                  var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  try
    aQuery := TPrADOQuery.Create(_MyConfig.DBName);
    try
      aQuery.ProcName := 'proc_GetDeviceOnLineLogList';
      aQuery.AddParamI('devId', aDevId);
      aQuery.AddParamT('beginDate', aBeginDay);
      aQuery.AddParamT('endDate', aEndDay);
      aQuery.AddParamPage(aPageInfo);
      aQuery.OpenProc;

      aPageInfo := aQuery.ReadPageInfo;

      if aQuery.GotoNextRecordset then
      begin
        aQuery.First;
        while not aQuery.Eof do
        begin
          with aOnLineList.Add do
          begin
            date := aQuery.ReadFieldAsRDateTime('datetime');
            onLine := aQuery.ReadFieldAsRBoolean('onLine');
            stateInfo := aQuery.ReadFieldAsRString('stateInfo');
          end;
          aQuery.Next;
        end;
      end;

      Result := True;
    finally
      aQuery.Free;
    end;
  except
    on E: Exception do
    begin
      Result := false;
      aErrorInfo := E.Message;
    end;
  end;
end;

function doGetOnLineSum(const aDevId: RInteger;
                        const aDevType: RInteger;
                        const aBeginDay: RDateTime;
                        const aEndDay: RDateTime;
                        var aOnLineRate: RDouble;
                        var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aQuery.ProcName := 'proc_GetOnLineSum';
    aQuery.AddParamI('devId', aDevId);
    aQuery.AddParamI('devType', aDevType);
    aQuery.AddParamT('beginDay', aBeginDay);
    aQuery.AddParamT('endDay', aEndDay);
    aQuery.OpenProc;

    aOnLineRate := aQuery.ReadFieldAsRDouble('onLineRate');

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetTopoOnLineInfoList(const aDevType: TDeviceType;
                                 const aBrokerId: RInteger;
                                 const aOnLineList: TOnLineDataList;
                                 var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aQuery.ProcName := 'proc_GetDeviceOnLineInfoList';
    aQuery.AddParamI('devType', Ord(aDevType));
    aQuery.AddParamI('brokerId', aBrokerId);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aOnLineList.Add do
      begin
        date := aQuery.ReadFieldAsRDateTime('datetime');
        totalCount := aQuery.ReadFieldAsRInteger('totalCount');
        onLineCount := aQuery.ReadFieldAsRInteger('onLineCount');
        offLineCount := aQuery.ReadFieldAsRInteger('offLineCount');
        debugCount := aQuery.ReadFieldAsRInteger('debugCount');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetTopoStateCountInfo(var aBrokerTotalCount: RInteger;
                                 var aBrokerOnLineCount: RInteger;
                                 var aBrokerOffLineCount: RInteger;
                                 var aBrokerDebugCount: RInteger;
                                 var aGatewayTotalCount: RInteger;
                                 var aGatewayOnLineCount: RInteger;
                                 var aGatewayOffLineCount: RInteger;
                                 var aGatewayDoubtCount: RInteger;
                                 var aGatewayDebugCount: RInteger;
                                 var aTerminalTotalCount: RInteger;
                                 var aTerminalOnLineCount: RInteger;
                                 var aTerminalOffLineCount: RInteger;
                                 var aTerminalDebugCount: RInteger;
                                 var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aQuery.ProcName := 'proc_GetAllDeviceRealOnLineInfo';
    aQuery.OpenProc;

    aQuery.First;
    aBrokerTotalCount := aQuery.ReadFieldAsRInteger('brokerTotalCount');
    aBrokerOnLineCount := aQuery.ReadFieldAsRInteger('brokerOnLineCount');
    aBrokerOffLineCount := aQuery.ReadFieldAsRInteger('brokerOffLineCount');
    aBrokerDebugCount := aQuery.ReadFieldAsRInteger('brokerDebugCount');
    aGatewayTotalCount := aQuery.ReadFieldAsRInteger('gatewayTotalCount');
    aGatewayOnLineCount := aQuery.ReadFieldAsRInteger('gatewayOnLineCount');
    aGatewayOffLineCount := aQuery.ReadFieldAsRInteger('gatewayOffLineCount');
    aGatewayDoubtCount := aQuery.ReadFieldAsRInteger('gatewayDoubtCount');
    aGatewayDebugCount := aQuery.ReadFieldAsRInteger('gatewayDebugCount');
    aTerminalTotalCount := aQuery.ReadFieldAsRInteger('terminalTotalCount');
    aTerminalOnLineCount := aQuery.ReadFieldAsRInteger('terminalOnLineCount');
    aTerminalOffLineCount := aQuery.ReadFieldAsRInteger('terminalOffLineCount');
    aTerminalDebugCount := aQuery.ReadFieldAsRInteger('terminalDebugCount');

    Result := True;
  finally
    aQuery.Free;
  end;
end;

end.
