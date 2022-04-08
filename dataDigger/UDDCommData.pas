{
  ��Ԫ: ͨѶ���ı��봦��Ԫ
  ����: lynch
  ����: 2016-08-02
}

unit UDDCommData;

interface

uses
  SysUtils, Windows, Classes,
  puer.DateUtils, puer.Json.JsonDataObjects;

const
  // ��ǰʱ��
  SYSTEM_TIME_ZONE = 8;

type
  // ͨѶ��������
  TCommDataType = (
    cdtError,       // ������
    cdtRequest,     // ��ҪӦ�������
    cdtUpdate,      // ��Ӧ�������
    cdtResponse     // Ӧ��
  );

  // ������Դ��Ϣ
  TFromInfo = record
    _devid: string;    // �豸���
    _model: string;    // �豸�ͺ�
    _version: string;  // ����汾
    _runstate: string; // ����״̬
  end;

  // ������Ϣ
  TCommDataInfo = record
    Receiver: string;
    Sender: string;
    BrokerId: Integer;
    DataType: TCommDataType;
    From: TFromInfo;
    RequestId: string;
    TaskId: Integer;
    Cmd: string;
    CmdData: string;
    StatusCode: string;
    ResponseData: string;
    CommStr: string;
    ReceiveTime: TDateTime;
  public
    function AsJsonStrForDebug: string;
  end;

  // ͨѶ���Ļ�����
  TCustomCommData = class
  private
    FJsonData: TJsonObject;          // ���� Json
    FCommDataType: TCommDataType;    // ��������
    FFrom: TFromInfo;                // ������Դ��Ϣ

    procedure AddHeader(const aFrom: TFromInfo);
    procedure AddRequest;
    procedure AddResponse;

    function IndexOfArray(const aJsonArray: TJsonArray;
                          const aKey: string): Integer;
    procedure doUpdateReturnKeyArray(const aKey: string;
                                     const aNeedReturn: Boolean);
    function doGetFromInfo: Boolean;

    function GetCmd: string;
    function GetCmdDataStr: string;
    function GetRequestTimestamp: TDateTime;
    function GetRequestId: string;
    function GetTaskId: Integer;

    function GetStatusCode: string;
    function GetResponseDataStr: string;
    function GetResponseTimestamp: TDateTime;

    procedure doParseCommData(const aCommData: string);
  protected
    procedure doSetCmd(const aCmd: string;                             //*����
                       const aNeedReturn: Boolean = False);            // ��Ҫ����
    procedure doSetData(const aData: string;                           // �������
                        const aNeedReturn: Boolean = False);
    procedure doSetTimestamp(const aDateTime: TDateTime;               // ʱ���
                             const aNeedReturn: Boolean = False);
    procedure doSetRequestId(const aRequestId: string;                 // �������κ�
                             const aNeedReturn: Boolean = False);
    procedure doSetStatusCode(const aStatusCode: string);              // Ӧ����
    procedure doSetRequestFromRequest(const aRequestData: TCustomCommData);  // ���������ֶ�
  public
    constructor Create(const aCommDataType: TCommDataType;    // ��������
                       const aFrom: TFromInfo); overload;     // ������Դ��Ϣ
    constructor Create(const aCommData: string); overload;    // ���յ��ı���
    destructor Destroy; override;

    function AsString: string;
    procedure GetRequestReturnKeyList(const aKeyList: TStrings);
    function GetResponseJson: TJsonObject;

    property CommDataType: TCommDataType read FCommDataType; // ��������
    property From: TFromInfo read FFrom;                     // ������Դ��Ϣ

    property Cmd: string read GetCmd;
    property CmdDataStr: string read GetCmdDataStr;
    property RequestTimestamp: TDateTime read GetRequestTimestamp;
    property RequestId: string read GetRequestId;
    property TaskId: Integer read GetTaskId;

    property StatusCode: string read GetStatusCode;
    property ResponseDataStr: string read GetResponseDataStr;
    property ResponseTimestamp: TDateTime read GetResponseTimestamp;
  end;

  // ���� ( ��Ӧ�� )
  TRequestData = class(TCustomCommData)
  public
    constructor Create(const aFrom: TFromInfo);                      // ������Դ��Ϣ

    procedure SetCmd(const aCmd: string;                             //*����
                     const aNeedReturn: Boolean = False);            // ��Ҫ����
    procedure SetData(const aData: string;                           // �������
                      const aNeedReturn: Boolean = False);
    procedure SetTimestamp(const aDateTime: TDateTime;               // ʱ���
                           const aNeedReturn: Boolean = False);
    procedure SetRequestId(const aRequestId: string;                 // �������κ�
                           const aNeedReturn: Boolean = False);
  end;

  // ���� ( ��Ӧ�� )
  TUpdateData = class(TCustomCommData)
  public
    constructor Create(const aFrom: TFromInfo);                 // ������Դ��Ϣ

    procedure SetCmd(const aCmd: string);                       //*����
    procedure SetData(const aData: string);                     // �������
    procedure SetTimestamp(const aDateTime: TDateTime);         // ʱ���
    procedure SetRequestId(const aRequestId: string);           // �������κ�
  end;

  // Ӧ�� ( ��Ӧ�� )
  TResponseData = class(TCustomCommData)
  public
    constructor Create(const aFrom: TFromInfo;                  // ������Դ��Ϣ
                       const aRequestData: TCustomCommData);    // ������

    procedure SetTimestamp(const aDateTime: TDateTime);         // ʱ���
    procedure SetStatusCode(const aStatusCode: string);         // Ӧ����
    procedure SetData(const aData: string); overload;           // Ӧ������
  end;

function _ParseCommData(const aCommData: string): TCommDataInfo;

implementation

function _ParseCommData(const aCommData: string): TCommDataInfo;
var
  aComm: TCustomCommData;
begin
  aComm := TCustomCommData.Create(aCommData);

  try
    Result.DataType := aComm.CommDataType;
    Result.CommStr := aCommData;

    if aComm.CommDataType = cdtError then
      Exit;

    Result.From := aComm.From;
    Result.RequestId := aComm.RequestId;
    Result.TaskId := aComm.TaskId;
    Result.Cmd := aComm.Cmd;
    Result.CmdData := aComm.CmdDataStr;
    Result.StatusCode := aComm.StatusCode;
    Result.ResponseData := aComm.ResponseDataStr;
  finally
    aComm.Free;
  end;
end;

function CommDataTypeToString(const aCommDataType: TCommDataType): string;
begin
  Result := '';

  case aCommDataType of
    cdtRequest:  Result := 'request';
    cdtUpdate:   Result := 'update';
    cdtResponse: Result := 'response';
  end;
end;

function StringToCommDataType(const aCommDataTypeStr: string): TCommDataType;
begin
  Result := cdtError;

  if SameText(aCommDataTypeStr, 'request') then
    Result := cdtRequest
  else if SameText(aCommDataTypeStr, 'update') then
    Result := cdtUpdate
  else if SameText(aCommDataTypeStr, 'response') then
    Result := cdtResponse;
end;

{ TCustomCommData }
constructor TCustomCommData.Create(const aCommDataType: TCommDataType;
                                   const aFrom: TFromInfo);
begin
  inherited Create;
  FCommDataType := aCommDataType;
  FFrom := aFrom;

  FJsonData := TJsonObject.Create;
  AddHeader(FFrom);
  AddRequest;
  if FCommDataType = cdtResponse then
    AddResponse;
end;

constructor TCustomCommData.Create(const aCommData: string);
begin
  inherited Create;
  FJsonData := TJsonObject.Create;
  FCommDataType := cdtError;

  doParseCommData(aCommData);
end;

procedure TCustomCommData.doParseCommData(const aCommData: string);
var
  aTmpCommDataType: TCommDataType;
begin
  try
    FJsonData.FromJSON(aCommData);

    if not FJsonData.Contains('header') or not FJsonData.Contains('request') then
      Exit;

    aTmpCommDataType := StringToCommDataType(FJsonData.O['header'].S['msgtype']);
    if aTmpCommDataType = cdtError then
      Exit;

    if not doGetFromInfo then
      Exit;

    case aTmpCommDataType of
      cdtRequest:
        begin
          //if FJsonData.O['request'].S['return'] = '' then
          //  Exit;
          if FJsonData.O['request'].S['cmd'] = '' then
            Exit;
        end;
      cdtUpdate:
        begin
          if FJsonData.O['request'].S['cmd'] = '' then
            Exit;
        end;
      cdtResponse:
        begin
          if not FJsonData.Contains('response') then
            Exit;
          if FJsonData.O['response'].S['statuscode'] = '' then
            Exit;
        end;
    end;

    FCommDataType := aTmpCommDataType;
  except
    FCommDataType := cdtError;
  end;
end;

destructor TCustomCommData.Destroy;
begin
  FJsonData.Free;
  inherited;
end;

procedure TCustomCommData.AddHeader(const aFrom: TFromInfo);
var
  aFromJson: TJsonObject;
begin
  FJsonData.O['header'].S['msgtype'] := CommDataTypeToString(FCommDataType);
  aFromJson := FJsonData.O['header'].O['from'];
  aFromJson.S['_devid'] := aFrom._devid;
  aFromJson.S['_model'] := aFrom._model;
  aFromJson.S['_version'] := aFrom._version;
  aFromJson.S['_runstate'] := aFrom._runstate;
end;

procedure TCustomCommData.AddRequest;
var
  aRequestJson: TJsonObject;
begin
  aRequestJson := FJsonData.O['request'];
  if FCommDataType = cdtRequest then
    aRequestJson.A['return'].Count := 0;
end;

procedure TCustomCommData.AddResponse;
begin
  FJsonData.O['response'] := nil;
end;

function TCustomCommData.AsString: string;
begin
  Result := FJsonData.ToString;
end;

function TCustomCommData.IndexOfArray(const aJsonArray: TJsonArray;
                                      const aKey: string): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to aJsonArray.Count - 1 do
    if SameText(aKey, aJsonArray.S[i]) then
      Result := i;
end;

procedure TCustomCommData.doUpdateReturnKeyArray(const aKey: string;
                                                 const aNeedReturn: Boolean);
var
  aIndex: Integer;
  aReturnKeyArray: TJsonArray;
begin
  aReturnKeyArray := FJsonData.O['request'].A['return'];
  aIndex := IndexOfArray(aReturnKeyArray, aKey);

  if aNeedReturn and (aIndex = -1) then
    aReturnKeyArray.Add(aKey)
  else if not aNeedReturn and (aIndex <> -1) then
    aReturnKeyArray.Delete(aIndex);
end;

function TCustomCommData.doGetFromInfo: Boolean;
var
  aFromJson: TJsonObject;
begin
  aFromJson := FJsonData.O['header'].O['from'];

  FFrom._devid    := aFromJson.S['_devid'];
  FFrom._model    := aFromJson.S['_model'];
  FFrom._version  := aFromJson.S['_version'];
  FFrom._runstate := aFromJson.S['_runstate'];

  if FFrom._model = 'TG100' then
    FFrom._model := 'TG100-N-485';

  {if (FFrom._devid = '') or
     (FFrom._model = '') or
     (FFrom._version = '') or
     (FFrom._runstate = '') then
    Exit; }

  Result := True;
end;

function TCustomCommData.GetCmd: string;
begin
  Result := FJsonData.O['request'].S['cmd'];
end;

function TCustomCommData.GetCmdDataStr: string;
begin
  Result := FJsonData.O['request'].RS['data'].AsString;
end;

function TCustomCommData.GetRequestTimestamp: TDateTime;
begin
  Result := UnixTimestampToDateTime(FJsonData.O['request'].I['timestamp'], SYSTEM_TIME_ZONE);
end;

function TCustomCommData.GetRequestId: string;
begin
  Result := FJsonData.O['request'].S['requestid'];
end;

function TCustomCommData.GetTaskId: Integer;
begin
  Result := FJsonData.O['request'].I['taskid'];
end;

function TCustomCommData.GetStatusCode: string;
begin
  Result := FJsonData.O['response'].S['statuscode'];
end;

function TCustomCommData.GetResponseDataStr: string;
begin
  Result := FJsonData.O['response'].RS['data'].AsString;
end;

function TCustomCommData.GetResponseTimestamp: TDateTime;
begin
  Result := UnixTimestampToDateTime(FJsonData.O['response'].I['timestamp'], SYSTEM_TIME_ZONE);
end;

procedure TCustomCommData.doSetCmd(const aCmd: string;
                                   const aNeedReturn: Boolean);
begin
  FJsonData.O['request'].S['cmd'] := aCmd;

  if FCommDataType = cdtRequest then
    doUpdateReturnKeyArray('cmd', aNeedReturn);
end;

procedure TCustomCommData.doSetData(const aData: string;
                                    const aNeedReturn: Boolean);
begin
  if FCommDataType = cdtResponse then
    FJsonData.O['response'].S['data'] := aData
  else
  begin
    FJsonData.O['request'].S['data'] := aData;

    if FCommDataType = cdtRequest then
      doUpdateReturnKeyArray('data', aNeedReturn);
  end;
end;

procedure TCustomCommData.doSetTimestamp(const aDateTime: TDateTime;
                                         const aNeedReturn: Boolean = False);
var
  aUnixTimestamp: Int64;
begin
  aUnixTimestamp := DateTimeToUnixTimestamp(aDateTime, SYSTEM_TIME_ZONE);

  if FCommDataType = cdtResponse then
    FJsonData.O['response'].I['timestamp'] := aUnixTimestamp
  else
  begin
    FJsonData.O['request'].I['timestamp'] := aUnixTimestamp;

    if FCommDataType = cdtRequest then
      doUpdateReturnKeyArray('timestamp', aNeedReturn);
  end;
end;

procedure TCustomCommData.doSetRequestId(const aRequestId: string;
                                         const aNeedReturn: Boolean);
begin
  FJsonData.O['request'].S['requestid'] := aRequestId;

  if FCommDataType = cdtRequest then
    doUpdateReturnKeyArray('requestid', aNeedReturn);
end;

procedure TCustomCommData.doSetStatusCode(const aStatusCode: string);
begin
  if FCommDataType = cdtResponse then
    FJsonData.O['response'].S['statuscode'] := aStatusCode;
end;

procedure TCustomCommData.GetRequestReturnKeyList(const aKeyList: TStrings);
var
  aReturnKeyArray: TJsonArray;
  i: Integer;
begin
  aKeyList.Clear;

  if FCommDataType = cdtRequest then
  begin
    aReturnKeyArray := FJsonData.O['request'].A['return'];
    for i := 0 to aReturnKeyArray.Count - 1 do
      aKeyList.Add(aReturnKeyArray.S[i]);
  end;
end;

function TCustomCommData.GetResponseJson: TJsonObject;
begin
  Result := FJsonData.O['request'];
end;

procedure TCustomCommData.doSetRequestFromRequest(const aRequestData: TCustomCommData);
begin
  FJsonData.O['response'].Assign(aRequestData.GetResponseJson);
end;

{ TRequestData }
constructor TRequestData.Create(const aFrom: TFromInfo);
begin
  inherited Create(cdtRequest, aFrom);
end;

procedure TRequestData.SetCmd(const aCmd: string;
                              const aNeedReturn: Boolean = False);
begin
  doSetCmd(aCmd, aNeedReturn);
end;

procedure TRequestData.SetData(const aData: string;
                               const aNeedReturn: Boolean = False);
begin
  doSetData(aData, aNeedReturn);
end;

procedure TRequestData.SetTimestamp(const aDateTime: TDateTime;
                                    const aNeedReturn: Boolean = False);
begin
  doSetTimestamp(aDateTime, aNeedReturn);
end;

procedure TRequestData.SetRequestId(const aRequestId: string;
                                    const aNeedReturn: Boolean = False);
begin
  doSetRequestId(aRequestId, aNeedReturn);
end;

{ TUpdateData }
constructor TUpdateData.Create(const aFrom: TFromInfo);
begin
  inherited Create(cdtUpdate, aFrom);
end;

procedure TUpdateData.SetCmd(const aCmd: string);
begin
  doSetCmd(aCmd);
end;

procedure TUpdateData.SetData(const aData: string);
begin
  doSetData(aData);
end;

procedure TUpdateData.SetTimestamp(const aDateTime: TDateTime);
begin
  doSetTimestamp(aDateTime);
end;

procedure TUpdateData.SetRequestId(const aRequestId: string);
begin
  doSetRequestId(aRequestId);
end;

{ TResponseData }
constructor TResponseData.Create(const aFrom: TFromInfo;
                                 const aRequestData: TCustomCommData);
begin
  inherited Create(cdtResponse, aFrom);
  doSetRequestFromRequest(aRequestData);
end;

procedure TResponseData.SetTimestamp(const aDateTime: TDateTime);
begin
  doSetTimestamp(aDateTime);
end;

procedure TResponseData.SetStatusCode(const aStatusCode: string);
begin
  doSetStatusCode(aStatusCode);
end;

procedure TResponseData.SetData(const aData: string);
begin
  doSetData(aData);
end;

{ TCommDataInfo }
function TCommDataInfo.AsJsonStrForDebug: string;
var
  aJson: TJsonObject;
  aCommType: string;
begin
  aJson := TJsonObject.Create;
  try
    case DataType of
      cdtError:    aCommType := 'Error';
      cdtRequest:  aCommType := 'Request';
      cdtUpdate:   aCommType := 'Update';
      cdtResponse: aCommType := 'Response';
    end;
    aJson.I['brokerId'] := BrokerId;
    aJson.S['commType'] := aCommType;
    aJson.S['gatewayDevId'] := From._devid;
    aJson.S['commStr'] := CommStr;
    Result := aJson.ToJson(True);
  finally
    aJson.Free;
  end;
end;

end.
