unit fminsmulval_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Grids, WTNavigator, WTComboBoxSql, wteditcompNew, umEdit,
  WDateEdit,LCLType,LSystemTrita, fpSpreadsheet, fpsTypes, LCLIntf;

type

  { Tfminsmulval }

  Tfminsmulval = class(TForm)
    al: TWDateEdit;
    articolazione: TumEdit;
    CAT: TumValidEdit;
    cognome: TumEdit;
    cont: TumValidEdit;
    dal: TWDateEdit;
    descrizione: TumEdit;
    ECval: TwtEditCompNew;
    grado: TumEdit;
    idmilitare: TumEdit;
    Image1: TImage;
    Image2: TImage;
    ksmotivo: TWTComboBoxSql;
    kstipodc: TWTComboBoxSql;
    ksvalutazione: TWTComboBoxSql;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Lcontatore: TLabel;
    matrmec: TumEdit;
    Nome: TumEdit;
    Panel1: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    reparto: TumEdit;
    SBcancel: TSpeedButton;
    SBdel1: TSpeedButton;
    SBexcel: TSpeedButton;
    SBIns1: TSpeedButton;
    SBok: TSpeedButton;
    scadenza: TWDateEdit;
    Sesso: TumValidEdit;
    SGValutazione: TStringGrid;
    SpeedButton1: TSpeedButton;
    WTNavigator1: TWTNavigator;
    procedure cognomeKeyPress(Sender: TObject; var Key: char);
    procedure ECvalBeforeFind(Sender: Tobject; var CampiValori, CampiWhere,
      CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
      var SelectCustomer: string);
    procedure ECvalContatore(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Label14Click(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdel1Click(Sender: TObject);
    procedure SBexcelClick(Sender: TObject);
    procedure SBIns1Click(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure WTNavigator1Click(Sender: TObject; Button: TNavButtonType);
  private
    procedure InsRecord;
    procedure VisibleTastiConferma(button:boolean);
    function  CheckDati:boolean;
    function  CheckData(data:string):string;
  public

  end;

var
  fminsmulval: Tfminsmulval;

implementation

uses DM_f, fmdatipersonali_f, main_f;

{$R *.lfm}

{ Tfminsmulval }

procedure Tfminsmulval.ECvalBeforeFind(Sender: Tobject; var CampiValori,
  CampiWhere, CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
  var SelectCustomer: string);
begin
   SelectCustomer:= 'SELECT idmilitare,matrmec,cont,sesso,cat,descrizione,grado,cognome,nome,reparto, ';
   SelectCustomer:= SelectCustomer + ' articolazione FROM VIEW_DATIPERSONALI ANAGRAFICA ';
   CampiWhere:= GrantPr.FiltroPresenti;
end;

procedure Tfminsmulval.ECvalContatore(Sender: TObject);
begin
    Lcontatore.Caption :=  'Trovati nr ' + ECval.contatore;
end;

procedure Tfminsmulval.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
   if SGValutazione.RowCount > 1 then
    begin
      ShowMessage('attenzioni! prima di uscire devi confermare i dati');
      CloseAction:= caNone;
    end;
end;

procedure Tfminsmulval.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 34) and (idmilitare.Text <> '') then
    WTNavigator1.ActiveButton('Successivo')
 else if (key = 33) and (idmilitare.Text <> '') then
    WTNavigator1.ActiveButton('Precedente');
end;

procedure Tfminsmulval.FormShow(Sender: TObject);
begin
  Panel1.SetFocus;
end;

procedure Tfminsmulval.Label14Click(Sender: TObject);
begin

end;

procedure Tfminsmulval.SBcancelClick(Sender: TObject);
begin
  VisibleTastiConferma(False);
  SGValutazione.Clear;
  SGValutazione.RowCount:= 1
end;

procedure Tfminsmulval.SBdel1Click(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGValutazione.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione di  ' +  SGValutazione.Cells[1,SGValutazione.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
          SGValutazione.DeleteRow(SGValutazione.Row)
      end;
   end;
  if SGValutazione.RowCount = 0 then
      VisibleTastiConferma(False);
end;

procedure Tfminsmulval.SBexcelClick(Sender: TObject);
Var
 MyWorkbook: TsWorkbook;
 MyWorksheet: TsWorksheet;
 riga,col,coln:integer;
begin
     riga:= 0;
     col:= 0;
     coln:= 0;
     MyWorkbook := TsWorkbook.Create;
     MyWorksheet := MyWorkbook.AddWorksheet('My Worksheet');

     for coln:= 0 to SGValutazione.ColCount - 1 do
      begin
       if SGValutazione.Columns[coln].Visible  then
         begin
            Inc(col);
            MyWorksheet.WriteUTF8Text(0, col, SGValutazione.Columns[coln].Title.Caption);// C5
         end;
      end;
    for riga := 1 to SGValutazione.RowCount -1  do
      begin
       col:= 0;
       for coln:= 0 to SGValutazione.ColCount - 1 do
         begin
          if SGValutazione.Columns[coln].Visible  then
            begin
              Inc(col);
              MyWorksheet.WriteUTF8Text(riga, col, SGValutazione.Cells[coln,riga]);// C5
            end;
         end;
      end;
    if FileExists(user.FileTemp) then
        DeleteFile(user.FileTemp);
      MyWorkbook.WriteToFile(user.FileTemp,sfExcel5,True);
      MyWorkbook.Free;
    OpenDocument(user.FileTemp);
end;

procedure Tfminsmulval.SBIns1Click(Sender: TObject);
begin
  if (idmilitare.Text <> '') and (CheckDati) then
    begin
       InsRecord;
       VisibleTastiConferma(True);
       Lcontatore.Caption:='';
    end;
end;

procedure Tfminsmulval.SBokClick(Sender: TObject);
Var riga:integer;
    st:string;
begin
 for riga := 1 to SGValutazione.RowCount - 1 do
    begin
      if SGValutazione.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_listadoccar(' + '''I'',';

           if SGValutazione.Cells[2,riga] = '' then  //idlistadc
            st:= st + '0,'
          else
            st:= st +  SGValutazione.Cells[2,riga] + ',';

           st:= st +  SGValutazione.Cells[0,riga] + ',';  // ksmilitare

          if SGValutazione.Cells[3,riga] = '' then  //KSTIPODC
            st:= st + '0,'
          else
            st:= st +  SGValutazione.Cells[3,riga] + ',';

          if SGValutazione.Cells[7,riga] = '' then  // DATA DAL
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGValutazione.Cells[7,riga],True) + ',';

          if SGValutazione.Cells[8,riga] = '' then  // DATA AL
            st:= st + 'null,'
          else
            st:= st +  DateDB(SGValutazione.Cells[8,riga],True) + ',';

          if SGValutazione.Cells[4,riga] = '' then  //KSMOTIVO
            st:= st + '0,'
          else
            st:= st +  SGValutazione.Cells[4,riga] + ',';

          if SGValutazione.Cells[5,riga] = '' then  //KSVALUTAZIONE
            st:= st + '0,'
          else
            st:= st +  SGValutazione.Cells[5,riga] + ',';

          st:= st +   SGValutazione.Cells[12,riga] + ',';   //da trasmettere

          if SGValutazione.Cells[11,riga] = '' then  // SCADENZA
            st:= st + 'null)'
          else
           begin
              st:= st +  DateDB(SGValutazione.Cells[11,riga],True) + ')';
           end;
           dm.QTemp.SQL.Text:= st;
           dm.QTemp.Open();
        end;
    end;
    dm.TR.CommitRetaining;
    SBcancel.OnClick(self);
end;

procedure Tfminsmulval.SpeedButton1Click(Sender: TObject);
begin
  scadenza.Text:= al.Text;
end;

procedure Tfminsmulval.WTNavigator1Click(Sender: TObject; Button: TNavButtonType
  );
begin
   cognome.SetFocus;
   if Button in [nbtPost] then
     Panel1.SetFocus;
end;

procedure Tfminsmulval.cognomeKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
   WTNavigator1.ActiveButton('Conferma');
end;

procedure Tfminsmulval.InsRecord;
Var riga:integer;
begin
  SGValutazione.RowCount:= SGValutazione.RowCount + 1;
  riga:= SGValutazione.RowCount -1;
  SGValutazione.Cells[0,riga]:= idmilitare.Text;
  SGValutazione.Cells[1,riga]:= cognome.Text + ' ' + nome.Text;
  SGValutazione.Cells[2,riga]:= '0';
  SGValutazione.Cells[3,riga]:= kstipodc.ValueLookField;
  SGValutazione.Cells[4,riga]:= ksmotivo.ValueLookField;
  SGValutazione.Cells[5,riga]:= ksvalutazione.ValueLookField;

  SGValutazione.Cells[6,riga]:= kstipodc.Text;
  SGValutazione.Cells[7,riga]:= CheckData(dal.Text);
  SGValutazione.Cells[8,riga]:= CheckData(al.Text);
  SGValutazione.Cells[9,riga]:= ksmotivo.Text;
  SGValutazione.Cells[10,riga]:=ksvalutazione.Text;
  SGValutazione.Cells[11,riga]:=CheckData(scadenza.Text);
  SGValutazione.Cells[12,riga]:= '1';
  ECval.Clear_Edit;
  Panel1.SetFocus;
end;

procedure Tfminsmulval.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:=button;
  SBcancel.Visible:=button;
  SBexcel.Visible:= button;
end;

function Tfminsmulval.CheckDati: boolean;
Var errore:string;
begin
  result:= True;
 errore:= '';
 if  kstipodc.Text = '' then
  begin
    Result:= False;
    errore:= 'Manca il tipo di <<DOCUMENTAZIONE>>';
  end;
 if  CheckData(dal.Text) = '' then
  begin
    Result:= False;
    errore:= 'Manca la data <<DAL>>';
  end;
 if  CheckData(al.Text) = '' then
  begin
    Result:= False;
    errore:= 'Manca la data <<AL>>';
  end;
 if  ksmotivo.Text = '' then
  begin
    Result:= False;
    errore:= 'Manca il <<MOTIVO>>';
  end;
(* if  ksvalutazione.Text = '' then
 begin
   Result:= False;
   errore:= 'Manca la <<VALUTAZIONE>>';
 end; *)

if errore <> '' then
  ShowMessage(errore);
end;

function Tfminsmulval.CheckData(data: string): string;
begin
  if (data[1] in ['0'..'9']) then
     result:= data
  else
     result := '';
end;

end.

