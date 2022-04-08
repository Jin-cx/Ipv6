{
  单元: 拓扑结构数据单元
  作者: lynch
  日期: 2016-08-02
}

unit UDDTopologyData;

interface

uses
  Classes, SysUtils, Generics.Collections, Generics.Defaults,
  puer.System;

type
  // 设备类型
  TDeviceType = (
    dtBroker,     // Broker 服务
    dtGateway,    // 通讯设备
    dtDevice,     // 终端设备
    dtDD          // 采集平台
  );

  // 通讯状态
  TCommState = (
    csOffLine,    // 离线
    csOnLine      // 在线
  );

  // 设备状态
  TDeviceState = (
    dsNormal,     // 正常
    dsUnIssue,    // 未下发
    dsDoubt       // 置疑
  );

  // 设备基础信息
  TTopologyData = class
  private
    Fid: RInteger;             // 编号
    FparentId: RInteger;       // 父节点编号
    Fname: RString;            // 名称
    Fnote: RString;            // 备注
    FcreateTime: RDateTime;    // 创建时间
    FdeviceType: TDeviceType;  // 设备类型
    FdevId: RString;           // 设备编号
    FdevModel: RString;        // 设备型号
    FdevModelName: RString;    // 设备型号名称
    Fconn: RString;            // 链接参数
    FcommState: TCommState;    // 通讯状态
    FdevState: TDeviceState;   // 设备状态
    Fdata: RString;            // 设备自定义数据
    FdoubtInfo: RString;       // 置疑信息
    FisTemp: RBoolean;         // 临时节点标识
    FisDebug: RBoolean;
    FdebugInfo: RString;
    FsortIndex: RInteger;      // 序号
    FisDelete: RBoolean;       // 被删除标识
    Fip: RString;              // IP 地址
    FdevFactoryNo: RString;    // 设备厂家编号
    FdevInstallDate: RDateTime;// 设备安装日期
    FdevInstallAddr: RString;  // 设备安装地址
    FlngLat: RString;          // 经纬度
    FtodayOnLineRate: RDouble; // 今日在线率
    FisReserve: RBoolean;      // 备用
  public
    constructor Create;

    property id: RInteger read Fid write Fid;
    property parentId: RInteger read FparentId write FparentId;
    property name: RString read Fname write Fname;
    property note: RString read Fnote write Fnote;
    property createTime: RDateTime read FcreateTime write FcreateTime;
    property deviceType: TDeviceType read FdeviceType write FdeviceType;
    property devId: RString read FdevId write FdevId;
    property conn: RString read Fconn write Fconn;
    property commState: TCommState read FcommState write FcommState;
    property devState: TDeviceState read FdevState write FdevState;
    property devModel: RString read FdevModel write FdevModel;
    property devModelName: RString read FdevModelName write FdevModelName;
    property data: RString read Fdata write Fdata;
    property doubtInfo: RString read FdoubtInfo write FdoubtInfo;
    property isTemp: RBoolean read FisTemp write FisTemp;
    property sortIndex: RInteger read FsortIndex write FsortIndex;
    property isDelete: RBoolean read FisDelete write FisDelete;
    property ip: RString read Fip write Fip;
    property devFactoryNo: RString read FdevFactoryNo write FdevFactoryNo;
    property devInstallDate: RDateTime read FdevInstallDate write FdevInstallDate;
    property devInstallAddr: RString read FdevInstallAddr write FdevInstallAddr;
    property lngLat: RString read FlngLat write FlngLat;
    property todayOnLineRate: RDouble read FtodayOnLineRate write FtodayOnLineRate;
    property isReserve: RBoolean read FisReserve write FisReserve;
    property isDebug: RBoolean read FisDebug write FisDebug;
    property debugInfo: RString read FdebugInfo write FdebugInfo;

    procedure Assign(const aTopologyData: TTopologyData);
    procedure AssignTo(const aTopologyData: TTopologyData);
    procedure UpdateFrom(const aTopologyData: TTopologyData);

    procedure UpdateData; virtual; // 将自定义变量JSON序列化到 data
    procedure ParseData; virtual;  // 从data 反序列化JSON 到 自定义变量
  end;

  TTopologyDataList = class(TObjectList<TTopologyData>)
  public
    function Add(): TTopologyData; overload;
    procedure Assign(const aTopologyDataList: TTopologyDataList);
    procedure SortBySortIndex;
  end;

  TTopologyComparer = class(TComparer<TTopologyData>)
  public
    function Compare(const Left, Right: TTopologyData): Integer; override;
  end;

implementation

{ TTopologyData }
constructor TTopologyData.Create;
begin
  Fid.Clear;
  FparentId.Clear;
  Fname.Clear;
  Fnote.Clear;
  FcreateTime.Clear;
  FdevId.Clear;
  FdevModel.Clear;
  FdevModelName.Clear;
  Fconn.Clear;
  Fdata.Clear;
  FdoubtInfo.Clear;
  FisTemp.Clear;
  FsortIndex.Clear;
  FisDelete.Clear;
  Fip.Clear;
  FdevFactoryNo.Clear;
  FdevInstallDate.Clear;
  FdevInstallAddr.Clear;
  FlngLat.Clear;
  FtodayOnLineRate.Clear;
end;

procedure TTopologyData.Assign(const aTopologyData: TTopologyData);
begin
  if aTopologyData = nil then
    Exit;

  Self.id := aTopologyData.id;
  Self.parentId := aTopologyData.parentId;
  Self.name := aTopologyData.name;
  Self.note := aTopologyData.note;
  Self.createTime := aTopologyData.createTime;
  Self.deviceType := aTopologyData.deviceType;
  Self.devId := aTopologyData.devId;
  Self.conn := aTopologyData.conn;
  Self.commState := aTopologyData.commState;
  Self.devState := aTopologyData.devState;
  Self.devModel := aTopologyData.devModel;
  Self.devModelName := aTopologyData.devModelName;
  Self.data := aTopologyData.data;
  Self.doubtInfo := aTopologyData.doubtInfo;
  Self.isTemp := aTopologyData.isTemp;
  Self.sortIndex := aTopologyData.sortIndex;
  Self.ip := aTopologyData.ip;

  Self.devFactoryNo := aTopologyData.devFactoryNo;
  Self.devInstallDate := aTopologyData.devInstallDate;
  Self.devInstallAddr := aTopologyData.devInstallAddr;
  Self.lngLat := aTopologyData.lngLat;
  Self.todayOnLineRate := aTopologyData.todayOnLineRate;

  Self.isReserve := aTopologyData.isReserve;

  Self.isDebug := aTopologyData.isDebug;
  Self.debugInfo := aTopologyData.debugInfo;

  ParseData;
end;

procedure TTopologyData.AssignTo(const aTopologyData: TTopologyData);
begin
  UpdateData;

  aTopologyData.Assign(Self);
end;

procedure TTopologyData.ParseData;
begin
  // 虚方法
end;

procedure TTopologyData.UpdateData;
begin
  // 虚方法
end;

procedure TTopologyData.UpdateFrom(const aTopologyData: TTopologyData);
begin
  if aTopologyData = nil then
    Exit;

  Self.parentId := aTopologyData.parentId;
  Self.name := aTopologyData.name;
  Self.note := aTopologyData.note;
  Self.devId := aTopologyData.devId;
  Self.devModel := aTopologyData.devModel;
  Self.conn := aTopologyData.conn;

  Self.devInstallDate := aTopologyData.devInstallDate;
  Self.devInstallAddr := aTopologyData.devInstallAddr;
  Self.lngLat := aTopologyData.lngLat;
  Self.todayOnLineRate := aTopologyData.todayOnLineRate;

  Self.isDebug := aTopologyData.isDebug;
  Self.debugInfo := aTopologyData.debugInfo;

  Self.data := aTopologyData.data;
  Self.ParseData;
end;

{ TTopologyDataList }
function TTopologyDataList.Add(): TTopologyData;
begin
  Result := TTopologyData.Create;
  Self.Add(Result);
end;

procedure TTopologyDataList.Assign(const aTopologyDataList: TTopologyDataList);
var
  aTopologyData: TTopologyData;
begin
  if aTopologyDataList = nil then
    Exit;

  Self.Clear;

  for aTopologyData in aTopologyDataList do
    Self.Add.Assign(aTopologyData);
end;

procedure TTopologyDataList.SortBySortIndex;
var
  aComparer: TTopologyComparer;
begin
  aComparer := TTopologyComparer.Create;
  try
    Self.Sort(aComparer);
  finally
    aComparer.Free;
  end;
end;

{ TTopologyComparer }
function TTopologyComparer.Compare(const Left, Right: TTopologyData): Integer;

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


