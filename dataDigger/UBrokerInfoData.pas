unit UBrokerInfoData;

interface

uses
  Classes, SysUtils, Generics.Collections,
  puer.System;

type
  // 采集器信息
  TBrokerInfoData = class
  private
    FdevId: RInteger;          // 编号
    FdevName: RString;         // 名称
    FdevNo: RString;           // 设备编号
    FdevModel: RString;        // 设备型号
    FdevModelName: RString;    // 设备型号名称
    FdevFactoryNo: RString;    // 设备厂家编号
    FdevInstallAddr: RString;  // 设备安装地址
    FlngLat: RString;          // 经纬度
    FonLine: RBoolean;         // 当前在线
    FtodayOnLineRate: RDouble; // 今日在线率
    FgatewayCount: RInteger;            // 网关数量
    FgatewayOnLineCount: RInteger;      // 网关在线数量
    FgatewayOnLineRate: RDouble;        // 网关在线率
    FgatewayTodayOnLineRate: RDouble;   // 网关今日在线率
    FterminalCount: RInteger;           // 终端数量
    FterminalOnLineCount: RInteger;     // 终端在线数量
    FterminalOnLineRate: RDouble;       // 终端在线率
    FterminalTodayOnLineRate: RDouble;  // 网关今日在线率
  public
    constructor Create;

    property devId: RInteger read FdevId write FdevId;
    property devName: RString read FdevName write FdevName;
    property devNo: RString read FdevNo write FdevNo;
    property devModel: RString read FdevModel write FdevModel;
    property devModelName: RString read FdevModelName write FdevModelName;
    property devFactoryNo: RString read FdevFactoryNo write FdevFactoryNo;
    property devInstallAddr: RString read FdevInstallAddr write FdevInstallAddr;
    property lngLat: RString read FlngLat write FlngLat;
    property onLine: RBoolean read FonLine write FonLine;
    property todayOnLineRate: RDouble read FtodayOnLineRate write FtodayOnLineRate;
    property gatewayCount: RInteger read FgatewayCount write FgatewayCount;
    property gatewayOnLineCount: RInteger read FgatewayOnLineCount write FgatewayOnLineCount;
    property gatewayOnLineRate: RDouble read FgatewayOnLineRate write FgatewayOnLineRate;
    property gatewayTodayOnLineRate: RDouble read FgatewayTodayOnLineRate write FgatewayTodayOnLineRate;
    property terminalCount: RInteger read FterminalCount write FterminalCount;
    property terminalOnLineCount: RInteger read FterminalOnLineCount write FterminalOnLineCount;
    property terminalOnLineRate: RDouble read FterminalOnLineRate write FterminalOnLineRate;
    property terminalTodayOnLineRate: RDouble read FterminalTodayOnLineRate write FterminalTodayOnLineRate;
  end;

  TBrokerInfoDataList = class(TObjectList<TBrokerInfoData>)
  public
    function Add(): TBrokerInfoData; overload;
  end;

implementation

{ TBrokerInfoData }
constructor TBrokerInfoData.Create;
begin
  FdevId.Clear;
  FdevName.Clear;
  FdevNo.Clear;
  FdevModel.Clear;
  FdevModelName.Clear;
  FdevFactoryNo.Clear;
  FdevInstallAddr.Clear;
  FlngLat.Clear;
  FonLine.Clear;
  FtodayOnLineRate.Clear;
  FgatewayCount.Clear;
  FgatewayOnLineCount.Clear;
  FgatewayOnLineRate.Clear;
  FgatewayTodayOnLineRate.Clear;
  FterminalCount.Clear;
  FterminalOnLineCount.Clear;
  FterminalOnLineRate.Clear;
  FterminalTodayOnLineRate.Clear;
end;

{ TBrokerInfoDataList }
function TBrokerInfoDataList.Add(): TBrokerInfoData;
begin
  Result := TBrokerInfoData.Create;
  Self.Add(Result);
end;

end.
