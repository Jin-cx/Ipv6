unit UDDTopologyCacheData;

interface

uses
  SysUtils, Generics.Collections,
  puer.System, puer.SyncObjs,
  UDDTopologyData, UDDBrokerData, UDDGatewayData, UDDDeviceData, UDDCommData;

type
  TGatewayCacheData = class;
  TDeviceCacheData  = class;

  // Broker缓存数据
  TBrokerCacheData = class(TBrokerData)
  private
    FLock_Sub: TPrRWLock;
    FGatewayList: TDictionary<string, TGatewayCacheData>;    // 网关列表

    FLock_OnLine: TPrRWLock;
    FOnLineGatewayList: TDictionary<string, TFromInfo>;     // 在线网关列表
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddOnLineGatewayInfo(const aFromInfo: TFromInfo);
    procedure DeleteOnLineGatewayInfo(const aDevId: string);
    function TryGetOnLineGatewayInfo(const aDevId: string;
                                     var aFromInfo: TFromInfo): Boolean;

    function TryGetGateway(const aGatewayDevId: string;
                           var aGatewayData: TGatewayCacheData): Boolean;




    procedure AddOnLineGateway(const aGatewayDevId: string);
    procedure RemoveOnLineGateway(const aGatewayDevId: string);

    function GetGatewayCommState(const aGatewayDevId: string): TCommState;

    procedure AddGateway(const aGatewayData: TGatewayCacheData);
    procedure RemoveGateway(const aGatewayData: TGatewayCacheData);
  end;

  // 通讯设备缓存数据
  TGatewayCacheData = class(TGatewayData)
  private
    FBroker: TBrokerCacheData; // 节点服务
    FLock_Sub: TPrRWLock;
    FDeviceList: TDictionary<string, TDeviceCacheData>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddDevice(const aDeviceData: TDeviceCacheData);
    procedure RemoveDevice(const aDeviceData: TDeviceCacheData); overload;
    procedure RemoveDevice(const aDeviceDevId: string); overload;
    function TryGetDevice(const aDevId: string;
                          var aDeviceData: TDeviceCacheData): Boolean;

    procedure RefreshState;

    procedure SetAllDeviceOffLine;

    property Broker: TBrokerCacheData read FBroker write FBroker;
  end;

  // 终端设备缓存数据
  TDeviceCacheData = class(TDeviceData)
  private
    FGateway: TGatewayCacheData; // 网关
  public
    property Gateway: TGatewayCacheData read FGateway write FGateway;
  end;

implementation

{ TBrokerCacheData }
constructor TBrokerCacheData.Create;
begin
  inherited;
  FLock_Sub := TPrRWLock.Create;
  FGatewayList := TDictionary<string, TGatewayCacheData>.Create;

  FLock_OnLine := TPrRWLock.Create;
  FOnLineGatewayList := TDictionary<string, TFromInfo>.Create;
end;

destructor TBrokerCacheData.Destroy;
begin
  FLock_Sub.BeginWrite;
  try
    FGatewayList.Free;
  finally
    FLock_Sub.EndWrite;
    FLock_Sub.Free;
  end;

  FLock_OnLine.BeginWrite;
  try
    FOnLineGatewayList.Free;
  finally
    FLock_OnLine.EndWrite;
    FLock_OnLine.Free;
  end;
  inherited;
end;

procedure TBrokerCacheData.AddOnLineGatewayInfo(const aFromInfo: TFromInfo);
begin
  FOnLineGatewayList.AddOrSetValue(UpperCase(aFromInfo._devid), aFromInfo);
end;

procedure TBrokerCacheData.DeleteOnLineGatewayInfo(const aDevId: string);
begin
  FOnLineGatewayList.Remove(UpperCase(aDevId));
end;

function TBrokerCacheData.TryGetGateway(const aGatewayDevId: string;
                                        var aGatewayData: TGatewayCacheData): Boolean;
begin
  Result := False;

  if aGatewayDevId = '' then
    Exit;

  FLock_Sub.BeginRead;
  try
    Result := FGatewayList.TryGetValue(UpperCase(aGatewayDevId), aGatewayData);
  finally
    FLock_Sub.EndRead;
  end;
end;

procedure TBrokerCacheData.AddOnLineGateway(const aGatewayDevId: string);
var
  aFrom: TFromInfo;
begin
  FLock_OnLine.BeginWrite;
  try
    aFrom._devid := aGatewayDevId;
    FOnLineGatewayList.AddOrSetValue(UpperCase(aGatewayDevId), aFrom);
  finally
    FLock_OnLine.EndWrite;
  end;
end;

procedure TBrokerCacheData.RemoveOnLineGateway(const aGatewayDevId: string);
begin
  FLock_OnLine.BeginWrite;
  try
    FOnLineGatewayList.Remove(UpperCase(aGatewayDevId));
  finally
    FLock_OnLine.EndWrite;
  end;
end;

function TBrokerCacheData.GetGatewayCommState(const aGatewayDevId: string): TCommState;
begin
  FLock_OnLine.BeginRead;
  try
    if FOnLineGatewayList.ContainsKey(UpperCase(aGatewayDevId)) then
      Result := csOnLine
    else
      Result := csOffLine;
  finally
    FLock_OnLine.EndRead;
  end;
end;

procedure TBrokerCacheData.AddGateway(const aGatewayData: TGatewayCacheData);
begin
  FLock_Sub.BeginWrite;
  try
    FGatewayList.AddOrSetValue(UpperCase(aGatewayData.devId.AsString), aGatewayData);
  finally
    FLock_Sub.EndWrite;
  end;
end;

procedure TBrokerCacheData.RemoveGateway(const aGatewayData: TGatewayCacheData);
begin
  FLock_Sub.BeginWrite;
  try
    FGatewayList.Remove(UpperCase(aGatewayData.devId.AsString));
  finally
    FLock_Sub.EndWrite;
  end;
end;

function TBrokerCacheData.TryGetOnLineGatewayInfo(const aDevId: string;
                                                  var aFromInfo: TFromInfo): Boolean;
begin
  if aDevId = '' then
  begin
    Result := False;
    Exit;
  end;

  FLock_OnLine.BeginRead;
  try
    Result := FOnLineGatewayList.TryGetValue(UpperCase(aDevId), aFromInfo);
  finally
    FLock_OnLine.EndRead;
  end;
end;

{ TGatewayCacheData }
constructor TGatewayCacheData.Create;
begin
  inherited;
  FLock_Sub := TPrRWLock.Create;
  FDeviceList := TDictionary<string, TDeviceCacheData>.Create;
end;

destructor TGatewayCacheData.Destroy;
begin
  FLock_Sub.BeginWrite;
  try
    FDeviceList.Free;
  finally
    FLock_Sub.EndWrite;
    FLock_Sub.Free;
  end;
  inherited;
end;

function TGatewayCacheData.TryGetDevice(const aDevId: string;
                                        var aDeviceData: TDeviceCacheData): Boolean;
begin
  Result := False;

  if aDevId = '' then
    Exit;

  Result := FDeviceList.TryGetValue(UpperCase(aDevId), aDeviceData);
end;

procedure TGatewayCacheData.RefreshState;
begin
  commState := Broker.GetGatewayCommState(devId.AsString);
  if devState <> dsUnIssue then
    devState := dsNormal;
end;

procedure TGatewayCacheData.SetAllDeviceOffLine;
var
  aDeviceData: TDeviceCacheData;
begin
  FLock_Sub.BeginRead;
  try
    for aDeviceData in FDeviceList.Values do
      aDeviceData.commState := csOffLine;
  finally
    FLock_Sub.EndRead;
  end;
end;

procedure TGatewayCacheData.AddDevice(const aDeviceData: TDeviceCacheData);
begin
  FLock_Sub.BeginWrite;
  try
    FDeviceList.AddOrSetValue(UpperCase(aDeviceData.devId.AsString), aDeviceData);
  finally
    FLock_Sub.EndWrite;
  end;
end;

procedure TGatewayCacheData.RemoveDevice(const aDeviceData: TDeviceCacheData);
begin
  RemoveDevice(aDeviceData.devId.AsString);
end;

procedure TGatewayCacheData.RemoveDevice(const aDeviceDevId: string);
begin
  FLock_Sub.BeginWrite;
  try
    FDeviceList.Remove(UpperCase(aDeviceDevId));
  finally
    FLock_Sub.EndWrite;
  end;
end;

end.
