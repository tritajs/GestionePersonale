unit frvalutazione_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql,  WDateEdit, Dialogs,
  Graphics, EditBtn, StdCtrls;


type

  { TFrValutazione }

  TFrValutazione = class(TFrame)
    AL: TWDateEdit;
    DAL: TWDateEdit;
    ksmotivo: TWTComboBoxSql;
    ksvalutazione: TWTComboBoxSql;
    Label1: TLabel;
    Image1: TImage;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGValutazione: TStringGrid;
    kstipodc: TWTComboBoxSql;
    scadenzadc: TWDateEdit;
    procedure alEditingDone(Sender: TObject);
    procedure alKeyPress(Sender: TObject; var Key: char);
    procedure dmorteKeyPress(Sender: TObject; var Key: char);
    procedure ksmotivoChange(Sender: TObject);
    procedure kstipodcChange(Sender: TObject);
    procedure dalEditingDone(Sender: TObject);
    procedure dalKeyPress(Sender: TObject; var Key: char);
    procedure ksvalutazioneChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGValutazioneCheckboxToggled(sender: TObject; aCol,
      aRow: Integer; aState: TCheckboxState);
    procedure SGValutazionePrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGValutazioneSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGValutazioneValidateEntry(sender: TObject; aCol, aRow: Integer;
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

{ TFrValutazione }


procedure TFrValutazione.SGValutazionePrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGValutazione.Cells[0,aRow] = 'C') then
        SGValutazione.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrValutazione.SGValutazioneSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
begin
  if (aCol=5) and (aRow>0) then begin  //tipo documentazione
    kstipodc.BoundsRect:=SGValutazione.CellRect(aCol,aRow);
    kstipodc.Text:=SGValutazione.Cells[SGValutazione.Col,SGValutazione.Row];
    Editor:= kstipodc;
  end;
  if (aCol=6) and (aRow>0) then begin  //dal
    dal.BoundsRect:=SGValutazione.CellRect(aCol,aRow);
    dal.Text:=SGValutazione.Cells[SGValutazione.Col,SGValutazione.Row];
    Editor:=dal;
  end;
  if (aCol=7) and (aRow>0) then begin  //al
    al.BoundsRect:= SGValutazione.CellRect(aCol,aRow);
    al.Text:=SGValutazione.Cells[SGValutazione.Col,SGValutazione.Row];
    Editor:=al;
  end;
  if (aCol=8) and (aRow>0) then begin  // motivo documentazione
    ksmotivo.BoundsRect:=SGValutazione.CellRect(aCol,aRow);
    ksmotivo.Text:= SGValutazione.Cells[SGValutazione.Col,SGValutazione.Row];
    Editor:= ksmotivo;
  end;
  if (aCol=9) and (aRow>0) then begin  //valutazione
    ksvalutazione.BoundsRect:= SGValutazione.CellRect(aCol,aRow);
    ksvalutazione.Text:=SGValutazione.Cells[SGValutazione.Col,SGValutazione.Row];
    Editor:= ksvalutazione;
  end;
end;

procedure TFrValutazione.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGValutazione.Options:= SGValutazione.Options + [goEditing];
   SGValutazione.RowCount:= SGValutazione.RowCount + 1;
   SGValutazione.Cells[0,SGValutazione.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGValutazione.Cells[10,SGValutazione.RowCount - 1]:= '1';
   scadenzadc.ReadOnly:= False; // abilito la data scadenza prossima documentazione
   SGValutazione.Col:= 1;
end;

procedure TFrValutazione.SBokClick(Sender: TObject);
begin
  SGValutazione.Col:=1;
  SalvaDati;
  Operazione:= FtView;
  VisibleTastiConferma(False);
end;

procedure TFrValutazione.SGValutazioneCheckboxToggled(sender: TObject; aCol,
  aRow: Integer; aState: TCheckboxState);
begin
  if SGValutazione.Cells[0,SGValutazione.Row]= '' then
    SGValutazione.Cells[0,SGValutazione.Row]:= 'M';
end;


procedure TFrValutazione.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGValutazione.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGValutazione.Cells[2,SGValutazione.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGValutazione.DeleteRow(SGValutazione.Row)
        else   // fase di modifica
         begin
           SGValutazione.Cells[0,SGValutazione.Row]:= 'C';
           VisibleTastiConferma(True);
           SGValutazione.Refresh;
         end;
      end;
   end;

end;

procedure TFrValutazione.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrValutazione.dalEditingDone(Sender: TObject);
begin
 SGValutazione.Cells[6,SGValutazione.Row]:= dal.Text;
 if SGValutazione.Cells[0,SGValutazione.Row]= '' then
   SGValutazione.Cells[0,SGValutazione.Row]:= 'M';
 SGValutazione.Col:= 6;
end;

procedure TFrValutazione.dalKeyPress(Sender: TObject; var Key: char);
begin
 if Key = #13 then
  if DAL.dataok then
    begin
       SGValutazione.Col:= 7;
       SGValutazione.SetFocus;
    end;
end;

procedure TFrValutazione.ksvalutazioneChange(Sender: TObject);
begin
  SGValutazione.Cells[9,SGValutazione.Row]:= ksvalutazione.Text;
  SGValutazione.Cells[4,SGValutazione.Row]:= ksvalutazione.ValueLookField;
  SGValutazione.Col:= 10;
  SGValutazione.Cells[10,SGValutazione.Row]:= SGValutazione.Cells[10,SGValutazione.Row];
  SGValutazione.SetFocus;
end;

procedure TFrValutazione.kstipodcChange(Sender: TObject);
begin
  SGValutazione.Cells[5,SGValutazione.Row]:= kstipodc.Text;
  SGValutazione.Cells[2,SGValutazione.Row]:= kstipodc.ValueLookField;
  SGValutazione.Col:= 6;
  SGValutazione.Cells[6,SGValutazione.Row]:= SGValutazione.Cells[6,SGValutazione.Row];
  SGValutazione.SetFocus;
end;


procedure TFrValutazione.ksmotivoChange(Sender: TObject);
begin
  SGValutazione.Cells[8,SGValutazione.Row]:= ksmotivo.Text;
  SGValutazione.Cells[3,SGValutazione.Row]:= ksmotivo.ValueLookField;
  SGValutazione.Col:= 9;
  SGValutazione.Cells[9,SGValutazione.Row] := SGValutazione.Cells[9,SGValutazione.Row];
  SGValutazione.SetFocus;
end;

procedure TFrValutazione.alKeyPress(Sender: TObject; var Key: char);
begin
    if Key = #13 then
    begin
       SGValutazione.Col:= 8;
       SGValutazione.SetFocus;
    end;
end;


procedure TFrValutazione.dmorteKeyPress(Sender: TObject; var Key: char);
begin
    if Key = #13 then
    begin
       SGValutazione.Col:= 9;
       SGValutazione.SetFocus;
    end;
end;

procedure TFrValutazione.alEditingDone(Sender: TObject);
begin
 SGValutazione.Cells[7,SGValutazione.Row]:= al.Text;
 scadenzadc.Date:= IncMonth(al.Date,12);
 if SGValutazione.Cells[0,SGValutazione.Row]= '' then
   SGValutazione.Cells[0,SGValutazione.Row]:= 'M';
 SGValutazione.Col:= 7;
end;

procedure TFrValutazione.SBeditClick(Sender: TObject);
begin
  SGValutazione.Options:= SGValutazione.Options + [goEditing];;
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrValutazione.SGValutazioneValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGValutazione.Cells[0,aRow] = '') then
    begin
      SGValutazione.Cells[0,aRow]:= 'M';
       scadenzadc.ReadOnly:= False; // abilito la data scadenza prossima documentazione
    end;
end;

procedure TFrValutazione.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  kstipodc.ReadOnly:= not button;      // abilito Combox tipo documentazione
  ksmotivo.ReadOnly:= not button;      // abilito Combox motivo documentazione
  ksvalutazione.ReadOnly:= not button; // abilito Combox valutazione
  dal.ReadOnly:= not button;        // abilito dal
  al.ReadOnly:= not button;         // abilito data matrimonio;
  scadenzadc.ReadOnly:= True; // disabilito la data scadenza prossima documentazione
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGValutazione.Options:= SGValutazione.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
      FmDatiPersonali.Pdati.TabStop:= True;
    end
  else
    begin
     SGValutazione.Options:= SGValutazione.Options - [goEditing];
     FmDatiPersonali.WTnav.Enabled:= True;
     FmDatiPersonali.Pdati.TabStop:= False;
    end;
end;

procedure TFrValutazione.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGValutazione.RowCount - 1 do
    begin
      if SGValutazione.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_listadoccar(' + '''' + SGValutazione.Cells[0,riga]  + ''',';

           if SGValutazione.Cells[1,riga] = '' then  //idlistadc
            st:= st + '0,'
          else
            st:= st +  SGValutazione.Cells[1,riga] + ',';
          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare
          if SGValutazione.Cells[2,riga] = '' then  //KSTIPODC
            st:= st + '0,'
          else
            st:= st +  SGValutazione.Cells[2,riga] + ',';
          if SGValutazione.Cells[6,riga] = '' then  // DATA DAL
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGValutazione.Cells[6,riga],True) + ',';
          if SGValutazione.Cells[7,riga] = '' then  // DATA AL
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGValutazione.Cells[7,riga],True) + ',';
          if SGValutazione.Cells[3,riga] = '' then  //KSMOTIVO
            st:= st + '0,'
          else
            st:= st +  SGValutazione.Cells[3,riga] + ',';

          if SGValutazione.Cells[4,riga] = '' then  //KSVALUTAZIONE
            st:= st + '0,'
          else
            st:= st +  SGValutazione.Cells[4,riga] + ',';

          st:= st +   SGValutazione.Cells[10,riga] + ',';   //da trasmettere

          if  operazione = FtInserimento then
            begin
              if MessageDlg('Attenzione!', ' confermi il ' + scadenzadc.Text + ' come nuova scadenza?' ,  mtConfirmation,
                 [mbYes, mbNo],0) = mrNo then
                 st:= st + 'null)'
              else
                 st:= st +  DateDB(scadenzadc.Text,True) + ')';
            end
          else
            st:= st +  DateDB(scadenzadc.Text,True) + ')';
           dm.QTemp.SQL.Text:= st;
           dm.QTemp.Open();
           dm.TR.CommitRetaining;
           FmDatiPersonali.ECdati.ReadDate;
        end;
    end;
   LeggeDati;
end;

procedure TFrValutazione.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= ' SELECT * from view_valutazioni a ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
 st:= st + ' order by a.al ';


 SGValutazione.Clear;
  SGValutazione.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGValutazione.RowCount:= SGValutazione.RowCount + 1;
          riga:= SGValutazione.RowCount - 1;
          SGValutazione.Cells[1,riga] := dm.DSetTemp.FieldByName('idlistadc').AsString;
          SGValutazione.Cells[2,riga] := dm.DSetTemp.FieldByName('kstipodc').AsString;
          SGValutazione.Cells[3,riga] := dm.DSetTemp.FieldByName('ksmotivo').AsString;
          SGValutazione.Cells[4,riga] := dm.DSetTemp.FieldByName('ksvalutazione').AsString;
          SGValutazione.Cells[5,riga]  := dm.DSetTemp.FieldByName('tipodoc').AsString;
          SGValutazione.Cells[6,riga] := dm.DSetTemp.FieldByName('dal').AsString;
          SGValutazione.Cells[7,riga] := dm.DSetTemp.FieldByName('al').AsString;
          SGValutazione.Cells[8,riga] := dm.DSetTemp.FieldByName('motivo').AsString;
          SGValutazione.Cells[9,riga] := dm.DSetTemp.FieldByName('valutazione').AsString;
          SGValutazione.Cells[10,riga] := dm.DSetTemp.FieldByName('datrasmettere').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
   scadenzadc.Text:=  FmDatiPersonali.scadenzadc.Text;
end;

procedure TFrValutazione.Esegui(grant: integer);
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

