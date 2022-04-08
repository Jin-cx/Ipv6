unit UDDGatewayCtrl;

interface

uses
  SysUtils, Windows,
  UDDCommData;

type
  TUpdateCmd = (
    ucNone,        // 什么都不是
    ucOnLine,      // 在线
    ucOffLine,     // 离线
    ucData         // 上报数据
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

  // 上报状态
  if SameText(aCmd, 'push/state.do') then
  begin
    if aCmdData = '1' then
      Result := ucOnLine
    else if aCmdData = '0' then
      Result := ucOffLine;
  end
  // 上报数据
  else if SameText(aCmd, {'push/data.do'}'do/auto_up_data') then
  begin
    Result := ucData;
  end;
end;

end.
