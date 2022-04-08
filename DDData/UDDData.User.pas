unit UDDData.User;

interface

uses
  Classes, SysUtils, Windows,
  UPrDbConnInter, UPrEMailInter, UPrSmsInter,
  puer.System,
  UDDUserData,
  UDDData.Config;

// ��ȡ�û����� (ͨ������)
function doSendPwdByEMail(const aUserCode: RString;
                          var aError: RResult): Boolean; stdcall;

// ��ȡ�û����� (ͨ������)
function doSendPwdBySMS(const aUserCode: RString;
                        var aError: RResult): Boolean; stdcall;

// ��ȡ�û���Ϣ�б� }
function doGetUserList(const aIsEnable: RBoolean;
                       const aFilter: RString;
                       var aPageInfo: RPageInfo;
                       const aUserList: TUserDataList;
                       var aError: RResult): Boolean; stdcall;

// ��ȡ�û���ϸ��Ϣ
function doGetUserInfo(const aUserId: RInteger;
                       const aUser: TUserData;
                       var aError: RResult): Boolean; stdcall;

// �����û�
function doStartUser(const aUserId: RInteger;
                     var aError: RResult): Boolean; stdcall;

// ͣ���û�
function doStopUser(const aUserId: RInteger;
                    var aError: RResult): Boolean; stdcall;

// �޸�����
function doUpdatePwd(const aUserId: RInteger;
                     const aOldPwd: RString;
                     const aNewPwd: RString;
                     var aError: RResult): Boolean; stdcall;

// ��������
function doResetPwd(const aUserId: RInteger;
                    var aError: RResult): Boolean; stdcall;

// ��ȡ��ϵ��ʽ
function doGetUserContact(const aUserId: RInteger;
                          var aTel: RString;
                          var aEmail: RString;
                          var aError: RResult): Boolean; stdcall;

// �޸���ϵ��ʽ
function doSetUserContact(const aUserId: RInteger;
                          const aTel: RString;
                          const aEmail: RString;
                          var aError: RResult): Boolean; stdcall;

// �����û�
function doAddUser(const aUser: TUserData;
                   var aError: RResult): Boolean; stdcall;

// �༭�û�
function doUpdateUser(const aUser: TUserData;
                      var aError: RResult): Boolean; stdcall;

// ɾ���û�
function doDeleteUser(const aUserId: RInteger;
                      var aError: RResult): Boolean; stdcall;

// �û���¼
function doLogin(const aUserCode: RString;
                 const aPassword: RString;
                 const aIsAdmin: RBoolean;
                 const aUser: TUserData;
                 var aError: RResult): Boolean; stdcall;

exports
  doSendPwdByEMail,
  doSendPwdBySMS,
  doGetUserList,
  doGetUserInfo,
  doStartUser,
  doStopUser,
  doUpdatePwd,
  doResetPwd,
  doGetUserContact,
  doSetUserContact,
  doAddUser,
  doUpdateUser,
  doDeleteUser,
  doLogin;

implementation

function doSendPwdByEMail(const aUserCode: RString;
                          var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_GetPwdInfoForEmail';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError) and
              UPrEmailInter.SendEmail(aQuery.ReadFieldAsRString('email').AsString,
                                      aQuery.ReadFieldAsRString('emailTopic').AsString,
                                      aQuery.ReadFieldAsRString('emailText').AsString,
                                      aError.Info);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doSendPwdBySMS(const aUserCode: RString;
                        var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_GetPwdInfoForSMS';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError) and
              UPrSmsInter.SendSms(aQuery.ReadFieldAsRString('tel').AsString,
                                  aQuery.ReadFieldAsRString('smsText').AsString,
                                  aError.Info);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doGetUserList(const aIsEnable: RBoolean;
                       const aFilter: RString;
                       var aPageInfo: RPageInfo;
                       const aUserList: TUserDataList;
                       var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_GetUserList';
    //aQuery.AddParamB('isAdmin', aIsAdmin);
    aQuery.AddParamB('isAdmin', False);
    aQuery.AddParamB('isEnable', aIsEnable);
    aQuery.AddParamS('filter', aFilter);
    aQuery.AddParamB('usePaging', aPageInfo.IsNotNull);
    aQuery.AddParamPage(aPageInfo);
    aQuery.OpenProc;

    if aPageInfo.IsNotNull then
    begin
      aPageInfo := aQuery.ReadPageInfo;
      if not aQuery.GotoNextRecordset then
        Exit(True);
    end;

    aQuery.First;
    while not aQuery.Eof do
    begin
      with aUserList.Add do
      begin
        userId := aQuery.ReadFieldAsRInteger('userId');
        userCode := aQuery.ReadFieldAsRString('userCode');
        userName := aQuery.ReadFieldAsRString('userName');
        isAdmin := aQuery.ReadFieldAsRBoolean('isAdmin');
        isEnable := aQuery.ReadFieldAsRBoolean('isEnable');
        tel := aQuery.ReadFieldAsRString('tel');
        email := aQuery.ReadFieldAsRString('email');
        userNote := aQuery.ReadFieldAsRString('userNote');
        dayReport := aQuery.ReadFieldAsRBoolean('dayReport');
      end;
      aQuery.Next;
    end;

    Result := True;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doGetUserInfo(const aUserId: RInteger;
                       const aUser: TUserData;
                       var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_GetUserInfo';
    aQuery.AddParamI('userId', aUserId);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
    if not Result then
      Exit;

    with aUser do
    begin
      userID := aQuery.ReadFieldAsRInteger('userId');
      userCode := aQuery.ReadFieldAsRString('userCode');
      userName := aQuery.ReadFieldAsRString('userName');
      isEnable := aQuery.ReadFieldAsRBoolean('isEnable');
      tel := aQuery.ReadFieldAsRString('tel');
      email := aQuery.ReadFieldAsRString('email');
      userNote := aQuery.ReadFieldAsRString('userNote');
      dayReport := aQuery.ReadFieldAsRBoolean('dayReport');
    end;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doStartUser(const aUserId: RInteger;
                     var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_SetUserEnable';
    aQuery.AddParamI('userId', aUserId);
    aQuery.AddParamB('isEnable', True);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doStopUser(const aUserId: RInteger;
                    var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_SetUserEnable';
    aQuery.AddParamI('userId', aUserId);
    aQuery.AddParamB('isEnable', False);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doUpdatePwd(const aUserId: RInteger;
                     const aOldPwd: RString;
                     const aNewPwd: RString;
                     var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_ChangeUserPwd';
    aQuery.AddParamI('userId', aUserId);
    aQuery.AddParamS('oldPwd', aOldPwd);
    aQuery.AddParamS('newPwd', aNewPwd);
    aQuery.AddParamS('commitPwd', aNewPwd{aCommitPwd});
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doResetPwd(const aUserId: RInteger;
                    var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_ResetUserPwd';
    aQuery.AddParamI('userId', aUserId);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doGetUserContact(const aUserId: RInteger;
                          var aTel: RString;
                          var aEmail: RString;
                          var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  Result := False;

  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_GetUserContact';
    aQuery.AddParamI('userId', aUserId);
    aQuery.OpenProc;

    if aQuery.ReadSQLResult(aError) then
    begin
      aTel := aQuery.ReadFieldAsRString('tel');
      aEmail := aQuery.ReadFieldAsRString('email');

      Result := True;
    end;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doSetUserContact(const aUserId: RInteger;
                          const aTel: RString;
                          const aEmail: RString;
                          var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_UpdateUserContact';
    aQuery.AddParamI('userId', aUserId);
    aQuery.AddParamS('tel', aTel);
    aQuery.AddParamS('email', aEmail);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doAddUser(const aUser: TUserData;
                   var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  Result := False;

  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_AddUser';
    aQuery.AddParamS('userCode', aUser.UserCode);
    aQuery.AddParamS('userName', aUser.UserName);
    aQuery.AddParamS('tel', aUser.tel);
    aQuery.AddParamS('email', aUser.email);
    aQuery.AddParamB('isEnable', aUser.isEnable);
    aQuery.AddParamS('userNote', aUser.userNote);
    aQuery.AddParamB('dayReport', aUser.dayReport);
    aQuery.OpenProc;

    if aQuery.ReadSQLResult(aError) then
    begin
      aUser.userId := aQuery.ReadFieldAsRInteger('userId');

      Result := True;
    end;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doUpdateUser(const aUser: TUserData;
                      var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_UpdateUser';
    aQuery.AddParamI('userId', aUser.userId);
    aQuery.AddParamS('userCode', aUser.userCode);
    aQuery.AddParamS('userName', aUser.userName);
    aQuery.AddParamS('tel', aUser.tel);
    aQuery.AddParamS('email', aUser.email);
    aQuery.AddParamB('isEnable', aUser.isEnable);
    aQuery.AddParamS('userNote', aUser.userNote);
    aQuery.AddParamB('dayReport', aUser.dayReport);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doDeleteUser(const aUserId: RInteger;
                      var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_DeleteUser';
    aQuery.AddParamI('userId', aUserId);
    aQuery.OpenProc;

    Result := aQuery.ReadSQLResult(aError);
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

function doLogin(const aUserCode: RString;
                 const aPassword: RString;
                 const aIsAdmin: RBoolean;
                 const aUser: TUserData;
                 var aError: RResult): Boolean;
var
  aQuery: TPrADOQuery;
begin
  Result := False;

  aQuery := TPrDbConnInter.LockAdoQuery(DB_METER);
  try
    aQuery.ProcName := 'proc_Login';
    aQuery.AddParamS('userCode', aUserCode);
    aQuery.AddParamS('password', aPassword);
    aQuery.AddParamB('isAdmin', aIsAdmin);
    aQuery.OpenProc;

    if aQuery.ReadSQLResult(aError) then
    begin
      aUser.userId   := aQuery.ReadFieldAsRInteger('userId');
      aUser.userCode := aQuery.ReadFieldAsRString('userCode');
      aUser.userName := aQuery.ReadFieldAsRString('userName');
      aUser.isAdmin  := aQuery.ReadFieldAsRBoolean('isAdmin');

      Result := True;
    end;
  finally
    TPrDbConnInter.UnlockAdoQuery(aQuery);
  end;
end;

end.
