unit UOnLineDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UOnLineData;

type
  TOnLineDataJson = class(TOnLineData)
  public
    function AsJson: TJsonObject;
    function AsStream: IPrStream;

    function AsJson_Info: TJsonObject;
  end;

  TOnLineDataListJson = class(TOnLineDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;

    function AsJson_Simple: TJsonObject;
    function AsStream_Simple: IPrStream;

    function AsJson_Log: TJsonArray;
    function AsStream_Log: IPrStream;

    function AsJson_Info: TJsonArray;
  end;

implementation

{ TOnLineDataJson }
function TOnLineDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RT['day'] := date.FormatLongDate;
  Result.RD['onLineRate'] := onLineRate;
end;

function TOnLineDataJson.AsJson_Info: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RT['date'] := date;
  Result.RI['onLineCount'] := onLineCount;
  Result.RI['debugCount'] := debugCount;
  Result.RI['offLineCount'] := offLineCount;
end;

function TOnLineDataJson.AsStream: IPrStream;
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

{ TOnLineDataListJson }
function TOnLineDataListJson.AsJson: TJsonArray;
var
  aOnLineData: TOnLineData;
begin
  Result := TJsonArray.Create;
  for aOnLineData in Self do
    Result.Add(TOnLineDataJson(aOnLineData).AsJson);
end;

function TOnLineDataListJson.AsStream: IPrStream;
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

function TOnLineDataListJson.AsJson_Info: TJsonArray;
var
  aOnLineData: TOnLineData;
begin
  Result := TJsonArray.Create;
  for aOnLineData in Self do
    Result.Add(TOnLineDataJson(aOnLineData).AsJson_Info);
end;

function TOnLineDataListJson.AsJson_Simple: TJsonObject;
var
  aOnLineData: TOnLineData;
begin
  Result := TJsonObject.Create;
  for aOnLineData in Self do
    Result.RD[aOnLineData.date.FormatLongDate.AsString] := aOnLineData.onLineRate;
end;

function TOnLineDataListJson.AsStream_Simple: IPrStream;
var
  aJson: TJsonObject;
begin
  aJson := AsJson_Simple;
  try
    Result := TPrStream.Create;
    aJson.SaveToStream(Result.Stream);
  finally
    aJson.Free;
  end;
end;

function TOnLineDataListJson.AsJson_Log: TJsonArray;
var
  aOnLineData: TOnLineData;
  aItem: TJsonObject;
begin
  Result := TJsonArray.Create;
  for aOnLineData in Self do
  begin
    aItem := Result.AddObject;
    aItem.RT['date'] := aOnLineData.date;
    aItem.RB['onLine'] := aOnLineData.onLine;
    aItem.RS['stateInfo'] := aOnLineData.stateInfo;
  end;
end;

function TOnLineDataListJson.AsStream_Log: IPrStream;
var
  aJson: TJsonArray;
begin
  aJson := AsJson_Log;
  try
    Result := TPrStream.Create;
    aJson.SaveToStream(Result.Stream);
  finally
    aJson.Free;
  end;
end;

end.
