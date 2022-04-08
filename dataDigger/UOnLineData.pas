unit UOnLineData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // 在线情况
  TOnLineData = class
  private
    Fdate: RDateTime;         // 日期
    FtotalCount: RInteger;    // 总数
    FonLineCount: RInteger;   // 在线数
    FoffLineCount: RInteger;  // 离线数
    FdebugCount: RInteger;    // 维护数
    FonLineRate: RDouble;     // 在线率
    FonLine: RBoolean;        // 在线
    FstateInfo: RString;      // 状态说明
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
