unit UDDData.DBConn;

interface

uses
  SysUtils, ADODB, Windows, Classes,
  puer.Json.JsonDataObjects,
  UPrDbConnInter,
  UDDLogInter;

const
  DB_METER = 'db_DD_Meter';

type
  TDBConnCtrl = class
  public
    class procedure Open;
    class procedure Close;

    //class procedure Connect;
    class procedure ExecSQL(const aSQLStr: string);
  end;

implementation

var
  _ADOConn: TADOConnection;
  _ConnectionString: string;

{ TDBConnCtrl }
class procedure TDBConnCtrl.Open;
const
  DB_CONN = 'Provider=%s;Persist Security Info=False;User ID=%s;Password=%s;Initial Catalog=%s;Data Source=%s;Initial File Name="";Server SPN=""';
var
  aConnJson: TMemoryStream;
  aJson: TJsonObject;
  aErrorInfo: string;
begin
  aConnJson := TMemoryStream.Create;
  aJson := TJsonObject.Create;
  try
    if UPrDbConnInter.GetConnByName(DB_METER, aConnJson, aErrorInfo) then
    begin
      try
        aConnJson.Position := 0;
        aJson.LoadFromStream(aConnJson);

        _ConnectionString := Format(DB_CONN, [aJson.S['provider'], aJson.S['username'], aJson.S['password'], aJson.S['initialcatalog'], aJson.S['datasource']]);

        _ADOConn := TADOConnection.Create(nil);
        _ADOConn.Close;
        _ADOConn.LoginPrompt := False;
        _ADOConn.ConnectionString := _ConnectionString;
        //_ADOConn.Connected := True;

        OutputDebugString(PChar('SaveRealData: open ADOConn ³É¹¦'));
      except
        on E: Exception do
        begin
          OutputDebugString(PChar('SaveRealData: open ADOConn ' + E.Message));
        end;
      end;
    end;
  finally
    aConnJson.Free;
    aJson.Free;
  end;
end;

class procedure TDBConnCtrl.Close;
begin
  _ADOConn.Free;
end;

class procedure TDBConnCtrl.ExecSQL(const aSQLStr: string);
var
  aRecordsAffected: Integer;
begin
  try
    _ADOConn.Execute(aSQLStr, aRecordsAffected);
  except
    try
      _ADOConn.Close;
      _ADOConn.ConnectionString := _ConnectionString;
      _ADOConn.Connected := True;
      _ADOConn.Execute(aSQLStr, aRecordsAffected);
    except
      on E: Exception do
      begin
        _DDLogInter._WriteLog(DD_LOG_NAME, ltInfo, 'DBConn Execute Error, ' + E.Message);
      end;
    end;
  end;
end;

end.
