unit UDDData.SQLite;

interface

uses
  puer.SyncObjs, puer.SQLite;

type
  TMySQLite = class(TSQLite3Database)
  private
    FWriteLock: TPrRWLock;
  public
    constructor Create(const aFileName: string); overload;
    destructor Destroy; override;

    procedure ExecWithLock(const SQL: string); overload;
    procedure ExecWithLock(const SQL: string;
                           var aLastInsertId: Int64); overload;
  end;

implementation

{ TMySQLite }
constructor TMySQLite.Create(const aFileName: string);
begin
  inherited Create;
  FWriteLock := TPrRWLock.Create;
  Self.Open(aFileName);
  Self.SetJournalMode_WAL;
  Self.SetSynchronous_NORMAL;
  Self.ExecWithLock('PRAGMA foreign_keys = ON;');
end;

destructor TMySQLite.Destroy;
begin
  FWriteLock.Free;
  inherited;
end;

procedure TMySQLite.ExecWithLock(const SQL: string);
begin
  FWriteLock.BeginWrite;
  try
    Self.Execute(SQL);
  finally
    FWriteLock.EndWrite;
  end;
end;

procedure TMySQLite.ExecWithLock(const SQL: string; var aLastInsertId: Int64);
begin
  FWriteLock.BeginWrite;
  try
    Self.Execute(SQL);
    aLastInsertId := Self.LastInsertRowID;
  finally
    FWriteLock.EndWrite;
  end;
end;

end.
