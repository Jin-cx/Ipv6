unit UDDValueListData;

interface

uses
  Classes, SysUtils, Generics.Collections;

type
  // 值 类型
  TValueType = (
    vtString,     // 字符串
    vtInt,        // 整数
    vtDouble,     // 浮点数
    vtBool,       // 布尔
    vtDate,       // 日期时间(Unix时间戳)
    vtPassword,   // 密码(显示密码 *)
    vtStringList  // 选择列表
  );

  // 值 读写模式
  TReadWriteMode = (
    rwmRead,      // 只读
    rwmReadWrite, // 读写
    rwmWrite      // 只写
  );

  // 值
  TValueData = class(TObject)
  private
    Fname: string;                  // 名称
    Fvalue: string;                 // 值
    FvalueType: TValueType;         // 创建时间
    FreadWriteMode: TReadWriteMode; // 读写模式
    Fnote: string;                  // 备注
    FpickList: TStringList;         // vtStringList 对应的下拉列表
  public
    property name: string read Fname write Fname;
    property value: string read Fvalue write Fvalue;
    property valueType: TValueType read FvalueType write FvalueType;
    property readWriteMode: TReadWriteMode read FreadWriteMode write FreadWriteMode;
    property note: string read Fnote write Fnote;
    property pickList: TStringList read FpickList write FpickList;

    procedure Assign(const aValueData: TValueData);
  end;

  // 值 列表
  TValueDataList = class(TObjectList<TValueData>)
  public
    function Add(): TValueData; overload;
    procedure Assign(const aValueDataList: TValueDataList);
  end;

implementation

{ TValueData }
procedure TValueData.Assign(const aValueData: TValueData);
begin
  if aValueData = nil then
    Exit;

  Self.name := aValueData.name;
  Self.value := aValueData.value;
  Self.valueType := aValueData.valueType;
  Self.readWriteMode := aValueData.readWriteMode;
  Self.note := aValueData.note;
  Self.pickList.Assign(aValueData.pickList);
end;

{ TValueDataList }
function TValueDataList.Add(): TValueData;
begin
  Result := TValueData.Create;
  Self.Add(Result);
end;

procedure TValueDataList.Assign(const aValueDataList: TValueDataList);
var
  aValueData: TValueData;
begin
  if aValueDataList = nil then
    Exit;

  Self.Clear;

  for aValueData in aValueDataList do
    Self.Add.Assign(aValueData);
end;

end.
