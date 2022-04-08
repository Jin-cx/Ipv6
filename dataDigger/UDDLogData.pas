unit UDDLogData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // �ն��豸ʵʱ����
  TLogData = class
  private
    FLogTypeId: RInteger;       // ��־����
    FLogKindId: RInteger;       // ��־����
    FLogCode: RString;          // ��־����
    FLogInfo: RString;          // ��־����
    FLogDateTime: RDateTime;    // ��־����ʱ��
    FUserId: RInteger;          //
    FUserCode: RString;         //
    FUserName: RString;         //
    FClientIp: RString;         //
    FLogId: RInteger;           // ��־ID
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
