unit UBrokerInfoData;

interface

uses
  Classes, SysUtils, Generics.Collections,
  puer.System;

type
  // �ɼ�����Ϣ
  TBrokerInfoData = class
  private
    FdevId: RInteger;          // ���
    FdevName: RString;         // ����
    FdevNo: RString;           // �豸���
    FdevModel: RString;        // �豸�ͺ�
    FdevModelName: RString;    // �豸�ͺ�����
    FdevFactoryNo: RString;    // �豸���ұ��
    FdevInstallAddr: RString;  // �豸��װ��ַ
    FlngLat: RString;          // ��γ��
    FonLine: RBoolean;         // ��ǰ����
    FtodayOnLineRate: RDouble; // ����������
    FgatewayCount: RInteger;            // ��������
    FgatewayOnLineCount: RInteger;      // ������������
    FgatewayOnLineRate: RDouble;        // ����������
    FgatewayTodayOnLineRate: RDouble;   // ���ؽ���������
    FterminalCount: RInteger;           // �ն�����
    FterminalOnLineCount: RInteger;     // �ն���������
    FterminalOnLineRate: RDouble;       // �ն�������
    FterminalTodayOnLineRate: RDouble;  // ���ؽ���������
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
