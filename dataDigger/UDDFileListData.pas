unit UDDFileListData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // 文件数据
  TFileData = class
  private
    FFileName: RString;           // 文件名称
    FCreationTime: RDateTime;     // 创建时间
    FLastWriteTime: RDateTime;    // 最后编辑时间
    FFileSize: RInteger;          // 文件大小 字节
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
