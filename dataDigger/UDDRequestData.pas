unit UDDRequestData;

interface

uses
  Classes, SysUtils, Generics.Collections,
  puer.System;

type
  // ÇëÇóÊý¾Ý
  TRequestData = class
  private
    FUserId: RInteger;
    FUserCode: RString;
    FRequestId: RString;
    FGatewayDevNo: RString;
    FGatewayDevName: RString;
    FDevNo: RString;
    FCmdName: RString;
    FCmd: RString;
    FCmdData: RString;
    FBeginTime: RDateTime;
    FEndTime: RDateTime;
    FResult: RInteger;
    FErrorCode: RString;
    FErrorInfo: RString;
    FResponseData: RString;
    FInfo: RString;
  public
    constructor Create;

    property UserId: RInteger read FUserId write FUserId;
    property UserCode: RString read FUserCode write FUserCode;
    property RequestId: RString read FRequestId write FRequestId;
    property GatewayDevNo: RString read FGatewayDevNo write FGatewayDevNo;
    property GatewayDevName: RString read FGatewayDevName write FGatewayDevName;
    property DevNo: RString read FDevNo write FDevNo;
    property CmdName: RString read FCmdName write FCmdName;
    property Cmd: RString read FCmd write FCmd;
    property CmdData: RString read FCmdData write FCmdData;
    property BeginTime: RDateTime read FBeginTime write FBeginTime;
    property EndTime: RDateTime read FEndTime write FEndTime;
    property Result: RInteger read FResult write FResult;
    property ErrorCode: RString read FErrorCode write FErrorCode;
    property ErrorInfo: RString read FErrorInfo write FErrorInfo;
    property ResponseData: RString read FResponseData write FResponseData;
    property Info: RString read FInfo write FInfo;
  end;

  TRequestDataList = class(TObjectList<TRequestData>)
  public
    function Add(): TRequestData; overload;
  end;

implementation

{ TRequestData }
constructor TRequestData.Create;
begin
  FUserId.Clear;
  FUserCode.Clear;
  FRequestId.Clear;
  FGatewayDevNo.Clear;
  FGatewayDevName.Clear;
  FDevNo.Clear;
  FCmdName.Clear;
  FCmd.Clear;
  FCmdData.Clear;
  FBeginTime.Clear;
  FEndTime.Clear;
  FResult.Clear;
  FErrorCode.Clear;
  FErrorInfo.Clear;
  FResponseData.Clear;
  FInfo.Clear;
end;

{ TRequestDataList }
function TRequestDataList.Add(): TRequestData;
begin
  Result := TRequestData.Create;
  Self.Add(Result);
end;

end.

