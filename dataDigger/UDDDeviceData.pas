unit UDDDeviceData;

interface

uses
  Generics.Collections, Generics.Defaults,
  puer.System, puer.Json.JsonDataObjects,
  UDDTopologyData, UDDDeviceModelData, UDDMeterData;

type
  TRealData = class
  private
    FRealTime: RString;
    FRealData: RString;
    FMasterValue: RString;
    FMeterValue: RString;
    FDataState: RInteger;
  public
    constructor Create;

    property RealTime: RString read FRealTime write FRealTime;
    property RealData: RString read FRealData write FRealData;
    property MasterValue: RString read FMasterValue write FMasterValue;
    property MeterValue: RString read FMeterValue write FMeterValue;
    property DataState: RInteger read FDataState write FDataState;

    procedure Assign(const aRealData: TRealData);

    function AsJson: TJsonObject;
    function AsJsonStr: string;
    procedure LoadFrom(const aJson: TJsonObject); overload;
    procedure LoadFrom(const aJsonStr: string); overload;
  end;

  TDeviceData = class(TTopologyData)
  private
    FisMeter: RBoolean;     // 是计量表具
    FmeterCode: RString;    // 已绑计量Code
    FrealData: RString;     // 实时数据
    FlastRealTime: RString; // 最后实时数据上报时间
    FmasterValue: RString;  // 实时数据展示
    FmeterValue: RString;   // 实时数据(计量数据)

    FlastRealData: TRealData;      // 最后一次上报的数据
    FlastValidRealData: TRealData; // 最后一次上报的有效数据

    FdeviceModel: TDeviceModelData;
    FmeterList: TMeterDataList;
    //FmeterData: TMeterData;
  public
    constructor Create;
    destructor Destroy; override;

    property isMeter: RBoolean read FisMeter write FisMeter;
    property meterCode: RString read FmeterCode write FmeterCode;
    property realData: RString read FrealData write FrealData;
    property lastRealTime: RString read FlastRealTime write FlastRealTime;
    property masterValue: RString read FmasterValue write FmasterValue;
    property meterValue: RString read FmeterValue write FmeterValue;
    property deviceModel: TDeviceModelData read FdeviceModel write FdeviceModel;
    property meterList: TMeterDataList read FmeterList write FmeterList;
    property lastRealData: TRealData read FlastRealData write FlastRealData;
    property lastValidRealData: TRealData read FlastValidRealData write FlastValidRealData;
    //property meterData: TMeterData read FmeterData write FmeterData;
    procedure Assign(const aDeviceData: TDeviceData); overload;
    procedure UpdateData; override;
    procedure ParseData; override;
  end;

  TDeviceDataList = class(TObjectList<TDeviceData>)
  public
    function Add(): TDeviceData; overload;
    procedure SortByCommId;
    function IdArray: TArray<RInteger>;
  end;

  TDeviceComparer = class(TComparer<TDeviceData>)
  public
    function Compare(const Left, Right: TDeviceData): Integer; override;
  end;

implementation

{ TDeviceData }
constructor TDeviceData.Create;
begin
  inherited;
  Self.deviceType := dtDevice;
  FdeviceModel := TDeviceModelData.Create;
  FmeterList := TMeterDataList.Create;
  //FmeterData := TMeterData.Create;

  FlastRealData := TRealData.Create;
  FlastValidRealData := TRealData.Create;

  FisMeter.Clear;
  FmeterCode.Clear;
  FrealData.Clear;
  FlastRealTime.Clear;
  FmasterValue.Clear;
  FmeterValue.Clear;
end;

destructor TDeviceData.Destroy;
begin
  FdeviceModel.Free;
  FmeterList.Free;

  FlastRealData.Free;
  FlastValidRealData.Free;
  inherited;
end;

procedure TDeviceData.Assign(const aDeviceData: TDeviceData);
begin
  if aDeviceData <> nil then
  begin
    Self.Assign(TTopologyData(aDeviceData));

    Self.isMeter := aDeviceData.isMeter;
    Self.meterCode := aDeviceData.meterCode;
    Self.lastRealTime := aDeviceData.lastRealTime;
    Self.realData := aDeviceData.realData;
    Self.masterValue := aDeviceData.masterValue;
    Self.meterValue := aDeviceData.meterValue;

    FlastRealData.Assign(aDeviceData.lastRealData);
    FlastValidRealData.Assign(aDeviceData.lastValidRealData);
  end;
end;

procedure TDeviceData.ParseData;
var
  aDataJson: TJsonObject;
begin
  aDataJson := TJsonObject.Create;
  try
    aDataJson.FromJSON(data.AsString);

    isMeter := aDataJson.RB['isMeter'];
    meterCode := aDataJson.RS['meterCode'];
    lastRealTime := aDataJson.RS['lastRealTime'];
    masterValue := aDataJson.RS['masterValue'];
    meterValue := aDataJson.RS['meterValue'];

    lastRealData.LoadFrom(aDataJson.O['lastRealData']);
    lastValidRealData.LoadFrom(aDataJson.O['lastValidRealData']);
  finally
    aDataJson.Free;
  end;
end;

procedure TDeviceData.UpdateData;
var
  aDataJson: TJsonObject;
begin
  aDataJson := TJsonObject.Create;
  try
    aDataJson.RB['isMeter'] := isMeter;
    aDataJson.RS['meterCode'] := meterCode;
    aDataJson.RS['lastRealTime'] := lastRealTime;
    aDataJson.RS['masterValue'] := masterValue;
    aDataJson.RS['meterValue'] := meterValue;

    aDataJson.O['lastRealData'] := lastRealData.AsJson;
    aDataJson.O['lastValidRealData'] := lastValidRealData.AsJson;

    data.Value := aDataJson.ToJSON(True);
  finally
    aDataJson.Free;
  end;
end;

{ TDeviceDataList }
function TDeviceDataList.Add(): TDeviceData;
begin
  Result := TDeviceData.Create;
  Self.Add(Result);
end;

procedure TDeviceDataList.SortByCommId;
var
  aComparer: TDeviceComparer;
begin
  aComparer := TDeviceComparer.Create;
  try
    Self.Sort(aComparer);
  finally
    aComparer.Free;
  end;
end;

function TDeviceDataList.IdArray: TArray<RInteger>;
var
  aIdList: TList<RInteger>;
  aDevice: TDeviceData;
begin
  aIdList := TList<RInteger>.Create;
  try
    for aDevice in Self do
      aIdList.Add(aDevice.id);
    Result := aIdList.ToArray;
  finally
    aIdList.Free;
  end;
end;

{ TDeviceComparer }
function TDeviceComparer.Compare(const Left, Right: TDeviceData): Integer;

  function CompareRString(const aLeft, aRight: RString): Integer;
  begin
    if aLeft.AsString = aRight.AsString then
      Exit(0);

    if aLeft.AsString < aRight.AsString then
      Result := -1
    else
      Result := 1;
  end;

begin
  Result := 0;
  //Result := CompareRString(Left.port, Right.port);
  //if Result = 0 then
  //  Result := CompareRString(Left.commId, Right.commId);
end;

{ TRealData }
constructor TRealData.Create;
begin
  FRealTime.Clear;
  FRealData.Clear;
  FMasterValue.Clear;
  FMeterValue.Clear;
  FDataState.Clear;
end;

procedure TRealData.Assign(const aRealData: TRealData);
begin
  FRealTime := aRealData.RealTime;
  FRealData := aRealData.RealData;
  FMasterValue := aRealData.MasterValue;
  FMeterValue := aRealData.MeterValue;
  FDataState := aRealData.DataState;
end;

function TRealData.AsJson: TJsonObject;
var
  aJsonRealData: TJsonBaseObject;
begin
  Result := TJsonObject.Create;
  Result.RS['realTime'] := FRealTime;
  //Result.RS['realData'] := FRealData;
  Result.RS['masterValue'] := FMasterValue;
  Result.RS['meterValue'] := FMeterValue;
  Result.RI['dataState'] := FDataState;
  try
    aJsonRealData := TJsonBaseObject.Parse(FRealData.AsString);
    if aJsonRealData is TJsonArray then
      Result.A['realData'] := TJsonArray(aJsonRealData)
    else if aJsonRealData is TJsonObject then
      Result.O['realData'] := TJsonObject(aJsonRealData);
  except
    Result.O['realData'] := nil;
  end;
end;

function TRealData.AsJsonStr: string;
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

procedure TRealData.LoadFrom(const aJson: TJsonObject);
begin
  if aJson = nil then
    Exit;

  FRealTime := aJson.RS['realTime'];
  FRealData := aJson.RS['realData'];
  FMasterValue := aJson.RS['masterValue'];
  FMeterValue := aJson.RS['meterValue'];
  FDataState := aJson.RI['dataState'];
end;

procedure TRealData.LoadFrom(const aJsonStr: string);
var
  aJson: TJsonObject;
begin
  if aJsonStr = '' then
    Exit;

  aJson := TJsonObject.Create;
  try
    aJson.FromJSON(aJsonStr);
    LoadFrom(aJson);
  finally
    aJson.Free;
  end;
end;

end.
