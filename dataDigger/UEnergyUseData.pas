unit UEnergyUseData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // 小时用能
  TEnergyHourUseData = class
  private
    FDayHour: RDateTime;  // 日期
    FDosage: RDouble;     // 用量
    FTce: RDouble;        // 标煤
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

  // 日用能
  TEnergyDayUseData = class
  private
    FDay: RDateTime;      // 日期
    FDosage: RDouble;     // 用量
    FTce: RDouble;        // 标煤
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

  // 月用能
  TEnergyMonthUseData = class
  private
    FYear: RInteger;      // 年
    FMonth: RInteger;     // 月
    FDosage: RDouble;     // 用量
    FTce: RDouble;        // 标煤
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
