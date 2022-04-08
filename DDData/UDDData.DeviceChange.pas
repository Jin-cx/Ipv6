(*
 * 设备更换模块
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 *
 * 修改:
 * 2016-12-08 (v0.1)
 *   + 第一次发布.
 *)

unit UDDData.DeviceChange;

interface

uses
  Classes, SysUtils, Generics.Collections,
  puer.System, puer.SyncObjs,
  UPrDbConnInter,
  UDDChangeData, UDDChangeDataXml,
  UDDData.Config;

// 添加换表记录
function doAddChange(const aChangeData: TChangeData;
                     var aErrorInfo: string): Boolean; stdcall;

// 获取换表历史
function doGetChangeList(const aBeginDay: RDateTime;
                         const aEndDay: RDateTime;
                         const aFilter: RString;
                         var aPageInfo: RPageInfo;
                         const aChangeList: TChangeDataList;
                         var aErrorInfo: string): Boolean; stdcall;

exports
  doAddChange,
  doGetChangeList;

implementation

function doAddChange(const aChangeData: TChangeData;
                     var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aResult: RResult;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_AddMeterChange';
    aQuery.AddParamI('userId', aChangeData.userId);
    aQuery.AddParamS('userCode', aChangeData.userCode);
    aQuery.AddParamS('userName', aChangeData.userName);
    aQuery.AddParamS('projectUserCode', aChangeData.projectUserCode);
    aQuery.AddParamS('projectUserName', aChangeData.projectUserName);
    aQuery.AddParamS('changeNote', aChangeData.changeNote);
    //aQuery.AddParamI('oldDevId', aChangeData.oldDevId);
    aQuery.AddParamS('oldDevNo', aChangeData.oldDevNo);
    aQuery.AddParamT('endTime', aChangeData.endTime);
    aQuery.AddParamS('endValueList', TMeterValueDataListXml(aChangeData.endValueList).AsXmlStr);
    aQuery.AddParamS('newDevNo', aChangeData.newDevNo);
    aQuery.AddParamS('newDevFactoryNo', aChangeData.newDevFactoryNo);
    aQuery.AddParamS('newConn', aChangeData.newConn);
    aQuery.AddParamT('beginTime', aChangeData.beginTime);
    aQuery.AddParamS('beginValueList', TMeterValueDataListXml(aChangeData.beginValueList).AsXmlStr);
    aQuery.AddParamS('newDevNote', aChangeData.newDevNote);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aResult);
    if not Result then
      aErrorInfo := aResult.Info;
  finally
    aQuery.Free;
  end;
end;

function doGetChangeList(const aBeginDay: RDateTime;
                         const aEndDay: RDateTime;
                         const aFilter: RString;
                         var aPageInfo: RPageInfo;
                         const aChangeList: TChangeDataList;
                         var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetMeterChangeList';
    aQuery.AddParamT('beginDay', aBeginDay);
    aQuery.AddParamT('endDay', aEndDay);
    aQuery.AddParamS('filter', aFilter);
    aQuery.AddParamPage(aPageInfo);
    aQuery.OpenProc;

    aPageInfo := aQuery.ReadPageInfo;

    if aQuery.GotoNextRecordset then
    begin
      aQuery.First;
      while not aQuery.Eof do
      begin
        with aChangeList.Add do
        begin
          changeId := aQuery.ReadFieldAsRInteger('changeId');
          userId := aQuery.ReadFieldAsRInteger('userId');
          userCode := aQuery.ReadFieldAsRString('userCode');
          userName := aQuery.ReadFieldAsRString('userName');
          projectUserCode := aQuery.ReadFieldAsRString('projectUserCode');
          projectUserName := aQuery.ReadFieldAsRString('projectUserName');
          changeTime := aQuery.ReadFieldAsRDateTime('changeTime');
          changeNote := aQuery.ReadFieldAsRString('changeNote');
          devName := aQuery.ReadFieldAsRString('devName');
          devModel := aQuery.ReadFieldAsRString('devModel');
          devModelName := aQuery.ReadFieldAsRString('devModelName');
          oldDevId := aQuery.ReadFieldAsRInteger('oldDevId');
          oldDevNo := aQuery.ReadFieldAsRString('oldDevNo');
          oldDevFactoryNo := aQuery.ReadFieldAsRString('oldDevFactoryNo');
          newDevId := aQuery.ReadFieldAsRInteger('newDevId');
          newDevNo := aQuery.ReadFieldAsRString('newDevNo');
          newDevFactoryNo := aQuery.ReadFieldAsRString('newDevFactoryNo');
          newConn := aQuery.ReadFieldAsRString('newConn');
          newDevNote := aQuery.ReadFieldAsRString('newDevNote');
          endTime := aQuery.ReadFieldAsRDateTime('oldEndTime');
          //endValueList: TMeterValueDataList;   // 结束示数列表
          beginTime := aQuery.ReadFieldAsRDateTime('newBeginTime');
          //beginValueList: TMeterValueDataList; // 起始示数列表
        end;

        aQuery.Next;
      end;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

end.
