unit UDDMeterData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // ����
  TMeterSortData = class
  private
    FSortId: RInteger;   // ���� ID
    FParentId: RInteger; // ���ڵ� ID
    FSortName: RString;  // ��������
  public
    constructor Create;

    property sortId: RInteger read FSortId write FSortId;
    property parentId: RInteger read FParentId write FParentId;
    property sortName: RString read FSortName write FSortName;
  end;

  TMeterSortDataList = class(TObjectList<TMeterSortData>)
  public
    function Add(): TMeterSortData; overload;
  end;

  // ����������
  TMeterData = class
  private
    FMeterId: RInteger;             // ������ ID
    FSortId: RInteger;              // ��� ID
    FMeterCode: RString;            // ��������
    FMeterName: RString;            // ����������
    FMeterNote: RString;            // �����㱸ע
    FMeterVersion: RInteger;        // �汾��
    FMeterRate: RDouble;            // �����㱶��
    FEnergyTypeId: RInteger;        // ��������  (1:��; 2:ˮ ...)
    FEnergyTypeName: RString;       // ������������
    FUnit_en: RString;              // ��λ (Ӣ��)
    FUnit_zh: RString;              // ��λ (����)
    FPayTypeId: RInteger;           // ��������  (1:Ԥ����; 2:�󸶷�)
    FRechargeTypeId: RInteger;      // ��ֵ����  (1:������; 2:����)
    FIsFrmPrice: RBoolean;          // Ӧ�õ���
    FStartTime: RString;            // ����ʱ��  (YYYY-MM-DD hh:mm:ss)
    FStopTime: RString;             // ͣ��ʱ��  (YYYY-MM-DD hh:mm:ss)
    FDevId: RInteger;               // �豸ID
    FDeviceId: RString;             // �豸���
    FMeterValueCode: RString;       // ����ֵ
    FDeviceModel: RString;          // �豸�ͺ�
    FDeviceModelName: RString;      // �豸�ͺ�����
    FDeviceFactoryNo: RString;      // ���ұ��
    FDeviceInstallAddr: RString;    // �豸��װ��ַ
    FDeviceInstallDate: RString;    // �豸��װ����  (YYYY-MM-DD)
    FGatewayDevId: RString;         // �����豸���
    FGatewayModel: RString;         // �����ͺ�
    FGatewayInstallAddr: RString;   // ���ذ�װ��ַ
    FIsVirtual: RBoolean;           // �Ƿ���������
    FOnLine: RBoolean;              // ����
    FLastDataTime: RDateTime;       // ����ϱ�ʱ��
    FLastMeterValue: RDouble;       // ���ʾ��
    FTodayOnLineRate: RDouble;      // ����������
    FHourUse: RString;              // 72Сʱ���� Json
  public
    constructor Create;

    property MeterId: RInteger read FMeterId write FMeterId;
    property SortId: RInteger read FSortId write FSortId;
    property MeterCode: RString read FMeterCode write FMeterCode;
    property MeterName: RString read FMeterName write FMeterName;
    property MeterNote: RString read FMeterNote write FMeterNote;
    property MeterVersion: RInteger read FMeterVersion write FMeterVersion;
    property MeterRate: RDouble read FMeterRate write FMeterRate;
    property EnergyTypeId: RInteger read FEnergyTypeId write FEnergyTypeId;
    property EnergyTypeName: RString read FEnergyTypeName write FEnergyTypeName;
    property unit_en: RString read FUnit_en write FUnit_en;
    property unit_zh: RString read FUnit_zh write FUnit_zh;
    property PayTypeId: RInteger read FPayTypeId write FPayTypeId;
    property RechargeTypeId: RInteger read FRechargeTypeId write FRechargeTypeId;
    property IsFrmPrice: RBoolean read FIsFrmPrice write FIsFrmPrice;
    property StartTime: RString read FStartTime write FStartTime;
    property StopTime: RString read FStopTime write FStopTime;
    property DevId: RInteger read FDevId write FDevId;
    property DeviceId: RString read FDeviceId write FDeviceId;
    property MeterValueCode: RString read FMeterValueCode write FMeterValueCode;
    property DeviceModel: RString read FDeviceModel write FDeviceModel;
    property DeviceModelName: RString read FDeviceModelName write FDeviceModelName;
    property DeviceFactoryNo: RString read FDeviceFactoryNo write FDeviceFactoryNo;
    property DeviceInstallAddr: RString read FDeviceInstallAddr write FDeviceInstallAddr;
    property DeviceInstallDate: RString read FDeviceInstallDate write FDeviceInstallDate;
    property GatewayDevId: RString read FGatewayDevId write FGatewayDevId;
    property GatewayModel: RString read FGatewayModel write FGatewayModel;
    property GatewayInstallAddr: RString read FGatewayInstallAddr write FGatewayInstallAddr;
    property isVirtual: RBoolean read FIsVirtual write FIsVirtual;
    property onLine: RBoolean read FOnLine write FOnLine;
    property lastDataTime: RDateTime read FLastDataTime write FLastDataTime;
    property lastMeterValue: RDouble read FLastMeterValue write FLastMeterValue;
    property todayOnLineRate: RDouble read FTodayOnLineRate write FTodayOnLineRate;
    property hourUse: RString read FHourUse write FHourUse;
  end;

  TMeterDataList = class(TObjectList<TMeterData>)
  public
    function Add(): TMeterData; overload;
  end;

implementation

{ TMeterSortData }
constructor TMeterSortData.Create;
begin
  FSortId.Clear;
  FParentId.Clear;
  FSortName.Clear;
end;

{ TMeterSortDataList }
function TMeterSortDataList.Add(): TMeterSortData;
begin
  Result := TMeterSortData.Create;
  Self.Add(Result);
end;

{ TMeterData }
constructor TMeterData.Create;
begin
  FMeterId.Clear;
  FSortId.Clear;
  FMeterCode.Clear;
  FMeterName.Clear;
  FMeterNote.Clear;
  FMeterVersion.Clear;
  FMeterRate.Clear;
  FEnergyTypeId.Clear;
  FEnergyTypeName.Clear;
  FUnit_en.Clear;
  FUnit_zh.Clear;
  FPayTypeId.Clear;
  FRechargeTypeId.Clear;
  FIsFrmPrice.Clear;
  FStartTime.Clear;
  FStopTime.Clear;
  FDevId.Clear;
  FDeviceId.Clear;
  FMeterValueCode.Clear;
  FDeviceModel.Clear;
  FDeviceModelName.Clear;
  FDeviceFactoryNo.Clear;
  FDeviceInstallAddr.Clear;
  FDeviceInstallDate.Clear;
  FGatewayDevId.Clear;
  FGatewayModel.Clear;
  FGatewayInstallAddr.Clear;
  FIsVirtual.Clear;
  FOnLine.Clear;
  FLastDataTime.Clear;
  FLastMeterValue.Clear;
  FTodayOnLineRate.Clear;
  FHourUse.Clear;
end;

{ TMeterDataList }
function TMeterDataList.Add(): TMeterData;
begin
  Result := TMeterData.Create;
  Self.Add(Result);
end;

end.
