(*
 * API接口单元 (计量点管理)
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 * 说明: 计量点
 *
 *
 * 修改:
 * 2017-05-08 (v0.1)
 *   + 第一次发布.
 *)

unit UdoDDAPI.Meter;

interface

uses
  Classes,
  puer.System,
  UDDDataInter, UDDTopoCacheInter, UDDModelsInter,
  UDDMeterData, UDDDeviceData, UDDDeviceModelData, UEnergyTypeData,
  UEnergyUseData;

// 取计量点分类列表
function doGetMeterSortList(const aMeterSortList: TMeterSortDataList;
                            var aErrorInfo: string): Boolean; stdcall;
// 获取 Sort 详情
function doGetMeterSortInfo(const aSortId: RInteger;
                            const aSortData: TMeterSortData;
                            var aErrorInfo: string): Boolean; stdcall;
// 添加 Sort
function doAddMeterSort(const aSortData: TMeterSortData;
                        var aErrorInfo: string): Boolean; stdcall;
// 编辑 Sort
function doUpdateMeterSort(const aSortData: TMeterSortData;
                           var aErrorInfo: string): Boolean; stdcall;
// 删除 Sort
function doDeleteMeterSort(const aSortId: RInteger;
                           var aErrorInfo: string): Boolean; stdcall;
// Sort 排序
function doSortMeterSort(const aSortList: RString;
                         var aErrorInfo: string): Boolean; stdcall;


// 取计量点列表
function doGetMeterList(const aSortId: RInteger;
                        const aEnergyTypeId: RInteger;
                        const aIsVirtual: RBoolean;
                        const aIsOnLine: RBoolean;
                        const aWithUse: RBoolean;
                        const aFilter: RString;
                        var aPageInfo: RPageInfo;
                        const aMeterList: TMeterDataList;
                        var aErrorInfo: string): Boolean; stdcall;
// 获取 计量点 详情
function doGetMeterInfo(const aMeterId: RInteger;
                        const aMeterData: TMeterData;
                        var aErrorInfo: string): Boolean; stdcall;

// 获取 Meter 详情 (根据编号)
function doGetMeterInfoByMeterCode(const aMeterCode: RString;
                                   const aMeterData: TMeterData;
                                   var aErrorInfo: string): Boolean; stdcall;

// 添加 计量点
function doAddMeter(const aMeterData: TMeterData;
                    var aErrorInfo: string): Boolean; stdcall;
// 编辑 计量点
function doUpdateMeter(const aMeterData: TMeterData;
                       var aErrorInfo: string): Boolean; stdcall;
// 删除 计量点
function doDeleteMeter(const aMeterId: RInteger;
                       var aErrorInfo: string): Boolean; stdcall;

// 获取能耗分类列表
function doGetEnergyTypeList(const aEnergyTypeList: TEnergyTypeDataList;
                             var aErrorInfo: string): Boolean; stdcall;

// 小时用能汇总
function doGetMeterUse_HourSum(const aMeterCode: RString;
                               const aBeginDay: RDateTime;
                               const aEndDay: RDateTime;
                               const aShowNullUse: RBoolean;
                               const aUseList: TEnergyHourUseDataList;
                               var aError: RResult): Boolean; stdcall;

// 天用能汇总
function doGetMeterUse_DaySum(const aMeterCode: RString;
                              const aBeginDay: RDateTime;
                              const aEndDay: RDateTime;
                              const aShowNullUse: RBoolean;
                              const aUseList: TEnergyDayUseDataList;
                              var aError: RResult): Boolean; stdcall;

// 月用能汇总
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
      aErrorInfo := '指定的设备不存在';
      Exit;
    end;

    aDevModel := TDeviceModelData.Create;
    try
      if not _DDModelsInter._doGetDeviceModelInfo(aDeviceData.devModel.AsString, aDevModel) then
      begin
        aErrorInfo := '指定的设备驱动不存在';
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
            aMeterData.EnergyTypeName.Value := '电';
            if aMeterData.MeterCode.AsString = '' then
              aMeterData.MeterCode.Value := 'D_' + aDeviceData.devId.AsString;
          end;
        etWater:
          begin
            aMeterData.EnergyTypeId.Value := 2;
            aMeterData.EnergyTypeName.Value := '水';
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
    必选
    DeviceId

    输入
    SortId
    MeterName    默认表具名称  (可重复, 不约束)
    MeterRate    倍率
    MeterNote
    PayType              INTEGER,'                  // 付费类型  (1:预付费; 2:后付费)
    RechargeType         INTEGER,'                  // 充值类型  (1:充用量; 2:充金额)
    IsFrmPrice           INTEGER,'                  // 应用单价

    返回
    MeterId
    MeterCode  (生成后才能改)

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
