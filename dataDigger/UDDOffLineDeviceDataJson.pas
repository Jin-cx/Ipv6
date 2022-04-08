unit UDDOffLineDeviceDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDOffLineDeviceData, UDDTopologyData, UDDTopologyDataJson;

type
  TOffLineDeviceDataJson = class(TOffLineDeviceData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TOffLineDeviceDataListJson = class(TOffLineDeviceDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TOffLineDeviceDataJson }
function TOffLineDeviceDataJson.AsJson: TJsonObject;
begin
  Self.UpdateData;
  Result := TTopologyDataJson(Self).AsJson;
end;

function TOffLineDeviceDataJson.ToJsonStr: string;
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

function TOffLineDeviceDataJson.AsStream: IPrStream;
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

procedure TOffLineDeviceDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  TTopologyDataJson(Self).LoadFromJson(aJson);
  Self.ParseData;
end;

procedure TOffLineDeviceDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TOffLineDeviceDataListJson }
function TOffLineDeviceDataListJson.AsJson: TJsonArray;
var
  aDeviceData: TOffLineDeviceData;
begin
  Result := TJsonArray.Create;
  for aDeviceData in Self do
    Result.Add(TOffLineDeviceDataJson(aDeviceData).AsJson);
end;

function TOffLineDeviceDataListJson.AsStream: IPrStream;
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

procedure TOffLineDeviceDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TOffLineDeviceDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TOffLineDeviceDataListJson.LoadFromJson(const aJsonString: string);
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
