unit fmdatipersonali_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Menus, ExtDlgs, ComCtrls, wteditcompNew, WTNavigator,
  WTComboBoxSql, WTMemo, WTComboBox, WTCheckBox, WTimage, umEdit, WDateEdit, Types;

type

  { TFmDatiPersonali }
   TGrantPr = record    // memorizza le restrizioni per la vista sola del reparto di appartenenza
    ksreparto: integer;
    idsitforza:string;  //questo campo determina i militari di competenza
    FiltroCompleto:string;  //visualizza tutti i militari di competenza anche i congedati
    FiltroPresenti:string; //visualizza solo i militari presenti di competenza
  end;
  TFmDatiPersonali = class(TForm)
    altezza: TumEdit;
    arruolato: TWDateEdit;
    CAT: TumValidEdit;
    celservizio: TumEdit;
    cognome: TumEdit;
    cont: TumValidEdit;
    dataarrivo: TWDateEdit;
    datagrado: TWDateEdit;
    dataposizione: TWDateEdit;
    ECdati: TwtEditCompNew;
    figli: TumEdit;
    FOTO: TWTimage;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    INCARICO: TWTComboBox;
    ksarticolazione: TWTComboBoxSql;
    kscomune: TWTComboBoxSql;
    ksgrado: TWTComboBoxSql;
    ksreparto: TWTComboBoxSql;
    kscapelli: TWTComboBoxSql;
    ksresidenza: TWTComboBoxSql;
    ksstatocivile: TWTComboBoxSql;
    ksstatogiuridico: TWTComboBoxSql;
    KStitolodistudio: TWTComboBoxSql;
    ksvalutazione: TWTComboBoxSql;
    ksocchi: TWTComboBoxSql;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LabelTitolo: TLabel;
    Lcontatore: TLabel;
    Lgrant: TLabel;
    lmilitari: TLabel;
    MainMenu: TMainMenu;
    matrmec: TumEdit;
    MIanni: TMenuItem;
    MIEsporta: TMenuItem;
    MIRichiestaTessera: TMenuItem;
    MITessera: TMenuItem;
    MIfiltro: TMenuItem;
    MIPrintDati: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MIcomunicazioni: TMenuItem;
    MIDesign: TMenuItem;
    MIexl: TMenuItem;
    MIStampaAllSchedaPdf: TMenuItem;
    MIStampaScheda: TMenuItem;
    MIStampaSchedaPdf: TMenuItem;
    MIStampe: TMenuItem;
    MItabelle: TMenuItem;
    MIViewReparti: TMenuItem;
    MIword: TMenuItem;
    nato: TWDateEdit;
    Nome: TumEdit;
    nos: TumValidEdit;
    Note: TWTMemo;
    NoteCarDal: TWDateEdit;
    operativo: TumValidEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PC: TPageControl;
    Pdati: TPanel;
    PMnav: TPopupMenu;
    Pr: TumEdit;
    presente: TWTCheckBox;
    provinciale: TumEdit;
    Prr: TumEdit;
    CF: TumEdit;
    sangue: TumEdit;
    SavePictureDialog1: TSavePictureDialog;
    SBfiltro: TSpeedButton;
    scadenzadc: TWDateEdit;
    Sesso: TumValidEdit;
    telprivato: TumEdit;
    TSAltreFFAA: TTabSheet;
    TSarma: TTabSheet;
    TSCorsi: TTabSheet;
    TSFamiliari: TTabSheet;
    TSgradi: TTabSheet;
    TSOnorificenze: TTabSheet;
    TSPatenti: TTabSheet;
    TSRicompense: TTabSheet;
    TSspecializzazioni: TTabSheet;
    TSStatoGiuridico: TTabSheet;
    TSTessere: TTabSheet;
    TStrasferimenti: TTabSheet;
    TSValutazione: TTabSheet;
    viaresidenza: TumEdit;
    WTnav: TWTNavigator;
    procedure cognomeKeyPress(Sender: TObject; var Key: char);
    procedure ECdatiBeforeDelete(Sender: Tobject; var where: string);
    procedure ECdatiBeforeFind(Sender: Tobject; var CampiValori, CampiWhere,
      CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
      var SelectCustomer: string; var EndOr: string);
    procedure ECdatiBeforeUpdate(Sender: Tobject; var where, CampiValore: string);
    procedure ECdatiContatore(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure kscomuneExit(Sender: TObject);
    procedure ksrepartoExit(Sender: TObject);
    procedure ksresidenzaExit(Sender: TObject);
    procedure Label22Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MIanniClick(Sender: TObject);
    procedure MIEsportaClick(Sender: TObject);
    procedure MIexlClick(Sender: TObject);
    procedure MIfiltroClick(Sender: TObject);
    procedure MIPrintDatiClick(Sender: TObject);
    procedure MIRichiestaTesseraClick(Sender: TObject);
    procedure MIStampaAllSchedaPdfClick(Sender: TObject);
    procedure MIStampaSchedaClick(Sender: TObject);
    procedure MIStampaSchedaPdfClick(Sender: TObject);
    procedure MITesseraClick(Sender: TObject);
    procedure MIwordClick(Sender: TObject);
    procedure PCChange(Sender: TObject);
    procedure SBfiltroClick(Sender: TObject);
    procedure WTnavBeforeClick(Sender: TObject; var Button: TNavButtonType;
      var EseguiPost: Boolean);
    procedure WTnavClick(Sender: TObject; Button: TNavButtonType);
  private
    procedure AggiornaFiltri;
    procedure SearchAllTables; //ricerca il nominativo su tutte le tabella e abilita le icone per il componente pagecontrol
    procedure PreparaMenuReparti(reparti:string = ''); //In base all'autorizzazione, preparo l'elenco dei reparti per il menu  ViewRearti
    procedure StampaMilitariReparto(Sender: TObject);
    { private declarations }
  public
    function CheckGrant:boolean; //controlla le autorizzazioni e abilita i grant
    function CheckGrantTab(NameTab:string):Integer; // controlla le autorizzazioni per i vari tab
    { public declarations }

  end;

var
  FmDatiPersonali: TFmDatiPersonali;
  GrantPr: TGrantPr;

implementation

uses DM_f, main_f, fraltreffaa_f, frarma_f, frcorsi_f, frfamiliari_f, frgradi_f,
  fricompense_f, fronorificenze_f, frpatenti_f, frspec_f, frstatogiuridico_f,
  frtessere_f, frtrasferimenti_f, frvalutazione_f, FrRicercaSuschede_f,
  FmModelliWord_f, fmcomunicazioni_f, fmexportexcel_f, fminsmulval_f,
  FmStampe_f, fmmodspec_f,  LSystemTrita, db;

Var FrGradi :         TFrGradi;
    FrTrasferimenti:  TFrTrasferimenti;
    FrSpec:           TFrSpec;
    FrArma:           TFrArma;
    FrFamiliari:      TFrFamiliari;
    FrAltreFFAA :     TFrAltreFFAA;
    FrPatenti:        TFrPatenti;
    FrTessere:        TFrTessere;
    FrStatoGiuridico: TFrStatoGiuridico;
    FrValutazione:    TFrValutazione;
    FrCorsi:          TFrCorsi;
    FrRicompense:     TFrRicompense;
    FrOnorificenze:   TFrOnorificenze;

{$R *.lfm}

{ TFmDatiPersonali }

procedure TFmDatiPersonali.FormShow(Sender: TObject);
Var x:integer;
begin
  Panel1.SetFocus;
  lmilitari.Caption:= user.nominativo;
  ECdati.Clear_Edit;
  pc.ActivePageIndex:= -1;
  for x:= 0 to pc.PageCount -1 do
    pc.Pages[x].ImageIndex:= -1  ;
 //  Gestione Permessi
//  CheckGrant;

end;

procedure TFmDatiPersonali.kscomuneExit(Sender: TObject);
begin
  PR.Text:= kscomune.FindField('PR');
  arruolato.SetFocus;
end;

procedure TFmDatiPersonali.ksrepartoExit(Sender: TObject);
begin
    AggiornaFiltri;
end;

procedure TFmDatiPersonali.ksresidenzaExit(Sender: TObject);
begin
  Prr.Text:= ksresidenza.FindField('PR');
  viaresidenza.SetFocus;
end;

procedure TFmDatiPersonali.Label22Click(Sender: TObject);
Var titolo,st: string;
begin
  if ECdati.stato in [dsEdit, dsInsert] then
    begin
     titolo:= InputBox('Inserisci un nuovo titolo di studio','Titolo di Studio','');
     if titolo <> '' then
       begin
        titolo:= Ch_apostrofo(Trim(UpperCase(titolo)));
        st:= ' Select * from titolidistudio where titolodistudio = ''' + titolo + '''';
        if not EseguiSQL(dm.QTabelle,st,Open,'') then
          begin
            titolo:= UpperCase(titolo);
            st:= 'INSERT INTO TITOLIDISTUDIO (TITOLODISTUDIO) VALUES (:TITOLODISTUDIO)';
            dm.QTemp.SQL.Text:=st;
            dm.QTemp.Params.ByNameAsString['TITOLODISTUDIO']:= titolo;
            dm.QTemp.ExecSQL;
          end
        else
         begin
           Showmessage(titolo + ' già presente in archivio');
           KStitolodistudio.SetFocus;
         end;
       end;
    end;
end;



procedure TFmDatiPersonali.MenuItem2Click(Sender: TObject);
begin
  FmComunicazioni.Comunicazione:=InvioDoc;
  FmComunicazioni.ShowModal;
end;

procedure TFmDatiPersonali.MenuItem6Click(Sender: TObject);
begin
  FmInsMulVal.ShowModal;
end;

procedure TFmDatiPersonali.MenuItem7Click(Sender: TObject);
begin
  if (Autorizzato.IndexOf('AMMINISTRATORE') > -1) or (user.idsitforza = '8') or
     (Autorizzato.IndexOf('MODIFICA GLOBALE') > -1) then
     fmmodspec.ShowModal;
end;

procedure TFmDatiPersonali.MIanniClick(Sender: TObject);
begin
   if matrmec.Text <> '' then
      fmexportexcel.EsportaAnni;
end;

procedure TFmDatiPersonali.MIEsportaClick(Sender: TObject);
begin
    if matrmec.Text <> '' then
      fmexportexcel.ShowModal;
end;

procedure TFmDatiPersonali.MIexlClick(Sender: TObject);
begin

end;



procedure TFmDatiPersonali.MIfiltroClick(Sender: TObject);
begin
  ECdati.Find(False);
  ShowMessage(ECdati.filtro);
end;

procedure TFmDatiPersonali.MIPrintDatiClick(Sender: TObject);
begin
 if cognome.Text <> '' then
   FmStampe.StampaDatiPersonali;
end;

procedure TFmDatiPersonali.MIRichiestaTesseraClick(Sender: TObject);
begin
  if matrmec.Text <> ''  then
    begin
     FmStampe.PrepataStampaTessera;
     FmStampe.StampaRichiestaTessera;
    end;
end;

procedure TFmDatiPersonali.MIwordClick(Sender: TObject);
begin
   FmModelliWord.Show;
end;

procedure TFmDatiPersonali.PCChange(Sender: TObject);
Var Grant:integer;
begin
 if cognome.Text <> '' then
 begin
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   if PC.ActivePage = TSgradi then //gradi
     begin
       if  not Assigned(FrGradi) then
         begin
           FrGradi:= TFrGradi.Create(TSGradi);
           FrGradi.Parent := TSGradi;
         end;
       Grant:= CheckGrantTab('GRADI');
       if Grant > 0 then
         FrGradi.Esegui(Grant)
       else
         PC.ActivePage:= nil;
     end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TStrasferimenti then   //trasferimenti
   begin
     if  not Assigned(FrTrasferimenti) then
       begin
         FrTrasferimenti:= TFrTrasferimenti.Create(TStrasferimenti);
         FrTrasferimenti.Parent := TStrasferimenti;
       end;
       Grant:= CheckGrantTab('SEDI');
       if Grant > 0 then
         FrTrasferimenti.Esegui(Grant)
       else
         PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSspecializzazioni then   //specializzazioni
   begin
     if  not Assigned(FrSpec) then
       begin
         FrSpec:= TFrSpec.Create(TSspecializzazioni);
         FrSpec.Parent := TSspecializzazioni;
       end;
     Grant:= CheckGrantTab('SPECIALIZZAZIONI');
     if Grant > 0 then
       FrSpec.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSarma then   //Arma
   begin
     if  not Assigned(FrArma) then
       begin
         FrArma:= TFrArma.Create(TSarma);
         FrArma.Parent := TSarma;
       end;
     Grant:= CheckGrantTab('ARMA');
     if Grant > 0 then
       FrArma.Esegui(Grant)
     else
       PC.ActivePage:= nil
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSFamiliari then   //Familiari
   begin
     if  not Assigned(FrFamiliari) then
       begin
         FrFamiliari:= TFrFamiliari.Create(TSFamiliari);
         FrFamiliari.Parent := TSFamiliari;
       end;
     Grant:= CheckGrantTab('FAMILIARI');
     if Grant > 0 then
       FrFamiliari.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSAltreFFAA then   //Altre FFAA
   begin
     if  not Assigned(FrAltreFFAA) then
       begin
         FrAltreFFAA:= TFrAltreFFAA.Create(TSAltreFFAA);
         FrAltreFFAA.Parent := TSAltreFFAA;
       end;
     Grant:= CheckGrantTab('ALTREFORZEARMATE');
     if Grant > 0 then
       FrAltreFFAA.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSPatenti then   //Patenti
   begin
     if  not Assigned(FrPatenti) then
       begin
         FrPatenti:= TFrPatenti.Create(TSPatenti);
         FrPatenti.Parent := TSPatenti;
       end;
     Grant:= CheckGrantTab('PATENTI');
     if Grant > 0 then
       FrPatenti.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSTessere then   //Tessere
   begin
     if  not Assigned(FrTessere) then
       begin
         FrTessere:= TFrTessere.Create(TSTessere);
         FrTessere.Parent := TSTessere;
       end;
     Grant:= CheckGrantTab('TESSERE');
     if Grant > 0 then
       FrTessere.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSStatoGiuridico then   //Posizione
   begin
     if  not Assigned(FrStatoGiuridico) then
       begin
         FrStatoGiuridico:= TFrStatoGiuridico.Create(TSStatoGiuridico);
         FrStatoGiuridico.Parent := TSStatoGiuridico;
       end;
     Grant:= CheckGrantTab('POSIZIONE');
     if Grant > 0 then
       FrStatoGiuridico.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSValutazione then   //Valutazione
   begin
     if  not Assigned(FrValutazione) then
       begin
         FrValutazione:= TFrValutazione.Create(TSValutazione);
         FrValutazione.Parent := TSValutazione;
       end;
     Grant:= CheckGrantTab('VALUTAZIONE');
     if Grant > 0 then
       FrValutazione.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSCorsi then   //Corsi
   begin
     if  not Assigned(FrCorsi) then
       begin
         FrCorsi:= TFrCorsi.Create(TSCorsi);
         FrCorsi.Parent := TSCorsi;
       end;
     Grant:= CheckGrantTab('CORSI');
     if Grant > 0 then
       FrCorsi.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSRicompense then   //Ricompense
   begin
     if  not Assigned(FrRicompense) then
       begin
         FrRicompense:= TFrRicompense.Create(TSricompense);
         FrRicompense.Parent := TSRicompense;
       end;
     Grant:= CheckGrantTab('RICOMPENSE');
     if Grant > 0 then
       FrRicompense.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   else if PC.ActivePage = TSOnorificenze then   //Ricompense
   begin
     if  not Assigned(FrOnorificenze) then
       begin
         FrOnorificenze:= TFrOnorificenze.Create(TSOnorificenze);
         FrOnorificenze.Parent := TSOnorificenze;
       end;
     Grant:= CheckGrantTab('ONORIFICENZE         ');
     if Grant > 0 then
       FrOnorificenze.Esegui(Grant)
     else
       PC.ActivePage:= nil;
   end;
 end;
end;



procedure TFmDatiPersonali.SBfiltroClick(Sender: TObject);
begin
  FmRicercaSuSchede.ShowModal;
end;



procedure TFmDatiPersonali.WTnavBeforeClick(Sender: TObject;
  var Button: TNavButtonType; var EseguiPost: Boolean);
Var x:Integer;
begin
 if button in [nbtFind] then
    begin
      presente.Checked:= False;
      dm.TR.Commit;
      dm.DSetDati.Active:=false;
      for x:= 0 to pc.PageCount -1 do
         pc.Pages[x].ImageIndex:= -1  ;
    end;
end;

procedure TFmDatiPersonali.WTnavClick(Sender: TObject; Button: TNavButtonType);
begin

 cognome.SetFocus;
 pc.TabIndex := -1;
 if button in [nbtPost] then
   begin
     Panel1.SetFocus;
     AggiornaFiltri;
   end;
//cambio il colore dello stato giuridico se un militare non più presente
 if ksstatogiuridico.Text <> 'PRESENTE' then
  begin
    ksstatogiuridico.Font.Style:=[fsBold];
//     ksstatogiuridico.Font.Color:= clFuchsia;
  end
 else
   begin
    ksstatogiuridico.Font.Style:=[];
//     ksstatogiuridico.Font.Color:= clDefault;
   end;

end;

//aggiorna il filtro per il combox articolazioni in base al reparto scelto
procedure TFmDatiPersonali.AggiornaFiltri;
Var st:string;
begin
  st:= 'SELECT * FROM ARTICOLAZIONI WHERE  ';
  st:= st + ' KSREPARTO = ' + ksreparto.ValueLookField;
  ksarticolazione.Sql.Text:= st;
end;

procedure TFmDatiPersonali.SearchAllTables;
Var st:string;
begin
  if dm.DSetDati.Active then
    begin
      st:= 'SELECT * FROM SEARCHALLTABLES(';
      st:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ')';
      dm.QTemp.SQL.Text:= st;
      dm.QTemp.Open;
      TSgradi.ImageIndex:=            dm.QTemp.Fields.ByNameAsInteger['gradi'];
      TStrasferimenti.ImageIndex:=    dm.QTemp.Fields.ByNameAsInteger['trasferimenti'];
      TSspecializzazioni.ImageIndex:= dm.QTemp.Fields.ByNameAsInteger['specializzazioni'];
      TSarma.ImageIndex:=             dm.QTemp.Fields.ByNameAsInteger['arma'];
      TSFamiliari.ImageIndex:=        dm.QTemp.Fields.ByNameAsInteger['parentele'];
      TSAltreFFAA.ImageIndex:=        dm.QTemp.Fields.ByNameAsInteger['altreffaa'];
      TSPatenti.ImageIndex:=          dm.QTemp.Fields.ByNameAsInteger['patenti'];
      TSTessere.ImageIndex:=          dm.QTemp.Fields.ByNameAsInteger['tessere'];
      TSStatoGiuridico.ImageIndex:=   dm.QTemp.Fields.ByNameAsInteger['statogiuridico'];
      TSValutazione.ImageIndex:=      dm.QTemp.Fields.ByNameAsInteger['valutazione'];
      TSCorsi.ImageIndex:=            dm.QTemp.Fields.ByNameAsInteger['corsi'];
      TSRicompense.ImageIndex:=       dm.QTemp.Fields.ByNameAsInteger['ricompense'];
      TSOnorificenze.ImageIndex:=     dm.QTemp.Fields.ByNameAsInteger['onorificenze'];
    end;
end;

//Assegno al Menu Reparti i reparti di Competenza per il militare che si è loggato
procedure TFmDatiPersonali.PreparaMenuReparti(reparti:string);
Var st,where:string;
    TempMI:TMenuItem;
begin
 st:= 'SELECT IDREPARTO,REPARTO,IDSITFORZA FROM REPARTI ';
 if reparti = 'tutti' then
   begin
     where:= ' where idsitforza > 0 ';
   end
 else
   begin
     if user.IdCompetenza <> '' then
       begin
         where:= ' where idreparto in (' + user.IdCompetenza + ')';
         GrantPr.FiltroCompleto:= ' ksreparto in (' + user.IdCompetenza + ')'

       end
     else
       begin
         where:= ' where idreparto = ' + IntToStr(user.ksreparto);
         GrantPr.FiltroCompleto:= 'KSREPARTO = ' + IntToStr(user.ksreparto);
       end;
   end;
 st:= st + where;
 dm.QTemp.SQL.Text:=st;
  dm.QTemp.Open;
  MIViewReparti.Clear;
  while not dm.QTemp.Eof do
    begin
       TempMI:= TMenuItem.Create(MainMenu);
       TempMI.Caption:= dm.QTemp.Fields.ByNameAsString['reparto'];
       TempMI.Tag:= dm.QTemp.Fields.ByNameAsInteger['idreparto'];
       TempMI.OnClick:= @StampaMilitariReparto;
       TempMI.ImageIndex:= 8;
       MIViewReparti.Add(TempMI);
       dm.QTemp.Next;
    end;

 // TempMI.Free;

end;

procedure TFmDatiPersonali.StampaMilitariReparto(Sender: TObject);
begin
  FmStampe.StampaMilitari(TMenuItem(sender).Tag);
end;

function TFmDatiPersonali.CheckGrant: boolean;
Var x:integer;
begin
  // stabilisco i dati di default
  Result:= False;
  provinciale.Visible:= True;
  //azzero le restrizioni per la vista solo del reparto di appartenenza
  GrantPr.idsitforza:='';
  GrantPr.ksreparto:= 0;
  GrantPr.FiltroCompleto:='';
  GrantPr.FiltroPresenti:='';
  MItabelle.Visible:= False;
  MIcomunicazioni.Visible:=False;
  ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE REPARTO CONTAINING :REPARTO';
  for x:= 0 to autorizzato.Count -1 do
   begin
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'AMMINISTRATORE' then
       begin
           WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast,
                                   nbtInsert, nbtDelete, nbtEdit, nbtPost, nbtCancel, nbtRefresh, nbtFind];
           Lgrant.Caption:='Grant: Amministratore';
           PreparaMenuReparti('tutti');
           result:= True;
           MItabelle.Visible:= True;
           MIcomunicazioni.Visible:= True;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'VISTA GLOBALE' then
       begin
           WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast,nbtFind, nbtPost];
           Lgrant.Caption:='Grant: Vista Globale';
           PreparaMenuReparti('tutti');
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'MODIFICA GLOBALE' then
       begin
         WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast,
                                nbtInsert, nbtDelete, nbtEdit, nbtPost, nbtCancel, nbtRefresh, nbtFind];
         Lgrant.Caption:='Grant: Modifica Globale';
         PreparaMenuReparti('tutti');
         result:= True;
         MItabelle.Visible:= True;
         MIcomunicazioni.Visible:=True;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'VISTA REPARTO' then
       begin
           WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast,nbtFind, nbtPost];
           Lgrant.Caption:='Grant: Vista Repaarto';
           if  user.IdCompetenza = '' then   // se il militare non appartiene a un reparto superiore vede solo i militari del suo reparto
             begin
               GrantPr.ksreparto:= user.ksreparto;
               ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto = ' + IntToStr(user.ksreparto);
               ksarticolazione.Sql.Text:='';
               PreparaMenuReparti('');
             end
            else
              begin
               ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto in (' + USER.IdCompetenza + ')';
               PreparaMenuReparti('');
              end;
           GrantPr.idsitforza:= user.idsitforza;
           provinciale.Visible:= False;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'MODIFICA REPARTO' then
       begin
          Lgrant.Caption:='Grant: Modifica Reparto';
          WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast, nbtInsert,
                                  nbtEdit, nbtPost, nbtCancel, nbtRefresh, nbtFind];
           if  user.IdCompetenza = '' then   // se il militare non appartiene a un reparto superiore vede solo i militari del suo reparto
            begin
              GrantPr.ksreparto:= user.ksreparto;
              ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto = ' + IntToStr(user.ksreparto);
              ksarticolazione.Sql.Text:='';
              PreparaMenuReparti('');
            end
          else
            begin
              ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto in (' + USER.IdCompetenza + ')';
              PreparaMenuReparti('');
              MIcomunicazioni.Visible:=True;
            end;
          GrantPr.idsitforza:= user.idsitforza;
          provinciale.Visible:= False;
          result:= True;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'VISTA PARZIALE REPARTO' then
       begin
           Lgrant.Caption:='Grant: Vista Parziale Reparto';
           WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast,nbtFind, nbtPost];
           if  user.IdCompetenza = '' then   // se il militare non appartiene a un reparto superiore vede solo i militari del suo reparto
            begin
               GrantPr.ksreparto:= user.ksreparto;
               ksreparto.Sql.Text:= '';
               ksarticolazione.Sql.Text:='SELECT * FROM REPARTI WHERE idreparto = ' + IntToStr(user.ksreparto);
               PreparaMenuReparti('');
            end
           else
            begin
              ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto in (' + USER.IdCompetenza + ')';
              PreparaMenuReparti('');
            end;
           GrantPr.idsitforza:= user.idsitforza;
           provinciale.Visible:= False;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          if autorizzato[x] = 'VISTA PARZIALE REGIONALE' then
       begin
           Lgrant.Caption:='Grant: Vista Parziale Regionale';
           WTnav.VisibleButtons:= [nbtFirst, nbtPrior, nbtNext, nbtLast,nbtFind, nbtPost];
           provinciale.Visible:= False;
       end;
   end;
   //restringe la visibilità solo per i militari presenti
   if GrantPr.FiltroCompleto <> '' then
     GrantPr.FiltroPresenti:= GrantPr.FiltroCompleto + ' and  VISUALIZZANOMI = ' + '''S'''
   else
     GrantPr.FiltroPresenti:= ' VISUALIZZANOMI = ' + '''S'''
end;

function TFmDatiPersonali.CheckGrantTab(NameTab: string): Integer;
Var x:integer;
     OkModifica:Boolean;
begin
 // GRANT = 0 NON TROVATO
 // GRANT = 2 MODIFICA
 // GRANT = 4 LETTURA
 Result:= 0;
 OkModifica:=False;
 for x:= 0 to autorizzato.Count -1 do
  begin
    if (autorizzato[x] = 'AMMINISTRATORE') or  (autorizzato[x]= 'MODIFICA REPARTO')
      or (autorizzato[x]= 'MODIFICA GLOBALE') then
      begin
        OkModifica:= True;
        Break;
      end;
  end;

 if OkModifica  then   // se si hanno già i diritti di modifica ritorno il valore True
   Result:= 2
 else
   begin
     for x:= 0 to autorizzato.Count -1 do
      begin
       //    ShowMessage(NameTab + '  ' + autorizzato[x]);
        if pos(NameTab,autorizzato[x]) > 0 then
        begin
         if pos('MODIFICA',autorizzato[x]) > 0 then
            Result:= 2
         else
            Result:= 4;
           end;
      end;
      //if not result then ShowMessage('Militare non Abilitato per ' + NameTab);
   end;
end;

procedure TFmDatiPersonali.ECdatiBeforeDelete(Sender: Tobject; var where: string
  );
begin
   where:=  'idmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString;
end;

procedure TFmDatiPersonali.ECdatiBeforeFind(Sender: Tobject; var CampiValori,
  CampiWhere, CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
  var SelectCustomer: string; var EndOr: string);
begin
  SelectCustomer:= 'SELECT * FROM VIEW_DATIPERSONALI ANAGRAFICA';
 if  presente.Checked then
    CampiWhere:= GrantPr.FiltroPresenti
  else
    CampiWhere:= GrantPr.FiltroCompleto;
end;

procedure TFmDatiPersonali.cognomeKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
    WTnav.ActiveButton('Conferma');
end;



procedure TFmDatiPersonali.ECdatiBeforeUpdate(Sender: Tobject; var where,
  CampiValore: string);
begin
    where:=  'idmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString;
end;

procedure TFmDatiPersonali.ECdatiContatore(Sender: TObject);
begin
   Lcontatore.Caption :=  'Trovati nr ' + ECdati.contatore;
  if dm.DSetDati.Active then
    MIStampaAllSchedaPdf.Visible:= (dm.DSetDati.RecordCount > 1);
  SearchAllTables;
end;

procedure TFmDatiPersonali.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
    dm.TR.Commit;
end;

procedure TFmDatiPersonali.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (key = 34) and (matrmec.Text <> '') then
      WTnav.ActiveButton('Successivo');
   if (key = 33) and (matrmec.Text <> '') then
      WTnav.ActiveButton('Precedente');
end;


///////
procedure TFmDatiPersonali.MIStampaSchedaClick(Sender: TObject);
begin
  if matrmec.Text <> ''  then
    FmStampe.StampaSchedaPersonale;
end;

procedure TFmDatiPersonali.MIStampaSchedaPdfClick(Sender: TObject);
begin
  if matrmec.Text <> ''  then
   FmStampe.StampaSchedaPdf;
end;

procedure TFmDatiPersonali.MITesseraClick(Sender: TObject);
begin
   if Autorizzato.IndexOf('AMMINISTRATORE') > -1 then
     begin
       DM.LoadFromDB('RichiestaTessera',FmStampe.frRichiestaTessera);
       FmStampe.frRichiestaTessera.DesignReport;
       DM.SaveToDB('RichiestaTessera',FmStampe.frRichiestaTessera);
     end;
end;


procedure TFmDatiPersonali.MIStampaAllSchedaPdfClick(Sender: TObject);
begin
   if matrmec.Text <> ''  then
     FmStampe.StampaSchedePdfFiltro;
end;


procedure TFmDatiPersonali.MenuItem3Click(Sender: TObject);
begin
   if Autorizzato.IndexOf('AMMINISTRATORE') > -1 then
   begin
     DM.LoadFromDB('ElencoFotoReparto',FmStampe.frAnagrafica);
     FmStampe.frAnagrafica.DesignReport;
     DM.SaveToDB('ElencoFotoReparto',FmStampe.frAnagrafica);
   end;
end;

procedure TFmDatiPersonali.MenuItem4Click(Sender: TObject);
begin
   if Autorizzato.IndexOf('AMMINISTRATORE') > -1 then
   begin
     DM.LoadFromDB('Scheda',FmStampe.frAnagrafica);
     FmStampe.frAnagrafica.DesignReport;
     DM.SaveToDB('Scheda',FmStampe.frAnagrafica);
   end;
end;

procedure TFmDatiPersonali.MenuItem5Click(Sender: TObject);
begin
 if Autorizzato.IndexOf('AMMINISTRATORE') > -1 then
     begin
       DM.LoadFromDB('Scadenze',FmStampe.frAnagrafica);
       FmStampe.frAnagrafica.DesignReport;
       DM.SaveToDB('Scadenze',FmStampe.frAnagrafica);
     end;
end;


end.

