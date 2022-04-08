(*
 * 报文收发统计单元
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 * 缓存要统计的报文信息，周期性存储到数据库(1分钟)
 * 线程信息:  保存任务线程 x 1
 * 本单元不涉及缓存，设备变更也不会影响本单元
 *
 * 修改:
 * 2018-03-21 (v0.1)
 *   + 第一次发布.
 *)
 unit UdoDDWork.CommStatis;

interface

uses
  Classes, SysUtils,
  puer.SyncObjs, puer.Collections, puer.Json.JsonDataObjects,
  UPrLogInter,
  UDDCommDataInfoData, UDDCommData,
  UdoDDAPI.CommStatis;

const
  SAVE_CYCLE = 1000*60; // 存储周期

type
  TDDWorkCommStatisCtrl = class
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;

    // 添加发送报文统计
    class procedure AddSendCommDataStatis(const aGatewayDevNo: string;          // 网关设备编号
                                          const aData: TCommDataInfo);          // 报文

    // 添加接收报文统计
    class procedure AddReceiveCommDataStatis(const aGatewayDevNo: string;       // 网关设备编号
                                             const aData: TCommDataInfo);       // 报文

    // 获取指定网关的报文
    class function GetGatewayCommList(const aGatewayDevNo: string;              // 网关设备编号
                                      const aStream: TMemoryStream;
                                      var aErrorInfo: string): Boolean;
  end;

  // 报文统计信息缓存
  TCommDataCache = class
  private
    FCommList: TPrStrDict<TGatewayCommStatisData>;
    FLock: TPrRWLock;
    function doGetCommDataInfo(const aGatewayDevNo: string): TGatewayCommStatisData;
    function doGetSize(const aData: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddSendCommData(const aGatewayDevNo: string; const aData: TCommDataInfo);
    procedure AddReceiveCommData(const aGatewayDevNo: string; const aData: TCommDataInfo);
    procedure GetCommStatisList(const aCommStatisList: TGatewayCommStatisDataList);
    function GetGatewayCommList(const aGatewayDevNo: string; const aStream: TMemoryStream; var aErrorInfo: string): Boolean;
  end;

  // 保存报文统计信息的线程
  TSaveCommDataWork = class(TThread)
  private
    FEvent: TPrSimpleEvent;
    procedure doSave;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation

var
  _CommDataCache: TCommDataCache;
  _SaveCommDataWork: TSaveCommDataWork;

{ TDDWorkCommStatisCtrl }
class procedure TDDWorkCommStatisCtrl.Open;
begin
  _CommDataCache := TCommDataCache.Create;
  _SaveCommDataWork := TSaveCommDataWork.Create;
end;

class procedure TDDWorkCommStatisCtrl.Close;
begin
  _SaveCommDataWork.Free;
  _CommDataCache.Free;
end;

class function TDDWorkCommStatisCtrl.Active: Boolean;
begin
  Result := _CommDataCache <> nil;
end;

class procedure TDDWorkCommStatisCtrl.AddReceiveCommDataStatis(const aGatewayDevNo: string; const aData: TCommDataInfo);
begin
  _CommDataCache.AddReceiveCommData(aGatewayDevNo, aData);
end;

class procedure TDDWorkCommStatisCtrl.AddSendCommDataStatis(const aGatewayDevNo: string; const aData: TCommDataInfo);
begin
  _CommDataCache.AddSendCommData(aGatewayDevNo, aData);
end;

class function TDDWorkCommStatisCtrl.GetGatewayCommList(const aGatewayDevNo: string; const aStream: TMemoryStream; var aErrorInfo: string): Boolean;
begin
  Result := _CommDataCache.GetGatewayCommList(aGatewayDevNo, aStream, aErrorInfo);
end;

{ TCommDataCache }
constructor TCommDataCache.Create;
begin
  FLock := TPrRWLock.Create;
  FCommList := TPrStrDict<TGatewayCommStatisData>.Create;
end;

destructor TCommDataCache.Destroy;
var
  aTmpCommStatis: TGatewayCommStatisData;
begin
  FLock.BeginWrite;
  try
    for aTmpCommStatis in FCommList.Values do
      aTmpCommStatis.Free;

    FCommList.Free;
  finally
    FLock.EndWrite;
    FLock.Free;
  end;
  inherited;
end;

function TCommDataCache.doGetCommDataInfo(const aGatewayDevNo: string): TGatewayCommStatisData;
begin
  if not FCommList.TryGetValue(aGatewayDevNo, Result) then
  begin
    Result := TGatewayCommStatisData.Create;
    Result.GatewayDevNo := aGatewayDevNo;
    Result.SendCount := 0;
    Result.SendSize := 0;
    Result.ReceiveCount := 0;
    Result.ReceiveSize := 0;
    FCommList.Add(aGatewayDevNo, Result);
  end;
end;

function TCommDataCache.doGetSize(const aData: string): Integer;
begin
  Result := Length(aData) div 2;
end;

procedure TCommDataCache.AddSendCommData(const aGatewayDevNo: string; const aData: TCommDataInfo);
var
  aCommDataInfo: TGatewayCommStatisData;
  aJson: TJsonObject;
begin
  if aGatewayDevNo = '' then
    Exit;

  FLock.BeginWrite;
  try
    aCommDataInfo := doGetCommDataInfo(aGatewayDevNo);
    aCommDataInfo.SendCount := aCommDataInfo.SendCount + 1;
    aCommDataInfo.SendSize := aCommDataInfo.SendSize + doGetSize(aData.CommStr);
    aJson := aCommDataInfo.CommList.InsertObject(0);
    aJson.I['brokerId'] := aData.BrokerId;
    aJson.S['brokerDevNo'] := aData.Sender;
    aJson.S['gatewayDevNo'] := aData.Receiver;
    aJson.S['sendTime'] := FormatDateTime('yyyy-MM-dd hh:mm:ss.zzz', aData.ReceiveTime);
    aJson.O['data'].FromJSON(aData.CommStr);
    if aCommDataInfo.CommList.Count > 100 then
      aCommDataInfo.CommList.Delete(100);
  finally
    FLock.EndWrite;
  end;
end;

procedure TCommDataCache.AddReceiveCommData(const aGatewayDevNo: string; const aData: TCommDataInfo);
var
  aCommDataInfo: TGatewayCommStatisData;
  aJson: TJsonObject;
begin
  if aGatewayDevNo = '' then
    Exit;

  FLock.BeginWrite;
  try
    aCommDataInfo := doGetCommDataInfo(aGatewayDevNo);
    aCommDataInfo.ReceiveCount := aCommDataInfo.ReceiveCount + 1;
    aCommDataInfo.ReceiveSize := aCommDataInfo.ReceiveSize + doGetSize(aData.CommStr);
    aJson := aCommDataInfo.CommList.InsertObject(0);
    aJson.I['brokerId'] := aData.BrokerId;
    aJson.S['brokerDevNo'] := aData.Receiver;
    aJson.S['gatewayDevNo'] := aData.Sender;
    aJson.S['sendTime'] := FormatDateTime('yyyy-MM-dd hh:mm:ss.zzz', aData.ReceiveTime);
    aJson.O['data'].FromJSON(aData.CommStr);
    if aCommDataInfo.CommList.Count > 100 then
      aCommDataInfo.CommList.Delete(100);
  finally
    FLock.EndWrite;
  end;
end;

procedure TCommDataCache.GetCommStatisList(const aCommStatisList: TGatewayCommStatisDataList);
var
  aTmpCommStatis: TGatewayCommStatisData;
begin
  FLock.BeginWrite;
  try
    for aTmpCommStatis in FCommList.Values do
    begin
      if (aTmpCommStatis.SendCount = 0) and (aTmpCommStatis.ReceiveCount = 0) then
        Continue;

      with aCommStatisList.Add do
      begin
        GatewayDevNo := aTmpCommStatis.GatewayDevNo;
        SendCount := aTmpCommStatis.SendCount;
        SendSize := aTmpCommStatis.SendSize;
        ReceiveCount := aTmpCommStatis.ReceiveCount;
        ReceiveSize := aTmpCommStatis.ReceiveSize;
      end;

      with aTmpCommStatis do
      begin
        SendCount := 0;
        SendSize := 0;
        ReceiveCount := 0;
        ReceiveSize := 0;
      end;
    end;
  finally
    FLock.EndWrite;
  end;
end;

function TCommDataCache.GetGatewayCommList(const aGatewayDevNo: string; const aStream: TMemoryStream; var aErrorInfo: string): Boolean;
var
  aCommDataInfo: TGatewayCommStatisData;
begin
  Result := False;

  if aGatewayDevNo = '' then
  begin
    aErrorInfo := '请指定网关编号';
    Exit;
  end;

  FLock.BeginWrite;
  try
    aCommDataInfo := doGetCommDataInfo(aGatewayDevNo);
    aCommDataInfo.CommList.SaveToStream(aStream);
    {aCommDataInfo.ReceiveCount := aCommDataInfo.ReceiveCount + 1;
    aCommDataInfo.ReceiveSize := aCommDataInfo.ReceiveSize + doGetSize(aData.CommStr);
    aJson := aCommDataInfo.CommList.InsertObject(0);
    aJson.I['brokerId'] := aData.BrokerId;
    aJson.S['brokerDevNo'] := aData.Receiver;
    aJson.S['gatewayDevNo'] := aData.Sender;
    aJson.S['sendTime'] := FormatDateTime('yyyy-MM-dd hh:mm:ss.zzz', aData.ReceiveTime);
    aJson.O['data'].FromJSON(aData.CommStr);
    if aCommDataInfo.CommList.Count > 100 then
      aCommDataInfo.CommList.Delete(100);  }

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

{ TSaveCommDataWork }
constructor TSaveCommDataWork.Create;
begin
  inherited Create(False);
  FEvent := TPrSimpleEvent.Create;
end;

destructor TSaveCommDataWork.Destroy;
begin
  FEvent.SetEvent;
  Terminate;
  WaitFor;
  FEvent.Free;
  inherited;
end;

procedure TSaveCommDataWork.doSave;
var
  aCommStatisList: TGatewayCommStatisDataList;
  aErrorInfo: string;
begin
  try
    aCommStatisList := TGatewayCommStatisDataList.Create;
    try
      _CommDataCache.GetCommStatisList(aCommStatisList);

      UdoDDAPI.CommStatis.doSaveGatewayCommStatisList(aCommStatisList, aErrorInfo);
    finally
      aCommStatisList.Free;
    end;
  except
    on E: Exception do   // UPrLogInter
      TPrLogInter.WriteLogError('SaveCommDataWork Error: ' + E.Message);
  end;
end;

procedure TSaveCommDataWork.Execute;
begin
  inherited;
  while not Terminated do
  begin
    doSave;

    if FEvent.WaitFor(SAVE_CYCLE) = wrSignaled then
      Exit;
  end;
end;

end.
