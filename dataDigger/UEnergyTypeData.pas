unit UEnergyTypeData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // �ܺķ���
  TEnergyTypeData = class
  private
    FEnergyTypeId: RInteger;    // �ܺķ��� ID
    FEnergyTypeCode: RString;   // �ܺķ������
    FEnergyTypeName: RString;   // �ܺķ�������
    FUnit_en: RString;          // ��λ (Ӣ��)
    FUnit_zh: RString;          // ��λ (����)
    FPrice: RDouble;            // ����
    FIsUsing: RBoolean;         // ����״̬
    FCiteCount: RInteger;       // ���ü���
  public
    constructor Create;

    property energyTypeId: RInteger read FEnergyTypeId write FEnergyTypeId;
    property energyTypeCode: RString read FEnergyTypeCode write FEnergyTypeCode;
    property energyTypeName: RString read FEnergyTypeName write FEnergyTypeName;
    property price: RDouble read FPrice write FPrice;
    property unit_en: RString read FUnit_en write FUnit_en;
    property unit_zh: RString read FUnit_zh write FUnit_zh;
    property isUsing: RBoolean read FIsUsing write FIsUsing;
    property citeCount: RInteger read FCiteCount write FCiteCount;
  end;

  TEnergyTypeDataList = class(TObjectList<TEnergyTypeData>)
  public
    function Add(): TEnergyTypeData; overload;
  end;

implementation

{ TEnergyTypeData }
constructor TEnergyTypeData.Create;
begin
  FEnergyTypeId.Clear;
  FEnergyTypeCode.Clear;
  FEnergyTypeName.Clear;
  FUnit_en.Clear;
  FUnit_zh.Clear;
  FPrice.Clear;
  FIsUsing.Clear;
  FCiteCount.Clear;
end;

{ TEnergyTypeDataList }
function TEnergyTypeDataList.Add(): TEnergyTypeData;
begin
  Result := TEnergyTypeData.Create;
  Self.Add(Result);
end;

end.
