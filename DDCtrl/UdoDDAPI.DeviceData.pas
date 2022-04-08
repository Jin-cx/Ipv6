(*
 * API�ӿڵ�Ԫ (�豸��ʷ���ݵĲ�ѯ�͹���)
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 *
 * ˵��: �豸��ʷ���ݵĲ�ѯ,  ������ݵȲ���
 *
 *
 * �޸�:
 * 2016-12-08 (v0.1)
 *   + ��һ�η���.
 *)

unit UdoDDAPI.DeviceData;

interface

uses
  Classes,
  puer.System,
  UDDDataInter, {UDDTopoCacheInter,} UDDModelsInter,
  UDDDeviceRealData, UDDFileListData, UDDDeviceData, UDDDeviceModelData;


// ��ȡ�����ļ����б�
function doGetRealDataFolderList(const aDevModelList: TDeviceModelDataList;
                                 var aErrorInfo: string): Boolean; stdcall;
// ��ȡ�����ļ��б�
function doGetRealDataFileList(const aDevModel: RString;
                               const aDeviceList: TDeviceDataList;
                               var aErrorInfo: string): Boolean; stdcall;
// ��ȡʵʱ����
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
