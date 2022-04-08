unit UDDOffLineDeviceData;

interface

uses
  Generics.Collections, Generics.Defaults,
  puer.System, puer.Json.JsonDataObjects,
  UDDTopologyData, UDDDeviceData;

type
  TOffLineDeviceData = class(TDeviceData)
  private
    FgatewayId: RInteger;             // 网关 ID
    FgatewayDevId: RString;           // 网关 设备编号
    FgatewayName: RString;            // 网关 名称
    FgatewayIp: RString;              // 网关 IP
    FgatewayOnLine: RBoolean;         // 网关是否在线
    FgatewayModel: RString;           // 网关型号
    FgatewayTodayOnLineRate: RDouble; // 网关今日在线率
    FgatewayState: TDeviceState;      // 网关设备状态
    FgatewayVersion: RString;         // 网关软件版本
  public
    constructor Create;

    property gatewayId: RInteger read FgatewayId write FgatewayId;
    property gatewayDevId: RString read FgatewayDevId write FgatewayDevId;
    property gatewayName: RString read FgatewayName write FgatewayName;
    property gatewayIp: RString read FgatewayIp write FgatewayIp;
    property gatewayOnLine: RBoolean read FgatewayOnLine write FgatewayOnLine;
    property gatewayModel: RString read FgatewayModel write FgatewayModel;
    property gatewayTodayOnLineRate: RDouble read FgatewayTodayOnLineRate write FgatewayTodayOnLineRate;
    property gatewayState: TDeviceState read FgatewayState write FgatewayState;
    property gatewayVersion: RString read FgatewayVersion write FgatewayVersion;
    procedure Assign(const aDeviceData: TOffLineDeviceData); overload;
    procedure Assign(const aDeviceData: TDeviceData); overload;
    procedure UpdateData; override;
    procedure ParseData; override;
  end;

  TOffLineDeviceDataList = class(TObjectList<TOffLineDeviceData>)
  public
    function Add(): TOffLineDeviceData; overload;
    procedure SortDevList;
  end;

  TOffLineDeviceComparer = class(TComparer<TOffLineDeviceData>)
  public
    function Compare(const Left, Right: TOffLineDeviceData): Integer; override;
  end;

implementation

{ TOffLineDeviceData }
constructor TOffLineDeviceData.Create;
begin
  FgatewayId.Clear;
  FgatewayDevId.Clear;
  FgatewayName.Clear;
  FgatewayIp.Clear;
  FgatewayOnLine.Clear;
  FgatewayModel.Clear;
  FgatewayTodayOnLineRate.Clear;
  FgatewayVersion.Clear;
end;

procedure TOffLineDeviceData.Assign(const aDeviceData: TOffLineDeviceData);
begin
  if aDeviceData <> nil then
  begin
    Self.Assign(TTopologyData(aDeviceData));

    Self.lastRealTime := aDeviceData.lastRealTime;
    Self.realData := aDeviceData.realData;
    Self.masterValue := aDeviceData.masterValue;
    Self.gatewayId := aDeviceData.gatewayId;
    Self.gatewayDevId := aDeviceData.gatewayDevId;
    Self.gatewayName := aDeviceData.gatewayName;
    Self.gatewayIp := aDeviceData.gatewayIp;
    Self.gatewayModel := aDeviceData.gatewayModel;
    Self.gatewayTodayOnLineRate := aDeviceData.gatewayTodayOnLineRate;
    Self.gatewayState := aDeviceData.gatewayState;
    Self.gatewayVersion := aDeviceData.gatewayVersion;
  end;
end;

procedure TOffLineDeviceData.Assign(const aDeviceData: TDeviceData);
begin
  if aDeviceData <> nil then
  begin
    Self.Assign(TTopologyData(aDeviceData));

    Self.lastRealTime := aDeviceData.lastRealTime;
    Self.realData := aDeviceData.realData;
    Self.masterValue := aDeviceData.masterValue;
  end;
end;

procedure TOffLineDeviceData.ParseData;
var
  aDataJson: TJsonObject;
begin
  aDataJson := TJsonObject.Create;
  try
    aDataJson.FromJSON(data.AsString);

    gatewayId := aDataJson.RI['gatewayId'];
    gatewayDevId := aDataJson.RS['gatewayDevId'];
    gatewayName := aDataJson.RS['gatewayName'];
    gatewayIp := aDataJson.RS['gatewayIp'];
    lastRealTime := aDataJson.RS['lastRealTime'];
    masterValue := aDataJson.RS['masterValue'];
    gatewayOnLine := aDataJson.RB['gatewayOnLine'];
    gatewayModel := aDataJson.RS['gatewayModel'];
    gatewayTodayOnLineRate := aDataJson.RD['gatewayTodayOnLineRate'];
    if not aDataJson.RI['gatewayState'].IsNull then
      gatewayState := TDeviceState(aDataJson.RI['gatewayState'].Value);
    gatewayVersion := aDataJson.RS['gatewayVersion'];
  finally
    aDataJson.Free;
  end;
end;

procedure TOffLineDeviceData.UpdateData;
var
  aDataJson: TJsonObject;
begin
  aDataJson := TJsonObject.Create;
  try
    aDataJson.RS['lastRealTime'] := lastRealTime;
    aDataJson.RS['masterValue'] := masterValue;
    aDataJson.RI['gatewayId'] := gatewayId;
    aDataJson.RS['gatewayDevId'] := gatewayDevId;
    aDataJson.RS['gatewayName'] := gatewayName;
    aDataJson.RS['gatewayIp'] := gatewayIp;
    aDataJson.RB['gatewayOnLine'] := gatewayOnLine;
    aDataJson.RS['gatewayModel'] := gatewayModel;
    aDataJson.RD['gatewayTodayOnLineRate'] := gatewayTodayOnLineRate;
    aDataJson.RS['gatewayVersion'] := gatewayVersion;
    aDataJson.RI['gatewayState'].Value := Ord(gatewayState);

    data.Value := aDataJson.ToJSON(True);
  finally
    aDataJson.Free;
  end;
end;

{ TOffLineDeviceDataList }
function TOffLineDeviceDataList.Add(): TOffLineDeviceData;
begin
  Result := TOffLineDeviceData.Create;
  Self.Add(Result);
end;

procedure TOffLineDeviceDataList.SortDevList;
var
  aComparer: TOffLineDeviceComparer;
begin
  aComparer := TOffLineDeviceComparer.Create;
  try
    Self.Sort(aComparer);
  finally
    aComparer.Free;
  end;
end;

{ TOffLineDeviceComparer }
function TOffLineDeviceComparer.Compare(const Left, Right: TOffLineDeviceData): Integer;

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
  Result := CompareRString(Left.gatewayDevId, Right.gatewayDevId);
  if Result = 0 then
    Result := CompareRString(Left.devId, Right.devId);
end;

end.
