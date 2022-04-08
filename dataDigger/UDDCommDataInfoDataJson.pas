unit UDDCommDataInfoDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDCommDataInfoData;

type
  TCommDataInfoDataJson = class(TCommDataInfoData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TCommDataInfoDataListJson = class(TCommDataInfoDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TCommDataInfoDataJson }
function TCommDataInfoDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RT['dayHour'] := dayHour;
  Result.RI['sendCount'] := sendCount;
  Result.RI['sendSize'] := sendSize;
  Result.RI['receiveCount'] := receiveCount;
  Result.RI['receiveSize'] := receiveSize;
  // ºÊ»›±£¡Ù
  Result.RT['date'] := dayHour;
  Result.RI['sendCommCount'] := sendCount;
  Result.RI['sendCommSize'] := sendSize;
  Result.RI['receiveCommCount'] := receiveCount;
  Result.RI['receiveCommSize'] := receiveSize;
end;

function TCommDataInfoDataJson.ToJsonStr: string;
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

function TCommDataInfoDataJson.AsStream: IPrStream;
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

procedure TCommDataInfoDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  dayHour := aJson.RT['dayHour'];
  sendCount := aJson.RI['sendCount'];
  sendSize := aJson.RI['sendSize'];
  receiveCount := aJson.RI['receiveCount'];
  receiveSize := aJson.RI['receiveSize'];
end;

procedure TCommDataInfoDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TCommDataInfoDataListJson }
function TCommDataInfoDataListJson.AsJson: TJsonArray;
var
  aCommInfo: TCommDataInfoData;
begin
  Result := TJsonArray.Create;
  for aCommInfo in Self do
    Result.Add(TCommDataInfoDataJson(aCommInfo).AsJson);
end;

function TCommDataInfoDataListJson.AsStream: IPrStream;
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

procedure TCommDataInfoDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TCommDataInfoDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TCommDataInfoDataListJson.LoadFromJson(const aJsonString: string);
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
