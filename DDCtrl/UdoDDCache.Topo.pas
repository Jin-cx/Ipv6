(*

  规划调整中，暂未启用

  缓存的作用:
      broker   列表
      gateway  列表
      terminal 列表

      获取单个设备的实时详情

      terminal 订阅用户列表

 *)

unit UdoDDCache.Topo;

interface

uses
  SysUtils, Classes, Generics.Collections,
  puer.System, puer.SyncObjs, puer.Collections, puer.CacheModels,
  UDDDataInter,
  UDDTopologyData, UDDBrokerData, UDDGatewayData, UDDDeviceData;

type
  TDDCacheTopoCtrl = class
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;

    class procedure SetTerminalUsersCacheNeedUpdate;
    class function GetTerminalUserList(const aDevId: Int64;
                                       const aUserCodeList: TStringList): Boolean;
  end;

implementation



type
  TTopoCache = class
  private
    FLock: TPrRWLock;
    FDevIdDict: TDictionary<Int64, TTopologyData>; // 所有设备的 Id 字典
    FDevNoDict: TPrStrDict<TTopologyData>;         // 所有设备的 设备编号 字典

    procedure doClearDevList;                      // 清理列表
  public
    constructor Create;
    destructor Destroy; override;
  end;

  // 终端设备下订阅的用户缓存
  TTerminalUsersCache = class(TPrCache)
  private
    FTerminalList: TDictionary<Int64, TStringList>;
    procedure ClearList;
  protected
    procedure doRefreshData; override;
  public
    constructor Create(const aNeedUpdate: Boolean);
    destructor Destroy; override;

    // 获取终端设备下的用户列表
    function doGetUserList(const aDevId: Int64;
                           const aUserCodeList: TStringList): Boolean;
  end;


{ TTopoCache }
constructor TTopoCache.Create;
begin
  inherited;
  FLock := TPrRWLock.Create;
  FDevIdDict := TDictionary<Int64, TTopologyData>.Create;
  FDevNoDict := TPrStrDict<TTopologyData>.Create;
end;

destructor TTopoCache.Destroy;
begin
  FLock.BeginWrite;
  try
    doClearDevList;
    FDevIdDict.Free;
    FDevNoDict.Free;
  finally
    FLock.Free;
  end;
  inherited;
end;

procedure TTopoCache.doClearDevList;
begin

end;

var
  _TopoCache: TTopoCache;
  _TerminalUsersCache: TTerminalUsersCache;

{ TDDCacheTopoCtrl }
class procedure TDDCacheTopoCtrl.Open;
begin
  _TopoCache := TTopoCache.Create;
  _TerminalUsersCache := TTerminalUsersCache.Create(True);
end;

class function TDDCacheTopoCtrl.Active: Boolean;
begin
  Result := _TopoCache <> nil;
end;

class procedure TDDCacheTopoCtrl.Close;
begin
  _TerminalUsersCache.Free;
  _TopoCache.Free;
end;

class procedure TDDCacheTopoCtrl.SetTerminalUsersCacheNeedUpdate;
begin
  _TerminalUsersCache.SetNeedUpdate;
end;

class function TDDCacheTopoCtrl.GetTerminalUserList(const aDevId: Int64;
  const aUserCodeList: TStringList): Boolean;
begin
  Result := _TerminalUsersCache.doGetUserList(aDevId, aUserCodeList);
end;

{ TTerminalUsersCache }
constructor TTerminalUsersCache.Create(const aNeedUpdate: Boolean);
begin
  inherited Create(aNeedUpdate);
  FTerminalList := TDictionary<Int64, TStringList>.Create;
end;

destructor TTerminalUsersCache.Destroy;
begin
  ClearList;
  FTerminalList.Free;
  inherited;
end;

procedure TTerminalUsersCache.ClearList;
var
  aUserList: TStringList;
begin
  for aUserList in FTerminalList.Values do
    aUserList.Free;
  FTerminalList.Clear;
end;

procedure TTerminalUsersCache.doRefreshData;
var
  aDevUserCodeList, aUserCodeList: TStringList;
  aDevId: Int64;
  aLine: string;
  aErrorInfo: string;
begin
  inherited;
  aDevUserCodeList := TStringList.Create;
  try
    if not _DDDataInter._doGetSubscribeTerminalUserList(aDevUserCodeList, aErrorInfo) then
      raise Exception.Create(aErrorInfo);

    ClearList;

    for aLine in aDevUserCodeList do
    begin
      aUserCodeList := TStringList.Create;
      aUserCodeList.CommaText := aLine;
      aDevId := StrToInt(aUserCodeList[0]);
      aUserCodeList.Delete(0);
      FTerminalList.AddOrSetValue(aDevId, aUserCodeList);
    end;
  finally
    aDevUserCodeList.Free;
  end;
end;

function TTerminalUsersCache.doGetUserList(const aDevId: Int64;
  const aUserCodeList: TStringList): Boolean;
var
  aUserList: TStringList;
begin
  Result := False;

  BeginRead;
  try
    if FTerminalList.TryGetValue(aDevId, aUserList) then
    begin
      aUserCodeList.AddStrings(aUserList);

      Result := True;
    end;
  finally
    EndRead;
  end;
end;

end.
