unit DM_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LR_Class, IniFiles, db, Forms, Dialogs, uib,
  uibdataset,  LSystemTrita, LCLType ;

type

  { TDM }

  TDM = class(TDataModule)
    DSArchivi: TDatasource;
    DSetArchivi: TUIBDataSet;
    DB: TUIBDataBase;
    DSetParenti: TUIBDataSet;
    DSetContributi: TUIBDataSet;
    QTabelle: TUIBQuery;
    QTemp1: TUIBQuery;
    TR: TUIBTransaction;
    QTemp: TUIBQuery;
    DSetDati: TUIBDataSet;
    DSetTemp: TUIBDataSet;
    DSetArma: TUIBDataSet;
    DSetSpec: TUIBDataSet;
    DSetCorsi: TUIBDataSet;
    procedure DataModuleCreate(Sender: TObject);
  private
//    function GetRegistryValue: string;
    { private declarations }
  public
    procedure LoadFromDB(NomeReport: string; Report: TfrReport);
    procedure SaveToDB(NomeReport: string; Report: TfrReport);
    function Accesso_Nominativo:Boolean;
    procedure LoadAutorizzazioni;
    //    function Autorizzato(autorizzazione:string):boolean;
    { public declarations }
  end;

var
  DM: TDM;

implementation

uses main_f;

{$R *.lfm}

{ TDM }


procedure TDM.DataModuleCreate(Sender: TObject);
Var
 IniFile: Tinifile;
 FileIni,s,PathSetup:String;
begin

 if tag = 0 then
   begin
    PathSetup:= ExtractFilePath(Application.EXEName) +  'setup\';
    FileIni:=   PathSetup +  'Setup.ini';
    if FileExists(FileIni) { *Converted from FileExists*  } then
      begin
        IniFile:= TIniFile.Create(FileIni);
        DB.DatabaseName:=  IniFile.ReadString('Server','DataBaseNamePersonale','');
        db.LibraryName:=   PathSetup +  IniFile.ReadString('Server','LibPersonale','');
     //   db.Connected:= True;
        IniFile.Free; // After we used ini file, we must call the Free method of object
      end
     else
      begin
        ShowMessage('attenzion e non è presente il file di configurazione, bisogna crearlo!');
        halt;
      end;
    end;



// utente preso dalle variabili d'ambiente

 s:= UpperCase(GetEnvironmentVariable('USERNAME'));
 User.matr:=copy(s,2,6)+copy(s,1,1);
 //directory temporanea
 s:= GetEnvironmentVariable('TEMP');
 if s = '' then
   s:= GetEnvironmentVariable('TMP');
 user.DirectTemp:= s;
 user.FileTemp := s + '\temp.xls' ;


// User.matr:='942597R'; //di blasio settimio
//User.matr:= GetRegistryValue; // restituisce la matricola dell'utente che utilizza il computer
//User.matr:= '852183Q';

//User.matr:= '902708R'; // Cotogno

// User.matr:= '881037E'; // marrone
//User.matr:= '852183Q' // MALANDRA
//User.matr:= '910634Z';
// User.matr:= '951614S'; //PICCIRILLI RUGGERO;
//    User.matr:= '980268R';// buttari deodato
end;


function TDM.Accesso_Nominativo: Boolean;
Var st:string;
begin
  result:= False;
  st:= 'SELECT r.KSREPARTO,r.GRADO, r.MATRMEC, r.REPARTO, r.codreparto, r.PROVINCIALE,' +
       'r.COGNOME, r.NOME, r.IDSITFORZA,r.idcompetenza  ' +
       ' FROM VIEW_DATIPERSONALI r WHERE r.MATRMEC = ' + '''' + user.matr + '''';
  if EseguiSQL(QTemp,st,Open,'') then
    begin
      user.ksreparto:=  QTemp.Fields.ByNameAsInteger['KSREPARTO'];
      user.matr:=       QTemp.Fields.ByNameAsString['MATRMEC']  ;
      user.grado:=      QTemp.Fields.ByNameAsString['GRADO'];
      user.reparto:=    QTemp.Fields.ByNameAsString['REPARTO'];
      user.codreparto:= QTemp.Fields.ByNameAsString['CODREPARTO'];
      user.nominativo:= QTemp.Fields.ByNameAsString['COGNOME'] + ' ' + QTemp.Fields.ByNameAsString['NOME'];
      user.provinciale:=QTemp.Fields.ByNameAsString['PROVINCIALE'];
      user.idsitforza:= QTemp.Fields.ByNameAsString['IDSITFORZA'];
      user.IdCompetenza:= QTemp.Fields.ByNameAsString['IDCOMPETENZA'];
      result:= True;
      LoadAutorizzazioni;
    end;
end;

procedure TDM.LoadAutorizzazioni;
Var st:string;
begin
  //carico le autorizzazioni attribuite al militare
  st:= 'select autorizzato from autorizzazioni where matrmec = ''' + User.matr + '''';
  autorizzato.Clear;
  if EseguiSQL(dm.QTemp,st,Open,'') then
   while not dm.QTemp.Eof do
     begin
       autorizzato.Add(Trim(dm.QTemp.Fields.ByNameAsString['AUTORIZZATO']));
       dm.QTemp.Next;
     end;
end;


procedure TDM.SaveToDB(NomeReport:string;Report:TfrReport);
var
  BoxStyle: Integer;
  st:  array[0..255] of Char;
  Stream: TMemoryStream;
begin
   BoxStyle := MB_ICONQUESTION + MB_YESNO;
   StrPCopy(st,'Vuoi Salvare il reporto nell''archivio? ');
   if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
     begin
      Stream := TMemoryStream.Create;
      Report.SaveToStream(Stream);
      try
        QTemp.BuildStoredProc('SALVAREPORT');
        QTemp.Params.ByNameAsString['NOMEREPORT']:= NomeReport;
        QTemp.ParamsSetBlob('FILEREPORT', Stream);
        QTemp.Open;
      finally
        Stream.Free;
      end;
      QTemp.Close(etmCommitRetaining);
     end;
end;


procedure TDM.LoadFromDB(NomeReport:string;Report: TfrReport);
var
  Stream: TMemoryStream;
begin
  QTemp.SQL.Text := 'Select * From Report where nomereport = ''' + NomeReport  + '''';
  QTemp.Params.Clear;
  QTemp.Open;
  if QTemp.Fields.RecordCount > 0 then
    begin
      Stream := TMemoryStream.Create;
      try
       QTemp.ReadBlob('FILEREPORT', Stream);
       Report.LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
    end;
  QTemp.Close(etmCommitRetaining);
end;

end.






