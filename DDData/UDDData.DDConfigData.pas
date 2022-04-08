{
  单元: 采集平台配置管理单元
  作者: lynch
  日期: 2016-11-01
}

unit UDDData.DDConfigData;

interface

uses
  Classes, SysUtils, Generics.Collections,
  puer.System, puer.SyncObjs, puer.Json.JsonDataObjects, puer.FileUtils;

type
  TDDConfigCtrl = class
  public
    class procedure Open(const aConfigPath: string);
    class procedure Close;
    class function Active: Boolean;
  end;

// 校验管理员密码
function doCheckUserPwd(const aUserName: string;
                        const aPassword: string;
                        var aErrorInfo: string): Boolean; stdcall;

// 修改密码
function doUpdateUserPwd(const aPassword: string;
                         const aNewPwd: string;
                         var aErrorInfo: string): Boolean; stdcall;

// 获取管理员联系方式
function doGetAdminContact(var aTel: string;
                           var aEmail: string;
                           var aErrorInfo: string): Boolean; stdcall;

// 获取管理员联系方式
function doSetAdminContact(const aTel: string;
                           const aEmail: string;
                           var aErrorInfo: string): Boolean; stdcall;

exports
  doCheckUserPwd,
  doUpdateUserPwd,
  doGetAdminContact,
  doSetAdminContact;

implementation

const
  DD_CONFIG_FILE_NAME = 'DD.cfg';

type
  TDDConfig = class
  private
    FLock: TPrRWLock;
    FConfigPath: string;
    FFileName: string;
    FJson: TJsonObject;
    procedure SaveConfig;
    procedure LoadConfig;
    procedure doSaveToFile(const aFileName: string);
  public
    constructor Create(const aConfigPath: string); overload;
    destructor Destroy; override;

    function CheckUserPwd(const aUserName: string;
                          const aPassword: string;
                          var aErrorInfo: string): Boolean;

    function UpdateUserPwd(const aPassword: string;
                           const aNewPwd: string;
                           var aErrorInfo: string): Boolean;

    function GetAdminContact(var aTel: string;
                             var aEmail: string;
                             var aErrorInfo: string): Boolean;

    function SetAdminContact(const aTel: string;
                             const aEmail: string;
                             var aErrorInfo: string): Boolean;
  end;

var
  _DDConfig: TDDConfig;
  _HasOpen: Boolean;

function doCheckUserPwd(const aUserName: string;
                        const aPassword: string;
                        var aErrorInfo: string): Boolean;
begin
  Result := _DDConfig.CheckUserPwd(aUserName, aPassword, aErrorInfo);
end;

function doUpdateUserPwd(const aPassword: string;
                         const aNewPwd: string;
                         var aErrorInfo: string): Boolean;
begin
  Result := _DDConfig.UpdateUserPwd(aPassword, aNewPwd, aErrorInfo);
end;

function doGetAdminContact(var aTel: string;
                           var aEmail: string;
                           var aErrorInfo: string): Boolean;
begin
  Result := _DDConfig.GetAdminContact(aTel, aEmail, aErrorInfo);
end;

function doSetAdminContact(const aTel: string;
                           const aEmail: string;
                           var aErrorInfo: string): Boolean;
begin
  Result := _DDConfig.SetAdminContact(aTel, aEmail, aErrorInfo);
end;

{ TDDConfigCtrl }
class procedure TDDConfigCtrl.Open(const aConfigPath: string);
begin
  _HasOpen := False;
  _DDConfig := TDDConfig.Create(aConfigPath);
  _HasOpen := True;
end;

class procedure TDDConfigCtrl.Close;
begin
  _HasOpen := False;
  _DDConfig.Free;
end;

class function TDDConfigCtrl.Active: Boolean;
begin
  Result := _HasOpen;
end;

{ TDDConfig }
constructor TDDConfig.Create(const aConfigPath: string);
begin
  inherited Create;
  FConfigPath := aConfigPath;
  FFileName := aConfigPath + DD_CONFIG_FILE_NAME;
  FJson := TJsonObject.Create;
  LoadConfig;
  FLock := TPrRWLock.Create;
end;

destructor TDDConfig.Destroy;
begin
  FJson.Free;
  FLock.Free;
  inherited;
end;

procedure TDDConfig.LoadConfig;
begin
  if FileExists(FFileName) then
    FJson.LoadFromFile(FFileName);
end;

procedure TDDConfig.SaveConfig;
begin
  doSaveToFile(FFileName);
end;

procedure TDDConfig.doSaveToFile(const aFileName: string);
var
  aDir: string;
begin
  aDir := ExtractFileDir(aFileName);
  if not DirectoryExists(aDir) and not ForceDirectories(aDir) then
    Exit;

  FJson.SaveToFile(aFileName);
end;

function TDDConfig.CheckUserPwd(const aUserName, aPassword: string;
  var aErrorInfo: string): Boolean;
var
  aAdminData: TJsonObject;
begin
  Result := False;

  FLock.BeginRead;
  try
    aAdminData := FJson.O['admin'];

    if SameText(aUserName, aAdminData.S['username']) and
       (aPassword = aAdminData.S['password']) then
      Result := True
    else
      aErrorInfo := '用户名或密码不正确';
  finally
    FLock.EndRead;
  end;
end;

function TDDConfig.UpdateUserPwd(const aPassword, aNewPwd: string;
  var aErrorInfo: string): Boolean;
var
  aAdminData: TJsonObject;
begin
  Result := False;

  FLock.BeginWrite;
  try
    aAdminData := FJson.O['admin'];

    if aPassword = aAdminData.S['password'] then
    begin
      aAdminData.S['password'] := aNewPwd;

      SaveConfig;

      Result := True;
    end
    else
      aErrorInfo := '原密码不正确';
  finally
    FLock.EndWrite;
  end;
end;

function TDDConfig.GetAdminContact(var aTel, aEmail,
  aErrorInfo: string): Boolean;
var
  aAdminData: TJsonObject;
begin
  FLock.BeginRead;
  try
    aAdminData := FJson.O['admin'];

    aTel := aAdminData.S['tel'];
    aEmail := aAdminData.S['email'];

    Result := True;
  finally
    FLock.EndRead;
  end;
end;

function TDDConfig.SetAdminContact(const aTel, aEmail: string;
  var aErrorInfo: string): Boolean;
var
  aAdminData: TJsonObject;
begin
  FLock.BeginWrite;
  try
    aAdminData := FJson.O['admin'];

    aAdminData.S['tel'] := aTel;
    aAdminData.S['email'] := aEmail;

    SaveConfig;

    Result := True;
  finally
    FLock.EndWrite;
  end;
end;

end.
