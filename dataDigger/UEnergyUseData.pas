unit UEnergyUseData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // Сʱ����
  TEnergyHourUseData = class
  private
    FDayHour: RDateTime;  // ����
    FDosage: RDouble;     // ����
    FTce: RDouble;        // ��ú
  public
    constructor Create;

    property dayHour: RDateTime read FDayHour write FDayHour;
    property dosage: RDouble read FDosage write FDosage;
    property tce: RDouble read FTce write FTce;
  end;

  TEnergyHourUseDataList = class(TObjectList<TEnergyHourUseData>)
  public
    function Add(): TEnergyHourUseData; overload;
  end;

  // ������
  TEnergyDayUseData = class
  private
    FDay: RDateTime;      // ����
    FDosage: RDouble;     // ����
    FTce: RDouble;        // ��ú
  public
    constructor Create;

    property day: RDateTime read FDay write FDay;
    property dosage: RDouble read FDosage write FDosage;
    property tce: RDouble read FTce write FTce;
  end;

  TEnergyDayUseDataList = class(TObjectList<TEnergyDayUseData>)
  public
    function Add(): TEnergyDayUseData; overload;
  end;

  // ������
  TEnergyMonthUseData = class
  private
    FYear: RInteger;      // ��
    FMonth: RInteger;     // ��
    FDosage: RDouble;     // ����
    FTce: RDouble;        // ��ú
  public
    constructor Create;

    property year: RInteger read FYear write FYear;
    property month: RInteger read FMonth write FMonth;
    property dosage: RDouble read FDosage write FDosage;
    property tce: RDouble read FTce write FTce;
  end;

  TEnergyMonthUseDataList = class(TObjectList<TEnergyMonthUseData>)
  public
    function Add(): TEnergyMonthUseData; overload;
  end;

implementation

{ TEnergyHourUseData }
constructor TEnergyHourUseData.Create;
begin
  FDayHour.Clear;
  FDosage.Clear;
  FTce.Clear;
end;

{ TEnergyHourUseDataList }
function TEnergyHourUseDataList.Add: TEnergyHourUseData;
begin
  Result := TEnergyHourUseData.Create;
  Self.Add(Result);
end;

{ TEnergyDayUseData }
constructor TEnergyDayUseData.Create;
begin
  FDay.Clear;
  FDosage.Clear;
  FTce.Clear;
end;

{ TEnergyDayUseDataList }
function TEnergyDayUseDataList.Add: TEnergyDayUseData;
begin
  Result := TEnergyDayUseData.Create;
  Self.Add(Result);
end;

{ TEnergyMonthUseData }
constructor TEnergyMonthUseData.Create;
begin
  FYear.Clear;
  FMonth.Clear;
  FDosage.Clear;
  FTce.Clear;
end;

{ TEnergyMonthUseDataList }
function TEnergyMonthUseDataList.Add: TEnergyMonthUseData;
begin
  Result := TEnergyMonthUseData.Create;
  Self.Add(Result);
end;

end.
