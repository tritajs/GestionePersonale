unit main_f;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, PopupNotifier, Buttons, Grids, FileUtil,
  LR_Class;

type

  Tuser = record
    matr: string;
    grado: string;
    nominativo: string;
    reparto: string;
    codreparto: string;
    ksreparto: integer;
    provinciale:string;
    idsitforza:string;
    FileTemp: string;
    DirectTemp:string;
    IdCompetenza:string;
  end;
  Toperazione = (FtView, FtInserimento, FtModifica, FtCancellazione);


  { Tmain }

  Tmain = class(TForm)
    IdleTimer1: TIdleTimer;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Lutente: TLabel;
    Lversione: TLabel;
    manuale: TImage;
    ImageAdF1: TImage;
    ImageAdF2: TImage;
    ImageList2: TImageList;
    ImageList3: TImageList;
    Iuscita: TImage;
    Label1: TLabel;
    Label2: TLabel;
    LabelSpec: TLabel;
    LabelCorsi: TLabel;
    LMilitareNonAbilitato: TLabel;
    LGestioneArchivi: TLabel;
    Panel1: TPanel;
    ILbottoni: TPanel;
    Panel2: TPanel;
    PanelAdF1: TPanel;
    PanelAdF2: TPanel;
    PanelCompleanni: TPanel;
    PanelR: TPanel;
    LabelDP: TLabel;
    ImageR: TImage;
    PanelSaD: TPanel;
    ImageSaD: TImage;
    PanelAdF: TPanel;
    LabelSC: TLabel;
    ImageAdF: TImage;
    notifica: TPopupNotifier;
    Shape1: TShape;
    Image1: TImage;
    ImageList1: TImageList;
    LabelSF: TLabel;
    SBUserOnLine: TSpeedButton;
    SBscadenze: TSpeedButton;
    SGC: TStringGrid;
    Timer: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure IuscitaClick(Sender: TObject);
    procedure IuscitaMouseEnter(Sender: TObject);
    procedure IuscitaMouseLeave(Sender: TObject);
    procedure LabelCorsiClick(Sender: TObject);
    procedure LabelSCClick(Sender: TObject);
    procedure LabelDPMouseEnter(Sender: TObject);
    procedure LabelDPMouseLeave(Sender: TObject);
    procedure LabelDPClick(Sender: TObject);
    procedure LabelExitClick(Sender: TObject);

    procedure LabelSFClick(Sender: TObject);
    procedure LabelSpecClick(Sender: TObject);
    procedure manualeClick(Sender: TObject);
    procedure SBscadenzeClick(Sender: TObject);
    procedure SBUserOnLineClick(Sender: TObject);
    procedure SGCPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure TimerTimer(Sender: TObject);
  private
     // procedure ControlloManutenzione;
    Procedure FSleep(Time : Integer);
    procedure RicercaCompleanni;
    procedure RicercaScadenze;
    procedure AggiornamentoVersione;
    { Private declarations }
  public
    function CapitalCase(st:string):string;
    { Public declarations }
  end;

var
  main: Tmain;
  user: Tuser;
  autorizzato: TStringList;
implementation

uses  DM_f, fmautorizzazioni_f, fmdatipersonali_f, fmsituazioneforza_f, fmstatistiche_f,
      fmfiltrospec_f, FmStampe_f, fminscorsi_f, fmcambiautente_f;


{$R *.lfm}

procedure Tmain.LabelDPMouseEnter(Sender: TObject);
begin
TLabel(sender).Font.Style := [fsBold, fsUnderline];
TLabel(sender).Font.Color :=  clred;
end;

procedure Tmain.LabelSCClick(Sender: TObject);
begin
  if not Assigned(FmStatistiche) then
      FmStatistiche:= TFmStatistiche.Create(Application);
  FmStatistiche.Show;
end;


procedure Tmain.FormShow(Sender: TObject);
Var st:string;
    versione:integer;
begin
   // DefaultFormatSettings.DecimalSeparator:= '.';
   DefaultFormatSettings.ShortDateFormat:='DD/MM/YYYY';
   autorizzato:= TStringList.Create;
   DM.Accesso_Nominativo;

   //controllo la versione del programma
   versione:= 1;
   Lversione.Caption:= 'Versione: ' + IntToStr(versione);
   dm.QTemp.SQL.Text:= 'select gestionePersonale from versione';
   dm.QTemp.Open;
   if dm.QTemp.Fields.AsInteger[0] <> versione then
     begin
      AggiornamentoVersione;
      //ShowMessage('<< Attenzione stai utilizzando una versione vecchia Richiedi al BCQS Tritapepe la Nuova Versione >>');
       halt;
      end;
   //inserisco il militare nel file di log

   //controllo s'è autorizzato
   if autorizzato.Count = 0 then
    begin
      LMilitareNonAbilitato.Caption:= ' IL ' + user.grado + ' ' + user.nominativo + ' NON E'' ABILITATO ' ;
      LMilitareNonAbilitato.Visible:=True;
      Timer.Enabled:=True;
    end
   else
    begin //S'è autorizzato inserisco il militare nella tabella useronline
      st:= ' select * from militareonline';
      st:= st + '(''' + user.matr + ''',''' +  StringReplace(user.nominativo,'''','''''',[rfReplaceAll])  +''',';
      st:= st + '''' + TimeToStr(Now)  +''')';

      dm.QTemp.SQL.Text:= st;
      dm.QTemp.Open();
      dm.TR.Commit;

      //visualizzo il nome dell'utente connesso
      Lutente.Caption:=   CapitalCase(user.grado) + ' ' + CapitalCase(user.nominativo);

      //Esegue Abilitazioni
      FmDatiPersonali.CheckGrant;

      // controllo eventuali scadenze solo se il mIlitare è abilitato alla modifica del suo reparto
      RicercaScadenze;
      //controllo i compleanni
      RicercaCompleanni;
    end;
end;

procedure Tmain.AggiornamentoVersione;
var
  ok:boolean;
  SourceFile,TargetFile,FileName:string;
begin
  Filename:= 'GestionalePersonale';
  SourceFile:= '\\CH116AQ052SIC01\Gestionali\' + FileName;
  TargetFile:= GetCurrentDir + '\' + FileName;
  ok := CopyFile(SourceFile, TargetFile);
   if ok then
     begin
        MessageDlg('File '+ FileName + ' correttamente copiato ',mtInformation,[mbOk],0);
     end
     else
       MessageDlg('Aggiornamento fallito',mtWarning,[mbOk],0)
end;



procedure Tmain.IdleTimer1Timer(Sender: TObject);
begin
  halt;
end;

procedure Tmain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var st:string;

 procedure termina;
   begin
     LMilitareNonAbilitato.Caption:= ' <<<<  PASSWORD ERRATA  >>>> ' ;
     FSleep(100);
     halt;
   end;

begin
{if (key = 120) and (Shift = [ssCtrl])   then
  begin
    st:= PasswordBox('','Inserisci La Password');
    if st = 'Lanciano66' then
      begin
        user.matr:='852406Y';
        if dm.Accesso_Nominativo then
          begin
            Timer.Enabled:= False;
            LMilitareNonAbilitato.Visible:= False;
            FmDatiPersonali.CheckGrant;
            FmDatiPersonali.Show;
          end
        else
          termina;
      end
    else
     Termina;
   end;

if (key = 119) and (Shift = [ssCtrl])   then
  begin
    st:= PasswordBox('','Inserisci La Password');
    if st = 'Lanciano' then
      begin
        user.matr:='000000Y';
        if dm.Accesso_Nominativo then
          begin
            Timer.Enabled:= False;
            LMilitareNonAbilitato.Visible:= False;
            FmDatiPersonali.CheckGrant;
          //  FmDatiPersonali.Show;
          end
        else
          termina;
      end
    else
      Termina;
  end;}
end;

procedure Tmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 dm.TR.Commit;
 dm.QTemp.SQL.Text:= 'delete from useronline where matrmec = ''' + user.matr + '''' ;
 dm.QTemp.Open();
 dm.TR.Commit;
end;


procedure Tmain.Image3Click(Sender: TObject);
var st:string;
begin
 if Autorizzato.IndexOf('AMMINISTRATORE') > -1 then
    FmAutorizzazioni.ShowModal
  else
   begin
    st:= PasswordBox('','Inserisci La Password');
    if st = 'Lanciano66' then
      FmAutorizzazioni.ShowModal
    else
      ShowMessage('<<< PASSWORD ERRATA >>>');
   end;
end;

procedure Tmain.Image4Click(Sender: TObject);
begin
 if Autorizzato.IndexOf('AMMINISTRATORE') > -1 then
    FmCambiaUtente.ShowModal;
end;


procedure Tmain.IuscitaClick(Sender: TObject);
begin
 close;
end;

procedure Tmain.IuscitaMouseEnter(Sender: TObject);
begin
 ImageList2.GetBitmap(1,Iuscita.Picture.Bitmap);
end;

procedure Tmain.IuscitaMouseLeave(Sender: TObject);
begin
  ImageList2.GetBitmap(0,Iuscita.Picture.Bitmap);
end;

procedure Tmain.LabelCorsiClick(Sender: TObject);
begin
  if not Assigned(FmInsCorsi) then
      FmInsCorsi:= TFmInsCorsi.Create(Application);
  FmInsCorsi.Show;
end;

{procedure Tmain.LGestioneArchiviClick(Sender: TObject);
begin
{ if dm.Autorizzato('GESTIONE ARCHIVI') then
    FMGestioneArchivi.ShowModal
 else
    ShowMessage('<<< MILITARE NON ABILITATO >>>'); ♀5
end;
}

procedure Tmain.LabelDPMouseLeave(Sender: TObject);
begin
TLabel(sender).Font.Style := [fsBold];
TLabel(sender).Font.Color :=  clBlack;
end;

procedure Tmain.LabelDPClick(Sender: TObject);
begin
 if autorizzato.Count > 0 then
   FmDatiPersonali.Show;
end;

procedure Tmain.LabelExitClick(Sender: TObject);
begin
 Close;
end;


procedure Tmain.LabelSFClick(Sender: TObject);
begin
 if autorizzato.Count > 0 then
   begin
     if not Assigned(FmSituazioneForza) then
         FmSituazioneForza:= TFmSituazioneForza.Create(Application);
     FmSituazioneForza.Show;
    end;
end;

procedure Tmain.LabelSpecClick(Sender: TObject);
begin
 if not Assigned(FmFiltroSpec) then
      FmFiltroSpec:= TFmFiltroSpec.Create(Application);
  FmFiltroSpec.Show;

end;

procedure Tmain.manualeClick(Sender: TObject);
Var manuale:string;
begin
 manuale:=   ExtractFilePath(Application.EXEName) +  'manuale\ManualeGestionale.pdf';
 OpenDocument(manuale);
end;


procedure Tmain.SBscadenzeClick(Sender: TObject);
Var st:string;
begin
 if GrantPr.ksreparto > 0 then   //controllo solo le scadenze  dei reparti periferici
     st:= 'SELECT * FROM ELABORAZIONE_SCADENZE(' + IntToStr(user.ksreparto)  + ',0)' // 0 seleziono i reparti periferici
  else
     st:= 'SELECT * FROM ELABORAZIONE_SCADENZE(' + user.idsitforza  + ',1)'; // 1 i provinciali e equiparati

 FmStampe.DSet1.SQL.Text:=st;
 FmStampe.DSet1.Open;

 DM.LoadFromDB('Scadenze',FmStampe.frScadenze);
  FmStampe.frScadenze.ShowReport;
end;

procedure Tmain.SBUserOnLineClick(Sender: TObject);
Var st:string;
begin
  dm.TR.CommitRetaining;
  dm.QTemp.SQL.Text:='SELECT * FROM USERONLINE';
  dm.QTemp.open;
  st:= '';
  while not dm.QTemp.Eof do
    begin
      st:= st + ' ' + dm.QTemp.Fields.ByNameAsString['MILITARE'] + ' ';
      st:= st + dm.QTemp.Fields.ByNameAsString['ACCESSO'] + ' ';
      dm.QTemp.Next;
    end;
    notifica.Text:= st;
    notifica.Visible:= True;
end;

procedure Tmain.SGCPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
//  if aCol = 1 then
//    begin
     if copy(SGC.Cells[1,aRow],1,2) = copy(DateToStr(Now),1,2) then
       begin
         SGC.Canvas.Font.Color := clBlue;
         SGC.Canvas.Font.Style:= [fsBold];
       end;
//    end;
end;

procedure Tmain.TimerTimer(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tmain.FSleep(Time: Integer);
var
  i:integer;
begin
  for i := 0 to Time do
    begin
      sleep(1);
      Application.ProcessMessages;
    end;
end;

procedure Tmain.RicercaCompleanni;
Var st:string;
    nr:integer;
begin
// SGC.Clear;
 PanelCompleanni.Visible:= False;
 st:= ' SELECT nato,r3.grado,cognome,nome,r1.reparto FROM  ANAGRAFICA r   ';
 st:= st + ' inner join reparti r1 on (r.KSREPARTO = r1.IDREPARTO) ';
 st:= st + ' inner join stato r2 on (r.KSSTATOGIURIDICO = r2.IDSTATO) ';
 st:= st + ' inner join gradi r3 on (r.KSGRADO = r3.IDGRADI) ';
 st:= st + ' where r1.IDSITFORZA = ' + user.idsitforza  + ' and  r2.VISUALIZZANOMI = ''S''  and ';
 st:= st + ' extract(month from r.NATO) = extract(month from cast(''NOW'' as date)) and ';
 st:= st + ' extract(day from r.NATO) >= extract(day from cast(''NOW'' as date)) ';
 st:= st + ' order by extract(day from r.nato)';
 //Memo1.Text:= st;
 dm.QTemp.SQL.Text:= st;
 dm.QTemp.Open;
 if dm.QTemp.Fields.RecordCount > 0 then
   begin
     PanelCompleanni.Visible:= True;

       nr:= 0;
       while not dm.QTemp.Eof do
       begin
         inc(nr);
         sgc.RowCount:= nr;
         sgc.Cells[0,nr-1]:= InttoStr(nr);
         sgc.Cells[1,nr-1]:= dm.QTemp.Fields.AsString[0];
         sgc.Cells[2,nr-1]:= dm.QTemp.Fields.AsString[1];
         sgc.Cells[3,nr-1]:= dm.QTemp.Fields.AsString[2];
         sgc.Cells[4,nr-1]:= dm.QTemp.Fields.AsString[3];
         sgc.Cells[5,nr-1]:= dm.QTemp.Fields.AsString[4];
         dm.QTemp.Next;
       end;
       Label2.Caption:= IntToStr(nr);
       Panel1.SetFocus;
   end;
end;

procedure Tmain.RicercaScadenze;
Var st:string;
    nr:integer;
begin
 if (Autorizzato.IndexOf('MODIFICA REPARTO') > -1) or
    (Autorizzato.IndexOf('AMMINISTRATORE') > -1 ) or
    (Autorizzato.IndexOf('VISTA REPARTO') > -1 )
    then
  begin
   SBscadenze.Visible:= True;

   if GrantPr.ksreparto > 0 then   //controllo solo le scadenze  dei reparti periferici
      st:= 'SELECT * FROM RICERCA_SCADENZE(' + IntToStr(user.ksreparto)  + ',0)' // 0 selezione i reparti periferici
   else
     st:= 'SELECT * FROM RICERCA_SCADENZE(' + user.idsitforza  + ',1)'; // 1 i provinciali e equiparati
   dm.QTemp.SQL.Text:= st;
   dm.QTemp.Open();
   if dm.QTemp.Fields.RecordCount > 0 then
     begin
        st:= 'SCADENZE IN CORSO: ';
        nr:= dm.QTemp.Fields.ByNameAsInteger['patenti'];
        if nr > 0 then st:= st + ' Patenti  ' + IntToStr(nr) + ' - ';

        nr:= dm.QTemp.Fields.ByNameAsInteger['tessere'];
        if nr > 0 then st:= st + '  Tessere GF: ' + IntToStr(nr);

        nr:= dm.QTemp.Fields.ByNameAsInteger['tessere_bt_at'];
        if nr > 0 then st:= st + '    - BT AT: ' + IntToStr(nr);

        nr:= dm.QTemp.Fields.ByNameAsInteger['valutazioni'];
        if nr > 0 then   st:= st + '   - Note Caratteristiche: ' + IntToStr(nr);
        SBscadenze.Caption:= st;
        SBscadenze.Visible:=True;
     end;
  end;
end;


function Tmain.CapitalCase(st: string): string;
var
   i,nrchar : byte;
   c :char;
   spazio:boolean;
begin
  nrchar:= length(st);
  i:= 1; spazio := True;
  while i <= nrchar  do
   begin
    c:= st[i];
    if c = ' ' then
      spazio:= True
     else
       begin
        if spazio then
          begin
            st[i]:= upCase(c);
            spazio:= False;
          end
        else
           st[i]:= lowerCase(c);
       end;
    i:= i + 1
   end;
  Result:= st;
end;



end.
