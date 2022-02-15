unit fmfiltrospec_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, CheckLst, StdCtrls, ComCtrls, Menus, DM_f, WTStringGridSql,
  WTComboBoxSql;

type

  { TFmFiltroSpec }
  TFmFiltroSpec = class(TForm)
    CBspec: TWTComboBoxSql;
    ImSpec: TImage;
    ImPatenti: TImage;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    Panel5: TPanel;
    Panel6: TPanel;
    PC: TPageControl;
    Panel1: TPanel;
    SBRicSpec: TSpeedButton;
    SBRicPatenti: TSpeedButton;
    sgspec: TwtStringGridSql;
    sgpatenti: TwtStringGridSql;
    TSpatenti: TTabSheet;
    TSspec: TTabSheet;
    cbpatenti: TWTComboBoxSql;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure PCChange(Sender: TObject);
    procedure SBRicPatentiClick(Sender: TObject);
    procedure SBRicSpecClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FmFiltroSpec: TFmFiltroSpec;
  filtro:string;
implementation

uses fmdatipersonali_f, fmexportexcel_f;

{$R *.lfm}

{ TFmFiltroSpec }

procedure TFmFiltroSpec.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
   CloseAction:= caFree;
end;

procedure TFmFiltroSpec.FormShow(Sender: TObject);
begin
    pc.ActivePageIndex:= 0;
end;

procedure TFmFiltroSpec.MenuItem1Click(Sender: TObject);
begin
  dm.DSetTemp.SQL.Text:=filtro;
  dm.DSetTemp.Open;
  FmExportExcel.EsportaEXL(dm.DSetTemp);
end;

procedure TFmFiltroSpec.PCChange(Sender: TObject);
begin
   if pc.ActivePage = TSpatenti then
    begin
      ImPatenti.Picture.Assign(ImSpec.Picture);
      sgpatenti.Active:=False;
      cbpatenti.Caption:='';
    end;
   if pc.ActivePage = TSspec then
    begin
      sgspec.Active:=False;
      CBspec.Caption:='';
    end;
end;

procedure TFmFiltroSpec.SBRicPatentiClick(Sender: TObject);
Var st:string;
begin
  if CBpatenti.ValueLookField <> '' then
   begin
     DM.TR.Commit;
     st:= 'SELECT MATRMEC,GRADO,COGNOME,NOME,REPARTO,DESCRIZIONEPATENTE,TIPO,NUMEROMOD,DATARILASCIO, ';
     st:= st + ' DATARINNOVO,DATASCADENZA,REPARTO as ENTE,NOTE,DESCRIZIONE FROM VIEW_LISTAPATENTI ';
     st:= st + ' where ' + GrantPr.FiltroPresenti;
     st:= st + ' and  kspatente =';
     st:= st + CBpatenti.ValueLookField;
     st:= st + ' order by cognome';
     filtro:= st;
     sgpatenti.Sql.Text:= filtro;
     sgpatenti.Active:= True;
   end;
end;


procedure TFmFiltroSpec.SBRicSpecClick(Sender: TObject);
Var st,where:string;
begin
  if CBspec.ValueLookField <> '' then
   begin
     DM.TR.Commit;
     st:= ' Select MATRMEC,GRADO,COGNOME,NOME,CONT,SESSO,STATOCIVILE,SPECIALIZZAZIONE,CODSPEC,SPEQUAB,DATASPEC,DATAES, ';
     st:= st + ' REPARTO,ARTICOLAZIONE,OPERATIVO,NATO,COMUNE,PR,ARRUOLATO,NOTE,STATOGIURIDICO from VIEW_LISTASPECIALIZZATI ';
     st:= st + ' where ' + GrantPr.FiltroPresenti;
     st:= st + ' and  ksspec =';
     st:= st + CBspec.ValueLookField;
     st:= st + ' order by cognome';
     filtro:= st;
     sgspec.Sql.Text:= filtro;
     sgspec.Active:= True;
   end;
end;


end.

