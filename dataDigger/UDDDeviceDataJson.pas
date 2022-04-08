unit UDDDeviceDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDDeviceData, UDDTopologyData, UDDTopologyDataJson, UDDDeviceModelDataJson,
  UDDDeviceModelData, UDDMeterDataJson;

type
  TDeviceDataJson = class(TDeviceData)
  public
    function AsJson: TJsonObject;
    function AsJson_Full: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    function AsStream_Full: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TDeviceDataListJson = class(TDeviceDataList)
  public
    function AsJson_Full: TJsonArray;
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    function AsStream_Full: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TDeviceDataJson }
function TDeviceDataJson.AsJson: TJsonObject;
begin
  Self.UpdateData;
  Result := TTopologyDataJson(Self).AsJson;
  Result.RB['isMeter'] := Self.isMeter;
  Result.RS['lastRealTime'] := Self.lastRealTime;
  Result.RS['lastRealData'] := Self.masterValue;
  Result.RS['meterValue'] := Self.meterValue;
end;

function TDeviceDataJson.AsJson_Full: TJsonObject;
var
  aMeterValueData: TMeterValueData;
  aMeterValueJson: TJsonObject;
begin
  Self.UpdateData;
  Result := TTopologyDataJson(Self).AsJson;
  if Self.realData.AsString = '' then
    Result.O['realData'].FromJSON('{}')
  else
    Result.O['realData'].FromJSON(Self.realData.AsString);
  Result.RB['isMeter'] := Self.isMeter;
  Result.RS['lastRealTime'] := Self.lastRealTime;

  for aMeterValueData in Self.deviceModel.MeterInfo.MeterValueList do
  begin
    aMeterValueJson := Result.A['lastMeterValueList'].AddObject;
    aMeterValueJson.S['meterValueCode'] := aMeterValueData.MeterValueCode;
    aMeterValueJson.S['meterValueName'] := aMeterValueData.MeterValueName;
    if Self.realData.AsString <> '' then
      aMeterValueJson.RD['meterValue'] := Result.O['realData'].RD[aMeterValueData.MeterValueCode];
  end;

  Result.RS['lastRealData'] := Self.masterValue;
  Result.RS['meterValue'] := Self.meterValue;
  if Self.conn.AsString <> '' then
    Result.O['connValues'].FromJSON(Self.conn.AsString);

  if Self.isMeter.IsTrue and (Self.meterList.Count > 0) then
  begin
    Result.RS['meterCode'] := Self.meterList[0].MeterCode;
    Result.RD['meterRate'] := Self.meterList[0].MeterRate;
    Result.RI['energyTypeId'] := Self.meterList[0].EnergyTypeId;
    Result.RS['energyTypeName'] := Self.meterList[0].EnergyTypeName;
    Result.RT['lastDataTime'] := Self.meterList[0].lastDataTime.FormatLongDateTime;
    Result.RD['lastMeterValue'] := Self.meterList[0].lastMeterValue;
    Result.RS['unit_en'] := Self.meterList[0].unit_en;
    Result.RS['unit_zh'] := Self.meterList[0].unit_zh;
  end;

  if Self.isMeter.IsTrue then
    Result.A['meterList'] := TMeterDataListJson(Self.meterList).AsJson;

  Result.O['devModelInfo'] := TDeviceModelDataJson(Self.deviceModel).AsJson;
end;

function TDeviceDataJson.ToJsonStr: string;
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

function TDeviceDataJson.AsStream: IPrStream;
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

function TDeviceDataJson.AsStream_Full: IPrStream;
var
  aJson: TJsonObject;
begin
  aJson := AsJson_Full;
  try
    Result := TPrStream.Create;
    aJson.SaveToStream(Result.Stream);
  finally
    aJson.Free;
  end;
end;

procedure TDeviceDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  TTopologyDataJson(Self).LoadFromJson(aJson);
  Self.ParseData;
  TDeviceVarDataListJson(Self.deviceModel.VarList).LoadFromJson(aJson.O['devModelInfo'].A['varList']);
end;

procedure TDeviceDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TDeviceDataListJson }
function TDeviceDataListJson.AsJson_Full: TJsonArray;
var
  aDeviceData: TDeviceData;
begin
  Result := TJsonArray.Create;
  for aDeviceData in Self do
    Result.Add(TDeviceDataJson(aDeviceData).AsJson_Full);
end;

function TDeviceDataListJson.AsJson: TJsonArray;
var
  aDeviceData: TDeviceData;
begin
  Result := TJsonArray.Create;
  for aDeviceData in Self do
    Result.Add(TDeviceDataJson(aDeviceData).AsJson);
end;

function TDeviceDataListJson.AsStream: IPrStream;
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

function TDeviceDataListJson.AsStream_Full: IPrStream;
var
  aJson: TJsonArray;
begin
  aJson := AsJson_Full;
  try
    Result := TPrStream.Create;
    aJson.SaveToStream(Result.Stream);
  finally
    aJson.Free;
  end;
end;

procedure TDeviceDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TDeviceDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TDeviceDataListJson.LoadFromJson(const aJsonString: string);
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
