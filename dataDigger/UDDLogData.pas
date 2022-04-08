unit UDDLogData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // 终端设备实时数据
  TLogData = class
  private
    FLogTypeId: RInteger;       // 日志类型
    FLogKindId: RInteger;       // 日志类型
    FLogCode: RString;          // 日志编码
    FLogInfo: RString;          // 日志内容
    FLogDateTime: RDateTime;    // 日志日期时间
    FUserId: RInteger;          //
    FUserCode: RString;         //
    FUserName: RString;         //
    FClientIp: RString;         //
    FLogId: RInteger;           // 日志ID
  public
    constructor Create;

    property LogId: RInteger read FLogId write FLogId;
    property LogTypeId: RInteger read FLogTypeId write FLogTypeId;
    property LogKindId: RInteger read FLogKindId write FLogKindId;
    property LogCode: RString read FLogCode write FLogCode;
    property LogInfo: RString read FLogInfo write FLogInfo;
    property LogDateTime: RDateTime read FLogDateTime write FLogDateTime;
    property UserId: RInteger read FUserId write FUserId;
    property UserCode: RString read FUserCode write FUserCode;
    property UserName: RString read FUserName write FUserName;
    property ClientIp: RString read FClientIp write FClientIp;
  end;

  TLogDataList = class(TObjectList<TLogData>)
  public
    function Add(): TLogData; overload;
  end;

implementation

{ TLogData }
constructor TLogData.Create;
begin
  FLogTypeId.Clear;
  FLogKindId.Clear;
  FLogCode.Clear;
  FLogInfo.Clear;
  FLogDateTime.Clear;
  FUserId.Clear;
  FUserCode.Clear;
  FUserName.Clear;
  FClientIp.Clear;
  FLogId.Clear;
end;

{ TLogDataList }
function TLogDataList.Add(): TLogData;
begin
  Result := TLogData.Create;
  Self.Add(Result);
end;

end.
