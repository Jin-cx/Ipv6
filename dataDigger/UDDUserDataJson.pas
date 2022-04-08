unit UDDUserDataJson;

interface

uses
  puer.System, puer.Json.JsonDataObjects,
  UDDUserData;

type
  TUserDataJson = class(TUserData)
  public
    function AsJson: TJsonObject;
    function ToJsonStr: string;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonObject);
    procedure LoadFromJsonStr(const aJsonStr: string);
  end;

  TUserDataListJson = class(TUserDataList)
  public
    function AsJson: TJsonArray;
    function AsStream: IPrStream;
    procedure LoadFromJson(const aJson: TJsonArray); overload;
    procedure LoadFromJson(const aJsonString: string); overload;
  end;

implementation

{ TUserDataJson }
function TUserDataJson.AsJson: TJsonObject;
begin
  Result := TJsonObject.Create;

  Result.RI['userId'] := UserId;
  Result.RS['userCode'] := UserCode;
  Result.RS['userName'] := UserName;
  Result.RB['isAdmin'] := IsAdmin;
  Result.RB['isEnable'] := IsEnable;
  Result.RS['tel'] := Tel;
  Result.RS['email'] := Email;
  Result.RS['userNote'] := UserNote;
  Result.RB['dayReport'] := DayReport;
end;

function TUserDataJson.ToJsonStr: string;
var
  aJson: TJsonObject;
begin
  aJson := AsJson;
  try
    Result := aJson.ToJSON(True);
  finally
    aJson.Free;
  end;
end;

function TUserDataJson.AsStream: IPrStream;
var
  aJson: TJsonObject;
begin
  aJson := AsJson;
  try
    Result := TPrStream.Create;
    aJson.SaveToStream(Result.Stream);
  finally
    aJson.Free;
  end;
end;

procedure TUserDataJson.LoadFromJson(const aJson: TJsonObject);
begin
  UserId := aJson.RI['userId'];
  UserCode := aJson.RS['userCode'];
  UserName := aJson.RS['userName'];
  IsAdmin := aJson.RB['isAdmin'];
  IsEnable := aJson.RB['isEnable'];
  Tel := aJson.RS['tel'];
  Email := aJson.RS['email'];
  UserNote := aJson.RS['userNote'];
  DayReport := aJson.RB['dayReport'];
end;

procedure TUserDataJson.LoadFromJsonStr(const aJsonStr: string);
var
  aJson: TJsonObject;
begin
  aJson := TJsonObject.Create;
  try
    aJson.FromJSON(aJsonStr);
    LoadFromJson(aJson);
  finally
    aJson.Free;
  end;
end;

{ TUserDataListJson }
function TUserDataListJson.AsJson: TJsonArray;
var
  aUserData: TUserData;
begin
  Result := TJsonArray.Create;
  for aUserData in Self do
    Result.Add(TUserDataJson(aUserData).AsJson);
end;

function TUserDataListJson.AsStream: IPrStream;
var
  aJson: TJsonArray;
begin
  aJson := AsJson;
  try
    Result := TPrStream.Create;
    aJson.SaveToStream(Result.Stream);
  finally
    aJson.Free;
  end;
end;

procedure TUserDataListJson.LoadFromJson(const aJson: TJsonArray);
var
  i: Integer;
begin
  if (aJson = nil) or (aJson.Count = 0) then
    Exit;

  for i := 0 to aJson.Count - 1 do
    TUserDataJson(Self.Add).LoadFromJson(aJson.O[i]);
end;

procedure TUserDataListJson.LoadFromJson(const aJsonString: string);
var
  aJson: TJsonArray;
begin
  if aJsonString = '' then
    Exit;

  aJson := TJsonArray.Create;
  try
    aJson.FromJSON(aJsonString);
    LoadFromJson(aJson);
  finally
    aJson.Free;
  end;
end;

end.
