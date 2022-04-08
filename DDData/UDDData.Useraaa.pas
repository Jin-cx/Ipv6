unit UDDData.Useraaa;

interface

uses
  Classes, SysUtils, Generics.Collections, Windows,
  puer.System, puer.SyncObjs, puer.SQLite,
  UDDUserData;

const
  USER_ADMIN      = 'Admin';            // ����Ա�˻�
  USER_GUEST      = 'Guest';            // �ο��˻��������ѯ��
  DEF_PWD_GENERAL = '123456';           // Ĭ������ ��ͨ�˻�
  DEF_PWD_ADMIN   = 'P@ssw0rd';         // Ĭ������ ����Ա�˻�
  DEF_PWD_GUEST   = 'Things@123456';    // Ĭ������ �ο��˻�

  ERROR_USER_NOT_EXISTS        = '�û������ڻ��ѱ�ɾ��';
  ERROR_USER_OR_PASSWORD_ERROR = '�û������������';
  ERROR_QUERY_USER_INFO        = '��ȡ�û��������:%s';
  ERROR_QUERY_USER_LIST        = '��ȡ�û��б����:%s';
  ERROR_ADD_USER               = '�����û�����:%s';
  ERROR_UPDATE_USER            = '�༭�û�����:%s';
  ERROR_USER_CODE_NULL         = '�û���Ų���Ϊ��';
  ERROR_USER_NAME_NULL         = '�û����Ʋ���Ϊ��';
  ERROR_USER_CODE_EXISTS       = '�û�����Ѵ���';
  ERROR_USER_NAME_EXISTS       = '�û������Ѵ���';

type
  TUserDataCtrl = class
  public
    class procedure Open(const aDataPath: string);
    class procedure Close;
  end;








// У���û�����
function doLogin(const aUserCode: RString;
                 const aPassword: RString;
                 const aIsAdmin: RBoolean;
                 const aUser: TUserData;
                 var aErrorInfo: string): Boolean; stdcall;











exports
  doLogin,
  doUpdatePwd,
  doGetUserContact,
  doSetUserContact,
  doResetPwd,
  doAddUser,
  doUpdateUser,
  doDeleteUser,
  doGetUserList;

implementation




function doLogin(const aUserCode: RString;
                 const aPassword: RString;
                 const aIsAdmin: RBoolean;
                 const aUser: TUserData;
                 var aErrorInfo: string): Boolean;
begin
  Result := _UserDataMgr.GetUserInfoByCode(aUserCode, aIsAdmin, aUser, aErrorInfo) and
            (aUser.Password.AsString = aPassword.AsString);
  if not Result then
    aErrorInfo := ERROR_USER_OR_PASSWORD_ERROR;
end;

function doUpdatePwd(const aUserId: RInteger;
                     const aOldPwd: RString;
                     const aNewPwd: RString;
                     var aErrorInfo: string): Boolean;
var
  aUser: TUserData;
begin
  Result := False;

  if aNewPwd.AsString = '' then
  begin
    aErrorInfo := '�����벻��Ϊ��';
    Exit;
  end;

  if aOldPwd.AsString = aNewPwd.AsString then
  begin
    aErrorInfo := '�����벻�����������ͬ';
    Exit;
  end;

  aUser := TUserData.Create;
  try
    if not _UserDataMgr.GetUserInfoById(aUserId, aUser, aErrorInfo) then
    begin
      aErrorInfo := ERROR_USER_NOT_EXISTS;
      Exit;
    end;

    if not (aUser.Password.AsString = aOldPwd.AsString) then
    begin
      aErrorInfo := 'ԭ���벻��ȷ';
      Exit;
    end;

    if not _UserDataMgr.UpdatePwd(aUserId, aNewPwd, aErrorInfo) then
    begin
      aErrorInfo := ERROR_USER_NOT_EXISTS;
      Exit;
    end;

    Result := True;
  finally
    aUser.Free;
  end;
end;

function doGetUserContact(const aUserId: RInteger;
                          var aTel: RString;
                          var aEmail: RString;
                          var aErrorInfo: string): Boolean;
var
  aUser: TUserData;
begin
  Result := False;

  aUser := TUserData.Create;
  try
    if not _UserDataMgr.GetUserInfoById(aUserId, aUser, aErrorInfo) then
    begin
      aErrorInfo := ERROR_USER_NOT_EXISTS;
      Exit;
    end;

    aTel := aUser.Tel;
    aEmail := aUser.Email;

    Result := True;
  finally
    aUser.Free;
  end;
end;

function doSetUserContact(const aUserId: RInteger;
                          const aTel: RString;
                          const aEmail: RString;
                          var aErrorInfo: string): Boolean;
begin
  if not _UserDataMgr.SetUserContact(aUserId, aTel, aEmail, aErrorInfo) then
  begin
    Result := False;
    aErrorInfo := ERROR_USER_NOT_EXISTS;
  end
  else
    Result := True;
end;

function doResetPwd(const aUserId: RInteger;
                    var aErrorInfo: string): Boolean;
begin
  if not _UserDataMgr.UpdatePwd(aUserId, RString.Parse(DEF_PWD_GENERAL), aErrorInfo) then
  begin
    Result := False;
    aErrorInfo := ERROR_USER_NOT_EXISTS;
  end
  else
    Result := True;
end;

function doAddUser(const aUser: TUserData;
                   var aErrorInfo: string): Boolean;
begin
  Result := _UserDataMgr.AddUser(aUser, aErrorInfo);
end;

function doUpdateUser(const aUser: TUserData;
                      var aErrorInfo: string): Boolean;
begin
  Result := _UserDataMgr.UpdateUser(aUser, aErrorInfo);
end;

function doDeleteUser(const aUserId: RInteger;
                      var aErrorInfo: string): Boolean;
begin
  if not _UserDataMgr.DeleteUser(aUserId, aErrorInfo) then
  begin
    Result := False;
    aErrorInfo := ERROR_USER_NOT_EXISTS;
  end
  else
    Result := True;
end;

function doGetUserList(const aIsEnable: RBoolean;
                       const aFilter: RString;
                       var aPageInfo: RPageInfo;
                       const aUserList: TUserDataList;
                       var aErrorInfo: string): Boolean;
begin
  Result := _UserDataMgr.GetUserList(aIsEnable, aFilter, aPageInfo, aUserList, aErrorInfo);
end;

function doGetUserInfo(const aUserId: RInteger;
                       const aUser: TUserData;
                       var aErrorInfo: string): Boolean;
begin
  if not _UserDataMgr.GetUserInfoById(aUserId, aUser, aErrorInfo) then
  begin
    Result := False;
    aErrorInfo := ERROR_USER_NOT_EXISTS;
  end
  else
    Result := True;
end;

function doStartUser(const aUserId: RInteger;
                     var aErrorInfo: string): Boolean;
begin
  if not _UserDataMgr.SetUserEnable(aUserId, True, aErrorInfo) then
  begin
    Result := False;
    aErrorInfo := ERROR_USER_NOT_EXISTS;
  end
  else
    Result := True;
end;

function doStopUser(const aUserId: RInteger;
                    var aErrorInfo: string): Boolean;
begin
  if not _UserDataMgr.SetUserEnable(aUserId, False, aErrorInfo) then
  begin
    Result := False;
    aErrorInfo := ERROR_USER_NOT_EXISTS;
  end
  else
    Result := True;
end;




procedure TUserDataManager.InitDataSource;
var
  aSQLStr: string;
begin
  FSQLite := TSQLite3Database.Create;
  FSQLite.Open(FUserDataFileName);
  FSQLite.SetJournalMode_WAL;

  // �����ڱ�ʹ���
  aSQLStr := ' CREATE TABLE IF NOT EXISTS tb_User '
           + ' ('
           + '   UserId       INTEGER  PRIMARY KEY,'     // ID
           + '   UserCode     TEXT     COLLATE NOCASE,'  // �û����
           + '   UserName     TEXT,'                     // �û�����
           + '   IsAdmin      INTEGER,'                  // �Ƿ��ǹ���Ա�˻�
           + '   Password     TEXT,'                     // ����
           + '   IsEnable     INTEGER,'                  // ����״̬
           + '   Tel          TEXT,'                     // ��ϵ�绰
           + '   Email        TEXT,'                     // �����ַ
           + '   UserNote     TEXT'                      // �˻����
           + ' );';
  FSQLite.Execute(aSQLStr);

  // ����Ψһ����
  aSQLStr := ' CREATE UNIQUE INDEX IF NOT EXISTS ix_tb_User_UserCode '
           + ' ON tb_User (UserCode); ';
  FSQLite.Execute(aSQLStr);

  // ��ʼ������Ա�˻�
  aSQLStr := 'INSERT INTO tb_User '
         + ' (UserCode, UserName, IsAdmin, Password, IsEnable, '
         + '  Tel, Email, UserNote)'
         + ' SELECT ' + QuotedStr(USER_ADMIN)
         + '       ,' + QuotedStr('ϵͳ����Ա')
         + '       ,' + IntToStr(1)
         + '       ,' + QuotedStr(DEF_PWD_ADMIN)
         + '       ,' + IntToStr(1)
         + '       ,' + QuotedStr('')
         + '       ,' + QuotedStr('')
         + '       ,' + QuotedStr('')
         + ' WHERE NOT EXISTS (SELECT * FROM tb_User WHERE UserCode = '+QuotedStr(USER_ADMIN)+');';
  FSQLite.Execute(aSQLStr);

  // ��ʼ���ο��˻�
  aSQLStr := 'INSERT INTO tb_User '
         + ' (UserCode, UserName, IsAdmin, Password, IsEnable, '
         + '  Tel, Email, UserNote)'
         + ' SELECT ' + QuotedStr(USER_GUEST)
         + '       ,' + QuotedStr('�ο�')
         + '       ,' + IntToStr(0)
         + '       ,' + QuotedStr(DEF_PWD_GUEST)
         + '       ,' + IntToStr(1)
         + '       ,' + QuotedStr('')
         + '       ,' + QuotedStr('')
         + '       ,' + QuotedStr('')
         + ' WHERE NOT EXISTS (SELECT * FROM tb_User WHERE UserCode = '+QuotedStr(USER_GUEST)+');';
  FSQLite.Execute(aSQLStr);
end;

function TUserDataManager.GetUserInfoById(const aUserId: RInteger;
                                          const aUser: TUserData;
                                          var aErrorInfo: string): Boolean;
var
  aStmt: TSQLite3Statement;
  aSQLStr: string;
begin
  Result := False;

  if aUserId.IsNull then
  begin
    aErrorInfo := ERROR_USER_NOT_EXISTS;
    Exit;
  end;

  try
    // ��ѯ����
    aSQLStr := 'SELECT UserId, UserCode, UserName, IsAdmin, '
             + '       IsEnable, Tel, Email, UserNote, Password '
             + '  FROM tb_User '
             + ' WHERE UserId = ' + aUserId.AsString;

    aStmt := FSQLite.Prepare(aSQLStr);
    try
      if aStmt.Step = SQLITE_ROW then
      begin
        aUser.UserId.Value := aStmt.ColumnInt(0);
        aUser.UserCode.Value := aStmt.ColumnText(1);
        aUser.UserName.Value := aStmt.ColumnText(2);
        aUser.IsAdmin.Value := aStmt.ColumnInt(3) = 1;
        aUser.IsEnable.Value := aStmt.ColumnInt(4) = 1;
        aUser.Tel.Value := aStmt.ColumnText(5);
        aUser.Email.Value := aStmt.ColumnText(6);
        aUser.UserNote.Value := aStmt.ColumnText(7);
        aUser.Password.Value := aStmt.ColumnText(8);
      end
      else
      begin
        aErrorInfo := ERROR_USER_NOT_EXISTS;
        Exit;
      end;

      Result := True;
    finally
      aStmt.Free;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := Format(ERROR_QUERY_USER_INFO, [E.Message]);
    end;
  end;
end;

function TUserDataManager.GetUserInfoByCode(const aUserCode: RString;
                                            const aIsAdmin: RBoolean;
                                            const aUser: TUserData;
                                            var aErrorInfo: string): Boolean;
var
  aStmt: TSQLite3Statement;
  aSQLStr: string;
begin
  Result := False;

  if (aUserCode.IsNull) or (aUserCode.AsString = '') then
  begin
    aErrorInfo := ERROR_USER_NOT_EXISTS;
    Exit;
  end;

  try
    // ��ѯ����
    aSQLStr := 'SELECT UserId, UserCode, UserName, IsAdmin, '
             + '       IsEnable, Tel, Email, UserNote, Password '
             + '  FROM tb_User '
             + ' WHERE UserCode = ' + QuotedStr(aUserCode.AsString);
    if not aIsAdmin.IsNull then
    begin
      if aIsAdmin.Value then
        aSQLStr := aSQLStr + ' and IsAdmin = 1'
      else
        aSQLStr := aSQLStr + ' and IsAdmin = 0';
    end;

    aStmt := FSQLite.Prepare(aSQLStr);
    try
      if aStmt.Step = SQLITE_ROW then
      begin
        aUser.UserId.Value := aStmt.ColumnInt(0);
        aUser.UserCode.Value := aStmt.ColumnText(1);
        aUser.UserName.Value := aStmt.ColumnText(2);
        aUser.IsAdmin.Value := aStmt.ColumnInt(3) = 1;
        aUser.IsEnable.Value := aStmt.ColumnInt(4) = 1;
        aUser.Tel.Value := aStmt.ColumnText(5);
        aUser.Email.Value := aStmt.ColumnText(6);
        aUser.UserNote.Value := aStmt.ColumnText(7);
        aUser.Password.Value := aStmt.ColumnText(8);
      end
      else
      begin
        aErrorInfo := ERROR_USER_NOT_EXISTS;
        Exit;
      end;

      Result := True;
    finally
      aStmt.Free;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := Format(ERROR_QUERY_USER_INFO, [E.Message]);
    end;
  end;
end;

function TUserDataManager.UpdatePwd(const aUserId: RInteger;
                                    const aNewPwd: RString;
                                    var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
begin
  Result := False;

  if aUserId.IsNull then
    Exit;

  FWriteLock.BeginWrite;
  try
    aSQLStr := 'UPDATE tb_User '
             + '   SET Password = ' + QuotedStr(aNewPwd.AsString)
             + ' WHERE UserId = ' + aUserId.AsString;
    FSQLite.Execute(aSQLStr);
    Result := True;
  finally
    FWriteLock.EndWrite;
  end;
end;

function TUserDataManager.SetUserContact(const aUserId: RInteger;
                                         const aTel: RString;
                                         const aEmail: RString;
                                         var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
begin
  Result := False;

  if aUserId.IsNull then
    Exit;

  FWriteLock.BeginWrite;
  try
    aSQLStr := 'UPDATE tb_User '
             + '   SET Tel = ' + QuotedStr(aTel.AsString)
             + '     , Email = ' + QuotedStr(aEmail.AsString)
             + ' WHERE UserId = ' + aUserId.AsString;
    FSQLite.Execute(aSQLStr);
    Result := True;
  finally
    FWriteLock.EndWrite;
  end;
end;

function TUserDataManager.SetUserEnable(const aUserId: RInteger;
                                        const aEnable: Boolean;
                                        var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aEnableVal: string;
begin
  Result := False;

  if aUserId.IsNull then
    Exit;

  FWriteLock.BeginWrite;
  try
    if aEnable then
      aEnableVal := '1'
    else
      aEnableVal := '0';

    aSQLStr := ' UPDATE tb_User '
             + '    SET IsEnable = ' + aEnableVal
             + '  WHERE UserId = ' + aUserId.AsString
             + '    AND IsAdmin = 0';
    FSQLite.Execute(aSQLStr);
    Result := True;
  finally
    FWriteLock.EndWrite;
  end;
end;

function TUserDataManager.DeleteUser(const aUserId: RInteger;
                                     var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
begin
  Result := False;

  if aUserId.IsNull then
    Exit;

  FWriteLock.BeginWrite;
  try
    aSQLStr := ' DELETE FROM tb_User '
             + '  WHERE UserId = ' + aUserId.AsString
             + '    AND IsAdmin = 0';
    FSQLite.Execute(aSQLStr);
    Result := True;
  finally
    FWriteLock.EndWrite;
  end;
end;

function TUserDataManager.GetUserList(const aIsEnable: RBoolean;
                                      const aFilter: RString;
                                      var aPageInfo: RPageInfo;
                                      const aUserList: TUserDataList;
                                      var aErrorInfo: string): Boolean;
var
  aStmt: TSQLite3Statement;
  aSQLStr, aWhereSQL: string;
  aLikeStr: string;
begin
  Result := False;

  try
    // ���� Where ���� SQL
    aWhereSQL := ' WHERE IsAdmin = 0 ';
    if not aIsEnable.IsNull then
    begin
      if aIsEnable.Value then
        aWhereSQL := aWhereSQL + ' and IsEnable = 1'
      else
        aWhereSQL := aWhereSQL + ' and IsEnable = 0';
    end;
    if not aFilter.IsNull then
    begin
      aLikeStr := '%' + aFilter.AsString + '%';
      aWhereSQL := aWhereSQL + ' and ((UserCode like ' + QuotedStr(aLikeStr) + ') '
                             + '   or (UserName like ' + QuotedStr(aLikeStr) + ') '
                             + '   or (Tel      like ' + QuotedStr(aLikeStr) + ') '
                             + '   or (Email    like ' + QuotedStr(aLikeStr) + ') '
                             + '   or (UserNote like ' + QuotedStr(aLikeStr) + ')) ';
    end;

    // ��ѯ�ܼ�¼��
    aSQLStr := ' SELECT Count(*) as RecordCount FROM tb_User ' + aWhereSQL + ';';
    aStmt := FSQLite.Prepare(aSQLStr);
    try
      if aStmt.Step = SQLITE_ROW then
        aPageInfo.RecordCount.Value := aStmt.ColumnInt(0)
      else
        aPageInfo.RecordCount.Value := 0;
      aPageInfo.CalcPageInfo(10);
    finally
      aStmt.Free;
    end;

    // ��ѯ����
    aSQLStr := 'SELECT UserId, UserCode, UserName, IsAdmin, '
             + '       IsEnable, Tel, Email, UserNote '
             + ' FROM tb_User '
             + aWhereSQL
             + ' ORDER BY UserCode'
             + ' LIMIT ' + aPageInfo.PageSize.AsString
             + ' OFFSET ' + IntToStr((aPageInfo.PageIndex.Value - 1)*aPageInfo.PageSize.Value)
             + ';';
    aStmt := FSQLite.Prepare(aSQLStr);
    try
      while aStmt.Step = SQLITE_ROW do
      begin
        with aUserList.Add do
        begin
          UserId.Value := aStmt.ColumnInt(0);
          UserCode.Value := aStmt.ColumnText(1);
          UserName.Value := aStmt.ColumnText(2);
          IsAdmin.Value := aStmt.ColumnInt(3) = 1;
          IsEnable.Value := aStmt.ColumnInt(4) = 1;
          Tel.Value := aStmt.ColumnText(5);
          Email.Value := aStmt.ColumnText(6);
          UserNote.Value := aStmt.ColumnText(7);
        end;
      end;
    finally
      aStmt.Free;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      aErrorInfo := Format(ERROR_QUERY_USER_LIST, [E.Message]);
    end;
  end;
end;

function TUserDataManager.CheckUserCodeExists(const aUserId: RInteger;
                                              const aUserCode: RString): Boolean;
var
  aStmt: TSQLite3Statement;
  aSQLStr: string;
begin
  Result := False;

  aSQLStr := ' SELECT UserId FROM tb_User '
           + ' WHERE UserCode = ' + QuotedStr(aUserCode.AsString);
  if not aUserId.IsNull then
    aSQLStr := aSQLStr + ' AND UserId <> ' + aUserId.AsString;

  aStmt := FSQLite.Prepare(aSQLStr);
  try
    Result := aStmt.Step = SQLITE_ROW;
  finally
    aStmt.Free;
  end;
end;

function TUserDataManager.CheckUserNameExists(const aUserId: RInteger;
                                              const aUserName: RString): Boolean;
var
  aStmt: TSQLite3Statement;
  aSQLStr: string;
begin
  Result := False;

  aSQLStr := ' SELECT UserId FROM tb_User '
             + ' WHERE UserName = ' + QuotedStr(aUserName.AsString);
  if not aUserId.IsNull then
    aSQLStr := aSQLStr + ' AND UserId <> ' + aUserId.AsString;

  aStmt := FSQLite.Prepare(aSQLStr);
  try
    Result := aStmt.Step = SQLITE_ROW;
  finally
    aStmt.Free;
  end;
end;

function TUserDataManager.AddUser(const aUser: TUserData;
                                  var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aEnableVal: string;
begin
  Result := False;

  if aUser.UserCode.IsNull then
  begin
    aErrorInfo := ERROR_USER_CODE_NULL;
    Exit;
  end;

  if aUser.UserName.IsNull then
  begin
    aErrorInfo := ERROR_USER_CODE_NULL;
    Exit;
  end;

  if CheckUserCodeExists(RInteger.Null, aUser.UserCode) then
  begin
    aErrorInfo := ERROR_USER_CODE_EXISTS;
    Exit;
  end;

  if CheckUserNameExists(RInteger.Null, aUser.UserName) then
  begin
    aErrorInfo := ERROR_USER_NAME_EXISTS;
    Exit;
  end;

  try
    FWriteLock.BeginWrite;
    try
      if aUser.IsEnable.IsNull or aUser.IsEnable.Value then
        aEnableVal := '1'
      else
        aEnableVal := '0';

      aSQLStr := 'INSERT INTO tb_User '
               + ' (UserCode, UserName, IsAdmin, Password, IsEnable, '
               + '  Tel, Email, UserNote)'
               + ' values (' + QuotedStr(aUser.UserCode.AsString)
               + '        ,' + QuotedStr(aUser.UserName.AsString)
               + '        ,' + IntToStr(0)
               + '        ,' + QuotedStr(DEF_PWD_GENERAL)
               + '        ,' + aEnableVal
               + '        ,' + QuotedStr(aUser.Tel.AsString)
               + '        ,' + QuotedStr(aUser.Email.AsString)
               + '        ,' + QuotedStr(aUser.UserNote.AsString)
               + '        );';
      FSQLite.Execute(aSQLStr);
      Result := True;
      aUser.UserId.Value := FSQLite.LastInsertRowID;
    finally
      FWriteLock.EndWrite;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := Format(ERROR_ADD_USER, [E.Message]);
    end;
  end;
end;

function TUserDataManager.UpdateUser(const aUser: TUserData;
                                     var aErrorInfo: string): Boolean;
var
  aSQLStr: string;
  aEnableVal: string;
begin
  Result := False;

  if aUser.UserId.IsNull then
  begin
    aErrorInfo := ERROR_USER_NOT_EXISTS;
    Exit;
  end;

  if aUser.UserCode.IsNull then
  begin
    aErrorInfo := ERROR_USER_CODE_NULL;
    Exit;
  end;

  if aUser.UserName.IsNull then
  begin
    aErrorInfo := ERROR_USER_CODE_NULL;
    Exit;
  end;

  if CheckUserCodeExists(aUser.UserId, aUser.UserCode) then
  begin
    aErrorInfo := ERROR_USER_CODE_EXISTS;
    Exit;
  end;

  if CheckUserNameExists(aUser.UserId, aUser.UserName) then
  begin
    aErrorInfo := ERROR_USER_NAME_EXISTS;
    Exit;
  end;

  try
    FWriteLock.BeginWrite;
    try
      if aUser.IsEnable.IsNull or aUser.IsEnable.Value then
        aEnableVal := '1'
      else
        aEnableVal := '0';

      aSQLStr := 'UPDATE tb_User '
               + '   SET UserName = ' + QuotedStr(aUser.UserName.AsString)
               + '     , IsEnable = ' + aEnableVal
               + '     , Tel = ' + QuotedStr(aUser.Tel.AsString)
               + '     , Email = ' + QuotedStr(aUser.Email.AsString)
               + '     , UserNote = ' + QuotedStr(aUser.UserNote.AsString)
               + ' WHERE UserId = ' + aUser.UserId.AsString
               + '   AND IsAdmin = 0';
      FSQLite.Execute(aSQLStr);
      Result := True;
    finally
      FWriteLock.EndWrite;
    end;
  except
    on E: Exception do
    begin
      aErrorInfo := Format(ERROR_UPDATE_USER, [E.Message]);
    end;
  end;
end;

{ TUserDataCtrl }
class procedure TUserDataCtrl.Open(const aDataPath: string);
begin
  _UserDataMgr := TUserDataManager.Create(aDataPath);
end;

class procedure TUserDataCtrl.Close;
begin
  _UserDataMgr.Free;
end;

end.
