{
  ��Ԫ: ͨѶ�豸��������洢����Ԫ
  ����: lynch
  ����: 2016-08-18
}

unit UDDData.Request;

interface

uses
  Classes, SysUtils, Windows,
  puer.System,
  UPrDbConnInter,
  UDDRequestData,
  UDDData.Config;

// ���һ�������
function doInsertRequestId(const aUserCode: string;
                           const aRequestId: string;
                           const aDevNo: string;
                           const aCmdName: string;
                           const aCmd: string;
                           const aCmdData: string;
                           const aInfo: string;
                           var aErrorInfo: string): Boolean; stdcall;

// ��������Ľ��
function doSetResponse(const aUserCode: string;
                       const aRequestId: string;
                       const aResult: Integer;
                       const aErrorCode: string;
                       const aErrorInfo: string;
                       const aResponseData: string;
                       var aError: RResult): Boolean; stdcall;

// ����������Ϣ
function doSetResponseInfo(const aUserCode: string;
                           const aRequestId: string;
                           const aInfo: string;
                           var aErrorInfo: string): Boolean; stdcall;

// ȡ�����б�
function doGetRequestList(const aUserCode: RString;
                          const aRequestId: RString;
                          const aDevNo: RString;
                          const aDateBegin: RDateTime;
                          const aDateEnd: RDateTime;
                          const aResult: RInteger;
                          const aFilter: RString;
                          var aPageInfo: RPageInfo;
                          const aRequestList: TRequestDataList;
                          var aErrorInfo: string): Boolean; stdcall;

// ȡ��������
function doGetRequestInfo(const aUserCode: RString;
                          const aRequestId: RString;
                          const aRequest: TRequestData;
                          var aError: RResult): Boolean; stdcall;

// �����������δ��ɵ���������Ϊ����
function doCheckDoubtRequest(var aErrorInfo: string): Boolean; stdcall;

// �˹�������������״̬
function doSetDoubtRequestResult(const aUserCode: RString;
                                 const aRequestId: RString;
                                 const aResult: RBoolean;
                                 var aErrorInfo: string): Boolean; stdcall;

exports
  doInsertRequestId,
  doSetResponse,
  doSetResponseInfo,
  doGetRequestList,
  doGetRequestInfo,
  doCheckDoubtRequest,
  doSetDoubtRequestResult;

implementation

function doInsertRequestId(const aUserCode: string;
                           const aRequestId: string;
                           const aDevNo: string;
                           const aCmdName: string;
                           const aCmd: string;
                           const aCmdData: string;
                           const aInfo: string;
                           var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_AddRequest';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.AddParamS('requestId', aRequestId);
    aQuery.AddParamS('devNo', aDevNo);
    aQuery.AddParamS('cmdName', aCmdName);
    aQuery.AddParamS('cmd', aCmd);
    aQuery.AddParamS('cmdData', aCmdData);
    aQuery.AddParamS('info', aInfo);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    aErrorInfo := aError.Info;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doSetResponse(const aUserCode: string;
                       const aRequestId: string;
                       const aResult: Integer;
                       const aErrorCode: string;
                       const aErrorInfo: string;
                       const aResponseData: string;
                       var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_SetResponse';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.AddParamS('requestId', aRequestId);
    aQuery.AddParamI('result', aResult);
    aQuery.AddParamS('errorCode', aErrorCode);
    aQuery.AddParamS('errorInfo', aErrorInfo);
    aQuery.AddParamS('responseData', aResponseData);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doSetResponseInfo(const aUserCode: string;
                           const aRequestId: string;
                           const aInfo: string;
                           var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_SetResponseInfo';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.AddParamS('requestId', aRequestId);
    aQuery.AddParamS('info', aInfo);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    aErrorInfo := aError.Info;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doGetRequestList(const aUserCode: RString;
                          const aRequestId: RString;
                          const aDevNo: RString;
                          const aDateBegin: RDateTime;
                          const aDateEnd: RDateTime;
                          const aResult: RInteger;
                          const aFilter: RString;
                          var aPageInfo: RPageInfo;
                          const aRequestList: TRequestDataList;
                          var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_GetRequestList';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.AddParamS('requestId', aRequestId);
    aQuery.AddParamS('devNo', aDevNo);
    aQuery.AddParamT('dateBegin', aDateBegin);
    aQuery.AddParamT('dateEnd', aDateEnd);
    aQuery.AddParamI('result', aResult);
    aQuery.AddParamS('filter', aFilter);
    aQuery.AddParamPage(aPageInfo);
    aQuery.OpenProc;

    aPageInfo := aQuery.ReadPageInfo;

    if aQuery.GotoNextRecordset then
    begin
      aQuery.First;
      while not aQuery.Eof do
      begin
        with aRequestList.Add do
        begin
          RequestId := aQuery.ReadFieldAsRString('requestId');
          UserCode := aQuery.ReadFieldAsRString('userCode');
          GatewayDevNo := aQuery.ReadFieldAsRString('gatewayDevNo');
          GatewayDevName := aQuery.ReadFieldAsRString('gatewayDevName');
          DevNo := aQuery.ReadFieldAsRString('devNo');
          CmdName := aQuery.ReadFieldAsRString('cmdName');
          Cmd := aQuery.ReadFieldAsRString('cmd');
          CmdData := aQuery.ReadFieldAsRString('cmdData');
          BeginTime := aQuery.ReadFieldAsRDateTime('beginTime');
          EndTime := aQuery.ReadFieldAsRDateTime('endTime');
          Result := aQuery.ReadFieldAsRInteger('result');
          ErrorCode := aQuery.ReadFieldAsRString('errorCode');
          ErrorInfo := aQuery.ReadFieldAsRString('errorInfo');
          ResponseData := aQuery.ReadFieldAsRString('responseData');
          Info := aQuery.ReadFieldAsRString('info');
        end;
        aQuery.Next;
      end;
    end;

    Result := True;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doGetRequestInfo(const aUserCode: RString;
                          const aRequestId: RString;
                          const aRequest: TRequestData;
                          var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_GetRequestInfo';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.AddParamS('requestId', aRequestId);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    if Result then
    begin
      aRequest.RequestId := aQuery.ReadFieldAsRString('requestId');
      aRequest.UserCode := aQuery.ReadFieldAsRString('userCode');
      aRequest.GatewayDevNo := aQuery.ReadFieldAsRString('gatewayDevNo');
      aRequest.GatewayDevName := aQuery.ReadFieldAsRString('gatewayDevName');
      aRequest.DevNo := aQuery.ReadFieldAsRString('devNo');
      aRequest.CmdName := aQuery.ReadFieldAsRString('cmdName');
      aRequest.Cmd := aQuery.ReadFieldAsRString('cmd');
      aRequest.CmdData := aQuery.ReadFieldAsRString('cmdData');
      aRequest.BeginTime := aQuery.ReadFieldAsRDateTime('beginTime');
      aRequest.EndTime := aQuery.ReadFieldAsRDateTime('endTime');
      aRequest.Result := aQuery.ReadFieldAsRInteger('result');
      aRequest.ErrorCode := aQuery.ReadFieldAsRString('errorCode');
      aRequest.ErrorInfo := aQuery.ReadFieldAsRString('errorInfo');
      aRequest.ResponseData := aQuery.ReadFieldAsRString('responseData');
      aRequest.Info := aQuery.ReadFieldAsRString('info');
    end;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doCheckDoubtRequest(var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_CheckDoubtRequest';
    aQuery.ExecProc;

    Result := True;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doSetDoubtRequestResult(const aUserCode: RString;
                                 const aRequestId: RString;
                                 const aResult: RBoolean;
                                 var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_SetDoubtRequestResult';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.AddParamS('requestId', aRequestId);
    aQuery.AddParamB('result', aResult);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    if not Result then
      aErrorInfo := aError.Info;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

end.
