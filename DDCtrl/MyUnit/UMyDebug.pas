{
  单元: 自定义输出 Debug 和 日志
  作者: lynch
  日期: 2016-06-11
}

unit UMyDebug;

interface

uses
  UPrLogInter, UPrDebugInter,
  UMyConfig;

type
  // 自定义 Debug
  TMyDebug = class(TObject)
  public
    // 输出 Debug 信息
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
