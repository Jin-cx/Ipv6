(*
 * API接口单元 (设备命令)
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 * 说明: 对指定设备执行指定的命令(对外的接口)
 *       带批号的提供回查
 *
 *
 * 修改:
 * 2016-12-08 (v0.1)
 *   + 第一次发布.
 *)

unit UdoDDAPI.DeviceCmd;

interface

uses
  SysUtils, Windows,
  puer.System,
  UDDDataInter, UDDTopoCacheInter, UDDCommInter, UDDModelsInter,
  UDDCommData, UDDRequestData;

// 同步发送命令
function doSendCmdSync(const aUserName: string;               // 账户
                       const aDevId: string;                  // 终端设备设备编号
                       const aBatchNo: string;                // 本次执行批号(可空)
                       const aCmdName: string;                // 命令名称
                       const aCmd: string;                    // 命令
                       const aCmdData: string;                // 命令数据
                       const aInfo: string;                   // 命令执行描述
                       const aTimeOut: Integer;               // 超时时间 秒
                       var aResult: Integer;                  // 执行结果
                       var aReceiveCmdData: TCommDataInfo;    // 应答的报文
                       var aErrorCode: string;
                       var aErrorInfo: string): Boolean; stdcall;

// 设置命令信息
function doSetCmdInfo(const aUserName: string;                // 账户
                      const aBatchNo: string;                 // 本次执行批号
                      const aInfo: string;                    // 命令执行描述
                      var aErrorInfo: string): Boolean; stdcall;

// 获取请求列表
function doGetRequestList(const aUserName: RString;              // 账户
                          const aRequestId: RString;             // 请求批号
                          const aDevId: RString;                 // 终端设备设备编号
                          const aDateBegin: RDateTime;           // 开始日期
                          const aDateEnd: RDateTime;             // 结束日期
                          const aResult: RInteger;               //
                          const aFilter: RString;                // 模糊过滤
                          var aPageInfo: RPageInfo;              // 分页
                          const aRequestList: TRequestDataList;  // 返回的请求列表
                          var aErrorInfo: string): Boolean; stdcall;

// 获取请求详情
function doGetRequestInfo(const aUserCode: RString;
                          const aRequestId: RString;             // 请求批号
                          const aRequest: TRequestData;          // 返回的请求
                          var aError: RResult): Boolean; stdcall;

// 人工设置置疑任务状态
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

  // 找终端设备信息
  //if not _DDDataInter._doGetDeviceInfoForCmd(aDevId, aBrokerId, aGatewayDevId, aGatewayModel, aDeviceModel, aErrorInfo) then
  if not _DDTopoCacheInter._doGetDeviceInfoForCmd(aDevId, aBrokerId, aGatewayDevId, aGatewayModel, aDeviceModel, aErrorInfo) then
  begin
    aErrorCode := 'D00002';
    Exit;
  end;

  // 有带入批号就入库
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

  // 发送命令
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

  // 有带入批号就将结果入库
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
        OutputDebugString(PChar('lynch: ' + '写入结果异常,' + E.Message));
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
