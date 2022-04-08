unit UDDUserData;

interface

uses
  puer.System,
  Generics.Collections;

type
  // �ն��豸ʵʱ����
  TUserData = class
  private
    FUserId: RInteger;    // ID
    FUserCode: RString;   // �û����
    FUserName: RString;   // �û�����
    FIsAdmin: RBoolean;   // �Ƿ��ǹ���Ա�˻�
    FPassword: RString;   // ����
    FIsEnable: RBoolean;  // ����״̬
    FTel: RString;        // ��ϵ�绰
    FEmail: RString;      // �����ַ
    FUserNote: RString;   // �˻����
    FDayReport: RBoolean; // ÿ��һ��
  public
    constructor Create;

    property UserId: RInteger read FUserId write FUserId;
    property UserCode: RString read FUserCode write FUserCode;
    property UserName: RString read FUserName write FUserName;
    property IsAdmin: RBoolean read FIsAdmin write FIsAdmin;
    property Password: RString read FPassword write FPassword;
    property IsEnable: RBoolean read FIsEnable write FIsEnable;
    property Tel: RString read FTel write FTel;
    property Email: RString read FEmail write FEmail;
    property UserNote: RString read FUserNote write FUserNote;
    property DayReport: RBoolean read FDayReport write FDayReport;
  end;

  TUserDataList = class(TObjectList<TUserData>)
  public
    function Add(): TUserData; overload;
  end;

implementation

{ TUserData }
constructor TUserData.Create;
begin
  FUserId.Clear;
  FUserCode.Clear;
  FUserName.Clear;
  FIsAdmin.Clear;
  FPassword.Clear;
  FIsEnable.Clear;
  FTel.Clear;
  FEmail.Clear;
  FUserNote.Clear;
end;

{ TUserDataList }
function TUserDataList.Add(): TUserData;
begin
  Result := TUserData.Create;
  Self.Add(Result);
end;

end.
