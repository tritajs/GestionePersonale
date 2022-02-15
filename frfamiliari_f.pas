unit frfamiliari_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  StdCtrls;


type

  { TFrFamiliari }

  TFrFamiliari = class(TFrame)
    dmorte: TWDateEdit;
    dmatrimonio: TWDateEdit;
    nato: TWDateEdit;
    kscomune: TWTComboBoxSql;
    Image1: TImage;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGFamiliari: TStringGrid;
    ksparentela: TWTComboBoxSql;
    procedure dmatrimonioEditingDone(Sender: TObject);
    procedure dmatrimonioKeyPress(Sender: TObject; var Key: char);
    procedure dmorteEditingDone(Sender: TObject);
    procedure dmorteKeyPress(Sender: TObject; var Key: char);
    procedure kscomuneChange(Sender: TObject);
    procedure ksparentelaChange(Sender: TObject);
    procedure natoEditingDone(Sender: TObject);
    procedure natoKeyPress(Sender: TObject; var Key: char);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGFamiliariButtonClick(Sender: TObject; aCol, aRow: Integer);
    procedure SGFamiliariGetCellHint(Sender: TObject; ACol, ARow: Integer;
      var HintText: String);
    procedure SGFamiliariPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGfamiliariSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGfamiliariValidateEntry(sender: TObject; aCol, aRow: Integer;
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

uses main_f, DM_f, fmdatipersonali_f, fmnote_f;

Var operazione: Toperazione;

{ TFrFamiliari }


procedure TFrFamiliari.SGFamiliariPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGFamiliari.Cells[0,aRow] = 'C') then
        SGFamiliari.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;



procedure TFrFamiliari.SGfamiliariSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
  if (aCol=1) and (aRow>0) then begin  //PARENTELE
    ksparentela.BoundsRect:=SGFamiliari.CellRect(aCol,aRow);
    ksparentela.Text:=SGFamiliari.Cells[SGFamiliari.Col,SGFamiliari.Row];
    Editor:= ksparentela;
  end;
  if (aCol=4) and (aRow>0) then begin  //NATO IL
    nato.BoundsRect:=SGFamiliari.CellRect(aCol,aRow);
    nato.Text:=SGFamiliari.Cells[SGFamiliari.Col,SGFamiliari.Row];
    Editor:=nato;
  end;
  if (aCol=5) and (aRow>0) then begin  //COMUNE DI NASCITA
    kscomune.BoundsRect:=SGFamiliari.CellRect(aCol,aRow);
    kscomune.Text:=SGFamiliari.Cells[SGFamiliari.Col,SGFamiliari.Row];
    Editor:= kscomune;
  end;
  if (aCol=9) and (aRow>0) then begin  //DATA MATRIMONIO
    dmatrimonio.BoundsRect:=SGFamiliari.CellRect(aCol,aRow);
    dmatrimonio.Text:=SGFamiliari.Cells[SGFamiliari.Col,SGFamiliari.Row];
    Editor:=dmatrimonio;
  end;
  if (aCol=10) and (aRow>0) then begin  //DATA MORTE
    dmorte.BoundsRect:=SGFamiliari.CellRect(aCol,aRow);
    dmorte.Text:=SGFamiliari.Cells[SGFamiliari.Col,SGFamiliari.Row];
    Editor:=dmorte;
  end;
end;


procedure TFrFamiliari.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGFamiliari.Options:= SGFamiliari.Options + [goEditing];
   SGFamiliari.RowCount:= SGFamiliari.RowCount + 1;
   SGFamiliari.Cells[0,SGFamiliari.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGFamiliari.Col:= 1;
end;

procedure TFrFamiliari.SBokClick(Sender: TObject);
begin
  SGFamiliari.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;

procedure TFrFamiliari.SGFamiliariButtonClick(Sender: TObject; aCol,
  aRow: Integer);
begin
  FmNote.Memo.Text:= SGFamiliari.Cells[11,aRow];
  FmNote.Memo.MaxLength:=199;
  if FmNote.ShowModal = mrOK then
    SGFamiliari.Cells[aCol,aRow]:= FmNote.Memo.Text;
end;

procedure TFrFamiliari.SGFamiliariGetCellHint(Sender: TObject; ACol,
  ARow: Integer; var HintText: String);
begin
  HintText:= SGFamiliari.Cells[ACol,ARow];
end;


procedure TFrFamiliari.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGFamiliari.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGFamiliari.Cells[2,SGFamiliari.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGFamiliari.DeleteRow(SGFamiliari.Row)
        else   // fase di modifica
         begin
           SGFamiliari.Cells[0,SGFamiliari.Row]:= 'C';
           VisibleTastiConferma(True);
           SGFamiliari.Refresh;
         end;
      end;
   end;

end;

procedure TFrFamiliari.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrFamiliari.natoEditingDone(Sender: TObject);
begin
 SGFamiliari.Cells[4,SGFamiliari.Row]:= nato.Text;
 if SGFamiliari.Cells[0,SGFamiliari.Row]= '' then
   SGFamiliari.Cells[0,SGFamiliari.Row]:= 'M';
 SGFamiliari.Col:= 4;
end;

procedure TFrFamiliari.natoKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    if nato.dataok then
    begin
       SGFamiliari.Col:= 5;
       SGFamiliari.SetFocus;
    end;
end;

procedure TFrFamiliari.ksparentelaChange(Sender: TObject);
begin
  SGFamiliari.Cells[SGFamiliari.Col,SGFamiliari.Row]:= ksparentela.Text;
  SGFamiliari.Cells[6,SGFamiliari.Row]:= ksparentela.ValueLookField;
  SGFamiliari.Col:= 2;
  SGFamiliari.Cells[2,SGFamiliari.Row]:= SGFamiliari.Cells[2,SGFamiliari.Row];
  SGFamiliari.SetFocus;
end;


procedure TFrFamiliari.kscomuneChange(Sender: TObject);
begin
  SGFamiliari.Cells[SGFamiliari.Col,SGFamiliari.Row]:= kscomune.Text;
  SGFamiliari.Cells[7,SGFamiliari.Row]:= kscomune.ValueLookField;
  SetFocus;
end;

procedure TFrFamiliari.dmatrimonioKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    if dmatrimonio.dataok then
    begin
       SGFamiliari.Col:= 9;
       SGFamiliari.SetFocus;
    end;
end;

procedure TFrFamiliari.dmorteEditingDone(Sender: TObject);
begin
 SGFamiliari.Cells[10,SGFamiliari.Row]:= dmorte.Text;
 if SGFamiliari.Cells[0,SGFamiliari.Row]= '' then
   SGFamiliari.Cells[0,SGFamiliari.Row]:= 'M';
 SGFamiliari.Col:= 10;
end;

procedure TFrFamiliari.dmorteKeyPress(Sender: TObject; var Key: char);
begin
    if Key = #13 then
    begin
       SGFamiliari.Col:= 10;
       SGFamiliari.SetFocus;
    end;
end;

procedure TFrFamiliari.dmatrimonioEditingDone(Sender: TObject);
begin
 SGFamiliari.Cells[9,SGFamiliari.Row]:= dmatrimonio.Text;
 if SGFamiliari.Cells[0,SGFamiliari.Row]= '' then
   SGFamiliari.Cells[0,SGFamiliari.Row]:= 'M';
 SGFamiliari.Col:= 9;
end;


procedure TFrFamiliari.SBeditClick(Sender: TObject);
begin
  SGFamiliari.Options:= SGFamiliari.Options + [goEditing];;
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrFamiliari.SGfamiliariValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGFamiliari.Cells[0,aRow] = '') then
     SGFamiliari.Cells[0,aRow]:= 'M';
end;

procedure TFrFamiliari.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  ksparentela.ReadOnly:= not button; // abilito Combox Parentela
  kscomune.ReadOnly:= not button; // abilito Combox Comuni
  nato.ReadOnly:= not button; // abilito nato
  dmatrimonio.ReadOnly:= not button; // abilito data matrimonio;
  dmorte.ReadOnly:= not button;   //abilito data morte
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGFamiliari.Options:= SGFamiliari.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
      FmDatiPersonali.Pdati.TabStop:= True;
    end
  else
    begin
     SGFamiliari.Options:= SGFamiliari.Options - [goEditing];
     FmDatiPersonali.WTnav.Enabled:= True;
     FmDatiPersonali.Pdati.TabStop:= False;
    end;
end;


procedure TFrFamiliari.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGFamiliari.RowCount - 1 do
    begin
      if SGFamiliari.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_parentele(' + '''' + SGFamiliari.Cells[0,riga]  + ''',';

           if SGFamiliari.Cells[8,riga] = '' then  //idparentela
            st:= st + '0,'
          else
            st:= st +  SGFamiliari.Cells[8,riga] + ',';

           st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

          if SGFamiliari.Cells[6,riga] = '' then  //parentela
            st:= st + '0,'
          else
            st:= st +  SGFamiliari.Cells[6,riga] + ',';

           st:= st + '''' +  StringReplace(SGFamiliari.Cells[2,riga],'''','''''',[rfReplaceAll]) +  ''','; //COGNOME
           st:= st + '''' +  StringReplace(SGFamiliari.Cells[3,riga],'''','''''',[rfReplaceAll]) +  ''','; //NOME

          if SGFamiliari.Cells[4,riga] = '' then  // DATA nato
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGFamiliari.Cells[4,riga],True) + ',';

          if SGFamiliari.Cells[7,riga] = '' then  //kscomune
            st:= st + '0,'
          else
            st:= st +  SGFamiliari.Cells[7,riga] + ',';

          if SGFamiliari.Cells[9,riga] = '' then  // DATA MATRIMONIO
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGFamiliari.Cells[9,riga],True) + ',';

          if SGFamiliari.Cells[10,riga] = '' then  // DATA MORTE
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGFamiliari.Cells[10,riga],True) + ',';

          if SGFamiliari.Cells[11,riga] = '' then  // note
            st:= st + 'null)'
          else
            st:=  st + '''' +  StringReplace(SGFamiliari.Cells[11,riga],'''','''''',[rfReplaceAll]) + ''')';
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
   LeggeDati;

end;

procedure TFrFamiliari.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
{ st:= ' SELECT P.PARENTELA,a.COGNOME, a.NOME, a.NATO, a.KSCOMUNE,c.COMUNE ||'' (''||c.PR||'')'' as COMUNE ,a.IDPARENTELE, ';
 st:= st + ' a.KSMILITARE, a.KSPARENTELA, a.DMATRIMONIO, a.DMORTE, a.NOTE ';
 st:= st + '  FROM LISTAPARENTELE a left join parentele p on (A.KSPARENTELA = P.IDPARENTELE) ';
 st:= st + '  left join comuni c on (a.KSCOMUNE = c.IDCOMUNE) ';  }
 st:= ' SELECT * FROM VIEW_PARENTI a ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
 SGFamiliari.Clear;
 SGFamiliari.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGFamiliari.RowCount:= SGFamiliari.RowCount + 1;
          riga:= SGFamiliari.RowCount - 1;
          SGFamiliari.Cells[1,riga] := dm.DSetTemp.FieldByName('PARENTELA').AsString;
          SGFamiliari.Cells[2,riga] := dm.DSetTemp.FieldByName('COGNOME').AsString;
          SGFamiliari.Cells[3,riga] := dm.DSetTemp.FieldByName('NOME').AsString;
          SGFamiliari.Cells[4,riga] := dm.DSetTemp.FieldByName('NATO').AsString;
          SGFamiliari.Cells[5,riga] := dm.DSetTemp.FieldByName('COMUNE').AsString;
          SGFamiliari.Cells[6,riga]  := dm.DSetTemp.FieldByName('KSPARENTELA').AsString;
          SGFamiliari.Cells[7,riga] := dm.DSetTemp.FieldByName('KSCOMUNE').AsString;
          SGFamiliari.Cells[8,riga] := dm.DSetTemp.FieldByName('IDPARENTELE').AsString;
          SGFamiliari.Cells[9,riga] := dm.DSetTemp.FieldByName('DMATRIMONIO').AsString;
          SGFamiliari.Cells[10,riga] := dm.DSetTemp.FieldByName('DMORTE').AsString;
          SGFamiliari.Cells[11,riga] := dm.DSetTemp.FieldByName('NOTE').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrFamiliari.Esegui(grant: integer);
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

