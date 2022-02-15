unit fronorificenze_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  Calendar, StdCtrls;

type

  { TFrOnorificenze }

  TFrOnorificenze = class(TFrame)
    DataRicompensa: TWDateEdit;
    Image1: TImage;
    KSonorificenza: TWTComboBoxSql;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGonorificenza: TStringGrid;
    procedure DataRicompensaEditingDone(Sender: TObject);
    procedure DataRicompensaKeyPress(Sender: TObject; var Key: char);
    procedure KSonorificenzaChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGonorificenzaGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure SGonorificenzaHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
   procedure SGonorificenzaPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGonorificenzaSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure SGonorificenzaSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGonorificenzaValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    procedure VisibleTastiConferma(button:boolean);
    procedure SalvaDati;
    procedure LeggeDati;
    { private declarations }
  public
    Procedure Esegui(grant:integer);
    { public declarations }
  end;

implementation
{$R *.lfm}

uses main_f, DM_f, fmdatipersonali_f;

Var operazione: Toperazione;

{ TFrOnorificenze }

procedure TFrOnorificenze.SGonorificenzaGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
   if (ARow > 0) then
   if (ACol = 3) then
     value := '!99/99/0000;1;_';
end;

procedure TFrOnorificenze.SGonorificenzaHeaderClick(Sender: TObject;
  IsColumn: Boolean; Index: Integer);
var
  st,Onore: string;
begin
   Onore := InputBox('',
    'Inserisci l''onorificenza che manca nell''elenco', '');
   // controllo se l'onorificenza è già presente in archivio
   Onore:= Ch_apostrofo(Trim(UpperCase(Onore)));
   st:= ' Select * from onorificenze where onorificenza = ''' + Onore + '''';
   if not EseguiSQL(dm.QTabelle,st,Open,'') then
     begin
       st:= 'insert into onorificenze (onorificenza) values (''' + Onore + ''')';
       EseguiSQL(dm.QTabelle,st,Open,'');
     end
   else
     Showmessage(Onore + ' già presente in archivio');
   SGonorificenza.SetFocus;
end;



procedure TFrOnorificenze.SGonorificenzaPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGonorificenza.Cells[0,aRow] = 'C') then
        SGonorificenza.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrOnorificenze.SGonorificenzaSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
//  if (Acol = 2) or (Acol = 5) then
//    CanSelect := False;
end;

procedure TFrOnorificenze.SGonorificenzaSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
   if (aCol=3) and (aRow>0) then begin
    DataRicompensa.BoundsRect:=SGonorificenza.CellRect(aCol,aRow);
    DataRicompensa.Text:=SGonorificenza.Cells[SGonorificenza.Col,SGonorificenza.Row];
    Editor:=DataRicompensa;
  end;
  if (aCol=1) and (aRow>0) then begin
     KSonorificenza.BoundsRect:=SGonorificenza.CellRect(aCol,aRow);
     KSonorificenza.Text:=SGonorificenza.Cells[SGonorificenza.Col,SGonorificenza.Row];
     Editor:= KSonorificenza;
  end;
end;

procedure TFrOnorificenze.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGonorificenza.Options:= SGonorificenza.Options + [goEditing];;
   SGonorificenza.RowCount:= SGonorificenza.RowCount + 1;
   SGonorificenza.Cells[0,SGonorificenza.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGonorificenza.Cells[1,SGonorificenza.RowCount - 1]:= '';
end;

procedure TFrOnorificenze.SBokClick(Sender: TObject);
begin
  SGonorificenza.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;


procedure TFrOnorificenze.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGonorificenza.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGonorificenza.Cells[0,SGonorificenza.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGonorificenza.DeleteRow(SGonorificenza.Row)
        else   // fase di modifica
         begin
           SGonorificenza.Cells[0,SGonorificenza.Row]:= 'C';
           SGonorificenza.Repaint;
           VisibleTastiConferma(True);
         end;
      end;
   end;
end;

procedure TFrOnorificenze.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrOnorificenze.DataRicompensaEditingDone(Sender: TObject);
begin
  SGonorificenza.Cells[SGonorificenza.Col,SGonorificenza.Row]:= DataRicompensa.Text;
  if SGonorificenza.Cells[0,SGonorificenza.Row]= '' then
     SGonorificenza.Cells[0,SGonorificenza.Row]:= 'M';
  SGonorificenza.SetFocus;
end;

procedure TFrOnorificenze.DataRicompensaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
   if DataRicompensa.dataok then
      begin
        SGonorificenza.Col:= 6;
        SGonorificenza.SetFocus;
      end;
end;



procedure TFrOnorificenze.KSonorificenzaChange(Sender: TObject);
begin
   SGonorificenza.Cells[1,SGonorificenza.Row]:= KSonorificenza.Text;
   SGonorificenza.Cells[5,SGonorificenza.Row]:= KSonorificenza.ValueLookField;
   SGonorificenza.Col:= 2;
   SGonorificenza.Cells[SGonorificenza.Col,SGonorificenza.Row]:= SGonorificenza.Cells[SGonorificenza.Col,SGonorificenza.Row];
   SGonorificenza.SetFocus;
end;

procedure TFrOnorificenze.SBeditClick(Sender: TObject);
begin
  SGonorificenza.Options:= SGonorificenza.Options + [goEditing];
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrOnorificenze.SGonorificenzaValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGonorificenza.Cells[0,aRow] = '') then
     SGonorificenza.Cells[0,aRow]:= 'M';
end;

procedure TFrOnorificenze.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSonorificenza.ReadOnly:= not button; //abilito o disabilito ricompense
  DataRicompensa.ReadOnly:= not button; // e la data Ricompensa
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGonorificenza.Options:= SGonorificenza.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
    end
  else
    begin
      SGonorificenza.Options:= SGonorificenza.Options - [goEditing];
      FmDatiPersonali.WTnav.Enabled:= True;
    end;
end;

procedure TFrOnorificenze.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGonorificenza.RowCount - 1 do
    begin
      if SGonorificenza.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_onorificenze(' + '''' + SGonorificenza.Cells[0,riga]  + ''',';
          if SGonorificenza.Cells[4,riga] = '' then  //idonorificenze
            st:= st + '0,'
          else
            st:= st +  SGonorificenza.Cells[4,riga] + ',';

          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

          if SGonorificenza.Cells[2,riga] = '' then  //NUMERO DETERMINA
             st:= st + 'null,'
          else
            st:= st + SGonorificenza.Cells[2,riga] + ',';      //NUMERO DETERMINA

          if SGonorificenza.Cells[3,riga] = '' then  // DATA ONORIFICENZA
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGonorificenza.Cells[3,riga],True) + ',';

          st:= st + SGonorificenza.Cells[5,riga] + ',';      //KSonorificenza

          if SGonorificenza.Cells[6,riga] = '' then  // NOTE
            st:= st + 'null)'
          else
            st:= st +  '''' + Ch_apostrofo(Trim(SGonorificenza.Cells[6,riga])) + ''')';
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
//       Memo1.Text:=st;
  LeggeDati;
end;

procedure TFrOnorificenze.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= ' SELECT * FROM VIEW_ONORIFICENZE r  ';
 st:= st + ' where r.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 SGonorificenza.Clear;
 SGonorificenza.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGonorificenza.RowCount:= SGonorificenza.RowCount + 1;
          riga:= SGonorificenza.RowCount - 1;
          SGonorificenza.Cells[1,riga] := dm.DSetTemp.FieldByName('ONORIFICENZA').AsString;
          SGonorificenza.Cells[2,riga] := dm.DSetTemp.FieldByName('DETERMINA').AsString;
          SGonorificenza.Cells[3,riga] := dm.DSetTemp.FieldByName('DATAONORIFICENZA').AsString;
          SGonorificenza.Cells[4,riga] := dm.DSetTemp.FieldByName('IDLISTAONORIFICENZE').AsString;
          SGonorificenza.Cells[5,riga] := dm.DSetTemp.FieldByName('KSONORIFICENZA').AsString;
          SGonorificenza.Cells[6,riga] := dm.DSetTemp.FieldByName('NOTE').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrOnorificenze.Esegui(grant: integer);
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

