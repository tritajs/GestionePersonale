unit fmexportexcel_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, uibdataset,LCLIntf, fpSpreadsheet, fpsTypes, DateUtils,LSystemTrita;


type

  { TFmExportExcel }

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
    function AltreForzeArmate(matrmec:string;var anni,mesi,giorni:Word):boolean;
    procedure CheckYMD(var anni,mesi,giorni:Word);
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

function TFmExportExcel.AltreForzeArmate(matrmec: string; var anni, mesi,
  giorni: Word): boolean;
var st:string;
    tmpAnni, tmpMesi, tmpGiorni: Word;
begin
  Result:= false;
  anni:= 0; mesi:= 0; giorni:= 0;
  st:= 'SELECT DESCRIZIONEFFAA,DAL,AL FROM VIEW_ALTREFORZEA where matrmec = ''' + matrmec + '''';
  if EseguiSQL(dm.QTemp1,st,Open,'errore') then
   begin
     Result:= True;
     while not dm.QTemp1.Eof do
       begin
         PeriodBetween(dm.QTemp1.Fields.ByNameAsDateTime['al'],dm.QTemp1.Fields.ByNameAsDateTime['dal'],tmpAnni, tmpMesi, tmpGiorni);
         anni:= tmpAnni; mesi:= tmpMesi; giorni:= tmpGiorni;
         dm.QTemp1.Next;
       end;
   end;
end;

procedure TFmExportExcel.CheckYMD(var anni, mesi, giorni: Word);
begin
  while giorni > 31 do
    begin
      mesi:=   mesi + 1;
      giorni:= giorni - 31;
    end;
  while mesi > 12 do
    begin
      anni:= anni + 1;
      mesi:= mesi - 12;
    end;
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
    Eanni,Emesi,Egiorni:Word;
    Aanni,Amesi,Agiorni:Word;
    AFanni,AFmesi,AFgiorni:Word;
    Totanni,Totmesi,Totgiorni:Word;

const
    testa:Array of string = ('MATRMEC','GRADO','COGNOME','NOME','REPARTO','DATA NASCITA','ETA''','DATA ARRUOLAMENTO',
                             'ANNI DI SERVIZIO IN G di F.','PERIODO ALTRE FF.AA.','TOTALE ANNI DI SERVIZIO');
    PosCol:array of integer = (0,1,2,3,4,5,6,8);
begin

  st:= '';
  campi:= 'matrmec,grado,cognome,nome,reparto,nato as datanascita,arruolato as dataarruolamento';
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
      Aanni:=0;Amesi:=0;Agiorni:=0;
      AFanni:=0;AFmesi:=0;AFgiorni:=0;
      Totanni:=0;Totmesi:=0;Totgiorni:=0;
      for col:= 0 to dm.DSetTemp.FieldCount - 1 do
         begin
            case col of
              0..4:MyWorksheet.WriteText(riga, col,  dm.DSetTemp.Fields[col].AsString);
              5:   MyWorksheet.WriteDateTime(riga,col,   dm.DSetTemp.Fields[col].AsDateTime, nfShortDate);
              6:   MyWorksheet.WriteDateTime(riga,col+1, dm.DSetTemp.Fields[col].AsDateTime, nfShortDate);
            end;

            case col of
              5..10: MyWorksheet.WriteHorAlignment(riga, col, haCenter);
            end;
          end;
      //calcolo totale Anni mesi e gioni di Età
      PeriodBetween(dm.DSetTemp.Fields[5].AsDateTime,Today,Eanni, Emesi, Egiorni);
      MyWorksheet.WriteText(riga, 6,  IntToStr(Eanni)+ ' anni '+IntToStr(Emesi)+' mesi '+IntToStr(Egiorni)+' giorni');
      //calcolo totale Anni mesi e gioni di Arruolamento
      PeriodBetween(dm.DSetTemp.Fields[6].AsDateTime,Today,Aanni, Amesi, Agiorni);
      MyWorksheet.WriteText(riga, 8,  IntToStr(Aanni)+ ' anni '+IntToStr(Amesi)+' mesi '+IntToStr(Agiorni)+' giorni');
      //calcolo totale Anni mesi e gioni altre Forze Armate
      if AltreForzeArmate(dm.DSetTemp.Fields[0].AsString,AFanni,AFmesi,AFgiorni) then
        begin
          MyWorksheet.WriteText(riga, 9,  IntToStr(AFanni)+ ' anni '+IntToStr(AFmesi)+' mesi '+IntToStr(AFgiorni)+' giorni');
        end;
      //calcolo Totale anni mesi e giorni
      Totanni:=   Aanni   + AFanni;
      Totmesi:=   Amesi   + AFmesi;
      Totgiorni:= Agiorni + AFgiorni;
      CheckYMD(Totanni,Totmesi,Totgiorni);
      MyWorksheet.WriteText(riga, 10,  IntToStr(Totanni)+ ' anni '+IntToStr(Totmesi)+' mesi '+IntToStr(Totgiorni)+' giorni');

      dm.DSetTemp.Next;
    end;
    if FileExists(user.FileTemp) then
       DeleteFile(user.FileTemp);
    MyWorkbook.WriteToFile(user.FileTemp,sfExcel5,True);
    MyWorkbook.Free;
   OpenDocument(user.FileTemp);
end;





end.

