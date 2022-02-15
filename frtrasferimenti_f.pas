unit frtrasferimenti_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita, WTComboBoxSql, WDateEdit, Dialogs, Graphics, EditBtn,
  StdCtrls;


type

  { TFrTrasferimenti }

  TFrTrasferimenti = class(TFrame)

    dataarrivo: TWDateEdit;
    Image1: TImage;
    KSarticolazione: TWTComboBoxSql;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGtrasferimenti: TStringGrid;
    KSreparti: TWTComboBoxSql;
    KSTipoTrasf: TWTComboBoxSql;
    decorrenza: TWDateEdit;
    procedure DataArrivoEditingDone(Sender: TObject);
    procedure DataArrivoKeyPress(Sender: TObject; var Key: char);
    procedure DecorrenzaAcceptDate(Sender: TObject; var ADate: TDateTime;
      var AcceptDate: Boolean);
    procedure DecorrenzaEditingDone(Sender: TObject);
    procedure DecorrenzaKeyPress(Sender: TObject; var Key: char);
    procedure KSarticolazioneChange(Sender: TObject);
    procedure KSrepartiChange(Sender: TObject);
    procedure KSTipoTrasfChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGtrasferimentiEditingDone(Sender: TObject);
    procedure SGtrasferimentiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGtrasferimentiSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure SGtrasferimentiValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    procedure VisibleTastiConferma(button:boolean);
    procedure SalvaDati;
    procedure LeggeDati;
    function  CheckDati:boolean; //cControlla i dati
    function IsValidEdit(sd:string):Boolean;
    { private declarations }
  public
    Procedure Esegui(grant:integer);
    { public declarations }
  end;

implementation
{$R *.lfm}

uses main_f, DM_f, fmdatipersonali_f;

Var operazione: Toperazione;

{ TFrTrasferimenti }


procedure TFrTrasferimenti.SGtrasferimentiPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGtrasferimenti.Cells[0,aRow] = 'C') then
        SGtrasferimenti.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFrTrasferimenti.SGtrasferimentiSelectEditor(Sender: TObject; aCol, aRow: Integer;
  var Editor: TWinControl);
Var st:string;
begin
 (*  if (aCol=1) and (aRow>0) then begin
    Decorrenza.BoundsRect:=SGtrasferimenti.CellRect(aCol,aRow);
    Decorrenza.Text:=SGtrasferimenti.Cells[SGtrasferimenti.Col,SGtrasferimenti.Row];
    Editor:=Decorrenza;
  end; *)

  if (aCol=2) and (aRow>0) then begin //DECORRENZA TRASFERIMENTO
    Decorrenza.BoundsRect:=SGtrasferimenti.CellRect(aCol,aRow);
    Decorrenza.Text:=SGtrasferimenti.Cells[SGtrasferimenti.Col,SGtrasferimenti.Row];
    Editor:=Decorrenza;
  end;
  if (aCol=3) and (aRow>0) then begin //DATAARRIVO
    dataarrivo.BoundsRect:=SGtrasferimenti.CellRect(aCol,aRow);
    dataarrivo.Text:=SGtrasferimenti.Cells[SGtrasferimenti.Col,SGtrasferimenti.Row];
    Editor:=dataarrivo;
  end;
  if (aCol=4) and (aRow>0) then begin  //TIPO TRASFERIMENTO
    KSTipoTrasf.BoundsRect:=SGtrasferimenti.CellRect(aCol,aRow);
    KSTipoTrasf.Text:=SGtrasferimenti.Cells[SGtrasferimenti.Col,SGtrasferimenti.Row];
    Editor:= KSTipoTrasf;
  end;
  if (aCol=6) and (aRow>0) then begin  //REPARTI
    KSreparti.BoundsRect:=SGtrasferimenti.CellRect(aCol,aRow);
    KSreparti.Text:=SGtrasferimenti.Cells[SGtrasferimenti.Col,SGtrasferimenti.Row];
    Editor:= KSreparti;
  end;
  if (aCol=7) and (aRow>0) then begin  //ARTICOLAZIONE
    KSarticolazione.BoundsRect:=SGtrasferimenti.CellRect(aCol,aRow);
    KSarticolazione.Text:=SGtrasferimenti.Cells[SGtrasferimenti.Col,SGtrasferimenti.Row];
    st:= 'SELECT * FROM ARTICOLAZIONI WHERE  ';
    st:= st + ' KSREPARTO = ' + SGtrasferimenti.Cells[9,SGtrasferimenti.Row];
    ksarticolazione.Sql.Text:= st;

    Editor:= KSarticolazione;
  end;
end;

procedure TFrTrasferimenti.SBInsClick(Sender: TObject);
begin
   Operazione:= FtInserimento;
   SGtrasferimenti.Options:= SGtrasferimenti.Options + [goEditing];
   SGtrasferimenti.RowCount:= SGtrasferimenti.RowCount + 1;
   SGtrasferimenti.Cells[0,SGtrasferimenti.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGtrasferimenti.Col:= 1;
   SGtrasferimenti.Row:= SGtrasferimenti.RowCount - 1;
end;

procedure TFrTrasferimenti.SBokClick(Sender: TObject);
begin
  if CheckDati then
   begin
     SGtrasferimenti.Col:=1;
     SalvaDati;
     Operazione:= FtView;
     VisibleTastiConferma(False);
   end;
end;



procedure TFrTrasferimenti.SGtrasferimentiEditingDone(Sender: TObject);
begin
 IF SGtrasferimenti.Col = 5 then;
    SGtrasferimenti.Col := 6;
end;



procedure TFrTrasferimenti.SBdelClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGtrasferimenti.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGtrasferimenti.Cells[2,SGtrasferimenti.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if Operazione = FtInserimento then   // fase di inserimento
          SGtrasferimenti.DeleteRow(SGtrasferimenti.Row)
        else   // fase di modifica
         begin
           SGtrasferimenti.Cells[0,SGtrasferimenti.Row]:= 'C';
           VisibleTastiConferma(True);
           SGtrasferimenti.Refresh;
         end;
      end;
   end;

end;

procedure TFrTrasferimenti.SBcancelClick(Sender: TObject);
begin
  Operazione:= FtView;
  LeggeDati;
  VisibleTastiConferma(False);
end;

procedure TFrTrasferimenti.DecorrenzaEditingDone(Sender: TObject);
begin
 SGtrasferimenti.Cells[2,SGtrasferimenti.Row]:= Decorrenza.Text;
 if SGtrasferimenti.Cells[0,SGtrasferimenti.Row]= '' then
   SGtrasferimenti.Cells[0,SGtrasferimenti.Row]:= 'M';
 SGtrasferimenti.Col:= 2;
end;

procedure TFrTrasferimenti.DecorrenzaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    if  decorrenza.dataok  then
      begin
        SGtrasferimenti.Col:= 3;
        SGtrasferimenti.SetFocus;
      end;
end;



procedure TFrTrasferimenti.DataArrivoEditingDone(Sender: TObject);
begin
   if Copy(DataArrivo.Text,1,1) = ' ' then
     SGtrasferimenti.Cells[3,SGtrasferimenti.Row]:= ''
   else
     SGtrasferimenti.Cells[3,SGtrasferimenti.Row]:= dataarrivo.Text;
   if SGtrasferimenti.Cells[0,SGtrasferimenti.Row]= '' then
     SGtrasferimenti.Cells[0,SGtrasferimenti.Row]:= 'M';
   SGtrasferimenti.Col:= 3;
end;

procedure TFrTrasferimenti.DataArrivoKeyPress(Sender: TObject; var Key: char);
begin
    if Key = #13 then
     if dataarrivo.dataok then
       begin
         SGtrasferimenti.Col:= 4;
         SGtrasferimenti.SetFocus;
       end;
end;

procedure TFrTrasferimenti.DecorrenzaAcceptDate(Sender: TObject;
  var ADate: TDateTime; var AcceptDate: Boolean);
begin
 if not IsValidEdit(Decorrenza.Text) then
   AcceptDate:= False;
end;



procedure TFrTrasferimenti.KSrepartiChange(Sender: TObject);
begin
  SGtrasferimenti.Cells[6,SGtrasferimenti.Row]:= KSreparti.Text;
  SGtrasferimenti.Cells[9,SGtrasferimenti.Row]:= KSreparti.ValueLookField;
  SGtrasferimenti.SetFocus;
  SGtrasferimenti.Col:= 7;
  SGtrasferimenti.Cells[7,SGtrasferimenti.Row]:= '';
  SGtrasferimenti.Cells[10,SGtrasferimenti.Row]:='';
end;



procedure TFrTrasferimenti.KSarticolazioneChange(Sender: TObject);
begin
  SGtrasferimenti.Cells[7,SGtrasferimenti.Row]:= KSarticolazione.Text;
  SGtrasferimenti.Cells[10,SGtrasferimenti.Row]:= KSarticolazione.ValueLookField;
  SGtrasferimenti.Col:= 8;
  SGtrasferimenti.Cells[8,SGtrasferimenti.Row]:= SGtrasferimenti.Cells[8,SGtrasferimenti.Row];
  SGtrasferimenti.SetFocus;
end;


procedure TFrTrasferimenti.KSTipoTrasfChange(Sender: TObject);
begin
  SGtrasferimenti.Cells[4,SGtrasferimenti.Row]:= KSTipoTrasf.Text;
  SGtrasferimenti.Cells[11,SGtrasferimenti.Row]:= KSTipoTrasf.ValueLookField;
  SGtrasferimenti.Col:= 5;
  SGtrasferimenti.Cells[5,SGtrasferimenti.Row]:= SGtrasferimenti.Cells[5,SGtrasferimenti.Row];
  SGtrasferimenti.SetFocus;
end;


procedure TFrTrasferimenti.SBeditClick(Sender: TObject);
begin
  SGtrasferimenti.Options:= SGtrasferimenti.Options + [goEditing];;
  Operazione:= FtModifica;
  VisibleTastiConferma(True);
end;

procedure TFrTrasferimenti.SGtrasferimentiValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGtrasferimenti.Cells[0,aRow] = '') then
     SGtrasferimenti.Cells[0,aRow]:= 'M';
end;

procedure TFrTrasferimenti.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSreparti.ReadOnly:= not button; // abilito Combox Reparti
  KSarticolazione.ReadOnly:= not button; // abilito Combox Articolazioni
  KSTipoTrasf.ReadOnly:= not button; // abilito Combox Tipo Trasferimento

  Decorrenza.ReadOnly:= not button; // abilito decorrenza
  dataarrivo.ReadOnly:= not button; // abilito dataarrivo
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGtrasferimenti.Options:= SGtrasferimenti.Options + [goEditing];
      FmDatiPersonali.WTnav.Enabled:= False;
    end
  else
    begin
     SGtrasferimenti.Options:= SGtrasferimenti.Options - [goEditing];
     FmDatiPersonali.WTnav.Enabled:= True;
    end;

end;



procedure TFrTrasferimenti.SalvaDati;
Var riga:integer;
    st:string;
begin
  for riga := 1 to SGtrasferimenti.RowCount - 1 do
    begin
      if SGtrasferimenti.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_trasferimenti(' + '''' + SGtrasferimenti.Cells[0,riga]  + ''',';

          st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

          if SGtrasferimenti.Cells[1,riga] = '' then  //idtrasferimenti
            st:= st + '0,'
          else
            st:= st +  SGtrasferimenti.Cells[1,riga] + ',';


          if SGtrasferimenti.Cells[9,riga] = '' then  //ksreparto
            begin
              st:= st + '0,';
              SGtrasferimenti.Cells[9,riga]:= '0';
            end
          else
            st:= st +  SGtrasferimenti.Cells[9,riga] + ',';



          if SGtrasferimenti.Cells[10,riga] = '' then  //ksarticolazione
            st:= st + '0,'
          else
            st:= st +  SGtrasferimenti.Cells[10,riga] + ',';


          if SGtrasferimenti.Cells[11,riga] = '' then  // kstipo
            st:= st + 'null,'
          else
            st:= st + '''' + SGtrasferimenti.Cells[11,riga] + ''',';


          if SGtrasferimenti.Cells[2,riga] = '' then  // DATA Decorrenza
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGtrasferimenti.Cells[2,riga],True) + ',';

          if SGtrasferimenti.Cells[8,riga] = '' then  // nota
            st:= st + 'null,'
          else
            st:= st + '''' +  StringReplace(SGtrasferimenti.Cells[8,riga],'''','''''',[rfReplaceAll]) +  ''',';

          if SGtrasferimenti.Cells[5,riga] = '' then  //incarico
            st:= st + 'null,'
          else
            begin
              st:= st + IntToStr( SGtrasferimenti.Columns[5].PickList.IndexOf(SGtrasferimenti.Cells[5,SGtrasferimenti.Row])) + ',';
          {    if SGtrasferimenti.Cells[5,riga] = 'COMANDANTE' then
                st:= st +  '1,'
              else if SGtrasferimenti.Cells[5,riga] = 'ADDETTO' then
                st:= st +  '2,'
              else
                st:= st + 'null,'  }
            end;
          if SGtrasferimenti.Cells[3,riga] = '' then  // Data Arrivo
              st:= st + 'null,''N'')'
          else
           begin
             if  (StrToDate(SGtrasferimenti.Cells[3,riga]) >=  FmDatiPersonali.dataarrivo.Date)
                and (SGtrasferimenti.Cells[6,riga] <> '')  and  (SGtrasferimenti.Cells[0,riga] <> 'C') then
               begin
                 if MessageDlg('Vuoi Aggiornare il Reparto: ' + SGtrasferimenti.Cells[6,riga] + ' Nella Maschera principale?', mtConfirmation,
                    [mbYes, mbNo],0) = mrYes  then
                   begin
                      st:= st +  DateDB(SGtrasferimenti.Cells[3,riga],True) + ',''S'')';
                      FmDatiPersonali.ksreparto.Text:= SGtrasferimenti.Cells[6,riga];
                      FmDatiPersonali.ksarticolazione.Text:= SGtrasferimenti.Cells[7,riga];
                      FmDatiPersonali.dataarrivo.Text :=  SGtrasferimenti.Cells[3,riga];
                      FmDatiPersonali.INCARICO.Text:= SGtrasferimenti.Cells[5,SGtrasferimenti.Row];
                   end
                 else
                    st:= st +  DateDB(SGtrasferimenti.Cells[3,riga],True) + ',''N'')';
               end
             else
               st:= st +  DateDB(SGtrasferimenti.Cells[3,riga],True) + ',''N'')';
           end;
//          Memo1.Text:=st;
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.CommitRetaining;
        end;
    end;
   LeggeDati;

end;

procedure TFrTrasferimenti.LeggeDati;
Var riga: integer;
    col:integer;
    st:string;
begin

 st:= ' SELECT a.IDTRASFERIMENTI, a.KSMILITARE,a.REPARTO, a.ARTICOLAZIONE, a.TIPOTRASFERIMENTO, a.KSREPARTO, a.KSARTICOLAZIONE, ';
 st:= st + ' a.KSTIPO, a.DECORRENZA, a.NOTA, a.DATAARRIVO,a.INCARICO FROM VIEW_TRASFERIMENTI a ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 SGtrasferimenti.Clear;
 SGtrasferimenti.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGtrasferimenti.RowCount:= SGtrasferimenti.RowCount + 1;
          riga:= SGtrasferimenti.RowCount - 1;
          SGtrasferimenti.Cells[1,riga] := dm.DSetTemp.FieldByName('IDTRASFERIMENTI').AsString;

          SGtrasferimenti.Cells[2,riga] := dm.DSetTemp.FieldByName('DECORRENZA').AsString;
          SGtrasferimenti.Cells[3,riga] := dm.DSetTemp.FieldByName('DATAARRIVO').AsString;
          SGtrasferimenti.Cells[4,riga] := dm.DSetTemp.FieldByName('TIPOTRASFERIMENTO').AsString;
          SGtrasferimenti.Cells[5,riga] := dm.DSetTemp.FieldByName('INCARICO').AsString;
          SGtrasferimenti.Cells[6,riga] := dm.DSetTemp.FieldByName('REPARTO').AsString;
          SGtrasferimenti.Cells[7,riga] := dm.DSetTemp.FieldByName('ARTICOLAZIONE').AsString;
          SGtrasferimenti.Cells[8,riga] := dm.DSetTemp.FieldByName('NOTA').AsString;

          SGtrasferimenti.Cells[9,riga] := dm.DSetTemp.FieldByName('KSREPARTO').AsString;
          SGtrasferimenti.Cells[10,riga] := dm.DSetTemp.FieldByName('KSARTICOLAZIONE').AsString;
          SGtrasferimenti.Cells[11,riga] := dm.DSetTemp.FieldByName('KSTIPO').AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
     SGtrasferimenti.Row:= SGtrasferimenti.RowCount - 1;
   end;
end;

function TFrTrasferimenti.CheckDati: boolean;
Var errore:string;
begin
  Result := True;
  errore:= '';
  with SGtrasferimenti  do
   begin
 //    if (Cells[2,Row] = '') then  errore:=  Columns[2].Title.Caption;
 //    if (Cells[4,Row] = '') then  errore:=  Columns[4].Title.Caption;
 //    if (Cells[6,Row] = '') then  errore:=  Columns[6].Title.Caption;
     if errore <> '' then
       begin
         ShowMessage(' Attenzione non hai inserito: ' +  errore );
         Result:= False;
       end;
   end;
end;

function TFrTrasferimenti.IsValidEdit(sd: string): Boolean;
begin
  try
    StrToDate(sd);
    Result := true;
  except
    Result := false;
  end;
end;

procedure TFrTrasferimenti.Esegui(grant: integer);
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

