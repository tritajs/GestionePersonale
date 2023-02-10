unit FrRicercaSuschede_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Menus, DBGrids, WTComboBoxSql, WTMemo, WTComboBox,
  wteditcompNew, WTCheckBox, db, umEdit, WDateEdit, fpspreadsheet, LCLIntf,
  ComCtrls, LSystemTrita, fpsTypes;

type

  { TFmRicercaSuSchede }

  TFmRicercaSuSchede = class(TForm)
    al: TWDateEdit;
    cognome: TumEdit;
    dal: TWDateEdit;
    DataRicompensaAl: TWDateEdit;
    dmatrimonio: TWDateEdit;
    dmorte: TWDateEdit;
    ksarma: TWTComboBox;
    kscomune: TWTComboBoxSql;
    KSIDFFAA: TWTComboBoxSql;
    ksparentela: TWTComboBoxSql;
    KSricompensa: TWTComboBoxSql;
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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MATRICOLACANNA: TumEdit;
    MATRICOLAPISTOLA: TumEdit;
    nato: TWDateEdit;
    nome: TumEdit;
    NoteParentela: TWTMemo;
    NotePistola: TWTMemo;
    PC: TPageControl;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    PanelPistola: TPanel;
    Presenti: TCheckBox;
    DS: TDataSource;
    DBGrid1: TDBGrid;
    ImSpec: TImage;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    SBesporta: TSpeedButton;
    SBokForzeArmate: TSpeedButton;
    SBokPistola: TSpeedButton;
    SBokPistola1: TSpeedButton;
    SBokRicompense: TSpeedButton;
    SpeedButton1: TSpeedButton;
    Starting: TMenuItem;
    Containing: TMenuItem;
    Panel2: TPanel;
    Panel5: TPanel;
    PMfiltro: TPopupMenu;
    ksreparto: TWTComboBoxSql;
    TSpatenti: TTabSheet;
    TStessere: TTabSheet;
    TSricompense: TTabSheet;
    TSAltreFA: TTabSheet;
    TSfamiliari: TTabSheet;
    TSArma: TTabSheet;
    DataRicompensaDal: TWDateEdit;
    determina: TumEdit;
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure PCChange(Sender: TObject);
    procedure PresentiChange(Sender: TObject);
    procedure SBesportaClick(Sender: TObject);
    procedure SBokForzeArmateClick(Sender: TObject);
    procedure SBokParentelaClick(Sender: TObject);
    procedure SBokPistolaClick(Sender: TObject);
    procedure SBokRicompenseClick(Sender: TObject);
    procedure SBclean(Sender: TObject);
  private
    GrantFiltro:string;
    procedure CleanComponent;
    { private declarations }
  public
    { public declarations }
  end;

var
  FmRicercaSuSchede: TFmRicercaSuSchede;

implementation

uses DM_f, fmdatipersonali_f, main_f;

{$R *.lfm}

{ TFmRicercaSuSchede }

procedure TFmRicercaSuSchede.SBokPistolaClick(Sender: TObject);
Var st,filtro:string;

begin
  filtro:= '';
  st:= 'SELECT MATRMEC,GRADO,COGNOME,NOME,REPARTO,MATRICOLAPISTOLA,';
  st:= st + ' MATRICOLACANNA, NOTE  from VIEW_ARMA  where ';
  if ksarma.ItemIndex > -1 then
     filtro:= ' ksarma = ' + IntToStr(ksarma.ItemIndex) + ' and ';
  if MATRICOLAPISTOLA.Text <> '' then
     filtro := filtro + ' matricolapistola ' + MATRICOLAPISTOLA.TypeFind + ' ''' + MATRICOLAPISTOLA.Text + ''' and ';
  if MATRICOLACANNA.Text <> '' then
     filtro := filtro + ' matricolacanna ' + MATRICOLACANNA.TypeFind + ' ''' +  MATRICOLACANNA.Text + ''' and ';
  if NotePistola.Text <> '' then
     filtro := filtro + ' note ' + NotePistola.TypeFind + ' ''' + NotePistola.Text + ''' and ';
  if filtro <> '' then
   begin
    filtro:= filtro + GrantFiltro;
  //  Memo1.Text:= st + FILTRO;
    dm.DSetTemp.SQL.Text:= st + filtro;
    dm.DSetTemp.Active:=True;
   end;
end;

procedure TFmRicercaSuSchede.SBokRicompenseClick(Sender: TObject);
Var st,filtro:string;
    DalOK,AlOK:Boolean;
    DataDal,DataAl:string;
begin
  filtro:= '';
  st:= 'SELECT  d.grado,d.COGNOME,d.nome,d.REPARTO, r.RICOMPENSA,r.DETERMINA, r.DATARICOMPENSA, r.AUTORITA';
  st:= st + ' FROM VIEW_RICOMPENSE r inner join VIEW_DATIPERSONALI d on (r.KSMILITARE = d.IDMILITARE)';

  DalOK:= Length(Trim(DataRicompensaDal.Text)) > 4;
  AlOK:=  Length(Trim(DataRicompensaAl.Text)) > 4;
  DataDal:=  DataRicompensaDal.GetDataDB(True);
  DataAl:=   DataRicompensaAl.GetDataDB(True);

  if (KSricompensa.ValueLookField <> '') then
    filtro:=  ' r.KSRICOMPENSA = ' + KSricompensa.ValueLookField + ' and ';
  if(determina.Text <> '')  then
   filtro:= ' r.determina = ' + determina.Text + ' and ';

  if (DalOK and not AlOK)  then
     filtro := filtro + ' r.dataricompensa = ' + DataDal + ' and ';

  if (DalOK and AlOK)  then
     filtro := filtro + ' r.dataricompensa  between ' + DataAl + ' and ' + DataAl + ' and ';

  if (ksreparto.ValueLookField ='') then
    begin
      if user.IdCompetenza <> '' then
        begin
         filtro := filtro + ' d.ksreparto in ''(' + USER.IdCompetenza + ') and ';
        end;
    end
  else
      filtro := filtro + ' d.ksreparto = ' + ksreparto.ValueLookField + ' and ';;

  if filtro <> '' then
   begin
  //  filtro:= Copy(filtro,1,Length(filtro)-4);
    filtro:= ' Where ' + filtro + GrantFiltro;
//    Memo1.Text:= st + FILTRO;
    dm.DSetTemp.SQL.Text:= st + filtro;
    dm.DSetTemp.Active:=True;
   end;
end;

procedure TFmRicercaSuSchede.SBclean(Sender: TObject);
begin
  CleanComponent;
end;

procedure TFmRicercaSuSchede.CleanComponent;
Var i:integer;
begin
 dm.DSetTemp.Close;
 with FmRicercaSuSchede do
  begin
    for i := 0 to ComponentCount - 1 do
    begin
      if Components[i].ClassName = 'TWTCheckBox' then
        TWTCheckBox(Components[i]).Checked:= False
      else if Components[i].ClassName = 'TWTComboBoxSql' then
        begin
          TWTComboBoxSql(Components[i]).ValueLookField:= '';
          TWTComboBoxSql(Components[i]).Text:= '';
        end
      else if Components[i].ClassName = 'TWTComboBox' then
        begin
          TWTComboBox(Components[i]).Text:= '';
          TWTComboBox(Components[i]).ItemIndex:= -1;
        end
      else if Components[i].ClassName = 'TWTimage' then
        // TWTimage(Components[i]).Fimage.Picture.Clear
      else if Components[i].ClassName = 'TWTMemo' then
         TWTMemo(Components[i]).Lines.Text:= ''
      else if Pos(Components[i].ClassName,'TumEdit;TumNumberEdit;TumValidEdit') > 0  then
         TCustomEdit(Components[i]).Text:= ''
      else if Pos(Components[i].ClassName,'TumDataEdit;TWDateEdit;TDateEdit') > 0  then
         TWDateEdit(Components[i]).date := 0;
    end;
  end;
end;


procedure TFmRicercaSuSchede.SBesportaClick(Sender: TObject);
Var
  MyWorkbook: TsWorkbook;
  MyWorksheet: TsWorksheet;
  riga,col:integer;
begin
  if dm.DSetTemp.Active then
     begin
       dm.DSetTemp.First;
       riga:= 0;
       col:= 0;
       MyWorkbook := TsWorkbook.Create;
       MyWorksheet := MyWorkbook.AddWorksheet('My Worksheet');
       for col:= 0 to dm.DSetTemp.FieldCount - 1 do
           MyWorksheet.WriteText(0, col, dm.DSetTemp.Fields[col].DisplayName);// C5
      while not dm.DSetTemp.EOF do
        begin
         inc(riga);
         for col:= 0 to dm.DSetTemp.FieldCount - 1 do
              MyWorksheet.WriteText(riga, col, dm.DSetTemp.Fields[col].AsString);// C5
         dm.DSetTemp.Next;
        end;
      if FileExists(user.FileTemp) then
         DeleteFile(user.FileTemp);
      MyWorkbook.WriteToFile(user.FileTemp,sfExcel5,True);
      MyWorkbook.Free;
    end;
    OpenDocument(user.FileTemp);
end;

procedure TFmRicercaSuSchede.SBokForzeArmateClick(Sender: TObject);
Var
  st,filtro:string;
begin
 filtro:= '';
 st:= 'select MATRMEC,GRADO,COGNOME,NOME,REPARTO,DESCRIZIONEFFAA,DAL,AL from VIEW_ALTREFORZEA ';
  st:= st + ' where ';
  if KSIDFFAA.ValueLookField <> '' then
      filtro:= ' KSIDFFAA = ' + KSIDFFAA.ValueLookField + ' and ';
  if Length(Trim(dal.Text)) > 4  then
     filtro := filtro + ' dal ' + dal.TypeFind + ' ' + dal.GetDataDB(True) + ' and ';
  if Length(Trim(al.Text)) > 4  then
     filtro := filtro + ' al ' + al.TypeFind + ' ' + al.GetDataDB(True) + ' and ';
  if filtro <> '' then
   begin
    filtro:= filtro + GrantFiltro;
  //  Memo1.Text:= st + FILTRO;
    dm.DSetTemp.SQL.Text:= st + filtro;
    dm.DSetTemp.Active:=True;
   end;
end;

procedure TFmRicercaSuSchede.SBokParentelaClick(Sender: TObject);
Var
  st,filtro:string;
begin
 st:= ' SELECT PARENTELA, COGNOME,NOME, NATO,COMUNE, DMATRIMONIO, DMORTE, NOTE, ';
 st:= st + ' MATRMEC,GRADO,COGNOMEMIL,NOMEMIL,REPARTO ';
 st:= st + ' FROM VIEW_PARENTELA WHERE ';
 filtro:= '';
  if ksparentela.ValueLookField <> '' then
     filtro:= ' ksparentela = ' + ksparentela.ValueLookField + ' and ';
   if cognome.Text <> '' then
     filtro := filtro + ' COGNOME ' + cognome.TypeFind + ' ''' + COGNOME.Text + ''' and ';
   if nome.Text <> '' then
     filtro := filtro + ' NOME ' + nome.TypeFind + ' ''' + NOME.Text + ''' and ';
   if Length(Trim(NATO.Text)) > 4  then
     filtro := filtro + ' NATO ' + nato.TypeFind + ' ' + NATO.GetDataDB(True) + ' and ';
   if kscomune.ValueLookField <> '' then
     filtro:= filtro + ' kscomune = ' + kscomune.ValueLookField + ' and ';
   if Length(Trim(dmatrimonio.Text)) > 4  then
     filtro := filtro + ' dmatrimonio ' + dmatrimonio.TypeFind + ' ' + dmatrimonio.GetDataDB(True) + ' and ';
   if Length(Trim(dmorte.Text)) > 4  then
     filtro := filtro + ' dmorte ' + dmorte.TypeFind + ' ' + dmorte.GetDataDB(True) + ' and ';
   if NoteParentela.Text <> '' then
     filtro := filtro + ' note ' + NoteParentela.TypeFind + ' ''' + NoteParentela.Text + ''' and ';
   if filtro <> '' then
    begin

     filtro:= filtro + GrantFiltro;
  //     Memo1.Text:= st + filtro;
     dm.DSetTemp.SQL.Text:= st + filtro;
     dm.DSetTemp.Active:=True;
    end;
end;

procedure TFmRicercaSuSchede.MenuItem1Click(Sender: TObject);
var operatore:string;
     i,PosCompFind:integer;
  //   Fmwtexpression: TFmwtexpression;
begin

 PosCompFind:=0; //posizione nell'array del componenti che ha il focus
 for i:= 0 to ComponentCount - 1 do
   begin
    if Components[i] is TCustomEdit then
      begin
        if TCustomEdit(Components[i]).Focused then
             PosCompFind:= i;
      end
    else if Components[i] is TCustomControl then
      begin
        if TCustomControl(Components[i]).Focused then
             PosCompFind:= i;
      end;
   end;
  operatore:=  TMenuItem(sender).Caption;
  TCustomEdit(Components[PosCompFind]).ShowHint:= True;
  TCustomEdit(Components[PosCompFind]).Hint:= operatore;
  if Components[PosCompFind] is TumEdit then
     TumEdit(Components[PosCompFind]).TypeFind:= operatore;
  if Components[PosCompFind] is TWDateEdit then
     TWDateEdit(Components[PosCompFind]).TypeFind:= operatore;
end;

procedure TFmRicercaSuSchede.PCChange(Sender: TObject);
begin
   dm.DSetTemp.Close;
   CleanComponent;
end;

procedure TFmRicercaSuSchede.PresentiChange(Sender: TObject);
begin
  if presenti.Checked then
    GrantFiltro:= GrantPr.FiltroPresenti
  else
    GrantFiltro:= GrantPr.FiltroCompleto;
end;

procedure TFmRicercaSuSchede.FormShow(Sender: TObject);
begin
 GrantFiltro:= GrantPr.FiltroPresenti;
 dm.DSetTemp.Active:= false;

 if (Autorizzato.IndexOf('AMMINISTRATORE') > -1) or
    (Autorizzato.IndexOf('VISTA GLOBALE') > -1 ) then
   begin
    ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE reparto containing :reparto';
   end
 else
   begin
    if  user.IdCompetenza = '' then   // se il militare non appartiene a un reparto superiore vede solo i militari del suo reparto
     begin
      ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto = ' + IntToStr(user.ksreparto);
      ksreparto.Caption := user.reparto;
      ksreparto.ValueLookField:= IntToStr(user.ksreparto);
     end

    else
      ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto in (' + USER.IdCompetenza + ')';
   end;
end;

end.

