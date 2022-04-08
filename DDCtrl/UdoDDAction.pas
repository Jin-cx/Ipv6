unit UdoDDAction;

interface

uses
  Classes, Windows, SysUtils, Generics.Collections, Generics.Defaults,
  puer.System, puer.SyncObjs, puer.FileUtils;

type
  // �ɼ�ƽ̨����ģ�����
  TDDAction = class
  public
    class procedure Open(const aRootPath: string;    // �ɼ�ƽ̨��Ŀ¼
                         const aTmpPath: string);    // ��ʱ�ļ�Ŀ¼
    class procedure Close;
    class function Active: Boolean;

    class function GetDllProcAddress(const aFileName: string;              // Dll���� ��Ŀ¼�����Ŀ¼
                                     const aProcName: string): FARPROC;    // ��������
  end;

function _GetProcAddr(const aFileName: string; const aProcName: string): FARPROC; stdcall;

implementation

function _GetProcAddr(const aFileName: string; const aProcName: string): FARPROC;
begin
  Result := TDDAction.GetDllProcAddress(aFileName, aProcName);
end;

type
  TActionCtrl = class
  private
    FLock: TPrRWLock;
    FRootPath: string;
    FTmpPath: string;
    FDllList: TDictionary<string, THandle>;
    //procedure ClearDllList;
    function CopyFileToTempPath(const aFileName: string): string;
  public
    constructor Create(const aRootPath: string;
                       const aTmpPath: string);
    destructor Destroy; override;

    function GetDllProcAddress(const aFileName: string;
                               const aProcName: string): FARPROC;
  end;

var
  _ActionCtrl: TActionCtrl;

const
  ERROR_GET_DLL_PROC = '�޷����ļ� "%s" ���ҵ����� "%s"��������Ϣ: %s';

{ TDDAction }
class procedure TDDAction.Open(const aRootPath: string; const aTmpPath: string);
begin
  _ActionCtrl := TActionCtrl.Create(aRootPath, aTmpPath);
end;

class procedure TDDAction.Close;
begin
  _ActionCtrl.Free;
end;

class function TDDAction.Active: Boolean;
begin
  Result := _ActionCtrl <> nil;
end;

class function TDDAction.GetDllProcAddress(const aFileName: string;
                                           const aProcName: string): FARPROC;
begin
  try
    Result := _ActionCtrl.GetDllProcAddress(aFileName, aProcName);
  except
    raise Exception.Create(Format('find %s in %s error', [aProcName, aFileName]));
  end;
end;

{ TActionCtrl }
constructor TActionCtrl.Create(const aRootPath: string; const aTmpPath: string);
begin
  inherited Create;
  FRootPath := aRootPath;
  FTmpPath := aTmpPath;

  FDllList := TDictionary<string, THandle>.Create;
  FLock := TPrRWLock.Create;

  // �����ʱ�ļ�
  ClearDirectory(FTmpPath);
end;

destructor TActionCtrl.Destroy;
begin
  FLock.BeginWrite;
  try
    //ClearDllList; Free ���ܻ������⣬��ʱ�� Free
    FDllList.Free;
  finally
    FLock.EndWrite;
    FLock.Free;
  end;
  inherited;
end;

{procedure TActionCtrl.ClearDllList;
var
  aHandle: THandle;
begin
  for aHandle in FDllList.Values do
    FreeLibrary(aHandle);
end; }

function TActionCtrl.CopyFileToTempPath(const aFileName: string): string;
var
  aSourceFileName, aNewFileName: string;
begin
  aSourceFileName := FRootPath + aFileName;
  aNewFileName := FTmpPath + ChangeFileExt(aFileName, Format('_%s.dll', [GetGUID32]));
  CopyFile(aSourceFileName, aNewFileName);
  Result := aNewFileName;
end;

function TActionCtrl.GetDllProcAddress(const aFileName: string;
                                       const aProcName: string): FARPROC;

  function GetDllHandle(const aFileName: string): THandle;
  var
    aKeyName: string;
    aTempFileName: string;
  begin
    aKeyName := LowerCase(aFileName);

    FLock.BeginRead;
    try
      if FDllList.TryGetValue(aKeyName, Result) then
        Exit;
    finally
      FLock.EndRead;
    end;

    FLock.BeginWrite;
    try
      if not FDllList.TryGetValue(aKeyName, Result) then
      begin
        aTempFileName := CopyFileToTempPath(aFileName);

        Result := Windows.LoadLibrary(PChar(aTempFileName));
        if Result = 0 then
          raise Exception.Create(Format('���� DLL "%s" ʧ�ܣ�������Ϣ: %s',
                                        [aTempFileName, SysErrorMessage(GetLastError)]));

        FDllList.AddOrSetValue(aKeyName, Result);
      end;
    finally
      FLock.EndWrite;
    end;
  end;

var
  aHandle: THandle;
begin
  aHandle := GetDllHandle(aFileName);
  Result := GetProcAddress(aHandle, PChar(aProcName));
  if Result = nil then
    raise Exception.Create(Format(ERROR_GET_DLL_PROC, [aFileName, aProcName, SysErrorMessage(GetLastError)]));
end;

end.
