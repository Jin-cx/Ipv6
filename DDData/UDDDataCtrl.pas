unit UDDDataCtrl;

interface

uses
  Windows, Classes,
  UPrDbConnInter;

// ��ȡ DDComm ģ��״̬
function Active: Boolean; stdcall;

// �� DDComm ģ��
procedure Open(const aDDLogInter: Pointer;
               const aConfigPath: string;
               const aDataPath: string); stdcall;

// �ر� DDComm ģ��
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
