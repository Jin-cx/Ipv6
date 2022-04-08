unit UDDBrokerModelData;

interface

uses
  Classes, Generics.Collections;

type
  // 数据采集器 型号信息
  TBrokerModelData = class
  private
    FFileName: string;            // 驱动文件
    FModel: string;               // 型号
    FModelName: string;           // 型号名称
    FModelNote: string;           // 型号说明
    FBindGatewayModel: string;    // 绑定的网关型号 (空表示不绑定)
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
