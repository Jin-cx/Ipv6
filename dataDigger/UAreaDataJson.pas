unit UAreaDataJson;

interface

uses
  Generics.Collections,
  puer.System, puer.Json.JsonDataObjects,
  UAreaData;

type
  TAreaDataJson = class(TAreaData)
  public
    function AsJson: TJsonObject;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject); overload;
    procedure LoadFromJson(const aJsonStr: string); overload;
  end;

  TAreaDataListJson = class(TAreaDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonStr: string); overload;
  end;

implementation

{ TAreaDataJson }
function TAreaDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RI['areaId'] := areaId;
  Result.RS['areaName'] := areaName;
  Result.RI['parentId'] := parentId;
  Result.RI['citeCount'] := citeCount;
end;

function TAreaDataJson.AsStream: IPrStream;
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

procedure TAreaDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  areaId := aJson.RI['areaId'];
  parentId := aJson.RI['parentId'];
  areaName := aJson.RS['areaName'];
end;

procedure TAreaDataJson.LoadFromJson(const aJsonStr: string);
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

{ TAreaDataListJson }
function TAreaDataListJson.AsJson: TJsonArray;
var
  aArea: TAreaData;
begin
  Result := TJsonArray.Create;
  for aArea in Self do
    Result.Add(TAreaDataJson(aArea).AsJson);
end;

function TAreaDataListJson.AsStream: IPrStream;
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

procedure TAreaDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  for i := 0 to aJson.Count - 1 do
    TAreaDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TAreaDataListJson.LoadFromJson(const aJsonStr: string);
var
  aJson: TJsonArray;
begin
  aJson := TJsonArray.Create;
  try
    aJson.FromJSON(aJsonStr);
    LoadFromJson(aJson);
  finally
    aJson.Free;
  end;
end;

end.
