unit UDDCustomDeviceData;

interface

uses
  puer.System;

type
  // 设备状态
  TDeviceState = (
    dsNone,        // 无
    dsOnLine,      // 在线
    dsOffLine,     // 离线
    dsDoubt,       // 置疑

    dsXXXX
  );

  // 设备类型
  TDeviceType = (
    dtBroker,      // Broker
    dtGateway,     // 网关
    dtDevice       // 终端设备
  );

  // 设备基础信息
  TCustomDeviceData = class
  private
    Fid: RInteger;            // 编号
    Fname: RString;           // 名称
    Fnote: RString;           // 备注
    FdevId: RString;          // 设备编号
    FcreateTime: RDateTime;   // 创建时间
    FdeviceType: TDeviceType; // 设备类型
    FdevState: TDeviceState;  // 状态
  public
    constructor Create;

    property id: RInteger read Fid write Fid;
    property name: RString read Fname write Fname;
    property note: RString read Fnote write Fnote;
    property devId: RString read FdevId write FdevId;
    property createTime: RDateTime read FcreateTime write FcreateTime;
    property deviceType: TDeviceType read FdeviceType write FdeviceType;
    property devState: TDeviceState read FdevState write FdevState;
  end;

implementation

{ TCustomDeviceData }
constructor TCustomDeviceData.Create;
begin
  Fid.Clear;
  Fname.Clear;
  Fnote.Clear;
  FdevId.Clear;
  FcreateTime.Clear;
end;

end.
