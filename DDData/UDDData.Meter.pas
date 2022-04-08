unit UDDData.Meter;

interface

uses
  Classes, SysUtils, Generics.Collections, Windows, DateUtils,
  puer.System, puer.SyncObjs, puer.Json.JsonDataObjects, puer.TTS,
  UPrDbConnInter,
  UDDMeterData, UEnergyTypeData, UEnergyUseData,
  UDDHourDosageData,
  UDDData.Config;

const
  ERROR_QUERY_METER_SORT_LIST    = '��ȡ����������б����:%s';
  ERROR_QUERY_METER_LIST         = '��ȡ�������б����:%s';
  ERROR_QUERY_METER_SORT         = '��ȡ������������:%s';
  ERROR_QUERY_METER              = '��ȡ���������:%s';

  ERROR_METER_SORT_NOT_EXISTS    = 'ָ���ļ�������಻����';
  ERROR_METER_NOT_EXISTS         = 'ָ���ļ����㲻����';


  //ERROR_USER_NOT_EXISTS        = '�û������ڻ��ѱ�ɾ��';
  //ERROR_USER_OR_PASSWORD_ERROR = '�û������������';
  //ERROR_QUERY_USER_INFO        = '��ȡ�û��������:%s';

  //ERROR_ADD_USER               = '�����û�����:%s';
  //ERROR_UPDATE_USER            = '�༭�û�����:%s';
  //ERROR_USER_CODE_NULL         = '�û���Ų���Ϊ��';
  //ERROR_USER_NAME_NULL         = '�û����Ʋ���Ϊ��';
  //ERROR_USER_CODE_EXISTS       = '�û�����Ѵ���';
  //ERROR_USER_NAME_EXISTS       = '�û������Ѵ���';

function doGetMeterList(const aSortId: RInteger;
                        const aEnergyTypeId: RInteger;
                        const aIsVirtual: RBoolean;
                        const aIsOnLine: RBoolean;
                        const aWithUse: RBoolean;
                        const aFilter: RString;
                        var aPageInfo: RPageInfo;
                        const aMeterList: TMeterDataList;
                        var aErrorInfo: string): Boolean; stdcall;

function doGetMeterListByDevId(const aDevNo: RString;
                               const aMeterList: TMeterDataList;
                               var aErrorInfo: string): Boolean; stdcall;

function doGetMeterInfo(const aMeterId: RInteger;
                        const aMeter: TMeterData;
                        var aErrorInfo: string): Boolean; stdcall;
function doGetMeterInfoByMeterCode(const aMeterCode: RString;
                                   const aMeter: TMeterData;
                                   var aErrorInfo: string): Boolean; stdcall;

// ��Ӽ�����
function doAddMeter(const aMeter: TMeterData;
                    var aErrorInfo: string): Boolean; stdcall;

// �༭������
function doUpdateMeter(const aMeter: TMeterData;
                       var aErrorInfo: string): Boolean; stdcall;

// ɾ��������
function doDeleteMeter(const aMeterId: RInteger;
                       var aErrorInfo: string): Boolean; stdcall;



// ------------------ ������� -----------------------------
// ��ȡ�ܺķ����б�
function doGetEnergyTypeList(const aEnergyTypeList: TEnergyTypeDataList;
                             var aErrorInfo: string): Boolean; stdcall;

// ȡ���������һ��Сʱ����
function doGetMeterLastHourData(const aMeterId: Integer;
                                const aDevId: Integer;
                                const aHourDosageList: THourDosageDataList;
                                var aErrorInfo: string): Boolean; stdcall;

// ��������� Сʱ�����б�
function doAddMeterHourDataList(const aMeterId: Integer;
                                const aHourDosageList: THourDosageDataList;
                                var aErrorInfo: string): Boolean; stdcall;

// ��ȡ���м������б�
function doGetAllMeterList(const aMeterList: TMeterDataList;
                           var aErrorInfo: string): Boolean; stdcall;

// ���¼�����ʵʱ����
function doUpdateMeterRealData(const aMeterId: Integer;
                               const aLastDataTime: RDatetime;
                               const aLastMeterValue: RDouble;
                               var aErrorInfo: string): Boolean; stdcall;

// ���������
function doGetMeterSortList(const aMeterSortList: TMeterSortDataList;
                            var aErrorInfo: string): Boolean; stdcall;
function doGetMeterSortInfo(const aSortId: RInteger;
                            const aSort: TMeterSortData;
                            var aErrorInfo: string): Boolean; stdcall;
function doAddMeterSort(const aSort: TMeterSortData;
                        var aErrorInfo: string): Boolean; stdcall;
function doUpdateMeterSort(const aSort: TMeterSortData;
                           var aErrorInfo: string): Boolean; stdcall;
function doDeleteMeterSort(var aSortId: RInteger;
                           var aErrorInfo: string): Boolean; stdcall;
function doSortMeterSort(const aSortList: RString;
                         var aErrorInfo: string): Boolean; stdcall;


// Сʱ���ܻ���
function doGetMeterUse_HourSum(const aMeterCode: RString;
                               const aBeginDay: RDateTime;
                               const aEndDay: RDateTime;
                               const aShowNullUse: RBoolean;
                               const aUseList: TEnergyHourUseDataList;
                               var aError: RResult): Boolean; stdcall;

// �����ܻ���
function doGetMeterUse_DaySum(const aMeterCode: RString;
                              const aBeginDay: RDateTime;
                              const aEndDay: RDateTime;
                              const aShowNullUse: RBoolean;
                              const aUseList: TEnergyDayUseDataList;
                              var aError: RResult): Boolean; stdcall;

// �����ܻ���
function doGetMeterUse_MonthSum(const aMeterCode: RString;
                                const aBeginDay: RDateTime;
                                const aEndDay: RDateTime;
                                const aShowNullUse: RBoolean;
                                const aUseList: TEnergyMonthUseDataList;
                                var aError: RResult): Boolean; stdcall;


exports

  doGetMeterList,
  doGetMeterListByDevId,
  doGetMeterInfo,
  doGetMeterInfoByMeterCode,
  doAddMeter,
  doUpdateMeter,
  doDeleteMeter,


  doGetEnergyTypeList,
  doGetMeterLastHourData,
  doAddMeterHourDataList,
  doGetAllMeterList,
  doUpdateMeterRealData,
  doGetMeterSortList,
  doGetMeterSortInfo,
  doAddMeterSort,
  doUpdateMeterSort,
  doDeleteMeterSort,
  doSortMeterSort,
  doGetMeterUse_HourSum,
  doGetMeterUse_DaySum,
  doGetMeterUse_MonthSum;

implementation








function doGetEnergyTypeList(const aEnergyTypeList: TEnergyTypeDataList;
                             var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetEnergyTypeList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aEnergyTypeList.Add do
      begin
        energyTypeId := aQuery.ReadFieldAsRInteger('energyTypeId');
        energyTypeCode := aQuery.ReadFieldAsRString('energyTypeCode');
        energyTypeName := aQuery.ReadFieldAsRString('energyTypeName');
        unit_en := aQuery.ReadFieldAsRString('unit_en');
        unit_zh := aQuery.ReadFieldAsRString('unit_zh');
        citeCount := aQuery.ReadFieldAsRInteger('citeCount');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetMeterLastHourData(const aMeterId: Integer;
                                const aDevId: Integer;
                                const aHourDosageList: THourDosageDataList;
                                var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetMeterLastHourData';
    aQuery.AddParamI('meterId', aMeterId);
    aQuery.AddParamI('devId', aDevId);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aHourDosageList.Add do
      begin
        Date := aQuery.ReadFieldAsRDateTime('Date').Value;
        Hour := HourOf(aQuery.ReadFieldAsRDateTime('Date').Value) + 1;
        DevId := aDevId;
        BeginValue := aQuery.ReadFieldAsRDouble('BeginValue');
        BeginTime := aQuery.ReadFieldAsRDateTime('BeginTime');
        EndValue := aQuery.ReadFieldAsRDouble('EndValue');
        EndTime := aQuery.ReadFieldAsRDateTime('EndTime');
        Dosage := aQuery.ReadFieldAsRDouble('Dosage');
        DataType := aQuery.FieldByName('DataType').AsInteger;
      end;

      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doAddMeterHourDataList(const aMeterId: Integer;
                                const aHourDosageList: THourDosageDataList;
                                var aErrorInfo: string): Boolean;
const
  TVP_FIELDS = 'devId,[date],dataType,beginValue,beginTime,endValue,endTime,dosage,dosage_Ten1,dosage_Ten2,dosage_Ten3,dosage_Ten4,dosage_Ten5,dosage_Ten6,isStatis';

  procedure doAddMeterHourDataList(const aQuery: TPrADOQuery;
                                   const aMeterId: Integer;
                                   const aTVPs: TPrTVPs);


  begin
    aQuery.ClearParamList;
    aQuery.ProcName := 'proc_AddMeterHourDataList_TVPs';
    aQuery.AddParamI('meterId', aMeterId);
    aQuery.AddParamTVPs('hourDataList', aTVPs);
    aQuery.ExecProc;

    aTVPs.ClearRecords;
  end;

var
  aQuery: TPrADOQuery;
  aTVPs: TPrTVPs;
  aHourData: THourDosageData;
begin
  if aHourDosageList.Count = 0 then
    Exit(True);

  aQuery := TPrADOQuery.Create(DB_METER);
  aTVPs := TPrTVPs.Create('hourDatas', 'TMeterHourDataList', TVP_FIELDS);
  try
    for aHourData in aHourDosageList do
    begin
      if (not aHourData.Dosage.IsNull) or (not aHourData.isStatis.IsTrue) then
      begin
      with aTVPs.AddRecord do
      begin
        AddValue(aHourData.devId);
        AddValue(IncHour(Trunc(aHourData.Date), aHourData.Hour - 1));
        AddValue(aHourData.DataType);
        AddValue(aHourData.BeginValue);
        AddValue(aHourData.BeginTime);
        AddValue(aHourData.EndValue);
        AddValue(aHourData.EndTime);
        AddValue(aHourData.Dosage);
        AddValue(aHourData.dosage_Ten1);
        AddValue(aHourData.dosage_Ten2);
        AddValue(aHourData.dosage_Ten3);
        AddValue(aHourData.dosage_Ten4);
        AddValue(aHourData.dosage_Ten5);
        AddValue(aHourData.dosage_Ten6);
        AddValue(aHourData.isStatis);
      end;
      end;

      if aTVPs.RecCount = 1000 then
        doAddMeterHourDataList(aQuery, aMeterId, aTVPs);
    end;

    if aTVPs.RecCount > 0 then
      doAddMeterHourDataList(aQuery, aMeterId, aTVPs);

    Result := True;
  finally
    aQuery.Free;
    aTVPs.Free;
  end;
end;

function doGetAllMeterList(const aMeterList: TMeterDataList;
                           var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetAllMeterList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aMeterList.Add do
      begin
        meterId := aQuery.ReadFieldAsRInteger('meterId');
        MeterCode := aQuery.ReadFieldAsRString('MeterCode');
        devId := aQuery.ReadFieldAsRInteger('devId');
        meterValueCode := aQuery.ReadFieldAsRString('meterValueCode');
        isVirtual := aQuery.ReadFieldAsRBoolean('isVirtual');
        meterRate := aQuery.ReadFieldAsRDouble('meterRate');
      end;

      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doUpdateMeterRealData(const aMeterId: Integer;
                               const aLastDataTime: RDatetime;
                               const aLastMeterValue: RDouble;
                               var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_UpdateMeterRealData';
    aQuery.AddParamI('meterId', aMeterId);
    aQuery.AddParamT('lastDataTime', aLastDataTime);
    aQuery.AddParamD('lastMeterValue', aLastMeterValue);
    aQuery.ExecProc;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetMeterSortList(const aMeterSortList: TMeterSortDataList;
                            var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetMeterSortList';
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aMeterSortList.Add do
      begin
        SortId := aQuery.ReadFieldAsRInteger('sortId');
        ParentId := aQuery.ReadFieldAsRInteger('parentId');
        SortName := aQuery.ReadFieldAsRString('sortName');
      end;

      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetMeterSortInfo(const aSortId: RInteger;
                            const aSort: TMeterSortData;
                            var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetMeterSortInfo';
    aQuery.AddParamI('sortId', aSortId);
    aQuery.OpenProc;

    if aQuery.ReadSQLResult(aError) then
    begin
      aQuery.First;

      aSort.SortId := aQuery.ReadFieldAsRInteger('sortId');
      aSort.ParentId := aQuery.ReadFieldAsRInteger('parentId');
      aSort.SortName := aQuery.ReadFieldAsRString('sortName');

      Result := True;
    end
    else
    begin
      aErrorInfo := aError.Info;
      Result := False;
    end;
  finally
    aQuery.Free;
  end;
end;

function doAddMeterSort(const aSort: TMeterSortData;
                        var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_AddMeterSort';
    aQuery.AddParamI('parentId', aSort.parentId);
    aQuery.AddParamS('sortName', aSort.sortName);
    aQuery.OpenProc;

    if aQuery.ReadSQLResult(aError) then
    begin
      aSort.sortId := aQuery.ReadFieldAsRInteger('sortId');

      Result := True;
    end
    else
    begin
      aErrorInfo := aError.Info;
      Result := False;
    end;
  finally
    aQuery.Free;
  end;
end;

function doUpdateMeterSort(const aSort: TMeterSortData;
                           var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_UpdateMeterSort';
    aQuery.AddParamI('sortId', aSort.sortId);
    aQuery.AddParamS('sortName', aSort.sortName);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function doDeleteMeterSort(var aSortId: RInteger;
                           var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_DeleteMeterSort';
    aQuery.AddParamI('sortId', aSortId);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function doSortMeterSort(const aSortList: RString;
                         var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aSortListXml: string;
  aJsonList: TJsonArray;
  aXmlList: TPrXmlList;
  aXmlItem: TPrXmlItem;
  i: Integer;
  aError: RResult;
begin
  aJsonList := TJsonArray.Create;
  aXmlList := TPrXmlList.Create;
  try
    aJsonList.FromJSON(aSortList.AsString);
    for i := 0 to aJsonList.Count - 1 do
    begin
      aXmlItem := aXmlList.Add;
      aXmlItem.SetKeyValue('sortId', aJsonList.O[i].I['sortId']);
      aXmlItem.SetKeyValue('parentId', aJsonList.O[i].I['parentId']);
    end;

    aSortListXml := aXmlList.XmlText;
  finally
    aXmlList.Free;
    aJsonList.Free;
  end;

  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_SortMeterSort';
    aQuery.AddParamS('sortList', aSortListXml);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    aErrorInfo := aError.Info;
  finally
    aQuery.Free;
  end;
end;

function doGetMeterUse_HourSum(const aMeterCode: RString;
                               const aBeginDay: RDateTime;
                               const aEndDay: RDateTime;
                               const aShowNullUse: RBoolean;
                               const aUseList: TEnergyHourUseDataList;
                               var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_MeterUse_HourSum';
    aQuery.AddParamS('meterCode', aMeterCode);
    aQuery.AddParamT('beginDay', aBeginDay);
    aQuery.AddParamT('endDay', aEndDay);
    aQuery.AddParamB('showNullUse', aShowNullUse);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aUseList.Add do
      begin
        dayHour := aQuery.ReadFieldAsRDateTime('dayHour');
        dosage := aQuery.ReadFieldAsRDouble('dosage');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetMeterUse_DaySum(const aMeterCode: RString;
                              const aBeginDay: RDateTime;
                              const aEndDay: RDateTime;
                              const aShowNullUse: RBoolean;
                              const aUseList: TEnergyDayUseDataList;
                              var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_MeterUse_DaySum';
    aQuery.AddParamS('meterCode', aMeterCode);
    aQuery.AddParamT('beginDay', aBeginDay);
    aQuery.AddParamT('endDay', aEndDay);
    aQuery.AddParamB('showNullUse', aShowNullUse);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aUseList.Add do
      begin
        day := aQuery.ReadFieldAsRDateTime('day');
        dosage := aQuery.ReadFieldAsRDouble('dosage');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetMeterUse_MonthSum(const aMeterCode: RString;
                                const aBeginDay: RDateTime;
                                const aEndDay: RDateTime;
                                const aShowNullUse: RBoolean;
                                const aUseList: TEnergyMonthUseDataList;
                                var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_MeterUse_MonthSum';
    aQuery.AddParamS('meterCode', aMeterCode);
    aQuery.AddParamT('beginDay', aBeginDay);
    aQuery.AddParamT('endDay', aEndDay);
    aQuery.AddParamB('showNullUse', aShowNullUse);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aUseList.Add do
      begin
        year := aQuery.ReadFieldAsRInteger('year');
        month := aQuery.ReadFieldAsRInteger('month');
        dosage := aQuery.ReadFieldAsRDouble('dosage');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;







function doGetMeterList(const aSortId: RInteger;
                        const aEnergyTypeId: RInteger;
                        const aIsVirtual: RBoolean;
                        const aIsOnLine: RBoolean;
                        const aWithUse: RBoolean;
                        const aFilter: RString;
                        var aPageInfo: RPageInfo;
                        const aMeterList: TMeterDataList;
                        var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetMeterList';
    aQuery.AddParamI('sortId', aSortId);
    aQuery.AddParamI('energyTypeId', aEnergyTypeId);
    aQuery.AddParamB('isVirtual', aIsVirtual);
    aQuery.AddParamB('isOnLine', aIsOnLine);
    //aQuery.AddParamB('withUse', aWithUse);
    aQuery.AddParamS('filter', aFilter);
    aQuery.AddParamPage(aPageInfo);
    aQuery.OpenProc;

    aPageInfo := aQuery.ReadPageInfo;

    if aQuery.GotoNextRecordset then
    begin
      aQuery.First;
      while not aQuery.Eof do
      begin
        with aMeterList.Add do
        begin
          SortId := aQuery.ReadFieldAsRInteger('SortId');
          MeterCode := aQuery.ReadFieldAsRString('MeterCode');
          MeterName := aQuery.ReadFieldAsRString('MeterName');
          MeterNote := aQuery.ReadFieldAsRString('MeterNote');
          MeterVersion := aQuery.ReadFieldAsRInteger('MeterVersion');
          MeterRate := aQuery.ReadFieldAsRDouble('MeterRate');
          EnergyTypeId := aQuery.ReadFieldAsRInteger('EnergyTypeId');
          EnergyTypeName := aQuery.ReadFieldAsRString('EnergyTypeName');
          unit_en := aQuery.ReadFieldAsRString('unit_en');
          unit_zh := aQuery.ReadFieldAsRString('unit_zh');
          PayTypeId := aQuery.ReadFieldAsRInteger('PayTypeId');
          RechargeTypeId := aQuery.ReadFieldAsRInteger('RechargeTypeId');
          IsFrmPrice := aQuery.ReadFieldAsRBoolean('IsFrmPrice');
          DeviceId := aQuery.ReadFieldAsRString('DeviceId');
          MeterValueCode := aQuery.ReadFieldAsRString('MeterValueCode');
          DeviceModel := aQuery.ReadFieldAsRString('DeviceModel');
          DeviceModelName := aQuery.ReadFieldAsRString('DeviceModelName');
          DeviceFactoryNo := aQuery.ReadFieldAsRString('DeviceFactoryNo');
          isVirtual := aQuery.ReadFieldAsRBoolean('isVirtual');
          onLine := aQuery.ReadFieldAsRBoolean('onLine');
          lastDataTime := aQuery.ReadFieldAsRDateTime('lastDataTime');
          lastMeterValue := aQuery.ReadFieldAsRDouble('lastMeterValue');
          todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');
          //hourUse := aQuery.ReadFieldAsRString('hourUse');
          hourUse.Value := '[]';
        end;

        aQuery.Next;
      end;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetMeterListByDevId(const aDevNo: RString;
                               const aMeterList: TMeterDataList;
                               var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetMeterListByDevNo';
    aQuery.AddParamS('devNo', aDevNo);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aMeterList.Add do
      begin
        SortId := aQuery.ReadFieldAsRInteger('SortId');
        MeterCode := aQuery.ReadFieldAsRString('MeterCode');
        MeterName := aQuery.ReadFieldAsRString('MeterName');
        MeterNote := aQuery.ReadFieldAsRString('MeterNote');
        MeterVersion := aQuery.ReadFieldAsRInteger('MeterVersion');
        MeterRate := aQuery.ReadFieldAsRDouble('MeterRate');
        EnergyTypeId := aQuery.ReadFieldAsRInteger('EnergyTypeId');
        EnergyTypeName := aQuery.ReadFieldAsRString('EnergyTypeName');
        unit_en := aQuery.ReadFieldAsRString('unit_en');
        unit_zh := aQuery.ReadFieldAsRString('unit_zh');
        PayTypeId := aQuery.ReadFieldAsRInteger('PayTypeId');
        RechargeTypeId := aQuery.ReadFieldAsRInteger('RechargeTypeId');
        IsFrmPrice := aQuery.ReadFieldAsRBoolean('IsFrmPrice');
        DeviceId := aQuery.ReadFieldAsRString('DeviceId');
        MeterValueCode := aQuery.ReadFieldAsRString('MeterValueCode');
        DeviceModel := aQuery.ReadFieldAsRString('DeviceModel');
        DeviceModelName := aQuery.ReadFieldAsRString('DeviceModelName');
        DeviceFactoryNo := aQuery.ReadFieldAsRString('DeviceFactoryNo');
        isVirtual := aQuery.ReadFieldAsRBoolean('isVirtual');
        onLine := aQuery.ReadFieldAsRBoolean('onLine');
        lastDataTime := aQuery.ReadFieldAsRDateTime('lastDataTime');
        lastMeterValue := aQuery.ReadFieldAsRDouble('lastMeterValue');
        todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');
      end;

      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doGetMeterInfo(const aMeterId: RInteger;
                        const aMeter: TMeterData;
                        var aErrorInfo: string): Boolean;
begin
  Result := False;
end;

function doGetMeterInfoByMeterCode(const aMeterCode: RString;
                                   const aMeter: TMeterData;
                                   var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aResult: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetMeterInfo';
    //aQuery.AddParamS('diggerCode', DIGGER_CODE);
    aQuery.AddParamS('meterCode', aMeterCode);
    aQuery.OpenProc;

    if not aQuery.ReadSQLResult(aResult) then
    begin
      aErrorInfo := aResult.Info;
      Exit(False);
    end;

    with aMeter do
    begin
      SortId := aQuery.ReadFieldAsRInteger('SortId');
      MeterCode := aQuery.ReadFieldAsRString('MeterCode');
      MeterName := aQuery.ReadFieldAsRString('MeterName');
      MeterNote := aQuery.ReadFieldAsRString('MeterNote');
      MeterVersion := aQuery.ReadFieldAsRInteger('MeterVersion');
      MeterRate := aQuery.ReadFieldAsRDouble('MeterRate');
      EnergyTypeId := aQuery.ReadFieldAsRInteger('EnergyTypeId');
      EnergyTypeName := aQuery.ReadFieldAsRString('EnergyTypeName');
      unit_en := aQuery.ReadFieldAsRString('unit_en');
      unit_zh := aQuery.ReadFieldAsRString('unit_zh');
      PayTypeId := aQuery.ReadFieldAsRInteger('PayTypeId');
      RechargeTypeId := aQuery.ReadFieldAsRInteger('RechargeTypeId');
      IsFrmPrice := aQuery.ReadFieldAsRBoolean('IsFrmPrice');
      DeviceId := aQuery.ReadFieldAsRString('DeviceId');
      DeviceModel := aQuery.ReadFieldAsRString('DeviceModel');
      DeviceModelName := aQuery.ReadFieldAsRString('DeviceModelName');
      DeviceFactoryNo := aQuery.ReadFieldAsRString('DeviceFactoryNo');
      isVirtual := aQuery.ReadFieldAsRBoolean('isVirtual');
      onLine := aQuery.ReadFieldAsRBoolean('onLine');
      lastDataTime := aQuery.ReadFieldAsRDateTime('lastDataTime');
      lastMeterValue := aQuery.ReadFieldAsRDouble('lastMeterValue');
      todayOnLineRate := aQuery.ReadFieldAsRDouble('todayOnLineRate');
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doAddMeter(const aMeter: TMeterData;
                    var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aResult: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_AddMeter';
    aQuery.AddParamS('meterCode', aMeter.MeterCode);
    aQuery.AddParamS('meterName', aMeter.MeterName);
    aQuery.AddParamD('meterRate', aMeter.MeterRate);
    aQuery.AddParamB('isVirtual', aMeter.isVirtual);
    aQuery.AddParamI('sortId', aMeter.SortId);
    aQuery.AddParamI('devId', aMeter.DevId);
    aQuery.AddParamS('meterValueCode', aMeter.MeterValueCode);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aResult);
    if not Result then
      aErrorInfo := aResult.Info;
  finally
    aQuery.Free;
  end;
end;

function doUpdateMeter(const aMeter: TMeterData;
                       var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
begin
  Result := False;

    aSQLStr := 'update tb_Meters '
             + ' set SortId = ' + aMeter.SortId.AsString
             //+ ' ,   MeterCode = ' + QuotedStr(aMeter.MeterCode.AsString)
             + ' ,   MeterName = ' + QuotedStr(aMeter.MeterName.AsString)
             + ' ,   MeterNote = ' + QuotedStr(aMeter.MeterNote.AsString)
             + ' ,   MeterRate = ' + aMeter.MeterRate.AsString
             //+ ' ,   EnergyType = ' + aMeter.EnergyType.AsString
             //+ ' ,   PayType = ' + aMeter.PayType.AsString
             //+ ' ,   RechargeType = ' + aMeter.RechargeType.AsString
             //+ ' ,   IsFrmPrice = ' + aMeter.IsFrmPrice.AsIntString
             //+ ' ,   DeviceId = ' + QuotedStr(aMeter.DeviceId.AsString)
             //+ ' ,   DeviceModel = ' + QuotedStr(aMeter.DeviceModel.AsString)
             //+ ' ,   DeviceModelName = ' + QuotedStr(aMeter.DeviceModelName.AsString)
             + ' WHERE MeterId = ' + aMeter.MeterId.AsString + ';';

    //Result := FSQLiteWrite.ExecSQL(aSQLStr) = 1;
end;

function doDeleteMeter(const aMeterId: RInteger;
                       var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
begin
  Result := False;

  if aMeterId.IsNull then
  begin
    aErrorInfo := ERROR_METER_NOT_EXISTS;
    Exit;
  end;

    aSQLStr := ' DELETE FROM tb_Meters '
             + ' WHERE MeterId = ' + aMeterId.AsString + ';';
    //Result := FSQLiteWrite.ExecSQL(aSQLStr) = 1;

end;

end.
