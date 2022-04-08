unit UDDChangeData;

interface

uses
  SysUtils, Generics.Collections,
  puer.System;

type
  TMeterValueData = class
  private
    FmeterValueCode: RString;  // 计量编号
    FmeterValue: RDouble;      // 计量值
  public
    constructor Create;

    property meterValueCode: RString read FmeterValueCode write FmeterValueCode;
    property meterValue: RDouble read FmeterValue write FmeterValue;
  end;

  TMeterValueDataList = class(TObjectList<TMeterValueData>)
  public
    function Add(): TMeterValueData; overload;

    function HasValue(const aMeterValueCode: string): Boolean;
  end;

  // 终端设备实时数据
  TChangeData = class
  private
    FchangeId: RInteger;                  // 更换 ID
    FuserId: RInteger;                    // 用户 ID
    FuserCode: RString;                   // 用户编号
    FuserName: RString;                   // 用户名称
    FprojectUserCode: RString;            // 实际用户编号
    FprojectUserName: RString;            // 实际用户名称
    FchangeTime: RDateTime;               // 操作时间
    FchangeNote: RString;                 // 换表备注
    FdevName: RString;                    // 设备名称
    FdevModel: RString;                   // 设备型号
    FdevModelName: RString;               // 设备型号
    FdevInstallAddr: RString;             // 设备安装地址
    FoldDevId: RInteger;                  // 旧 设备 ID
    FoldDevNo: RString;                   // 旧 设备编号
    FoldDevFactoryNo: RString;            // 旧 设备厂家编号
    FnewDevId: RInteger;                  // 新 设备 ID
    FnewDevNo: RString;                   // 新 设备编号
    FnewDevFactoryNo: RString;            // 新 设备厂家编号
    FnewConn: RString;                    // 新 链接参数
    FnewDevNote: RString;                 // 新 备注
    FendTime: RDateTime;                  // 结束时间
    FendValueList: TMeterValueDataList;   // 结束示数列表
    FbeginTime: RDateTime;                // 起始时间
    FbeginValueList: TMeterValueDataList; // 起始示数列表
  public
    constructor Create;
    destructor Destroy; override;

    property changeId: RInteger read FchangeId write FchangeId;
    property userId: RInteger read FuserId write FuserId;
    property userCode: RString read FuserCode write FuserCode;
    property userName: RString read FuserName write FuserName;
    property projectUserCode: RString read FprojectUserCode write FprojectUserCode;
    property projectUserName: RString read FprojectUserName write FprojectUserName;
    property changeTime: RDateTime read FchangeTime write FchangeTime;
    property changeNote: RString read FchangeNote write FchangeNote;
    property devName: RString read FdevName write FdevName;
    property devModel: RString read FdevModel write FdevModel;
    property devModelName: RString read FdevModelName write FdevModelName;
    property devInstallAddr: RString read FdevInstallAddr write FdevInstallAddr;
    property oldDevId: RInteger read FoldDevId write FoldDevId;
    property oldDevNo: RString read FoldDevNo write FoldDevNo;
    property oldDevFactoryNo: RString read FoldDevFactoryNo write FoldDevFactoryNo;
    property newDevId: RInteger read FnewDevId write FnewDevId;
    property newDevNo: RString read FnewDevNo write FnewDevNo;
    property newDevFactoryNo: RString read FnewDevFactoryNo write FnewDevFactoryNo;
    property newConn: RString read FnewConn write FnewConn;
    property newDevNote: RString read FnewDevNote write FnewDevNote;
    property endTime: RDateTime read FendTime write FendTime;
    property endValueList: TMeterValueDataList read FendValueList write FendValueList;
    property beginTime: RDateTime read FbeginTime write FbeginTime;
    property beginValueList: TMeterValueDataList read FbeginValueList write FbeginValueList;
  end;

  TChangeDataList = class(TObjectList<TChangeData>)
  public
    function Add(): TChangeData; overload;
  end;

implementation

{ TMeterValueData }
constructor TMeterValueData.Create;
begin
  FmeterValueCode.Clear;
  FmeterValue.Clear;
end;

{ TMeterValueDataList }
function TMeterValueDataList.Add(): TMeterValueData;
begin
  Result := TMeterValueData.Create;
  Self.Add(Result);
end;

function TMeterValueDataList.HasValue(const aMeterValueCode: string): Boolean;
var
  aMeterValue: TMeterValueData;
begin
  for aMeterValue in Self do
  begin
    if SameText(aMeterValue.meterValueCode.AsString, aMeterValueCode) then
    begin
      Result := not aMeterValue.FmeterValue.IsNull;
      Exit;
    end;
  end;

  Result := False;
end;

{ TChangeData }
constructor TChangeData.Create;
begin
  inherited;
  FendValueList := TMeterValueDataList.Create;
  FbeginValueList := TMeterValueDataList.Create;

  FchangeId.Clear;
  FuserId.Clear;
  FuserCode.Clear;
  FuserName.Clear;
  FprojectUserCode.Clear;
  FprojectUserName.Clear;
  FchangeTime.Clear;
  FchangeNote.Clear;
  FdevName.Clear;
  FdevModel.Clear;
  FdevModelName.Clear;
  FdevInstallAddr.Clear;
  FoldDevId.Clear;
  FoldDevNo.Clear;
  FoldDevFactoryNo.Clear;
  FnewDevId.Clear;
  FnewDevNo.Clear;
  FnewDevFactoryNo.Clear;
  FnewConn.Clear;
  FnewDevNote.Clear;
  FendTime.Clear;
  FbeginTime.Clear;
end;

destructor TChangeData.Destroy;
begin
  FendValueList.Free;
  FbeginValueList.Free;
  inherited;
end;

{ TChangeDataList }
function TChangeDataList.Add(): TChangeData;
begin
  Result := TChangeData.Create;
  Self.Add(Result);
end;

end.
