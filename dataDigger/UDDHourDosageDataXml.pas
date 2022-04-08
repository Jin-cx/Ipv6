unit UDDHourDosageDataXml;

interface

uses
  SysUtils, DateUtils,
  puer.System, puer.Json.JsonDataObjects, puer.TTS,
  UDDHourDosageData;

type
  THourDosageDataListXml = class(THourDosageDataList)
  public
    function AsXml: string;
  end;

implementation

{ THourDosageDataListXml }
function THourDosageDataListXml.AsXml: string;
var
  aXmlList: TPrXmlList;
  aXmlItem: TPrXmlItem;
  aHourData: THourDosageData;
  aDate: TDateTime;
begin
  Result := '';

  aXmlList := TPrXmlList.Create;
  try
    for aHourData in Self do
    begin
      aXmlItem := aXmlList.Add;
      aXmlItem.SetKeyValue('devId', aHourData.devId);
      aDate := IncHour(Trunc(aHourData.Date), aHourData.Hour - 1);
      aXmlItem.SetKeyValue('date', DateTimeToStr(aDate));
      aXmlItem.SetKeyValue('dataType', aHourData.DataType);
      aXmlItem.SetKeyValue('beginValue', aHourData.BeginValue);
      aXmlItem.SetKeyValue('beginTime', aHourData.BeginTime);
      aXmlItem.SetKeyValue('endValue', aHourData.EndValue);
      aXmlItem.SetKeyValue('endTime', aHourData.EndTime);
      aXmlItem.SetKeyValue('dosage', aHourData.Dosage);
      aXmlItem.SetKeyValue('dosage_Ten1', aHourData.dosage_Ten1);
      aXmlItem.SetKeyValue('dosage_Ten2', aHourData.dosage_Ten2);
      aXmlItem.SetKeyValue('dosage_Ten3', aHourData.dosage_Ten3);
      aXmlItem.SetKeyValue('dosage_Ten4', aHourData.dosage_Ten4);
      aXmlItem.SetKeyValue('dosage_Ten5', aHourData.dosage_Ten5);
      aXmlItem.SetKeyValue('dosage_Ten6', aHourData.dosage_Ten6);
      aXmlItem.SetKeyValue('isStatis', aHourData.isStatis);
    end;

    Result := aXmlList.XmlText;
  finally
    aXmlList.Free;
  end;
end;

end.
