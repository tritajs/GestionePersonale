unit FmStampe_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LR_Class, LR_Desgn, LR_DBSet, LR_Shape, LR_RRect,
  Forms, Controls, Graphics, Dialogs, DM_f, uibdataset, uib, LCLIntf,  lr_e_pdf,
  LCLType,xlsbiff8, fpspreadsheet,fpsTypes, LSystemTrita, dateutils;

type

  { TFmStampe }

  TFmStampe = class(TForm)
    DsetFamiliari: TUIBDataSet;
    DSetGradi: TUIBDataSet;
    frDSetFamiliari: TfrDBDataSet;
    frDSetSedi: TfrDBDataSet;
    frDset1: TfrDBDataSet;
    frDesigner1: TfrDesigner;
    frAnagrafica: TfrReport;
    frDSetGradi: TfrDBDataSet;
    frDSetFA: TfrDBDataSet;
    frRichiestaTessera: TfrReport;
    frScadenze: TfrReport;
    frRoundRectObject1: TfrRoundRectObject;
    frShapeObject1: TfrShapeObject;
    frTNPDFExport1: TfrTNPDFExport;
    DSet1: TUIBDataSet;
    DSetSedi: TUIBDataSet;
    DsetFA: TUIBDataSet;
    SaveDialog1: TSaveDialog;
    Qgradi: TUIBQuery;
    QTessera: TUIBQuery;
    procedure frAnagraficaEnterRect(Memo: TStringList; View: TfrView);
    procedure frRichiestaTesseraGetValue(const ParName: String;
      var ParValue: Variant);
  private
    { private declarations }
    procedure PreparaStampaScheda;
    function  UpperStart(st: string):string;
  public
    procedure StampaMilitari(idreparto:integer);
    procedure StampaSchedaPersonale;
    procedure StampaSchedaPdf;
    procedure StampaSchedePdfFiltro;
    procedure StampaDatiPersonali;
    procedure StampaRichiestaTessera;
    procedure PrepataStampaTessera;
    function  AddSpaceStr(st: String; space: Integer): string;
    { public declarations }
  end;

var
  FmStampe: TFmStampe;

implementation

uses main_f, fmdatipersonali_f;

{$R *.lfm}

{ TFmStampe }

procedure TFmStampe.frAnagraficaEnterRect(Memo: TStringList; View: TfrView);
Var BlobStream : TMemoryStream;
begin
  if (View.name = 'foto')  then
    begin
     BlobStream:= TMemoryStream.Create;
      if not DSet1.FieldByName('foto').IsNull   then
        begin
          DSet1.ReadBlob('foto',BlobStream);
          TfrPictureView(View).Picture.LoadFromStream(BlobStream);
        end
      else
       TfrPictureView(View).Picture.Clear;
      //ShowMessage(dm.DSetDati.FieldByName('cognome').AsString);
    end
end;

procedure TFmStampe.frRichiestaTesseraGetValue(const ParName: String;
  var ParValue: Variant);
  var tmp:string;
begin
  if ParName = 'matrmec' then
    ParValue:= AddSpaceStr(FmDatiPersonali.matrmec.Text,2);
  if ParName = 'data' then
    begin
     tmp:= StringReplace(datetostr(now()),'/','',[rfReplaceAll]);
     ParValue:= AddSpaceStr(tmp,2);
    end;
   if ParName = 'pr' then
     ParValue:= AddSpaceStr(FmDatiPersonali.pr.Text,2);
   if (ParName = 'sessoM') and (FmDatiPersonali.Sesso.Text = 'M')  then
     ParValue:= 'X';
   if (ParName = 'sessoF') and (FmDatiPersonali.Sesso.Text = 'F')  then
     ParValue:= 'X';
   if ParName = 'dataNascita' then
     begin
      tmp:= StringReplace(FmDatiPersonali.nato.Text,'/','',[rfReplaceAll]);
      ParValue:= AddSpaceStr(tmp,2);
     end;
   if (ParName = 'sangueA') and (FmDatiPersonali.sangue.Text[1] = 'A') and
      (FmDatiPersonali.sangue.Text[2] <> 'B') then
     ParValue:= 'X';
   if (ParName = 'sangueB') and (FmDatiPersonali.sangue.Text[1] = 'B')  then
     ParValue:= 'X';
   if (ParName = 'sangueAB') and (copy(FmDatiPersonali.sangue.Text,1,2) = 'AB')  then
     ParValue:= 'X';
   if (ParName = 'sangueO') and (FmDatiPersonali.sangue.Text[1] in ['0','O'])  then
     ParValue:= 'X';

   if (ParName = 'fattoreT') and (pos('+',FmDatiPersonali.sangue.Text)> 0)  then
     ParValue:= 'X';
   if (ParName = 'fattoreU') and (pos('-',FmDatiPersonali.sangue.Text)> 0)   then
     ParValue:= 'X';

   if ParName = 'grado' then
      ParValue:= UpperCase(Qgradi.Fields.ByNameAsString['esteso']);
   if ParName = 'codGrado' then
     ParValue:= AddSpaceStr(Qgradi.Fields.ByNameAsString['cod'],2);
   if ParName = 'vecchiaTessera' then
     ParValue:= AddSpaceStr('0'+ QTessera.Fields.ByNameAsString['numero'],2);
   if ParName = 'statura' then
     ParValue:=  AddSpaceStr(FmDatiPersonali.altezza.Text,2);

   if (ParName = 'capelliA') and (DM.DSetDati.FieldByName('CODCAPELLO').AsString = 'A') then
      ParValue:= 'X';
   if (ParName = 'capelliB') and (DM.DSetDati.FieldByName('CODCAPELLO').AsString = 'B') then
      ParValue:= 'X';
   if (ParName = 'capelliC') and (DM.DSetDati.FieldByName('CODCAPELLO').AsString = 'C') then
      ParValue:= 'X';
   if (ParName = 'capelliD') and (DM.DSetDati.FieldByName('CODCAPELLO').AsString = 'D') then
      ParValue:= 'X';
   if (ParName = 'capelliE') and (DM.DSetDati.FieldByName('CODCAPELLO').AsString = 'E') then
      ParValue:= 'X';
   if (ParName = 'capelliF') and (DM.DSetDati.FieldByName('CODCAPELLO').AsString = 'F') then
      ParValue:= 'X';

   if (ParName = 'occhiG') and (DM.DSetDati.FieldByName('CODOCCHIO').AsString = 'G') then
      ParValue:= 'X';
   if (ParName = 'occhiH') and (DM.DSetDati.FieldByName('CODOCCHIO').AsString = 'H') then
      ParValue:= 'X';
   if (ParName = 'occhiL') and (DM.DSetDati.FieldByName('CODOCCHIO').AsString = 'L') then
      ParValue:= 'X';
   if (ParName = 'occhiM') and (DM.DSetDati.FieldByName('CODOCCHIO').AsString = 'M') then
      ParValue:= 'X';
   if (ParName = 'occhiN') and (DM.DSetDati.FieldByName('CODOCCHIO').AsString = 'N') then
      ParValue:= 'X';









end;


procedure TFmStampe.PrepataStampaTessera;
Var st:string;
begin
 Qgradi.SQL.Text:=' select * from gradi where idgradi = ' + DM.DSetDati.FieldByName('ksgrado').AsString;
 Qgradi.Open();
 st:= 'SELECT  NUMERO FROM LISTATESSERE r  where r.TIPOTESSERA = ''GF''';
 st:= st + ' AND R.KSMILITARE = ' + DM.DSetDati.FieldByName('idmilitare').AsString;
 st:= st + ' ORDER BY R.DATARILASCIO DESC  ';
 QTessera.SQL.Text:= st;
 QTessera.Open();
end;

procedure TFmStampe.PreparaStampaScheda;
Var st:string;
begin
  st:= ' select * from VIEW_DATIPERSONALI r where r.idmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
  DSet1.SQL.Text:=st;
  DSet1.Open;
  //gradi
  st:= ' SELECT * FROM view_gradi g ';
  st:= st + ' where g.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
  DSetGradi.SQL.Text:=st;

 //altre Forze Armate
 st:= ' SELECT b.DESCRIZIONEFFAA,a.IDLISTAALTRAFFAA, a.KSMILITARE, a.KSIDFFAA, a.DAL, a.AL ';
 st:= st + ' FROM LISTAALTREFFAA a LEFT JOIN ALTREFFAA b ON (a.KSIDFFAA = b.IDFFAA) ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
 DsetFA.SQL.Text:=st;
 //Familiari

 st:= ' SELECT P.PARENTELA,a.COGNOME, a.NOME, a.NATO, c.COMUNE ||'' (''||c.PR||'')'' as COMUNE , ';
 st:= st + '  a.DMATRIMONIO, a.DMORTE, a.NOTE ';
 st:= st + '  FROM LISTAPARENTELE a left join parentele p on (A.KSPARENTELA = P.IDPARENTELE) ';
 st:= st + '  left join comuni c on (a.KSCOMUNE = c.IDCOMUNE) ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
 DsetFamiliari.sql.Text:= st;


 //sedi
 st:= ' SELECT a.IDTRASFERIMENTI,a.REPARTO, a.ARTICOLAZIONE, a.TIPOTRASFERIMENTO, ';
 st:= st + '  a.DECORRENZA, a.NOTA, a.DATAARRIVO,a.INCARICO FROM VIEW_TRASFERIMENTI a ';
 st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
 DSetSedi.SQL.Text:=st;
end;



procedure TFmStampe.StampaMilitari(idreparto: integer);
Var st:string;
begin
  //DSet1.Close;
  st:= ' SELECT  a.MATRMEC, a.grado,a.ksgrado, a.CONT, a.COGNOME, a.NOME,a.REPARTO,a.ARTICOLAZIONE, a.KSARTICOLAZIONE, ' ;
  st:= st + ' case a.INCARICO WHEN 1 THEN ''COMANDANTE''  WHEN 3 THEN ''CAPOSEZIONE'' ELSE '''' END AS INCARICO';
//  st:= st + ' iif(a.INCARICO = 1,''COMANDANTE'','''') AS INCARICO

  st:= st + ',a.foto, a.VISUALIZZANOMI  FROM VIEW_DATIPERSONALI a ';
  st:= st + ' where a.KSREPARTO = ' + IntToStr(idreparto) + ' and a.VISUALIZZANOMI = ''S'' ' ;
//  st:= st + ' and a.KSSTATOGIURIDICO in (3,5,6) order by a.KSARTICOLAZIONE,a.INCARICO,a.KSGRADO desc ';
  st:= st + ' order by a.KSARTICOLAZIONE,a.INCARICO,a.KSGRADO desc ';
  DSet1.SQL.Text:=st;
  DSet1.Open;
  DM.LoadFromDB('ElencoFotoReparto',frAnagrafica);
  frAnagrafica.ShowReport;
end;

procedure TFmStampe.StampaSchedaPersonale;
begin
 PreparaStampaScheda;
 DM.LoadFromDB('Scheda',FmStampe.frAnagrafica);
 frAnagrafica.ShowReport;
end;

procedure TFmStampe.StampaSchedaPdf;
Var namefile:string;
begin
 namefile:= user.DirectTemp + '\scheda.pdf';
 DM.LoadFromDB('Scheda',frAnagrafica);
 PreparaStampaScheda;
 frAnagrafica.PrepareReport;
 frAnagrafica.Options:= [roHideDefaultFilter ];
 frAnagrafica.ExportTo(TFrTNPDFExportFilter, namefile );
 OpenDocument(namefile);
end;

procedure TFmStampe.StampaSchedePdfFiltro;
Var namefile,NewDir:string;
begin
  //NewDir:='C:\Users\' + Copy(user.matr,7,1) + Copy(user.matr,1,6) + '\Document\SchedePdf\';
  NewDir:=user.DirectTemp + '\SchedePdf\';

  If Not DirectoryExists(NewDir) then
    If Not CreateDir (NewDir) Then
      begin
         Showmessage('Non sono riuscito a creare la directore ' + NewDir);
         exit;
      end;
   dm.DSetDati.First;
   DM.LoadFromDB('Scheda',frAnagrafica);
   while not dm.DSetDati.EOF do
    begin
      namefile:= NewDir + dm.DSetDati.FieldByName('COGNOME').AsString + '_' + dm.DSetDati.FieldByName('NOME').AsString + '.PDF';
      PreparaStampaScheda;
      frAnagrafica.PrepareReport;
      frAnagrafica.Options:= [roHideDefaultFilter ];
      frAnagrafica.ExportTo(TFrTNPDFExportFilter, namefile );
      dm.DSetDati.Next;
    end;
   dm.DSetDati.First;
end;

procedure TFmStampe.StampaDatiPersonali;
var   st,ReadFile:string;
    MyWorkbook: TsWorkbook;
    MyWorksheet: TsWorksheet;
    riga,Coly:integer;
 //   riga,col,Rigax,x,TotCol :integer;
 //,SheetName
  function RicercaParenti(st:string):string; //ricerca la parentela
   begin
     result:= '';
     riga:= 0;
     dm.DSetParenti.First;
       while not dm.DSetParenti.EOF DO
         begin
           if pos(st,dm.DSetParenti.FieldByName('PARENTELA').AsString) > 0 then
             begin
               if result <> '' then result:= result + #13;
               result:= result + UpperStart(dm.DSetParenti.FieldByName('COGNOME').AsString) + '  ' +
                         UpperStart(dm.DSetParenti.FieldByName('NOME').AsString) + ' nato/a ' +
                         dm.DSetParenti.FieldByName('NATO').AsString + ' a ' +
                         UpperStart(dm.DSetParenti.FieldByName('COMUNE1').AsString) + '(' +
                         dm.DSetParenti.FieldByName('PR').AsString + ') anni: ' +
                         IntToStr(YearsBetween(now,dm.DSetParenti.FieldByName('NATO').AsDateTime));
             end;
           dm.DSetParenti.Next;
         end;
   end;
  function RicercaValutazione():string;
    var st:string;
        riga:integer;
    begin
       st:= ' SELECT * from view_valutazioni a ';
       st:= st + ' where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
       st:= st + ' order by a.al ';
       riga:= 0;
       result:= '';
       if EseguiSQLDS(dm.DSetTemp,st,open,'') then
         begin
          while not dm.DSetTemp.EOF DO
             begin
               if  dm.DSetTemp.FieldByName('valutazione').AsString <> '' then
                 begin
                   Inc(riga);
                   if result <> '' then result:= result + #13;
                         result:= result + '. dal ' + dm.DSetTemp.FieldByName('dal').AsString + ' al ' +
                         dm.DSetTemp.FieldByName('al').AsString +  #13 +
                         '      "' + LowerCase(dm.DSetTemp.FieldByName('valutazione').AsString) + '"';
                 end;
                dm.DSetTemp.Next;
             end;
           MyWorksheet.WriteRowHeight(19,riga * 0.45 * 2,suCentimeters);
         end;
    end;

begin
     ReadFile := ExtractFilePath(ParamStr(0)) + 'excel\SchedaDati.xls';
     MyWorkbook := TsWorkbook.Create;
     MyWorkbook.ReadFromFile(ReadFile);
     MyWorksheet := MyWorkbook.GetFirstWorksheet;
     riga:= 1;
     coly:= 0;
     st:= dm.DSetDati.FieldByName('grado').AsString + ' ' +
         dm.DSetDati.FieldByName('cognome').AsString + ' ' +
         dm.DSetDati.FieldByName('nome').AsString +
         ' "' + dm.DSetDati.FieldByName('matrmec').AsString + '"';
     MyWorksheet.WriteUTF8Text(1, 0, st);
     st:= 'Ordinario';
     if dm.DSetDati.FieldByName('cont').AsString = 'M' then
       st:= 'Mare';

     MyWorksheet.WriteUTF8Text(2,1 , st);
     MyWorksheet.WriteUTF8Text(3, 1, dm.DSetDati.FieldByName('arruolato').AsString);
     // Anzianità di Servizio
     st:= IntToStr(YearsBetween(now,dm.DSetDati.FieldByName('arruolato').AsDateTime));
     st:= st + '  anni di servizio di cui___ alla sede di __ ';
     MyWorksheet.WriteUTF8Text(4, 1,st);
     //Situazione Forza
     //ricalcolo situazione forza
     st:= ' select * from Elabora_sitforza_reparti(' +  dm.DSetDati.FieldByName('ksreparto').AsString + ')';
     EseguiSQL(dm.QTemp,st,Open,'');
     //inserisci nel file excel i dati della situazione forza
     MyWorksheet.WriteUTF8Text(5, 1, dm.DSetDati.FieldByName('reparto').AsString);
     st:= ' SELECT * FROM REPARTI where idreparto = ' + dm.DSetDati.FieldByName('ksreparto').AsString;
     if EseguiSQL(dm.QTemp,st,Open,'') then
       begin
         if dm.DSetDati.FieldByName('cont').AsString = 'O' then
           begin
             MyWorksheet.WriteNumber(7, 3, dm.QTemp.Fields.ByNameAsInteger['org_isp_ord']);
             MyWorksheet.WriteNumber(7, 4, dm.QTemp.Fields.ByNameAsInteger['org_sov_ord']);
             MyWorksheet.WriteNumber(7, 5, dm.QTemp.Fields.ByNameAsInteger['org_mil_ord']);
             MyWorksheet.WriteNumber(8, 3, dm.QTemp.Fields.ByNameAsInteger['eff_isp_ord']);
             MyWorksheet.WriteNumber(8, 4, dm.QTemp.Fields.ByNameAsInteger['eff_sov_ord']);
             MyWorksheet.WriteNumber(8, 5, dm.QTemp.Fields.ByNameAsInteger['eff_mil_ord']);
           end
         else
           begin
             MyWorksheet.WriteNumber(7, 3, dm.QTemp.Fields.ByNameAsInteger['org_isp_mar']);
             MyWorksheet.WriteNumber(7, 4, dm.QTemp.Fields.ByNameAsInteger['org_sov_mar']);
             MyWorksheet.WriteNumber(7, 5, dm.QTemp.Fields.ByNameAsInteger['org_mil_mar']);
             MyWorksheet.WriteNumber(8, 3, dm.QTemp.Fields.ByNameAsInteger['eff_isp_mar']);
             MyWorksheet.WriteNumber(8, 4, dm.QTemp.Fields.ByNameAsInteger['eff_sov_mar']);
             MyWorksheet.WriteNumber(8, 5, dm.QTemp.Fields.ByNameAsInteger['eff_mil_mar']);
           end;
         // formule da applicare alla situazione forza
         MyWorksheet.WriteFormula(7, 6, '=SUM(D8+E8+F8)');
         MyWorksheet.WriteFormula(8, 6, '=SUM(D9+E9+F9)');
         MyWorksheet.WriteFormula(9, 3, '=100*D9/D8');
         MyWorksheet.WriteFormula(9, 4, '=100*E9/E8');
         MyWorksheet.WriteFormula(9, 5, '=100*F9/F8');
         MyWorksheet.WriteFormula(9, 6, '=100*G9/G8');
       end;
       //comune di nascita del militare
       st:= UpperStart(dm.DSetDati.FieldByName('comune').AsString) + ' (' +
            dm.DSetDati.FieldByName('pr').AsString + ')';
       MyWorksheet.WriteText(11,1,st);
       // leggo l'archivio contenente i dati dei famigliari
       st:= ' select * from VIEW_PARENTI a where a.ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
       EseguiSQLDS(dm.DSetParenti,st,Open,'');

       //stato civile
       MyWorksheet.WriteText(12,0,dm.DSetDati.FieldByName('statocivile').AsString);
       // cerco il coniuge
        MyWorksheet.WriteText(12,1,RicercaParenti('CONIUGE'));
       //Residenza
       st:= UpperStart(dm.DSetDati.FieldByName('comuneres').AsString) + ' (' +
            dm.DSetDati.FieldByName('prr').AsString + ') ' +
            UpperStart(dm.DSetDati.FieldByName('viaresidenza').AsString);
       MyWorksheet.WriteText(13,1,st);
       //figlia
       st:= 'Figli ' +  dm.DSetDati.FieldByName('figli').AsString;
       MyWorksheet.WriteRowHeight(14,dm.DSetDati.FieldByName('figli').AsFloat * 0.65,suCentimeters);
       MyWorksheet.WriteText(14,0,st);
       MyWorksheet.WriteText(14,1,RicercaParenti('FIGL'));
       //Residenza Genitori del militare


       //Residenza Suoceri Militare

       //Valutazione caratteristica
       MyWorksheet.WriteText(19,1,RicercaValutazione());


       //Mansioni ricoperte
       st:= FmDatiPersonali.INCARICO.Caption + ' " ' +
            dm.DSetDati.FieldByName('articolazione').AsString + '" ';
       MyWorksheet.WriteText(23,1,UpperStart(st));


    if FileExists(user.FileTemp) then
         DeleteFile(user.FileTemp);
      MyWorkbook.WriteToFile(user.FileTemp,sfExcel8,True);
      MyWorkbook.Free;
      OpenDocument(user.FileTemp);
end;

procedure TFmStampe.StampaRichiestaTessera;
begin
// PreparaStampaScheda;
 DM.LoadFromDB('RichiestaTessera',FmStampe.frRichiestaTessera);
 frRichiestaTessera.ShowReport;
end;


function TFmStampe.AddSpaceStr(st: String; space: Integer): string;
Var car:string;
     x,y:integer;
begin
 for x := 1 to Length(st) do
   begin
     car:= car + st[x];
     for y:= 0 to space do
       car:= car + ' ';
   end;
  result := car;
end;



function TFmStampe.UpperStart(st: string):string;
 Var x:integer;
      Space:Boolean;
      NrAscii:smallint;
  Const
     CharMin = [97..122];  // Set Caratteri Minuscoli
     CharMai = [65..90];   // Set Caratteri Maiuscoli
     AsciSpace = 32;       // Codice Ascci per lo spazio
begin
  Space:= True;
  for x:= 1 to Length(st) do
   begin
     NrAscii:= ord(st[x]);
     if (Space) and (NrAscii in CharMin) then
       begin
         st[x] := Char(NrAscii-32);
         Space:= False;
       end
     else if not (Space) and (NrAscii in CharMai) then
       st[x] := Char(NrAscii+32)
     else if  NrAscii = AsciSpace then
       Space:= True
     else
       Space := False;
     end;
  Result:= st;
end;

end.

