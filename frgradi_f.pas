unit FrGradi_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  Calendar;

type

  { TFrGradi }

  TFrGradi = class(TFrame)
    DateEdit1: TWDateEdit;
    Image1: TImage;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGgradi: TStringGrid;
    KSgradi: TWTComboBoxSql;
    procedure DateEdit1EditingDone(Sender: TObject);
    procedure KSgradiChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGgradiGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure SGgradiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGgradiSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGgradiValidateEntry(sender: TObject; aCol, aRow: Integer;
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

{ TFrGradi }

procedure TFrGradi.SGgradiGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
   if (ARow > 0) then
   if (ACol = 1) then
     value := '!99/99/0000;1;_';
end;

procedure TFrGradi.SGgradiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGgradi.Cells[2,aRow] = 'C') then
        SGgradi.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrGradi.SGgradiSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
   if (aCol=1) and (aRow>0) then begin
    DateEdit1.BoundsRect:=SGgradi.CellRect(aCol,aRow);
    DateEdit1.Text:=SGgradi.Cells[SGgradi.Col,SGgradi.Row];
    Editor:=DateEdit1;
  end;
  if (aCol=0) and (aRow>0) then begin
    KSgradi.BoundsRect:=SGgradi.CellRect(aCol,aRow);
    KSgradi.Text:=SGgradi.Cells[SGgradi.Col,SGgradi.Row];
    Editor:= KSgradi;
  end;

end;

procedure TFrGradi.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGgradi.Options:= SGgradi.Options + [goEditing];;
   SGgradi.RowCount:= SGgradi.RowCount + 1;
   SGgradi.Cells[2,SGgradi.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGgradi.Cells[0,SGgradi.RowCount - 1]:= '';
end;

procedure TFrGradi.SBokClick(Sender: TObject);
begin
  SGgradi.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;



procedure TFrGradi.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGgradi.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGgradi.Cells[0,SGgradi.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGgradi.DeleteRow(SGgradi.Row)
        else   // fase di modifica
         begin
           SGgradi.Cells[2,SGgradi.Row]:= 'C';
           VisibleTastiConferma(True);
           SGgradi.Refresh;
         end;
      end;
   end;

end;

procedure TFrGradi.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrGradi.DateEdit1EditingDone(Sender: TObject);
begin
  SGgradi.Cells[SGgradi.Col,SGgradi.Row]:= DateEdit1.Text;
  if SGgradi.Cells[2,SGgradi.Row]= '' then
     SGgradi.Cells[2,SGgradi.Row]:= 'M';
  SGgradi.SetFocus;

end;


procedure TFrGradi.KSgradiChange(Sender: TObject);
begin
  SGgradi.Cells[SGgradi.Col,SGgradi.Row]:= KSgradi.Text;
  SGgradi.Cells[3,SGgradi.Row]:= KSgradi.ValueLookField;
  SGgradi.Col:= 1;
  SGgradi.Cells[1,SGgradi.Row]:= SGgradi.Cells[1,SGgradi.Row];
  SGgradi.SetFocus;
end;


procedure TFrGradi.SBeditClick(Sender: TObject);
begin
  SGgradi.Options:= SGgradi.Options + [goEditing];
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrGradi.SGgradiValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGgradi.Cells[2,aRow] = '') then
     SGgradi.Cells[2,aRow]:= 'M';
end;

procedure TFrGradi.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSgradi.ReadOnly:= not button; // abilito o disabilito la gradi
  DateEdit1.ReadOnly:= not button; // e la data
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGgradi.Options:= SGgradi.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
    end
  else
    begin
      SGgradi.Options:= SGgradi.Options - [goEditing];
      FmDatiPersonali.WTnav.Enabled:= True;
    end;
end;

procedure TFrGradi.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGgradi.RowCount - 1 do
    begin
      if SGgradi.Cells[2,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_gradi(' + '''' + SGgradi.Cells[2,riga]  + ''',';
          if SGgradi.Cells[4,riga] = '' then  //idgrado
            st:= st + '0,'
          else
            st:= st +  SGgradi.Cells[4,riga] + ',';

          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

          if SGgradi.Cells[3,riga] = '' then
            st:= st + 'null,'
          else
           st:= st + SGgradi.Cells[3,riga] + ',';
          if SGgradi.Cells[1,riga] = '' then  // DATA GRADO
            st:= st + 'null)'
          else
            st:= st +  DateDB(SGgradi.Cells[1,riga],True) + ')';
            dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
   LeggeDati;
   //aggiorno i dati relativi al grado nella parte superiore
   if SGgradi.RowCount > 0 then
     begin
       FmDatiPersonali.ksgrado.Text:= SGgradi.Cells[0,SGgradi.RowCount -1];
       FmDatiPersonali.datagrado.Text:=  SGgradi.Cells[1,SGgradi.RowCount -1];
     end;
          //FmDatiPersonali.ECdati.ReadDate;


end;

procedure TFrGradi.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= ' SELECT * FROM view_gradi g ';
 st:= st + ' where g.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 SGgradi.Clear;
 SGgradi.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGgradi.RowCount:= SGgradi.RowCount + 1;
          riga:= SGgradi.RowCount - 1;
          SGgradi.Cells[0,riga] := dm.DSetTemp.FieldByName('GRADO').AsString;
          SGgradi.Cells[1,riga] := dm.DSetTemp.FieldByName('DATAGRADO').AsString;
          SGgradi.Cells[3,riga] := dm.DSetTemp.FieldByName('KSGRADO').AsString;
          SGgradi.Cells[4,riga] := dm.DSetTemp.FieldByName('IDGRADO').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrGradi.Esegui(grant: integer);
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

