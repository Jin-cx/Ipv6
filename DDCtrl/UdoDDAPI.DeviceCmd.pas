(*
 * API�ӿڵ�Ԫ (�豸����)
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 *
 * ˵��: ��ָ���豸ִ��ָ��������(����Ľӿ�)
 *       �����ŵ��ṩ�ز�
 *
 *
 * �޸�:
 * 2016-12-08 (v0.1)
 *   + ��һ�η���.
 *)

unit UdoDDAPI.DeviceCmd;

interface

uses
  SysUtils, Windows,
  puer.System,
  UDDDataInter, UDDTopoCacheInter, UDDCommInter, UDDModelsInter,
  UDDCommData, UDDRequestData;

// ͬ����������
function doSendCmdSync(const aUserName: string;               // �˻�
                       const aDevId: string;                  // �ն��豸�豸���
                       const aBatchNo: string;                // ����ִ������(�ɿ�)
                       const aCmdName: string;                // ��������
                       const aCmd: string;                    // ����
                       const aCmdData: string;                // ��������
                       const aInfo: string;                   // ����ִ������
                       const aTimeOut: Integer;               // ��ʱʱ�� ��
                       var aResult: Integer;                  // ִ�н��
                       var aReceiveCmdData: TCommDataInfo;    // Ӧ��ı���
                       var aErrorCode: string;
                       var aErrorInfo: string): Boolean; stdcall;

// ����������Ϣ
function doSetCmdInfo(const aUserName: string;                // �˻�
                      const aBatchNo: string;                 // ����ִ������
                      const aInfo: string;                    // ����ִ������
                      var aErrorInfo: string): Boolean; stdcall;

// ��ȡ�����б�
function doGetRequestList(const aUserName: RString;              // �˻�
                          const aRequestId: RString;             // ��������
                          const aDevId: RString;                 // �ն��豸�豸���
                          const aDateBegin: RDateTime;           // ��ʼ����
                          const aDateEnd: RDateTime;             // ��������
                          const aResult: RInteger;               //
                          const aFilter: RString;                // ģ������
                          var aPageInfo: RPageInfo;              // ��ҳ
                          const aRequestList: TRequestDataList;  // ���ص������б�
                          var aErrorInfo: string): Boolean; stdcall;

// ��ȡ��������
function doGetRequestInfo(const aUserCode: RString;
                          const aRequestId: RString;             // ��������
                          const aRequest: TRequestData;          // ���ص�����
                          var aError: RResult): Boolean; stdcall;

// �˹�������������״̬
function doSetDoubtRequestResult(const aUserCode: RString;
                                 const aRequestId: RString;
                                 const aResult: RBoolean;
                                 var aErrorInfo: string): Boolean; stdcall;

exports
  doSendCmdSync,
  doSetCmdInfo,
  doGetRequestList,
  doGetRequestInfo,
  doSetDoubtRequestResult;

implementation

function doSendCmdSync(const aUserName: string;
                       const aDevId: string;
                       const aBatchNo: string;
                       const aCmdName: string;
                       const aCmd: string;
                       const aCmdData: string;
                       const aInfo: string;
                       const aTimeOut: Integer;
                       var aResult: Integer;
                       var aReceiveCmdData: TCommDataInfo;
                       var aErrorCode: string;
                       var aErrorInfo: string): Boolean;
var
  aBrokerId: Int64;
  aGatewayDevId: string;
  aGatewayModel: string;
  aDeviceModel: string;
  aHasResult: Boolean;
  aSendCmdData: TCommDataInfo;
  aError: RResult;
begin
  Result := False;

  // ���ն��豸��Ϣ
  //if not _DDDataInter._doGetDeviceInfoForCmd(aDevId, aBrokerId, aGatewayDevId, aGatewayModel, aDeviceModel, aErrorInfo) then
  if not _DDTopoCacheInter._doGetDeviceInfoForCmd(aDevId, aBrokerId, aGatewayDevId, aGatewayModel, aDeviceModel, aErrorInfo) then
  begin
    aErrorCode := 'D00002';
    Exit;
  end;

  // �д������ž����
  if aBatchNo <> '' then
    if not _DDDataInter._doInsertRequestId(aUserName,
                                           aBatchNo,
                                           aDevId,
                                           aCmdName,
                                           aCmd,
                                           aCmdData,
                                           aInfo,
                                           aErrorInfo) then
    begin
      aErrorCode := 'D00003';
      aErrorInfo := '' + aErrorInfo;
      Exit;
    end;

  // ��������
  aSendCmdData.Cmd := aCmd;
  aSendCmdData.CmdData := aCmdData;

  Result := _DDCommInter._SendCmd(aBrokerId,
                                  aGatewayDevId,
                                  aSendCmdData,
                                  aReceiveCmdData,
                                  aTimeOut,
                                  aHasResult,
                                  aErrorCode,
                                  aErrorInfo);

  if aHasResult then
  begin
    aErrorCode := aReceiveCmdData.StatusCode;
    if aReceiveCmdData.StatusCode = '0' then
      aResult := 0
    else
    begin
      aResult := 2;

      _DDModelsInter._doParseDeviceError(aReceiveCmdData.StatusCode,
                                         aGatewayModel,
                                         aDeviceModel,
                                         aErrorCode,
                                         aErrorInfo);
    end;
  end
  else
    aResult := 3;

  // �д������žͽ�������
  if aBatchNo <> '' then
  begin
    try
      _DDDataInter._doSetResponse(aUserName,
                                  aBatchNo,
                                  aResult,
                                  aErrorCode,
                                  aErrorInfo,
                                  aReceiveCmdData.ResponseData,
                                  aError);
    except
      on E: Exception do
      begin
        OutputDebugString(PChar('lynch: ' + 'д�����쳣,' + E.Message));
        Exit;
      end;
    end;
  end;
end;

function doSetCmdInfo(const aUserName: string;
                      const aBatchNo: string;
                      const aInfo: string;
                      var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doSetResponseInfo(aUserName,
                                            aBatchNo,
                                            aInfo,
                                            aErrorInfo);
end;

function doGetRequestList(const aUserName: RString;
                          const aRequestId: RString;
                          const aDevId: RString;
                          const aDateBegin: RDateTime;
                          const aDateEnd: RDateTime;
                          const aResult: RInteger;
                          const aFilter: RString;
                          var aPageInfo: RPageInfo;
                          const aRequestList: TRequestDataList;
                          var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetRequestList(aUserName, aRequestId, aDevId,
    aDateBegin, aDateEnd, aResult, aFilter, aPageInfo, aRequestList, aErrorInfo);
end;

function doGetRequestInfo(const aUserCode: RString;
                          const aRequestId: RString;
                          const aRequest: TRequestData;
                          var aError: RResult): Boolean;
begin
  Result := _DDDataInter._doGetRequestInfo(aUserCode, aRequestId, aRequest, aError);
end;

function doSetDoubtRequestResult(const aUserCode: RString;
                                 const aRequestId: RString;
                                 const aResult: RBoolean;
                                 var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doSetDoubtRequestResult(aUserCode, aRequestId, aResult, aErrorInfo);
end;

end.
