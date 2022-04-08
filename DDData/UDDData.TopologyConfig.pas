{
  单元: 拓扑结构存储管理单元
  作者: lynch
  日期: 2016-08-18
}

unit UDDData.TopologyConfig;

interface

uses
  Classes, SysUtils, Generics.Collections, Windows,
  puer.System, puer.SyncObjs, puer.Json.JsonDataObjects,
  puer.FileUtils, puer.SQLite,
  UDDTopologyData, UDDTopologyDataJson, UDDDeviceData;

type
  TTopologyConfigCtrl = class
  public
    class procedure Open(const aConfigPath: string);
    class procedure Close;
    class function Active: Boolean;
  end;

// 取拓扑结构列表
procedure doGetTopologyList(const aTopologyDataList: TTopologyDataList); stdcall;
// 添加拓扑节点
function doAddTopology(const aTopologyData: TTopologyData;
                       var aErrorInfo: string): Boolean; stdcall;
// 添加网关如果设备编号不存在
function doAddGatewayIfDevIdNotExist(const aTopologyData: TTopologyData): Boolean; stdcall;
// 更新拓扑节点
function doUpdateTopology(const aTopologyData: TTopologyData;
                          var aErrorInfo: string): Boolean; stdcall;
// 删除拓扑节点 (单个)
function doDeleteTopology(const aTopologyId: RInteger;
                          var aErrorInfo: string): Boolean; stdcall;
// 删除拓扑节点 (批量)
function doDeleteTopologys(const aTopologyIdList: TArray<RInteger>;
                           var aErrorInfo: string): Boolean; stdcall;
// 排序拓扑节点
function doSortTopologys(const aTopologyIdList: TArray<RInteger>;
                         var aErrorInfo: string): Boolean; stdcall;
// 设置拓扑节点状态
procedure doSetTopoDevState(const aTopologyId: Int64;
                            const aDevState: TDeviceState); stdcall;
// 设置拓扑节点 IP
function doUpdateTopologyIp(const aTopologyId: Int64;
                            const aIp: string;
                            var aErrorInfo: string): Boolean; stdcall;

// 设置设备计量点编号
function doSetDeviceMeterCode(const aTopologyId: Int64;
                              const aMeterCode: string;
                              var aErrorInfo: string): Boolean; stdcall;

// 备份扑结构列表
procedure doBackupTopology; stdcall;
// 保存扑结构列表到流
procedure doSaveTopologyToStream(const aStream: TStream); stdcall;
// 保存扑结构列表到文件
procedure doSaveTopologyToFile(const aFileName: string); stdcall;

{exports
  doGetTopologyList,
  doAddTopology,
  doAddGatewayIfDevIdNotExist,
  doUpdateTopology,
  doDeleteTopology,
  doDeleteTopologys,
  doSortTopologys,
  doSetTopoDevState,
  doUpdateTopologyIp,
  doBackupTopology,
  doSaveTopologyToStream,
  doSaveTopologyToFile,
  doSetDeviceMeterCode; }

implementation

const
  TOPOLOGY_CONFIG_FILE_NAME        = 'topology.cfg';
  TOPOLOGY_CONFIG_BACKUP_FILE_NAME = 'backup\topology_%s.cfg';

  ERROR_NAME_NOT_NULL       = '设备名称不可为空！';
  ERROR_TOPOLOGY_NOT_EXISTS = '指定的设备不存在！';
  ERROR_PARENT_NOT_EXISTS   = '所属上级设备不存在！';
  ERROR_PARENT_NOT_SUPPORT  = '所属上级设备不支持本设备类型！';

type
  TTopologyConfig = class
  private
    FLock: TPrRWLock;
    FConfigPath: string;
    FFileName: string;
    FNextId: Int64;
    FTopologyList: TTopologyDataListJson;
    FTopologyDict: TDictionary<Int64, TTopologyData>;
    procedure SaveTopologyConfig;
    procedure LoadTopologyConfig;

    procedure doSaveToFile(const aFileName: string);
    procedure doSaveToStream(const aStream: TStream);

    procedure CreateCache;
    procedure FreeCache;

    function GetNextId: Int64;

    function TryFindTopology(const aTopoId: Int64;
                             var aTopoData: TTopologyData): Boolean; overload;
    function TryFindTopology(const aTopoId: RInteger;
                             var aTopoData: TTopologyData): Boolean; overload;
  public
    constructor Create(const aConfigPath: string); overload;
    destructor Destroy; override;

    procedure CopyTopologyListTo(const aTopologyDataList: TTopologyDataList);
    function AddTopology(const aTopologyData: TTopologyData;
                         var aErrorInfo: string): Boolean;
    function AddGatewayIfDevIdNotExist(const aTopologyData: TTopologyData): Boolean;
    function UpdateTopology(const aTopologyData: TTopologyData;
                            var aErrorInfo: string): Boolean;
    function DeleteTopology(const aTopologyId: RInteger;
                            var aErrorInfo: string): Boolean;
    function DeleteTopologys(const aTopologyIdList: TArray<RInteger>;
                             var aErrorInfo: string): Boolean;
    function SortTopologys(const aTopologyIdList: TArray<RInteger>;
                           var aErrorInfo: string): Boolean;

    function SetDeviceMeterCode(const aTopologyId: Int64;
                                const aMeterCode: string;
                                var aErrorInfo: string): Boolean;

    procedure SetTopoDevState(const aTopoId: Int64;
                              const aDevState: TDeviceState);
    procedure UpdateTopologyIp(const aTopologyId: Int64;
                               const aIp: string);

    procedure BackupTopology;

    procedure SaveToFile(const aFileName: string);
    procedure SaveToStream(const aStream: TStream);
  end;

var
  _TopologyConfig: TTopologyConfig;
  _HasOpen: Boolean;

procedure doGetTopologyList(const aTopologyDataList: TTopologyDataList);
begin
  _TopologyConfig.CopyTopologyListTo(aTopologyDataList);
end;

function doAddTopology(const aTopologyData: TTopologyData;
                       var aErrorInfo: string): Boolean;
begin
  Result := _TopologyConfig.AddTopology(aTopologyData, aErrorInfo);
end;

function doAddGatewayIfDevIdNotExist(const aTopologyData: TTopologyData): Boolean;
begin
  Result := _TopologyConfig.AddGatewayIfDevIdNotExist(aTopologyData);
end;

function doUpdateTopology(const aTopologyData: TTopologyData;
                          var aErrorInfo: string): Boolean;
begin
  Result := _TopologyConfig.UpdateTopology(aTopologyData, aErrorInfo);
end;

function doDeleteTopology(const aTopologyId: RInteger;
                          var aErrorInfo: string): Boolean;
begin
  Result := _TopologyConfig.DeleteTopology(aTopologyId, aErrorInfo);
end;

function doDeleteTopologys(const aTopologyIdList: TArray<RInteger>;
                           var aErrorInfo: string): Boolean;
begin
  Result := _TopologyConfig.DeleteTopologys(aTopologyIdList, aErrorInfo);
end;

function doSortTopologys(const aTopologyIdList: TArray<RInteger>;
                         var aErrorInfo: string): Boolean;
begin
  Result := _TopologyConfig.SortTopologys(aTopologyIdList, aErrorInfo);
end;

procedure doSetTopoDevState(const aTopologyId: Int64;
                            const aDevState: TDeviceState);
begin
  _TopologyConfig.SetTopoDevState(aTopologyId, aDevState);
end;

function doUpdateTopologyIp(const aTopologyId: Int64;
                            const aIp: string;
                            var aErrorInfo: string): Boolean;
begin
  Result := True;
  _TopologyConfig.UpdateTopologyIp(aTopologyId, aIp);
end;

function doSetDeviceMeterCode(const aTopologyId: Int64;
                              const aMeterCode: string;
                              var aErrorInfo: string): Boolean;
begin
  Result := _TopologyConfig.SetDeviceMeterCode(aTopologyId, aMeterCode, aErrorInfo);
end;

procedure doBackupTopology;
begin
  _TopologyConfig.BackupTopology;
end;

procedure doSaveTopologyToStream(const aStream: TStream);
begin
  _TopologyConfig.SaveToStream(aStream);
end;

procedure doSaveTopologyToFile(const aFileName: string);
begin
  _TopologyConfig.SaveToFile(aFileName);
end;

{ TTopologyConfigCtrl }
class procedure TTopologyConfigCtrl.Open(const aConfigPath: string);
begin
  _HasOpen := False;
  _TopologyConfig := TTopologyConfig.Create(aConfigPath);
  _HasOpen := True;
end;

class procedure TTopologyConfigCtrl.Close;
begin
  _HasOpen := False;
  _TopologyConfig.Free;
end;

class function TTopologyConfigCtrl.Active: Boolean;
begin
  Result := _HasOpen;
end;

{ TTopologyConfig }
constructor TTopologyConfig.Create(const aConfigPath: string);
begin
  inherited Create;
  FConfigPath := aConfigPath;
  FFileName := aConfigPath + TOPOLOGY_CONFIG_FILE_NAME;
  CreateCache;
  LoadTopologyConfig;
  FLock := TPrRWLock.Create;
end;

destructor TTopologyConfig.Destroy;
begin
  FLock.BeginWrite;
  try
    FreeCache;
  finally
    FLock.EndWrite;
    FLock.Free;
  end;
  inherited;
end;

procedure TTopologyConfig.CreateCache;
begin
  FNextId := 1;
  FTopologyList := TTopologyDataListJson.Create;
  FTopologyDict := TDictionary<Int64, TTopologyData>.Create;
end;

procedure TTopologyConfig.FreeCache;
begin
  if FTopologyList <> nil then
    FTopologyList.Free;
  if FTopologyDict <> nil then
    FTopologyDict.Free;
end;

function TTopologyConfig.GetNextId: Int64;
begin
  Result := FNextId;
  Inc(FNextId);
end;

procedure TTopologyConfig.LoadTopologyConfig;
var
  aJson: TJsonArray;
  aTopologyData: TTopologyData;
begin
  if FileExists(FFileName) then
  begin
    aJson := TJsonArray.Create;
    try
      aJson.LoadFromFile(FFileName);
      FTopologyList.LoadFromJson(aJson);
      if FTopologyList.Count <> 0 then
      begin
        for aTopologyData in FTopologyList do
          FTopologyDict.AddOrSetValue(aTopologyData.id.Value, aTopologyData);
        FNextId := FTopologyList.Last.id.Value + 1;
      end;
    finally
      aJson.Free;
    end;
  end;
end;

procedure TTopologyConfig.SaveTopologyConfig;
begin
  doSaveToFile(FFileName);
end;

procedure TTopologyConfig.doSaveToFile(const aFileName: string);
var
  aDir: string;
  aJson: TJsonArray;
  aTopologyData: TTopologyData;
begin
  aDir := ExtractFileDir(aFileName);
  if not DirectoryExists(aDir) and not ForceDirectories(aDir) then
    Exit;

  aJson := TJsonArray.Create;
  try
    for aTopologyData in FTopologyList do
      if not aTopologyData.isTemp.IsTrue then
        aJson.Add(TTopologyDataJson(aTopologyData).AsJson);

    aJson.SaveToFile(aFileName);
  finally
    aJson.Free;
  end;
end;

procedure TTopologyConfig.doSaveToStream(const aStream: TStream);
var
  aJson: TJsonArray;
begin
  aJson := FTopologyList.AsJson;
  try
    aJson.SaveToStream(aStream);
  finally
    aJson.Free;
  end;
end;

procedure TTopologyConfig.CopyTopologyListTo(const aTopologyDataList: TTopologyDataList);
begin
  FLock.BeginRead;
  try
    aTopologyDataList.Assign(FTopologyList);
  finally
    FLock.EndRead;
  end;
end;

function TTopologyConfig.AddTopology(const aTopologyData: TTopologyData;
                                     var aErrorInfo: string): Boolean;
var
  aNewTopology: TTopologyData;
  aParentTopo: TTopologyData;
begin
  Result := False;

  FLock.BeginWrite;
  try
    // 名称不可空
    if Trim(aTopologyData.name.AsString) = '' then
    begin
      aErrorInfo := ERROR_NAME_NOT_NULL;
      Exit;
    end;

    // 检查上级设备存在和类型
    if aTopologyData.deviceType <> dtBroker then
    begin
      if not TryFindTopology(aTopologyData.parentId, aParentTopo) then
      begin
        aErrorInfo := ERROR_PARENT_NOT_EXISTS;
        Exit;
      end;

      if ((aTopologyData.deviceType = dtGateway) and (aParentTopo.deviceType <> dtBroker))
         or
         ((aTopologyData.deviceType = dtDevice) and (aParentTopo.deviceType <> dtGateway)) then
      begin
        aErrorInfo := ERROR_PARENT_NOT_SUPPORT;
        Exit;
      end;
    end;

    aTopologyData.id.Value := GetNextId;
    aTopologyData.createTime := RDateTime.Parse(Now);
    aTopologyData.sortIndex := aTopologyData.id;

    aNewTopology := FTopologyList.Add;
    aNewTopology.Assign(aTopologyData);


    FTopologyDict.Add(aNewTopology.id.Value, aNewTopology);

    if not aNewTopology.isTemp.IsTrue then
      SaveTopologyConfig;

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyConfig.AddGatewayIfDevIdNotExist(const aTopologyData: TTopologyData): Boolean;
var
  aNewTopology, aParentTopo, aTmpTopo: TTopologyData;
begin
  Result := False;

  if Trim(aTopologyData.devId.AsString) = '' then
    Exit;
  if Trim(aTopologyData.name.AsString) = '' then
    Exit;

  FLock.BeginWrite;
  try
    if not TryFindTopology(aTopologyData.parentId, aParentTopo) then
      Exit;
    if aParentTopo.deviceType <> dtBroker then
      Exit;

    for aTmpTopo in FTopologyList do
    begin
      if aTmpTopo.parentId.IsNull then
        Continue;

      if (aTmpTopo.parentId.Value = aTopologyData.parentId.Value) and
         (aTmpTopo.devId.AsString = aTopologyData.devId.AsString) then
        Exit;
    end;

    aTopologyData.id.Value := GetNextId;
    aTopologyData.createTime := RDateTime.Parse(Now);
    aTopologyData.sortIndex := aTopologyData.id;

    aNewTopology := FTopologyList.Add;
    aNewTopology.Assign(aTopologyData);

    FTopologyDict.Add(aNewTopology.id.Value, aNewTopology);

    if not aNewTopology.isTemp.IsTrue then
      SaveTopologyConfig;

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyConfig.UpdateTopology(const aTopologyData: TTopologyData;
                                        var aErrorInfo: string): Boolean;
var
  aOldTopology: TTopologyData;
begin
  Result := False;

  FLock.BeginWrite;
  try
    // 名称不可空
    {if Trim(aTopologyData.name) = '' then
    begin
      aErrorInfo := ERROR_NAME_NOT_NULL;
      Exit;
    end;}

    if TryFindTopology(aTopologyData.id, aOldTopology) then
    begin
      // 编辑
      //aOldTopology.parentId := aTopologyData.parentId;
      aOldTopology.name := aTopologyData.name;
      aOldTopology.note := aTopologyData.note;
      aOldTopology.data := aTopologyData.data;
      aOldTopology.conn := aTopologyData.conn;
      //aOldTopology.deviceType := aTopologyData.deviceType;
      aOldTopology.devId := aTopologyData.devId;
      aOldTopology.devModel := aTopologyData.devModel;
      aOldTopology.isTemp := aTopologyData.isTemp;



      // 保存配置文件
      if not aOldTopology.isTemp.IsTrue then
        SaveTopologyConfig;

      Result := True;
    end
    else
      aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyConfig.DeleteTopology(const aTopologyId: RInteger;
                                        var aErrorInfo: string): Boolean;

  procedure doAddToList(const aTopoIdList: TList<RInteger>; const aTopologyId: RInteger);
  var
    aTopo: TTopologyData;
  begin
    aTopoIdList.Add(aTopologyId);
    for aTopo in FTopologyList do
      if aTopo.parentId.Equals(aTopologyId) then
        doAddToList(aTopoIdList, aTopo.id);
  end;

var
  aTopologyData: TTopologyData;
  aTopoIdList: TList<RInteger>;
begin
  Result := False;

  aTopoIdList := TList<RInteger>.Create;
  try
    FLock.BeginWrite;
    try
      if not TryFindTopology(aTopologyId, aTopologyData) then
      begin
        aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
        Exit;
      end;

      doAddToList(aTopoIdList, aTopologyId);
    finally
      FLock.EndWrite;
    end;

    Result := DeleteTopologys(aTopoIdList.ToArray, aErrorInfo);
  finally
    aTopoIdList.Free;
  end;
end;

function TTopologyConfig.DeleteTopologys(const aTopologyIdList: TArray<RInteger>;
                                         var aErrorInfo: string): Boolean;
var
  aTopologyData: TTopologyData;
  aTopologyId: RInteger;
  aHasChanged: Boolean;
begin
  FLock.BeginWrite;
  try
    aHasChanged := False;
    for aTopologyId in aTopologyIdList do
      if TryFindTopology(aTopologyId, aTopologyData) then
      begin
        // 删除
        FTopologyList.Remove(aTopologyData);
        FTopologyDict.Remove(aTopologyId.Value);

        aHasChanged := True;
      end;

    // 保存配置文件
    if aHasChanged then
      SaveTopologyConfig;

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyConfig.SortTopologys(const aTopologyIdList: TArray<RInteger>;
                                       var aErrorInfo: string): Boolean;
var
  aTopologyData: TTopologyData;
  aTopologyId: RInteger;
  aHasChanged: Boolean;
  aSortIndex: Integer;
begin
  FLock.BeginWrite;
  try
    aHasChanged := False;
    aSortIndex := 1;
    for aTopologyId in aTopologyIdList do
      if TryFindTopology(aTopologyId, aTopologyData) then
      begin
        aTopologyData.sortIndex := RInteger.Parse(aSortIndex);
        Inc(aSortIndex);

        aHasChanged := True;
      end;

    // 保存配置文件
    if aHasChanged then
      SaveTopologyConfig;

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

function TTopologyConfig.SetDeviceMeterCode(const aTopologyId: Int64;
                                            const aMeterCode: string;
                                            var aErrorInfo: string): Boolean;
var
  aOldTopology: TTopologyData;
  aDeviceData: TDeviceData;
begin
  Result := False;

  FLock.BeginWrite;
  try
    if not TryFindTopology(aTopologyId, aOldTopology) then
    begin
      aErrorInfo := ERROR_TOPOLOGY_NOT_EXISTS;
      Exit;
    end;

    aDeviceData := TDeviceData.Create;
    try
      aDeviceData.Assign(aOldTopology);
      aDeviceData.meterCode.Value := aMeterCode;
      aDeviceData.AssignTo(aOldTopology);
    finally
      aDeviceData.Free;
    end;

    // 保存配置文件
    if not aOldTopology.isTemp.IsTrue then
      SaveTopologyConfig;

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyConfig.SetTopoDevState(const aTopoId: Int64;
                                          const aDevState: TDeviceState);
var
  aTopoData: TTopologyData;
begin
  FLock.BeginWrite;
  try
    if TryFindTopology(aTopoId, aTopoData) then
    begin
      aTopoData.devState := aDevState;
      if aDevState = dsUnIssue then
        aTopoData.isTemp.Value := False;
      SaveTopologyConfig;
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyConfig.UpdateTopologyIp(const aTopologyId: Int64;
                                           const aIp: string);
var
  aTopoData: TTopologyData;
begin
  FLock.BeginWrite;
  try
    if TryFindTopology(aTopologyId, aTopoData) then
    begin
      aTopoData.ip.Value := aIp;
      SaveTopologyConfig;
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTopologyConfig.BackupTopology;
var
  aFileName: string;
begin
  FLock.BeginRead;
  try
    aFileName := FConfigPath + Format(TOPOLOGY_CONFIG_BACKUP_FILE_NAME, [DateTimeToStr(Now)]);
    doSaveToFile(aFileName);
  finally
    FLock.EndRead;
  end;
end;

procedure TTopologyConfig.SaveToFile(const aFileName: string);
begin
  FLock.BeginRead;
  try
    doSaveToFile(aFileName);
  finally
    FLock.EndRead;
  end;
end;

procedure TTopologyConfig.SaveToStream(const aStream: TStream);
begin
  FLock.BeginRead;
  try
    doSaveToStream(aStream);
  finally
    FLock.EndRead;
  end;
end;

function TTopologyConfig.TryFindTopology(const aTopoId: Int64;
                                         var aTopoData: TTopologyData): Boolean;
begin
  Result := FTopologyDict.TryGetValue(aTopoId, aTopoData);
end;

function TTopologyConfig.TryFindTopology(const aTopoId: RInteger;
                                         var aTopoData: TTopologyData): Boolean;
begin
  Result := False;
  if aTopoId.IsNull then
    Exit;

  Result := TryFindTopology(aTopoId.Value, aTopoData);
end;

end.
