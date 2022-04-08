unit UDDBrokerModelData;

interface

uses
  Classes, Generics.Collections;

type
  // ���ݲɼ��� �ͺ���Ϣ
  TBrokerModelData = class
  private
    FFileName: string;            // �����ļ�
    FModel: string;               // �ͺ�
    FModelName: string;           // �ͺ�����
    FModelNote: string;           // �ͺ�˵��
    FBindGatewayModel: string;    // �󶨵������ͺ� (�ձ�ʾ����)
  public
    property FileName: string read FFileName write FFileName;
    property Model: string read FModel write FModel;
    property ModelName: string read FModelName write FModelName;
    property ModelNote: string read FModelNote write FModelNote;
    property BindGatewayModel: string read FBindGatewayModel write FBindGatewayModel;
    procedure Assign(const aBrokerModel: TBrokerModelData);
  end;

  TBrokerModelDataList = class(TObjectList<TBrokerModelData>)
  public
    function Add: TBrokerModelData; overload;
    procedure Assign(const aBrokerModelList: TBrokerModelDataList);
  end;

implementation

{ TBrokerModelData }
procedure TBrokerModelData.Assign(const aBrokerModel: TBrokerModelData);
begin
  FFileName := aBrokerModel.FileName;
  FModel := aBrokerModel.Model;
  FModelName := aBrokerModel.ModelName;
  FModelNote := aBrokerModel.ModelNote;
  FBindGatewayModel := aBrokerModel.BindGatewayModel;
end;

{ TBrokerModelDataList }
function TBrokerModelDataList.Add: TBrokerModelData;
begin
  Result := TBrokerModelData.Create;
  Self.Add(Result);
end;

procedure TBrokerModelDataList.Assign( const aBrokerModelList: TBrokerModelDataList);
var
  aBrokerModel: TBrokerModelData;
begin
  Self.Clear;

  for aBrokerModel in aBrokerModelList do
    Self.Add.Assign(aBrokerModel);
end;

end.
