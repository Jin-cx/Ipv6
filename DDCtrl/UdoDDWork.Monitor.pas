unit UdoDDWork.Monitor;

interface

uses
  Classes, SysUtils, DateUtils, Windows,
  puer.System, puer.SyncObjs,
  UPrMQTTClientForPuerInter, UPrHttpServerInter, UPrDbConnInter,
  UPrManagerInter, UPrHttpClientInter, UPrLogInter,
  UDDCommInter,
  UMyConfig;

type
  TDDMonitorCtrl = class
    class procedure Open;
    class procedure Close;
    class function Active: Boolean;

    class procedure SendNotice(const aTopic, aMsg: string);
    class procedure SendWarn(const aTitle, aText, aTime, aNote: string);
  end;

  // 记录池信息的日志
  TPoolLogWork = class(TThread)
  private
    FEvent: TPrSimpleEvent;
    FLastLogTime: TDateTime;
    FHttpHandle: Integer;

    FLastRefreshTime: TDateTime;
    FDBVer: string;              // 数据库版本
    FRecoveryModel: string;      // 恢复模式
    FDBDataSize: Integer;        // 数据库数据文件大小 (MB)
    FDBLogSize: Integer;         // 数据库日志文件大小 (MB)
    FLastBackupTime: string;     // 最后备份时间
    FLastBackupSize: Integer;    // 最后备份文件大小 (MB)

    procedure doLog;
    procedure doRefreshDBInfo;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation

uses
  UdoDDWork.CommIO, UdoDDAPI.OnLine;

var
  _Active: Boolean;
  _PoolLogWork: TPoolLogWork;

{ TDDMonitorCtrl }
class procedure TDDMonitorCtrl.Open;
begin
  TPrMQTTClientForPuerInter.Open('DDIoT_' + GetGUID32);
  _PoolLogWork := TPoolLogWork.Create;
  _Active := True;
end;

class procedure TDDMonitorCtrl.Close;
begin
  _PoolLogWork.Free;
  TPrMQTTClientForPuerInter.Close;
  _Active := False;
end;

class function TDDMonitorCtrl.Active: Boolean;
begin
  Result := _Active;
end;

class procedure TDDMonitorCtrl.SendNotice(const aTopic, aMsg: string);
begin
  TPrMQTTClientForPuerInter.Publish('dd-iot/' + aTopic, aMsg);
end;

class procedure TDDMonitorCtrl.SendWarn(const aTitle, aText, aTime, aNote: string);
const
  MSG = '{"first":"%s","performance":"%s","time":"%s","remark":"%s"}';
begin
  TPrMQTTClientForPuerInter.Publish('dd/warning/event', Format(MSG, [aTitle, aText, aTime, aNote]));
end;

{ TPoolLogWork }
constructor TPoolLogWork.Create;
begin
  inherited Create(False);
  FEvent := TPrSimpleEvent.Create;
  FLastLogTime := Now;
  FLastRefreshTime := Now - 1;
  FHttpHandle := LockHttpClient;
end;

destructor TPoolLogWork.Destroy;
begin
  FEvent.SetEvent;
  Terminate;
  WaitFor;
  FEvent.Free;
  UnLockHttpClient(FHttpHandle);
  inherited;
end;

procedure TPoolLogWork.doRefreshDBInfo;
var
  aQuery: TPrADOQuery;
begin
  if MinutesBetween(Now, FLastRefreshTime) > 20 then
  begin
    aQuery := TPrADOQuery.Create(DB_METER);
    try
      aQuery.SQL.Text := 'select CAST(SERVERPROPERTY(''ProductVersion'') as nvarchar(64))+''(''+CAST(SERVERPROPERTY(''ProductLevel'') as nvarchar(64))+'') '' +CAST(SERVERPROPERTY(''Edition'') as nvarchar(64)) as dbVer';
      aQuery.Open;
      FDBVer := aQuery.FieldByName('dbVer').AsString;

      aQuery.Close;
      aQuery.SQL.Text := 'SELECT recovery_model_desc FROM sys.databases WHERE name = DB_NAME();';
      aQuery.Open;
      FRecoveryModel := aQuery.FieldByName('recovery_model_desc').AsString;

      aQuery.Close;
      aQuery.SQL.Text := 'select convert(int,size) * 8/1024 as dbDataSize from [dbo].[sysfiles] where groupid >= 1';
      aQuery.Open;
      FDBDataSize := aQuery.FieldByName('dbDataSize').AsInteger;

      aQuery.Close;
      aQuery.SQL.Text := 'select convert(int,size) * 8/1024 as dbLogSize from [dbo].[sysfiles] where groupid = 0';
      aQuery.Open;
      FDBLogSize := aQuery.FieldByName('dbLogSize').AsInteger;

      aQuery.Close;
      aQuery.SQL.Clear;
      aQuery.SQL.Add('select top 1 backup_finish_date, ceiling(compressed_backup_size / Square(1024)) backup_size');
      aQuery.SQL.Add('from msdb.dbo.backupset');
      aQuery.SQL.Add('where database_name = db_name() and type = ''D''');
      aQuery.SQL.Add('order by backup_finish_date desc');
      aQuery.Open;
      if aQuery.RecordCount = 0 then
      begin
        FLastBackupTime := '';
        FLastBackupSize := 0;
      end
      else
      begin
        FLastBackupTime := FormatDateTime('yyyy-MM-dd hh:mm:ss', aQuery.FieldByName('backup_finish_date').AsDateTime);
        FLastBackupSize := aQuery.FieldByName('backup_size').AsInteger;
      end;
    finally
      aQuery.Free;
    end;
    FLastRefreshTime := Now;
  end;
end;

procedure TPoolLogWork.doLog;
const
  PAYLOAD = '{"header":{"from":{"_devid":"TG-DD-Monitor","_model":"TG-DD-Monitor","_runstate":"1","_version":"v1"},"msgtype":"update"},' +
            '"request":{"cmd":"do/auto_up_data",'+
            '"data":{"_devid":"%s",'+
            '"puerVer":"%s",'+
            '"ddVer":"%s",'+
            '"memory":"%s",'+
            '"thread":%d,'+
            '"handleCount":%d,'+
            '"devTotalCount":%d,'+
            '"devOffLineCount":%d,'+
            '"dbVer":"%s",'+
            '"recoveryModel":"%s",'+
            '"dbDataSize":%d,'+
            '"dbLogSize":%d,'+
            '"dbLastBackupTime":"%s",'+
            '"dbLastBackupSize":%d'+
            '},"statuscode": 0}}';
var
  aErrorInfo: string;
  //aAllPoolCount: Integer;
  //aUsePoolCount: Integer;

  aUrl: string;
  aStream: TMemoryStream;

  aDevId: string;
  aPuerVer: string;
  aDDVer: string;
  aMemory: string;
  aThread: Integer;
  aHandleCount: Integer;
  aDevTotalCount: Integer;
  aDevOffLineCount: Integer;

  aBrokerTotalCount: RInteger;
  aBrokerOnLineCount: RInteger;
  aBrokerOffLineCount: RInteger;
  aBrokerDebugCount: RInteger;
  aGatewayTotalCount: RInteger;
  aGatewayOnLineCount: RInteger;
  aGatewayOffLineCount: RInteger;
  aGatewayDoubtCount: RInteger;
  aGatewayDebugCount: RInteger;
  aTerminalTotalCount: RInteger;
  aTerminalOnLineCount: RInteger;
  aTerminalOffLineCount: RInteger;
  aTerminalDebugCount: RInteger;
begin
  try
    // 10 分钟记录一次日志
    if MinutesBetween(Now, FLastLogTime) > 1 then
    begin
      // MQTT 任务池
      //if _DDCommInter._GetTaskPoolInfo(aAllPoolCount, aUsePoolCount, aErrorInfo) then
      //  _DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, Format('MQTT 任务池状态: %d / %d', [aUsePoolCount, aAllPoolCount]));

      // 保存实时数据任务池
      //if TDDWorkCommIOCtrl.GetRealDataTaskPoolInfo(aAllPoolCount, aUsePoolCount, aErrorInfo) then
      //  _DDLogInter._WriteLog(UDDLogInter.DD_LOG_NAME, ltInfo, Format('实时数据 任务池状态: %d / %d', [aUsePoolCount, aAllPoolCount]));

      // 上报状态
      aDevId := TPrManagerInter.GetKey_Sn;
      if aDevId = '' then aDevId := _MyConfig.MySN;
      aPuerVer := TPrManagerInter.GetVersion;
      if TPrManagerInter.IsConsole then
        aPuerVer := aPuerVer + ' C'
      else
        aPuerVer := aPuerVer + ' S';
      if SameText(TPrManagerInter.GetCompileMode, 'Release') then
        aPuerVer := aPuerVer + 'R'
      else
        aPuerVer := aPuerVer + 'D';

      aDDVer := _MyConfig.DDVer;
      aMemory := FormatFloat('0.##', TPrManagerInter.GetProcMemorySize / 1024) + ' MB';
      aThread := TPrManagerInter.GetProcThreadCount;
      aHandleCount := TPrManagerInter.GetProcHandleCount;

      aDevTotalCount := -1;
      aDevOffLineCount := -1;
      if doGetTopoStateCountInfo(aBrokerTotalCount, aBrokerOnLineCount, aBrokerOffLineCount, aBrokerDebugCount,
           aGatewayTotalCount, aGatewayOnLineCount, aGatewayOffLineCount, aGatewayDoubtCount, aGatewayDebugCount,
           aTerminalTotalCount, aTerminalOnLineCount, aTerminalOffLineCount, aTerminalDebugCount, aErrorInfo) then
      begin
        if not aTerminalTotalCount.IsNull then
          aDevTotalCount := aTerminalTotalCount.Value;
        if not aTerminalOffLineCount.IsNull then
          aDevOffLineCount := aTerminalOffLineCount.Value;
      end;

      doRefreshDBInfo;

      aStream := TMemoryStream.Create;
      try
        aUrl := _MyConfig.UpStateUrl;
        aUrl := aUrl + '?brokerId=19';
        aUrl := aUrl + '&topic=' + string(TPrHttpFun.Str2HTML('DD-IoT-Monitor/TG-DD-Monitor'));
        aUrl := aUrl + '&payload=' + string(TPrHttpFun.Str2HTML(AnsiString(Format(PAYLOAD,
          [aDevId, aPuerVer, aDDVer, aMemory, aThread, aHandleCount, aDevTotalCount, aDevOffLineCount,
           FDBVer, FRecoveryModel, FDBDataSize, FDBLogSize, FLastBackupTime, FLastBackupSize]))));

        UPrHttpClientInter.Send_Get(FHttpHandle, aUrl, aStream, aErrorInfo);
        //TPrHttpClientInter.Get(aUrl, aStream, aErrorInfo, 5);
      finally
        aStream.Free;
      end;

      FLastLogTime := Now;
    end;
  except
    on E: Exception do
      TPrLogInter.WriteLogError('up log to DD-Center Error: ' + E.Message);
  end;
end;

procedure TPoolLogWork.Execute;
begin
  inherited;
  while not Terminated do
  begin
    doLog;

    if FEvent.WaitFor(1000) = wrSignaled then
      Exit;
  end;
end;

initialization
  _Active := False;

end.
