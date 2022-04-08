unit UDDHourValueData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // ���Сʱʾ��
  THourValueData = class
  private
    FDate: TDate;      // ����
    FHour: Integer;    // Сʱ
    FValue: Double;    // ���ʾ��
    FTime: TDateTime;  // ʾ��ʱ��
  public
    property Date: TDate read FDate write FDate;
    property Hour: Integer read FHour write FHour;
    property Value: Double read FValue write FValue;
    property Time: TDateTime read FTime write FTime;
  end;

  THourValueDataList = class(TObjectList<THourValueData>)
  public
    function Add(): THourValueData; overload;
  end;

implementation

{ THourValueDataList }
function THourValueDataList.Add(): THourValueData;
begin
  Result := THourValueData.Create;
  Self.Add(Result);
end;

end.
