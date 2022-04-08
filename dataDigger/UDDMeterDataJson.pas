unit UDDMeterDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDMeterData;

type
  // 分类
  TMeterSortDataJson = class(TMeterSortData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TMeterSortDataListJson = class(TMeterSortDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

  // 计量点
  TMeterDataJson = class(TMeterData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TMeterDataListJson = class(TMeterDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TMeterSortDataJson }
function TMeterSortDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;

  Result.RI['sortId'] := SortId;
  Result.RI['parentId'] := ParentId;
  Result.RS['sortName'] := SortName;
end;

function TMeterSortDataJson.ToJsonStr: string;
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

function TMeterSortDataJson.AsStream: IPrStream;
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

procedure TMeterSortDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  SortId := aJson.RI['sortId'];
  ParentId := aJson.RI['parentId'];
  SortName := aJson.RS['sortName'];
end;

procedure TMeterSortDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TMeterSortDataListJson }
function TMeterSortDataListJson.AsJson: TJsonArray;
var
  aMeterSort: TMeterSortData;
begin
  Result := TJsonArray.Create;
  for aMeterSort in Self do
    Result.Add(TMeterSortDataJson(aMeterSort).AsJson);
end;

function TMeterSortDataListJson.AsStream: IPrStream;
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

procedure TMeterSortDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TMeterSortDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TMeterSortDataListJson.LoadFromJson(const aJsonString: string);
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

{ TMeterDataJson }
function TMeterDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;

  //Result.RI['meterId'] := MeterId;
  Result.RI['sortId'] := SortId;
  Result.RS['meterCode'] := MeterCode;
  Result.RS['meterName'] := MeterName;
  Result.RS['meterNote'] := MeterNote;
  Result.RI['meterVersion'] := MeterVersion;
  Result.RD['meterRate'] := MeterRate;
  Result.RI['energyTypeId'] := EnergyTypeId;
  Result.RS['energyTypeName'] := EnergyTypeName;
  Result.RI['payTypeId'] := PayTypeId;
  Result.RI['rechargeTypeId'] := RechargeTypeId;
  Result.RB['isFrmPrice'] := IsFrmPrice;
  //Result.RS['startTime'] := StartTime;
  //Result.RS['stopTime'] := StopTime;
  Result.RS['devId'] := DeviceId;
  Result.RS['meterValueCode'] := MeterValueCode;
  Result.RS['devModel'] := DeviceModel;
  Result.RS['devModelName'] := DeviceModelName;
  Result.RS['devFactoryNo'] := DeviceFactoryNo;
  Result.RS['devInstallAddr'] := DeviceInstallAddr;
  //Result.RS['deviceInstallDate'] := DeviceInstallDate;
  //Result.RS['gatewayDevId'] := GatewayDevId;
  //Result.RS['gatewayModel'] := GatewayModel;
  //Result.RS['gatewayInstallAddr'] := GatewayInstallAddr;
  Result.RB['onLine'] := onLine;
  Result.RT['lastDataTime'] := lastDataTime.FormatLongDateTime;
  Result.RD['lastMeterValue'] := lastMeterValue;
  Result.RD['todayOnLineRate'] := todayOnLineRate;

  if hourUse.AsString <> '' then
    Result.A['72Hour'].FromJSON(hourUse.AsString);
end;

function TMeterDataJson.ToJsonStr: string;
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

function TMeterDataJson.AsStream: IPrStream;
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

procedure TMeterDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  MeterId            := aJson.RI['meterId'];
  SortId             := aJson.RI['sortId'];
  MeterCode          := aJson.RS['meterCode'];
  MeterName          := aJson.RS['meterName'];
  MeterNote          := aJson.RS['meterNote'];
  MeterVersion       := aJson.RI['meterVersion'];
  MeterRate          := aJson.RD['meterRate'];
  EnergyTypeId       := aJson.RI['energyTypeId'];
  EnergyTypeName     := aJson.RS['energyTypeName'];
  PayTypeId          := aJson.RI['payTypeId'];
  RechargeTypeId     := aJson.RI['rechargeTypeId'];
  IsFrmPrice         := aJson.RB['isFrmPrice'];
  StartTime          := aJson.RS['startTime'];
  StopTime           := aJson.RS['stopTime'];
  DeviceId           := aJson.RS['devId'];
  MeterValueCode     := aJson.RS['meterValueCode'];
  DeviceModel        := aJson.RS['devModel'];
  DeviceModelName    := aJson.RS['devModelName'];
  DeviceFactoryNo    := aJson.RS['devFactoryNo'];
  DeviceInstallAddr  := aJson.RS['devInstallAddr'];
  DeviceInstallDate  := aJson.RS['devInstallDate'];
  GatewayDevId       := aJson.RS['gatewayDevId'];
  GatewayModel       := aJson.RS['gatewayModel'];
  GatewayInstallAddr := aJson.RS['gatewayInstallAddr'];
end;

procedure TMeterDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TMeterDataListJson }
function TMeterDataListJson.AsJson: TJsonArray;
var
  aMeterData: TMeterData;
begin
  Result := TJsonArray.Create;
  for aMeterData in Self do
    Result.Add(TMeterDataJson(aMeterData).AsJson);
end;

function TMeterDataListJson.AsStream: IPrStream;
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

procedure TMeterDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TMeterDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TMeterDataListJson.LoadFromJson(const aJsonString: string);
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
