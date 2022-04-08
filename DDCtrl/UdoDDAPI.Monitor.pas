(*
 * API�ӿڵ�Ԫ (���ļ��)
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 *
 * ˵��: ����շ�����
 *
 *
 * �޸�:
 * 2016-12-08 (v0.1)
 *   + ��һ�η���.
 *)

unit UdoDDAPI.Monitor;

interface

uses
  {UDDMonitorInter, }UdoDDWork.CommIO;

// ���Ի�ȡ���ļ��
function doGetDebugInfo(const aClientTag: string;
                        const aUserName: string;
                        var aDebugInfo: string;
                        var aErrorInfo: string): Boolean; stdcall;
// ���ñ��ļ�⿪��
function doSetCommMonitorActive(const aCommMonitorActive: Boolean;
                                var aErrorInfo: string): Boolean; stdcall;
// ��ȡ���ļ�⿪��״̬
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
  aErrorInfo := '�ӿڹر�';
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
