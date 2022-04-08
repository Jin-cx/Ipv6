unit UDDRequestDataJson;

interface

uses
  SysUtils,
  puer.System, puer.Json.JsonDataObjects,
  UDDRequestData;

type
  TRequestDataJson = class(TRequestData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TRequestDataListJson = class(TRequestDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TRequestDataJson }
function TRequestDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RS['requestUser'] := UserCode;
  Result.RS['userCode'] := UserCode;
  Result.RS['requestId'] := RequestId;
  Result.RS['devId'] := DevNo;
  Result.RS['gatewayDevNo'] := GatewayDevNo;
  Result.RS['gatewayDevName'] := GatewayDevName;
  Result.RS['devNo'] := DevNo;
  Result.RS['cmdName'] := CmdName;
  Result.RS['cmd'] := Cmd;
  Result.RS['cmdData'] := CmdData;
  Result.RT['beginTime'] := BeginTime.Format(FormatSettings.LongDateFormat + ' ' + FormatSettings.LongTimeFormat +'.zzz');
  Result.RT['endTime'] := EndTime.Format(FormatSettings.LongDateFormat + ' ' + FormatSettings.LongTimeFormat +'.zzz');
  Result.RI['result'] := Self.Result;
  Result.RS['errorCode'] := ErrorCode;
  Result.RS['errorInfo'] := ErrorInfo;
  Result.RS['responseData'] := ResponseData;
  Result.RS['info'] := Info;
end;

function TRequestDataJson.ToJsonStr: string;
var
  aJson: TJsonObject;
begin
  aJson := AsJson;
  try
    Result := aJson.ToJSON(True);
  finally
    aJson.Free;
  end;
end;

function TRequestDataJson.AsStream: IPrStream;
var
  aJson: TJsonObject;
begin
  aJson := AsJson;
  try
    Result := TPrStream.Create;
    aJson.SaveToStream(Result.Stream);
  finally
    aJson.Free;
  end;
end;

procedure TRequestDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  RequestId := aJson.RS['requestId'];
  UserCode := aJson.RS['userCode'];
  GatewayDevNo := aJson.RS['gatewayDevNo'];
  GatewayDevName := aJson.RS['gatewayDevName'];
  DevNo := aJson.RS['devNo'];
  CmdName := aJson.RS['cmdName'];
  Cmd := aJson.RS['cmd'];
  CmdData := aJson.RS['cmdData'];
  BeginTime := aJson.RT['beginTime'];
  EndTime := aJson.RT['endTime'];
  Result := aJson.RI['result'];
  ErrorCode := aJson.RS['errorCode'];
  ErrorInfo := aJson.RS['errorInfo'];
  ResponseData := aJson.RS['responseData'];
  Info := aJson.RS['info'];
end;

procedure TRequestDataJson.LoadFromJsonStr(const aJsonStr: string);
var
  aJson: TJsonObject;
begin
  aJson := TJsonObject.Create;
  try
    aJson.FromJSON(aJsonStr);
    LoadFromJson(aJson);
  finally
    aJson.Free;
  end;
end;

{ TRequestDataListJson }
function TRequestDataListJson.AsJson: TJsonArray;
var
  aRequestData: TRequestData;
begin
  Result := TJsonArray.Create;
  for aRequestData in Self do
    Result.Add(TRequestDataJson(aRequestData).AsJson);
end;

function TRequestDataListJson.AsStream: IPrStream;
var
  aJson: TJsonArray;
begin
  aJson := AsJson;
  try
    Result := TPrStream.Create;
    aJson.SaveToStream(Result.Stream);
  finally
    aJson.Free;
  end;
end;

procedure TRequestDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TRequestDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TRequestDataListJson.LoadFromJson(const aJsonString: string);
var
  aJson: TJsonArray;
begin
  if aJsonString = '' then
    Exit;

  aJson := TJsonArray.Create;
  try
    aJson.FromJSON(aJsonString);
    LoadFromJson(aJson);
  finally
    aJson.Free;
  end;
end;

end.
