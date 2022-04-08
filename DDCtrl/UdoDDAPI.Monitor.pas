(*
 * API接口单元 (报文监测)
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 * 说明: 监测收发报文
 *
 *
 * 修改:
 * 2016-12-08 (v0.1)
 *   + 第一次发布.
 *)

unit UdoDDAPI.Monitor;

interface

uses
  {UDDMonitorInter, }UdoDDWork.CommIO;

// 尝试获取报文监测
function doGetDebugInfo(const aClientTag: string;
                        const aUserName: string;
                        var aDebugInfo: string;
                        var aErrorInfo: string): Boolean; stdcall;
// 设置报文监测开启
function doSetCommMonitorActive(const aCommMonitorActive: Boolean;
                                var aErrorInfo: string): Boolean; stdcall;
// 获取报文监测开启状态
function doGetCommMonitorActive(var aCommMonitorActive: Boolean;
                                var aErrorInfo: string): Boolean; stdcall;

exports
  doGetDebugInfo,
  doSetCommMonitorActive,
  doGetCommMonitorActive;

implementation

function doGetDebugInfo(const aClientTag: string;
                        const aUserName: string;
                        var aDebugInfo: string;
                        var aErrorInfo: string): Boolean;
begin
  Result := False;
  aErrorInfo := '接口关闭';
  //Result := _DDMonitorInter._GetDebugInfo(aClientTag, aUserName, aDebugInfo, aErrorInfo);
end;

function doSetCommMonitorActive(const aCommMonitorActive: Boolean;
                                var aErrorInfo: string): Boolean;
begin
  TDebugCtrl.SetCommMonitorActive(aCommMonitorActive);
  Result := True;
end;

function doGetCommMonitorActive(var aCommMonitorActive: Boolean;
                                var aErrorInfo: string): Boolean;
begin
  aCommMonitorActive := TDebugCtrl.GetCommMonitorActive;
  Result := True;
end;

end.
