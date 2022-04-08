(*
 * �����շ�ͳ�Ƶ�Ԫ
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 * ����Ҫͳ�Ƶı�����Ϣ�������Դ洢�����ݿ�(1����)
 * �߳���Ϣ:  ���������߳� x 1
 * ����Ԫ���漰���棬�豸���Ҳ����Ӱ�챾��Ԫ
 *
 * �޸�:
 * 2018-03-21 (v0.1)
 *   + ��һ�η���.
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
  SAVE_CYCLE = 1000*60; // �洢����

type
  TDDWorkCommStatisCtrl = class
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;

    // ��ӷ��ͱ���ͳ��
    class procedure AddSendCommDataStatis(const aGatewayDevNo: string;          // �����豸���
                                          const aData: TCommDataInfo);          // ����

    // ��ӽ��ձ���ͳ��
    class procedure AddReceiveCommDataStatis(const aGatewayDevNo: string;       // �����豸���
                                             const aData: TCommDataInfo);       // ����

    // ��ȡָ�����صı���
    class function GetGatewayCommList(const aGatewayDevNo: string;              // �����豸���
                                      const aStream: TMemoryStream;
                                      var aErrorInfo: string): Boolean;
  end;

  // ����ͳ����Ϣ����
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

  // ���汨��ͳ����Ϣ���߳�
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
    aErrorInfo := '��ָ�����ر��';
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
