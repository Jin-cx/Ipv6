unit UDDChangeData;

interface

uses
  SysUtils, Generics.Collections,
  puer.System;

type
  TMeterValueData = class
  private
    FmeterValueCode: RString;  // �������
    FmeterValue: RDouble;      // ����ֵ
  public
    constructor Create;

    property meterValueCode: RString read FmeterValueCode write FmeterValueCode;
    property meterValue: RDouble read FmeterValue write FmeterValue;
  end;

  TMeterValueDataList = class(TObjectList<TMeterValueData>)
  public
    function Add(): TMeterValueData; overload;

    function HasValue(const aMeterValueCode: string): Boolean;
  end;

  // �ն��豸ʵʱ����
  TChangeData = class
  private
    FchangeId: RInteger;                  // ���� ID
    FuserId: RInteger;                    // �û� ID
    FuserCode: RString;                   // �û����
    FuserName: RString;                   // �û�����
    FprojectUserCode: RString;            // ʵ���û����
    FprojectUserName: RString;            // ʵ���û�����
    FchangeTime: RDateTime;               // ����ʱ��
    FchangeNote: RString;                 // ����ע
    FdevName: RString;                    // �豸����
    FdevModel: RString;                   // �豸�ͺ�
    FdevModelName: RString;               // �豸�ͺ�
    FdevInstallAddr: RString;             // �豸��װ��ַ
    FoldDevId: RInteger;                  // �� �豸 ID
    FoldDevNo: RString;                   // �� �豸���
    FoldDevFactoryNo: RString;            // �� �豸���ұ��
    FnewDevId: RInteger;                  // �� �豸 ID
    FnewDevNo: RString;                   // �� �豸���
    FnewDevFactoryNo: RString;            // �� �豸���ұ��
    FnewConn: RString;                    // �� ���Ӳ���
    FnewDevNote: RString;                 // �� ��ע
    FendTime: RDateTime;                  // ����ʱ��
    FendValueList: TMeterValueDataList;   // ����ʾ���б�
    FbeginTime: RDateTime;                // ��ʼʱ��
    FbeginValueList: TMeterValueDataList; // ��ʼʾ���б�
  public
    constructor Create;
    destructor Destroy; override;

    property changeId: RInteger read FchangeId write FchangeId;
    property userId: RInteger read FuserId write FuserId;
    property userCode: RString read FuserCode write FuserCode;
    property userName: RString read FuserName write FuserName;
    property projectUserCode: RString read FprojectUserCode write FprojectUserCode;
    property projectUserName: RString read FprojectUserName write FprojectUserName;
    property changeTime: RDateTime read FchangeTime write FchangeTime;
    property changeNote: RString read FchangeNote write FchangeNote;
    property devName: RString read FdevName write FdevName;
    property devModel: RString read FdevModel write FdevModel;
    property devModelName: RString read FdevModelName write FdevModelName;
    property devInstallAddr: RString read FdevInstallAddr write FdevInstallAddr;
    property oldDevId: RInteger read FoldDevId write FoldDevId;
    property oldDevNo: RString read FoldDevNo write FoldDevNo;
    property oldDevFactoryNo: RString read FoldDevFactoryNo write FoldDevFactoryNo;
    property newDevId: RInteger read FnewDevId write FnewDevId;
    property newDevNo: RString read FnewDevNo write FnewDevNo;
    property newDevFactoryNo: RString read FnewDevFactoryNo write FnewDevFactoryNo;
    property newConn: RString read FnewConn write FnewConn;
    property newDevNote: RString read FnewDevNote write FnewDevNote;
    property endTime: RDateTime read FendTime write FendTime;
    property endValueList: TMeterValueDataList read FendValueList write FendValueList;
    property beginTime: RDateTime read FbeginTime write FbeginTime;
    property beginValueList: TMeterValueDataList read FbeginValueList write FbeginValueList;
  end;

  TChangeDataList = class(TObjectList<TChangeData>)
  public
    function Add(): TChangeData; overload;
  end;

implementation

{ TMeterValueData }
constructor TMeterValueData.Create;
begin
  FmeterValueCode.Clear;
  FmeterValue.Clear;
end;

{ TMeterValueDataList }
function TMeterValueDataList.Add(): TMeterValueData;
begin
  Result := TMeterValueData.Create;
  Self.Add(Result);
end;

function TMeterValueDataList.HasValue(const aMeterValueCode: string): Boolean;
var
  aMeterValue: TMeterValueData;
begin
  for aMeterValue in Self do
  begin
    if SameText(aMeterValue.meterValueCode.AsString, aMeterValueCode) then
    begin
      Result := not aMeterValue.FmeterValue.IsNull;
      Exit;
    end;
  end;

  Result := False;
end;

{ TChangeData }
constructor TChangeData.Create;
begin
  inherited;
  FendValueList := TMeterValueDataList.Create;
  FbeginValueList := TMeterValueDataList.Create;

  FchangeId.Clear;
  FuserId.Clear;
  FuserCode.Clear;
  FuserName.Clear;
  FprojectUserCode.Clear;
  FprojectUserName.Clear;
  FchangeTime.Clear;
  FchangeNote.Clear;
  FdevName.Clear;
  FdevModel.Clear;
  FdevModelName.Clear;
  FdevInstallAddr.Clear;
  FoldDevId.Clear;
  FoldDevNo.Clear;
  FoldDevFactoryNo.Clear;
  FnewDevId.Clear;
  FnewDevNo.Clear;
  FnewDevFactoryNo.Clear;
  FnewConn.Clear;
  FnewDevNote.Clear;
  FendTime.Clear;
  FbeginTime.Clear;
end;

destructor TChangeData.Destroy;
begin
  FendValueList.Free;
  FbeginValueList.Free;
  inherited;
end;

{ TChangeDataList }
function TChangeDataList.Add(): TChangeData;
begin
  Result := TChangeData.Create;
  Self.Add(Result);
end;

end.
