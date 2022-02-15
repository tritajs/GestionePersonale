unit frstatogiuridico_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  StdCtrls;


type

  { TFrStatoGiuridico }

  TFrStatoGiuridico = class(TFrame)
    AL: TWDateEdit;

    DAL: TWDateEdit;
    Image1: TImage;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGStatoGiuridico: TStringGrid;
    KSstato: TWTComboBoxSql;
    procedure ALEditingDone(Sender: TObject);
    procedure ALKeyPress(Sender: TObject; var Key: char);
    procedure DALEditingDone(Sender: TObject);
    procedure DALKeyPress(Sender: TObject; var Key: char);
    procedure KSstatoChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGStatoGiuridicoPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGStatoGiuridicoSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGStatoGiuridicoValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    procedure VisibleTastiConferma(button:boolean);
    procedure SalvaDati;
    procedure LeggeDati;
    function  CheckDati:boolean; //cControlla i dati
    { private declarations }
  public
    Procedure Esegui(grant:integer);
    { public declarations }
  end;

implementation
{$R *.lfm}

uses main_f, DM_f, fmdatipersonali_f;

Var operazione: Toperazione;

{ TFrStatoGiuridico }


procedure TFrStatoGiuridico.SGStatoGiuridicoPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGStatoGiuridico.Cells[0,aRow] = 'C') then
        SGStatoGiuridico.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrStatoGiuridico.SGStatoGiuridicoSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
Var st:string;
begin
  if (aCol=4) and (aRow>0) then begin  //stato giuridico
    KSstato.BoundsRect:=SGStatoGiuridico.CellRect(aCol,aRow);
    KSstato.Text:=SGStatoGiuridico.Cells[SGStatoGiuridico.Col,SGStatoGiuridico.Row];
    Editor:= KSstato;
  end;
  if (aCol=5) and (aRow>0) then begin //DAL TRASFERIMENTO
    DAL.BoundsRect:=SGStatoGiuridico.CellRect(aCol,aRow);
    DAL.Text:=SGStatoGiuridico.Cells[SGStatoGiuridico.Col,SGStatoGiuridico.Row];
    Editor:=DAL;
  end;
  if (aCol=6) and (aRow>0) then begin //AL
    AL.BoundsRect:=SGStatoGiuridico.CellRect(aCol,aRow);
    AL.Text:=SGStatoGiuridico.Cells[SGStatoGiuridico.Col,SGStatoGiuridico.Row];
    Editor:=AL;
  end;
end;

procedure TFrStatoGiuridico.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGStatoGiuridico.Options:= SGStatoGiuridico.Options + [goEditing];
   SGStatoGiuridico.RowCount:= SGStatoGiuridico.RowCount + 1;
   SGStatoGiuridico.Cells[0,SGStatoGiuridico.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGStatoGiuridico.Col:= 1;
   SGStatoGiuridico.Row:= SGStatoGiuridico.RowCount - 1;
end;

procedure TFrStatoGiuridico.SBokClick(Sender: TObject);
begin
  if CheckDati then
   begin
     SGStatoGiuridico.Col:=1;
     SalvaDati;
     Operazione:= FtView;
     VisibleTastiConferma(False);
   end;
end;





procedure TFrStatoGiuridico.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGStatoGiuridico.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGStatoGiuridico.Cells[2,SGStatoGiuridico.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGStatoGiuridico.DeleteRow(SGStatoGiuridico.Row)
        else   // fase di modifica
         begin
           SGStatoGiuridico.Cells[0,SGStatoGiuridico.Row]:= 'C';
           VisibleTastiConferma(True);
           SGStatoGiuridico.Refresh;
         end;
      end;
   end;
end;

procedure TFrStatoGiuridico.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrStatoGiuridico.DALEditingDone(Sender: TObject);
begin
 SGStatoGiuridico.Cells[5,SGStatoGiuridico.Row]:= DAL.Text;
 if SGStatoGiuridico.Cells[0,SGStatoGiuridico.Row]= '' then
   SGStatoGiuridico.Cells[0,SGStatoGiuridico.Row]:= 'M';
end;

procedure TFrStatoGiuridico.DALKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
   if DAL.dataok then
     begin
       SGStatoGiuridico.Col:= 6;
       SGStatoGiuridico.SetFocus;
      end;
end;


procedure TFrStatoGiuridico.ALKeyPress(Sender: TObject; var Key: char);
begin
    if Key = #13 then
    begin
       SGStatoGiuridico.Col:= 7;
       SGStatoGiuridico.SetFocus;
    end;
end;

procedure TFrStatoGiuridico.ALEditingDone(Sender: TObject);
begin
  SGStatoGiuridico.Cells[6,SGStatoGiuridico.Row]:= AL.Text;
 if SGStatoGiuridico.Cells[0,SGStatoGiuridico.Row]= '' then
   SGStatoGiuridico.Cells[0,SGStatoGiuridico.Row]:= 'M';
end;


procedure TFrStatoGiuridico.KSstatoChange(Sender: TObject);
begin
  SGStatoGiuridico.Cells[4,SGStatoGiuridico.Row]:= KSstato.Text;
  SGStatoGiuridico.Cells[3,SGStatoGiuridico.Row]:= KSstato.ValueLookField;
  SGStatoGiuridico.Col:= 5;
  SGStatoGiuridico.Cells[5,SGStatoGiuridico.Row]:= SGStatoGiuridico.Cells[5,SGStatoGiuridico.Row];
  SGStatoGiuridico.SetFocus;

end;


procedure TFrStatoGiuridico.SBeditClick(Sender: TObject);
begin
  SGStatoGiuridico.Options:= SGStatoGiuridico.Options + [goEditing];;
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrStatoGiuridico.SGStatoGiuridicoValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGStatoGiuridico.Cells[0,aRow] = '') then
     SGStatoGiuridico.Cells[0,aRow]:= 'M';
end;

procedure TFrStatoGiuridico.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSstato.ReadOnly:= not button; // abilito Combox Stato Giuridico
  DAL.ReadOnly:= not button; // abilito DAL
  AL.ReadOnly:= not button; // abilito AL
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGStatoGiuridico.Options:= SGStatoGiuridico.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
    end
  else
    begin
     SGStatoGiuridico.Options:= SGStatoGiuridico.Options - [goEditing];
     FmDatiPersonali.WTnav.Enabled:= True;
    end;

end;

procedure TFrStatoGiuridico.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGStatoGiuridico.RowCount - 1 do
    begin
      if SGStatoGiuridico.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from AGGIORNAMENTO_STATOGIURIDICO(' + '''' + SGStatoGiuridico.Cells[0,riga]  + ''',';
          if SGStatoGiuridico.Cells[1,riga] = '' then  //idstatogiuridico
            st:= st + '0,'
          else
            st:= st +  SGStatoGiuridico.Cells[1,riga] + ',';
          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare
          if SGStatoGiuridico.Cells[3,riga] = '' then  //ksstato
            st:= st + '0,'
          else
            st:= st +  SGStatoGiuridico.Cells[3,riga] + ',';
          if SGStatoGiuridico.Cells[5,riga] = '' then  // DATA DAL
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGStatoGiuridico.Cells[5,riga],True) + ',';
          if SGStatoGiuridico.Cells[6,riga] = '' then  // DATA AL
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGStatoGiuridico.Cells[6,riga],True) + ',';
          if SGStatoGiuridico.Cells[7,riga] = '' then  // nota
            st:= st + 'null)'
          else
            st:= st + '''' +  StringReplace(SGStatoGiuridico.Cells[7,riga],'''','''''',[rfReplaceAll]) +  ''')';
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
      //    Memo1.Text:=st;
          FmDatiPersonali.ECdati.ReadDate;
        end;
    end;
   LeggeDati;

end;

procedure TFrStatoGiuridico.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= ' SELECT r.IDSTATOGIURIDICO, r.KSMILITARE, r.KSSTATO, r1.DESCRIZIONE, r.DAL, r.AL, r.NOTE   ';
 st:= st + ' FROM LISTASTATOGIURIDICO r left join STATO r1 on (r.ksstato = r1.IDSTATO) ';
 st:= st + ' where r.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 st:= st + ' order by r.idstatogiuridico';
 SGStatoGiuridico.Clear;
 SGStatoGiuridico.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGStatoGiuridico.RowCount:= SGStatoGiuridico.RowCount + 1;
          riga:= SGStatoGiuridico.RowCount - 1;
          SGStatoGiuridico.Cells[1,riga] := dm.DSetTemp.FieldByName('IDSTATOGIURIDICO').AsString;
          SGStatoGiuridico.Cells[2,riga] := dm.DSetTemp.FieldByName('KSMILITARE').AsString;
          SGStatoGiuridico.Cells[3,riga] := dm.DSetTemp.FieldByName('KSSTATO').AsString;
          SGStatoGiuridico.Cells[4,riga] := dm.DSetTemp.FieldByName('DESCRIZIONE').AsString;
          SGStatoGiuridico.Cells[5,riga] := dm.DSetTemp.FieldByName('DAL').AsString;
          SGStatoGiuridico.Cells[6,riga] := dm.DSetTemp.FieldByName('AL').AsString;
          SGStatoGiuridico.Cells[7,riga] := dm.DSetTemp.FieldByName('NOTE').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

function TFrStatoGiuridico.CheckDati: boolean;
Var errore:string;
begin
  Result := True;
  errore:= '';
  with SGStatoGiuridico  do
   begin
 //    if (Cells[2,Row] = '') then  errore:=  Columns[2].Title.Caption;
 //    if (Cells[4,Row] = '') then  errore:=  Columns[4].Title.Caption;
 //    if (Cells[6,Row] = '') then  errore:=  Columns[6].Title.Caption;
     if errore <> '' then
       begin
         ShowMessage(' Attenzione non hai inserito: ' +  errore );
         Result:= False;
       end;
   end;
end;

procedure TFrStatoGiuridico.Esegui(grant: integer);
begin
  LeggeDati;
  if Grant = 4 then //Solo Lettura
    begin
      SBdel.Visible:= False;
      SBIns.Visible:= False;
      SBedit.Visible:=False;
    end;
end;

end.

