unit UDDHourValueData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // 表具小时示数
  THourValueData = class
  private
    FDate: TDate;      // 日期
    FHour: Integer;    // 小时
    FValue: Double;    // 最后示数
    FTime: TDateTime;  // 示数时间
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
