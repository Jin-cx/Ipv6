{
  ��Ԫ: �ն��豸ʵʱ���ݴ洢����ģ��
  ����: lynch
  ����: 2016-09-17
}

unit UDDData.DeviceRealData;

interface

uses
  Classes, SysUtils, Generics.Collections, DateUtils, Windows,
  puer.System, puer.SyncObjs, puer.FileUtils, puer.Json.JsonDataObjects,
  puer.Collections,
  UPrDbConnInter,
  UDDTopologyData, UDDDeviceModelData, UDDDeviceData,
  UDDDeviceRealData, UDDFileListData, UDDHourValueData,
  UDDData.Config;

// ɾ���ն��豸ʵʱ���ݴ洢�ļ�
function doDeleteRealDataFile(const aDevModel: string;
                              const aDevId: string;
                              var aErrorInfo: string): Boolean; stdcall;
// ����ն��豸ʵʱ�����ļ��е�����
function doClearRealDataRecord(const aDevModel: string;
                               const aDevId: string;
                               var aErrorInfo: string): Boolean; stdcall;

// ��ȡ�����ļ����б�
function doGetRealDataFolderList(const aDevModelList: TDeviceModelDataList;
                                 var aErrorInfo: string): Boolean; stdcall;
// ��ȡ�����ļ��б�
function doGetRealDataFileList(const aDevModel: RString;
                               const aDeviceList: TDeviceDataList;
                               var aErrorInfo: string): Boolean; stdcall;






// ������ʷ����
function doDeleteRealData(const aDevModel: string;
                          const aDevId: string;
                          const aDeadline: TDateTime;
                          var aErrorInfo: string): Boolean; stdcall;









// ��ȡСʱ����
function doGetDeviceHourValueList(const aDevId: Integer;
                                  const aMeterValueCode: string;
                                  const aBeginDate: RDateTime;
                                  const aEndDate: RDateTime;
                                  const aHourValueList: THourValueDataList;
                                  var aErrorInfo: string): Boolean; stdcall;

function doGetDeviceTenMinValueList(const aDevId: Integer;
                                    const aMeterValueCode: string;
                                    const aDateHour: TDateTime;
                                    const aHourValueList: THourValueDataList;
                                    var aErrorInfo: string): Boolean; stdcall;

// ��ȡʵʱ����
function doGetDeviceRealDataList(const aDevId: string;
                                 const aDay: TDateTime;
                                 var aPageInfo: RPageInfo;
                                 const aDeviceVarList: TDeviceVarDataList;
                                 const aDeviceRealDataList: TDeviceRealDataList;
                                 var aErrorInfo: string): Boolean; stdcall;

exports
  doDeleteRealDataFile,
  doClearRealDataRecord,
  doGetRealDataFolderList,
  doGetRealDataFileList,
  doDeleteRealData,

  doGetDeviceHourValueList,
  doGetDeviceTenMinValueList,
  doGetDeviceRealDataList;

implementation

function doDeleteRealDataFile(const aDevModel: string;
                              const aDevId: string;
                              var aErrorInfo: string): Boolean;
begin
  Result := False;
  aErrorInfo := 'Ҳ��ͣ�õĽӿ�';
end;

function doClearRealDataRecord(const aDevModel: string;
                               const aDevId: string;
                               var aErrorInfo: string): Boolean;
begin
  Result := False;
  aErrorInfo := 'Ҳ��ͣ�õĽӿ�';
end;

function doGetRealDataFolderList(const aDevModelList: TDeviceModelDataList;
                                 var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetTerminalDevModelList';
    aQuery.AddParamB('hasTerminal', True);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aDevModelList.Add do
      begin
        Model := aQuery.FieldByName('devModel').AsString;
        ModelName := aQuery.FieldByName('devModelName').AsString;
        Brand := aQuery.FieldByName('devBrand').AsString;
        DeviceName := aQuery.FieldByName('devSort').AsString;
        DevCount := aQuery.FieldByName('devCount').AsInteger;
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetRealDataFileList(const aDevModel: RString;
                               const aDeviceList: TDeviceDataList;
                               var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetTerminalListByDevModel';
    aQuery.AddParamS('devModel', aDevModel);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aDeviceList.Add do
      begin
        devId := aQuery.ReadFieldAsRString('devNo');
        name := aQuery.ReadFieldAsRString('devName');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetDeviceRealDataList(const aDevId: string;
                                 const aDay: TDateTime;
                                 var aPageInfo: RPageInfo;
                                 const aDeviceVarList: TDeviceVarDataList;
                                 const aDeviceRealDataList: TDeviceRealDataList;
                                 var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetRealDataList';
    aQuery.AddParamS('devNo', aDevId);
    aQuery.AddParamT('datetime', aDay);
    aQuery.AddParamPage(aPageInfo);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aDeviceVarList.Add do
      begin
        varType := TVarType(aQuery.FieldByName('varType').AsInteger);
        code := aQuery.FieldByName('varCode').AsString;
        name := aQuery.FieldByName('varName').AsString;
        VUnit := aQuery.FieldByName('varUnit').AsString;
        KV := aQuery.FieldByName('varKV').AsString;
        Note := aQuery.FieldByName('varNote').AsString;
      end;
      aQuery.Next;
    end;

    if aQuery.GotoNextRecordset then
    begin
      aPageInfo := aQuery.ReadPageInfo;
    end;

    if aQuery.GotoNextRecordset then
    begin
      aQuery.First;
      while not aQuery.Eof do
      begin
        with aDeviceRealDataList.Add do
        begin
          RealDateTime := aQuery.ReadFieldAsRDateTime('dateTime');
          RealData := aQuery.ReadFieldAsRString('realData');
          DataState := aQuery.ReadFieldAsRInteger('dataState');
        end;
        aQuery.Next;
      end;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetDeviceHourValueList(const aDevId: Integer;
                                  const aMeterValueCode: string;
                                  const aBeginDate: RDateTime;
                                  const aEndDate: RDateTime;
                                  const aHourValueList: THourValueDataList;
                                  var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aFieldStr: string;
begin
  Result := False;

  if aEndDate.IsNull then
    Exit;

  aFieldStr := aMeterValueCode;
  if aFieldStr = '' then
    aFieldStr := 'meterValue';

  try
    aQuery := TPrADOQuery.Create(DB_METER);
    try
      aQuery.ProcName := 'proc_GetHourDataList';
      aQuery.AddParamI('devId', aDevId);
      aQuery.AddParamS('meterValueCode', aFieldStr);
      aQuery.AddParamT('beginDatetime', aBeginDate);
      aQuery.AddParamT('endDatetime', aEndDate);
      aQuery.OpenProc;

      aQuery.First;
      while not aQuery.Eof do
      begin
        with aHourValueList.Add do
        begin
          Time := aQuery.FieldByName('datetime').AsDateTime;
          Date := aQuery.FieldByName('date').AsDateTime;
          Hour := aQuery.FieldByName('hour').AsInteger;
          Value := aQuery.FieldByName('value').AsFloat;
        end;

        aQuery.Next;
      end;
    finally
      aQuery.Free;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      aErrorInfo := E.Message;
    end;
  end;
end;

function doGetDeviceTenMinValueList(const aDevId: Integer;
                                    const aMeterValueCode: string;
                                    const aDateHour: TDateTime;
                                    const aHourValueList: THourValueDataList;
                                    var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aFieldStr: string;
begin
  Result := False;

  aFieldStr := aMeterValueCode;
  if aFieldStr = '' then
    aFieldStr := 'meterValue';

  try
    aQuery := TPrADOQuery.Create(DB_METER);
    try
      aQuery.ProcName := 'proc_GetTenMinDataList';
      aQuery.AddParamI('devId', aDevId);
      aQuery.AddParamS('meterValueCode', aFieldStr);
      aQuery.AddParamT('dateHour', aDateHour);
      aQuery.OpenProc;

      aQuery.First;
      while not aQuery.Eof do
      begin
        with aHourValueList.Add do
        begin
          Time := aQuery.FieldByName('datetime').AsDateTime;
          Hour := aQuery.FieldByName('hour').AsInteger;
          Value := aQuery.FieldByName('value').AsFloat;
        end;
        aQuery.Next;
      end;
    finally
      aQuery.Free;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      aErrorInfo := E.Message;
    end;
  end;
end;

function doDeleteRealData(const aDevModel: string;
                          const aDevId: string;
                          const aDeadline: TDateTime;
                          var aErrorInfo: string): Boolean;
begin
  Result := False;
  aErrorInfo := 'Ҳ��ͣ�õĽӿ�';
end;

end.
