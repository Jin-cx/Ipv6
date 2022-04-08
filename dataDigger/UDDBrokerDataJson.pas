unit UDDBrokerDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDBrokerData, UDDTopologyData, UDDTopologyDataJson;

type
  TBrokerDataJson = class(TBrokerData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TBrokerDataListJson = class(TBrokerDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TBrokerDataJson }
function TBrokerDataJson.AsJson: TJsonObject;
var
  aHost: string;
  aPort: string;
begin
  aHost := Self.brokerHost.AsString;
  aPort := Self.brokerPort.AsString;
  if aPort <> '' then
    aHost := aHost + ':' + aPort;

  Self.UpdateData;
  Result := TTopologyDataJson(Self).AsJson;
  Result.S['brokerHost'] := aHost;
end;

function TBrokerDataJson.ToJsonStr: string;
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

function TBrokerDataJson.AsStream: IPrStream;
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

procedure TBrokerDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  TTopologyDataJson(Self).LoadFromJson(aJson);
  Self.ParseData;
end;

procedure TBrokerDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TBrokerDataListJson }
function TBrokerDataListJson.AsJson: TJsonArray;
var
  aBrokerData: TBrokerData;
begin
  Result := TJsonArray.Create;
  for aBrokerData in Self do
    Result.Add(TBrokerDataJson(aBrokerData).AsJson);
end;

function TBrokerDataListJson.AsStream: IPrStream;
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

procedure TBrokerDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TBrokerDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TBrokerDataListJson.LoadFromJson(const aJsonString: string);
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
