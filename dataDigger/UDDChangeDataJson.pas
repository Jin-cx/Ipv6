unit UDDChangeDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDChangeData;

type
  TMeterValueDataJson = class(TMeterValueData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TMeterValueDataListJson = class(TMeterValueDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

  TChangeDataJson = class(TChangeData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TChangeDataListJson = class(TChangeDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TMeterValueDataJson }
function TMeterValueDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RS['meterValueCode'] := meterValueCode;
  Result.RD['meterValue'] := meterValue;
end;

function TMeterValueDataJson.ToJsonStr: string;
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

function TMeterValueDataJson.AsStream: IPrStream;
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

procedure TMeterValueDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  meterValueCode := aJson.RS['meterValueCode'];
  meterValue := aJson.RD['meterValue'];
end;

procedure TMeterValueDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TMeterValueDataListJson }
function TMeterValueDataListJson.AsJson: TJsonArray;
var
  aMeterValueData: TMeterValueData;
begin
  Result := TJsonArray.Create;
  for aMeterValueData in Self do
    Result.Add(TMeterValueDataJson(aMeterValueData).AsJson);
end;

function TMeterValueDataListJson.AsStream: IPrStream;
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

procedure TMeterValueDataListJson.LoadFromJson(const aJson: TJsonObject);
var
  i: Integer;
  aName: string;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
  begin
    aName := aJson.Names[i];
    with Self.Add do
    begin
      meterValueCode.Value := aName;
      meterValue := aJson.RD[aName];
    end;
  end;
end;

procedure TMeterValueDataListJson.LoadFromJson(const aJsonString: string);
var
  aJson: TJsonObject;
begin
  if aJsonString = '' then
    Exit;

  aJson := TJsonObject.Create;
  try
    aJson.FromJSON(aJsonString);
    LoadFromJson(aJson);
  finally
    aJson.Free;
  end;
end;

{ TChangeDataJson }
function TChangeDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RI['changeId'] := changeId;
  Result.RI['userId'] := userId;
  Result.RS['userCode'] := userCode;
  Result.RS['userName'] := userName;
  Result.RS['projectUserCode'] := projectUserCode;
  Result.RS['projectUserName'] := projectUserName;
  Result.RT['changeTime'] := changeTime;
  Result.RS['changeNote'] := changeNote;
  Result.RS['devName'] := devName;
  Result.RS['devModel'] := devModel;
  Result.RS['devModelName'] := devModelName;
  Result.RS['devInstallAddr'] := devInstallAddr;
  Result.RI['oldDevId'] := oldDevId;
  Result.RS['oldDevNo'] := oldDevNo;
  Result.RS['oldDevFactoryNo'] := oldDevFactoryNo;
  Result.RI['newDevId'] := newDevId;
  Result.RS['newDevNo'] := newDevNo;
  Result.RS['newDevFactoryNo'] := newDevFactoryNo;
  Result.RS['newConn'] := newConn;
  Result.RT['endTime'] := endTime;

  Result.RT['beginTime'] := beginTime;

end;

function TChangeDataJson.ToJsonStr: string;
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

function TChangeDataJson.AsStream: IPrStream;
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

procedure TChangeDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  {LogTypeId := aJson.RI['logTypeId'];
  LogKindId := aJson.RI['logKindId'];
  LogCode := aJson.RS['logCode'];
  LogInfo := aJson.RS['logInfo'];
  LogDateTime := aJson.RT['logDateTime'];
  UserId := aJson.RI['userId'];
  UserCode := aJson.RS['userCode'];
  UserName := aJson.RS['userName'];
  ClientIp := aJson.RS['clientIp']; }
end;

procedure TChangeDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TChangeDataListJson }
function TChangeDataListJson.AsJson: TJsonArray;
var
  aChangeData: TChangeData;
begin
  Result := TJsonArray.Create;
  for aChangeData in Self do
    Result.Add(TChangeDataJson(aChangeData).AsJson);
end;

function TChangeDataListJson.AsStream: IPrStream;
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

procedure TChangeDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TChangeDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TChangeDataListJson.LoadFromJson(const aJsonString: string);
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
