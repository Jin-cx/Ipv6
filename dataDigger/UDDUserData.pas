unit UDDUserData;

interface

uses
  puer.System,
  Generics.Collections;

type
  // 终端设备实时数据
  TUserData = class
  private
    FUserId: RInteger;    // ID
    FUserCode: RString;   // 用户编号
    FUserName: RString;   // 用户名称
    FIsAdmin: RBoolean;   // 是否是管理员账户
    FPassword: RString;   // 密码
    FIsEnable: RBoolean;  // 启用状态
    FTel: RString;        // 联系电话
    FEmail: RString;      // 邮箱地址
    FUserNote: RString;   // 账户编号
    FDayReport: RBoolean; // 每日一报
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
