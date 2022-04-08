unit UDDGatewayDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDGatewayData, UDDTopologyData, UDDTopologyDataJson;

type
  TGatewayDataJson = class(TGatewayData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TGatewayDataListJson = class(TGatewayDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TGatewayDataJson }
function TGatewayDataJson.AsJson: TJsonObject;
begin
  Self.UpdateData;
  Result := TTopologyDataJson(Self).AsJson;
end;

function TGatewayDataJson.ToJsonStr: string;
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

function TGatewayDataJson.AsStream: IPrStream;
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

procedure TGatewayDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  TTopologyDataJson(Self).LoadFromJson(aJson);
  Self.ParseData;
end;

procedure TGatewayDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TGatewayDataListJson }
function TGatewayDataListJson.AsJson: TJsonArray;
var
  aGatewayData: TGatewayData;
begin
  Result := TJsonArray.Create;
  for aGatewayData in Self do
    Result.Add(TGatewayDataJson(aGatewayData).AsJson);
end;

function TGatewayDataListJson.AsStream: IPrStream;
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

procedure TGatewayDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TGatewayDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TGatewayDataListJson.LoadFromJson(const aJsonString: string);
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
