(*
 * API接口单元 (账户管理)
 * 开发: lynch (153799053@qq.com)
 * 网站: http://www.thingspower.com.cn
 *
 *
 * 说明: 账户的增删改, 修改密码, 权限判断等
 *
 *
 * 修改:
 * 2016-12-08 (v0.1)
 *   + 第一次发布.
 *)

unit UdoDDAPI.User;

interface

uses
  puer.System,
  UDDDataInter,
  UDDUserData;

// 校验用户密码
function doLogin(const aUserCode: RString;
                 const aPassword: RString;
                 const aIsAdmin: RBoolean;
                 const aUser: TUserData;
                 var aErrorInfo: string): Boolean; stdcall;
// 修改密码
function doUpdatePwd(const aUserId: RInteger;
                     const aOldPwd: RString;
                     const aNewPwd: RString;
                     var aErrorInfo: string): Boolean; stdcall;
// 获取用户联系方式
function doGetUserContact(const aUserId: RInteger;
                          var aTel: RString;
                          var aEmail: RString;
                          var aErrorInfo: string): Boolean; stdcall;
// 获取用户联系方式
function doSetUserContact(const aUserId: RInteger;
                          const aTel: RString;
                          const aEmail: RString;
                          var aErrorInfo: string): Boolean; stdcall;
// 重置密码
function doResetPwd(const aUserId: RInteger;
                    var aErrorInfo: string): Boolean; stdcall;
// 新增用户
function doAddUser(const aUser: TUserData;
                   var aErrorInfo: string): Boolean; stdcall;
// 编辑用户
function doUpdateUser(const aUser: TUserData;
                      var aErrorInfo: string): Boolean; stdcall;

// 删除用户
function doDeleteUser(const aUserId: RInteger;
                      var aErrorInfo: string): Boolean; stdcall;
// 获取用户列表
function doGetUserList(const aIsEnable: RBoolean;
                       const aFilter: RString;
                       var aPageInfo: RPageInfo;
                       const aUserList: TUserDataList;
                       var aErrorInfo: string): Boolean; stdcall;
// 获取用户详情
function doGetUserInfo(const aUserId: RInteger;
                       const aUser: TUserData;
                       var aErrorInfo: string): Boolean; stdcall;
// 启用用户
function doStartUser(const aUserId: RInteger;
                     var aErrorInfo: string): Boolean; stdcall;
// 停用用户
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
