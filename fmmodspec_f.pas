unit fmmodspec_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DBGrids, WTNavigator, wteditcompNew, uibdataset, db, umEdit;

type

  { Tfmmodspec }

  Tfmmodspec = class(TForm)
    areaimpiego: TumEdit;
    codspec: TumEdit;
    DBGrid1: TDBGrid;
    DSetSpec: TUIBDataSet;
    DSspec: TDataSource;
    ecSpec: TwtEditCompNew;
    IDSPEC: TumEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Lcontatore: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    SPECIALIZZAZIONE: TumEdit;
    SPEQUAB: TumEdit;
    WTNav: TWTNavigator;
    procedure DSetSpecAfterScroll(DataSet: TDataSet);
    procedure ecSpecBeforeFind(Sender: Tobject; var CampiValori, CampiWhere,
      CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
      var SelectCustomer: string);
    procedure ecSpecBeforeUpdate(Sender: Tobject; var where, CampiValore: string
      );
    procedure ecSpecContatore(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SPECIALIZZAZIONEKeyPress(Sender: TObject; var Key: char);
    procedure WTNavBeforeClick(Sender: TObject;
      var Button: TNavButtonType; var EseguiPost: Boolean);
    procedure WTNavClick(Sender: TObject; Button: TNavButtonType);
  private

  public

  end;

var
  fmmodspec: Tfmmodspec;

implementation

{$R *.lfm}

{ Tfmmodspec }

procedure Tfmmodspec.WTNavBeforeClick(Sender: TObject;
  var Button: TNavButtonType; var EseguiPost: Boolean);
begin
  if Button in [nbtInsert] then
    DSetSpec.Close;
end;

procedure Tfmmodspec.FormShow(Sender: TObject);
begin
    Panel2.SetFocus;
end;

procedure Tfmmodspec.SPECIALIZZAZIONEKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
    WTnav.ActiveButton('Conferma');
end;

procedure Tfmmodspec.ecSpecContatore(Sender: TObject);
begin
   Lcontatore.Caption :=  'Trovati nr ' + ecSpec.contatore;
end;

procedure Tfmmodspec.ecSpecBeforeFind(Sender: Tobject; var CampiValori,
  CampiWhere, CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
  var SelectCustomer: string);
begin
   indice := 'order by SPECIALIZZAZIONI.SPECIALIZZAZIONE';
end;

procedure Tfmmodspec.ecSpecBeforeUpdate(Sender: Tobject; var where,
  CampiValore: string);
begin
  where := 'idspec = ' + IDSPEC.Text;
end;

procedure Tfmmodspec.DSetSpecAfterScroll(DataSet: TDataSet);
begin
 ecSpec.SayDati;
end;

procedure Tfmmodspec.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  DSetSpec.Active:=fALSE;
end;

procedure Tfmmodspec.WTNavClick(Sender: TObject; Button: TNavButtonType);
begin
  if (button in [nbtFind,nbtEdit,nbtInsert]) then
    SPECIALIZZAZIONE.SetFocus;
  if (button in [nbtPost]) then
    begin
      Panel2.SetFocus;
    end;
end;

end.

