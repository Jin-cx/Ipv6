unit UDDTopologyCache;

interface

uses
  Classes, SysUtils, Generics.Collections, Generics.Defaults, Windows,

  puer.System, puer.SyncObjs, puer.Json.JsonDataObjects,
  UDDDataInter, UDDCommInter, UDDLogInter, UDDModelsInter,
  UDDTopologyData, UDDCommData, UDDDeviceModelData,
  UDDBrokerData, UDDGatewayData, UDDDeviceData, UDDTopologyCacheData,
  UDDGatewayCtrl;

type
  // Topology �б�,״̬��������¼�
  TOnTopologyChanged = procedure(); stdcall;

  // ���˽ṹ�������
  TTopologyCacheCtrl = class
  public
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;
  end;

  // ���˽ṹ����
  TTopologyCache = class
  private
    FLock: TPrRWLock;

    FBrokerList: TDictionary<Int64, TBrokerCacheData>;
    FGatewayList: TDictionary<Int64, TGatewayCacheData>;
    FDeviceList: TDictionary<Int64, TDeviceCacheData>;

    FGatewayModelList: TStringList;

    FOnTopologyChanged: TFarProc;

    // ************* �� *************
    // �༭���˵���
    procedure BeginEditTopology;
    procedure EndEditTopology;
    // ��ȡ���˵���
    procedure BeginReadTopology;
    procedure EndReadTopology;

    procedure CreateCache;
    procedure FreeCache;
    procedure LoadCache;

    procedure InitModels;
    procedure FreeModels;

    procedure ClearBrokerList;
    procedure ClearGatewayList;
    procedure ClearDeviceList;


    //procedure doAddTopologyDataToCache(const aTopologyData: TTopologyData);

    procedure doChanged;

    function TryFindGateway(const aBrokerId: Int64;
                            const aGatewayDevId: string;
                            var aGatewayData: TGatewayCacheData): Boolean;

    function GetTmpGateway(const aBrokerId: Int64;
                           const aGatewayDevId: string;
                           const aTmpGateway: TGatewayCacheData): Boolean;

    function doTryGetBroker(const aBrokerId: RInteger;
                            var aBrokerData: TBrokerCacheData): Boolean;
    function doTryGetGateway(const aGatewayId: RInteger;
                             var aGatewayData: TGatewayCacheData): Boolean;

    function GetBroker(aBrokerId: RInteger): TBrokerCacheData;
    function GetGateway(aGatewayId: RInteger): TGatewayCacheData;
    function GetDevice(aDeviceId: RInteger): TDeviceCacheData;

    procedure doDeleteBroker(const aBrokerId: Int64;
                             const aTopologyIdList: TList<RInteger>);
    procedure doDeleteGateway(const aGatewayId: Int64;
                              const aTopologyIdList: TList<RInteger>);
    procedure doDeleteDevice(const aDeviceId: Int64;
                             const aTopologyIdList: TList<RInteger>);

    procedure doSetGatewayOnLine(const aBrokerId: Int64; const aFromInfo: TFromInfo);
    procedure doSetGatewayOffLine(const aBrokerId: Int64; const aGatewayDevId: string);


    procedure doClearDeviceOfGateway(const aGateway: TGatewayCacheData);
    procedure doUpdateDeviceNameFromOldDevice(const aGateway: TGatewayCacheData;
                                              const aNewDeviceList: TDeviceDataList);

    function doGetRealDeviceList(const aGateway: TGatewayCacheData;
                                 const aDeviceList: TDeviceDataList;
                                 var aFrom: TFromInfo;
                                 var aErrorInfo: string): Boolean;
    function doUpdateDevicesFromGateway(const aGatewayId: RInteger;
                                        var aErrorInfo: string): Boolean;
    function doIssueDevicesToGateway(const aGatewayId: RInteger;
                                     var aErrorInfo: string): Boolean;


    // �Ƚ�2���ն��豸�Ƿ���ͬ
    function DeviceEqual(const aDeviceA, aDeviceB: TDeviceData): Boolean;

    procedure doGetUpData(const aBrokerId: Int64;
                          const aCommDataInfo: TCommDataInfo);
    procedure doUpdateBrokerGatewayState(const aBrokerId: Int64;
                                         const aFrom: TFromInfo);

    procedure doSetCommEvents;
    procedure doCloseCommEvents;


    ////////////////////////////////////////////////////////////////////////////

    // ���ڵ����
    function doCheckTopologyExists(const aTopologyId: RInteger;
                                   const aDeviceType: TDeviceType): Boolean;
    // ȡ�ڵ��豸����
    function doGetTopologyDeviceType(const aTopologyId: RInteger;
                                     var aDeviceType: TDeviceType): Boolean;
    // ���ڵ����� (Add)
    function doCheckForAdd(const aTopologyData: TTopologyData;
                           var aErrorInfo: string): Boolean;

    // **************  Broker  **************
    procedure doAddBroker(const aTopologyData: TTopologyData);
    function doRegBroker(const aBrokerData: TBrokerCacheData;
                         var aErrorInfo: string): Boolean;
    procedure doUnRegBroker(const aBrokerId: Int64);

    // **************  Gateway  **************
    procedure doAddGateway(const aTopologyData: TTopologyData);

    // ����, �༭ ��, ˢ������״̬(����״̬���豸״̬)
    procedure doUpdateGatewayState(const aGatewayData: TGatewayCacheData);

    // ��������״̬Ϊ δ�·�
    procedure doSetGatewayUnIssue(const aGatewayData: TGatewayCacheData);


    // **************  Device  **************
    procedure doAddDevice(const aTopologyData: TTopologyData;
                          const aIsNew: Boolean = False);


    procedure doSortBrokers(const aTopologyIdList: TArray<RInteger>;
                            const aIdList: TList<RInteger>);
    procedure doSortGateways(const aBroker: TBrokerCacheData;
                             const aTopologyIdList: TArray<RInteger>;
                             const aIdList: TList<RInteger>);
    procedure doSortDevices(const aGateway: TGatewayCacheData;
                            const aTopologyIdList: TArray<RInteger>;
                            const aIdList: TList<RInteger>);
  public
    constructor Create;
    destructor Destroy; override;

    // ��ʼ������
    procedure InitCache;

    // �������˽ڵ� ͨѶ״̬
    procedure SetTopologyCommState(const aTopologyId: Int64;
                                   const aDeviceType: TDeviceType;
                                   const aCommState: TCommState); overload;
    procedure SetTopologyCommState(const aTopologyId: RInteger;
                                   const aDeviceType: TDeviceType;
                                   const aCommState: TCommState); overload;

    // ���� Topology �б�,״̬��������¼�
    procedure SetCallBack(const aOnTopologyChanged: TFarProc);

    procedure GetBrokerGatewayList(const aTopologyDataList: TTopologyDataList);

    // ��ȡ Topology �б�
    procedure GetTopologyList(const aTopologyDataList: TTopologyDataList);
    // ��ȡ Topology ����
    function GetTopologyInfo(const aTopologyId: RInteger;
                             const aTopologyData: TTopologyData;
                             var aErrorInfo: string): Boolean;

    // ��ȡ�����ͺ�
    function GetGatewayModel(const aGatewayId: RInteger; var aGatewayModel: string): Boolean;

    // ��� Topology
    function AddTopology(const aTopologyData: TTopologyData;
                         var aErrorInfo: string): Boolean;
    function AddBroker(const aTopologyData: TTopologyData;
                       var aErrorInfo: string): Boolean;
    function AddGateway(const aTopologyData: TTopologyData;
                        var aErrorInfo: string): Boolean;
    function AddDevice(const aTopologyData: TTopologyData;
                       var aErrorInfo: string): Boolean;

    // �༭ Topology
    function UpdateTopology(const aTopologyData: TTopologyData;
                            var aErrorInfo: string): Boolean;
    function UpdateBroker(const aTopologyData: TTopologyData;
                          var aErrorInfo: string): Boolean;
    function UpdateGateway(const aTopologyData: TTopologyData;
                           var aErrorInfo: string): Boolean;
    function UpdateDevice(const aTopologyData: TTopologyData;
                          var aErrorInfo: string): Boolean;

    // ɾ�� Topology
    function DeleteTopology(const aTopologyId: RInteger;
                            var aErrorInfo: string): Boolean;

    // ���� Topology
    function SortTopologys(const aParentTopologyId: RInteger;
                           const aTopologyIdList: TArray<RInteger>;
                           var aErrorInfo: string): Boolean;


    function GetConfigDeviceList(const aGatewayId: RInteger;
                                 var aRunState: RString;
                                 const aTopologyDataList: TTopologyDataList;
                                 var aErrorInfo: string): Boolean;
    function GetRealDeviceList(const aGatewayId: RInteger;
                               var aRunState: RString;
                               const aTopologyDataList: TTopologyDataList;
                               var aErrorInfo: string): Boolean;


    // ˢ�� Gateway ���豸�б�
    function UpdateDevicesFromGateway(const aGatewayId: RInteger;
                                      var aErrorInfo: string): Boolean;
    // �·� Gateway ���豸�б�
    function IssueDevicesToGateway(const aGatewayId: RInteger;
                                   var aErrorInfo: string): Boolean;
    // ��ȡ�ն��豸ʵʱ����
    function GetDeviceRealData(const aDeviceId: RInteger;
                               var aLastRealTime: RString;
                               var aRealData: RString;
                               var aErrorInfo: string): Boolean;

    // ���յ�����
    procedure ReceiveCommData(const aBrokerId: Int64; const aCommDataInfo: TCommDataInfo);

    // ͬ����������
    function SendDataSync(const aGatewayId: RInteger;
                          const aCmd: string;
                          const aData: string;
                          var aStatusCode: string;
                          var aResponseData: string;
                          var aErrorInfo: string): Boolean;

  public
    procedure GetTopoCountInfo(var aBrokerTotalCount: Integer;
                               var aBrokerOffLineCount: Integer;
                               var aGatewayTotalCount: Integer;
                               var aGatewayOffLineCount: Integer;
                               var aGatewayDoubtCount: Integer;
                               var aGatewayUnknowCount: Integer;
                               var aDeviceTotalCount: Integer;
                               var aDeviceOffLineCount: Integer;
                               var aDeviceAlarmCount: Integer);
  end;

// ************ ���˻���������� �ص��¼� ************
procedure OnSendEvent(const aCallbackId: Integer;
                      const aCommDataInfo: TCommDataInfo); stdcall;
procedure OnReceiveEvent(const aCallbackId: Integer;
                         const aCommDataInfo: TCommDataInfo); stdcall;
procedure OnConnectEvent(const aCallbackId: Integer); stdcall;
procedure OnDisconnectEvent(const aCallbackId: Integer); stdcall;

// ************ ����ӿ� ************

// ��ȡ Broker �� ���� ���豸�б�
procedure doGetBrokerGatewayList(const aTopologyDataList: TTopologyDataList); stdcall;

// ��ȡ Gateway ��ǰ�����ն��豸�б�
function doGetConfigDeviceList(const aGatewayId: RInteger;
                               var aRunState: RString;
                               const aTopologyDataList: TTopologyDataList;
                               var aErrorInfo: string): Boolean; stdcall;

// ��ȡ Gateway ��ǰ��ʵ�ն��豸�б�
function doGetRealDeviceList(const aGatewayId: RInteger;
                             var aRunState: RString;
                             const aTopologyDataList: TTopologyDataList;
                             var aErrorInfo: string): Boolean; stdcall;

// ���� Topology �б�,״̬��������¼�
procedure doSetCallBack(const aOnTopologyChanged: TFarProc); stdcall;
// ��ȡ Topology �б�
procedure doGetTopologyList(const aTopologyDataList: TTopologyDataList); stdcall;
// ��ȡ Topology ����
function doGetTopologyInfo(const aTopologyId: RInteger;
                           const aTopologyData: TTopologyData;
                           var aErrorInfo: string): Boolean; stdcall;
// ��� Topology
function doAddTopology(const aTopologyData: TTopologyData;
                       var aErrorInfo: string): Boolean; stdcall;
// �༭ Topology
function doUpdateTopology(const aTopologyData: TTopologyData;
                          var aErrorInfo: string): Boolean; stdcall;
// ɾ�� Topology
function doDeleteTopology(const aTopologyId: RInteger;
                          var aErrorInfo: string): Boolean; stdcall;
// ���� Topology
function doSortTopologys(const aParentTopologyId: RInteger;
                         const aTopologyIdList: TArray<RInteger>;
                         var aErrorInfo: string): Boolean; stdcall;
// ˢ�� Gateway ���豸�б�
function doUpdateDevicesFromGateway(const aGatewayId: RInteger;
                                    var aErrorInfo: string): Boolean; stdcall;
// �·� Gateway ���豸�б�
function doIssueDevicesToGateway(const aGatewayId: RInteger;
                                 var aErrorInfo: string): Boolean; stdcall;

// ��ȡ ͨѶ�豸 �ͺ��б�
procedure doGetGatewayModelList(const aModelList: TStringList); stdcall;

// ��ȡ���ص��豸�ͺ��б�
procedure doGetDeviceModelList(const aGatewayId: RInteger;
                               const aDevModelList: TDeviceModelDataList); stdcall;

// ��ȡ�ն��豸ʵʱ����
function doGetDeviceRealData(const aDeviceId: RInteger;
                             var aLastRealTime: RString;
                             var aRealData: RString;
                             var aErrorInfo: string): Boolean; stdcall;

// ͬ����������
function doSendDataSync(const aGatewayId: RInteger;
                        const aCmd: string;
                        const aData: string;
                        var aStatusCode: string;
                        var aResponseData: string;
                        var aErrorInfo: string): Boolean; stdcall;

// ��ȡ����������Ϣ
function doGetTopoCountInfo(var aBrokerTotalCount: Integer;
                            var aBrokerOffLineCount: Integer;
                            var aGatewayTotalCount: Integer;
                            var aGatewayOffLineCount: Integer;
                            var aGatewayDoubtCount: Integer;
                            var aGatewayUnknowCount: Integer;
                            var aDeviceTotalCount: Integer;
                            var aDeviceOffLineCount: Integer;
                            var aDeviceAlarmCount: Integer;
                            var aErrorInfo: string): Boolean; stdcall;

exports
  doGetBrokerGatewayList,
  doGetConfigDeviceList,
  doGetRealDeviceList,

  doSetCallBack,
  doGetTopologyList,
  doGetTopologyInfo,
  doAddTopology,
  doUpdateTopology,
  doDeleteTopology,
  doSortTopologys,
  doUpdateDevicesFromGateway,
  doIssueDevicesToGateway,
  doGetGatewayModelList,
  doGetDeviceModelList,
  doGetDeviceRealData,
  doSendDataSync,

  doGetTopoCountInfo;
  //doGetChildDeviceTypeList,


implementation

var
  _TopologyCache: TTopologyCache;

const
  ERROR_TOPOLOGY_NOT_EXISTS = 'ָ�����豸�����ڣ�';

procedure doSetCallBack(const aOnTopologyChanged: TFarProc);
begin
  _TopologyCache.SetCallBack(aOnTopologyChanged);
end;

function doGetConfigDeviceList(const aGatewayId: RInteger;
                               var aRunState: RString;
                               const aTopologyDataList: TTopologyDataList;
                               var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.GetConfigDeviceList(aGatewayId, aRunState, aTopologyDataList, aErrorInfo);
end;

function doGetRealDeviceList(const aGatewayId: RInteger;
                             var aRunState: RString;
                             const aTopologyDataList: TTopologyDataList;
                             var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.GetRealDeviceList(aGatewayId, aRunState, aTopologyDataList, aErrorInfo);
end;

procedure doGetBrokerGatewayList(const aTopologyDataList: TTopologyDataList);
begin
  _TopologyCache.GetBrokerGatewayList(aTopologyDataList);
end;

procedure doGetTopologyList(const aTopologyDataList: TTopologyDataList);
begin
  _TopologyCache.GetTopologyList(aTopologyDataList);
end;

function doGetTopologyInfo(const aTopologyId: RInteger;
                           const aTopologyData: TTopologyData;
                           var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.GetTopologyInfo(aTopologyId,
                                           aTopologyData,
                                           aErrorInfo);
end;

function doAddTopology(const aTopologyData: TTopologyData;
                       var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.AddTopology(aTopologyData, aErrorInfo);
end;

function doUpdateTopology(const aTopologyData: TTopologyData;
                          var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.UpdateTopology(aTopologyData, aErrorInfo);
end;

function doDeleteTopology(const aTopologyId: RInteger;
                          var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.DeleteTopology(aTopologyId, aErrorInfo);
end;

function doSortTopologys(const aParentTopologyId: RInteger;
                         const aTopologyIdList: TArray<RInteger>;
                         var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.SortTopologys(aParentTopologyId,
                                         aTopologyIdList,
                                         aErrorInfo);
end;

function doUpdateDevicesFromGateway(const aGatewayId: RInteger;
                                    var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.UpdateDevicesFromGateway(aGatewayId, aErrorInfo);
end;

function doIssueDevicesToGateway(const aGatewayId: RInteger;
                                 var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.IssueDevicesToGateway(aGatewayId, aErrorInfo);
end;

procedure doGetGatewayModelList(const aModelList: TStringList);
begin
  _DDModelsInter._doGetGatewayModelList(aModelList);
end;

procedure doGetDeviceModelList(const aGatewayId: RInteger;
                               const aDevModelList: TDeviceModelDataList);
var
  aGatewayModel: string;
begin
  if _TopologyCache.GetGatewayModel(aGatewayId, aGatewayModel) then
    _DDModelsInter._doGetDeviceModelList(aGatewayModel, aDevModelList);
end;

function doGetDeviceRealData(const aDeviceId: RInteger;
                             var aLastRealTime: RString;
                             var aRealData: RString;
                             var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.GetDeviceRealData(aDeviceId, aLastRealTime, aRealData, aErrorInfo);
end;

function doSendDataSync(const aGatewayId: RInteger;
                        const aCmd: string;
                        const aData: string;
                        var aStatusCode: string;
                        var aResponseData: string;
                        var aErrorInfo: string): Boolean;
begin
  Result := _TopologyCache.SendDataSync(aGatewayId, aCmd, aData, aStatusCode, aResponseData, aErrorInfo);
end;

function doGetTopoCountInfo(var aBrokerTotalCount: Integer;
                            var aBrokerOffLineCount: Integer;
                            var aGatewayTotalCount: Integer;
                            var aGatewayOffLineCount: Integer;
                            var aGatewayDoubtCount: Integer;
                            var aGatewayUnknowCount: Integer;
                            var aDeviceTotalCount: Integer;
                            var aDeviceOffLineCount: Integer;
                            var aDeviceAlarmCount: Integer;
                            var aErrorInfo: string): Boolean;
begin
  Result := _TopoCountCache.GetTopoCountInfo(aBrokerTotalCount,
                                             aBrokerOffLineCount,
                                             aGatewayTotalCount,
                                             aGatewayOffLineCount,
                                             aGatewayDoubtCount,
                                             aGatewayUnknowCount,
                                             aDeviceTotalCount,
                                             aDeviceOffLineCount,
                                             aDeviceAlarmCount,
                                             aErrorInfo);
end;

{ TTopologyCacheCtrl }
class procedure TTopologyCacheCtrl.Open;
begin
  _TopologyCache := TTopologyCache.Create;
  _TopologyCache.InitCache;
end;

class procedure TTopologyCacheCtrl.Close;
begin
  _TopologyCache.Free;
end;

class function TTopologyCacheCtrl.Active: Boolean;
begin
  Result := _TopologyCache <> nil;
end;

// �ص��¼�
procedure OnSendEvent(const aCallbackId: Integer;
                      const aCommDataInfo: TCommDataInfo);
begin

end;

procedure OnReceiveEvent(const aCallbackId: Integer;
                         const aCommDataInfo: TCommDataInfo);
var
  aError: string;
begin
  try
    //OutputDebugString(PChar(Format('[rev] %s: %s', [aCommDataInfo.From._devid, aCommDataInfo.Cmd])));
    UPrMsgInter.SendMsg2(aCommDataInfo.CommStr, 'system', 'dataDiggerDebug', '', aError);
    _TopologyCache.ReceiveCommData(aCallbackId, aCommDataInfo);
  except
    OutputDebugString(PChar(Format('_TopologyCache.ReceiveCommData ������ %s', [''])));
  end;
end;

procedure OnConnectEvent(const aCallbackId: Integer);
begin
  _TopologyCache.SetTopologyCommState(aCallbackId, dtBroker, csOnLine);
end;

procedure OnDisconnectEvent(const aCallbackId: Integer);
begin
  _TopologyCache.SetTopologyCommState(aCallbackId, dtBroker, csOffLine);
end;

{ TTopologyCache }
constructor TTopologyCache.Create;
begin
  inherited;
  CreateCache;
  InitModels;
  FLock := TPrRWLock.Create;
  doSetCommEvents;
end;

destructor TTopologyCache.Destroy;
begin
  doCloseCommEvents;
  FreeCache;
  FreeModels;
  FLock.Free;
  inherited;
end;

procedure TTopologyCache.InitCache;
begin
  FLock.BeginWrite;
  try
    LoadCache;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.SetTopologyCommState(const aTopologyId: Int64;
                                              const aDeviceType: TDeviceType;
                                              const aCommState: TCommState);
var
  aBrokerData: TBrokerCacheData;
  aGatewayData: TGatewayCacheData;
  aDeviceData: TDeviceCacheData;
  aHasChanged: Boolean;
begin
  aHasChanged := False;

  FLock.BeginWrite;
  try
    case aDeviceType of
      dtBroker:
        begin
          if FBrokerList.TryGetValue(aTopologyId, aBrokerData) then
          begin
            if aBrokerData.commState <> aCommState then
            begin
              aBrokerData.commState := aCommState;
              aHasChanged := True;
            end;
          end;
        end;
      dtGateway:
        begin
          if FGatewayList.TryGetValue(aTopologyId, aGatewayData) then
          begin
            if aGatewayData.commState <> aCommState then
            begin
              aGatewayData.commState := aCommState;
              aHasChanged := True;
            end;
          end;
        end;
      dtDevice:
        begin
          if FDeviceList.TryGetValue(aTopologyId, aDeviceData) then
          begin
            if aDeviceData.commState <> aCommState then
            begin
              aDeviceData.commState := aCommState;
              aHasChanged := True;
            end;
          end;
        end;
    end;
  finally
    FLock.EndWrite;
  end;

  if aHasChanged then
  begin
    doChanged;
    _TopoCountCache.SetNeedUpdate;
  end;
end;

procedure TTopologyCache.SetTopologyCommState(const aTopologyId: RInteger;
                                              const aDeviceType: TDeviceType;
                                              const aCommState: TCommState);
begin
  if aTopologyId.IsNull then
    Exit;

  SetTopologyCommState(aTopologyId.Value, aDeviceType, aCommState);
end;

procedure TTopologyCache.doChanged;
var
  aError: string;
begin
  if Assigned(FOnTopologyChanged) then
    TOnTopologyChanged(FOnTopologyChanged);
  UPrMsgInter.SendMsg2('topoChanged', 'system', 'dataDiggerTopo', '', aError);
end;

function TTopologyCache.TryFindGateway(const aBrokerId: Int64;
                                       const aGatewayDevId: string;
                                       var aGatewayData: TGatewayCacheData): Boolean;
var
  aTmpGatewayData: TGatewayCacheData;
begin
  Result := False;

  for aTmpGatewayData in FGatewayList.Values do
  begin
    if (aTmpGatewayData.parentId.Value = aBrokerId) and
       SameText(aTmpGatewayData.devId.AsString, aGatewayDevId) then
    begin
      aGatewayData := aTmpGatewayData;
      Exit(True);
    end;
  end;
end;

function TTopologyCache.GetTmpGateway(const aBrokerId: Int64;
                                      const aGatewayDevId: string;
                                      const aTmpGateway: TGatewayCacheData): Boolean;
var
  aBrokerData: TBrokerCacheData;
  aGatewayData: TGatewayCacheData;
begin
  Result := False;

  BeginReadTopology;
  try
    if FBrokerList.TryGetValue(aBrokerId, aBrokerData) and
       aBrokerData.TryGetGatewayInfo(aGatewayDevId, aGatewayData) then
    begin
      aTmpGateway.Assign(aGatewayData);
      Exit(True);
    end;
  finally
    EndReadTopology;
  end;
end;

function TTopologyCache.GetBroker(aBrokerId: RInteger): TBrokerCacheData;
var
  aBroker: TBrokerCacheData;
begin
  Result := nil;

  if aBrokerId.IsNull then
    Exit;

  if FBrokerList.TryGetValue(aBrokerId.Value, aBroker) then
    Result := aBroker;
end;

function TTopologyCache.doTryGetBroker(const aBrokerId: RInteger;
                                       var aBrokerData: TBrokerCacheData): Boolean;
begin
  Result := False;

  if aBrokerId.IsNull then
    Exit;

  Result := FBrokerList.TryGetValue(aBrokerId.Value, aBrokerData);
end;

function TTopologyCache.doTryGetGateway(const aGatewayId: RInteger;
                                        var aGatewayData: TGatewayCacheData): Boolean;
begin
  Result := False;

  if aGatewayId.IsNull then
    Exit;

  Result := FGatewayList.TryGetValue(aGatewayId.Value, aGatewayData);
end;

function TTopologyCache.GetGateway(aGatewayId: RInteger): TGatewayCacheData;
var
  aGateway: TGatewayCacheData;
begin
  Result := nil;

  if aGatewayId.IsNull then
    Exit;

  if FGatewayList.TryGetValue(aGatewayId.Value, aGateway) then
    Result := aGateway;
end;

function TTopologyCache.GetDevice(aDeviceId: RInteger): TDeviceCacheData;
var
  aDevice: TDeviceCacheData;
begin
  Result := nil;

  if aDeviceId.IsNull then
    Exit;

  if FDeviceList.TryGetValue(aDeviceId.Value, aDevice) then
    Result := aDevice;
end;

procedure TTopologyCache.doDeleteBroker(const aBrokerId: Int64;
                                        const aTopologyIdList: TList<RInteger>);
var
  aBrokerData: TBrokerCacheData;
  aGatewayData: TGatewayCacheData;
begin
  if FBrokerList.TryGetValue(aBrokerId, aBrokerData) then
    FBrokerList.Remove(aBrokerId)
  else
    Exit;

  aTopologyIdList.Add(aBrokerData.id);

  for aGatewayData in aBrokerData.GatewayList.Values do
    doDeleteGateway(aGatewayData.id.Value, aTopologyIdList);

  aBrokerData.Free;
  doUnRegBroker(aBrokerId);
end;

procedure TTopologyCache.doDeleteGateway(const aGatewayId: Int64;
                                         const aTopologyIdList: TList<RInteger>);
var
  aGatewayData: TGatewayCacheData;
  aDeviceData: TDeviceCacheData;
begin
  if FGatewayList.TryGetValue(aGatewayId, aGatewayData) then
    FGatewayList.Remove(aGatewayId)
  else
    Exit;

  aTopologyIdList.Add(aGatewayData.id);
  for aDeviceData in aGatewayData.DeviceList.Values do
  begin
    aTopologyIdList.Add(aDeviceData.id);

    FDeviceList.Remove(aDeviceData.id.Value);
    aDeviceData.Free;
  end;

  aGatewayData.Free;
end;

procedure TTopologyCache.doDeleteDevice(const aDeviceId: Int64;
                                        const aTopologyIdList: TList<RInteger>);
var
  aDeviceData: TDeviceCacheData;
begin
  if FDeviceList.TryGetValue(aDeviceId, aDeviceData) then
    FDeviceList.Remove(aDeviceId)
  else
    Exit;

  aTopologyIdList.Add(aDeviceData.id);

  aDeviceData.Gateway.DeviceList.Remove(aDeviceData.id.Value);
  doSetGatewayUnIssue(aDeviceData.Gateway);
  aDeviceData.Free;
end;

//  aBrokerId: Int64;
//  aReceiveDevId: string;
//  aCmd: string;
//  aData: string;
//  aStatusCode: string;
//  aResponseData: string;
//
//  begin
//    aBrokerId := aDeviceData.Gateway.Broker.id.Value;
//    aReceiveDevId := aDeviceData.Gateway.devId.AsString;
//    aCmd := 'manager/dev/delete.do';
//    aData := Format('{"_commid": "%s","_port": "%s"}', [aDeviceData.commId.AsString, aDeviceData.port.AsString]);
//
//    if not _DDCommInter._SendRequestDataSync(aBrokerId,
//                                             aReceiveDevId,
//                                             aCmd,
//                                             aData,
//                                             aStatusCode,
//                                             aResponseData,
//                                             aErrorInfo) then
//      Exit;
//
//    if aStatusCode = '0' then
//    begin
//      aDeviceData.Free;
//      FDeviceList.Remove(aDeviceId);
//
//      Result := True;
//    end
//    else
//      aErrorInfo := Format('������: %s', [aStatusCode]);
//  end;

procedure TTopologyCache.SetCallBack(const aOnTopologyChanged: TFarProc);
begin
  FLock.BeginWrite;
  try
    FOnTopologyChanged := aOnTopologyChanged;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.CreateCache;
begin
  FBrokerList := TDictionary<Int64, TBrokerCacheData>.Create;
  FGatewayList := TDictionary<Int64, TGatewayCacheData>.Create;
  FDeviceList := TDictionary<Int64, TDeviceCacheData>.Create;
end;

procedure TTopologyCache.InitModels;
begin
  FGatewayModelList := TStringList.Create;
end;

procedure TTopologyCache.BeginEditTopology;
begin
  FLock.BeginWrite;
end;

procedure TTopologyCache.EndEditTopology;
begin
  FLock.EndWrite;
end;

procedure TTopologyCache.BeginReadTopology;
begin
  FLock.BeginRead;
end;

procedure TTopologyCache.EndReadTopology;
begin
  FLock.EndRead;
end;

procedure TTopologyCache.FreeModels;
begin
  if FGatewayModelList <> nil then
    FGatewayModelList.Free;
end;

procedure TTopologyCache.FreeCache;
begin
  if FBrokerList <> nil then
  begin
    ClearBrokerList;
    FBrokerList.Free;
  end;
  if FGatewayList <> nil then
  begin
    ClearGatewayList;
    FGatewayList.Free;
  end;
  if FDeviceList <> nil then
  begin
    ClearDeviceList;
    FDeviceList.Free;
  end;
end;

procedure TTopologyCache.LoadCache;
var
  aTopologyDataList: TTopologyDataList;
  aTopologyData: TTopologyData;
begin
  aTopologyDataList := TTopologyDataList.Create;
  try
    _DDDataInter._doGetTopologyList(aTopologyDataList);
    for aTopologyData in aTopologyDataList do
    begin
      case aTopologyData.deviceType of
        dtBroker:  doAddBroker(aTopologyData);
        dtGateway: doAddGateway(aTopologyData);
        dtDevice:  doAddDevice(aTopologyData);
      end;
    end;
  finally
    aTopologyDataList.Free;
  end;
end;

procedure TTopologyCache.ClearBrokerList;
var
  aBrokerData: TBrokerData;
begin
  for aBrokerData in FBrokerList.Values do
  begin
    // ��ж�� MQTT ����
    OutputDebugString('��ʼ�ͷ� Broker');
    _DDCommInter._UnRegBroker(aBrokerData.id.Value);
    OutputDebugString('�ͷ� Broker ���');
    aBrokerData.Free;
  end;
end;

procedure TTopologyCache.ClearGatewayList;
var
  aGatewayData: TGatewayData;
begin
  for aGatewayData in FGatewayList.Values do
    aGatewayData.Free;
end;

procedure TTopologyCache.ClearDeviceList;
var
  aDeviceData: TDeviceData;
begin
  for aDeviceData in FDeviceList.Values do
    aDeviceData.Free;
end;
{
procedure TTopologyCache.doAddTopologyDataToCache(const aTopologyData: TTopologyData);
var
  aBrokerData: TBrokerCacheData;
  aGatewayData: TGatewayCacheData;
  aDeviceData: TDeviceCacheData;
begin
  case aTopologyData.deviceType of
    // Broker ����
    dtBroker:
      begin
        aBrokerData := TBrokerCacheData.Create;
        aBrokerData.Assign(aTopologyData);
        aBrokerData.commState := csOffLine;
        FBrokerList.AddOrSetValue(aBrokerData.id.Value, aBrokerData);

        doAddMQTTSvr(aBrokerData);
      end;
    // ͨѶ�豸
    dtGateway:
      begin
        aGatewayData := TGatewayCacheData.Create;
        aGatewayData.Assign(aTopologyData);
        aGatewayData.Broker := GetBroker(aGatewayData.parentId);


        //if aGatewayData.devState = dsNone then
        //  aGatewayData.devState := dsOffLine;

        FGatewayList.AddOrSetValue(aGatewayData.id.Value, aGatewayData);

        aGatewayData.Broker.GatewayList.AddOrSetValue(aGatewayData.devId.AsString, aGatewayData);
      end;
    // �ն��豸
    dtDevice:
      begin
        aDeviceData := TDeviceCacheData.Create;
        aDeviceData.Assign(aTopologyData);
        aDeviceData.Gateway := GetGateway(aDeviceData.parentId);
        aDeviceData.commState := csOffLine;

        FDeviceList.AddOrSetValue(aDeviceData.id.Value, aDeviceData);

        aDeviceData.Gateway.DeviceList.AddOrSetValue(aDeviceData.devId.AsString, aDeviceData);
      end;
  end;
end; }

procedure TTopologyCache.GetBrokerGatewayList(const aTopologyDataList: TTopologyDataList);
var
  aBrokerData: TBrokerData;
  aGatewayData: TGatewayData;
begin
  FLock.BeginRead;
  try
    for aBrokerData in FBrokerList.Values do
      aBrokerData.AssignTo(aTopologyDataList.Add);

    for aGatewayData in FGatewayList.Values do
      aGatewayData.AssignTo(aTopologyDataList.Add);
  finally
    FLock.EndRead;
  end;

  aTopologyDataList.SortBySortIndex;
end;

procedure TTopologyCache.GetTopologyList(const aTopologyDataList: TTopologyDataList);
var
  aBrokerData: TBrokerData;
  aGatewayData: TGatewayData;
  aDeviceData: TDeviceData;
begin
  FLock.BeginRead;
  try
    for aBrokerData in FBrokerList.Values do
      aBrokerData.AssignTo(aTopologyDataList.Add);

    for aGatewayData in FGatewayList.Values do
      aGatewayData.AssignTo(aTopologyDataList.Add);

    for aDeviceData in FDeviceList.Values do
      aDeviceData.AssignTo(aTopologyDataList.Add);
  finally
    FLock.EndRead;
  end;

  aTopologyDataList.SortBySortIndex;
end;

function TTopologyCache.GetTopologyInfo(const aTopologyId: RInteger;
                                        const aTopologyData: TTopologyData;
                                        var aErrorInfo: string): Boolean;
var
  aBrokerData: TBrokerCacheData;
  aGatewayData: TGatewayCacheData;
  aDeviceData: TDeviceCacheData;
begin
  Result := False;

  if aTopologyId.IsNull then
  begin
    aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
    Exit;
  end;

  FLock.BeginRead;
  try
    if FBrokerList.TryGetValue(aTopologyId.Value, aBrokerData) then
    begin
      aBrokerData.AssignTo(aTopologyData);
      Exit(True);
    end;

    if FGatewayList.TryGetValue(aTopologyId.Value, aGatewayData) then
    begin
      aGatewayData.AssignTo(aTopologyData);
      Exit(True);
    end;

    if FDeviceList.TryGetValue(aTopologyId.Value, aDeviceData) then
    begin
      aDeviceData.AssignTo(aTopologyData);
      Exit(True);
    end;

    if not Result then
      aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
  finally
    FLock.EndRead;
  end;
end;

function TTopologyCache.GetGatewayModel(const aGatewayId: RInteger;
                                        var aGatewayModel: string): Boolean;
var
  aGatewayData: TGatewayCacheData;
begin
  Result := False;

  if aGatewayId.IsNull then
    Exit;

  FLock.BeginRead;
  try
    if FGatewayList.TryGetValue(aGatewayId.Value, aGatewayData) then
    begin
      aGatewayModel := aGatewayData.devModel.AsString;
      Exit(True);
    end;
  finally
    FLock.EndRead;
  end;
end;

function TTopologyCache.doCheckTopologyExists(const aTopologyId: RInteger;
                                              const aDeviceType: TDeviceType): Boolean;
begin
  Result := False;

  if aTopologyId.IsNull then
    Exit;

  case aDeviceType of
    dtBroker:  Result := FBrokerList.ContainsKey(aTopologyId.Value);
    dtGateway: Result := FGatewayList.ContainsKey(aTopologyId.Value);
    dtDevice:  Result := FDeviceList.ContainsKey(aTopologyId.Value);
  end;
end;

function TTopologyCache.doGetTopologyDeviceType(const aTopologyId: RInteger;
                                                var aDeviceType: TDeviceType): Boolean;
begin
  Result := False;

  if aTopologyId.IsNull then
    Exit;

  if FBrokerList.ContainsKey(aTopologyId.Value) then
  begin
    aDeviceType := dtBroker;
    Result := True;
    Exit;
  end;

  if FGatewayList.ContainsKey(aTopologyId.Value) then
  begin
    aDeviceType := dtGateway;
    Result := True;
    Exit;
  end;

  if FDeviceList.ContainsKey(aTopologyId.Value) then
  begin
    aDeviceType := dtDevice;
    Result := True;
    Exit;
  end;
end;

function TTopologyCache.doCheckForAdd(const aTopologyData: TTopologyData;
                                      var aErrorInfo: string): Boolean;

  function CheckParentExists(const aTopologyData: TTopologyData): Boolean;
  begin
    Result := False;

    case aTopologyData.deviceType of
      dtBroker:  Result := True;
      dtGateway: Result := doCheckTopologyExists(aTopologyData.parentId, dtBroker);
      dtDevice:  Result := doCheckTopologyExists(aTopologyData.parentId, dtGateway);
    end;
  end;

begin
  Result := False;

  // ****************** ���ͨ�õ� ******************

  // name ���� , ��ʱ������Ψһ
  if Trim(aTopologyData.name.AsString) = '' then
  begin
    aErrorInfo := '���Ʋ���Ϊ��';
    Exit;
  end;

  // ����豸���
  // devId: RString;

  // ����豸�ͺ��Ƿ����
  //CheckModelExists(aTopologyData.devModel.AsString)
  //_DDModelsInter._doGetGatewayModelList();

  // ��鸸�ڵ����
  if not CheckParentExists(aTopologyData) then
  begin
    aErrorInfo := '���ڵ㲻���ڣ�';
    Exit;
  end;

  // ****************** ������ ******************
  //data: RString;           // �豸�Զ�������
  case aTopologyData.deviceType of
    dtBroker:  // Broker ����
      begin
      end;
    dtGateway: // ͨѶ�豸
      begin
      end;
    dtDevice: // �ն��豸
      begin
      end;
  end;

  Result := True;
end;

procedure TTopologyCache.doSetGatewayUnIssue(const aGatewayData: TGatewayCacheData);
var
  aErrorInfo: string;
begin
  aGatewayData.devState := dsUnIssue;
  _DDDataInter._doUpdateTopology(aGatewayData, aErrorInfo);
end;

procedure TTopologyCache.doAddBroker(const aTopologyData: TTopologyData);
var
  aBrokerData: TBrokerCacheData;
  aErrorInfo: string;
begin
  aBrokerData := TBrokerCacheData.Create;
  aBrokerData.Assign(aTopologyData);
  aBrokerData.commState := csOffLine;
  aBrokerData.devState := dsNormal;
  FBrokerList.AddOrSetValue(aBrokerData.id.Value, aBrokerData);

  if not doRegBroker(aBrokerData, aErrorInfo) then
  begin
    aBrokerData.devState := dsDoubt;
    aBrokerData.doubtInfo.Value := aErrorInfo;
  end;
end;

function TTopologyCache.doRegBroker(const aBrokerData: TBrokerCacheData;
                                    var aErrorInfo: string): Boolean;
begin
  Result := False;

  if aBrokerData.id.IsNull then
  begin
    aErrorInfo := '���ķ���ID������';
    Exit;
  end;

  Result := _DDCommInter._RegBroker(aBrokerData.id.Value,
                                    aBrokerData.devId.AsString,
                                    aBrokerData.brokerHost.AsString,
                                    aBrokerData.brokerPort.Value,
                                    aBrokerData.userName.AsString,
                                    aBrokerData.password.AsString,
                                    aErrorInfo);
end;

procedure TTopologyCache.doUnRegBroker(const aBrokerId: Int64);
begin
  _DDCommInter._UnRegBroker(aBrokerId);
end;

function TTopologyCache.AddTopology(const aTopologyData: TTopologyData;
                                    var aErrorInfo: string): Boolean;
begin
  case aTopologyData.deviceType of
    dtBroker:  Result := AddBroker(aTopologyData, aErrorInfo);
    dtGateway: Result := AddGateway(aTopologyData, aErrorInfo);
    dtDevice:  Result := AddDevice(aTopologyData, aErrorInfo);
  else
    begin
      aErrorInfo := '�豸���Ͳ�����';
      Result := False;
    end;
  end;
  if Result then
    _TopoCountCache.SetNeedUpdate;
end;

function TTopologyCache.AddBroker(const aTopologyData: TTopologyData;
                                  var aErrorInfo: string): Boolean;
begin
  Result := False;

  FLock.BeginWrite;
  try
    // ������ݺϷ���
    if not doCheckForAdd(aTopologyData, aErrorInfo) then
      Exit;

    // Broker �޽ڵ�
    aTopologyData.parentId.Clear;

    // ��ӵ����������ļ�
    if not _DDDataInter._doAddTopology(aTopologyData, aErrorInfo) then
      Exit;

    // ��ӵ�����
    doAddBroker(aTopologyData);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.doUpdateGatewayState(const aGatewayData: TGatewayCacheData);

  function CheckAndGetDoubtInfo(const aGatewayData: TGatewayCacheData;
                                const aFromInfo: TFromInfo;
                                var aDoubtInfo: string): Boolean;
  begin
    Result := True;

    if not SameText(aGatewayData.devModel.AsString, aFromInfo._model) then
    begin
      aDoubtInfo := '�豸�ͺŲ�һ��';
      Exit;
    end;

    if (aFromInfo._runstate <> '') and
       not SameText(aGatewayData.runState.AsString, aFromInfo._runstate) then
    begin
      aDoubtInfo := '�豸�б�汾�Ų�һ��';
      Exit;
    end;

    Result := False;
  end;

var
  aFromInfo: TFromInfo;
  aDoubtInfo: string;
  aDeviceData: TDeviceCacheData;
begin
  if aGatewayData.Broker.TryGetOnLineGatewayInfo(aGatewayData.devId.AsString, aFromInfo) then
  begin
    aGatewayData.commState := csOnLine;
    if CheckAndGetDoubtInfo(aGatewayData, aFromInfo, aDoubtInfo) then
    begin
      aGatewayData.devState := dsDoubt;
      aGatewayData.doubtInfo.Value := aDoubtInfo;
    end
    else
      aGatewayData.devState := dsNormal;
  end
  else
  begin
    aGatewayData.commState := csOffLine;
    aGatewayData.devState := dsNormal;
    for aDeviceData in aGatewayData.DeviceList.Values do
      aDeviceData.commState := csOffLine;
  end;
end;

procedure TTopologyCache.doAddGateway(const aTopologyData: TTopologyData);
var
  aGatewayData: TGatewayCacheData;
begin
  aGatewayData := TGatewayCacheData.Create;
  aGatewayData.Assign(aTopologyData);
  aGatewayData.Broker := GetBroker(aGatewayData.parentId);

  doUpdateGatewayState(aGatewayData);

  FGatewayList.AddOrSetValue(aGatewayData.id.Value, aGatewayData);
  aGatewayData.Broker.GatewayList.AddOrSetValue(aGatewayData.id.Value, aGatewayData);
end;

function TTopologyCache.AddGateway(const aTopologyData: TTopologyData;
                                   var aErrorInfo: string): Boolean;
begin
  Result := False;

  FLock.BeginWrite;
  try
    // ������ݺϷ���
    if not doCheckForAdd(aTopologyData, aErrorInfo) then
      Exit;

    // ��ӵ����������ļ�
    if not _DDDataInter._doAddTopology(aTopologyData, aErrorInfo) then
      Exit;

    // ��ӵ�����
    doAddGateway(aTopologyData);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyCache.AddDevice(const aTopologyData: TTopologyData;
                                  var aErrorInfo: string): Boolean;
begin
  Result := False;

  FLock.BeginWrite;
  try
    // ������ݺϷ���
    if not doCheckForAdd(aTopologyData, aErrorInfo) then
      Exit;

    // ��ӵ����������ļ�
    if not _DDDataInter._doAddTopology(aTopologyData, aErrorInfo) then
      Exit;

    // ��ӵ�����
    doAddDevice(aTopologyData, True);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.doAddDevice(const aTopologyData: TTopologyData;
                                     const aIsNew: Boolean);
var
  aDeviceData: TDeviceCacheData;
  aGateway: TGatewayCacheData;
begin
  aGateway := GetGateway(aTopologyData.parentId);
  if aGateway = nil then
  begin
    OutputDebugString('����ն��豸������ʧ��, ���ز�����');
    Exit;
  end;
  aDeviceData := TDeviceCacheData.Create;
  aDeviceData.Assign(aTopologyData);
  aDeviceData.Gateway := aGateway;
  aDeviceData.commState := csOffLine;

  if aIsNew then
    doSetGatewayUnIssue(aDeviceData.Gateway);

  FDeviceList.AddOrSetValue(aDeviceData.id.Value, aDeviceData);
  aDeviceData.Gateway.DeviceList.AddOrSetValue(aDeviceData.id.Value, aDeviceData);
end;

function TTopologyCache.UpdateBroker(const aTopologyData: TTopologyData;
                                     var aErrorInfo: string): Boolean;

  // �ж� Broker �����Ƿ����仯
  function doCheckBrokerConfigChanged(const aBrokerData: TBrokerCacheData;
                                      const aTopologyData: TTopologyData): Boolean;
  begin
    Result := not SameText(aBrokerData.devId.AsString, aTopologyData.devId.AsString)
           or not SameText(aBrokerData.data.AsString, aTopologyData.data.AsString);
  end;

var
  aBrokerData: TBrokerCacheData;
  aNeedChangeMQTT: Boolean;    // �Ƿ���Ҫ����ע�� MQTT
begin
  Result := False;

  FLock.BeginWrite;
  try
    // 1. ���Ҫ���µĽڵ����
    if aTopologyData.id.IsNull or
       not FBrokerList.TryGetValue(aTopologyData.id.Value, aBrokerData) then
    begin
      aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
      Exit;
    end;

    // 2. ������ݺϷ���
    if not doCheckForAdd(aTopologyData, aErrorInfo) then
      Exit;

    // 3. ���µ����������ļ�
    if not _DDDataInter._doUpdateTopology(aTopologyData, aErrorInfo) then
      Exit;

    // 4. ���µ�����
    aNeedChangeMQTT := doCheckBrokerConfigChanged(aBrokerData, aTopologyData);
    aBrokerData.UpdateFrom(aTopologyData);
    if aNeedChangeMQTT then
    begin
      doUnRegBroker(aBrokerData.id.Value);
      aBrokerData.commState := csOffLine;
      aBrokerData.devState := dsNormal;

      if not doRegBroker(aBrokerData, aErrorInfo) then
      begin
        aBrokerData.devState := dsDoubt;
        aBrokerData.doubtInfo.Value := aErrorInfo;
      end;
    end;

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyCache.UpdateGateway(const aTopologyData: TTopologyData;
                                      var aErrorInfo: string): Boolean;

  // �ж� Gateway �����Ƿ����仯
  function doCheckGatewayConfigChanged(const aGatewayData: TGatewayCacheData;
                                       const aTopologyData: TTopologyData): Boolean;
  begin
    Result := not SameText(aGatewayData.devId.AsString, aTopologyData.devId.AsString)
           or not SameText(aGatewayData.devModel.AsString, aTopologyData.devModel.AsString);
  end;

var
  aGatewayData: TGatewayCacheData;
  aConfigChanged: Boolean;
begin
  Result := False;

  FLock.BeginWrite;
  try
    // 1. ���Ҫ���µĽڵ����
    if aTopologyData.id.IsNull or
       not FGatewayList.TryGetValue(aTopologyData.id.Value, aGatewayData) then
    begin
      aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
      Exit;
    end;

    // 2. ������ݺϷ���
    if not doCheckForAdd(aTopologyData, aErrorInfo) then
      Exit;

    /////////////////////////////
    // Broker ������ô��
    // parentId: RInteger;      // ���ڵ���

    // 3. ���µ�����
    aConfigChanged := doCheckGatewayConfigChanged(aGatewayData, aTopologyData);
    if aConfigChanged then
    begin
      aGatewayData.UpdateFrom(aTopologyData);
      aGatewayData.runState.Value := '';
      aGatewayData.UpdateData;
      doUpdateGatewayState(aGatewayData);
    end
    else
    begin
      aGatewayData.name := aTopologyData.name;
      aGatewayData.note := aTopologyData.note;
    end;

    // 4. ���µ����������ļ�
    if not _DDDataInter._doUpdateTopology(aGatewayData, aErrorInfo) then
      Exit;

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyCache.UpdateDevice(const aTopologyData: TTopologyData;
                                     var aErrorInfo: string): Boolean;
var
  aDeviceData: TDeviceCacheData;
begin
  Result := False;

  FLock.BeginWrite;
  try
    // 1. ���Ҫ���µĽڵ����
    if aTopologyData.id.IsNull or
       not FDeviceList.TryGetValue(aTopologyData.id.Value, aDeviceData) then
    begin
      aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
      Exit;
    end;

    // 2. ������ݺϷ���
    if not doCheckForAdd(aTopologyData, aErrorInfo) then
      Exit;

    // 3. ���µ����������ļ�
    if not _DDDataInter._doUpdateTopology(aTopologyData, aErrorInfo) then
      Exit;

    // 4. ���µ�����
    aDeviceData.UpdateFrom(aTopologyData);
    aDeviceData.commState := csOffLine;
    aDeviceData.devState := dsNormal;

    doSetGatewayUnIssue(aDeviceData.Gateway);

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyCache.UpdateTopology(const aTopologyData: TTopologyData;
                                       var aErrorInfo: string): Boolean;
begin
  case aTopologyData.deviceType of
    dtBroker:  Result := UpdateBroker(aTopologyData, aErrorInfo);
    dtGateway: Result := UpdateGateway(aTopologyData, aErrorInfo);
    dtDevice:  Result := UpdateDevice(aTopologyData, aErrorInfo);
  else
    begin
      aErrorInfo := '�豸���Ͳ�����';
      Result := False;
    end;
  end;
  if Result then
    _TopoCountCache.SetNeedUpdate;
end;

function TTopologyCache.DeleteTopology(const aTopologyId: RInteger;
                                       var aErrorInfo: string): Boolean;
var
  aDeviceType: TDeviceType;
  aIdList: TList<RInteger>;
begin
  Result := False;

  FLock.BeginWrite;
  try
    // 1. ȡ�ڵ���豸����
    if not doGetTopologyDeviceType(aTopologyId, aDeviceType) then
    begin
      aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
      Exit;
    end;

    // 2. �ӻ�����ɾ���ڵ�
    aIdList := TList<RInteger>.Create;
    try
      case aDeviceType of
        dtBroker:  doDeleteBroker(aTopologyId.Value, aIdList);
        dtGateway: doDeleteGateway(aTopologyId.Value, aIdList);
        dtDevice:  doDeleteDevice(aTopologyId.Value, aIdList);
      end;

      // ��������ɾ��
      Result := _DDDataInter._doDeleteTopologys(aIdList.ToArray, aErrorInfo);

      _TopoCountCache.SetNeedUpdate;
    finally
      aIdList.Free;
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.doSortBrokers(const aTopologyIdList: TArray<RInteger>;
                                       const aIdList: TList<RInteger>);
var
  aId: RInteger;
  i: Integer;
  aBroker: TBrokerCacheData;
begin
  aIdList.Clear;
  i := 1;
  for aId in aTopologyIdList do
  begin
    if doTryGetBroker(aId, aBroker) then
    begin
      aBroker.sortIndex.Value := i;
      Inc(i);

      aIdList.Add(aBroker.id);
    end;
  end;
end;

procedure TTopologyCache.doSortGateways(const aBroker: TBrokerCacheData;
                                        const aTopologyIdList: TArray<RInteger>;
                                        const aIdList: TList<RInteger>);
var
  aId: RInteger;
  i: Integer;
  aGateway: TGatewayCacheData;
begin
  aIdList.Clear;
  i := 1;
  for aId in aTopologyIdList do
  begin
    if aBroker.TryGetGateway(aId, aGateway) then
    begin
      aGateway.sortIndex.Value := i;
      Inc(i);

      aIdList.Add(aGateway.id);
    end;
  end;
end;

procedure TTopologyCache.doSortDevices(const aGateway: TGatewayCacheData;
                                       const aTopologyIdList: TArray<RInteger>;
                                       const aIdList: TList<RInteger>);
var
  aId: RInteger;
  i: Integer;
  aDevice: TDeviceCacheData;
begin
  aIdList.Clear;
  i := 1;
  for aId in aTopologyIdList do
  begin
    if aGateway.TryGetDevice(aId, aDevice) then
    begin
      aDevice.sortIndex.Value := i;
      Inc(i);

      aIdList.Add(aDevice.id);
    end;
  end;
end;

function TTopologyCache.SortTopologys(const aParentTopologyId: RInteger;
                                      const aTopologyIdList: TArray<RInteger>;
                                      var aErrorInfo: string): Boolean;
var
  aIdList: TList<RInteger>;
  aBroker: TBrokerCacheData;
  aGateway: TGatewayCacheData;
begin
  FLock.BeginWrite;
  try
    aIdList := TList<RInteger>.Create;
    try
      if aParentTopologyId.IsNull then
        doSortBrokers(aTopologyIdList, aIdList)
      else
      if FBrokerList.TryGetValue(aParentTopologyId.Value, aBroker) then
        doSortGateways(aBroker, aTopologyIdList, aIdList)
      else
      if FGatewayList.TryGetValue(aParentTopologyId.Value, aGateway) then
        doSortDevices(aGateway, aTopologyIdList, aIdList);

      // ��������
      Result := _DDDataInter._doSortTopologys(aIdList.ToArray, aErrorInfo);
    finally
      aIdList.Free;
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.doClearDeviceOfGateway(const aGateway: TGatewayCacheData);
var
  aDeviceData: TDeviceCacheData;
  aIdList: TList<RInteger>;
  aErrorInfo: string;
begin
  aIdList := TList<RInteger>.Create;
  try
    for aDeviceData in aGateway.DeviceList.Values do
    begin
      aIdList.Add(aDeviceData.id);

      FDeviceList.Remove(aDeviceData.id.Value);
      aDeviceData.Free;
    end;

    aGateway.DeviceList.Clear;

    _DDDataInter._doDeleteTopologys(aIdList.ToArray, aErrorInfo);
  finally
    aIdList.Free;
  end;
end;

procedure TTopologyCache.doUpdateDeviceNameFromOldDevice(const aGateway: TGatewayCacheData;
                                                         const aNewDeviceList: TDeviceDataList);
var
  aOldDevice: TDeviceCacheData;
  aNewDevice: TDeviceData;
begin
  for aNewDevice in aNewDeviceList do
  begin
    aNewDevice.name.Value := aNewDevice.devId.AsString + '(δ֪)';
    for aOldDevice in aGateway.DeviceList.Values do
    begin
      if SameText(aNewDevice.port.AsString, aOldDevice.port.AsString) and
         SameText(aNewDevice.commId.AsString, aOldDevice.commId.AsString) and
         SameText(aNewDevice.devId.AsString, aOldDevice.devId.AsString) then
      begin
        aNewDevice.name := aOldDevice.name;
        aNewDevice.note := aOldDevice.note;
      end;
    end;
  end;
end;

function TTopologyCache.doGetRealDeviceList(const aGateway: TGatewayCacheData;
                                            const aDeviceList: TDeviceDataList;
                                            var aFrom: TFromInfo;
                                            var aErrorInfo: string): Boolean;

  function GetDeviceListFromJson(const aJsonStr: string;
                                 const aDeviceList: TDeviceDataList): Boolean;
  var
    aJson: TJsonArray;
    i: Integer;
  begin
    aJson := TJsonArray.Parse(aJsonStr) as TJsonArray;
    try
      try
        for i := 0 to aJson.Count - 1 do
        begin
          with aDeviceList.Add do
          begin
            commId   := aJson.O[i].RS['_commid'];
            port     := aJson.O[i].RS['_port'];
            devId    := aJson.O[i].RS['_devid'];
            devAddr  := aJson.O[i].RS['_devaddr'];
            devModel := aJson.O[i].RS['_type'];
          end;
        end;
        Result := True;
      except
        Result := False;
      end;
    finally
      aJson.Free;
    end;
  end;

var
  aBrokerId: Int64;
  aReceiveDevId: string;
  aSendData: TCommDataInfo;
  aReceiveData: TCommDataInfo;
begin
  Result := False;

  aBrokerId := aGateway.Broker.id.Value;
  aReceiveDevId := aGateway.devId.AsString;
  with aSendData do
  begin
    DataType := cdtRequest;
    Cmd := 'manager/dev/list.do';
    CmdData := '{}';
  end;

  if not _DDCommInter._SendCmdSync(aBrokerId,
                                   aReceiveDevId,
                                   aSendData,
                                   aReceiveData,
                                   aErrorInfo) then
    Exit;

  if aReceiveData.StatusCode = '0' then
  begin
    Result := GetDeviceListFromJson(aReceiveData.ResponseData, aDeviceList);
    if not Result then
      aErrorInfo := '�������ݸ�ʽ����';
  end
  else
    aErrorInfo := Format('������: %s', [aReceiveData.StatusCode]);
end;

function TTopologyCache.doUpdateDevicesFromGateway(const aGatewayId: RInteger;
                                                   var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayCacheData;
  aFrom: TFromInfo;
  aNewDeviceList: TDeviceDataList;
  aNewDevice: TDeviceData;
begin
  Result := False;

  if not doTryGetGateway(aGatewayId, aGatewayData) then
  begin
    aErrorInfo := 'ָ�������ز�����';
    Exit;
  end;

  aNewDeviceList := TDeviceDataList.Create;
  try
    if not doGetRealDeviceList(aGatewayData, aNewDeviceList, aFrom, aErrorInfo) then
      Exit;

    // �����ذ���ͬ�豸�����Ƹ��ƹ���
    doUpdateDeviceNameFromOldDevice(aGatewayData, aNewDeviceList);

    // ��������µ��豸�б�
    doClearDeviceOfGateway(aGatewayData);

    for aNewDevice in aNewDeviceList do
    begin
      aNewDevice.parentId := aGatewayData.id;
      aNewDevice.UpdateData;

      if not _DDDataInter._doAddTopology(aNewDevice, aErrorInfo) then
        Exit;

      doAddDevice(aNewDevice);
    end;

    aGatewayData.devState := dsNormal;
    aGatewayData.doubtInfo.Value := '';
    aGatewayData.runState.Value := aFrom._runstate;
    aGatewayData.UpdateData;
    if not _DDDataInter._doUpdateTopology(aGatewayData, aErrorInfo) then
      Exit;

    Result := True;
    doChanged;
  finally
    aNewDeviceList.Free;
  end;
end;

function TTopologyCache.doIssueDevicesToGateway(const aGatewayId: RInteger;
                                                var aErrorInfo: string): Boolean;

  function GetDeviceListAsCmdData(const aGateway: TGatewayCacheData): string;
  const
    DEV_UPDATE = '{"_type":"%s","_port":"%s","_commid":"%s","_devaddr":"%s","_devid":"%s"}';
  var
    aDevice: TDeviceData;
  begin
    Result := '';

    for aDevice in aGateway.DeviceList.Values do
    begin
      Result := Result + ',' +
                Format(DEV_UPDATE, [aDevice.devModel.AsString, aDevice.port.AsString,
                                    aDevice.commId.AsString, aDevice.devAddr.AsString,
                                    aDevice.devId.AsString]);
    end;
    if Result <> '' then
      Delete(Result, 1, 1);
    Result := '[' + Result + ']';
  end;

var
  aGateway: TGatewayCacheData;
  aBrokerId: Int64;
  aReceiveDevId: string;
  aSendData: TCommDataInfo;
  aReceiveData: TCommDataInfo;
begin
  Result := False;

  if not doTryGetGateway(aGatewayId, aGateway) then
  begin
    aErrorInfo := 'ָ�������ز�����';
    Exit;
  end;

  aBrokerId := aGateway.Broker.id.Value;
  aReceiveDevId := aGateway.devId.AsString;
  with aSendData do
  begin
    DataType := cdtRequest;
    Cmd := 'manager/dev/replace.do';
    CmdData := GetDeviceListAsCmdData(aGateway);
  end;

  if not _DDCommInter._SendCmdSync(aBrokerId,
                                   aReceiveDevId,
                                   aSendData,
                                   aReceiveData,
                                   aErrorInfo) then
    Exit;

  if aReceiveData.StatusCode = '0' then
  begin
    // ���� �豸�б�
    Result := doUpdateDevicesFromGateway(aGateway.id, aErrorInfo);
  end
  else
    aErrorInfo := Format('������: %s', [aReceiveData.StatusCode]);
end;

function TTopologyCache.DeviceEqual(const aDeviceA, aDeviceB: TDeviceData): Boolean;
begin
  Result := SameText(aDeviceA.port.AsString, aDeviceB.port.AsString) and
            SameText(aDeviceA.commId.AsString, aDeviceB.commId.AsString) and
            SameText(aDeviceA.devAddr.AsString, aDeviceB.devAddr.AsString) and
            SameText(aDeviceA.devId.AsString, aDeviceB.devId.AsString) and
            SameText(aDeviceA.devModel.AsString, aDeviceB.devModel.AsString);
end;

function TTopologyCache.GetConfigDeviceList(const aGatewayId: RInteger;
                                            var aRunState: RString;
                                            const aTopologyDataList: TTopologyDataList;
                                            var aErrorInfo: string): Boolean;
var
  aGateway: TGatewayCacheData;
  aDeviceList: TDeviceDataList;
  aDevice: TDeviceCacheData;
  aDeviceData: TDeviceData;
begin
  Result := False;

  FLock.BeginRead;
  try
    if not doTryGetGateway(aGatewayId, aGateway) then
    begin
      aErrorInfo := 'ָ�������ز�����';
      Exit;
    end;

    aRunState := aGateway.runState;

    aDeviceList := TDeviceDataList.Create;
    try
      for aDevice in aGateway.DeviceList.Values do
        aDeviceList.Add.Assign(aDevice);

      aDeviceList.SortByCommId;

      for aDeviceData in aDeviceList do
        aDeviceData.AssignTo(aTopologyDataList.Add);
    finally
      aDeviceList.Free;
    end;

    Result := True;
  finally
    FLock.EndRead;
  end;
end;

function TTopologyCache.GetRealDeviceList(const aGatewayId: RInteger;
                                          var aRunState: RString;
                                          const aTopologyDataList: TTopologyDataList;
                                          var aErrorInfo: string): Boolean;
var
  aGateway: TGatewayCacheData;
  aFrom: TFromInfo;
  aDeviceList: TDeviceDataList;
  aDevice: TDeviceData;
begin
  Result := False;

  FLock.BeginRead;
  try
    if not doTryGetGateway(aGatewayId, aGateway) then
    begin
      aErrorInfo := 'ָ�������ز�����';
      Exit;
    end;

    aDeviceList := TDeviceDataList.Create;
    try
      if not doGetRealDeviceList(aGateway, aDeviceList, aFrom, aErrorInfo) then
        Exit;

      aRunState.Value := aFrom._runstate;

      aDeviceList.SortByCommId;

      for aDevice in aDeviceList do
        aDevice.AssignTo(aTopologyDataList.Add);

      Result := True;
    finally
      aDeviceList.Free;
    end;
  finally
    FLock.EndRead;
  end;
end;

function TTopologyCache.UpdateDevicesFromGateway(const aGatewayId: RInteger;
                                                 var aErrorInfo: string): Boolean;
begin
  FLock.BeginWrite;
  try
    Result := doUpdateDevicesFromGateway(aGatewayId, aErrorInfo);
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyCache.IssueDevicesToGateway(const aGatewayId: RInteger;
                                              var aErrorInfo: string): Boolean;
begin
  FLock.BeginWrite;
  try
    Result := doIssueDevicesToGateway(aGatewayId, aErrorInfo);
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyCache.GetDeviceRealData(const aDeviceId: RInteger;
                                          var aLastRealTime: RString;
                                          var aRealData: RString;
                                          var aErrorInfo: string): Boolean;
var
  aDevice: TDeviceCacheData;
begin
  Result := False;

  FLock.BeginRead;
  try
    aDevice := GetDevice(aDeviceId);

    if aDevice = nil then
    begin
      aErrorInfo := 'ָ�����ն˲�����';
      Exit;
    end;

    aLastRealTime := aDevice.lastRealTime;
    aRealData := aDevice.realData;

    Result := True;
  finally
    FLock.EndRead;
  end;
end;

procedure TTopologyCache.doSetGatewayOnLine(const aBrokerId: Int64;
  const aFromInfo: TFromInfo);
var
  aBrokerData: TBrokerCacheData;
  aGatewayData: TGatewayCacheData;
  aTmpGatewayData: TGatewayData;
  aFrom: TFromInfo;
  aErrorInfo: string;
begin
FLock.BeginWrite;
  try
    if not FBrokerList.TryGetValue(aBrokerId, aBrokerData) then
      Exit;

    aFrom := aFromInfo;
    aFrom._runstate := '';
    aBrokerData.AddOnLineGatewayInfo(aFrom);

    if aBrokerData.TryGetGatewayInfo(aFromInfo._devid, aGatewayData) then
      doUpdateGatewayState(aGatewayData)
    else
    begin
      aTmpGatewayData := TGatewayData.Create;
      try
        aTmpGatewayData.parentId.Value := aBrokerId;
        aTmpGatewayData.name.Value := aFrom._devid + '(δ֪)';
        aTmpGatewayData.devId.Value := aFrom._devid;
        aTmpGatewayData.devModel.Value := aFrom._model;
        aTmpGatewayData.isTemp.Value := True;
        aTmpGatewayData.UpdateData;
        // ��ӵ����������ļ�
        if not _DDDataInter._doAddTopology(aTmpGatewayData, aErrorInfo) then
          Exit;

        // ��ӵ�����
        doAddGateway(aTmpGatewayData);
      finally
        aTmpGatewayData.Free;
      end;
    end;
    doChanged;
    _TopoCountCache.SetNeedUpdate;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.doSetGatewayOffLine(const aBrokerId: Int64;
  const aGatewayDevId: string);
var
  aBrokerData: TBrokerCacheData;
  aGatewayData: TGatewayCacheData;
begin
  FLock.BeginWrite;
  try
    if not FBrokerList.TryGetValue(aBrokerId, aBrokerData) then
      Exit;

    aBrokerData.DeleteOnLineGatewayInfo(aGatewayDevId);

    if aBrokerData.TryGetGatewayInfo(aGatewayDevId, aGatewayData) then
    begin
      doUpdateGatewayState(aGatewayData);
      doChanged;
      _TopoCountCache.SetNeedUpdate;
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.doUpdateBrokerGatewayState(const aBrokerId: Int64;
                                                    const aFrom: TFromInfo);
var
  aBroker: TBrokerCacheData;
  aGateway: TGatewayCacheData;
  aFromInfo: TFromInfo;
begin
  FLock.BeginWrite;
  try
    if not FBrokerList.TryGetValue(aBrokerId, aBroker) then
      Exit;

    if not aBroker.TryGetOnLineGatewayInfo(aFrom._devid, aFromInfo) then
      Exit;

    if not SameText(aFromInfo._model, aFrom._model) or
       not SameText(aFromInfo._runstate, aFrom._runstate) then
    begin
      aBroker.AddOnLineGatewayInfo(aFrom);

      if TryFindGateway(aBrokerId, aFrom._devid, aGateway) then
        doUpdateGatewayState(aGateway);
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyCache.doGetUpData(const aBrokerId: Int64;
                                     const aCommDataInfo: TCommDataInfo);
var
  aGateway: TGatewayCacheData;
  aDevice: TDeviceCacheData;
  aJsonArray: TJsonArray;
  aJsonItem: TJsonObject;
  i: Integer;
  aNowDateTime: string;
  aCommId: string;
  aPort: string;
  aDevId: string;
  aRealValue1, aRealValue2, aRealValue3: string;
  aErrorInfo: string;
begin
  aJsonArray := TJsonArray.Create;
  try
    aJsonArray.FromJSON(aCommDataInfo.CmdData);
    if aJsonArray.Count = 0 then
      Exit;

    aNowDateTime := DateTimeToStr(Now);
    doUpdateBrokerGatewayState(aBrokerId, aCommDataInfo.From);
    aGateway := TGatewayCacheData.Create;
    try
      if not GetTmpGateway(aBrokerId, aCommDataInfo.From._devid, aGateway) then
        Exit;

      for i := 0 to aJsonArray.Count - 1 do
      begin
        aJsonItem := aJsonArray.O[i];

        aCommId := aJsonItem.S['_commid'];
        aPort := aJsonItem.S['_port'];
        aDevId := aJsonItem.S['_devid'];

        // ��Ҫ��ȱһ��������Ч����
        if (aCommId = '') or (aPort = '') or (aDevId = '') then
          Continue;

        // ��Ҫ����ʵ�ʻ������ݲ�����������Ч����
        if not aGateway.TryGetDeviceInfo(aDevId, aDevice) or
           not SameText(aDevice.commId.AsString, aCommId) or
           not SameText(aDevice.port.AsString, aPort) then
          Continue;

        if SameText(aJsonItem.S['_status'], 'offline') then
        begin
          aDevice.commState := csOffLine;
        end
        else
        begin
          aDevice.commState := csOnLine;

          // �ж�������ȷ�󣬸���ʵʱ���ݣ���д�������ļ�
          aDevice.lastRealTime.Value := aNowDateTime;
          aDevice.realData.Value := aJsonItem.ToJSON(True);

          // ������ ��������
          // ���ݴ���
          if _DDModelsInter._doGetDeviceMainValues(aDevice.devModel.AsString,
                                                   aJsonItem.ToJson(True),
                                                   aRealValue1,
                                                   aRealValue2,
                                                   aRealValue3,
                                                   aErrorInfo) then
          begin
            aDevice.realValue1.Value := aRealValue1;
            aDevice.realValue2.Value := aRealValue2;
            aDevice.realValue3.Value := aRealValue3;
          end
          else
          begin
            aDevice.realValue1.Value := aErrorInfo;
            aDevice.realValue2.Value := '';
            aDevice.realValue3.Value := '';
          end;

          _DDDataInter._doSaveDeviceRealData(aDevId, aNowDateTime, aDevice.realData.AsString, aErrorInfo);
        end;
      end;
    finally
      aGateway.Free;
    end;

    doChanged;
    _TopoCountCache.SetNeedUpdate;
  finally
    aJsonArray.Free;
  end;
end;

procedure TTopologyCache.doSetCommEvents;
begin
  _DDCommInter._SetCallBackEvent(@OnSendEvent, @OnReceiveEvent, @OnConnectEvent, @OnDisconnectEvent);
end;

procedure TTopologyCache.doCloseCommEvents;
begin
  _DDCommInter._SetCallBackEvent(nil, nil, nil, nil);
end;

procedure TTopologyCache.ReceiveCommData(const aBrokerId: Int64; const aCommDataInfo: TCommDataInfo);
var
  aUpdateCmd: TUpdateCmd;
begin
  case aCommDataInfo.DataType of
    // ��Ӧ�������
    cdtUpdate:
      begin
        aUpdateCmd := TDDGatewayCtrl.GetUpdateCmd(aCommDataInfo.Cmd, aCommDataInfo.CmdData);
        if aUpdateCmd = ucNone then
          Exit;

        case aUpdateCmd of
          ucOnLine:  doSetGatewayOnLine(aBrokerId, aCommDataInfo.From);
          ucOffLine: doSetGatewayOffLine(aBrokerId, aCommDataInfo.From._devid);
          ucData:    doGetUpData(aBrokerId, aCommDataInfo);
        end;
      end;
  end;
end;

procedure TTopologyCache.GetTopoCountInfo(var aBrokerTotalCount: Integer;
                                          var aBrokerOffLineCount: Integer;
                                          var aGatewayTotalCount: Integer;
                                          var aGatewayOffLineCount: Integer;
                                          var aGatewayDoubtCount: Integer;
                                          var aGatewayUnknowCount: Integer;
                                          var aDeviceTotalCount: Integer;
                                          var aDeviceOffLineCount: Integer;
                                          var aDeviceAlarmCount: Integer);
var
  aBroker: TBrokerCacheData;
  aGateway: TGatewayCacheData;
  aDevice: TDeviceCacheData;
begin
  aBrokerTotalCount := 0;
  aBrokerOffLineCount := 0;
  aGatewayTotalCount := 0;
  aGatewayOffLineCount := 0;
  aGatewayDoubtCount := 0;
  aGatewayUnknowCount := 0;
  aDeviceTotalCount := 0;
  aDeviceOffLineCount := 0;
  aDeviceAlarmCount := 0;

  FLock.BeginRead;
  try
    // Broker
    aBrokerTotalCount := FBrokerList.Count;
    for aBroker in FBrokerList.Values do
    begin
      if aBroker.commState = csOffLine then
        Inc(aBrokerOffLineCount);
    end;

    // Gateway
    aGatewayTotalCount := FGatewayList.Count;
    for aGateway in FGatewayList.Values do
    begin
      if aGateway.commState = csOffLine then
        Inc(aGatewayOffLineCount)
      else if aGateway.devState = dsDoubt then
        Inc(aGatewayDoubtCount)
      else if aGateway.isTemp.IsTrue then
        Inc(aGatewayUnknowCount);
    end;

    // Device
    aDeviceTotalCount := FDeviceList.Count;
    for aDevice in FDeviceList.Values do
    begin
      if aDevice.commState = csOffLine then
        Inc(aDeviceOffLineCount);
    end;
  finally
    FLock.EndRead;
  end;
end;

function TTopologyCache.SendDataSync(const aGatewayId: RInteger;
                                     const aCmd: string;
                                     const aData: string;
                                     var aStatusCode: string;
                                     var aResponseData: string;
                                     var aErrorInfo: string): Boolean;
var
  aGateway: TGatewayCacheData;
  aBrokerId: Int64;
  aReceiveDevId: string;
  aFrom: TFromInfo;
begin
  Result := False;

  FLock.BeginRead;
  try
    aGateway := GetGateway(aGatewayId);

    if aGateway = nil then
    begin
      aErrorInfo := 'δ�ҵ���Ӧ��������Ϣ';
      Exit;
    end;

    {if aGateway.devState <> dsOnLine then
    begin
      aError.Info := '���ز�����';
      Exit;
    end;}

    aReceiveDevId := aGateway.devId.AsString;
    aBrokerId := aGateway.Broker.id.Value;
  finally
    FLock.EndRead;
  end;

  {Result := _DDCommInter._SendRequestDataSync(aBrokerId,
                                              aReceiveDevId,
                                              aCmd,
                                              aData,
                                              aFrom,
                                              aStatusCode,
                                              aResponseData,
                                              aErrorInfo);   }
end;





{
var
  aBrokerData: TBrokerData;
  aGatewayData: TGatewayData;
  //aTopologyData: TTopologyData;
  //aDeviceData: TDeviceData;
  aCommData: TCustomCommData;
  aError: RError;
begin
  FLock.BeginRead;
  try
    if not FBrokerList.TryGetValue(aBrokerId, aBrokerData) then
      Exit;
  finally
    FLock.EndRead;
  end;

  aCommData := TCustomCommData.Create(aMsg);
  try
    if aCommData.CommDataType = cdtNone then
      Exit;

    FLock.BeginWrite;
    try
      // �Ѵ���
      if TryFindGateway(aBrokerId, aCommData.From._devid, aGatewayData) then
      begin
        case aCommData.CommDataType of
          // ��ҪӦ�������
          cdtRequest:
            begin
              // �����յ���
            end;
          // ��Ӧ�������
          cdtUpdate:
            begin
              // �����ϱ��ı���Ҫ�̻������ܶ�̬

              case TDDGatewayCtrl.GetUpdateCmd(aCommData) of
                ucOnLine:
                  begin
                    aGatewayData.devState := dsOnLine;
                    doChanged;
                  end;
                ucOffLine:
                  begin
                    aGatewayData.devState := dsOffLine;
                    doChanged;
                  end;
                ucData:
                  begin
                    /////
                  end;
              end;
            end;
          // Ӧ��
          cdtResponse:
            begin

            end;
        end;



      end
      else
      // ������
      begin
        if TDDGatewayCtrl.GetUpdateCmd(aCommData) = ucOnLine then
        begin
          aGatewayData := TGatewayData.Create;
          aGatewayData.parentId := RInteger.Parse(aBrokerId);
          aGatewayData.devId := aCommData.From._devid;
          aGatewayData.devModel := aCommData.From._model;
          aGatewayData.name := 'δ֪';
          aGatewayData.runState := aCommData.From._runstate;
          aGatewayData.devState := dsOnLine;
          aGatewayData.UpdateData;
          if _DDDataInter._doAddTopology(aGatewayData, aError) then
          begin
            doAddTopologyDataToCache(aGatewayData);
            doChanged;
          end;
        end;
      end;
    finally
      FLock.EndWrite;
    end;
  finally
    aCommData.Free;
  end;
end;
}

{ TTopoCountCache }
constructor TTopoCountCache.Create(const aNeedUpdate: Boolean);
begin
  inherited Create(aNeedUpdate);
  doInitTopoCount;
end;

procedure TTopoCountCache.doInitTopoCount;
begin
  FBrokerTotalCount := 0;
  FBrokerOffLineCount := 0;
  FGatewayTotalCount := 0;
  FGatewayOffLineCount := 0;
  FGatewayDoubtCount := 0;
  FGatewayUnknowCount := 0;
  FDeviceTotalCount := 0;
  FDeviceOffLineCount := 0;
  FDeviceAlarmCount := 0;
end;

procedure TTopoCountCache.doRefreshData;
begin
  _TopologyCache.GetTopoCountInfo(FBrokerTotalCount,
                                  FBrokerOffLineCount,
                                  FGatewayTotalCount,
                                  FGatewayOffLineCount,
                                  FGatewayDoubtCount,
                                  FGatewayUnknowCount,
                                  FDeviceTotalCount,
                                  FDeviceOffLineCount,
                                  FDeviceAlarmCount);
end;

function TTopoCountCache.GetTopoCountInfo(var aBrokerTotalCount,
  aBrokerOffLineCount, aGatewayTotalCount, aGatewayOffLineCount,
  aGatewayDoubtCount, aGatewayUnknowCount, aDeviceTotalCount,
  aDeviceOffLineCount, aDeviceAlarmCount: Integer;
  var aErrorInfo: string): Boolean;
begin
  Result := False;

  BeginRead;
  try
    aBrokerTotalCount := FBrokerTotalCount;
    aBrokerOffLineCount := FBrokerOffLineCount;
    aGatewayTotalCount := FGatewayTotalCount;
    aGatewayOffLineCount := FGatewayOffLineCount;
    aGatewayDoubtCount := FGatewayDoubtCount;
    aGatewayUnknowCount := FGatewayUnknowCount;
    aDeviceTotalCount := FDeviceTotalCount;
    aDeviceOffLineCount := FDeviceOffLineCount;
    aDeviceAlarmCount := FDeviceAlarmCount;

    Result := True;
  finally
    EndRead;
  end;
end;

end.

