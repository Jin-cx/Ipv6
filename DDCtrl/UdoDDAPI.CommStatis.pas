unit UdoDDAPI.CommStatis;

interface

uses
  SysUtils,
  puer.System,
  UPrDbConnInter,
  UDDCommDataInfoData,
  UMyConfig;

// 取收发报文统计
function doGetCommDataInfoList(const aBrokerId: RInteger;
                               const aGatewayId: RInteger;
                               const aBeginDay: RDateTime;
                               const aEndDay: RDateTime;
                               const aCommDataInfoList: TCommDataInfoDataList;
                               var aErrorInfo: string): Boolean; stdcall;

// 保存网关报文统计信息
function doSaveGatewayCommStatisList(const aCommStatisList: TGatewayCommStatisDataList;
                                     var aErrorInfo: string): Boolean; stdcall;

exports
  doGetCommDataInfoList,
  doSaveGatewayCommStatisList;

implementation

function doGetCommDataInfoList(const aBrokerId: RInteger;
                               const aGatewayId: RInteger;
                               const aBeginDay: RDateTime;
                               const aEndDay: RDateTime;
                               const aCommDataInfoList: TCommDataInfoDataList;
                               var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrADOQuery.Create(DB_METER);
  try
    aQuery.ProcName := 'proc_GetCommStatisList';
    aQuery.AddParamI('brokerId', aBrokerId);
    aQuery.AddParamI('gatewayId', aGatewayId);
    aQuery.AddParamT('beginDay', aBeginDay);
    aQuery.AddParamT('endDay', aEndDay);
    aQuery.OpenProc;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aCommDataInfoList.Add do
      begin
        dayHour := aQuery.ReadFieldAsRDateTime('dayHour');
        sendCount := aQuery.ReadFieldAsRInteger('sendCount');
        sendSize := aQuery.ReadFieldAsRInteger('sendSize');
        receiveCount := aQuery.ReadFieldAsRInteger('receiveCount');
        receiveSize := aQuery.ReadFieldAsRInteger('receiveSize');
      end;

      aQuery.Next;
    end;

    Result := True;
  finally
    aQuery.Free;
  end;
end;

function doSaveGatewayCommStatisList(const aCommStatisList: TGatewayCommStatisDataList;
  var aErrorInfo: string): Boolean;
var
  aQuery: TPrADOQuery;
  aSQLStr: string;
  aCommStatisData: TGatewayCommStatisData;
  aIsFirst: Boolean;
begin
  try
    aQuery := TPrADOQuery.Create(DB_METER);
    try
      aQuery.SQL.Clear;
      aQuery.SQL.Add('declare @tmp as TCommStatisList;');
      aQuery.SQL.Add('insert into @tmp (gatewayDevNo, sendCount, sendSize, receiveCount, receiveSize)');

      aIsFirst := True;
      for aCommStatisData in aCommStatisList do
      begin
        if aIsFirst then
        begin
          aSQLStr := 'values ';
          aIsFirst := False;
        end
        else
          aSQLStr := ', ';

        aSQLStr := aSQLStr + ' ( '+QuotedStr(aCommStatisData.GatewayDevNo)
                              +','+IntToStr(aCommStatisData.SendCount)
                              +','+IntToStr(aCommStatisData.SendSize)
                              +','+IntToStr(aCommStatisData.ReceiveCount)
                              +','+IntToStr(aCommStatisData.ReceiveSize)+')';
        aQuery.SQL.Add(aSQLStr);
      end;
      aQuery.SQL.Add('exec proc_SaveCommStatisList @tmp;');
      aQuery.ExecSQL;

      Result := True;
    finally
      aQuery.Free;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := '保存网关报文统计数据异常: ' + E.Message;
      Result := False;
    end;
  end;
end;

end.
