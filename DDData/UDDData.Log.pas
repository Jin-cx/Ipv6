(*
 * ��־ģ��
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 *
 * ˵��: ά��������־��д�ͻ�ȡ
 *
 *
 * �޸�:
 * 2016-12-08 (v0.1)
 *   + ��һ�η���.
 *)

unit UDDData.Log;

interface

uses
  Classes, SysUtils,
  puer.System,
  UPrDbConnInter,
  UDDLogData,
  UDDData.Config;

// д��־
function doWriteLog(const aLogTypeId: Integer;
                    const aLogKindId: Integer;
                    const aLogCode: string;
                    const aLogInfo: string;
                    const aUserId: Integer;
                    const aUserCode: string;
                    const aUserName: string;
                    const aClientIp: string;
                    var aErrorInfo: string): Boolean; stdcall;

// ��ȡ��־
function doGetLogList(const aLogTypeId: RInteger;
                      const aLogKindId: RInteger;
                      const aLogDateBegin: RDateTime;
                      const aLogDateEnd: RDateTime;
                      const aFilter: RString;
                      var aPageInfo: RPageInfo;
                      const aLogList: TLogDataList;
                      var aErrorInfo: string): Boolean; stdcall;

exports
  doWriteLog,
  doGetLogList;

implementation

function doWriteLog(const aLogTypeId: Integer;
                    const aLogKindId: Integer;
                    const aLogCode: string;
                    const aLogInfo: string;
                    const aUserId: Integer;
                    const aUserCode: string;
                    const aUserName: string;
                    const aClientIp: string;
                    var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aError: RResult;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_WriteLog';
    aQuery.AddParamI('logTypeId', aLogTypeId);
    aQuery.AddParamI('logKindId', aLogKindId);
    aQuery.AddParamS('logCode', aLogCode);
    aQuery.AddParamS('logInfo', aLogInfo);
    aQuery.AddParamI('userId', aUserId);
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.AddParamS('userName', aUserName);
    aQuery.AddParamS('clientIp', aClientIp);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    aErrorInfo := aError.Info;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doGetLogList(const aLogTypeId: RInteger;
                      const aLogKindId: RInteger;
                      const aLogDateBegin: RDateTime;
                      const aLogDateEnd: RDateTime;
                      const aFilter: RString;
                      var aPageInfo: RPageInfo;
                      const aLogList: TLogDataList;
                      var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_GetLogsPaging';
    aQuery.AddParamI('logTypeId', aLogTypeId);
    aQuery.AddParamI('logKindId', aLogKindId);
    aQuery.AddParamT('logDateBegin', aLogDateBegin);
    aQuery.AddParamT('logDateEnd', aLogDateEnd);
    aQuery.AddParamS('filter', aFilter);
    aQuery.AddParamPage(aPageInfo);
    aQuery.OpenProc;

    aPageInfo := aQuery.ReadPageInfo;

    if aQuery.GotoNextRecordset then
    begin
      aQuery.First;
      while not aQuery.Eof do
      begin
        with aLogList.Add do
        begin
          logId := aQuery.ReadFieldAsRInteger('logId');
          logTypeId := aQuery.ReadFieldAsRInteger('logTypeId');
          logKindId := aQuery.ReadFieldAsRInteger('logKindId');
          logDateTime := aQuery.ReadFieldAsRDateTime('LogDateTime');
          logCode := aQuery.ReadFieldAsRString('logCode');
          logInfo := aQuery.ReadFieldAsRString('logInfo');
          userId := aQuery.ReadFieldAsRInteger('userId');
          userCode := aQuery.ReadFieldAsRString('userCode');
          userName := aQuery.ReadFieldAsRString('userName');
          clientIp := aQuery.ReadFieldAsRString('clientIp');
        end;
        aQuery.Next;
      end;
    end;

    Result := True;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

end.
