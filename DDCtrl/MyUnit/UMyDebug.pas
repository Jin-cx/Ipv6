{
  ��Ԫ: �Զ������ Debug �� ��־
  ����: lynch
  ����: 2016-06-11
}

unit UMyDebug;

interface

uses
  UPrLogInter, UPrDebugInter,
  UMyConfig;

type
  // �Զ��� Debug
  TMyDebug = class(TObject)
  public
    // ��� Debug ��Ϣ
    class procedure OutputDebug(const DebugInfo: string;
                                const NeedWriteLog: Boolean = False);
  end;

implementation

{ TMyDebug }
class procedure TMyDebug.OutputDebug(const DebugInfo: string;
                                     const NeedWriteLog: Boolean);
var
  aInfo: string;
begin
  aInfo := _MyConfig.DebugHead + DebugInfo;
  TPrDebugInter.OutputDebug(aInfo);
  if NeedWriteLog then
    TPrLogInter.WriteLogInfo(aInfo);
end;

end.
