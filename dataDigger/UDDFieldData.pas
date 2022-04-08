unit UDDFieldData;

interface

uses
  Generics.Collections;

type
  // ��������
  TFieldType = (ftInteger,    // ����
                ftReal,       // ������
                ftString);    // �ַ���

  // �ֶ�
  TFieldData = class
  private
    FFieldName: string;        // �ֶ�����
    FFieldType: TFieldType;    // �ֶ�����
    FFieldTitle: string;       // �ֶα���
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
