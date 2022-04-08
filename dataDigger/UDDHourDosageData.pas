unit UDDHourDosageData;

interface

uses
  Generics.Collections,
  puer.System;

type
  // ���Сʱ����
  THourDosageData = class
  private
    FDate: TDate;           // ����
    FHour: Integer;         // Сʱ
    FDevId: Integer;        // Сʱ
    FDevNo: string;         // �豸���
    FBeginValue: RDouble;   // ��ʼʾ��
    FBeginTime: RDateTime;  // ��ʼʱ��
    FEndValue: RDouble;     // ����ʾ��
    FEndTime: RDateTime;    // ����ʱ��
    FDosage: RDouble;       // ����
    FDataType: Integer;     // ��������
    FDosage_Ten1: RDouble;  // ��1��ʮ���ӵ�����
    FDosage_Ten2: RDouble;  // ��2��ʮ���ӵ�����
    FDosage_Ten3: RDouble;  // ��3��ʮ���ӵ�����
    FDosage_Ten4: RDouble;  // ��4��ʮ���ӵ�����
    FDosage_Ten5: RDouble;  // ��5��ʮ���ӵ�����
    FDosage_Ten6: RDouble;  // ��6��ʮ���ӵ�����
    FIsStatis: RBoolean;    // �Ƿ�ͳ�����
  public
    constructor Create;

    property date: TDate read FDate write FDate;
    property hour: Integer read FHour write FHour;
    property devId: Integer read FDevId write FDevId;
    property devNo: string read FDevNo write FDevNo;
    property beginValue: RDouble read FBeginValue write FBeginValue;
    property beginTime: RDateTime read FBeginTime write FBeginTime;
    property endValue: RDouble read FEndValue write FEndValue;
    property endTime: RDateTime read FEndTime write FEndTime;
    property dosage: RDouble read FDosage write FDosage;
    property dataType: Integer read FDataType write FDataType;
    property dosage_Ten1: RDouble read FDosage_Ten1 write FDosage_Ten1;
    property dosage_Ten2: RDouble read FDosage_Ten2 write FDosage_Ten2;
    property dosage_Ten3: RDouble read FDosage_Ten3 write FDosage_Ten3;
    property dosage_Ten4: RDouble read FDosage_Ten4 write FDosage_Ten4;
    property dosage_Ten5: RDouble read FDosage_Ten5 write FDosage_Ten5;
    property dosage_Ten6: RDouble read FDosage_Ten6 write FDosage_Ten6;
    property isStatis: RBoolean read FIsStatis write FIsStatis;
    procedure Assign(const aHourDosageData: THourDosageData);
  end;

  THourDosageDataList = class(TObjectList<THourDosageData>)
  public
    function Add(): THourDosageData; overload;
    procedure Assign(const aDataList: THourDosageDataList);
  end;

implementation

{ THourDosageData }
procedure THourDosageData.Assign(const aHourDosageData: THourDosageData);
begin
  Self.Date := aHourDosageData.Date;
  Self.Hour := aHourDosageData.Hour;
  Self.devId := aHourDosageData.devId;
  Self.DevNo := aHourDosageData.DevNo;
  Self.BeginValue := aHourDosageData.BeginValue;
  Self.BeginTime := aHourDosageData.BeginTime;
  Self.EndValue := aHourDosageData.EndValue;
  Self.EndTime := aHourDosageData.EndTime;
  Self.Dosage := aHourDosageData.Dosage;
  Self.DataType := aHourDosageData.DataType;
  Self.dosage_Ten1 := aHourDosageData.dosage_Ten1;
  Self.dosage_Ten2 := aHourDosageData.dosage_Ten2;
  Self.dosage_Ten3 := aHourDosageData.dosage_Ten3;
  Self.dosage_Ten4 := aHourDosageData.dosage_Ten4;
  Self.dosage_Ten5 := aHourDosageData.dosage_Ten5;
  Self.dosage_Ten6 := aHourDosageData.dosage_Ten6;
  Self.isStatis := aHourDosageData.isStatis;
end;

constructor THourDosageData.Create;
begin
  FBeginValue.Clear;
  FBeginTime.Clear;
  FEndValue.Clear;
  FEndTime.Clear;
  FDosage.Clear;
  FDosage_Ten1.Clear;
  FDosage_Ten2.Clear;
  FDosage_Ten3.Clear;
  FDosage_Ten4.Clear;
  FDosage_Ten5.Clear;
  FDosage_Ten6.Clear;
  FIsStatis.Clear;
end;

{ THourDosageDataList }
function THourDosageDataList.Add(): THourDosageData;
begin
  Result := THourDosageData.Create;
  Self.Add(Result);
end;

procedure THourDosageDataList.Assign(const aDataList: THourDosageDataList);
var
  aData: THourDosageData;
begin
  Self.Clear;
  if aDataList = nil then
    Exit;

  for aData in aDataList do
    Self.Add.Assign(aData);
end;

end.
