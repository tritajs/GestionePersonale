program GestionePersonale;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, laz_fpspreadsheet, uiblaz, main_f, DM_f, fmautorizzazioni_f,
  fmdatipersonali_f, FrRicercaSuschede_f, FmModelliWord_f, fmcomunicazioni_f,
  fmexportexcel_f, fminsmulval_f, FmStampe_f, lazreportpdfexport, fminscorsi_f,
  fmsituazioneforza_f, fmcambiautente_f, fmmodspec_f, fmnote_f, frcontributi_f;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(Tmain, main);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFmAutorizzazioni, FmAutorizzazioni);
  Application.CreateForm(TFmDatiPersonali, FmDatiPersonali);
  Application.CreateForm(TFmModelliWord, FmModelliWord);
  Application.CreateForm(TFmComunicazioni, FmComunicazioni);
  Application.CreateForm(TFmExportExcel, FmExportExcel);
  Application.CreateForm(Tfminsmulval, fminsmulval);
  Application.CreateForm(TFmStampe, FmStampe);
  Application.CreateForm(TFmCambiaUtente, FmCambiaUtente);
  Application.CreateForm(Tfmmodspec, fmmodspec);
  Application.CreateForm(TFmNote, FmNote);
  Application.Run;
end.

