unit fricompense_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  Calendar, StdCtrls;

type

  { TFrOnorificenze }

  TFrRicompense = class(TFrame)
    DataRicompensa: TWDateEdit;
    Image1: TImage;
    KSricompensa: TWTComboBoxSql;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGricompensa: TStringGrid;
    KSAUTORITA: TWTComboBoxSql;
    procedure DataRicompensaEditingDone(Sender: TObject);
    procedure DataRicompensaKeyPress(Sender: TObject; var Key: char);
    procedure KSAUTORITAChange(Sender: TObject);
    procedure KSricompensaChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGricompensaGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure SGricompensaHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure SGricompensaPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGricompensaSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure SGricompensaSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGricompensaValidateEntry(sender: TObject; aCol, aRow: Integer;
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

procedure TFrRicompense.SGricompensaGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
   if (ARow > 0) then
   if (ACol = 3) then
     value := '!99/99/0000;1;_';
end;

procedure TFrRicompense.SGricompensaHeaderClick(Sender: TObject;
  IsColumn: Boolean; Index: Integer);

Var st,st1: string;
begin
  if index = 1 then //Ricompense
    begin
       st1 := InputBox('',
        'Inserisci la ricompensa che manca nell''elenco', '');
       // controllo se la ricompensa è già presente in archivio
       if st1 <> '' then
         begin
           St1:= Ch_apostrofo(Trim(UpperCase(st1)));
           st:= ' Select * from ricompense where ricompensa = ''' + st1 + '''';
           if not EseguiSQL(dm.QTabelle,st,Open,'') then
             begin
               st:= 'insert into ricompense (ricompensa) values (''' + st1 + ''')';
               EseguiSQL(dm.QTabelle,st,Open,'');
             end
           else
             Showmessage(st1 + ' già presente in archivio');
         end;
    end;

  if index = 4 then //AUTORITA' CONCEDENTE
    begin
       st1 := InputBox('',
        'Inserisci l'' autorità che manca nell''elenco', '');
       // controllo se l' autorità è già presente in archivio
       if st1 <> '' then
         begin
           St1:= Ch_apostrofo(Trim(UpperCase(st1)));
           st:= ' Select * from  autoritaricompensa where autorita = ''' + st1 + '''';
           if not EseguiSQL(dm.QTabelle,st,Open,'') then
             begin
               st:= 'insert into autoritaricompensa (autorita) values (''' + st1 + ''')';
               EseguiSQL(dm.QTabelle,st,Open,'');
             end
           else
             Showmessage(st1 + ' già presente in archivio');
         end;
    end;
  SGricompensa.SetFocus;
end;

procedure TFrRicompense.SGricompensaPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGricompensa.Cells[0,aRow] = 'C') then
        SGricompensa.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrRicompense.SGricompensaSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
//  if (Acol = 2) or (Acol = 5) then
//    CanSelect := False;
end;

procedure TFrRicompense.SGricompensaSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
   if (aCol=3) and (aRow>0) then begin
    DataRicompensa.BoundsRect:=SGricompensa.CellRect(aCol,aRow);
    DataRicompensa.Text:=SGricompensa.Cells[SGricompensa.Col,SGricompensa.Row];
    Editor:=DataRicompensa;
  end;
  if (aCol=1) and (aRow>0) then begin
     KSricompensa.BoundsRect:=SGricompensa.CellRect(aCol,aRow);
     KSricompensa.Text:=SGricompensa.Cells[SGricompensa.Col,SGricompensa.Row];
     Editor:= KSricompensa;
  end;
  if (aCol=4) and (aRow>0) then begin
    KSAUTORITA.BoundsRect:=SGricompensa.CellRect(aCol,aRow);
    KSAUTORITA.Text:=SGricompensa.Cells[SGricompensa.Col,SGricompensa.Row];
    Editor:= KSAUTORITA;
  end;
end;

procedure TFrRicompense.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGricompensa.Options:= SGricompensa.Options + [goEditing];;
   SGricompensa.RowCount:= SGricompensa.RowCount + 1;
   SGricompensa.Cells[0,SGricompensa.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGricompensa.Cells[1,SGricompensa.RowCount - 1]:= '';
end;

procedure TFrRicompense.SBokClick(Sender: TObject);
begin
  SGricompensa.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;


procedure TFrRicompense.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGricompensa.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGricompensa.Cells[0,SGricompensa.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGricompensa.DeleteRow(SGricompensa.Row)
        else   // fase di modifica
         begin
           SGricompensa.Cells[0,SGricompensa.Row]:= 'C';
           SGricompensa.Repaint;
           VisibleTastiConferma(True);
         end;
      end;
   end;
end;

procedure TFrRicompense.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrRicompense.DataRicompensaEditingDone(Sender: TObject);
begin
  SGricompensa.Cells[SGricompensa.Col,SGricompensa.Row]:= DataRicompensa.Text;
  if SGricompensa.Cells[0,SGricompensa.Row]= '' then
     SGricompensa.Cells[0,SGricompensa.Row]:= 'M';
  SGricompensa.SetFocus;
end;

procedure TFrRicompense.DataRicompensaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
   if DataRicompensa.dataok then
      begin
        SGricompensa.Col:= 4;
        SGricompensa.SetFocus;
      end;
end;


procedure TFrRicompense.KSAUTORITAChange(Sender: TObject);
begin
  SGricompensa.Cells[4,SGricompensa.Row]:= KSAUTORITA.Text;
  SGricompensa.Cells[6,SGricompensa.Row]:= KSAUTORITA.ValueLookField;
  SGricompensa.Col:= 2;
  SGricompensa.Cells[2,SGricompensa.Row]:= SGricompensa.Cells[2,SGricompensa.Row];
  SGricompensa.SetFocus;
end;

procedure TFrRicompense.KSricompensaChange(Sender: TObject);
begin
   SGricompensa.Cells[1,SGricompensa.Row]:= KSricompensa.Text;
   SGricompensa.Cells[7,SGricompensa.Row]:= KSricompensa.ValueLookField;
   SGricompensa.Col:= 2;
   SGricompensa.Cells[SGricompensa.Col,SGricompensa.Row]:= SGricompensa.Cells[SGricompensa.Col,SGricompensa.Row];
   SGricompensa.SetFocus;
end;

procedure TFrRicompense.SBeditClick(Sender: TObject);
begin
  SGricompensa.Options:= SGricompensa.Options + [goEditing];
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrRicompense.SGricompensaValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGricompensa.Cells[0,aRow] = '') then
     SGricompensa.Cells[0,aRow]:= 'M';
end;

procedure TFrRicompense.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSAUTORITA.ReadOnly:= not button; // abilito o disabilito la gradi
  KSricompensa.ReadOnly:= not button; //abilito o disabilito ricompense
  DataRicompensa.ReadOnly:= not button; // e la data Ricompensa
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGricompensa.Options:= SGricompensa.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
    end
  else
    begin
      SGricompensa.Options:= SGricompensa.Options - [goEditing];
      FmDatiPersonali.WTnav.Enabled:= True;
    end;
end;

procedure TFrRicompense.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGricompensa.RowCount - 1 do
    begin
      if SGricompensa.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_ricompense(' + '''' + SGricompensa.Cells[0,riga]  + ''',';
          if SGricompensa.Cells[5,riga] = '' then  //idricompense
            st:= st + '0,'
          else
            st:= st +  SGricompensa.Cells[5,riga] + ',';

          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

          if SGricompensa.Cells[2,riga] = '' then  //NUMERO DETERMINA
             st:= st + 'null,'
          else
             st:= st + SGricompensa.Cells[2,riga] + ',';

          if SGricompensa.Cells[3,riga] = '' then  // DATA RICOMPENSA
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGricompensa.Cells[3,riga],True) + ',';

          if SGricompensa.Cells[6,riga] = '' then
             st:= st + 'null,'
          else
             st:= st + SGricompensa.Cells[6,riga] + ',';      //KSAUTORITA

          st:= st + SGricompensa.Cells[7,riga] + ')';      //KSRICOMPENSA
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
       //Memo1.Text:=st;
  LeggeDati;
end;

procedure TFrRicompense.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= ' SELECT * FROM VIEW_RICOMPENSE r  ';
 st:= st + ' where r.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 SGricompensa.Clear;
 SGricompensa.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGricompensa.RowCount:= SGricompensa.RowCount + 1;
          riga:= SGricompensa.RowCount - 1;
          SGricompensa.Cells[1,riga] := dm.DSetTemp.FieldByName('RICOMPENSA').AsString;
          SGricompensa.Cells[2,riga] := dm.DSetTemp.FieldByName('DETERMINA').AsString;
          SGricompensa.Cells[3,riga] := dm.DSetTemp.FieldByName('DATARICOMPENSA').AsString;
          SGricompensa.Cells[4,riga] := dm.DSetTemp.FieldByName('AUTORITA').AsString;
          SGricompensa.Cells[5,riga] := dm.DSetTemp.FieldByName('IDLISTARICOMPENSE').AsString;
          SGricompensa.Cells[6,riga] := dm.DSetTemp.FieldByName('KSAUTORITA').AsString;
          SGricompensa.Cells[7,riga] := dm.DSetTemp.FieldByName('KSRICOMPENSA').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrRicompense.Esegui(grant: integer);
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

