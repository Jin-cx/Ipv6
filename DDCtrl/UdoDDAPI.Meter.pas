(*
 * API�ӿڵ�Ԫ (���������)
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 *
 * ˵��: ������
 *
 *
 * �޸�:
 * 2017-05-08 (v0.1)
 *   + ��һ�η���.
 *)

unit UdoDDAPI.Meter;

interface

uses
  Classes,
  puer.System,
  UDDDataInter, UDDTopoCacheInter, UDDModelsInter,
  UDDMeterData, UDDDeviceData, UDDDeviceModelData, UEnergyTypeData,
  UEnergyUseData;

// ȡ����������б�
function doGetMeterSortList(const aMeterSortList: TMeterSortDataList;
                            var aErrorInfo: string): Boolean; stdcall;
// ��ȡ Sort ����
function doGetMeterSortInfo(const aSortId: RInteger;
                            const aSortData: TMeterSortData;
                            var aErrorInfo: string): Boolean; stdcall;
// ��� Sort
function doAddMeterSort(const aSortData: TMeterSortData;
                        var aErrorInfo: string): Boolean; stdcall;
// �༭ Sort
function doUpdateMeterSort(const aSortData: TMeterSortData;
                           var aErrorInfo: string): Boolean; stdcall;
// ɾ�� Sort
function doDeleteMeterSort(const aSortId: RInteger;
                           var aErrorInfo: string): Boolean; stdcall;
// Sort ����
function doSortMeterSort(const aSortList: RString;
                         var aErrorInfo: string): Boolean; stdcall;


// ȡ�������б�
function doGetMeterList(const aSortId: RInteger;
                        const aEnergyTypeId: RInteger;
                        const aIsVirtual: RBoolean;
                        const aIsOnLine: RBoolean;
                        const aWithUse: RBoolean;
                        const aFilter: RString;
                        var aPageInfo: RPageInfo;
                        const aMeterList: TMeterDataList;
                        var aErrorInfo: string): Boolean; stdcall;
// ��ȡ ������ ����
function doGetMeterInfo(const aMeterId: RInteger;
                        const aMeterData: TMeterData;
                        var aErrorInfo: string): Boolean; stdcall;

// ��ȡ Meter ���� (���ݱ��)
function doGetMeterInfoByMeterCode(const aMeterCode: RString;
                                   const aMeterData: TMeterData;
                                   var aErrorInfo: string): Boolean; stdcall;

// ��� ������
function doAddMeter(const aMeterData: TMeterData;
                    var aErrorInfo: string): Boolean; stdcall;
// �༭ ������
function doUpdateMeter(const aMeterData: TMeterData;
                       var aErrorInfo: string): Boolean; stdcall;
// ɾ�� ������
function doDeleteMeter(const aMeterId: RInteger;
                       var aErrorInfo: string): Boolean; stdcall;

// ��ȡ�ܺķ����б�
function doGetEnergyTypeList(const aEnergyTypeList: TEnergyTypeDataList;
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
  doGetMeterSortList,
  doGetMeterSortInfo,
  doAddMeterSort,
  doUpdateMeterSort,
  doDeleteMeterSort,
  doSortMeterSort,
  doGetMeterList,
  doGetMeterInfo,
  doGetMeterInfoByMeterCode,
  doAddMeter,
  doUpdateMeter,
  doDeleteMeter,
  doGetEnergyTypeList,
  doGetMeterUse_HourSum,
  doGetMeterUse_DaySum,
  doGetMeterUse_MonthSum;

implementation

function doGetMeterSortList(const aMeterSortList: TMeterSortDataList;
                            var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetMeterSortList(aMeterSortList, aErrorInfo);
end;

function doGetMeterSortInfo(const aSortId: RInteger;
                            const aSortData: TMeterSortData;
                            var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetMeterSortInfo(aSortId, aSortData, aErrorInfo);
end;

function doAddMeterSort(const aSortData: TMeterSortData;
                        var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doAddMeterSort(aSortData, aErrorInfo);
end;

function doUpdateMeterSort(const aSortData: TMeterSortData;
                           var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doUpdateMeterSort(aSortData, aErrorInfo);
end;

function doDeleteMeterSort(const aSortId: RInteger;
                           var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doDeleteMeterSort(aSortId, aErrorInfo);
end;

function doSortMeterSort(const aSortList: RString;
                         var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doSortMeterSort(aSortList, aErrorInfo);
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
begin
  Result := _DDDataInter._doGetMeterList(aSortId, aEnergyTypeId, aIsVirtual,
    aIsOnLine, aWithUse, aFilter, aPageInfo, aMeterList, aErrorInfo);
end;

function doGetMeterInfo(const aMeterId: RInteger;
                        const aMeterData: TMeterData;
                        var aErrorInfo: string): Boolean;
begin
  Result := False;
end;

function doGetMeterInfoByMeterCode(const aMeterCode: RString;
                                   const aMeterData: TMeterData;
                                   var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetMeterInfoByMeterCode(aMeterCode, aMeterData, aErrorInfo);
end;

function doAddMeter(const aMeterData: TMeterData;
                    var aErrorInfo: string): Boolean;
var
  aDeviceData: TDeviceData;
  aDevModel: TDeviceModelData;
begin
  Result := False;

  aDeviceData := TDeviceData.Create;
  try
    if not _DDTopoCacheInter._doGetDeviceInfoByDevId(aMeterData.DeviceId.AsString, aDeviceData) then
    begin
      aErrorInfo := 'ָ�����豸������';
      Exit;
    end;

    aDevModel := TDeviceModelData.Create;
    try
      if not _DDModelsInter._doGetDeviceModelInfo(aDeviceData.devModel.AsString, aDevModel) then
      begin
        aErrorInfo := 'ָ�����豸����������';
        Exit;
      end;

      if aMeterData.MeterName.AsString = '' then
        aMeterData.MeterName := aDeviceData.name;
      //aMeterData.SortId.Value := 0;
      if aMeterData.MeterRate.IsNull then
        aMeterData.MeterRate.Value := aDevModel.MeterInfo.MeterRate;
      case aDevModel.MeterInfo.EnergyType of
        etElect:
          begin
            aMeterData.EnergyTypeId.Value := 1;
            aMeterData.EnergyTypeName.Value := '��';
            if aMeterData.MeterCode.AsString = '' then
              aMeterData.MeterCode.Value := 'D_' + aDeviceData.devId.AsString;
          end;
        etWater:
          begin
            aMeterData.EnergyTypeId.Value := 2;
            aMeterData.EnergyTypeName.Value := 'ˮ';
            if aMeterData.MeterCode.AsString = '' then
              aMeterData.MeterCode.Value := 'S_' + aDeviceData.devId.AsString;
          end;
      end;
      aMeterData.PayTypeId.Value := Ord(aDevModel.MeterInfo.PayType);
      aMeterData.RechargeTypeId.Value := Ord(aDevModel.MeterInfo.RechargeType);
      aMeterData.IsFrmPrice.Value := aDevModel.MeterInfo.IsFrmPrice;
      aMeterData.DeviceModel := aDeviceData.devModel;
      aMeterData.DeviceModelName := aDeviceData.devModelName;
      aMeterData.DevId := aDeviceData.id;
      aMeterData.isVirtual.Value := False;
    finally
      aDevModel.Free;
    end;

    Result := _DDDataInter._doAddMeter(aMeterData, aErrorInfo);
  finally
    aDeviceData.Free;
  end;




  {
    ��ѡ
    DeviceId

    ����
    SortId
    MeterName    Ĭ�ϱ������  (���ظ�, ��Լ��)
    MeterRate    ����
    MeterNote
    PayType              INTEGER,'                  // ��������  (1:Ԥ����; 2:�󸶷�)
    RechargeType         INTEGER,'                  // ��ֵ����  (1:������; 2:����)
    IsFrmPrice           INTEGER,'                  // Ӧ�õ���

    ����
    MeterId
    MeterCode  (���ɺ���ܸ�)

  }
end;

function doUpdateMeter(const aMeterData: TMeterData;
                       var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doUpdateMeter(aMeterData, aErrorInfo);
end;

function doDeleteMeter(const aMeterId: RInteger;
                       var aErrorInfo: string): Boolean;
begin
  Result := False;
end;

function doGetEnergyTypeList(const aEnergyTypeList: TEnergyTypeDataList;
                             var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetEnergyTypeList(aEnergyTypeList, aErrorInfo);
end;

function doGetMeterUse_HourSum(const aMeterCode: RString;
                               const aBeginDay: RDateTime;
                               const aEndDay: RDateTime;
                               const aShowNullUse: RBoolean;
                               const aUseList: TEnergyHourUseDataList;
                               var aError: RResult): Boolean;
begin
  Result := _DDDataInter._doGetMeterUse_HourSum(aMeterCode, aBeginDay, aEndDay, aShowNullUse, aUseList, aError);
end;

function doGetMeterUse_DaySum(const aMeterCode: RString;
                              const aBeginDay: RDateTime;
                              const aEndDay: RDateTime;
                              const aShowNullUse: RBoolean;
                              const aUseList: TEnergyDayUseDataList;
                              var aError: RResult): Boolean;
begin
  Result := _DDDataInter._doGetMeterUse_DaySum(aMeterCode, aBeginDay, aEndDay, aShowNullUse, aUseList, aError);
end;

function doGetMeterUse_MonthSum(const aMeterCode: RString;
                                const aBeginDay: RDateTime;
                                const aEndDay: RDateTime;
                                const aShowNullUse: RBoolean;
                                const aUseList: TEnergyMonthUseDataList;
                                var aError: RResult): Boolean;
begin
  Result := _DDDataInter._doGetMeterUse_MonthSum(aMeterCode, aBeginDay, aEndDay, aShowNullUse, aUseList, aError);
end;

end.
