(*
 * API�ӿڵ�Ԫ (�˻�����)
 * ����: lynch (153799053@qq.com)
 * ��վ: http://www.thingspower.com.cn
 *
 *
 * ˵��: �˻�����ɾ��, �޸�����, Ȩ���жϵ�
 *
 *
 * �޸�:
 * 2016-12-08 (v0.1)
 *   + ��һ�η���.
 *)

unit UdoDDAPI.User;

interface

uses
  puer.System,
  UDDDataInter,
  UDDUserData;

// У���û�����
function doLogin(const aUserCode: RString;
                 const aPassword: RString;
                 const aIsAdmin: RBoolean;
                 const aUser: TUserData;
                 var aErrorInfo: string): Boolean; stdcall;
// �޸�����
function doUpdatePwd(const aUserId: RInteger;
                     const aOldPwd: RString;
                     const aNewPwd: RString;
                     var aErrorInfo: string): Boolean; stdcall;
// ��ȡ�û���ϵ��ʽ
function doGetUserContact(const aUserId: RInteger;
                          var aTel: RString;
                          var aEmail: RString;
                          var aErrorInfo: string): Boolean; stdcall;
// ��ȡ�û���ϵ��ʽ
function doSetUserContact(const aUserId: RInteger;
                          const aTel: RString;
                          const aEmail: RString;
                          var aErrorInfo: string): Boolean; stdcall;
// ��������
function doResetPwd(const aUserId: RInteger;
                    var aErrorInfo: string): Boolean; stdcall;
// �����û�
function doAddUser(const aUser: TUserData;
                   var aErrorInfo: string): Boolean; stdcall;
// �༭�û�
function doUpdateUser(const aUser: TUserData;
                      var aErrorInfo: string): Boolean; stdcall;

// ɾ���û�
function doDeleteUser(const aUserId: RInteger;
                      var aErrorInfo: string): Boolean; stdcall;
// ��ȡ�û��б�
function doGetUserList(const aIsEnable: RBoolean;
                       const aFilter: RString;
                       var aPageInfo: RPageInfo;
                       const aUserList: TUserDataList;
                       var aErrorInfo: string): Boolean; stdcall;
// ��ȡ�û�����
function doGetUserInfo(const aUserId: RInteger;
                       const aUser: TUserData;
                       var aErrorInfo: string): Boolean; stdcall;
// �����û�
function doStartUser(const aUserId: RInteger;
                     var aErrorInfo: string): Boolean; stdcall;
// ͣ���û�
function doStopUser(const aUserId: RInteger;
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
  doGetUserList,
  doGetUserInfo,
  doStartUser,
  doStopUser;

implementation

function doLogin(const aUserCode: RString;
                 const aPassword: RString;
                 const aIsAdmin: RBoolean;
                 const aUser: TUserData;
                 var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doLogin(aUserCode, aPassword, aIsAdmin, aUser, aErrorInfo);
end;

function doUpdatePwd(const aUserId: RInteger;
                     const aOldPwd: RString;
                     const aNewPwd: RString;
                     var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doUpdatePwd(aUserId, aOldPwd, aNewPwd, aErrorInfo);
end;

function doGetUserContact(const aUserId: RInteger;
                          var aTel: RString;
                          var aEmail: RString;
                          var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetUserContact(aUserId, aTel, aEmail, aErrorInfo);
end;

function doSetUserContact(const aUserId: RInteger;
                          const aTel: RString;
                          const aEmail: RString;
                          var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doSetUserContact(aUserId, aTel, aEmail, aErrorInfo);
end;

function doResetPwd(const aUserId: RInteger;
                    var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doResetPwd(aUserId, aErrorInfo);
end;

function doAddUser(const aUser: TUserData;
                   var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doAddUser(aUser, aErrorInfo);
end;

function doUpdateUser(const aUser: TUserData;
                      var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doUpdateUser(aUser, aErrorInfo);
end;

function doDeleteUser(const aUserId: RInteger;
                      var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doDeleteUser(aUserId, aErrorInfo);
end;

function doGetUserList(const aIsEnable: RBoolean;
                       const aFilter: RString;
                       var aPageInfo: RPageInfo;
                       const aUserList: TUserDataList;
                       var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetUserList(aIsEnable, aFilter, aPageInfo, aUserList, aErrorInfo);
end;

function doGetUserInfo(const aUserId: RInteger;
                       const aUser: TUserData;
                       var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doGetUserInfo(aUserId, aUser, aErrorInfo);
end;

function doStartUser(const aUserId: RInteger;
                     var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doStartUser(aUserId, aErrorInfo);
end;

function doStopUser(const aUserId: RInteger;
                    var aErrorInfo: string): Boolean;
begin
  Result := _DDDataInter._doStopUser(aUserId, aErrorInfo);
end;

end.
