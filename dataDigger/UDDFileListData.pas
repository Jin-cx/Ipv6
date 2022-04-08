unit UDDFileListData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // �ļ�����
  TFileData = class
  private
    FFileName: RString;           // �ļ�����
    FCreationTime: RDateTime;     // ����ʱ��
    FLastWriteTime: RDateTime;    // ���༭ʱ��
    FFileSize: RInteger;          // �ļ���С �ֽ�
  public
    constructor Create;

    property FileName: RString read FFileName write FFileName;
    property CreationTime: RDateTime read FCreationTime write FCreationTime;
    property LastWriteTime: RDateTime read FLastWriteTime write FLastWriteTime;
    property FileSize: RInteger read FFileSize write FFileSize;

    procedure Assign(const aFileData: TFileData);
  end;

  TFileDataList = class(TObjectList<TFileData>)
  public
    function Add(): TFileData; overload;
  end;

implementation

{ TFileData }
constructor TFileData.Create;
begin
  FFileName.Clear;
  FCreationTime.Clear;
  FLastWriteTime.Clear;
  FFileSize.Clear;
end;

procedure TFileData.Assign(const aFileData: TFileData);
begin
  if aFileData = nil then
    Exit;
  FFileName := aFileData.FileName;
  FCreationTime := aFileData.CreationTime;
  FLastWriteTime := aFileData.LastWriteTime;
  FFileSize := aFileData.FileSize;
end;

{ TFileDataList }
function TFileDataList.Add(): TFileData;
begin
  Result := TFileData.Create;
  Self.Add(Result);
end;

end.
