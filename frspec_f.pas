unit frSpec_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  Calendar;

type

  { TFrSpec }

  TFrSpec = class(TFrame)
    DateEs: TWDateEdit;
    DateSpec: TWDateEdit;
    Image1: TImage;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGspec: TStringGrid;
    KSspec: TWTComboBoxSql;
    procedure DateEsEditingDone(Sender: TObject);
    procedure DateSpecEditingDone(Sender: TObject);
    procedure DateSpecKeyPress(Sender: TObject; var Key: char);
    procedure KSspecChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGspecGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure SGspecPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGspecSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure SGspecSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGspecValidateEntry(sender: TObject; aCol, aRow: Integer;
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

{ TFrSpec }

procedure TFrSpec.SGspecGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
   if (ARow > 0) then
   if (ACol = 3) or (ACol = 4) then
     value := '!99/99/0000;1;_';
end;

procedure TFrSpec.SGspecPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGspec.Cells[0,aRow] = 'C') then
        SGspec.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrSpec.SGspecSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if (Acol = 2) or (Acol = 5) then
    CanSelect := False;
end;

procedure TFrSpec.SGspecSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
   if (aCol=3) and (aRow>0) then begin
    DateSpec.BoundsRect:=SGspec.CellRect(aCol,aRow);
    DateSpec.Text:=SGspec.Cells[SGspec.Col,SGspec.Row];
    Editor:=DateSpec;
  end;

   if (aCol=4) and (aRow>0) then begin
    DateEs.BoundsRect:=SGspec.CellRect(aCol,aRow);
    DateEs.Text:=SGspec.Cells[SGspec.Col,SGspec.Row];
    Editor:= DateEs;
  end;



  if (aCol=1) and (aRow>0) then begin
    KSspec.BoundsRect:=SGspec.CellRect(aCol,aRow);
    KSspec.Text:=SGspec.Cells[SGspec.Col,SGspec.Row];
    Editor:= KSspec;
  end;



end;

procedure TFrSpec.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGspec.Options:= SGspec.Options + [goEditing];;
   SGspec.RowCount:= SGspec.RowCount + 1;
   SGspec.Cells[0,SGspec.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGspec.Cells[1,SGspec.RowCount - 1]:= '';
end;

procedure TFrSpec.SBokClick(Sender: TObject);
begin
  SGspec.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;


procedure TFrSpec.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGspec.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGspec.Cells[0,SGspec.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGspec.DeleteRow(SGspec.Row)
        else   // fase di modifica
         begin
           SGspec.Cells[0,SGspec.Row]:= 'C';
           SGspec.Repaint;
           VisibleTastiConferma(True);
         end;
      end;
   end;

end;

procedure TFrSpec.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrSpec.DateSpecEditingDone(Sender: TObject);
begin
  SGspec.Cells[SGspec.Col,SGspec.Row]:= DateSpec.Text;
  if SGspec.Cells[0,SGspec.Row]= '' then
     SGspec.Cells[0,SGspec.Row]:= 'M';
  SGspec.SetFocus;
end;

procedure TFrSpec.DateSpecKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
   if DateSpec.dataok then
      begin
        SGspec.Col:= 4;
        SGspec.SetFocus;
      end;
end;

procedure TFrSpec.DateEsEditingDone(Sender: TObject);
begin
  SGspec.Cells[SGspec.Col,SGspec.Row]:= DateEs.Text;
  if SGspec.Cells[0,SGspec.Row]= '' then
     SGspec.Cells[0,SGspec.Row]:= 'M';
  SGspec.Col:= 4;
  SGspec.SetFocus;
end;



procedure TFrSpec.KSspecChange(Sender: TObject);
begin
  SGspec.Cells[SGspec.Col,SGspec.Row]:= KSspec.Text;
  SGspec.Cells[7,SGspec.Row]:= KSspec.ValueLookField;
  SGspec.Cells[2,SGspec.Row]:= KSspec.FindField('CODSPEC');
  SGspec.Cells[5,SGspec.Row]:= KSspec.FindField('SPEQUAB');
  SGspec.Col:= 3;
  SGspec.Cells[3,SGspec.Row]:= SGspec.Cells[3,SGspec.Row];
  SGspec.SetFocus;
//  SGspec.Cells[SGspec.Col,SGspec.Row]:= '';
end;


procedure TFrSpec.SBeditClick(Sender: TObject);
begin
  SGspec.Options:= SGspec.Options + [goEditing];
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrSpec.SGspecValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGspec.Cells[0,aRow] = '') then
     SGspec.Cells[0,aRow]:= 'M';
end;

procedure TFrSpec.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSspec.ReadOnly:= not button; // abilito o disabilito la gradi
  DateSpec.ReadOnly:= not button; // e la data Specializzazione
  DateEs.ReadOnly:= not button; // e la data Esonero
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGspec.Options:= SGspec.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
    end
  else
    begin
      SGspec.Options:= SGspec.Options - [goEditing];
      FmDatiPersonali.WTnav.Enabled:= True;
    end;
end;

procedure TFrSpec.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGspec.RowCount - 1 do
    begin
      if SGspec.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_spec(' + '''' + SGspec.Cells[0,riga]  + ''',';
          if SGspec.Cells[6,riga] = '' then  //idlistspec
            st:= st + '0,'
          else
            st:= st +  SGspec.Cells[6,riga] + ',';

          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

          st:= st + SGspec.Cells[7,riga] + ',';      //ksspec

          if SGspec.Cells[3,riga] = '' then  // DATA spec
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGspec.Cells[3,riga],True) + ',';

          if SGspec.Cells[4,riga] = '' then  // DATA es
            st:= st + 'null)'
          else
            st:= st +  DateDB(SGspec.Cells[4,riga],True) + ')';
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
   LeggeDati;

end;

procedure TFrSpec.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= ' SELECT * FROM VIEW_SPECIALIZZAZIONI r  ';
 st:= st + ' where r.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 SGspec.Clear;
 SGspec.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGspec.RowCount:= SGspec.RowCount + 1;
          riga:= SGspec.RowCount - 1;
          SGspec.Cells[1,riga] := dm.DSetTemp.FieldByName('SPECIALIZZAZIONE').AsString;
          SGspec.Cells[2,riga] := dm.DSetTemp.FieldByName('CODSPEC').AsString;
          SGspec.Cells[3,riga] := dm.DSetTemp.FieldByName('DATASPEC').AsString;
          SGspec.Cells[4,riga] := dm.DSetTemp.FieldByName('DATAES').AsString;
          SGspec.Cells[5,riga] := dm.DSetTemp.FieldByName('SPEQUAB').AsString;
          SGspec.Cells[6,riga] := dm.DSetTemp.FieldByName('IDLISTASPEC').AsString;
          SGspec.Cells[7,riga] := dm.DSetTemp.FieldByName('KSSPEC').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrSpec.Esegui(grant: integer);
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

