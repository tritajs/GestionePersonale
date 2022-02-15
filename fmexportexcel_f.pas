unit fmexportexcel_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, uibdataset,LCLIntf, fpSpreadsheet, fpsTypes;


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
    { private declarations }
  public
    procedure EsportaEXL(DataSet:TUIBDataSet);
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
           MyWorksheet.WriteUTF8Text(0, col, DataSet.Fields[col].DisplayName);// C5
        end;
      while not DataSet.EOF do
        begin
         inc(riga);
         for col:= 0 to DataSet.FieldCount - 1 do
           begin
            if DataSet.Fields[col].DisplayName <> 'FOTO'  then
              MyWorksheet.WriteUTF8Text(riga, col, DataSet.Fields[col].AsString);// C5
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





end.

