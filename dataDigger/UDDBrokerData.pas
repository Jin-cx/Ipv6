unit UDDBrokerData;

interface

uses
  Generics.Collections, Generics.Defaults, Windows,
  puer.System, puer.Json.JsonDataObjects,
  UDDTopologyData;

type
  TBrokerData = class(TTopologyData)
  private
    FbrokerHost: RString;   // �����ַ
    FbrokerPort: RInteger;  // ����˿�
    FuseTLS: RBoolean;      // ʹ�� TLS
    FuserName: RString;     // ����Ա����
    Fpassword: RString;     // ����Ա����
    FhasGateway: RBoolean;  // �Դ�����

    FallGatewayCount: RInteger;        // ������������
    FonLineGatewayCount: RInteger;     // ������������
    FoffLineGatewayCount: RInteger;    // ������������
    FdebugGatewayCount: RInteger;      // ά����������
    FgatewayOnLineRate: RDouble;       // ����������

    FallTerminalCount: RInteger;       // �����ն�����
    FonLineTerminalCount: RInteger;    // �����ն�����
    FoffLineTerminalCount: RInteger;   // �����ն�����
    FdebugTerminalCount: RInteger;     // ά���ն�����
    FterminalOnLineRate: RDouble;      // �ն�������
  public
    constructor Create;

    property brokerHost: RString read FbrokerHost write FbrokerHost;
    property brokerPort: RInteger read FbrokerPort write FbrokerPort;
    property useTLS: RBoolean read FuseTLS write FuseTLS;
    property userName: RString read FuserName write FuserName;
    property password: RString read Fpassword write Fpassword;
    property hasGateway: RBoolean read FhasGateway write FhasGateway;

    property allGatewayCount: RInteger read FallGatewayCount write FallGatewayCount;
    property onLineGatewayCount: RInteger read FonLineGatewayCount write FonLineGatewayCount;
    property offLineGatewayCount: RInteger read FoffLineGatewayCount write FoffLineGatewayCount;
    property debugGatewayCount: RInteger read FdebugGatewayCount write FdebugGatewayCount;
    property gatewayOnLineRate: RDouble read FgatewayOnLineRate write FgatewayOnLineRate;

    property allTerminalCount: RInteger read FallTerminalCount write FallTerminalCount;
    property onLineTerminalCount: RInteger read FonLineTerminalCount write FonLineTerminalCount;
    property offLineTerminalCount: RInteger read FoffLineTerminalCount write FoffLineTerminalCount;
    property debugTerminalCount: RInteger read FdebugTerminalCount write FdebugTerminalCount;
    property terminalOnLineRate: RDouble read FterminalOnLineRate write FterminalOnLineRate;

    procedure Assign(const aBrokerData: TBrokerData); overload;
    procedure UpdateData; override;
    procedure ParseData; override;
  end;

  TBrokerDataList = class(TObjectList<TBrokerData>)
  public
    function Add(): TBrokerData; overload;
    procedure SortBySortIndex;
  end;

  TBrokerComparer = class(TComparer<TBrokerData>)
  public
    function Compare(const Left, Right: TBrokerData): Integer; override;
  end;

implementation

{ TBrokerData }
constructor TBrokerData.Create;
begin
  inherited;
  Self.deviceType := dtBroker;

  FbrokerHost.Clear;
  FbrokerPort.Clear;
  FuseTLS.Clear;
  FuserName.Clear;
  Fpassword.Clear;
  FhasGateway.Clear;
end;

procedure TBrokerData.Assign(const aBrokerData: TBrokerData);
begin
  if aBrokerData <> nil then
  begin
    Self.Assign(TTopologyData(aBrokerData));

    Self.brokerHost := aBrokerData.brokerHost;
    Self.brokerPort := aBrokerData.brokerPort;
    Self.useTLS := aBrokerData.useTLS;
    Self.userName := aBrokerData.userName;
    Self.password := aBrokerData.password;
    Self.hasGateway := aBrokerData.hasGateway;

    Self.allGatewayCount := aBrokerData.allGatewayCount;
    Self.onLineGatewayCount := aBrokerData.onLineGatewayCount;
    Self.offLineGatewayCount := aBrokerData.offLineGatewayCount;
    Self.debugGatewayCount := aBrokerData.debugGatewayCount;
    Self.gatewayOnLineRate := aBrokerData.gatewayOnLineRate;

    Self.allTerminalCount := aBrokerData.allTerminalCount;
    Self.onLineTerminalCount := aBrokerData.onLineTerminalCount;
    Self.offLineTerminalCount := aBrokerData.offLineTerminalCount;
    Self.debugTerminalCount := aBrokerData.debugTerminalCount;
    Self.terminalOnLineRate := aBrokerData.terminalOnLineRate;
  end;
end;

procedure TBrokerData.ParseData;
var
  aDataJson: TJsonObject;
begin
  aDataJson := TJsonObject.Create;
  try
    try
      aDataJson.FromJSON(data.AsString);

      brokerHost := aDataJson.RS['brokerHost'];
      brokerPort := aDataJson.RI['brokerPort'];
      useTLS := aDataJson.RB['useTLS'];
      userName := aDataJson.RS['userName'];
      password := aDataJson.RS['password'];
      hasGateway := aDataJson.RB['hasGateway'];

      allGatewayCount := aDataJson.RI['allGatewayCount'];
      onLineGatewayCount := aDataJson.RI['onLineGatewayCount'];
      offLineGatewayCount := aDataJson.RI['offLineGatewayCount'];
      debugGatewayCount := aDataJson.RI['debugGatewayCount'];
      gatewayOnLineRate := aDataJson.RD['gatewayOnLineRate'];

      allTerminalCount := aDataJson.RI['allTerminalCount'];
      onLineTerminalCount := aDataJson.RI['onLineTerminalCount'];
      offLineTerminalCount := aDataJson.RI['offLineTerminalCount'];
      debugTerminalCount := aDataJson.RI['debugTerminalCount'];
      terminalOnLineRate := aDataJson.RD['terminalOnLineRate'];
    except
      OutputDebugString(PChar('broker error:' + data.AsString));
    end;
  finally
    aDataJson.Free;
  end;
end;

procedure TBrokerData.UpdateData;
var
  aDataJson: TJsonObject;
begin
  aDataJson := TJsonObject.Create;
  try
    aDataJson.RS['brokerHost'] := brokerHost;
    aDataJson.RI['brokerPort'] := brokerPort;
    aDataJson.RB['useTLS'] := useTLS;
    aDataJson.RS['userName'] := userName;
    aDataJson.RS['password'] := password;
    aDataJson.RB['hasGateway'] := hasGateway;

    aDataJson.RI['allGatewayCount'] := allGatewayCount;
    aDataJson.RI['onLineGatewayCount'] := onLineGatewayCount;
    aDataJson.RI['offLineGatewayCount'] := offLineGatewayCount;
    aDataJson.RI['debugGatewayCount'] := debugGatewayCount;
    aDataJson.RD['gatewayOnLineRate'] := gatewayOnLineRate;

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

{ TBrokerDataList }
function TBrokerDataList.Add(): TBrokerData;
begin
  Result := TBrokerData.Create;
  Self.Add(Result);
end;

procedure TBrokerDataList.SortBySortIndex;
var
  aComparer: TBrokerComparer;
begin
  aComparer := TBrokerComparer.Create;
  try
    Self.Sort(aComparer);
  finally
    aComparer.Free;
  end;
end;

{ TBrokerComparer }
function TBrokerComparer.Compare(const Left, Right: TBrokerData): Integer;

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

