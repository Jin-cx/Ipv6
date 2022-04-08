(*
 * API接口单元 (日志查询)
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 * 说明: 维护日志和运行日志
 *
 *
 * 修改:
 * 2016-12-08 (v0.1)
 *   + 第一次发布.
 *)

unit UdoDDAPI.Log;

interface

uses
  puer.System,
  UDDDataInter,
  UDDLogData;

function doWriteLog(const aLogTypeId: Integer;
                    const aLogKindId: Integer;
                    const aLogCode: string;
                    const aLogInfo: string;
                    const aUserId: Integer;
                    const aUserCode: string;
                    const aUserName: string;
                    const aClientIp: string;
                    var aErrorInfo: string): Boolean; stdcall;

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
begin
  Result := _DDDataInter._doWriteLog(aLogTypeId,
                                     aLogKindId,
                                     aLogCode,
                                     aLogInfo,
                                     aUserId,
                                     aUserCode,
                                     aUserName,
                                     aClientIp,
                                     aErrorInfo);
end;

function doGetLogList(const aLogTypeId: RInteger;
                      const aLogKindId: RInteger;
                      const aLogDateBegin: RDateTime;
                      const aLogDateEnd: RDateTime;
                      const aFilter: RString;
                      var aPageInfo: RPageInfo;
                      const aLogList: TLogDataList;
                      var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetLogList(aLogTypeId,
                                       aLogKindId,
                                       aLogDateBegin,
                                       aLogDateEnd,
                                       aFilter,
                                       aPageInfo,
                                       aLogList,
                                       aErrorInfo);
end;

end.
