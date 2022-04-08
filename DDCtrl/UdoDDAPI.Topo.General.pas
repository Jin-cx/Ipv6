unit UdoDDAPI.Topo.General;

interface

uses
  puer.System,
  UPrDbConnInter,
  UMyConfig;

// 设置 Device 维护状态
function doSetDeviceDebug(const aDevId: RInteger;
                            const aDebugInfo: RString;
                            var aError: RResult): Boolean; stdcall;
// 取消 Device 维护状态
function doCancelDeviceDebug(const aDevId: RInteger;
                               var aError: RResult): Boolean; stdcall;

exports
  doSetDeviceDebug,
  doCancelDeviceDebug;

implementation

function doSetDeviceDebug(const aDevId: RInteger;
                            const aDebugInfo: RString;
                            var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_SetDeviceDebug';
    aQuery.AddParamI('devId', aDevId);
    aQuery.AddParamS('debugInfo', aDebugInfo);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    aQuery.Free;
  end;
end;

function doCancelDeviceDebug(const aDevId: RInteger; var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_CancelDeviceDebug';
    aQuery.AddParamI('devId', aDevId);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    aQuery.Free;
  end;
end;

end.
