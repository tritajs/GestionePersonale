unit FmModelliWord_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  FileCtrl, Buttons, StdCtrls, WTekrtf, LCLIntf;

type

  { TFmModelliWord }

  TFmModelliWord = class(TForm)
    FLBlettere: TFileListBox;
    Image1: TImage;
    Memo1: TMemo;
    Panel1: TPanel;
    PanelMenu: TPanel;
    SBIns: TSpeedButton;
    SBdel: TSpeedButton;
    SBOpen: TSpeedButton;
    SBPrint: TSpeedButton;
    SpeedButton1: TSpeedButton;
    WTekrtf1: TWTekrtf;
    procedure FormShow(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBOpenClick(Sender: TObject);
    procedure SBPrintClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FmModelliWord: TFmModelliWord;
  DirectoryModelli:string;

implementation

uses DM_f, main_f;

{$R *.lfm}

{ TFmModelliWord }

procedure TFmModelliWord.SBInsClick(Sender: TObject);
(*var
  S: TStringList;
  ClickedOK: Boolean;
  NewFile,tabella: string;
begin

   ClickedOK := InputQuery('Inserisci il nome del Modello', '', NewFile);
  if ClickedOK then
    begin
      NewFile:= DirectoryModelli + NewFile + '.rtf';
      if FileExists(NewFile) then
        ShowMessage('Attenzione il modello esiste già')
      else
        begin
          S := TStringList.Create;
          try
            S.Add('Questi sono i campi che puoi utilizzare');
            S.Add('\a:cont\ - \a:cat\ - \a:sesso\ - \a:grado\ - \a:cognome\ - \a:nome\ - \a:matrmec\ -  \a:datacongedo\ ');
            S.Add('\a:nato\ - \a:comune\  - \a:pr\ - \a:arruolato\  - \a:reparto\ - \a:codreparto\');
            S.Add('\a:articolazione\ - \a:statocivile\ - \a:celservizio\ - \a:telprivato\ - \a:titolostudio\');
            S.Add('\a:valutazione\ - \a:comuneres\ - \a:viaresidenza\ - \a:sangue\ - \a:incarico\');
            S.SaveToFile(NewFile);
            OpenDocument(NewFile);
          finally
            S.Free;
          end;
        end;
    end; *)

Var modello:string;
    fs: TFileStream;
begin
  FormStyle:= fsStayOnTop;
  modello:= InputBox('','Inserisci in nuovo modello','');
  if modello <> '' then
    begin
      //LEVO EVENTUALI ESTENZIONI
      if pos('.',modello) > 0 then
        modello := Copy(modello,0,pos('.',modello) - 1);
      try
        modello := DirectoryModelli + modello + '.rtf';
        fs:= TFileStream.Create(modello,fmCreate);
//        fs.Write(PChar('{\rtf1}')^, 7);

      fs.Write('{\rtf1}',7);
      finally
        fs.free
      end;
      FLBlettere.UpdateFileList;
      OpenDocument(modello);
    end;
end;


procedure TFmModelliWord.SBOpenClick(Sender: TObject);
Var  modello:string;
begin
  FormStyle:= fsStayOnTop;
  modello:= FLBlettere.Items[FLBlettere.ItemIndex];
  OpenDocument(DirectoryModelli + modello);
end;

procedure TFmModelliWord.SBPrintClick(Sender: TObject);
Var  modello,st:string;
begin
 FormStyle:= fsNormal;
 modello:= FLBlettere.Items[FLBlettere.ItemIndex];
 WTekrtf1.InputFile:= DirectoryModelli + modello;
 // cerco i dati nella tabella Arma
 st:= '  SELECT a.IDARMI, a.KSMILITARE, case a.KSARMA when 1 then ''84 BB'' WHEN 2 then ''92 FS'' else '''' end AS PISTOLA, ';
 ST:= ST + 'a.MATRICOLAPISTOLA, a.MATRICOLACANNA, a.NOTE AS NOTEARMI FROM LISTAARMI a ';
 st:= st + ' where ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 DM.DSetArma.SQL.Text:= st;
 DM.DSetArma.Open;
 // cerco i dati della specializzazioni
 st:= ' SELECT * FROM VIEW_SPECIALIZZAZIONI  ' ;
 st:= st + ' where ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 DM.DSetSpec.SQL.Text:= st;
 DM.DSetSpec.Open;
 WTekrtf1.Execute([dm.DSetDati,DM.DSetArma,DM.DSetSpec]);
end;

procedure TFmModelliWord.SpeedButton1Click(Sender: TObject);
begin
  if  FmModelliWord.Width < 400 then
   begin
      FmModelliWord.Width:= 800;
   end
  else
    FmModelliWord.Width:= 334;
end;

procedure TFmModelliWord.SBdelClick(Sender: TObject);
Var  modello:string;
begin
  modello:= FLBlettere.Items[FLBlettere.ItemIndex];
  if MessageDlg ('Cancella File', 'Sei sicuro di voler cancellare?  ' + modello, mtConfirmation,
                  [mbYes, mbNo],0) = mrYes   then
     begin
       DeleteFile(DirectoryModelli + modello);
       FLBlettere.UpdateFileList;
     end;
end;

procedure TFmModelliWord.FormShow(Sender: TObject);
Var WorkDir:string;
    DirLocal:string;
begin
  FmModelliWord.Width:= 334;
  // setto il percorso del file temporaneo
  DirLocal:= GetEnvironmentVariable('LOCALAPPDATA');
  WorkDir:= DirLocal + '\ModelliGestionale\';
  //directory che contiene i modelli
  If Not DirectoryExists(WorkDir) then
    If Not CreateDir (WorkDir) Then
      Showmessage('Non sono riuscito a creare la directore ' + WorkDir );

  WTekrtf1.OutputFile:= WorkDir + '\temp.doc';
  DirectoryModelli:= WorkDir;
  FLBlettere.Directory:= DirectoryModelli;
end;

end.

