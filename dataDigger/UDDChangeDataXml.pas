unit UDDChangeDataXml;

interface

uses
  puer.TTS,
  UDDChangeData;

type
 TMeterValueDataListXml = class(TMeterValueDataList)
  public
    function AsXmlStr: string;
  end;

implementation

{ TMeterValueDataListXml }
function TMeterValueDataListXml.AsXmlStr: string;
var
  aXmlList: TPrXmlList;
  aXmlItem: TPrXmlItem;
  aMeterValue: TMeterValueData;
begin
  Result := '';

  aXmlList := TPrXmlList.Create;
  try
    for aMeterValue in Self do
    begin
      aXmlItem := aXmlList.Add;
      aXmlItem.SetKeyValue('meterValueCode', aMeterValue.meterValueCode);
      aXmlItem.SetKeyValue('meterValue', aMeterValue.meterValue);
    end;

    Result := aXmlList.XmlText;
  finally
    aXmlList.Free;
  end;
end;

end.
