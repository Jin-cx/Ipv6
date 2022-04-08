unit UAreaData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // 区域
  TAreaData = class
  private
    FAreaId: RInteger;       // 区域 ID
    FAreaName: RString;      // 区域名称
    FParentId: RInteger;     // 父节点 ID
    FCiteCount: RInteger;    // 引用计数
  public
    property areaId: RInteger read FAreaId write FAreaId;
    property areaName: RString read FAreaName write FAreaName;
    property parentId: RInteger read FParentId write FParentId;
    property citeCount: RInteger read FCiteCount write FCiteCount;
  end;

  TAreaDataList = class(TObjectList<TAreaData>)
  public
    function Add(): TAreaData; overload;
  end;

implementation

{ TAreaDataList }
function TAreaDataList.Add(): TAreaData;
begin
  Result := TAreaData.Create;
  Self.Add(Result);
end;

end.
