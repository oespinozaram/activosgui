unit uModulo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, SQLite3Conn;

type

  { Tdm }

  Tdm = class(TDataModule)
    conn: TSQLite3Connection;
    qry_search: TSQLQuery;
    qry_result: TSQLQuery;
    sqlt: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private

  public

  end;

var
  dm: Tdm;

implementation

{$R *.lfm}

{ Tdm }

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  conn.DatabaseName:='activos.db';
end;

end.

