unit UdoDDAPI.Topo.Gateway;

interface

uses
  Classes, SysUtils, Windows,
  puer.System, puer.Json.JsonDataObjects,
  UPrDbConnInter,
  UDDDataInter, UDDTopoCacheInter, UDDCommInter, UDDModelsInter,
  UdoDDCache.Topo,
  UDDBrokerModelData, UDDGatewayModelData,
  UDDTopologyData, UDDBrokerData, UDDGatewayData, UDDDeviceData,
  UDDDeviceModelData, UDDCommData, UDDFieldData, UDDOffLineDeviceData,
  UOnLineData, UBrokerInfoData,
  UMyConfig;

// ��ȡ Gateway �ͺ��б�
procedure doGetGatewayModelList(const aModelList: TGatewayModelDataList); stdcall;
// ��ȡ Gateway �б�
function doGetGatewayList(const aBrokerId: RInteger;
                          const aGatewayList: TGatewayDataList;
                          var aErrorInfo: string): Boolean; stdcall;
// ��ȡ Gateway ����
function doGetGatewayInfo(const aGatewayId: RInteger;
                          const aGatewayData: TGatewayData;
                          var aErrorInfo: string): Boolean; stdcall;
// ��� Gateway
function doAddGateway(const aGatewayData: TGatewayData;
                      var aErrorInfo: string): Boolean; stdcall;
// �༭ Gateway
function doUpdateGateway(const aGatewayData: TGatewayData;
                         var aErrorInfo: string): Boolean; stdcall;
// ɾ�� Gateway
function doDeleteGateway(const aGatewayId: RInteger;
                         var aErrorInfo: string): Boolean; stdcall;
// Gateway ����
function doSortGateways(const aBrokerId: RInteger;
                        const aGatewayIdList: TArray<RInteger>;
                        var aErrorInfo: string): Boolean; stdcall;

// ��ȡ Gateway ��ǰ��ʵ�ն��豸�б�
function doGetRealDeviceList(const aGatewayId: RInteger;
                             var aRunState: RString;
                             const aDeviceList: TDeviceDataList;
                             var aErrorInfo: string): Boolean; stdcall;
// ˢ�� Gateway ���豸�б�
function doUpdateDevicesFromGateway(const aGatewayId: RInteger;
                                    var aErrorInfo: string): Boolean; stdcall;
// �·� Gateway ���豸�б�
function doIssueDevicesToGateway(const aGatewayId: RInteger;
                                 var aErrorInfo: string): Boolean; stdcall;

// �·� ���
function doGatewayIssueDevice_Add(const aGatewayId: RInteger;
                                  const aDevId: string;
                                  const aDevName: string;
                                  const aModel: string;
                                  const aConn: string;
                                  var aErrorInfo: string): Boolean; stdcall;

// �·� ����
function doGatewayIssueDevice_Update(const aGatewayId: RInteger;
                                     const aDevId: string;
                                     const aDevName: string;
                                     const aModel: string;
                                     const aConn: string;
                                     var aErrorInfo: string): Boolean; stdcall;

// �·� ɾ��
function doGatewayIssueDevice_Delete(const aGatewayId: RInteger;
                                     const aDevId: string;
                                     const aModel: string;
                                     const aConn: string;
                                     var aErrorInfo: string): Boolean; stdcall;

// ��ȡ Gateway �������б�
function doGetGatewayVarList(const aGatewayId: RInteger;
                             var aErrorInfo: string): Boolean; stdcall;

// ��ȡ Gateway �ϱ�����
function doGetGatewayPushCycle(const aGatewayId: RInteger;
                               var aPushCycle: Integer;
                               var aErrorInfo: string): Boolean; stdcall;
// ���� Gateway �ϱ�����
function doSetGatewayPushCycle(const aGatewayId: RInteger;
                               const aPushCycle: RInteger;
                               var aErrorInfo: string): Boolean; stdcall;

// �����ط�������֪ͨ
function doSendGatewayUpdateMsg(const aGatewayId: RInteger;
                                var aErrorInfo: string): Boolean; stdcall;

// ��¡
function doCloneGateway(const aFromDevNo: RString;
                        const aToDevNo: RString;
                        const aBrokerNo: string;
                        var aErrorInfo: string): Boolean; stdcall;

function doSearchGatewayList(const aParentId: RInteger;
                             const aIsOnLine: RBoolean;
                             const aFilter: RString;
                             var aPageInfo: RPageInfo;
                             const aGatewayList: TGatewayDataList;
                             var aErrorInfo: string): Boolean; stdcall;

// �����ص����ģ�ⷢ������
function doPublishAsGateway(const aGatewayId: RInteger;
                            const aPayload: string;
                            var aErrorInfo: string): Boolean; stdcall;

function doGetGatewayCommList(const aGatewayDevNo: RString;
                              const aStream: TMemoryStream;
                              var aErrorInfo: string): Boolean; stdcall;

exports
  doGetGatewayModelList,
  doGetGatewayList,
  doGetGatewayInfo,
  doAddGateway,
  doUpdateGateway,
  doDeleteGateway,
  doGetRealDeviceList,
  doSortGateways,
  doUpdateDevicesFromGateway,
  doIssueDevicesToGateway,
  doGatewayIssueDevice_Add,
  doGatewayIssueDevice_Update,
  doGatewayIssueDevice_Delete,
  doGetGatewayVarList,
  doGetGatewayPushCycle,
  doSetGatewayPushCycle,
  doSearchGatewayList,
  doCloneGateway,
  doSendGatewayUpdateMsg,
  doPublishAsGateway,
  doGetGatewayCommList;

implementation

uses
  UdoDDAPI.Topo.Terminal, UdoDDWork.CommStatis;

procedure doGetGatewayModelList(const aModelList: TGatewayModelDataList);
begin
  _DDModelsInter._doGetGatewayModelList(aModelList);
end;

function doGetGatewayList(const aBrokerId: RInteger;
                          const aGatewayList: TGatewayDataList;
                          var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aGateway: TGatewayData;
  aOnLineCount: Integer;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetGatewayList';
    aQuery.AddParamI('brokerId', aBrokerId);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      aGateway := TGatewayData.Create;
      aGateway.id := aQuery.ReadFieldAsRInteger('devId');
      aGateway.deviceType := TDeviceType(aQuery.ReadFieldAsRInteger('devType').Value);
      aGateway.parentId := aQuery.ReadFieldAsRInteger('parentId');
      aGateway.name := aQuery.ReadFieldAsRString('devName');
      aGateway.note := aQuery.ReadFieldAsRString('devNote');
      aGateway.devId := aQuery.ReadFieldAsRString('devNo');
      aGateway.devModel := aQuery.ReadFieldAsRString('devModel');
      aGateway.devModelName := aQuery.ReadFieldAsRString('devModelName');
      aGateway.devState := TDeviceState(aQuery.ReadFieldAsRInteger('devState').Value);
      aGateway.devInstallAddr := aQuery.ReadFieldAsRString('devInstallAddr');
      if aQuery.ReadFieldAsRBoolean('onLine').IsTrue then
        aGateway.commState := csOnLine
      else
        aGateway.commState := csOffLine;
      aGateway.todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');

      aGateway.isDebug := aQuery.ReadFieldAsRBoolean('isDebug');
      aGateway.debugInfo := aQuery.ReadFieldAsRString('debugInfo');

      aGateway.isTemp := aQuery.ReadFieldAsRBoolean('isTemp');
      aGateway.ip := aQuery.ReadFieldAsRString('ip');
      aGateway.runState := aQuery.ReadFieldAsRString('runState');
      aGateway.version := aQuery.ReadFieldAsRString('version');
      aGateway.sortIndex := aQuery.ReadFieldAsRInteger('sortIndex');

      aGateway.allTerminalCount := aQuery.ReadFieldAsRInteger('allTerminalCount', 0);
      aGateway.onLineTerminalCount := aQuery.ReadFieldAsRInteger('onLineTerminalCount', 0);
      aGateway.debugTerminalCount := aQuery.ReadFieldAsRInteger('debugTerminalCount', 0);

      aOnLineCount := aGateway.onLineTerminalCount.Value + aGateway.debugTerminalCount.Value;
      if aOnLineCount > aGateway.allTerminalCount.Value then
        aGateway.allTerminalCount.Value := aOnLineCount;
      aGateway.offLineTerminalCount.Value := aGateway.allTerminalCount.Value - aOnLineCount;
      if aOnLineCount > 0 then
        aGateway.terminalOnLineRate.Value := aOnLineCount/aGateway.allTerminalCount.Value
      else
        aGateway.terminalOnLineRate.Value := 0;

      aGateway.lastRealTime := aQuery.ReadFieldAsRString('lastRealTime');

      aGateway.UpdateData;
      aGatewayList.Add(aGateway);

      aQuery.Next;
    end;
    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetGatewayInfo(const aGatewayId: RInteger;
                          const aGatewayData: TGatewayData;
                          var aErrorInfo: string): Boolean;
begin
  Result := not aGatewayId.IsNull and
            _DDTopoCacheInter._doGetGatewayInfo(aGatewayId.Value, aGatewayData, aErrorInfo);
  if not Result then
    aErrorInfo := 'ָ�������ز�����';
end;

function doAddGateway(const aGatewayData: TGatewayData;
                      var aErrorInfo: string): Boolean;
begin
  aGatewayData.UpdateData;

  Result := _DDDataInter._doAddTopology(aGatewayData, aErrorInfo)
            and
            _DDTopoCacheInter._doAddGateway(aGatewayData, aErrorInfo);
end;

function doUpdateGateway(const aGatewayData: TGatewayData;
                         var aErrorInfo: string): Boolean;
begin
  aGatewayData.isTemp.Value := False;
  aGatewayData.UpdateData;

  Result := _DDDataInter._doUpdateTopology(aGatewayData, aErrorInfo)
            and
            _DDTopoCacheInter._doUpdateGateway(aGatewayData, aErrorInfo);
end;

function doDeleteGateway(const aGatewayId: RInteger;
                         var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doDeleteTopology(aGatewayId, aErrorInfo)
            and
            _DDTopoCacheInter._doDeleteGateway(aGatewayId, aErrorInfo);
end;

function doPublishAsGateway(const aGatewayId: RInteger;
                            const aPayload: string;
                            var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
  aErrorCode: string;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    // ����
    if not _DDCommInter._PublishAsSender(aGatewayData.parentId.Value,
                                         aGatewayData.devId.AsString,
                                         aPayload,
                                         aErrorCode,
                                         aErrorInfo) then
      Exit;

    Result := True;
  finally
    aGatewayData.Free;
  end;
end;

function doGetGatewayCommList(const aGatewayDevNo: RString;
                              const aStream: TMemoryStream;
                              var aErrorInfo: string): Boolean;
begin
  Result := TDDWorkCommStatisCtrl.GetGatewayCommList(aGatewayDevNo.AsString, aStream, aErrorInfo);
end;

function doGetRealDeviceList(const aGatewayId: RInteger;
                             var aRunState: RString;
                             const aDeviceList: TDeviceDataList;
                             var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aCmd, aCmdData: string;
  aErrorCode: string;
  aJson: TJsonArray;
  i: Integer;
  aDevice: TDeviceData;
  aVarlist: TJsonArray;
  j: Integer;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    // ��������
    _DDModelsInter._doCmd_GetDeviceList(aCmd, aCmdData);
    aSendCmdData.Cmd := aCmd;
    aSendCmdData.CmdData := aCmdData;
    if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                     aGatewayData.devId.AsString,
                                     aSendCmdData,
                                     aReceiveCmdData,
                                     10,
                                     aErrorCode,
                                     aErrorInfo) then
    begin
      aErrorInfo := '��ȡ�����ն��豸�б�ʧ��' + aErrorInfo;
      Exit;
    end;

    if aReceiveCmdData.StatusCode <> '0' then
    begin
      aErrorInfo := Format('��ȡ�����ն��豸�б�ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
      Exit;
    end;

    if aReceiveCmdData.ResponseData = '' then
      aReceiveCmdData.ResponseData := '[]';

    aJson := TJsonArray.Parse(aReceiveCmdData.ResponseData) as TJsonArray;
    try
      try
        for i := 0 to aJson.Count - 1 do
        begin
          aDevice := aDeviceList.Add;
          aDevice.devId    := aJson.O[i].RS['_devid'];
          aDevice.devModel := aJson.O[i].RS['_type'];
          aDevice.conn     := aJson.O[i].RS['_conn'];
          aDevice.name     := aJson.O[i].RS['dname'];

          // �Զ����豸��Ҫ
          if SameText(aDevice.devModel.AsString, 'CustomDev') then
          begin
            aVarlist := aJson.O[i].A['_varlist'];
            for j := 0 to aVarlist.Count - 1 do
            begin
              aDevice.deviceModel.VarList.AddVar(TVarType(aVarlist.O[j].I['_vartype']),
                                                 aVarlist.O[j].S['_varcode'],
                                                 aVarlist.O[j].S['_varname'],
                                                 '',
                                                 False,
                                                 False);
            end;
          end;
        end;
        aRunState.Value := aReceiveCmdData.From._runstate;
        Result := True;
      except
        Result := False;
        aErrorInfo := '��ȡ�����ն��豸�б�ʧ��, ���ص����ݸ�ʽ����ȷ.';
      end;
    finally
      aJson.Free;
    end;
  finally
    aGatewayData.Free;
  end;
end;

function doSortGateways(const aBrokerId: RInteger;
                        const aGatewayIdList: TArray<RInteger>;
                        var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doSortTopologys(aGatewayIdList, aErrorInfo);
            //and
            //_DDTopoCacheInter._doSortGateways(aBrokerId, aGatewayIdList, aErrorInfo);
end;

function doUpdateDevicesFromGateway(const aGatewayId: RInteger;
                                    var aErrorInfo: string): Boolean;
var
  aRunState: RString;
  aNewDevice, aOldDevice: TDeviceData;
  aNewDeviceList, aOldDeviceList: TDeviceDataList;
  aFound: Boolean;
begin
  Result := False;

  aNewDeviceList := TDeviceDataList.Create;
  try
    // ȡ��ǰ��������ʵ���豸�б�
    if not doGetRealDeviceList(aGatewayId, aRunState, aNewDeviceList, aErrorInfo) then
      Exit;

    // ��Ҫ������
    if not _DDTopoCacheInter._doUpdateGatewayRunState(aGatewayId, aRunState.AsString, aErrorInfo) then
      Exit;

    // ���»����е��豸�б�
    aOldDeviceList := TDeviceDataList.Create;
    try
      // ��ȡ��ǰ���õ��豸�б�
      if not doGetDeviceList(aGatewayId, aOldDeviceList, aErrorInfo) then
        Exit;

      if not _DDDataInter._doUpdateDevicesOfGateway(aGatewayId, aRunState, aNewDeviceList, aErrorInfo) then
        Exit;

      for aNewDevice in aNewDeviceList do
      begin
        aNewDevice.parentId := aGatewayId;
        if aNewDevice.name.AsString = '' then
          aNewDevice.name.Value := aNewDevice.devId.AsString + '(δ֪)';

        if _DDModelsInter._doGetDeviceModelInfo(aNewDevice.devModel.AsString, aNewDevice.deviceModel) then
        begin
          aNewDevice.devModelName.Value := aNewDevice.deviceModel.ModelName;
          aNewDevice.isMeter.Value := aNewDevice.deviceModel.IsMeter;
        end
        else
        begin
          aNewDevice.devModelName.Value := 'δ֪�ͺ�';
          aNewDevice.isMeter.Value := False;
        end;

        aFound := False;
        for aOldDevice in aOldDeviceList do
        begin
          if SameText(aNewDevice.devId.AsString, aOldDevice.devId.AsString) then
          begin
            aNewDevice.name := aOldDevice.name;
            aNewDevice.note := aOldDevice.note;
            aNewDevice.meterCode := aOldDevice.meterCode;

            if SameText(aNewDevice.devModel.AsString, aOldDevice.devModel.AsString) then
            begin
              aNewDevice.lastRealTime := aOldDevice.lastRealTime;
              aNewDevice.masterValue := aOldDevice.masterValue;
              aNewDevice.commState := aOldDevice.commState;
            end;

            aOldDeviceList.Remove(aOldDevice);
            aFound := True;
            Break;
          end;
        end;

        aNewDevice.UpdateData;

        if aFound then
        begin
          if not _DDTopoCacheInter._doUpdateDevice(aNewDevice, aErrorInfo) then
          begin
            aErrorInfo :=  aNewDevice.devId.AsString + ' ' + '���»���ʧ��,' + aErrorInfo;
            Exit;
          end;
        end
        else
        begin
          if not _DDTopoCacheInter._doAddDevice(aNewDevice, aErrorInfo) then
          begin
            aErrorInfo :=  aNewDevice.devId.AsString + ' ' + '�뻺��ʧ��,' + aErrorInfo;
            Exit;
          end;
        end;
      end;

      for aOldDevice in aOldDeviceList do
        _DDTopoCacheInter._doDeleteDevice(aOldDevice.id, aOldDevice, aErrorInfo);
    finally
      aOldDeviceList.Free;
    end;

    Result := True;
  finally
    aNewDeviceList.Free;
  end;
end;

function doIssueDevicesToGateway(const aGatewayId: RInteger;
                                 var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
  aDeviceList: TDeviceDataList;
  aCmd, aCmdData: string;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode: string;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    aDeviceList := TDeviceDataList.Create;
    try
      if not doGetDeviceList(aGatewayId, aDeviceList, aErrorInfo) then
        Exit;

      _DDModelsInter._doCmd_IssueDeviceList(aDeviceList, aCmd, aCmdData);
      aSendCmdData.Cmd := aCmd;
      aSendCmdData.CmdData := aCmdData;
      if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                       aGatewayData.devId.AsString,
                                       aSendCmdData,
                                       aReceiveCmdData,
                                       60,
                                       aErrorCode,
                                       aErrorInfo) then
      begin
        aErrorInfo := '�·��ն��豸�б�����ʧ��' + aErrorInfo;
        Exit;
      end;

      if aReceiveCmdData.StatusCode <> '0' then
      begin
        aErrorInfo := Format('�·��ն��豸�б�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
        Exit;
      end;

      Result := doUpdateDevicesFromGateway(aGatewayId, aErrorInfo);
    finally
      aDeviceList.Free;
    end;
  finally
    aGatewayData.Free;
  end;
end;


function doGatewayIssueDevice_Add(const aGatewayId: RInteger;
                                  const aDevId: string;
                                  const aDevName: string;
                                  const aModel: string;
                                  const aConn: string;
                                  var aErrorInfo: string): Boolean;
const
  DEV_UPDATE = '{"_type":"%s","_devid":"%s","dname":"%s","_conn":%s}';
var
  aGatewayData: TGatewayData;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode: string;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    aSendCmdData.Cmd := 'manager/dev/update.do';
    aSendCmdData.CmdData := Format(DEV_UPDATE, [aModel, aDevId, aDevName, aConn]);

    if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                     aGatewayData.devId.AsString,
                                     aSendCmdData,
                                     aReceiveCmdData,
                                     60,
                                     aErrorCode,
                                     aErrorInfo) then
    begin
      aErrorInfo := '�·��ն��豸�б�����ʧ��' + aErrorInfo;
      Exit;
    end;

    if aReceiveCmdData.StatusCode <> '0' then
    begin
      aErrorInfo := Format('�·��ն��豸�б�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
      Exit;
    end;

    Result := True;
  finally
    aGatewayData.Free;
  end;
end;

function doGatewayIssueDevice_Update(const aGatewayId: RInteger;
                                     const aDevId: string;
                                     const aDevName: string;
                                     const aModel: string;
                                     const aConn: string;
                                     var aErrorInfo: string): Boolean;
const
  DEV_UPDATE = '{"_type":"%s","_devid":"%s","dname":"%s","_conn":%s}';
var
  aGatewayData: TGatewayData;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode: string;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    aSendCmdData.Cmd := 'manager/dev/update.do';
    aSendCmdData.CmdData := Format(DEV_UPDATE, [aModel, aDevId, aDevName, aConn]);

    if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                     aGatewayData.devId.AsString,
                                     aSendCmdData,
                                     aReceiveCmdData,
                                     60,
                                     aErrorCode,
                                     aErrorInfo) then
    begin
      aErrorInfo := '�·��ն��豸�б�����ʧ��' + aErrorInfo;
      Exit;
    end;

    if aReceiveCmdData.StatusCode <> '0' then
    begin
      aErrorInfo := Format('�·��ն��豸�б�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
      Exit;
    end;

    Result := True;
  finally
    aGatewayData.Free;
  end;
end;

function doGatewayIssueDevice_Delete(const aGatewayId: RInteger;
                                     const aDevId: string;
                                     const aModel: string;
                                     const aConn: string;
                                     var aErrorInfo: string): Boolean;
const
  DEV_UPDATE = '{"_type":"%s","_devid":"%s","_conn":%s}';
var
  aGatewayData: TGatewayData;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode: string;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    aSendCmdData.Cmd := 'manager/dev/delete.do';
    aSendCmdData.CmdData := Format(DEV_UPDATE, [aModel, aDevId, aConn]);

    if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                     aGatewayData.devId.AsString,
                                     aSendCmdData,
                                     aReceiveCmdData,
                                     60,
                                     aErrorCode,
                                     aErrorInfo) then
    begin
      aErrorInfo := '�·��ն��豸�б�����ʧ��' + aErrorInfo;
      Exit;
    end;

    if aReceiveCmdData.StatusCode <> '0' then
    begin
      aErrorInfo := Format('�·��ն��豸�б�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
      Exit;
    end;

    Result := True;
  finally
    aGatewayData.Free;
  end;
end;

function doGetGatewayVarList(const aGatewayId: RInteger;
                             var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode: string;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    //aSendCmdData.Cmd := 'manager/getvar.do';
    //aSendCmdData.CmdData := '{"_varname":["*"]}';
    aSendCmdData.Cmd := 'init/get.do';
    aSendCmdData.CmdData := '{}';

    if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                     aGatewayData.devId.AsString,
                                     aSendCmdData,
                                     aReceiveCmdData,
                                     60,
                                     aErrorCode,
                                     aErrorInfo) then
    begin
      aErrorInfo := '�·��ն��豸�б�����ʧ��' + aErrorInfo;
      Exit;
    end;

    if aReceiveCmdData.StatusCode <> '0' then
    begin
      aErrorInfo := Format('�·��ն��豸�б�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
      Exit;
    end;

    Result := True;
  finally
    aGatewayData.Free;
  end;
end;

function doGetGatewayPushCycle(const aGatewayId: RInteger;
                               var aPushCycle: Integer;
                               var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
  aCmd, aCmdData: string;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode: string;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    if not _DDModelsInter._doCmd_GetPushCycle(aGatewayData.devModel.AsString, aCmd, aCmdData, aErrorInfo) then
      Exit;

    aSendCmdData.Cmd := aCmd;
    aSendCmdData.CmdData := aCmdData;

    if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                     aGatewayData.devId.AsString,
                                     aSendCmdData,
                                     aReceiveCmdData,
                                     5,
                                     aErrorCode,
                                     aErrorInfo) then
      Exit;

    if aReceiveCmdData.StatusCode <> '0' then
    begin
      aErrorInfo := Format('��ȡ�����ϱ�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
      Exit;
    end;

    if not _DDModelsInter._doParse_GetPushCycle(aGatewayData.devModel.AsString,
                                                aReceiveCmdData.ResponseData,
                                                aPushCycle,
                                                aErrorInfo) then
      Exit;

    Result := True;
  finally
    aGatewayData.Free;
  end;
end;

function doSetGatewayPushCycle(const aGatewayId: RInteger;
                               const aPushCycle: RInteger;
                               var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
  aCmd, aCmdData: string;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode: string;
begin
  Result := False;

  if aPushCycle.IsNull then
  begin
    aErrorInfo := '��ָ��Ҫ���õ��ϱ�����';
    Exit;
  end;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;
    if not _DDModelsInter._doCmd_SetPushCycle(aGatewayData.devModel.AsString,
                                              aPushCycle.Value,
                                              aCmd,
                                              aCmdData,
                                              aErrorInfo) then
      Exit;

    aSendCmdData.Cmd := aCmd;
    aSendCmdData.CmdData := aCmdData;

    if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                     aGatewayData.devId.AsString,
                                     aSendCmdData,
                                     aReceiveCmdData,
                                     60,
                                     aErrorCode,
                                     aErrorInfo) then
      Exit;

    if aReceiveCmdData.StatusCode <> '0' then
    begin
      aErrorInfo := Format('���������ϱ�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
      Exit;
    end;

    Result := True;
  finally
    aGatewayData.Free;
  end;
end;

function doSendGatewayUpdateMsg(const aGatewayId: RInteger;
                                var aErrorInfo: string): Boolean;
var
  aGatewayData: TGatewayData;
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aErrorCode: string;
begin
  Result := False;

  aGatewayData := TGatewayData.Create;
  try
    if not doGetGatewayInfo(aGatewayId, aGatewayData, aErrorInfo) then
      Exit;

    if _MyConfig.GatewayUpdateUrl = '' then
    begin
      aErrorInfo := '������ Config.cfg ���������ظ��µ� URL';
      Exit;
    end;

    aSendCmdData.Cmd := 'manager/update_drive';
    aSendCmdData.CmdData := '{"url": "' + _MyConfig.GatewayUpdateUrl + '"}';

    if not _DDCommInter._SendCmdSync(aGatewayData.parentId.Value,
                                     aGatewayData.devId.AsString,
                                     aSendCmdData,
                                     aReceiveCmdData,
                                     60,
                                     aErrorCode,
                                     aErrorInfo) then
      Exit;

    if aReceiveCmdData.StatusCode <> '0' then
    begin
      aErrorInfo := Format('������: %s', [aReceiveCmdData.StatusCode]);
      Exit;
    end;

    Result := True;
  finally
    aGatewayData.Free;
  end;
end;

function doIssueAllDevicesToGateway(const aDeviceList: TDeviceDataList;
                                    const aGateway: TGatewayData;
                                    var aErrorInfo: string): Boolean;
var
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aDevice: TDeviceData;
  aJson: TJsonArray;
  aItem: TJsonObject;
  aErrorCode: string;
begin
  Result := False;

  for aDevice in aDeviceList do
  begin
    if not doGatewayIssueDevice_Add(aGateway.id,
                                    aDevice.devId.AsString,
                                    aDevice.name.AsString,
                                    aDevice.devModel.AsString,
                                    aDevice.conn.AsString,
                                    aErrorInfo) then
      Exit;
  end;

  Result := True;

  Exit;

  aSendCmdData.Cmd := 'manager/dev/update.do';
  aJson := TJsonArray.Create;
  try
    for aDevice in aDeviceList do
    begin
      aItem := aJson.AddObject;
      aItem.S['_type'] := aDevice.devModel.AsString;
      aItem.S['_devid'] := aDevice.devId.AsString;
      aItem.O['_conn'].FromJSON(aDevice.conn.AsString);
    end;

    aSendCmdData.CmdData := aJson.ToJSON(True);
  finally
    aJson.Free;
  end;

  if not _DDCommInter._SendCmdSync(aGateway.parentId.Value,
                                   aGateway.devId.AsString,
                                   aSendCmdData,
                                   aReceiveCmdData,
                                   60,
                                   aErrorCode,
                                   aErrorInfo) then
  begin
    aErrorInfo := '�·��ն��豸�б�����ʧ��' + aErrorInfo;
    Exit;
  end;

  if aReceiveCmdData.StatusCode <> '0' then
  begin
    aErrorInfo := Format('�·��ն��豸�б�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
    Exit;
  end;

  Result := True;
end;


function doInitGateway(const aFromGateway, aToGateway: TGatewayData;
                       const aBrokerNo: string;
                       var aErrorInfo: string): Boolean;
var
  aSendCmdData: TCommDataInfo;
  aReceiveCmdData: TCommDataInfo;
  aJson: TJsonObject;
  aErrorCode: string;
  aGate: string;
begin
  Result := False;

  aSendCmdData.Cmd := 'init/set.do';
  aJson := TJsonObject.Create;
  try
    aJson.S['_server_ip'] := '192.168.1.66';
    aJson.S['_server_port'] := '8080';
    aJson.S['_username'] := 'things';
    aJson.S['_password'] := 'P@ssw0rd';
    aJson.S['_server_name'] := aBrokerNo;
    aJson.S['_will'] := '1';
    aJson.S['_keepalive'] := '60';

    aJson.S['_interface_inet'] := 'static';
    aJson.S['_client_ip'] := aFromGateway.ip.AsString;
    aJson.S['_client_netmask'] := '255.255.255.0';
    aGate := aFromGateway.ip.AsString;
    while Copy(aGate, Length(aGate), 1) <> '.' do
      Delete(aGate, Length(aGate), 1);
    aJson.S['_client_gateway'] := aGate + '1';
    aSendCmdData.CmdData := aJson.ToJSON(True);
  finally
    aJson.Free;
  end;

  if not _DDCommInter._SendCmdSync(aToGateway.parentId.Value,
                                   aToGateway.devId.AsString,
                                   aSendCmdData,
                                   aReceiveCmdData,
                                   60,
                                   aErrorCode,
                                   aErrorInfo) then
  begin
    aErrorInfo := '�·����õ�����ʧ��' + aErrorInfo;
    Exit;
  end;

  if aReceiveCmdData.StatusCode <> '0' then
  begin
    aErrorInfo := Format('�·����õ�����ʧ��,������: %s', [aReceiveCmdData.StatusCode]);
    Exit;
  end;

  Result := True;
end;

function doCloneGateway(const aFromDevNo: RString;
                        const aToDevNo: RString;
                        const aBrokerNo: string;
                        var aErrorInfo: string): Boolean;
var
  aDeviceList: TDeviceDataList;
  aFromGateway, aToGateway: TGatewayData;
  aGatewayList: TGatewayDataList;
  aPageInfo: RPageInfo;
begin
  Result := False;

  aGatewayList := TGatewayDataList.Create;
  aFromGateway := TGatewayData.Create;
  aToGateway := TGatewayData.Create;
  aDeviceList := TDeviceDataList.Create;
  try
    if not _DDDataInter._doGetAllGatewayList(RInteger.Null, RBoolean.Null,
                                             aFromDevNo, aPageInfo, aGatewayList, aErrorInfo) then
      Exit;
    if aGatewayList.Count = 0 then
    begin
      aErrorInfo := ' FromDevNo δ�ҵ�';
      Exit;
    end;
    aFromGateway.Assign(aGatewayList[0]);

    aGatewayList.Clear;

    if not _DDDataInter._doGetAllGatewayList(RInteger.Null, RBoolean.Null,
                                             aToDevNo, aPageInfo, aGatewayList, aErrorInfo) then
      Exit;
    if aGatewayList.Count = 0 then
    begin
      aErrorInfo := ' aToDevNo δ�ҵ�';
      Exit;
    end;
    aToGateway.Assign(aGatewayList[0]);


    if not _DDTopoCacheInter._doGetDeviceList(aFromGateway.id, aDeviceList, aErrorInfo) then
      Exit;

    // �·��豸�б�
    if not doIssueAllDevicesToGateway(aDeviceList, aToGateway, aErrorInfo) then
      Exit;

    // �·�����
    if not doInitGateway(aFromGateway, aToGateway, aBrokerNo, aErrorInfo) then
      Exit;

    Result := True;

  finally
    aGatewayList.Free;
    aDeviceList.Free;
  end;

end;

function doSearchGatewayList(const aParentId: RInteger;
                             const aIsOnLine: RBoolean;
                             const aFilter: RString;
                             var aPageInfo: RPageInfo;
                             const aGatewayList: TGatewayDataList;
                             var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetAllGatewayList(aParentId,
                                              aIsOnLine,
                                              aFilter,
                                              aPageInfo,
                                              aGatewayList,
                                              aErrorInfo);
end;

end.
