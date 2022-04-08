unit UDDMeterData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // 分类
  TMeterSortData = class
  private
    FSortId: RInteger;   // 分类 ID
    FParentId: RInteger; // 父节点 ID
    FSortName: RString;  // 分类名称
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

  // 计量点数据
  TMeterData = class
  private
    FMeterId: RInteger;             // 计量点 ID
    FSortId: RInteger;              // 类别 ID
    FMeterCode: RString;            // 计量点编号
    FMeterName: RString;            // 计量点名称
    FMeterNote: RString;            // 计量点备注
    FMeterVersion: RInteger;        // 版本号
    FMeterRate: RDouble;            // 计量点倍率
    FEnergyTypeId: RInteger;        // 用能类型  (1:电; 2:水 ...)
    FEnergyTypeName: RString;       // 用能类型名称
    FUnit_en: RString;              // 单位 (英文)
    FUnit_zh: RString;              // 单位 (中文)
    FPayTypeId: RInteger;           // 付费类型  (1:预付费; 2:后付费)
    FRechargeTypeId: RInteger;      // 充值类型  (1:充用量; 2:充金额)
    FIsFrmPrice: RBoolean;          // 应用单价
    FStartTime: RString;            // 启用时间  (YYYY-MM-DD hh:mm:ss)
    FStopTime: RString;             // 停用时间  (YYYY-MM-DD hh:mm:ss)
    FDevId: RInteger;               // 设备ID
    FDeviceId: RString;             // 设备编号
    FMeterValueCode: RString;       // 计量值
    FDeviceModel: RString;          // 设备型号
    FDeviceModelName: RString;      // 设备型号名称
    FDeviceFactoryNo: RString;      // 厂家编号
    FDeviceInstallAddr: RString;    // 设备安装地址
    FDeviceInstallDate: RString;    // 设备安装日期  (YYYY-MM-DD)
    FGatewayDevId: RString;         // 网关设备编号
    FGatewayModel: RString;         // 网关型号
    FGatewayInstallAddr: RString;   // 网关安装地址
    FIsVirtual: RBoolean;           // 是否虚拟网关
    FOnLine: RBoolean;              // 在线
    FLastDataTime: RDateTime;       // 最后上报时间
    FLastMeterValue: RDouble;       // 最后示数
    FTodayOnLineRate: RDouble;      // 今日在线率
    FHourUse: RString;              // 72小时用能 Json
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
