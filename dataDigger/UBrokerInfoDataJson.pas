unit UBrokerInfoDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UBrokerInfoData;

type
  TBrokerInfoDataJson = class(TBrokerInfoData)
  public
    function AsJson: TJsonObject;
    function AsStream: IPrStream;
  end;

  TBrokerInfoDataListJson = class(TBrokerInfoDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
  end;

implementation

{ TBrokerInfoDataJson }
function TBrokerInfoDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;

  Result.RI['devId'] := devId;
  Result.RS['devName'] := devName;
  Result.RS['devNo'] := devNo;
  Result.RS['devModel'] := devModel;
  Result.RS['devModelName'] := devModelName;
  Result.RS['devFactoryNo'] := devFactoryNo;
  Result.RS['devInstallAddr'] := devInstallAddr;
  if lngLat.AsString <> '' then
    Result.A['lngLat'].FromJSON(lngLat.AsString);
  Result.RB['onLine'] := onLine;
  Result.RD['todayOnLineRate'] := todayOnLineRate;

  Result.O['gateways'].RI['totalCount'] := gatewayCount;
  Result.O['gateways'].RI['onLineCount'] := gatewayOnLineCount;
  Result.O['gateways'].I['offLineCount'] := Result.O['gateways'].I['totalCount'] - Result.O['gateways'].I['onLineCount'];
  Result.O['gateways'].RD['onLineRate'] := gatewayOnLineRate;
  Result.O['gateways'].RD['todayOnLineRate'] := gatewayTodayOnLineRate;

  Result.O['terminals'].RI['totalCount'] := terminalCount;
  Result.O['terminals'].RI['onLineCount'] := terminalOnLineCount;
  Result.O['terminals'].I['offLineCount'] := Result.O['terminals'].I['totalCount'] - Result.O['terminals'].I['onLineCount'];
  Result.O['terminals'].RD['onLineRate'] := terminalOnLineRate;
  Result.O['terminals'].RD['todayOnLineRate'] := terminalTodayOnLineRate;

  Result.S['restNote'] := 'ÒÔÏÂ¼æÈÝ×Ö¶Î';

  Result.O['devices'].RI['totalCount'] := terminalCount;
  Result.O['devices'].RI['onLineCount'] := terminalOnLineCount;
  Result.O['devices'].I['offLineCount'] := Result.O['devices'].I['totalCount'] - Result.O['devices'].I['onLineCount'];
  Result.O['devices'].RD['onLineRate'] := terminalOnLineRate;
  Result.O['devices'].RD['todayOnLineRate'] := terminalTodayOnLineRate;

  Result.RI['id'] := devId;
  Result.RS['name'] := devName;
  Result.RS['devId'] := devNo;
end;

function TBrokerInfoDataJson.AsStream: IPrStream;
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

{ TBrokerInfoDataListJson }
function TBrokerInfoDataListJson.AsJson: TJsonArray;
var
  aBrokerInfo: TBrokerInfoData;
begin
  Result := TJsonArray.Create;
  for aBrokerInfo in Self do
    Result.Add(TBrokerInfoDataJson(aBrokerInfo).AsJson);
end;

function TBrokerInfoDataListJson.AsStream: IPrStream;
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
