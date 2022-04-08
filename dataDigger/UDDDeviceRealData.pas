unit UDDDeviceRealData;

interface

uses
  puer.System,
  Generics.Collections;

type
  // 终端设备实时数据
  TDeviceRealData = class
  private
    FRealDateTime: RDateTime;  // 时间
    FRealData: RString;        // 实时数据报文
    FDataState: RInteger;      // 数据状态
  public
    constructor Create;

    property RealDateTime: RDateTime read FRealDateTime write FRealDateTime;
    property RealData: RString read FRealData write FRealData;
    property DataState: RInteger read FDataState write FDataState;
  end;

  TDeviceRealDataList = class(TObjectList<TDeviceRealData>)
  public
    function Add(): TDeviceRealData; overload;
  end;

  TRealDataInfo = record
    DevId: Int64;
    DevNo: string;
    RealTime: TDateTime;
    RealData: string;
    MasterValue: string;
    MeterValue: string;
    DataState: Integer;
  end;

implementation

{ TDeviceRealData }
constructor TDeviceRealData.Create;
begin
  FRealDateTime.Clear;
  FRealData.Clear;
end;

{ TDeviceRealDataList }
function TDeviceRealDataList.Add(): TDeviceRealData;
begin
  Result := TDeviceRealData.Create;
  Self.Add(Result);
end;

end.

