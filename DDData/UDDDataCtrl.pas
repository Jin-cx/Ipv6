unit UDDDataCtrl;

interface

uses
  Windows, Classes,
  UPrDbConnInter;

// 获取 DDComm 模块状态
function Active: Boolean; stdcall;

// 打开 DDComm 模块
procedure Open(const aDDLogInter: Pointer;
               const aConfigPath: string;
               const aDataPath: string); stdcall;

// 关闭 DDComm 模块
procedure Close; stdcall;

exports
  Active,
  Open,
  Close;

implementation

var
  _HasOpen: Boolean;

function Active: Boolean;
begin
  Result := _HasOpen;
end;

procedure Open(const aDDLogInter: Pointer;
               const aConfigPath: string;
               const aDataPath: string);
begin
  _HasOpen := True;
end;

procedure Close;
begin
  _HasOpen := False;
end;

end.
