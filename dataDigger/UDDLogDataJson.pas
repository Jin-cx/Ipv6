unit UDDLogDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDLogData;

type
  TLogDataJson = class(TLogData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TLogDataListJson = class(TLogDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TLogDataJson }
function TLogDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RI['logId'] := LogId;
  Result.RI['logTypeId'] := LogTypeId;
  Result.RI['logKindId'] := LogKindId;
  Result.RS['logCode'] := LogCode;
  Result.RS['logInfo'] := LogInfo;
  Result.RT['logDateTime'] := LogDateTime;
  Result.RI['userId'] := UserId;
  Result.RS['userCode'] := UserCode;
  Result.RS['userName'] := UserName;
  Result.RS['clientIp'] := ClientIp;
end;

function TLogDataJson.ToJsonStr: string;
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

function TLogDataJson.AsStream: IPrStream;
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

procedure TLogDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  LogTypeId := aJson.RI['logTypeId'];
  LogKindId := aJson.RI['logKindId'];
  LogCode := aJson.RS['logCode'];
  LogInfo := aJson.RS['logInfo'];
  LogDateTime := aJson.RT['logDateTime'];
  UserId := aJson.RI['userId'];
  UserCode := aJson.RS['userCode'];
  UserName := aJson.RS['userName'];
  ClientIp := aJson.RS['clientIp'];
end;

procedure TLogDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TLogDataListJson }
function TLogDataListJson.AsJson: TJsonArray;
var
  aLogData: TLogData;
begin
  Result := TJsonArray.Create;
  for aLogData in Self do
    Result.Add(TLogDataJson(aLogData).AsJson);
end;

function TLogDataListJson.AsStream: IPrStream;
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

procedure TLogDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TLogDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TLogDataListJson.LoadFromJson(const aJsonString: string);
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
