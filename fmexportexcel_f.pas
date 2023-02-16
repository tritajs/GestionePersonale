unit fmexportexcel_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, uibdataset,LCLIntf, fpSpreadsheet, fpsTypes, DateUtils,LSystemTrita;


type

  { TFmExportExcel }

  YMD = record
    y: Word;
    m: Word;
    d: Word;
  end;

  operazione = (SOMMA,SOTTRAZIONE);
  operazioni = set of operazione;

  TFmExportExcel = class(TForm)
    CGcampi: TCheckGroup;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    SBesporta: TSpeedButton;
    SBSelect: TSpeedButton;
    procedure SBSelectClick(Sender: TObject);
    procedure SBesportaClick(Sender: TObject);
  private
    function  AltreForzeArmate(matrmec:string;var periodo:YMD):boolean;
    function  PeriodiCongedo(matrmec:string;var periodo:YMD):boolean;
    function  ContributiEsterni(idmilitare:string;var periodo:YMD):boolean;
    procedure OperazioniYMD(var periodo1:YMD; periodo2:YMD; operatore: operazioni );

    { private declarations }
  public
    procedure EsportaEXL(DataSet:TUIBDataSet);
    procedure EsportaAnni;
    { public declarations }
  end;

var
  FmExportExcel: TFmExportExcel;

implementation

uses DM_f, fmdatipersonali_f, main_f;

{$R *.lfm}

{ TFmExportExcel }

procedure TFmExportExcel.SBSelectClick(Sender: TObject);
Var x:integer;
begin
  if SBSelect.Tag = 1 then
    begin
     SBSelect.Caption:= 'Seleziona Tutti';
     SBSelect.Tag := 0;
     for x:= 0 to CGcampi.Items.Count -1 do
       CGcampi.Checked[x]:= False;
    end
  else
    begin
     SBSelect.Caption:= 'Deseleziona Tutti';
     SBSelect.Tag := 1;
     for x:= 0 to CGcampi.Items.Count -1 do
       CGcampi.Checked[x]:= True;
    end;
end;

procedure TFmExportExcel.SBesportaClick(Sender: TObject);
Var st:string;
    x:integer;
    where:string;
    filtro:string;
begin
  st:= '';
  filtro:= UpperCase(FmDatiPersonali.ECdati.filtro);
  where := Copy(filtro,pos('WHERE',filtro),Length(filtro));
  for x:= 0 to CGcampi.Items.Count -1 do
    if CGcampi.Checked[x] then
     st:= st + 'anagrafica.' + CGcampi.Items[x] + ',';
  if st <> '' then
   begin
    st := ' select ' + Copy(st,1,Length(st)-1) + ' from VIEW_DATIPERSONALI anagrafica ';
    st:= st + where;
    dm.DSetTemp.SQL.Text:= st;
    dm.DSetTemp.Active:=True;
    EsportaEXL(dm.DSetTemp);
   end;
end;

function TFmExportExcel.AltreForzeArmate(matrmec: string; var periodo: YMD): boolean;
var st:string;
      PeriodoTmp:YMD;
begin
  Result:= false;
  periodo.y:=0; periodo.m:= 0; periodo.d:= 0;
  st:= 'SELECT DESCRIZIONEFFAA,DAL,AL,KSIDFFAA FROM VIEW_ALTREFORZEA where KSIDFFAA <> 12 and matrmec = ''' + matrmec + '''';
  if EseguiSQL(dm.QTemp1,st,Open,'errore') then
   begin
     Result:= True;
     while not dm.QTemp1.Eof do
       begin
         PeriodBetween(dm.QTemp1.Fields.ByNameAsDateTime['al'],dm.QTemp1.Fields.ByNameAsDateTime['dal'],PeriodoTmp.y, PeriodoTmp.m, PeriodoTmp.d);
         OperazioniYMD(periodo,PeriodoTmp,[SOMMA]);
         dm.QTemp1.Next;
       end;
   end;
end;

function TFmExportExcel.PeriodiCongedo(matrmec: string; var periodo: YMD): boolean;
var st:string;
    PeriodoTmp:YMD;
begin
  Result:= false;
  periodo.y:=0; periodo.m:= 0; periodo.d:= 0;
  st:= 'SELECT DESCRIZIONEFFAA,DAL,AL,KSIDFFAA FROM VIEW_ALTREFORZEA where KSIDFFAA = 12 and  matrmec = ''' + matrmec + '''';
  if EseguiSQL(dm.QTemp1,st,Open,'errore') then
   begin
     Result:= True;
     while not dm.QTemp1.Eof do
       begin
         PeriodBetween(dm.QTemp1.Fields.ByNameAsDateTime['al'],dm.QTemp1.Fields.ByNameAsDateTime['dal'],PeriodoTmp.y, PeriodoTmp.m, PeriodoTmp.d);
         OperazioniYMD(periodo,PeriodoTmp,[SOMMA]);
         dm.QTemp1.Next;
       end;
   end;
end;

function TFmExportExcel.ContributiEsterni(idmilitare: string; var periodo: YMD): boolean;
var st:string;
begin
  Result:= false;
  periodo.y:=0; periodo.m:= 0; periodo.d:= 0;
  st:= 'SELECT DD, MM, YY, NOTE FROM CONTRIBUTIESTERNI  where ksmilitare  = ''' + idmilitare + '''';
  if EseguiSQL(dm.QTemp1,st,Open,'errore') then
    begin
      Result:= True;
      periodo.d :=  dm.QTemp1.Fields.ByNameAsSmallint['dd'];
      periodo.m :=  dm.QTemp1.Fields.ByNameAsSmallint['mm'];
      periodo.y :=  dm.QTemp1.Fields.ByNameAsSmallint['yy'];
    end;
end;


procedure TFmExportExcel.OperazioniYMD(var periodo1: YMD; periodo2: YMD;
  operatore: operazioni);

var gg1,gg2,newGG:SmallInt;

begin
 gg1:= (periodo1.y * 365) + (periodo1.m * 30) + periodo1.d;
 gg2:= (periodo2.y * 365) + (periodo2.m * 30) + periodo2.d;
 if SOMMA in operatore then
     newGG:= gg1 + gg2
 else if SOTTRAZIONE in operatore then
    newGG:= abs(gg1 - gg2);

 periodo1.y:= Trunc(newGG / 365);
 periodo1.m:= Trunc((newGG - periodo1.y * 365) / 30);
 periodo1.d:= newGG - (periodo1.y * 365) - (periodo1.m * 30);
end;


procedure TFmExportExcel.EsportaEXL(DataSet: TUIBDataSet);
Var
  MyWorkbook: TsWorkbook;
  MyWorksheet: TsWorksheet;
  riga,col:integer;
begin
  if DataSet.Active then
     begin
       DataSet.First;
       riga:= 0;
       col:= 0;
       //  MyDir := ExtractFilePath(ParamStr(0));
       MyWorkbook := TsWorkbook.Create;
     //  MyWorkbook.ReadFromFile('c:\windows\temp\temp.xls',sfExcel8);
      // MyWorksheet := MyWorkbook.GetFirstWorksheet;
       MyWorksheet := MyWorkbook.AddWorksheet('My Worksheet');
       for col:= 0 to DataSet.FieldCount - 1 do
        begin
         if DataSet.Fields[col].DisplayName <> 'FOTO'  then
           MyWorksheet.WriteText(0, col, DataSet.Fields[col].DisplayName);// C5
        end;
      while not DataSet.EOF do
        begin
         inc(riga);
         for col:= 0 to DataSet.FieldCount - 1 do
           begin
            if DataSet.Fields[col].DisplayName <> 'FOTO'  then
              MyWorksheet.WriteText(riga, col, DataSet.Fields[col].AsString);// C5
           end;
         DataSet.Next;
        end;
      if FileExists(user.FileTemp) then
         DeleteFile(user.FileTemp);
      MyWorkbook.WriteToFile(user.FileTemp,sfExcel5,True);
      MyWorkbook.Free;
      OpenDocument(user.FileTemp);
    end;
end;

procedure TFmExportExcel.EsportaAnni;
Var st:string;
    where:string;
    filtro:string;
    campi:string;
    MyWorkbook: TsWorkbook;
    MyWorksheet: TsWorksheet;
    riga,col,eta:integer;
    EtaYMD: YMD;
    CongedoYMD: YMD;
    GdFYMD: YMD;
    AltreForzeYMD: YMD;
    ContributiYMD: YMD;
    TotaleYMD: YMD;

const
    testa:Array of string = ('MATRMEC','GRADO','COGNOME','NOME','REPARTO','DATA NASCITA','ETA''','DATA ARRUOLAMENTO',
                             'PERIODO CONGEDO','ANNI DI SERVIZIO IN G di F.','PERIODO ALTRE FF.AA.',
                             'TOTALE ANNI SERVIZIO per concessione CROCE','ALTRI CONTRIBUTI PENSIONISTICI - DUM',
                             'TOTALE CONTRIBUTI utili ai fini pensionistici');
    PosCol:array of integer = (0,1,2,3,4,5,6,8);
begin

  st:= '';
  campi:= 'matrmec,grado,cognome,nome,reparto,nato as datanascita,arruolato as dataarruolamento,idmilitare';
  filtro:= UpperCase(FmDatiPersonali.ECdati.filtro);
  where := Copy(filtro,pos('WHERE',filtro),Length(filtro));
  st := ' select ' + campi + ' from VIEW_DATIPERSONALI anagrafica ';
  st:= st + where;
  dm.DSetTemp.SQL.Text:= st;
  dm.DSetTemp.Active:=True;
  dm.DSetTemp.First;
  riga:= 0;
  col:= 0;
  //  MyDir := ExtractFilePath(ParamStr(0));
  MyWorkbook := TsWorkbook.Create;
  MyWorksheet := MyWorkbook.AddWorksheet('My Worksheet');
  for col:= 0 to Length(testa) - 1 do
    begin
      MyWorksheet.WriteHorAlignment(0, col, haCenter);
      MyWorksheet.WriteFontStyle(riga,col,[fssBold]);
   //   MyWorksheet.WriteBackground(riga,col,scSilver);
      case col of
        0..1,5:MyWorksheet.WriteColWidth(col,3,suCentimeters);
        4:MyWorksheet.WriteColWidth(col,7,suCentimeters);
        7:MyWorksheet.WriteColWidth(col,4.5,suCentimeters);
      else
        MyWorksheet.WriteColWidth(col,5,suCentimeters);
      end;
      MyWorksheet.WriteText(0, col, testa[col]);
    end;
  while not dm.DSetTemp.EOF do
    begin
      inc(riga);

      EtaYMD.y:=0; EtaYMD.m:=0; EtaYMD.d:=0;
      GdfYMD.y:=0; GdfYMD.m:=0; GdfYMD.d:=0;
      CongedoYMD.y:=0; CongedoYMD.m:=0; CongedoYMD.d:=0;
      AltreForzeYMD.y:=0;  AltreForzeYMD.m:=0; AltreForzeYMD.d:=0;
      ContributiYMD.y:= 0; ContributiYMD.m:= 0; ContributiYMD.d:= 0;
      TotaleYMD.y:= 0; TotaleYMD.m:= 0; TotaleYMD.d:= 0;

      for col:= 0 to dm.DSetTemp.FieldCount - 1 do
         begin
            case col of
              0..4:MyWorksheet.WriteText(riga, col,  dm.DSetTemp.Fields[col].AsString);
              5:   MyWorksheet.WriteDateTime(riga,col,   dm.DSetTemp.Fields[col].AsDateTime, nfShortDate);
              6:   MyWorksheet.WriteDateTime(riga,col+1, dm.DSetTemp.Fields[col].AsDateTime, nfShortDate);
            end;
            MyWorksheet.WriteHorAlignment(riga, col, haCenter);
            case col of
              5..13: MyWorksheet.WriteHorAlignment(riga, col, haCenter);
            end;
          end;

      //calcolo totale Anni mesi e gioni di Età
      PeriodBetween(dm.DSetTemp.Fields[5].AsDateTime,Today,EtaYMD.y, EtaYMD.m, EtaYMD.d);
      MyWorksheet.WriteText(riga, 6,  IntToStr(EtaYMD.y)+ ' anni '+IntToStr(EtaYMD.m)+' mesi '+IntToStr(EtaYMD.d)+' giorni');


      //calcolo periodi di congedo
      if PeriodiCongedo(dm.DSetTemp.Fields[0].AsString,CongedoYMD) then
        begin
          MyWorksheet.WriteText(riga, 8,  IntToStr(CongedoYMD.y)+ ' anni '+IntToStr(CongedoYMD.m)+' mesi '+IntToStr(CongedoYMD.d)+' giorni');
        end;

      //calcolo totale Anni mesi e gioni di Arruolamento
      PeriodBetween(dm.DSetTemp.Fields[6].AsDateTime,Today,GdFYMD.y, GdFYMD.m, GdFYMD.d);


      //detraggo  eventuali giorni di congedo
      if(CongedoYMD.y + CongedoYMD.m + CongedoYMD.d) > 0 then
        OperazioniYMD(GdFYMD,CongedoYMD,[SOTTRAZIONE]);

      //giorni effettivi nella Guardia di Finanza
      MyWorksheet.WriteText(riga, 9,  IntToStr(GdFYMD.y)+ ' anni '+IntToStr(GdFYMD.m)+' mesi '+IntToStr(GdFYMD.d)+' giorni');

      //calcolo totale Anni mesi e gioni altre Forze Armate
      if AltreForzeArmate(dm.DSetTemp.Fields[0].AsString,AltreForzeYMD) then
        begin
          MyWorksheet.WriteText(riga, 10,  IntToStr(AltreForzeYMD.y)+ ' anni '+IntToStr(AltreForzeYMD.m)+' mesi '+IntToStr(AltreForzeYMD.d)+' giorni');
        end;

      //calcolo Totale anni mesi e giorni
      OperazioniYMD(TotaleYMD,GdFYMD,[SOMMA]);
      OperazioniYMD(TotaleYMD,AltreForzeYMD,[SOMMA]);

      //totale anni di servizio per concessione Croce
      MyWorksheet.WriteText(riga, 11,  IntToStr(TotaleYMD.y)+ ' anni '+IntToStr(TotaleYMD.m)+' mesi '+IntToStr(TotaleYMD.d)+' giorni');


      //totale contributi
      if ContributiEsterni(dm.DSetTemp.FieldByName('idmilitare').AsString,ContributiYMD) then
        begin
           MyWorksheet.WriteText(riga, 12,  IntToStr(ContributiYMD.y)+ ' anni '+IntToStr(ContributiYMD.m)+' mesi '+IntToStr(ContributiYMD.d)+' giorni');
           OperazioniYMD(TotaleYMD,ContributiYMD,[SOMMA]);
        end;

        MyWorksheet.WriteText(riga, 13,  IntToStr(TotaleYMD.y)+ ' anni '+IntToStr(TotaleYMD.m)+' mesi '+IntToStr(TotaleYMD.d)+' giorni');

      dm.DSetTemp.Next;
    end;
    if FileExists(user.FileTemp) then
       DeleteFile(user.FileTemp);
    MyWorkbook.WriteToFile(user.FileTemp,sfExcel5,True);
    MyWorkbook.Free;
   OpenDocument(user.FileTemp);
end;





end.

