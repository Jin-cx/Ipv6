unit UdoDDAPI.DeviceChange;

interface

uses
  SysUtils, Classes,
  puer.System,
  UDDDataInter, UDDTopoCacheInter, UDDModelsInter,
  UdoDDAPI.Topo.Gateway, UdoDDAPI.Topo.Terminal,
  UDDChangeData, UDDDeviceData, UDDDeviceModelData;

function doAddChange(const aChangeData: TChangeData;
                     var aErrorInfo: string): Boolean; stdcall;

function doGetChangeList(const aBeginDay: RDateTime;
                         const aEndDay: RDateTime;
                         const aFilter: RString;
                         var aPageInfo: RPageInfo;
                         const aChangeList: TChangeDataList;
                         var aErrorInfo: string): Boolean; stdcall;

exports
  doAddChange,
  doGetChangeList;

implementation

{
  �������

  db.������豸


  ȷ��Ҫ���ľɱ����
  ����±�
  �±��·������� ��ʧ��Ҳ�У���ʾ���û���

  �ӻ���ɾ���ɱ�
  ����±����� �����������ݿ�֮��

  ��ӻ����¼

  ����ɱ�û�м����㣬ֱ�����


  ���������

  �±���ʼ����

  ����ɱ�������

}

function doCheckChangeParam(const aOldDeviceData: TDeviceData;
                            const aChangeData: TChangeData;
                            var aErrorInfo: string): Boolean;
var
  aMeterValue: UDDDeviceModelData.TMeterValueData;



  aMeterValueCodeList: TStringList;
  aMeterValueCode: string;
begin
  Result := False;

  if SameText(aOldDeviceData.devId.AsString, aChangeData.newDevNo.AsString) then
  begin
    aErrorInfo := '���豸��Ų�������豸�����ͬ';
    Exit;
  end;

  if aChangeData.endTime.IsNull then
  begin
    aErrorInfo := '����ȷ���豸����ʱ��';
    Exit;
  end;

  if aChangeData.endTime.Value > Now then
  begin
    aErrorInfo := '���豸����ʱ�䲻�ɴ��ڵ�ǰ������ʱ��';
    Exit;
  end;

  for aMeterValue in aOldDeviceData.deviceModel.MeterInfo.MeterValueList do
  begin
    if not aChangeData.endValueList.HasValue(aMeterValue.MeterValueCode) then
    begin
      aErrorInfo := '����ȷ���豸����ʱ ' + aMeterValue.MeterValueName + ' ';
      Exit;
    end;
  end;





  Result := True;
end;

function doAddChange(const aChangeData: TChangeData;
                     var aErrorInfo: string): Boolean;
var
  aOldDeviceData, aNewDeviceData: TDeviceData;
begin
  Result := False;

  aOldDeviceData := TDeviceData.Create;
  aNewDeviceData := TDeviceData.Create;
  try
    if not _DDTopoCacheInter._doGetDeviceInfoByDevId(aChangeData.oldDevNo.AsString, aOldDeviceData) or
       not _DDModelsInter._doGetDeviceModelInfo(aOldDeviceData.devModel.AsString, aOldDeviceData.deviceModel)then
    begin
      aErrorInfo := 'ָ���ľ��豸������';
      Exit;
    end;

    // ������
    if not doCheckChangeParam(aOldDeviceData, aChangeData, aErrorInfo) then
      Exit;

    aNewDeviceData.parentId := aOldDeviceData.parentId;
    aNewDeviceData.note := aChangeData.newDevNote;
    aNewDeviceData.devId := aChangeData.newDevNo;
    aNewDeviceData.devModel := aOldDeviceData.devModel;
    aNewDeviceData.conn := aChangeData.newConn;
    aNewDeviceData.devFactoryNo := aChangeData.newDevFactoryNo;
    aNewDeviceData.devInstallAddr := aOldDeviceData.devInstallAddr;
    aNewDeviceData.name.Value := aOldDeviceData.name.AsString + '(������)';

    if not UdoDDAPI.Topo.Terminal.doAddDevice(aNewDeviceData, aErrorInfo) then
    begin
      Exit;
    end;






  finally
    aOldDeviceData.Free;
    aNewDeviceData.Free;
  end;


  // db.AddDevice




  aOldDeviceData := TDeviceData.Create;
  try
    if not _DDTopoCacheInter._doGetDeviceInfoByDevId(aChangeData.oldDevNo.AsString, aOldDeviceData) then
    begin
      aErrorInfo := 'ָ���ľ��豸������';
      Exit;
    end;

    // ɾ�����豸
    if not UdoDDAPI.Topo.Gateway.doGatewayIssueDevice_Delete(aOldDeviceData.parentId,
                                                             aChangeData.oldDevNo.AsString,
                                                             aOldDeviceData.devModel.AsString,
                                                             aOldDeviceData.conn.AsString,
                                                             aErrorInfo) then
      Exit;

    // ������豸
    if not UdoDDAPI.Topo.Gateway.doGatewayIssueDevice_Add(aOldDeviceData.parentId,
                                                          aChangeData.newDevNo.AsString,
                                                          aOldDeviceData.name.AsString,
                                                          aOldDeviceData.devModel.AsString,
                                                          aChangeData.newConn.AsString,
                                                          aErrorInfo) then
      Exit;
  finally
    aOldDeviceData.Free;
  end;

  Result := _DDDataInter._doAddChange(aChangeData, aErrorInfo);
end;

function doGetChangeList(const aBeginDay: RDateTime;
                         const aEndDay: RDateTime;
                         const aFilter: RString;
                         var aPageInfo: RPageInfo;
                         const aChangeList: TChangeDataList;
                         var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetChangeList(aBeginDay,
                                          aEndDay,
                                          aFilter,
                                          aPageInfo,
                                          aChangeList,
                                          aErrorInfo);
end;

end.
