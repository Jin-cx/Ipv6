unit UDDDeviceDataXml;

interface

uses
  SysUtils, DateUtils,
  puer.System, puer.Json.JsonDataObjects, puer.TTS,
  UDDDeviceData;

type
  TDeviceDataListXml = class(TDeviceDataList)
  public
    function AsXml: string;
  end;

implementation

{ TDeviceDataListXml }
function TDeviceDataListXml.AsXml: string;
var
  aXmlList: TPrXmlList;
  aXmlItem: TPrXmlItem;
  aDevice: TDeviceData;
begin
  Result := '';

  aXmlList := TPrXmlList.Create;
  try
    for aDevice in Self do
    begin
      aXmlItem := aXmlList.Add;
      aXmlItem.SetKeyValue('devName', aDevice.name);
      aXmlItem.SetKeyValue('devNo', aDevice.devId);
      aXmlItem.SetKeyValue('devModel', aDevice.devModel);
      aXmlItem.SetKeyValue('conn', aDevice.conn);
    end;

    Result := aXmlList.XmlText;
  finally
    aXmlList.Free;
  end;
end;

end.
