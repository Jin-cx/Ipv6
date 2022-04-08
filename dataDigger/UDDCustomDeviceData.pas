unit UDDCustomDeviceData;

interface

uses
  puer.System;

type
  // �豸״̬
  TDeviceState = (
    dsNone,        // ��
    dsOnLine,      // ����
    dsOffLine,     // ����
    dsDoubt,       // ����

    dsXXXX
  );

  // �豸����
  TDeviceType = (
    dtBroker,      // Broker
    dtGateway,     // ����
    dtDevice       // �ն��豸
  );

  // �豸������Ϣ
  TCustomDeviceData = class
  private
    Fid: RInteger;            // ���
    Fname: RString;           // ����
    Fnote: RString;           // ��ע
    FdevId: RString;          // �豸���
    FcreateTime: RDateTime;   // ����ʱ��
    FdeviceType: TDeviceType; // �豸����
    FdevState: TDeviceState;  // ״̬
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
