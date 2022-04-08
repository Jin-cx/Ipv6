unit UDDGatewayData;

interface

uses
  Generics.Collections, Generics.Defaults,
  puer.System, puer.Json.JsonDataObjects,
  UDDTopologyData;

type
  TGatewayData = class(TTopologyData)
  private
    FrunState: RString;     // 运行状态
    Fversion: RString;      // 网关软件版本
    FlastRealTime: RString; // 最后上报时间
    FallTerminalCount: RInteger;     // 所有终端数量
    FonLineTerminalCount: RInteger;  // 在线终端数量
    FoffLineTerminalCount: RInteger; // 离线终端数量
    FdebugTerminalCount: RInteger;   // 维护终端数量
    FterminalOnLineRate: RDouble;    // 终端在线率
  public
    constructor Create;

    property runState: RString read FrunState write FrunState;
    property version: RString read Fversion write Fversion;
    property lastRealTime: RString read FlastRealTime write FlastRealTime;

    property allTerminalCount: RInteger read FallTerminalCount write FallTerminalCount;
    property onLineTerminalCount: RInteger read FonLineTerminalCount write FonLineTerminalCount;
    property offLineTerminalCount: RInteger read FoffLineTerminalCount write FoffLineTerminalCount;
    property debugTerminalCount: RInteger read FdebugTerminalCount write FdebugTerminalCount;
    property terminalOnLineRate: RDouble read FterminalOnLineRate write FterminalOnLineRate;

    procedure Assign(const aGatewayData: TGatewayData); overload;
    procedure UpdateData; override;
    procedure ParseData; override;
  end;

  TGatewayDataList = class(TObjectList<TGatewayData>)
  public
    function Add(): TGatewayData; overload;
    procedure SortBySortIndex;
  end;

  TGatewayComparer = class(TComparer<TGatewayData>)
  public
    function Compare(const Left, Right: TGatewayData): Integer; override;
  end;

implementation

{ TGatewayData }
constructor TGatewayData.Create;
begin
  inherited;
  Self.deviceType := dtGateway;
  Self.runState.Value := '';
end;

procedure TGatewayData.Assign(const aGatewayData: TGatewayData);
begin
  if aGatewayData <> nil then
  begin
    Self.Assign(TTopologyData(aGatewayData));

    Self.runState := aGatewayData.runState;
    Self.version := aGatewayData.version;
    Self.lastRealTime := aGatewayData.lastRealTime;

    Self.allTerminalCount := aGatewayData.allTerminalCount;
    Self.onLineTerminalCount := aGatewayData.onLineTerminalCount;
    Self.offLineTerminalCount := aGatewayData.offLineTerminalCount;
    Self.debugTerminalCount := aGatewayData.debugTerminalCount;
    Self.terminalOnLineRate := aGatewayData.terminalOnLineRate;
  end;
end;

procedure TGatewayData.ParseData;
var
  aDataJson: TJsonObject;
begin
  aDataJson := TJsonObject.Create;
  try
    aDataJson.FromJSON(data.AsString);

    runState := aDataJson.RS['runState'];
    version := aDataJson.RS['version'];
    lastRealTime := aDataJson.RS['lastRealTime'];

    allTerminalCount := aDataJson.RI['allTerminalCount'];
    onLineTerminalCount := aDataJson.RI['onLineTerminalCount'];
    offLineTerminalCount := aDataJson.RI['offLineTerminalCount'];
    debugTerminalCount := aDataJson.RI['debugTerminalCount'];
    terminalOnLineRate := aDataJson.RD['terminalOnLineRate'];
  finally
    aDataJson.Free;
  end;
end;

procedure TGatewayData.UpdateData;
var
  aDataJson: TJsonObject;
begin
  aDataJson := TJsonObject.Create;
  try
    aDataJson.RS['runState'] := runState;
    aDataJson.RS['version'] := version;
    aDataJson.RS['lastRealTime'] := lastRealTime;

    aDataJson.RI['allTerminalCount'] := allTerminalCount;
    aDataJson.RI['onLineTerminalCount'] := onLineTerminalCount;
    aDataJson.RI['offLineTerminalCount'] := offLineTerminalCount;
    aDataJson.RI['debugTerminalCount'] := debugTerminalCount;
    aDataJson.RD['terminalOnLineRate'] := terminalOnLineRate;

    data.Value := aDataJson.ToJSON(True);
  finally
    aDataJson.Free;
  end;
end;

{ TGatewayDataList }
function TGatewayDataList.Add(): TGatewayData;
begin
  Result := TGatewayData.Create;
  Self.Add(Result);
end;

procedure TGatewayDataList.SortBySortIndex;
var
  aComparer: TGatewayComparer;
begin
  aComparer := TGatewayComparer.Create;
  try
    Self.Sort(aComparer);
  finally
    aComparer.Free;
  end;
end;

{ TGatewayComparer }
function TGatewayComparer.Compare(const Left, Right: TGatewayData): Integer;

  function CompareRInteger(const aLeft, aRight: RInteger): Integer;
  var
    aLeftVal, aRightVal: Integer;
  begin
    if aLeft.IsNull then
      aLeftVal := -1
    else
      aLeftVal := aLeft.Value;

    if aRight.IsNull then
      aRightVal := -1
    else
      aRightVal := aRight.Value;

    Result := aLeftVal - aRightVal;
  end;

begin
  if Left.deviceType = Right.deviceType then
    Result := CompareRInteger(Left.sortIndex, Right.sortIndex)
  else
    Result := Ord(Left.deviceType) - Ord(Right.deviceType);
end;

end.
