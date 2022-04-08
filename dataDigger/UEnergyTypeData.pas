unit UEnergyTypeData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // 能耗分类
  TEnergyTypeData = class
  private
    FEnergyTypeId: RInteger;    // 能耗分类 ID
    FEnergyTypeCode: RString;   // 能耗分类编码
    FEnergyTypeName: RString;   // 能耗分类名称
    FUnit_en: RString;          // 单位 (英文)
    FUnit_zh: RString;          // 单位 (中文)
    FPrice: RDouble;            // 单价
    FIsUsing: RBoolean;         // 启用状态
    FCiteCount: RInteger;       // 引用计数
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
