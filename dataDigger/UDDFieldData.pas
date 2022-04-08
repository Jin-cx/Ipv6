unit UDDFieldData;

interface

uses
  Generics.Collections;

type
  // 数据类型
  TFieldType = (ftInteger,    // 整型
                ftReal,       // 浮点型
                ftString);    // 字符串

  // 字段
  TFieldData = class
  private
    FFieldName: string;        // 字段名称
    FFieldType: TFieldType;    // 字段类型
    FFieldTitle: string;       // 字段标题
  public
    property FieldName: string read FFieldName write FFieldName;
    property FieldType: TFieldType read FFieldType write FFieldType;
    property FieldTitle: string read FFieldTitle write FFieldTitle;
  end;

  TFieldDataList = class(TObjectList<TFieldData>)
  public
    function Add(): TFieldData; overload;
    procedure Add(const aFieldName: string;
                  const aFieldType: TFieldType;
                  const aFieldTitle: string); overload;
  end;

implementation

{ TFieldDataList }
function TFieldDataList.Add(): TFieldData;
begin
  Result := TFieldData.Create;
  Self.Add(Result);
end;

procedure TFieldDataList.Add(const aFieldName: string;
                             const aFieldType: TFieldType;
                             const aFieldTitle: string);
begin
  with Self.Add do
  begin
    FieldName := aFieldName;
    FieldType := aFieldType;
    FieldTitle := aFieldTitle;
  end;
end;

end.
