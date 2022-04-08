{
  ��Ԫ: ���˽ṹ���ݵ�Ԫ
  ����: lynch
  ����: 2016-08-02
}

unit UDDTopologyData;

interface

uses
  Classes, SysUtils, Generics.Collections, Generics.Defaults,
  puer.System;

type
  // �豸����
  TDeviceType = (
    dtBroker,     // Broker ����
    dtGateway,    // ͨѶ�豸
    dtDevice,     // �ն��豸
    dtDD          // �ɼ�ƽ̨
  );

  // ͨѶ״̬
  TCommState = (
    csOffLine,    // ����
    csOnLine      // ����
  );

  // �豸״̬
  TDeviceState = (
    dsNormal,     // ����
    dsUnIssue,    // δ�·�
    dsDoubt       // ����
  );

  // �豸������Ϣ
  TTopologyData = class
  private
    Fid: RInteger;             // ���
    FparentId: RInteger;       // ���ڵ���
    Fname: RString;            // ����
    Fnote: RString;            // ��ע
    FcreateTime: RDateTime;    // ����ʱ��
    FdeviceType: TDeviceType;  // �豸����
    FdevId: RString;           // �豸���
    FdevModel: RString;        // �豸�ͺ�
    FdevModelName: RString;    // �豸�ͺ�����
    Fconn: RString;            // ���Ӳ���
    FcommState: TCommState;    // ͨѶ״̬
    FdevState: TDeviceState;   // �豸״̬
    Fdata: RString;            // �豸�Զ�������
    FdoubtInfo: RString;       // ������Ϣ
    FisTemp: RBoolean;         // ��ʱ�ڵ��ʶ
    FisDebug: RBoolean;
    FdebugInfo: RString;
    FsortIndex: RInteger;      // ���
    FisDelete: RBoolean;       // ��ɾ����ʶ
    Fip: RString;              // IP ��ַ
    FdevFactoryNo: RString;    // �豸���ұ��
    FdevInstallDate: RDateTime;// �豸��װ����
    FdevInstallAddr: RString;  // �豸��װ��ַ
    FlngLat: RString;          // ��γ��
    FtodayOnLineRate: RDouble; // ����������
    FisReserve: RBoolean;      // ����
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

    procedure UpdateData; virtual; // ���Զ������JSON���л��� data
    procedure ParseData; virtual;  // ��data �����л�JSON �� �Զ������
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
  // �鷽��
end;

procedure TTopologyData.UpdateData;
begin
  // �鷽��
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


