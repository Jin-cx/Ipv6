(*
 * �ɼ�ƽ̨�ܿص�Ԫ
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 *
 *
 *
 * �޸�:
 * 2016-12-08 (v0.1)
 *   + ��һ�η���.
 *)

unit UdoDDCtrl;

interface

uses
  SysUtils, Windows, Classes,
  { Comm ������Ԫ }
  puer.System, puer.SyncObjs,
  { Puerƽ̨�ӿڵ�Ԫ }
  UPrMsgInter, UPrDbConnInter, UPrLogInter,
  { �ɼ�ƽ̨ģ��ӿڵ�Ԫ }
  UdoDDAction,
  UDDCommInter, UDDDataInter, UDDTopoCacheInter, UDDModelsInter,
  { ҵ��Ԫ }
  UdoDDCache.Topo,                // ���˻���
  UdoDDWork.CommIO,               // ���Ĵ���
  UdoDDWork.CommStatis,           // �շ���������ͳ��
  UdoDDWork.MeterStatisTask,      // ����������ͳ��
  UdoDDWork.OnLineRateStatisTask, // �豸������ͳ��
  { Data }
  UDDTopologyData, UDDBrokerData, UDDDeviceData,
  UDDBrokerModelData, UDDGatewayModelData, UDDDeviceModelData,
  UMyConfig, UMyDebug, UdoQRCodeInter;

const
  ERROR_DIGGER_IS_OPEN          = '�ɼ�ƽ̨������';
  ERROR_DIGGER_IS_CLOSE         = '�ɼ�ƽ̨�ѹر�';
  ERROR_WAIT_FOR_CLOSE_TIME_OUT = '�ȴ��ɼ�ƽ̨�رճ�ʱ';

// ******************* �ɼ�ƽ̨�����رղ��� ******************* //
// �����м��ԭ�ļ�·��
procedure doSetModuleFileName(const aModuleFileName: string); stdcall;
// �м����ʼ��
procedure doInit; stdcall;
// �м���ͷ�
procedure doFree; stdcall;
// ��ʼ��״̬
function Active: Boolean; stdcall;

// ��ȡƽ̨��װ����
function doGetDDInstallData: RDateTime; stdcall;
// ��ȡ��ͼ���ã����ĵ����Ϣ��
function doGetMapConfig(var aMapConfig: RString; var aErrorInfo: string): Boolean; stdcall;
// ���õ�ͼ���ã����ĵ����Ϣ��
function doSetMapConfig(const aMapConfig: RString; var aErrorInfo: string): Boolean; stdcall;
function doGetDD(const aDD: TTopologyData; var aErrorInfo: string): Boolean; stdcall;


{function doCreateQRCode(const aModel: string;
                        const aTitle: string;
                        const aCode: string;
                        const aQRCodeJPG: TMemoryStream;
                        var aError: string): Boolean; stdcall; external 'QRCode.dll';   }

exports
  doSetModuleFileName,
  doInit,
  doFree,
  Active,
  doGetDDInstallData,
  doGetMapConfig,
  doSetMapConfig,
  doGetDD;

implementation

uses
  UdoDDWork.Monitor;

var
  _ModuleState: TPrModuleState;    // ƽ̨����״̬������

  _DDInstallData: RDateTime;       // ƽ̨��װ����
  _MapConfig: RString;             // ƽ̨��ͼ����

function doGetDDInstallData: RDateTime;
begin
  Result := _DDInstallData;
end;

function doGetMapConfig(var aMapConfig: RString; var aErrorInfo: string): Boolean;
begin
  aMapConfig := _MapConfig;
  Result := True;
end;

function doSetMapConfig(const aMapConfig: RString; var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aSQLStr := ' update tb_Devices set lngLat = ''' + aMapConfig.AsString + ''''
             + ' where devType = 3';
    aQuery.SQL.Text := aSQLStr;
    aQuery.ExecSQL;

    _MapConfig := aMapConfig;
    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetDD(const aDD: TTopologyData; var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(_MyConfig.DBName);
  try
    aSQLStr := ' select devId, devType, parentId, devName, devNo, devInstallDate, lngLat from tb_Devices '
             + ' where devType = 3';
    aQuery.SQL.Text := aSQLStr;
    aQuery.Open;

    with aDD do
    begin
      id := aQuery.ReadFieldAsRInteger('devId');
      deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
      parentId := aQuery.ReadFieldAsRInteger('parentId');
      name := aQuery.ReadFieldAsRString('devName');
      devId := aQuery.ReadFieldAsRString('devNo');
      devInstallDate := aQuery.ReadFieldAsRDateTime('devInstallDate');
      lngLat := aQuery.ReadFieldAsRString('lngLat');
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

{procedure doQRCode();
var
  aStream: TMemoryStream;
  aError: string;
  aCount: Integer;
begin
  aCount := GetTickCount;
  aStream := TMemoryStream.Create;
  try
    //UdoQRCodeInter._doCreateQRCode

    doCreateQRCode(//'dd-iot\_do\qr\QRCode.dll',
                                   'D:\Puer_EMMS\htdocs\water\monitor\_do\QRCode.cfg',
                                   '������֪ƽ̨DD',
                                   'http://192.168.1.24:8764/water/monitor/configuration/baseset',
                                   aStream,
                                   aError);


    aStream.SaveToFile('D:\QRCode.png');

  finally
    aStream.Free;
  end;

  TMyDebug.OutputDebug('CreateQRCode:' + IntToStr(GetTickCount - aCount));
end;}

procedure doSetModuleFileName(const aModuleFileName: string);
begin
  UMyConfig.doInitConfig(aModuleFileName);
  TMyDebug.OutputDebug('doSetModuleFileName');

  //doQRCode;
end;

procedure doInitTopoList;
const
  UNKNOWN_MODEL = 'δ֪�ͺ�';
var
  aTopoList: TTopologyDataList;
  aTopo: TTopologyData;
  aBroker: TBrokerData;
  aErrorInfo: string;
begin
  aTopoList := TTopologyDataList.Create;
  try
    // ȡ Topo ����
    try
      _DDDataInter._doGetTopologyList(aTopoList);
    except
      on E: Exception do
      begin
        OutputDebugString(PChar('[DD-IoT] _doGetTopologyList, ' + E.Message));
        raise E;
      end;
    end;

    // ��ʼ�� TopoCache
    try
      _DDTopoCacheInter._doInitTopoCache(aTopoList);
    except
      on E: Exception do
      begin
        OutputDebugString(PChar('[DD-IoT] _doInitTopoCache, ' + E.Message));
        raise E;
      end;
    end;

    // ע�� Broker
    for aTopo in aTopoList do
    begin
      if aTopo.deviceType = dtDD then
      begin
        _DDInstallData := aTopo.devInstallDate;
        _MapConfig := aTopo.lngLat;
      end
      else if aTopo.deviceType = dtBroker then
      begin
        aBroker := TBrokerData.Create;
        try
          aBroker.Assign(aTopo);

          if not _DDCommInter._RegBroker(aBroker.id.Value,
                                         aBroker.devId.AsString,
                                         aBroker.brokerHost.AsString,
                                         aBroker.brokerPort.Value,
                                         aBroker.useTLS.IsTrue,
                                         _MyConfig.BrokerCrt,
                                         aBroker.userName.AsString,
                                         aBroker.password.AsString,
                                         aErrorInfo) then
          begin
            OutputDebugString(PChar('lynch RegBroker error: ' + aErrorInfo));
          end;
        finally
          aBroker.Free;
        end;
      end;
    end;
    TPrLogInter.WriteLogInfo('doInitTopoList.RegBroker ���');
  finally
    aTopoList.Free;
  end;
end;

function doOpenDigger(var aErrorInfo: string): Boolean;
begin
  // ************   DDAction   ************
  TDDAction.Open(_MyConfig.RootPath, _MyConfig.TmpPath);
  TMyDebug.OutputDebug('DDAction.Open');

  // ************ ͨ�û���ģ�� ************
  // 1. Log
  //_DDLogInter := TDDLogInter.Create(@_GetProcAddr);
  //_DDLogInter._Open(aErrorInfo);
  //_DDLogInter._RegLog(UDDLogInter.DD_LOG_NAME, _MyConfig.LogPath, aErrorInfo);

  // ************ �ɼ�����ģ�� ************
  // 1. Models     ģ��
  _DDModelsInter := TDDModelsInter.Create(@_GetProcAddr);
  _DDModelsInter._Open(nil, _MyConfig.RootPath, @_GetProcAddr);

  // 2. Data       ����
  _DDDataInter := TDDDataInter.Create(@_GetProcAddr);
  _DDDataInter._Open(nil, _MyConfig.ConfigPath, _MyConfig.DataPath);

  // 3. Comm       ͨѶ
  //_DDDataInter._doCheckDoubtRequest(aErrorInfo);
  _DDCommInter := TDDCommInter.Create(@_GetProcAddr);
  _DDCommInter._Open(nil);

  // 5. TopoCache  ����ʵʱ״̬���ݻ���
  _DDTopoCacheInter := TDDTopoCacheInter.Create(@_GetProcAddr);
  _DDTopoCacheInter._Open(nil);

  // ************ �ܿ�ģ���ʼ�� ************

  // ֪ͨ��Ϣ����
  TDDMonitorCtrl.Open;

  // Topo ����
  TDDCacheTopoCtrl.Open;

  // ���Ĵ���Ԫ
  TDDWorkCommIOCtrl.Open;

  // �շ�����ͳ�Ƶ�Ԫ
  TDDWorkCommStatisCtrl.Open;

  TMyDebug.OutputDebug('doInitTopoList begin', True);

  // ��ʼ�� Topo
  doInitTopoList;

  TMyDebug.OutputDebug('doInitTopoList end', True);

  // ������ ���� ͳ��
  TDDWorkMeterStatisCtrl.Open;

  // �豸������ͳ��
  TDDWorkOnLineRateStatisCtrl.Open;

  Result := True;
end;

function doBeforeCloseDigger(var aErrorInfo: string): Boolean;
begin
  Result := True;
end;

function doCloseDigger(var aErrorInfo: string): Boolean;
begin
  TPrLogInter.WriteLogInfo('��ʼ�ر� DD-IoT');
  // ��ֹͣ���� MQTT
  if _DDCommInter <> nil then
    _DDCommInter._Stop;

  TPrLogInter.WriteLogInfo('DDComm Stop');

  // ************ �ܿ�ģ���������ر� ************
  if TDDWorkOnLineRateStatisCtrl.Active then
    TDDWorkOnLineRateStatisCtrl.Close;
  TPrLogInter.WriteLogInfo('DDWorkOnLineRateStatis Close');

  if TDDWorkCommIOCtrl.Active then
    TDDWorkCommIOCtrl.Close;
  TPrLogInter.WriteLogInfo('DDWorkCommIO Close');

  if TDDWorkCommStatisCtrl.Active then
    TDDWorkCommStatisCtrl.Close;
  TPrLogInter.WriteLogInfo('DDWorkCommStatis Close');

  if TDDWorkMeterStatisCtrl.Active then
    TDDWorkMeterStatisCtrl.Close;
  TPrLogInter.WriteLogInfo('DDWorkMeterStatis Close');

  if TDDCacheTopoCtrl.Active then
    TDDCacheTopoCtrl.Close;
  TPrLogInter.WriteLogInfo('DDCacheTopo Close');

  if TDDMonitorCtrl.Active then
    TDDMonitorCtrl.Close;
  TPrLogInter.WriteLogInfo('DDMonitor Close');

  // ************ �ɼ�����ģ��ر� ************
  if _DDTopoCacheInter <> nil then
  begin
    _DDTopoCacheInter._Close;
    _DDTopoCacheInter.Free;
  end;
  TPrLogInter.WriteLogInfo('DDTopoCache Close');

  if _DDCommInter <> nil then
  begin
    _DDCommInter._Close;
    _DDCommInter.Free;
  end;
  TPrLogInter.WriteLogInfo('DDComm Close');

  if _DDDataInter <> nil then
  begin
    _DDDataInter._Close;
    _DDDataInter.Free;
  end;
  TPrLogInter.WriteLogInfo('DDData Close');

  if _DDModelsInter <> nil then
  begin
    _DDModelsInter._Close;
    _DDModelsInter.Free;
  end;
  TPrLogInter.WriteLogInfo('DDModels Close');

  // ************ ͨ�û���ģ��ر� ************
  //if _DDLogInter <> nil then
  //begin
  //  _DDLogInter._Close(aErrorInfo);
  //  _DDLogInter.Free;
  //end;

  // ���ر� DDAction
  if TDDAction.Active then
  begin
    TDDAction.Close;
  end;
  TPrLogInter.WriteLogInfo('DDAction Close');

  Result := True;
end;

procedure doInit;
var
  aErrorInfo: string;
begin
  TMyDebug.OutputDebug('doInit');

  _ModuleState.Lock;
  try
    if _ModuleState.Active then
      raise Exception.Create(ERROR_DIGGER_IS_OPEN);

    try
      if not doOpenDigger(aErrorInfo) then
        raise Exception.Create(aErrorInfo);
    except
      on E: Exception do
      begin
        doCloseDigger(aErrorInfo);
        raise Exception.Create(E.Message);
      end;
    end;

    _ModuleState.SetActive(True);
  finally
    _ModuleState.UnLock;
  end;
end;

procedure doFree;
var
  aErrorInfo: string;
begin
  TMyDebug.OutputDebug('doFree');
  _ModuleState.Lock;
  try
    if not _ModuleState.Active then
      raise Exception.Create(ERROR_DIGGER_IS_CLOSE);

    _ModuleState.SetActive(False);

    if not doBeforeCloseDigger(aErrorInfo) then
    begin
      _ModuleState.SetActive(True);
      raise Exception.Create(aErrorInfo);
    end;

    if not _ModuleState.WaitFor(60*1000) then
    begin
      _ModuleState.SetActive(True);
      raise Exception.Create(ERROR_WAIT_FOR_CLOSE_TIME_OUT);
    end;

    if not doCloseDigger(aErrorInfo) then
    begin
      _ModuleState.SetActive(True);
      raise Exception.Create(aErrorInfo);
    end;
  finally
    _ModuleState.UnLock;
  end;
end;

function Active: Boolean;
begin
  Result := _ModuleState.Active;
end;

initialization
  _ModuleState := TPrModuleState.Create;

finalization
  _ModuleState.Free;

end.
