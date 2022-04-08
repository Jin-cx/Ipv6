unit UAreaData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // ����
  TAreaData = class
  private
    FAreaId: RInteger;       // ���� ID
    FAreaName: RString;      // ��������
    FParentId: RInteger;     // ���ڵ� ID
    FCiteCount: RInteger;    // ���ü���
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
