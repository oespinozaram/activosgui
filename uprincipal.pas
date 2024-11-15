unit uPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, EditBtn;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnLimpiar: TBitBtn;
    btnCerrar: TBitBtn;
    edtBusqueda: TEditButton;
    GroupBox1: TGroupBox;
    edtNumExp: TLabeledEdit;
    edtNombre: TLabeledEdit;
    edtApePaterno: TLabeledEdit;
    edtApeMaterno: TLabeledEdit;
    edtFecha: TLabeledEdit;
    edtEstatus: TLabeledEdit;
    lbResultados: TListBox;
    lbNumExp: TListBox;
    rgBusqueda: TRadioGroup;
    procedure btnLimpiarClick(Sender: TObject);
    procedure edtBusquedaButtonClick(Sender: TObject);
    procedure edtBusquedaKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure lbResultadosClick(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation
uses uModulo;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.edtBusquedaButtonClick(Sender: TObject);
var
  nombre_completo : string;
begin
  if (edtBusqueda.Text <> EmptyStr) then
  begin
    edtNumExp.Text := '';
    edtNombre.Text := '';
    edtApePaterno.Text := '';
    edtApeMaterno.Text := '';
    edtFecha.Text := '';
    edtEstatus.Text := '';
    lbResultados.Clear;
    lbNumExp.Clear;
    dm.qry_search.Close;
    if (rgBusqueda.ItemIndex = 0) then
    begin
      dm.qry_search.SQL.Clear;
      dm.qry_search.SQL.Add('SELECT * FROM tbl_activos WHERE num_expediente LIKE :num');
      dm.qry_search.ParamByName('num').AsString := Format('%%%s%%', [edtBusqueda.Text]);
    end
    else
    begin
      dm.qry_search.SQL.Clear;
      dm.qry_search.SQL.Add('SELECT * FROM tbl_activos WHERE  nombre LIKE :buscar OR ape_paterno LIKE :buscar OR ape_materno LIKE :buscar');
      dm.qry_search.ParamByName('buscar').AsString := Format('%%%s%%', [edtBusqueda.Text]);
    end;

    dm.qry_search.Prepare;
    dm.qry_search.Open;

    if (not dm.qry_search.IsEmpty) then
    begin
      dm.qry_search.First;
      lbResultados.Items.BeginUpdate;
      lbNumExp.Items.BeginUpdate;
      while not dm.qry_search.EOF do
      begin
        nombre_completo := Format('%s %s %s', [
           dm.qry_search.FieldByName('nombre').AsString,
           dm.qry_search.FieldByName('ape_paterno').AsString,
           dm.qry_search.FieldByName('ape_materno').AsString
           ]);
        lbResultados.Items.Add(nombre_completo);
        lbNumExp.Items.Add(dm.qry_search.FieldByName('num_expediente').AsString);
        dm.qry_search.Next;
      end;
      lbResultados.Items.EndUpdate;
      lbNumExp.Items.EndUpdate;
    end;
    dm.qry_search.Close;
  end;
end;

procedure TfrmMain.btnLimpiarClick(Sender: TObject);
begin
  edtNumExp.Text := '';
  edtNombre.Text := '';
  edtApePaterno.Text := '';
  edtApeMaterno.Text := '';
  edtFecha.Text := '';
  edtEstatus.Text := '';
  lbResultados.Clear;
  lbNumExp.Clear;
  edtBusqueda.Clear;
  edtBusqueda.SetFocus;
end;

procedure TfrmMain.edtBusquedaKeyPress(Sender: TObject; var Key: char);
begin
  if (Key = #13) then edtBusquedaButtonClick(Sender);
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  dm.conn.Connected:=False;
  CloseAction := caFree;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  dm.conn.Connected:=True;
  rgBusqueda.ItemIndex:=0;
  edtBusqueda.SetFocus;
end;

procedure TfrmMain.lbResultadosClick(Sender: TObject);
var
  nombre, nombre_tmp, num : string;
begin
  if (lbResultados.ItemIndex > -1 ) then
  begin
    nombre := lbResultados.Items.Strings[lbResultados.ItemIndex];
    num := lbNumExp.Items.Strings[lbResultados.ItemIndex];
    dm.qry_result.Close;
    dm.qry_result.ParamByName('numexp').AsString := num;
    dm.qry_result.Prepare;
    dm.qry_result.Open;
    if (not dm.qry_result.IsEmpty) then
    begin
      dm.qry_result.First;
      while not dm.qry_result.Eof do
      begin
        nombre_tmp := Format('%s %s %s', [
           dm.qry_result.FieldByName('nombre').AsString,
           dm.qry_result.FieldByName('ape_paterno').AsString,
           dm.qry_result.FieldByName('ape_materno').AsString
           ]);
        if (CompareStr(nombre, nombre_tmp) = 0) then
        begin
          edtNumExp.Text := dm.qry_result.FieldByName('num_expediente').AsString;
          edtNombre.Text := dm.qry_result.FieldByName('nombre').AsString;
          edtApePaterno.Text := dm.qry_result.FieldByName('ape_paterno').AsString;
          edtApeMaterno.Text := dm.qry_result.FieldByName('ape_materno').AsString;
          edtFecha.Text := dm.qry_result.FieldByName('fecha').AsString;
          edtEstatus.Text := dm.qry_result.FieldByName('estatus').AsString;
          btnLimpiar.SetFocus;
          break;
        end;
        dm.qry_result.Next;
      end;
    end;
  end;
end;

end.

