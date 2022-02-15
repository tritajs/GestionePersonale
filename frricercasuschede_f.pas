unit FrRicercaSuschede_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Menus, DBGrids, WTComboBoxSql, WTMemo, WTComboBox,
  wteditcompNew, db, umEdit, WDateEdit,fpspreadsheet,LCLIntf, LSystemTrita,fpsTypes;

type

  { TFmRicercaSuSchede }

  TFmRicercaSuSchede = class(TForm)
    Label17: TLabel;
    Ptessere: TPanel;
    Presenti: TCheckBox;
    KSIDFFAA: TWTComboBoxSql;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label9: TLabel;
    dal: TWDateEdit;
    al: TWDateEdit;
    nome: TumEdit;
    DS: TDataSource;
    DBGrid1: TDBGrid;
    ImSpec: TImage;
    ksarma: TWTComboBox;
    kscomune: TWTComboBoxSql;
    ksparentela: TWTComboBoxSql;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    cognome: TumEdit;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    NoteParentela: TWTMemo;
    Panel1: TPanel;
    Panel3: TPanel;
    SBesporta: TSpeedButton;
    SBokPistola1: TSpeedButton;
    SBokForzeArmate: TSpeedButton;
    Starting: TMenuItem;
    Containing: TMenuItem;
    PanelPistola: TPanel;
    Panel2: TPanel;
    Panel5: TPanel;
    PMfiltro: TPopupMenu;
    SBokPistola: TSpeedButton;
    NotePistola: TWTMemo;
    MATRICOLACANNA: TumEdit;
    MATRICOLAPISTOLA: TumEdit;
    nato: TWDateEdit;
    dmatrimonio: TWDateEdit;
    dmorte: TWDateEdit;
    ksreparto: TWTComboBoxSql;
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure PresentiChange(Sender: TObject);
    procedure SBesportaClick(Sender: TObject);
    procedure SBokForzeArmateClick(Sender: TObject);
    procedure SBokParentelaClick(Sender: TObject);
    procedure SBokPistolaClick(Sender: TObject);
  private
    GrantFiltro:string;
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
  st:= 'SELECT MATRMEC,GRADO,COGNOME,NOME,REPARTO,MATRICOLAPISTOLA,';
  st:= st + ' MATRICOLACANNA, NOTE  from VIEW_ARMA  where ';
  if ksarma.ItemIndex > -1 then
     filtro:= ' ksarma = ' + IntToStr(ksarma.ItemIndex) + ' and ';
  if MATRICOLAPISTOLA.Text <> '' then
     filtro := filtro + ' matricolapistola ' + MATRICOLAPISTOLA.TypeFind + ' ''' + MATRICOLAPISTOLA.Text + ''' and ';
  if MATRICOLACANNA.Text <> '' then
     filtro := filtro + ' r.matricolacanna ' + MATRICOLACANNA.TypeFind + ' ''' +  MATRICOLACANNA.Text + ''' and ';
  if NotePistola.Text <> '' then
     filtro := filtro + ' r.note ' + NotePistola.TypeFind + ' ''' + NotePistola.Text + ''' and ';
  if filtro <> '' then
   begin
    filtro:= filtro + GrantFiltro;
 //   Memo1.Text:= st + FILTRO;
    dm.DSetTemp.SQL.Text:= st + filtro;
    dm.DSetTemp.Active:=True;
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
       //  MyDir := ExtractFilePath(ParamStr(0));
       MyWorkbook := TsWorkbook.Create;
     //  MyWorkbook.ReadFromFile('c:\windows\temp\temp.xls',sfExcel8);
      // MyWorksheet := MyWorkbook.GetFirstWorksheet;
       MyWorksheet := MyWorkbook.AddWorksheet('My Worksheet');
       for col:= 0 to dm.DSetTemp.FieldCount - 1 do
           MyWorksheet.WriteUTF8Text(0, col, dm.DSetTemp.Fields[col].DisplayName);// C5
      while not dm.DSetTemp.EOF do
        begin
         inc(riga);
         for col:= 0 to dm.DSetTemp.FieldCount - 1 do
              MyWorksheet.WriteUTF8Text(riga, col, dm.DSetTemp.Fields[col].AsString);// C5
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
var operatore,field:string;
     i,PosCompFind:integer;
  //   Fmwtexpression: TFmwtexpression;
begin
 field:='';
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
 PanelPistola.SetFocus;
 dm.DSetTemp.Active:= false;
 if  user.IdCompetenza = '' then   // se il militare non appartiene a un reparto superiore vede solo i militari del suo reparto
   ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto = ' + IntToStr(user.ksreparto)
 else
   ksreparto.Sql.Text:= 'SELECT * FROM REPARTI WHERE idreparto in (' + USER.IdCompetenza + ')';
end;




end.

