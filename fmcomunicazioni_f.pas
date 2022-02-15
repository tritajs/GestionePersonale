unit fmcomunicazioni_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, fmdatipersonali_f, main_f, WTekrtf, WTStringGridSql;

type

  { TFmComunicazioni }
  TComunicazione = (InvioDoc);
  TFiltro = record
    Select:string;
    From :string;
    Where:string;
  end;

  TFmComunicazioni = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Panel1: TPanel;
    SBCanc: TSpeedButton;
    SBPrint: TSpeedButton;
    WTekrtf1: TWTekrtf;
    sg: TwtStringGridSql;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SBCancClick(Sender: TObject);
    procedure SBPrintClick(Sender: TObject);
    procedure WTekrtf1GetValue(const ParName: String; var ParValue: String);
  private
    procedure PreparaFiltro;
    { private declarations }
  public
    Comunicazione:TComunicazione;
    { public declarations }
  end;

var
  FmComunicazioni: TFmComunicazioni;

implementation

uses DM_f;

Var Filtro:TFiltro;
    DirectoryModelli:String;

{$R *.lfm}

{ TFmComunicazioni }



procedure TFmComunicazioni.FormCreate(Sender: TObject);
begin
  DirectoryModelli:= GetCurrentDir + '\modelli\';
end;

procedure TFmComunicazioni.FormShow(Sender: TObject);
begin
  case Comunicazione of
   InvioDoc:
    begin
      Label1.Caption:= 'Invio Documentazione Caratteristica';
      PreparaFiltro;
      sg.Sql.Text:= Filtro.Select + Filtro.From +  ' where ' + Filtro.Where + ' order by cognome';
      sg.Active:= True;
    end;
  end;
end;

procedure TFmComunicazioni.SBCancClick(Sender: TObject);
Var st:string;
begin
 case Comunicazione of
   InvioDoc:
    begin
      if MessageDlg('Deselezione', 'Confermi la deselezione dei nominativi in elenco', mtConfirmation, [mbYes, mbNo],0) = mrYes  then
        begin
          if not dm.DSetTemp.Active then
            dm.DSetTemp.Open;
          dm.DSetTemp.First;
          while not dm.DSetTemp.EOF do
            begin
              st:= 'update LISTADOCCAR set datrasmettere = 0 where idlistadc = ';
              st:= st + dm.DSetTemp.FieldByName('idlistadc').AsString;
              dm.QTemp.SQL.Text:= st;
              dm.QTemp.Open();
              dm.DSetTemp.Next;
            end;
          dm.TR.Commit;
          close;
        end;
    end;
  end;
end;

procedure TFmComunicazioni.SBPrintClick(Sender: TObject);
begin
 case Comunicazione of
  InvioDoc:
   begin
     if not dm.DSetTemp.Active then
       dm.DSetTemp.Open;
     dm.DSetTemp.Last;
     dm.DSetTemp.First;
     WTekrtf1.InputFile:= DirectoryModelli + 'inviodocumentazione.rtf';
      // setto il percorso del file temporaneo
     WTekrtf1.OutputFile:= GetEnvironmentVariable('TEMP') + '\tmpinviodoc.doc';
     WTekrtf1.Execute([dm.DSetTemp]);
   end;
 end;
end;

procedure TFmComunicazioni.WTekrtf1GetValue(const ParName: String;
  var ParValue: String);
begin
  if ParName = 'TOTDOC' then
     ParValue:= IntToStr(dm.DSetTemp.RecordCount);
end;



procedure TFmComunicazioni.PreparaFiltro;
Var st:string;
begin
 case Comunicazione of
   InvioDoc:
     begin
       st:= ' SELECT  a4.GRADO, a3.COGNOME,a3.NOME,a1.TIPODOC,a2.MOTIVO,  a.DAL, a.AL , a.DATRASMETTERE , a.IDLISTADC';
       Filtro.Select:= st;
       st:= ' FROM LISTADOCCAR a LEFT JOIN TIPODOCCAR a1 on (a.KSTIPODC = a1.IDTIPODC) ';
       st:= st + ' LEFT JOIN MOTIVICHIUSURADOCCAR a2 on (a.KSMOTIVO = a2.IDMOTIVO) ';
       st:= st + ' left join ANAGRAFICA a3  on (a.KSMILITARE = a3.IDMILITARE) ';
       st:= st + ' left join GRADI      a4  on (a3.KSGRADO   = a4.idgradi) ';
       st:= st + ' left join STATO      a5  on (a3.KSSTATOGIURIDICO   = a5.idstato) ';
       st:= st + ' left join REPARTI    a6  on (a3.KSREPARTO     = a6.IDREPARTO) ';
       Filtro.From:= st;
       Filtro.Where:= ' a6.IDSITFORZA = ' + user.idsitforza + ' and a.datrasmettere = 1';
       dm.DSetTemp.SQL.Text:= Filtro.Select + Filtro.From +  ' where ' + Filtro.Where + ' order by cognome';
//       Memo1.Text:= dm.DSetTemp.SQL.Text;
     end;
  end;
end;



end.

