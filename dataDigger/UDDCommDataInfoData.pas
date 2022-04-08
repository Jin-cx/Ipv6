unit UDDCommDataInfoData;

interface

uses
  Generics.Collections,
  puer.System, puer.Json.JsonDataObjects;

type
  // ���ر���ͳ������
  TGatewayCommStatisData = class
  private
    FGatewayDevNo: string;
    FSendCount: Integer;
    FSendSize: Integer;
    FReceiveCount: Integer;
    FReceiveSize: Integer;
    FCommList: TJsonArray;
  public
    constructor Create;
    destructor Destroy; override;

    property GatewayDevNo: string read FGatewayDevNo write FGatewayDevNo;
    property SendCount: Integer read FSendCount write FSendCount;
    property SendSize: Integer read FSendSize write FSendSize;
    property ReceiveCount: Integer read FReceiveCount write FReceiveCount;
    property ReceiveSize: Integer read FReceiveSize write FReceiveSize;
    property CommList: TJsonArray read FCommList;
  end;

  TGatewayCommStatisDataList = class(TObjectList<TGatewayCommStatisData>)
  public
    function Add(): TGatewayCommStatisData; overload;
  end;


  TCommDataInfoData = class
  private
    FdayHour: RDateTime;     // ����ʱ��
    FsendCount: RInteger;     // �� �������� (��)
    FsendSize: RInteger;      // �� ���Ĵ�С (KB)
    FreceiveCount: RInteger;  // �� �������� (��)
    FreceiveSize: RInteger;   // �� ���Ĵ�С (KB)
  public
    constructor Create;

    property dayHour: RDateTime read FdayHour write FdayHour;
    property sendCount: RInteger read FsendCount write FsendCount;
    property sendSize: RInteger read FsendSize write FsendSize;
    property receiveCount: RInteger read FreceiveCount write FreceiveCount;
    property receiveSize: RInteger read FreceiveSize write FreceiveSize;
  end;

  TCommDataInfoDataList = class(TObjectList<TCommDataInfoData>)
  public
    function Add(): TCommDataInfoData; overload;
  end;

implementation

{ TCommDataInfoData }
constructor TCommDataInfoData.Create;
begin
  FdayHour.Clear;
  FsendCount.Clear;
  FsendSize.Clear;
  FreceiveCount.Clear;
  FreceiveSize.Clear;
end;

{ TCommDataInfoDataList }
function TCommDataInfoDataList.Add(): TCommDataInfoData;
begin
  Result := TCommDataInfoData.Create;
  Self.Add(Result);
end;

{ TGatewayCommStatisData }
constructor TGatewayCommStatisData.Create;
begin
  inherited;
  FCommList := TJsonArray.Create;
end;

destructor TGatewayCommStatisData.Destroy;
begin
  FCommList.Free;
  inherited;
end;

{ TGatewayCommStatisDataList }
function TGatewayCommStatisDataList.Add: TGatewayCommStatisData;
begin
  Result := TGatewayCommStatisData.Create;
  Self.Add(Result);
end;

end.
