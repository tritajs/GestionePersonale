unit frpatenti_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  StdCtrls;


type

  { TFrPatenti }

  TFrPatenti = class(TFrame)
    DATARILASCIO: TWDateEdit;
    DATARINNOVO: TWDateEdit;
    DATASCADENZA: TWDateEdit;
    Image1: TImage;
    KSENTEGDF: TWTComboBoxSql;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGPatenti: TStringGrid;
    KSPATENTE: TWTComboBoxSql;
    procedure DATARINNOVOEditingDone(Sender: TObject);
    procedure DATARINNOVOKeyPress(Sender: TObject; var Key: char);
    procedure DATASCADENZAEditingDone(Sender: TObject);
    procedure DATASCADENZAKeyPress(Sender: TObject; var Key: char);
    procedure KSENTEGDFChange(Sender: TObject);
    procedure KSPATENTEChange(Sender: TObject);
    procedure DATARILASCIOEditingDone(Sender: TObject);
    procedure DATARILASCIOKeyPress(Sender: TObject; var Key: char);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGPatentiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGPatentiSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGPatentiValidateEntry(sender: TObject; aCol, aRow: Integer;
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

{ TFrPatenti }


procedure TFrPatenti.SGPatentiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGPatenti.Cells[0,aRow] = 'C') then
        SGPatenti.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrPatenti.SGPatentiSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
  if (aCol=1) and (aRow>0) then begin  //MODELLO PATENTE
    KSPATENTE.BoundsRect:=SGPatenti.CellRect(aCol,aRow);
    KSPATENTE.Text:=SGPatenti.Cells[SGPatenti.Col,SGPatenti.Row];
    Editor:= KSPATENTE;
  end;
  if (aCol=2) and (aRow>0) then begin  //ENTE EROGATORE
    KSENTEGDF.BoundsRect:=SGPatenti.CellRect(aCol,aRow);
    KSENTEGDF.Text:=SGPatenti.Cells[SGPatenti.Col,SGPatenti.Row];
    Editor:=KSENTEGDF;
  end;
  if (aCol=4) and (aRow>0) then begin  //DATARILASCIO
    DATARILASCIO.BoundsRect:=SGPatenti.CellRect(aCol,aRow);
    DATARILASCIO.Text:=SGPatenti.Cells[SGPatenti.Col,SGPatenti.Row];
    Editor:=DATARILASCIO;
  end;
  if (aCol=5) and (aRow>0) then begin  //DATARINNOVO
    DATARINNOVO.BoundsRect:=SGPatenti.CellRect(aCol,aRow);
    DATARINNOVO.Text:=SGPatenti.Cells[SGPatenti.Col,SGPatenti.Row];
    Editor:=DATARINNOVO;
  end;
  if (aCol=6) and (aRow>0) then begin  //DATASCADENZA
    DATASCADENZA.BoundsRect:=SGPatenti.CellRect(aCol,aRow);
    DATASCADENZA.Text:=SGPatenti.Cells[SGPatenti.Col,SGPatenti.Row];
    Editor:=DATASCADENZA;
  end;
end;

procedure TFrPatenti.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGPatenti.Options:= SGPatenti.Options + [goEditing];
   SGPatenti.RowCount:= SGPatenti.RowCount + 1;
   SGPatenti.Cells[0,SGPatenti.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGPatenti.Col:= 1;
end;

procedure TFrPatenti.SBokClick(Sender: TObject);
begin
  SGPatenti.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;


procedure TFrPatenti.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGPatenti.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGPatenti.Cells[2,SGPatenti.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGPatenti.DeleteRow(SGPatenti.Row)
        else   // fase di modifica
         begin
           SGPatenti.Cells[0,SGPatenti.Row]:= 'C';
           VisibleTastiConferma(True);
           SGPatenti.Refresh;
         end;
      end;
   end;

end;

procedure TFrPatenti.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrPatenti.DATARILASCIOEditingDone(Sender: TObject);
begin
 SGPatenti.Cells[4,SGPatenti.Row]:= DATARILASCIO.Text;
 if SGPatenti.Cells[0,SGPatenti.Row]= '' then
   SGPatenti.Cells[0,SGPatenti.Row]:= 'M';
 SGPatenti.Col:= 4;
end;

procedure TFrPatenti.DATARILASCIOKeyPress(Sender: TObject; var Key: char);
begin
 if Key = #13 then
  if DATARILASCIO.dataok then
    begin
       SGPatenti.Col:= 5;
       SGPatenti.SetFocus;
    end;
end;

procedure TFrPatenti.KSPATENTEChange(Sender: TObject);
begin
  SGPatenti.Cells[1,SGPatenti.Row]:= KSPATENTE.Text;
  SGPatenti.Cells[10,SGPatenti.Row]:= KSPATENTE.ValueLookField;
 // SGPatenti.Cells[2,SGPatenti.Row]:= '';
//  SGPatenti.SetFocus;
  SGPatenti.Col:= 2;
//  SGPatenti.Cells[2,SGPatenti.Row]:= SGPatenti.Cells[2,SGPatenti.Row];
  SGPatenti.SetFocus;
end;



procedure TFrPatenti.DATARINNOVOKeyPress(Sender: TObject; var Key: char);
begin
 if Key = #13 then
  if DATARINNOVO.dataok then
    begin
       SGPatenti.Col:= 6;
       SGPatenti.SetFocus;
    end;
end;

procedure TFrPatenti.DATASCADENZAEditingDone(Sender: TObject);
begin
 SGPatenti.Cells[6,SGPatenti.Row]:= DATASCADENZA.Text;
 if SGPatenti.Cells[0,SGPatenti.Row]= '' then
   SGPatenti.Cells[0,SGPatenti.Row]:= 'M';
 SGPatenti.Col:= 6;
end;

procedure TFrPatenti.DATASCADENZAKeyPress(Sender: TObject; var Key: char);
begin
 if Key = #13 then
  if DATASCADENZA.dataok then
    begin
       SGPatenti.Col:= 7;
       SGPatenti.SetFocus;
    end;
end;

procedure TFrPatenti.KSENTEGDFChange(Sender: TObject);
begin
  SGPatenti.Cells[2,SGPatenti.Row]:= KSENTEGDF.Text;
  SGPatenti.Cells[11,SGPatenti.Row]:= KSENTEGDF.ValueLookField;
  SGPatenti.Col:= 3;

  SGPatenti.SetFocus;
end;

procedure TFrPatenti.DATARINNOVOEditingDone(Sender: TObject);
begin
 SGPatenti.Cells[5,SGPatenti.Row]:= DATARINNOVO.Text;
 if SGPatenti.Cells[0,SGPatenti.Row]= '' then
   SGPatenti.Cells[0,SGPatenti.Row]:= 'M';
 SGPatenti.Col:= 5;
end;


procedure TFrPatenti.SBeditClick(Sender: TObject);
begin
  SGPatenti.Options:= SGPatenti.Options + [goEditing];;
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrPatenti.SGPatentiValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGPatenti.Cells[0,aRow] = '') then
     SGPatenti.Cells[0,aRow]:= 'M';
end;

procedure TFrPatenti.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSPATENTE.ReadOnly:=    not button; // abilito Combox Patenti
  KSENTEGDF.ReadOnly:=    not button; // abilito Combox EntiGdf
  DATARILASCIO.ReadOnly:= not button; // abilito DATA RILASCIO
  DATARINNOVO.ReadOnly:=  not button; // abilito data Rinnovo;
  DATASCADENZA.ReadOnly:= not button; // abilito data Rinnovo;

  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGPatenti.Options:= SGPatenti.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
      FmDatiPersonali.Pdati.TabStop:= True;
    end
  else
    begin
     SGPatenti.Options:= SGPatenti.Options - [goEditing];
     FmDatiPersonali.WTnav.Enabled:= True;
     FmDatiPersonali.Pdati.TabStop:= False;
    end;
end;


procedure TFrPatenti.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGPatenti.RowCount - 1 do
    begin
      if SGPatenti.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from AGGIORNAMENTO_PATENTI(' + '''' + SGPatenti.Cells[0,riga]  + ''',';
           if SGPatenti.Cells[8,riga] = '' then  // IDLISTAPATENTI
            st:= st + '0,'
          else
            st:= st +  SGPatenti.Cells[8,riga] + ',';
          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare
          if SGPatenti.Cells[10,riga] = '' then  //KSPATENTE
            st:= st + '0,'
          else
            st:= st +  SGPatenti.Cells[10,riga] + ',';
          if SGPatenti.Cells[11,riga] = '' then  //KSENTEGDF
            st:= st + '0,'
          else
            st:= st +  SGPatenti.Cells[11,riga] + ',';
          if SGPatenti.Cells[3,riga] = '' then  // NUMEROMOD
            st:= st + 'null,'
          else
            st:= st +  SGPatenti.Cells[3,riga] + ',';
          if SGPatenti.Cells[4,riga] = '' then  // DATA DATARILASCIO
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGPatenti.Cells[4,riga],True) + ',';
          if SGPatenti.Cells[5,riga] = '' then  // DATA RINNOVO
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGPatenti.Cells[5,riga],True) + ',';
          if SGPatenti.Cells[6,riga] = '' then  // DATA SCADENZA
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGPatenti.Cells[6,riga],True) + ',';
          if SGPatenti.Cells[7,riga] = '' then  // NOTE
            st:= st + 'null)'
          else
            st:= st + '''' + StringReplace(SGPatenti.Cells[7,riga],'''','''''',[rfReplaceAll]) + ''')';
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
     //     Memo1.Text:=st;
          dm.TR.CommitRetaining;
        end;
    end;
   LeggeDati;

end;

procedure TFrPatenti.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin

 st:= ' SELECT r.IDLISTAPATENTI, r.KSMILITARE, r.KSPATENTE, r.KSENTEGDF, ';
 st:= st + ' r.NUMEROMOD, r.DATARILASCIO, r.DATARINNOVO, r.DATASCADENZA, r.NOTE, ';
 st:= st + ' p.DESCRIZIONEPATENTE,e.REPARTO ';
 st:= st + ' FROM LISTAPATENTI r left join PATENTI p on (r.KSPATENTE = p.IDPATENTE) ';
 st:= st + ' left join ENTIGDF e on (r.KSENTEGDF = e.IDENTEGDF) ';
 st:= st + ' where r.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
 SGPatenti.Clear;
 SGPatenti.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGPatenti.RowCount:= SGPatenti.RowCount + 1;
          riga:= SGPatenti.RowCount - 1;
          SGPatenti.Cells[1,riga] := dm.DSetTemp.FieldByName('DESCRIZIONEPATENTE').AsString;
          SGPatenti.Cells[2,riga] := dm.DSetTemp.FieldByName('REPARTO').AsString;
          SGPatenti.Cells[3,riga] := dm.DSetTemp.FieldByName('NUMEROMOD').AsString;
          SGPatenti.Cells[4,riga] := dm.DSetTemp.FieldByName('DATARILASCIO').AsString;
          SGPatenti.Cells[5,riga] := dm.DSetTemp.FieldByName('DATARINNOVO').AsString;
          SGPatenti.Cells[6,riga] := dm.DSetTemp.FieldByName('DATASCADENZA').AsString;
          SGPatenti.Cells[7,riga] := dm.DSetTemp.FieldByName('NOTE').AsString;
          SGPatenti.Cells[8,riga] := dm.DSetTemp.FieldByName('IDLISTAPATENTI').AsString;
          SGPatenti.Cells[9,riga] := dm.DSetTemp.FieldByName('KSMILITARE').AsString;
          SGPatenti.Cells[10,riga] := dm.DSetTemp.FieldByName('KSPATENTE').AsString;
          SGPatenti.Cells[11,riga] := dm.DSetTemp.FieldByName('KSENTEGDF').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrPatenti.Esegui(grant: integer);
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

