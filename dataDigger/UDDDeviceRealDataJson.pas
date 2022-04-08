unit UDDDeviceRealDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDDeviceRealData;

type
  TDeviceRealDataJson = class(TDeviceRealData)
  public
    function AsJson: TJsonObject;
    function AsJson_Join: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
  end;

  TDeviceRealDataListJson = class(TDeviceRealDataList)
  public
    function AsJson: TJsonArray;
    function AsJson_Join: TJsonArray;
    function AsStream: IPrStream;
  end;

implementation

{ TDeviceRealDataJson }
function TDeviceRealDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RT['realDateTime'] := RealDateTime.FormatLongDateTime;
  Result.RS['realData'] := RealData;
  Result.RI['dataState'] := DataState;
end;

function TDeviceRealDataJson.AsJson_Join: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.FromJSON(RealData.AsString);
  Result.RT['realDateTime'] := RealDateTime.FormatLongDateTime;
  Result.RI['dataState'] := DataState;
end;

function TDeviceRealDataJson.ToJsonStr: string;
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

function TDeviceRealDataJson.AsStream: IPrStream;
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

{ TDeviceRealDataListJson }
function TDeviceRealDataListJson.AsJson: TJsonArray;
var
  aDeviceRealData: TDeviceRealData;
begin
  Result := TJsonArray.Create;
  for aDeviceRealData in Self do
    Result.Add(TDeviceRealDataJson(aDeviceRealData).AsJson);
end;

function TDeviceRealDataListJson.AsJson_Join: TJsonArray;
var
  aDeviceRealData: TDeviceRealData;
begin
  Result := TJsonArray.Create;
  for aDeviceRealData in Self do
    Result.Add(TDeviceRealDataJson(aDeviceRealData).AsJson_Join);
end;

function TDeviceRealDataListJson.AsStream: IPrStream;
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

end.
