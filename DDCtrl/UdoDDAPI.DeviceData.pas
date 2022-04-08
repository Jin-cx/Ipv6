(*
 * API接口单元 (设备历史数据的查询和管理)
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 * 说明: 设备历史数据的查询,  清空数据等操作
 *
 *
 * 修改:
 * 2016-12-08 (v0.1)
 *   + 第一次发布.
 *)

unit UdoDDAPI.DeviceData;

interface

uses
  Classes,
  puer.System,
  UDDDataInter, {UDDTopoCacheInter,} UDDModelsInter,
  UDDDeviceRealData, UDDFileListData, UDDDeviceData, UDDDeviceModelData;


// 获取数据文件夹列表
function doGetRealDataFolderList(const aDevModelList: TDeviceModelDataList;
                                 var aErrorInfo: string): Boolean; stdcall;
// 获取数据文件列表
function doGetRealDataFileList(const aDevModel: RString;
                               const aDeviceList: TDeviceDataList;
                               var aErrorInfo: string): Boolean; stdcall;
// 获取实时数据
function doGetDeviceRealDataList(const aDevId: string;
                                 const aDay: TDateTime;
                                 var aPageInfo: RPageInfo;
                                 const aDeviceVarList: TDeviceVarDataList;
                                 const aDeviceRealDataList: TDeviceRealDataList;
                                 var aErrorInfo: string): Boolean; stdcall;


exports
  doGetRealDataFolderList,
  doGetRealDataFileList,
  doGetDeviceRealDataList;

implementation

function doGetRealDataFolderList(const aDevModelList: TDeviceModelDataList;
                                 var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetRealDataFolderList(aDevModelList, aErrorInfo);
end;

function doGetRealDataFileList(const aDevModel: RString;
                               const aDeviceList: TDeviceDataList;
                               var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetRealDataFileList(aDevModel, aDeviceList, aErrorInfo);
end;

function doGetDeviceRealDataList(const aDevId: string;
                                 const aDay: TDateTime;
                                 var aPageInfo: RPageInfo;
                                 const aDeviceVarList: TDeviceVarDataList;
                                 const aDeviceRealDataList: TDeviceRealDataList;
                                 var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetDeviceRealDataList(aDevId,
                                                  aDay,
                                                  aPageInfo,
                                                  aDeviceVarList,
                                                  aDeviceRealDataList,
                                                  aErrorInfo);
end;

end.
