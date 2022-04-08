unit UDDValueListData;

interface

uses
  Classes, SysUtils, Generics.Collections;

type
  // ֵ ����
  TValueType = (
    vtString,     // �ַ���
    vtInt,        // ����
    vtDouble,     // ������
    vtBool,       // ����
    vtDate,       // ����ʱ��(Unixʱ���)
    vtPassword,   // ����(��ʾ���� *)
    vtStringList  // ѡ���б�
  );

  // ֵ ��дģʽ
  TReadWriteMode = (
    rwmRead,      // ֻ��
    rwmReadWrite, // ��д
    rwmWrite      // ֻд
  );

  // ֵ
  TValueData = class(TObject)
  private
    Fname: string;                  // ����
    Fvalue: string;                 // ֵ
    FvalueType: TValueType;         // ����ʱ��
    FreadWriteMode: TReadWriteMode; // ��дģʽ
    Fnote: string;                  // ��ע
    FpickList: TStringList;         // vtStringList ��Ӧ�������б�
  public
    property name: string read Fname write Fname;
    property value: string read Fvalue write Fvalue;
    property valueType: TValueType read FvalueType write FvalueType;
    property readWriteMode: TReadWriteMode read FreadWriteMode write FreadWriteMode;
    property note: string read Fnote write Fnote;
    property pickList: TStringList read FpickList write FpickList;

    procedure Assign(const aValueData: TValueData);
  end;

  // ֵ �б�
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
