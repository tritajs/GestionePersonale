unit fminscorsi_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, WTNavigator, WTMemo, WTComboBox, WTComboBoxSql,
  WTStringGridSql, wteditcompNew, umEdit,db,comobj,fmexportexcel_f;

type

  { TFmInsCorsi }

  TFmInsCorsi = class(TForm)
    anno: TumNumberEdit;
    corso: TWTMemo;
    ECcorsi: TwtEditCompNew;
    IDCORSO: TumEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    ksareariferimento: TWTComboBoxSql;
    KSESITO: TWTComboBoxSql;
    ksmodalita: TWTComboBox;
    KSNATURA: TWTComboBoxSql;
    KSNOMINATIVO: TWTComboBoxSql;
    kstipologia: TWTComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LabelAreaRiferimento: TLabel;
    LContatore: TLabel;
    note: TumEdit;
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel6: TPanel;
    SBcancel: TSpeedButton;
    SBExportExcel: TSpeedButton;
    SBIns: TSpeedButton;
    sbInsFromFile: TSpeedButton;
    SBok: TSpeedButton;
    SGnomi: TwtStringGridSql;
    WTNav: TWTNavigator;
    procedure ECcorsiBeforeDelete(Sender: Tobject; var where: string);
    procedure ECcorsiBeforeUpdate(Sender: Tobject; var where,
      CampiValore: string);
    procedure ECcorsiContatore(Sender: TObject);
    procedure ECcorsiStato(Sender: Tobject; var Operazione: string);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure LabelAreaRiferimentoClick(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBExportExcelClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure sbInsFromFileClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure WTNavBeforeClick(Sender: TObject; var Button: TNavButtonType;
      var EseguiPost: Boolean);
    procedure WTNavClick(Sender: TObject; Button: TNavButtonType);
  private
    SceltaIns:string;
    procedure VisibleTastiConferma(button:boolean);
    procedure ClearName;

  public

  end;

var
  FmInsCorsi: TFmInsCorsi;

implementation
uses main_f, DM_f;

const FiltroNomi = ' SELECT a1.MATRMEC,a2.GRADO, a1.COGNOME,a1.NOME,a3.REPARTO,a4.ESITOCORSO,a.note ' +
                   ' FROM LISTACORSI a ' +
                   ' left join ANAGRAFICA a1 on (a.KSMILITARE = a1.IDMILITARE) ' +
                   ' left join GRADI a2 on (a1.KSGRADO = a2.IDGRADI) ' +
                   ' left join REPARTI a3 on (a1.KSREPARTO = a3.IDREPARTO) ' +
                   ' left join ESITOCORSO a4 on (a.KSESITO = a4.IDESITOCORSO) ';


{$R *.lfm}

{ TFmInsCorsi }

procedure TFmInsCorsi.ECcorsiBeforeUpdate(Sender: Tobject; var where,
  CampiValore: string);
begin
 where:= ' idcorso = ' + IDCORSO.Text;
end;

procedure TFmInsCorsi.ECcorsiBeforeDelete(Sender: Tobject; var where: string);
begin
    where:= ' idcorso = ' + IDCORSO.Text;
end;

procedure TFmInsCorsi.ECcorsiContatore(Sender: TObject);
begin
  Lcontatore.Caption :=   ECcorsi.contatore;
end;

procedure TFmInsCorsi.ECcorsiStato(Sender: Tobject; var Operazione: string);
Var st:string;
begin
  if IDCORSO.Text <> '' then
    begin
     st:= FiltroNomi + ' where a.kscorso = ' + IDCORSO.Text;
     SGnomi.Sql.Text:= st;
     SGnomi.Active:=True;
    end;
end;

procedure TFmInsCorsi.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   dm.TR.Commit;
  ECcorsi.Clear_Edit;
  SGnomi.Active:=False;
end;

procedure TFmInsCorsi.FormShow(Sender: TObject);
begin
  if (Autorizzato.IndexOf('AMMINISTRATORE') > -1) or (user.idsitforza = '8') or
    (Autorizzato.IndexOf('CORSI MODIFICA') > -1) then
   begin
    WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast,
                                   nbtInsert, nbtDelete, nbtEdit, nbtPost, nbtCancel, nbtRefresh, nbtFind];
    SBIns.Visible:= True;
   end
  else
   begin
    WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast,
                                  nbtPost, nbtCancel, nbtRefresh, nbtFind];
    SBIns.Visible:= False;
   end;

  Panel6.SetFocus;
end;

procedure TFmInsCorsi.LabelAreaRiferimentoClick(Sender: TObject);
Var AreaRiferimento,st: string;
begin
   if ECcorsi.stato in [dsEdit, dsInsert] then
    begin
     AreaRiferimento:= InputBox('Inserisci una nuova Area Riferimento','Area Riferimento','');
     if AreaRiferimento <> '' then
       begin
        AreaRiferimento:= UpperCase(AreaRiferimento);
        st:= 'INSERT INTO AREARIFERIMENTOCORSO (AREARIFERIMENTO) VALUES (:AREARIFERIMENTO)';
        dm.QTemp.SQL.Text:=st;
        dm.QTemp.Params.ByNameAsString['AREARIFERIMENTO']:= AreaRiferimento;
        dm.QTemp.ExecSQL;
       end;
    end;
end;

procedure TFmInsCorsi.SBcancelClick(Sender: TObject);
begin
  ClearName;
  VisibleTastiConferma(False);
  SGnomi.Active:=False;
end;

procedure TFmInsCorsi.SBExportExcelClick(Sender: TObject);
begin
  dm.DSetTemp.SQL.Text:= SGnomi.Sql.Text;
  dm.DSetTemp.Open;
  FmExportExcel.EsportaEXL(dm.DSetTemp);
end;

procedure TFmInsCorsi.SBInsClick(Sender: TObject);
begin
 if idcorso.Text <> '' then
   begin
     VisibleTastiConferma(True);
     KSNOMINATIVO.SetFocus;
     SceltaIns:= 'InsNomi';
   end;
end;

procedure TFmInsCorsi.sbInsFromFileClick(Sender: TObject);
Var rigaSG,rigaXLS,colXLS,nr,x: integer;
    ReadFile: widestring;
    valueuno:string;
    conta:integer;
    XLApp: Variant;
begin
    if idcorso.Text = '' then
      begin
        ShowMessage('Devi Inserire Prima un corso e poi caricare il file Excel');
        exit;
      end;

   if OpenDialog.Execute then
     ReadFile:= OpenDialog.FileName
   else
    exit;
   SceltaIns:='InsExcel';
   // preparo sgnomi
   SGnomi.Active:=false;
   SGnomi.RowCount:= 2;
   VisibleTastiConferma(True);
   SGnomi.Columns.Clear;
   for x:= 0 to 4 do  SGnomi.Columns.Add;
   SGnomi.Columns[0].Title.Caption:= 'MATRICOLA';
   SGnomi.Columns[1].Title.Caption:='COGNOME';
   SGnomi.Columns[2].Title.Caption:='NOME';
   SGnomi.Columns[3].Title.Caption:='ESITO';
   SGnomi.Columns[4].Title.Caption:='NOTE';
   XLApp := CreateOleObject('Excel.Application'); // requires comobj in uses
    try
       XLApp.Visible := False;         // Hide Excel
       XLApp.DisplayAlerts := False;
       XLApp.Workbooks.Open(ReadFile);     // Open the Workbook
       XLApp.Workbooks[1].Worksheets[1].select; //selezione il 1 foglio
       rigaXLS:= 1;
       valueuno:= UpperCase(XLApp.Cells[rigaXLS,1].Value);
       if valueuno = 'MATRICOLA' then
         begin
            inc(rigaXLS);
            valueuno:= XLApp.Cells[rigaXLS,1].Value;
            SGnomi.RowCount:= rigaXLS;
            while (valueuno <> '') do
               begin
                 SGnomi.Cells[0,rigaXLS-1]:= XLApp.Cells[rigaXLS,1].Value ;
                 SGnomi.Cells[1,rigaXLS-1]:= XLApp.Cells[rigaXLS,2].Value ;
                 SGnomi.Cells[2,rigaXLS-1]:= XLApp.Cells[rigaXLS,3].Value ;
                 SGnomi.Cells[3,rigaXLS-1]:= XLApp.Cells[rigaXLS,4].Value ;
                 SGnomi.Cells[4,rigaXLS-1]:= XLApp.Cells[rigaXLS,5].Value ;
                 inc(rigaXLS);
                 valueuno:= XLApp.Cells[rigaXLS,1].Value;
                 if (valueuno <> '') then
                    SGnomi.RowCount:= rigaXLS;
               end;
         end
       else
         ShowMessage('Attenzione la prima riga deve essere "MATRICOLA"');
     finally
      XLApp.Quit;
      XLAPP := Unassigned;
      SGnomi.AutoSizeColumns;
    end;
end;

procedure TFmInsCorsi.SBokClick(Sender: TObject);
Var st,SqlRicerca:string;
    riga:integer;
begin
   if SceltaIns = 'InsNomi' then
      begin
        st:= ' insert into listacorsi (KSMILITARE,KSCORSO,KSESITO,NOTE,DATRASCRIVERE) values (';
        st:= st + KSNOMINATIVO.FindField('IDMILITARE') + ',';
        st:= st + IDCORSO.Text + ',';
        st:= st + KSESITO.ValueLookField + ',';
        st:= st + '''' + StringReplace( note.Text,'''','''''',[rfReplaceAll])  + ''',1)';
        dm.QTemp.SQL.Text:=st;
        dm.QTemp.Open;
      end
    else  //Inserimento da file Excel
      begin
         for riga:= 1 to SGnomi.RowCount -1 do
           begin
              st:= ' insert into listacorsi (KSMILITARE,KSCORSO,KSESITO,NOTE,DATRASCRIVERE) values (';
              SqlRicerca:= 'select idmilitare from anagrafica where matrmec = ''' + SGnomi.Cells[0,riga] + '''';
              dm.QTemp.SQL.Text:= SqlRicerca;
              dm.QTemp.Open;
              if dm.QTemp.Fields.RecordCount > 0 then
                 st:= st + dm.QTemp.Fields.AsString[0] + ','
              else
                begin
                 Showmessage('Attenzione la matricola ' + SGnomi.Cells[0,riga] + ' di ' + SGnomi.Cells[1,riga] + ' non esiste ');
                 exit;
                end;
              st:= st + IDCORSO.Text + ',';
              if (SGnomi.Cells[3,riga] = '') or (SGnomi.Cells[3,riga] = 'CONCLUSO') then
                 st:= st + '1,';
              st:= st + '''' + StringReplace( SGnomi.Cells[4,riga] ,'''','''''',[rfReplaceAll])  + ''',1)';

              dm.QTemp.SQL.Text:=st;
              dm.QTemp.Open;
           end;
          dm.TR.Commit;
          SGnomi.Columns.Clear;
      end;
      VisibleTastiConferma(False);
      SGnomi.Active:=False;
      SGnomi.Active:=True;
      ClearName;
end;

procedure TFmInsCorsi.WTNavBeforeClick(Sender: TObject;
  var Button: TNavButtonType; var EseguiPost: Boolean);
begin
   if Button = nbtFind then
    corso.SetFocus;
end;

procedure TFmInsCorsi.WTNavClick(Sender: TObject; Button: TNavButtonType);
Var st:string;
begin
  if (Button in [nbtPost]) and (ECcorsi.stato = dsInsert) then
    begin
      st:= ' select idcorso from corsi where corso = ' ;
      st:= st + '''' + StringReplace(corso.Text,'''','''''',[rfReplaceAll]) + '''';
      dm.QTemp.SQL.Text:=st;
      dm.QTemp.Open();
      if dm.QTemp.Fields.RecordCount > -1 then
        IDCORSO.Text:= dm.QTemp.Fields.ByNameAsAnsiString['idcorso'];
    end
  else if (Button in [nbtInsert,nbtEdit,nbtFind]) then
    begin
      corso.SetFocus;
      SGnomi.Active:=False;
    end
end;

procedure TFmInsCorsi.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  KSNOMINATIVO.ReadOnly:= not button;
  KSESITO.ReadOnly:=      not button;
  note.ReadOnly:=         not button;
end;

procedure TFmInsCorsi.ClearName;
begin
  KSNOMINATIVO.Text:='';
  KSNOMINATIVO.ValueLookField:='';
  KSESITO.Text:='';
  KSESITO.ValueLookField:='';
  note.Text:='';
end;



end.

