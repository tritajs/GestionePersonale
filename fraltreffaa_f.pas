unit fraltreffaa_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  StdCtrls;


type

  { TFrAltreFFAA }

  TFrAltreFFAA = class(TFrame)
    DAL: TWDateEdit;
    AL: TWDateEdit;
    Image1: TImage;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGaltraFFAA: TStringGrid;
    KSIDFFAA: TWTComboBoxSql;
    procedure ALEditingDone(Sender: TObject);
    procedure ALKeyPress(Sender: TObject; var Key: char);
    procedure KSIDFFAAChange(Sender: TObject);
    procedure DALEditingDone(Sender: TObject);
    procedure DALKeyPress(Sender: TObject; var Key: char);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGaltraFFAAPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGaltraFFAASelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGaltraFFAAValidateEntry(sender: TObject; aCol, aRow: Integer;
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

{ TFrAltreFFAA }


procedure TFrAltreFFAA.SGaltraFFAAPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGaltraFFAA.Cells[0,aRow] = 'C') then
        SGaltraFFAA.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrAltreFFAA.SGaltraFFAASelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
  if (aCol=1) and (aRow>0) then begin  //altra forza armata
    KSIDFFAA.BoundsRect:=SGaltraFFAA.CellRect(aCol,aRow);
    KSIDFFAA.Text:=SGaltraFFAA.Cells[SGaltraFFAA.Col,SGaltraFFAA.Row];
    Editor:= KSIDFFAA;
  end;
  if (aCol=2) and (aRow>0) then begin  //DAL
    DAL.BoundsRect:=SGaltraFFAA.CellRect(aCol,aRow);
    DAL.Text:=SGaltraFFAA.Cells[SGaltraFFAA.Col,SGaltraFFAA.Row];
    Editor:=DAL;
  end;
  if (aCol=3) and (aRow>0) then begin  //AL
    AL.BoundsRect:=SGaltraFFAA.CellRect(aCol,aRow);
    AL.Text:=SGaltraFFAA.Cells[SGaltraFFAA.Col,SGaltraFFAA.Row];
    Editor:=AL;
  end;
end;

procedure TFrAltreFFAA.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGaltraFFAA.Options:= SGaltraFFAA.Options + [goEditing];
   SGaltraFFAA.RowCount:= SGaltraFFAA.RowCount + 1;
   SGaltraFFAA.Cells[0,SGaltraFFAA.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGaltraFFAA.Col:= 1;
end;

procedure TFrAltreFFAA.SBokClick(Sender: TObject);
begin
  SGaltraFFAA.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;


procedure TFrAltreFFAA.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGaltraFFAA.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGaltraFFAA.Cells[2,SGaltraFFAA.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGaltraFFAA.DeleteRow(SGaltraFFAA.Row)
        else   // fase di modifica
         begin
           SGaltraFFAA.Cells[0,SGaltraFFAA.Row]:= 'C';
           VisibleTastiConferma(True);
           SGaltraFFAA.Refresh;
         end;
      end;
   end;

end;

procedure TFrAltreFFAA.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrAltreFFAA.DALEditingDone(Sender: TObject);
begin
 SGaltraFFAA.Cells[2,SGaltraFFAA.Row]:= DAL.Text;
 if SGaltraFFAA.Cells[0,SGaltraFFAA.Row]= '' then
   SGaltraFFAA.Cells[0,SGaltraFFAA.Row]:= 'M';
 SGaltraFFAA.Col:= 2;
end;

procedure TFrAltreFFAA.DALKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    if DAL.dataok then
      begin
        SGaltraFFAA.Col:= 3;
        SGaltraFFAA.SetFocus;
      end;
end;

procedure TFrAltreFFAA.KSIDFFAAChange(Sender: TObject);
begin
  SGaltraFFAA.Cells[SGaltraFFAA.Col,SGaltraFFAA.Row]:= KSIDFFAA.Text;
  SGaltraFFAA.Cells[6,SGaltraFFAA.Row]:= KSIDFFAA.ValueLookField;
  SGaltraFFAA.Col:= 2;
  SGaltraFFAA.Cells[2,SGaltraFFAA.Row]:= SGaltraFFAA.Cells[2,SGaltraFFAA.Row];
  SGaltraFFAA.SetFocus;
end;



procedure TFrAltreFFAA.ALKeyPress(Sender: TObject; var Key: char);
begin
    if Key = #13 then
    begin
       SGaltraFFAA.Col:= 3;
       SGaltraFFAA.SetFocus;
    end;
end;


procedure TFrAltreFFAA.ALEditingDone(Sender: TObject);
begin
 SGaltraFFAA.Cells[3,SGaltraFFAA.Row]:= AL.Text;
 if SGaltraFFAA.Cells[0,SGaltraFFAA.Row]= '' then
   SGaltraFFAA.Cells[0,SGaltraFFAA.Row]:= 'M';
 SGaltraFFAA.Col:= 3;
end;


procedure TFrAltreFFAA.SBeditClick(Sender: TObject);
begin
  SGaltraFFAA.Options:= SGaltraFFAA.Options + [goEditing];;
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrAltreFFAA.SGaltraFFAAValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGaltraFFAA.Cells[0,aRow] = '') then
     SGaltraFFAA.Cells[0,aRow]:= 'M';
end;

procedure TFrAltreFFAA.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSIDFFAA.ReadOnly:= not button; // abilito Combox Parentela
  DAL.ReadOnly:= not button; // abilito DAL
  AL.ReadOnly:= not button; // abilito data matrimonio;
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGaltraFFAA.Options:= SGaltraFFAA.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
      FmDatiPersonali.Pdati.TabStop:= True;
    end
  else
    begin
     SGaltraFFAA.Options:= SGaltraFFAA.Options - [goEditing];
     FmDatiPersonali.WTnav.Enabled:= True;
     FmDatiPersonali.Pdati.TabStop:= False;
    end;
end;

procedure TFrAltreFFAA.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGaltraFFAA.RowCount - 1 do
    begin
      if SGaltraFFAA.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from AGGIORNAMENTO_ALTREFFAA(' + '''' + SGaltraFFAA.Cells[0,riga]  + ''',';

           if SGaltraFFAA.Cells[4,riga] = '' then  // IDLISTAALTRAFFAA
            st:= st + '0,'
          else
            st:= st +  SGaltraFFAA.Cells[4,riga] + ',';

           st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

          if SGaltraFFAA.Cells[6,riga] = '' then  //KSIDFFAA
            st:= st + '0,'
          else
            st:= st +  SGaltraFFAA.Cells[6,riga] + ',';


          if SGaltraFFAA.Cells[2,riga] = '' then  // DATA DAL
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGaltraFFAA.Cells[2,riga],True) + ',';


          if SGaltraFFAA.Cells[3,riga] = '' then  // DATA DAL
            st:= st + 'null)'
          else
            st:= st + DateDB(SGaltraFFAA.Cells[3,riga],True) + ')';

          dm.QTemp.SQL.Text:= st;

          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
   LeggeDati;

end;

procedure TFrAltreFFAA.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= ' SELECT b.DESCRIZIONEFFAA,a.IDLISTAALTRAFFAA, a.KSMILITARE, a.KSIDFFAA, a.DAL, a.AL ';
 st:= st + ' FROM LISTAALTREFFAA a LEFT JOIN ALTREFFAA b ON (a.KSIDFFAA = b.IDFFAA) ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
 SGaltraFFAA.Clear;
 SGaltraFFAA.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGaltraFFAA.RowCount:= SGaltraFFAA.RowCount + 1;
          riga:= SGaltraFFAA.RowCount - 1;
          SGaltraFFAA.Cells[1,riga] := dm.DSetTemp.FieldByName('DESCRIZIONEFFAA').AsString;
          SGaltraFFAA.Cells[2,riga] := dm.DSetTemp.FieldByName('DAL').AsString;
          SGaltraFFAA.Cells[3,riga] := dm.DSetTemp.FieldByName('AL').AsString;
          SGaltraFFAA.Cells[4,riga] := dm.DSetTemp.FieldByName('IDLISTAALTRAFFAA').AsString;
          SGaltraFFAA.Cells[5,riga] := dm.DSetTemp.FieldByName('KSMILITARE').AsString;
          SGaltraFFAA.Cells[6,riga] := dm.DSetTemp.FieldByName('KSIDFFAA').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFrAltreFFAA.Esegui(grant: integer);
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

