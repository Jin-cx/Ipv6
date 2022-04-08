{
  单元: 拓扑结构数据单元
  作者: lynch
  日期: 2016-08-02
}

unit UDDTopologyDataJson;

interface

uses
  Windows, SysUtils,
  puer.System, puer.Json.JsonDataObjects,
  UDDTopologyData;

type
  // 设备基础信息
  TTopologyDataJson = class(TTopologyData)
  public
    function AsJson_DD: TJsonObject;
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TTopologyDataListJson = class(TTopologyDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
    //procedure LoadFromJson(const aJsonString: UTF8String); overload;
  end;

implementation

{ TTopologyDataJson }
function TTopologyDataJson.AsJson_DD: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RI['id'] := id;
  Result.RI['parentId'] := parentId;
  Result.RS['name'] := name;
  Result.RT['createTime'] := createTime;
  Result.RI['deviceType'] := RInteger.Parse(Ord(deviceType));
  Result.RS['devId'] := devId;
  if lngLat.AsString <> '' then
    Result.O['lngLat'].FromJSON(lngLat.AsString);
end;

function TTopologyDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.RI['id'] := id;
  Result.RI['parentId'] := parentId;
  Result.RS['name'] := name;
  Result.RS['note'] := note;
  Result.RT['createTime'] := createTime;
  Result.RI['deviceType'] := RInteger.Parse(Ord(deviceType));
  Result.RS['data'] := data;
  Result.RS['devModel'] := devModel;
  Result.RS['devModelName'] := devModelName;
  Result.RS['devId'] := devId;
  Result.RS['conn'] := conn;
  Result.RI['sortIndex'] := sortIndex;
  Result.RI['commState'] := RInteger.Parse(Ord(commState));
  Result.RI['devState'] := RInteger.Parse(Ord(devState));
  Result.RS['doubtInfo'] := doubtInfo;
  Result.RB['isTemp'] := isTemp;
  Result.RS['ip'] := ip;
  Result.RS['devFactoryNo'] := devFactoryNo;
  Result.RS['devInstallAddr'] := devInstallAddr;
  if lngLat.AsString <> '' then
    Result.A['lngLat'].FromJSON(lngLat.AsString);
  Result.B['onLine'] := commState = csOnLine;
  Result.RD['todayOnLineRate'] := todayOnLineRate;
  Result.RB['isReserve'] := isReserve;

  Result.RB['isDebug'] := isDebug;
  Result.RS['debugInfo'] := debugInfo;
end;

function TTopologyDataJson.ToJsonStr: string;
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

function TTopologyDataJson.AsStream: IPrStream;
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

procedure TTopologyDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  id := aJson.RI['id'];
  parentId := aJson.RI['parentId'];
  name := aJson.RS['name'];
  note := aJson.RS['note'];
  createTime := aJson.RT['createTime'];
  deviceType := TDeviceType(aJson.RI['deviceType'].Value);
  data := aJson.RS['data'];
  devModel := aJson.RS['devModel'];
  devModelName := aJson.RS['devModelName'];
  devId := aJson.RS['devId'];
  conn := aJson.RS['conn'];
  sortIndex := aJson.RI['sortIndex'];
  commState := TCommState(aJson.RI['commState'].Value);
  devState := TDeviceState(aJson.RI['devState'].Value);
  doubtInfo := aJson.RS['doubtInfo'];
  isTemp := aJson.RB['isTemp'];
  ip := aJson.RS['ip'];
  devFactoryNo := aJson.RS['devFactoryNo'];
  devInstallAddr := aJson.RS['devInstallAddr'];
  if deviceType = dtDD then
    lngLat.Value := aJson.O['lngLat'].ToJSON(True)
  else
    lngLat.Value := aJson.A['lngLat'].ToJSON(True);
  todayOnLineRate := aJson.RD['todayOnLineRate'];
  isReserve := aJson.RB['isReserve'];

  isDebug := aJson.RB['isDebug'];
  debugInfo := aJson.RS['debugInfo'];
end;

procedure TTopologyDataJson.LoadFromJsonStr(const aJsonStr: string);
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

{ TTopologyDataListJson }
function TTopologyDataListJson.AsJson: TJsonArray;
var
  aTopologyData: TTopologyData;
begin
  Result := TJsonArray.Create;
  for aTopologyData in Self do
    Result.Add(TTopologyDataJson(aTopologyData).AsJson);
end;

function TTopologyDataListJson.AsStream: IPrStream;
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

procedure TTopologyDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TTopologyDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TTopologyDataListJson.LoadFromJson(const aJsonString: string);
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

{procedure TTopologyDataListJson.LoadFromJson(const aJsonString: UTF8String);
var
  aJson: ISuperObject;
begin
  if aJsonString = '' then
    Exit;

  aJson := SO(aJsonString);
  try
    LoadFromJson(aJson);
  finally
    aJson := nil;
  end;
end;  }


end.
