unit fmstatistiche_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Grids, Buttons, LSystemTrita,comobj,LCLIntf;

type

  { TFmStatistiche }

  TFmStatistiche = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LVscelta: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    SBexcel: TSpeedButton;
    SGstatistiche: TStringGrid;
    TCstatisitca: TTabControl;
    procedure FormShow(Sender: TObject);
    procedure LVsceltaSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure SBexcelClick(Sender: TObject);
    procedure TCstatisitcaChange(Sender: TObject);
  private
    procedure ElaboraStatistica(idsitforza:smallint);
    procedure ExcelStatisticaMedia;
    { private declarations }
  public
    { public declarations }
  end;

var
  FmStatistiche: TFmStatistiche;

implementation

uses DM_f;

{$R *.lfm}

{ TFmStatistiche }




procedure TFmStatistiche.LVsceltaSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  SGstatistiche.Clear;
  SGstatistiche.RowCount:= 1;
  Label11.Caption:= '.....';
  if Selected then
    begin
      Item.ImageIndex:= 2;
      Label11.Caption:= Item.Caption;
      TCstatisitca.TabIndex:=-1;
     end
  else
    Item.ImageIndex:=-1;
end;

procedure TFmStatistiche.FormShow(Sender: TObject);
begin
 LVscelta.ItemIndex := -1 ;
 SGstatistiche.Clear;
 SGstatistiche.RowCount:= 1;
 Label11.Caption:= '.....';
end;

procedure TFmStatistiche.SBexcelClick(Sender: TObject);
begin
  ExcelStatisticaMedia;
end;

procedure TFmStatistiche.TCstatisitcaChange(Sender: TObject);
begin
 if LVscelta.ItemIndex = -1 then
  begin
   ShowMessage('Attenzione! devi scegliere prima la statistica che vuoi elaborare');
   exit;
  end;
 SGstatistiche.Clear;
 SGstatistiche.RowCount:= 1;
 case TCstatisitca.TabIndex of
     0: begin   // Situazione Forza Generale
         SGstatistiche.Columns[0].Title.Caption:= 'REGIONALE ABRUZZO';
         ElaboraStatistica(0);
      end;
     1: begin   // Comando Regionale
          ElaboraStatistica(1);
          SGstatistiche.Columns[0].Title.Caption:= 'COMANDO REGIONALE';
        end;
     2: begin   // Provinciale L'Aquila;
         SGstatistiche.Columns[0].Title.Caption:= 'PROVINCIALE L''AQUILA';
         ElaboraStatistica(2);
        end;
     3: begin   // Provinciale Chieti;
         SGstatistiche.Columns[0].Title.Caption:= 'PROVINCIALE CHIETI';
         ElaboraStatistica(3);
        end;
     4: begin   // Provinciale Pescara;
         SGstatistiche.Columns[0].Title.Caption:= 'PROVINCIALE PESCARA';
         ElaboraStatistica(4);
        end;
     5: begin   // Provinciale Teramo;
         SGstatistiche.Columns[0].Title.Caption:= 'PROVINCIALE TERAMO';
         ElaboraStatistica(5);
        end;
     6: begin   // Provinciale Teramo;
         SGstatistiche.Columns[0].Title.Caption:= 'ROAN';
         ElaboraStatistica(6);
        end;
     7: begin   // Provinciale Teramo;
         SGstatistiche.Columns[0].Title.Caption:= 'RTLA';
         ElaboraStatistica(7);
        end;
     8: begin   // Provinciale Teramo;
         SGstatistiche.Columns[0].Title.Caption:= 'CENTRO ADDESTRAMENTO';
         ElaboraStatistica(8);
        end;
   end;
end;

procedure TFmStatistiche.ElaboraStatistica(idsitforza: smallint);
Var st:string;
    riga,col:integer;
begin
 // Statistica Età Media
 if LVscelta.ItemIndex = 0 then
  st:= ' select * from Statistica_media_eta(' + IntToStr(idsitforza) + ')';
 // Statistica Media Anni di servizio
 if LVscelta.ItemIndex = 1 then
  st:= ' select * from Statistica_media_arruolamento(' + IntToStr(idsitforza) + ')';
 dm.QTemp.SQL.Text:= st;
 if EseguiSQL(dm.QTemp,st,Open,'')  then
   begin
     while not dm.QTemp.Eof do
       begin
          SGstatistiche.RowCount:= SGstatistiche.RowCount + 1;
          riga:= SGstatistiche.RowCount - 1;
          for col:= 0 to 3 do
            SGstatistiche.Cells[col,riga] := dm.QTemp.Fields.AsString[col];
          dm.QTemp.Next;
       end;
   end;
end;

procedure TFmStatistiche.ExcelStatisticaMedia;
Var  XLApp: Variant;
     rigaSG,rigaXLS,colXLS: integer;
     ReadFile: widestring;
  //   reparto:string;
begin
  // Statistica Età Media
 if LVscelta.ItemIndex = 0 then
   ReadFile := ExtractFilePath(ParamStr(0)) + 'excel\StatisticaMediaEta.xlsx';
 // Statistica Media Anni di servizio
 if LVscelta.ItemIndex = 1 then
   ReadFile := ExtractFilePath(ParamStr(0)) + 'excel\StatisticaMediaArruolamento.xlsx';

 XLApp := CreateOleObject('Excel.Application'); // requires comobj in uses
 try
   XLApp.Visible := False;         // Hide Excel
   XLApp.DisplayAlerts := False;
   XLApp.Workbooks.Open(ReadFile);     // Open the Workbook
   XLApp.Workbooks[1].Worksheets[2].select; //selezione il 2 foglio
   rigaXLS:= 4;
   for rigaSG:= 1 to SGstatistiche.RowCount -1 do
     begin
        for colXLS:= 0 to 3 do
        XLApp.Cells[rigaXLS,colXLS+2].Value := WideString(SGstatistiche.Cells[colXLS,rigaSG]);

       INC(rigaXLS);
     end;
    XLApp.Workbooks[1].Worksheets[1].select; //selezione il 1 foglio
    XLApp.Workbooks[1].SaveAs('c:\windows\temp\statistica.xlsx',XLApp.Workbooks[1].fileformat);
 finally
   XLApp.Quit;
   XLAPP := Unassigned;
 end;

OpenDocument('c:\windows\temp\statistica.xlsx');
end;
end.


