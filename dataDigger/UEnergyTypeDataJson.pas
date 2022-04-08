unit UEnergyTypeDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UEnergyTypeData;

type
  TEnergyTypeDataJson = class(TEnergyTypeData)
  public
    function AsJson: TJsonObject;
    function AsStream: IPrStream;
  end;

  TEnergyTypeDataListJson = class(TEnergyTypeDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
  end;

implementation

{ TEnergyTypeDataJson }
function TEnergyTypeDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RI['energyTypeId'] := energyTypeId;
  Result.RS['energyTypeCode'] := energyTypeCode;
  Result.RS['energyTypeName'] := energyTypeName;
  Result.RS['unit_en'] := unit_en;
  Result.RS['unit_zh'] := unit_zh;
  //Result.RD['price'] := price;
  //Result.RB['isUsing'] := isUsing;
  //Result.RI['citeCount'] := citeCount;
end;

function TEnergyTypeDataJson.AsStream: IPrStream;
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

{ TEnergyTypeDataListJson }
function TEnergyTypeDataListJson.AsJson: TJsonArray;
var
  aEnergyType: TEnergyTypeData;
begin
  Result := TJsonArray.Create;
  for aEnergyType in Self do
    Result.Add(TEnergyTypeDataJson(aEnergyType).AsJson);
end;

function TEnergyTypeDataListJson.AsStream: IPrStream;
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
