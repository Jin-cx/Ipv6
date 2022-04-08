unit UEnergyUseDataJson;

interface

uses
  SysUtils, DateUtils,
  puer.System, puer.Json.JsonDataObjects,
  UEnergyUseData;

type
  TEnergyHourUseDataJson = class(TEnergyHourUseData)
  public
    function AsJson: TJsonObject;
  end;

  TEnergyHourUseDataListJson = class(TEnergyHourUseDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
  end;

  TEnergyDayUseDataJson = class(TEnergyDayUseData)
  public
    function AsJson: TJsonObject;
  end;

  TEnergyDayUseDataListJson = class(TEnergyDayUseDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
  end;

  TEnergyMonthUseDataJson = class(TEnergyMonthUseData)
  public
    function AsJson: TJsonObject;
  end;

  TEnergyMonthUseDataListJson = class(TEnergyMonthUseDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
  end;

implementation

{ TEnergyHourUseDataJson }
function TEnergyHourUseDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RT['dayHour'] := dayHour.Format(FormatSettings.LongDateFormat + ' hh');
  Result.RD['dosage'] := dosage;
  //Result.RD['tce'] := tce;
end;

{ TEnergyHourUseDataListJson }
function TEnergyHourUseDataListJson.AsJson: TJsonArray;
var
  aEnergyUse: TEnergyHourUseData;
begin
  Result := TJsonArray.Create;
  for aEnergyUse in Self do
    Result.Add(TEnergyHourUseDataJson(aEnergyUse).AsJson);
end;

function TEnergyHourUseDataListJson.AsStream: IPrStream;
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

{ TEnergyDayUseDataJson }
function TEnergyDayUseDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RT['day'] := day.FormatLongDate;
  Result.RD['dosage'] := dosage;
  //Result.RD['tce'] := tce;
end;

{ TEnergyDayUseDataListJson }
function TEnergyDayUseDataListJson.AsJson: TJsonArray;
var
  aEnergyUse: TEnergyDayUseData;
begin
  Result := TJsonArray.Create;
  for aEnergyUse in Self do
    Result.Add(TEnergyDayUseDataJson(aEnergyUse).AsJson);
end;

function TEnergyDayUseDataListJson.AsStream: IPrStream;
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

{ TEnergyMonthUseDataJson }
function TEnergyMonthUseDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RI['year'] := year;
  Result.RI['month'] := month;
  Result.S['yearMonth'] := FormatDateTime('YYYY-MM', EncodeDateTime(year.Value, month.Value, 1, 0, 0, 0, 0));
  Result.RD['dosage'] := dosage;
  //Result.RD['tce'] := tce;
end;

{ TEnergyMonthUseDataListJson }
function TEnergyMonthUseDataListJson.AsJson: TJsonArray;
var
  aEnergyUse: TEnergyMonthUseData;
begin
  Result := TJsonArray.Create;
  for aEnergyUse in Self do
    Result.Add(TEnergyMonthUseDataJson(aEnergyUse).AsJson);
end;

function TEnergyMonthUseDataListJson.AsStream: IPrStream;
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
