unit UOnLineData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // �������
  TOnLineData = class
  private
    Fdate: RDateTime;         // ����
    FtotalCount: RInteger;    // ����
    FonLineCount: RInteger;   // ������
    FoffLineCount: RInteger;  // ������
    FdebugCount: RInteger;    // ά����
    FonLineRate: RDouble;     // ������
    FonLine: RBoolean;        // ����
    FstateInfo: RString;      // ״̬˵��
  public
    constructor Create;

    property date: RDateTime read Fdate write Fdate;
    property totalCount: RInteger read FtotalCount write FtotalCount;
    property onLineCount: RInteger read FonLineCount write FonLineCount;
    property offLineCount: RInteger read FoffLineCount write FoffLineCount;
    property debugCount: RInteger read FdebugCount write FdebugCount;
    property onLineRate: RDouble read FonLineRate write FonLineRate;
    property onLine: RBoolean read FonLine write FonLine;
    property stateInfo: RString read FstateInfo write FstateInfo;
  end;

  TOnLineDataList = class(TObjectList<TOnLineData>)
  public
    function Add(): TOnLineData; overload;
  end;

implementation

{ TOnLineData }
constructor TOnLineData.Create;
begin
  Fdate.Clear;
  FtotalCount.Clear;
  FonLineCount.Clear;
  FoffLineCount.Clear;
  FonLineRate.Clear;
  FonLine.Clear;
  FstateInfo.Clear;
end;

{ TOnLineDataList }
function TOnLineDataList.Add(): TOnLineData;
begin
  Result := TOnLineData.Create;
  Self.Add(Result);
end;

end.
