unit frcorsi_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql,  Dialogs, Graphics, EditBtn,
  StdCtrls;


type

  { TFrCorsi }

  TFrCorsi = class(TFrame)
    Image1: TImage;
    KSCORSO: TWTComboBoxSql;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGCorsi: TStringGrid;
    KSESITO: TWTComboBoxSql;
    procedure KSCORSOChange(Sender: TObject);
    procedure KSESITOChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGCorsiCheckboxToggled(sender: TObject; aCol, aRow: Integer;
      aState: TCheckboxState);
    procedure SGCorsiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGCorsiSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGCorsiValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    procedure VisibleTastiConferma(button:boolean);
    procedure SalvaDati;
    procedure LeggeDati;
    { private declarations }
  public
    { public declarations }
    Procedure Esegui(grant:integer);
  end;

implementation
{$R *.lfm}

uses main_f, DM_f, fmdatipersonali_f;

Var operazione: Toperazione;

{ TFrCorsi }


procedure TFrCorsi.SGCorsiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGCorsi.Cells[0,aRow] = 'C') then
        SGCorsi.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrCorsi.SGCorsiSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
 if (aCol=2) and (aRow>0) then begin  //KSCORSO
    KSCORSO.BoundsRect:=SGCorsi.CellRect(aCol,aRow);
    KSCORSO.Text:= SGCorsi.Cells[aCol,SGCorsi.Row];
    Editor:= KSCORSO;
  end;
 if (aCol=3) and (aRow>0) then begin  //KSESITO
    KSESITO.BoundsRect:=SGCorsi.CellRect(aCol,aRow);
    KSESITO.Text:= SGCorsi.Cells[aCol,SGCorsi.Row];
    Editor:= KSESITO;
  end;


end;

procedure TFrCorsi.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGCorsi.Options:= SGCorsi.Options + [goEditing];
   SGCorsi.RowCount:= SGCorsi.RowCount + 1;
   SGCorsi.Cells[0,SGCorsi.RowCount - 1]:= 'I';
   SGCorsi.Cells[12,SGCorsi.RowCount - 1]:= '1';
   VisibleTastiConferma(True);
   SGCorsi.Col:= 1;
end;


procedure TFrCorsi.SBokClick(Sender: TObject);
begin
  SGCorsi.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;

procedure TFrCorsi.SGCorsiCheckboxToggled(sender: TObject; aCol, aRow: Integer;
  aState: TCheckboxState);
begin
  if SGCorsi.Cells[0,SGCorsi.Row]= '' then
    SGCorsi.Cells[0,SGCorsi.Row]:= 'M';
end;


procedure TFrCorsi.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGCorsi.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGCorsi.Cells[2,SGCorsi.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGCorsi.DeleteRow(SGCorsi.Row)
        else   // fase di modifica
         begin
           SGCorsi.Cells[0,SGCorsi.Row]:= 'C';
           VisibleTastiConferma(True);
           SGCorsi.Refresh;
         end;
      end;
   end;
end;

procedure TFrCorsi.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;


procedure TFrCorsi.KSCORSOChange(Sender: TObject);
begin
  SGCorsi.Cells[2,SGCorsi.Row]:= KSCORSO.Text;
  SGCorsi.Cells[9,SGCorsi.Row]:= KSCORSO.ValueLookField;
  SGCorsi.Cells[4,SGCorsi.Row]:= KSCORSO.FindField('KSTIPOLOGIA');
  SGCorsi.Cells[5,SGCorsi.Row]:= KSCORSO.FindField('NATURACORSO');
  SGCorsi.Cells[6,SGCorsi.Row]:= KSCORSO.FindField('AREARIFERIMENTO');
  SGCorsi.Cells[7,SGCorsi.Row]:= KSCORSO.FindField('ANNO');
  SGCorsi.Cells[8,SGCorsi.Row]:= KSCORSO.FindField('KSMODALITA');
  SGCorsi.Col:= 3;
  SGCorsi.Cells[3,SGCorsi.Row]:= SGCorsi.Cells[3,SGCorsi.Row];
  SGCorsi.SetFocus;
end;

procedure TFrCorsi.KSESITOChange(Sender: TObject);
begin
  SGCorsi.Cells[3,SGCorsi.Row]:= KSESITO.Text;
  SGCorsi.Cells[10,SGCorsi.Row]:= KSESITO.ValueLookField;
  SGCorsi.Col:= 11;
  SGCorsi.Cells[11,SGCorsi.Row]:= SGCorsi.Cells[11,SGCorsi.Row];
  SGCorsi.SetFocus;
end;



procedure TFrCorsi.SBeditClick(Sender: TObject);
begin
  SGCorsi.Options:= SGCorsi.Options + [goEditing];;
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrCorsi.SGCorsiValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGCorsi.Cells[0,aRow] = '') then
     SGCorsi.Cells[0,aRow]:= 'M';
end;

procedure TFrCorsi.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSCORSO.ReadOnly:= not button; // abilito Combox corso
  KSESITO.ReadOnly:= not button; // abilito Combox esito
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGCorsi.Options:= SGCorsi.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
      FmDatiPersonali.Pdati.TabStop:= True;
    end
  else
    begin
     SGCorsi.Options:= SGCorsi.Options - [goEditing];
     FmDatiPersonali.WTnav.Enabled:= True;
     FmDatiPersonali.Pdati.TabStop:= False;
    end;
end;


procedure TFrCorsi.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGCorsi.RowCount - 1 do
    begin
      if SGCorsi.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_listacorsi(' + '''' + SGCorsi.Cells[0,riga]  + ''',';
          if SGCorsi.Cells[1,riga] = '' then  //idlistacorso
            st:= st + '0,'
          else
            st:= st +  SGCorsi.Cells[1,riga] + ',';
          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare
          if SGCorsi.Cells[9,riga] = '' then  //kscorso
            st:= st + 'null,'
          else
            st:= st +  SGCorsi.Cells[9,riga] + ',';
          if SGCorsi.Cells[10,riga] = '' then  //ksesito
            st:= st + 'null,'
          else
            st:= st +  SGCorsi.Cells[10,riga] + ',';
          if SGCorsi.Cells[11,riga] = '' then  //note
            st:= st + 'null,'
          else
            st:=  st + '''' +  StringReplace(SGCorsi.Cells[11,riga],'''','''''',[rfReplaceAll]) + ''',';
          st:= st +  SGCorsi.Cells[12,riga] + ')';  //DA TRASCRIVERE

          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
   LeggeDati;
end;

procedure TFrCorsi.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= ' SELECT a.IDLISTACORSI,a2.CORSO,a1.ESITOCORSO, ';
 st:= st + ' iif(a2.KSTIPOLOGIA = 0,''CENTRALIZZATO'',''PERIFERICO'') AS TIPOLOGIA, ';
 st:= st + ' a4.NATURACORSO,a3.AREARIFERIMENTO,a2.ANNO, ';
 st:= st + ' iif(a2.KSMODALITA = 0, ''AULA'',''E-LEARNING'') AS MODALITA,  a.KSCORSO, a.KSESITO, ';
 st:= st + ' a.NOTE, a.DATRASCRIVERE ';
 st:= st + ' FROM LISTACORSI a ';
 st:= st + ' left join ESITOCORSO a1 on (a.KSESITO = a1.IDESITOCORSO) ';
 st:= st + ' left join corsi a2 on (a.KSCORSO = a2.idcorso) ';
 st:= st + ' left join AREARIFERIMENTOCORSO a3 on (a2.KSAREARIFERIMENTO = a3.IDAREARIFERIMENTO) ';
 st:= st + ' left join NATURACORSO a4 on (a2.KSNATURA = a4.IDNATURACORSO) ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;

 SGCorsi.Clear;
 SGCorsi.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGCorsi.RowCount:= SGCorsi.RowCount + 1;
          riga:= SGCorsi.RowCount - 1;
          SGCorsi.Cells[1,riga] := dm.DSetTemp.FieldByName('IDLISTACORSI').AsString;
          SGCorsi.Cells[2,riga] := dm.DSetTemp.FieldByName('CORSO').AsString;
          SGCorsi.Cells[3,riga] := dm.DSetTemp.FieldByName('ESITOCORSO').AsString;
          SGCorsi.Cells[4,riga] := Trim(dm.DSetTemp.FieldByName('TIPOLOGIA').AsString);
          SGCorsi.Cells[5,riga] := dm.DSetTemp.FieldByName('NATURACORSO').AsString;
          SGCorsi.Cells[6,riga]  := dm.DSetTemp.FieldByName('AREARIFERIMENTO').AsString;
          SGCorsi.Cells[7,riga] := dm.DSetTemp.FieldByName('ANNO').AsString;
          SGCorsi.Cells[8,riga] := Trim(dm.DSetTemp.FieldByName('MODALITA').AsString);
          SGCorsi.Cells[9,riga] := dm.DSetTemp.FieldByName('KSCORSO').AsString;
          SGCorsi.Cells[10,riga] := dm.DSetTemp.FieldByName('KSESITO').AsString;
          SGCorsi.Cells[11,riga] := dm.DSetTemp.FieldByName('NOTE').AsString;
          SGCorsi.Cells[12,riga] := dm.DSetTemp.FieldByName('DATRASCRIVERE').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrCorsi.Esegui(grant: integer);
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

