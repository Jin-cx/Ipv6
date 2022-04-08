unit UDDGatewayCtrl;

interface

uses
  SysUtils, Windows,
  UDDCommData;

type
  TUpdateCmd = (
    ucNone,        // ʲô������
    ucOnLine,      // ����
    ucOffLine,     // ����
    ucData         // �ϱ�����
  );

  TDDGatewayCtrl = class
  public
    class function GetUpdateCmd(const aCmd, aCmdData: string): TUpdateCmd;
  end;

implementation

{ TDDGatewayCtrl }
class function TDDGatewayCtrl.GetUpdateCmd(const aCmd, aCmdData: string): TUpdateCmd;
begin
  Result := ucNone;

  // �ϱ�״̬
  if SameText(aCmd, 'push/state.do') then
  begin
    if aCmdData = '1' then
      Result := ucOnLine
    else if aCmdData = '0' then
      Result := ucOffLine;
  end
  // �ϱ�����
  else if SameText(aCmd, {'push/data.do'}'do/auto_up_data') then
  begin
    Result := ucData;
  end;
end;

end.
