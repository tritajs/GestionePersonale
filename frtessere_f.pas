unit frtessere_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  StdCtrls;


type

  { TFrTessere }

  TFrTessere = class(TFrame)
    datarilascio: TWDateEdit;
    datascadenza: TWDateEdit;
    Image1: TImage;
    KSparentela: TWTComboBoxSql;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGTessere: TStringGrid;
    procedure datarilascioEditingDone(Sender: TObject);
    procedure datarilascioExit(Sender: TObject);
    procedure datarilascioKeyPress(Sender: TObject; var Key: char);
    procedure datascadenzaEditingDone(Sender: TObject);
    procedure KSparentelaChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGTessereEditingDone(Sender: TObject);
    procedure SGTesserePrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGTessereSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGTessereValidateEntry(sender: TObject; aCol, aRow: Integer;
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

{ TFrTessere }


procedure TFrTessere.SGTesserePrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGTessere.Cells[0,aRow] = 'C') then
        SGTessere.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrTessere.SGTessereSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
  Var anno:smallint;
begin
  if (aCol=3) and (aRow>0) then begin  //datarilascio
     datarilascio.BoundsRect:=SGTessere.CellRect(aCol,aRow);
     datarilascio.Text:=SGTessere.Cells[SGTessere.Col,SGTessere.Row];
     Editor:=datarilascio;
  end;
  if (aCol=4) and (aRow>0) then begin  //datascadenza
    datascadenza.BoundsRect:=SGTessere.CellRect(aCol,aRow);
    datascadenza.Text:=SGTessere.Cells[SGTessere.Col,SGTessere.Row];
    if (Length(Trim(datarilascio.Text))= 10) and (operazione in  [FtInserimento,FtModifica]) then
    begin
      if SGTessere.Cells[1,SGTessere.Row] = 'GF' then
        anno:= StrToInt(Copy(SGTessere.Cells[3,SGTessere.Row],7,4)) + 6
      else
        anno:= StrToInt(Copy(SGTessere.Cells[3,SGTessere.Row],7,4)) + 10;

      SGTessere.Cells[4,SGTessere.Row]:= Copy(SGTessere.Cells[3,SGTessere.Row],1,6) + IntToStr(anno);
    end;
    Editor:=datascadenza;
  end;
  if (aCol=6) and (aRow>0) then begin  //KSparentela
    KSparentela.BoundsRect:=SGTessere.CellRect(aCol,aRow);
    KSparentela.Text:=SGTessere.Cells[SGTessere.Col,SGTessere.Row];
    Editor:=KSparentela;
  end;

end;

procedure TFrTessere.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGTessere.Options:= SGTessere.Options + [goEditing];
   SGTessere.RowCount:= SGTessere.RowCount + 1;
   SGTessere.Cells[0,SGTessere.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGTessere.Col:= 1;
end;

procedure TFrTessere.SBokClick(Sender: TObject);
begin
  SGTessere.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;

procedure TFrTessere.SGTessereEditingDone(Sender: TObject);
begin
  if SGTessere.col = 1 then
    SGTessere.col := 2;

end;


procedure TFrTessere.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGTessere.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGTessere.Cells[2,SGTessere.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGTessere.DeleteRow(SGTessere.Row)
        else   // fase di modifica
         begin
           SGTessere.Cells[0,SGTessere.Row]:= 'C';
           VisibleTastiConferma(True);
           SGTessere.Refresh;
         end;
      end;
   end;

end;

procedure TFrTessere.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrTessere.datascadenzaEditingDone(Sender: TObject);
begin
 SGTessere.Cells[4,SGTessere.Row]:= datascadenza.Text;
 if SGTessere.Cells[0,SGTessere.Row]= '' then
   SGTessere.Cells[0,SGTessere.Row]:= 'M';
 SGTessere.Col:= 4;
end;


procedure TFrTessere.KSparentelaChange(Sender: TObject);
begin
  SGTessere.Cells[SGTessere.Col,SGTessere.Row]:= KSparentela.Text;
  SGTessere.Cells[7,SGTessere.Row]:= KSparentela.ValueLookField;
  SGTessere.Col:= 2;
  SGTessere.Cells[2,SGTessere.Row]:= SGTessere.Cells[2,SGTessere.Row];
  SGTessere.SetFocus;
end;


procedure TFrTessere.datarilascioEditingDone(Sender: TObject);
begin
 SGTessere.Cells[3,SGTessere.Row]:= datarilascio.Text;
 if SGTessere.Cells[0,SGTessere.Row]= '' then
   SGTessere.Cells[0,SGTessere.Row]:= 'M';
 SGTessere.Col:= 3;
end;

procedure TFrTessere.datarilascioExit(Sender: TObject);
Var anno:integer;
begin
 if SGTessere.Cells[1,SGTessere.Row] = 'GF' then
      anno:= StrToInt(Copy(SGTessere.Cells[3,SGTessere.Row],7,4)) + 6
  else
     anno:= StrToInt(Copy(SGTessere.Cells[3,SGTessere.Row],7,4)) + 10;
   SGTessere.Cells[4,SGTessere.Row]:= Copy(SGTessere.Cells[3,SGTessere.Row],1,6) + IntToStr(anno);
end;

procedure TFrTessere.datarilascioKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    if datarilascio.dataok then
      begin
        SGTessere.Col:= 4;
        SGTessere.SetFocus;
     end;
end;


procedure TFrTessere.SBeditClick(Sender: TObject);
begin
  SGTessere.Options:= SGTessere.Options + [goEditing];;
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrTessere.SGTessereValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGTessere.Cells[0,aRow] = '') then
     SGTessere.Cells[0,aRow]:= 'M';
end;

procedure TFrTessere.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  datascadenza.ReadOnly:= not button; // abilito data scadenza
  datarilascio.ReadOnly:= not button; // abilito data rilascio;
  KSparentela.ReadOnly:= not button; // abiliti KSparentela
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGTessere.Options:= SGTessere.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
      FmDatiPersonali.Pdati.TabStop:= True;
    end
  else
    begin
     SGTessere.Options:= SGTessere.Options - [goEditing];
     FmDatiPersonali.WTnav.Enabled:= True;
     FmDatiPersonali.Pdati.TabStop:= False;
    end;
end;


procedure TFrTessere.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGTessere.RowCount - 1 do
    begin
      if SGTessere.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from AGGIORNAMENTO_TESSERE(' + '''' + SGTessere.Cells[0,riga]  + ''',';

           if SGTessere.Cells[5,riga] = '' then  // IDLISTATESSERA
            st:= st + '0,'
          else
            st:= st +  SGTessere.Cells[5,riga] + ',';

            st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

          if SGTessere.Cells[1,riga] = '' then  //tipo tessera
            st:= st + 'null,'
          else
            st:= st + '''' +  SGTessere.Cells[1,riga] + ''',';

          if SGTessere.Cells[2,riga] = '' then  //numero
            st:= st + 'null,'
          else
            st:= st +  SGTessere.Cells[2,riga] + ',';

          if SGTessere.Cells[3,riga] = '' then  // DATA rilascio
            st:= st + 'null,'
          else
            st:= st + DateDB(SGTessere.Cells[3,riga],True) + ',';
          if SGTessere.Cells[4,riga] = '' then  // DATA datascadenza
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGTessere.Cells[4,riga],True) + ',';
          if SGTessere.Cells[7,riga] = '' then  // KSparentela
            st:= st + 'null)'
          else
            st:= st + '''' +  SGTessere.Cells[7,riga] + ''')';

          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
   LeggeDati;

end;



procedure TFrTessere.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 // preparo il combox con i nominativi dei parenti del militare
 st:= ' SELECT a.IDPARENTELE, p.parentela ||'' - ''|| a.COGNOME ||'' ''|| a.NOME  as PARENTE ';
 st:= st + ' FROM LISTAPARENTELE a left join PARENTELE p on (a.ksparentela = p.idparentele) ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
 KSparentela.Sql.Text:= st;



 st:= ' SELECT a.IDLISTATESSERA,a.TIPOTESSERA,a.NUMERO,a.DATARILASCIO,a.DATASCADENZA,a.KSPARENTE,a2.PARENTELA ';
 st:= st + '|| '': '' || a1.COGNOME  || '' '' ||a1.NOME as PARENTE FROM LISTATESSERE a ';
 st:= st + 'left join LISTAPARENTELE a1 on (a.KSPARENTE = a1.IDPARENTELE) ';
 st:= st + 'left join PARENTELE a2 on (a1.KSPARENTELA = a2.IDPARENTELE) ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
 SGTessere.Clear;
 SGTessere.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGTessere.RowCount:= SGTessere.RowCount + 1;
          riga:= SGTessere.RowCount - 1;
          SGTessere.Cells[1,riga] := dm.DSetTemp.FieldByName('TIPOTESSERA').AsString;
          SGTessere.Cells[2,riga] := dm.DSetTemp.FieldByName('NUMERO').AsString;
          SGTessere.Cells[3,riga] := dm.DSetTemp.FieldByName('DATARILASCIO').AsString;
          SGTessere.Cells[4,riga] := dm.DSetTemp.FieldByName('DATASCADENZA').AsString;
          SGTessere.Cells[5,riga] := dm.DSetTemp.FieldByName('IDLISTATESSERA').AsString;
          SGTessere.Cells[6,riga] := dm.DSetTemp.FieldByName('PARENTE').AsString;
          SGTessere.Cells[7,riga] := dm.DSetTemp.FieldByName('KSPARENTE').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrTessere.Esegui(grant: integer);
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

