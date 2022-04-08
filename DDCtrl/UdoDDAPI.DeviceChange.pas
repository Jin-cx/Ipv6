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
  换表过程

  db.添加新设备


  确认要换的旧表存在
  添加新表
  新表下发到网关 （失败也行，提示给用户）

  从缓存删除旧表
  添加新表到缓存 （必须在数据库之后）

  添加换表记录

  如果旧表没有计量点，直接完成


  结算计量点

  新表起始数据

  如果旧表数据已

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
    aErrorInfo := '新设备编号不可与旧设备编号相同';
    Exit;
  end;

  if aChangeData.endTime.IsNull then
  begin
    aErrorInfo := '请明确旧设备结束时间';
    Exit;
  end;

  if aChangeData.endTime.Value > Now then
  begin
    aErrorInfo := '旧设备结束时间不可大于当前服务器时间';
    Exit;
  end;

  for aMeterValue in aOldDeviceData.deviceModel.MeterInfo.MeterValueList do
  begin
    if not aChangeData.endValueList.HasValue(aMeterValue.MeterValueCode) then
    begin
      aErrorInfo := '请明确旧设备结束时 ' + aMeterValue.MeterValueName + ' ';
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
      aErrorInfo := '指定的旧设备不存在';
      Exit;
    end;

    // 检查参数
    if not doCheckChangeParam(aOldDeviceData, aChangeData, aErrorInfo) then
      Exit;

    aNewDeviceData.parentId := aOldDeviceData.parentId;
    aNewDeviceData.note := aChangeData.newDevNote;
    aNewDeviceData.devId := aChangeData.newDevNo;
    aNewDeviceData.devModel := aOldDeviceData.devModel;
    aNewDeviceData.conn := aChangeData.newConn;
    aNewDeviceData.devFactoryNo := aChangeData.newDevFactoryNo;
    aNewDeviceData.devInstallAddr := aOldDeviceData.devInstallAddr;
    aNewDeviceData.name.Value := aOldDeviceData.name.AsString + '(待换表)';

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
      aErrorInfo := '指定的旧设备不存在';
      Exit;
    end;

    // 删除旧设备
    if not UdoDDAPI.Topo.Gateway.doGatewayIssueDevice_Delete(aOldDeviceData.parentId,
                                                             aChangeData.oldDevNo.AsString,
                                                             aOldDeviceData.devModel.AsString,
                                                             aOldDeviceData.conn.AsString,
                                                             aErrorInfo) then
      Exit;

    // 添加新设备
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
