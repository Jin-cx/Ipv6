unit UDDFileListDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDFileListData;

type
  TFileDataJson = class(TFileData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TFileDataListJson = class(TFileDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TFileDataJson }
function TFileDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RS['fileName'] := FileName;
  Result.RT['creationTime'] := CreationTime;
  Result.RT['lastWriteTime'] := LastWriteTime;
  Result.RI['fileSize'] := FileSize;
end;

function TFileDataJson.ToJsonStr: string;
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

function TFileDataJson.AsStream: IPrStream;
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

procedure TFileDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  FileName := aJson.RS['fileName'];
  CreationTime := aJson.RT['creationTime'];
  LastWriteTime := aJson.RT['lastWriteTime'];
  FileSize := aJson.RI['fileSize'];
end;

procedure TFileDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TFileDataListJson }
function TFileDataListJson.AsJson: TJsonArray;
var
  aFileData: TFileData;
begin
  Result := TJsonArray.Create;
  for aFileData in Self do
    Result.Add(TFileDataJson(aFileData).AsJson);
end;

function TFileDataListJson.AsStream: IPrStream;
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

procedure TFileDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TFileDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TFileDataListJson.LoadFromJson(const aJsonString: string);
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
