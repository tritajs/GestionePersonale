unit fmsituazioneforza_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, Buttons, StdCtrls, ComCtrls, Grids, LSystemTrita, //comobj,
  LCLIntf, uib, fpspreadsheet,fpsTypes;

type

  { TFmSituazioneForza }

  TFmSituazioneForza = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Lcontatore: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBedit: TSpeedButton;
    SBok: TSpeedButton;
    SGforza: TStringGrid;
    SBexcel: TSpeedButton;
    TCforza: TTabControl;
    procedure FormShow(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBexcelClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGforzaPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGforzaSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure SGforzaValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
    procedure TCforzaChange(Sender: TObject);
  private
    procedure Carica_Situazione;
    procedure Carica_Situazione_Reparti(idsitforza:smallint); // Carica la situazione forza del reparto passato come parametro
    procedure ElaboraSitForzaRegionale;
    procedure ElaboraSitForzaReparti(idsitforza:smallint);// elebora la situazione forza dei reparti collegati con il campo idsitforza
    procedure VisibleTastiConferma(button:boolean);
  //  procedure ExcelSitForzaRegionale;
    procedure ExcelSitForzaReparti(idsitforza: smallint);
    procedure SalvaDati;
    function CheckGrantSitFor(Rep:string):Boolean;
    function FormulaSum(Riga,Col,Riga2,Col2: smallint): TsRPNFormula;

    { private declarations }
  public
    { public declarations }
  end;

var
  FmSituazioneForza: TFmSituazioneForza;

implementation

uses DM_f, main_f;

{$R *.lfm}

{ TFmSituazioneForza }

procedure TFmSituazioneForza.FormShow(Sender: TObject);
begin
 SGforza.Clear;
 SGforza.RowCount:= 1;
 TCforza.TabIndex:= -1;
end;

procedure TFmSituazioneForza.SBcancelClick(Sender: TObject);
begin
  TCforzaChange(self);
  VisibleTastiConferma(False);
end;

procedure TFmSituazioneForza.SBeditClick(Sender: TObject);
begin
  SGforza.Options:= SGforza.Options + [goEditing];;
  VisibleTastiConferma(True);

end;

procedure TFmSituazioneForza.SBexcelClick(Sender: TObject);
begin
   ExcelSitForzaReparti(TCforza.TabIndex)
end;

procedure TFmSituazioneForza.SBokClick(Sender: TObject);
begin
  SalvaDati;
  TCforzaChange(self);
  VisibleTastiConferma(False);
end;

procedure TFmSituazioneForza.SGforzaPrepareCanvas(sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
begin
  if (aRow > 0) and (aCol in [4,7,10,13,16,19]) then
    if (StrToInt(SGforza.Cells[aCol,aRow]) < 0) then
      SGforza.Canvas.Font.Color := clRed;
end;

procedure TFmSituazioneForza.SGforzaSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
  if aCol in [2,5,8,11,14,17] then CanSelect:= True else
    CanSelect:= False;
end;



procedure TFmSituazioneForza.SGforzaValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
   if (NewValue <> OldValue) then
     SGforza.Cells[20,aRow]:= 'M';
end;

procedure TFmSituazioneForza.TCforzaChange(Sender: TObject);
begin
 SGforza.Clear;
 SGforza.RowCount:= 1;
 dm.tr.Commit;
 case TCforza.TabIndex of
   0: begin   // Situazione Forza Generale
       if CheckGrantSitFor('Totale') then
         begin
           ElaboraSitForzaRegionale;
           Carica_Situazione;
           SGforza.Columns[1].Title.Caption:= 'REGIONALE ABRUZZO';
         end;
      end;
   1: begin   // Comando Regionale AQ022
       if CheckGrantSitFor('AQ022') then
         begin
           ElaboraSitForzaReparti(1);
           Carica_Situazione_Reparti(1);
           SGforza.Columns[1].Title.Caption:= 'COMANDO REGIONALE';
         end;
      end;
   2: begin   // Provinciale L'Aquila AQ054;
       if CheckGrantSitFor('AQ054') then
         begin
          SGforza.Columns[1].Title.Caption:= 'PROVINCIALE L''AQUILA';
          ElaboraSitForzaReparti(2);
          Carica_Situazione_Reparti(2);
         end;
      end;
   3: begin   // Provinciale Chieti CH050;
       if CheckGrantSitFor('CH050') then
         begin
          SGforza.Columns[1].Title.Caption:= 'PROVINCIALE CHIETI';
          ElaboraSitForzaReparti(3);
          Carica_Situazione_Reparti(3);
         end;
      end;
   4: begin   // Provinciale Pescara PE053;
       if CheckGrantSitFor('PE053') then
         begin
          SGforza.Columns[1].Title.Caption:= 'PROVINCIALE PESCARA';
          ElaboraSitForzaReparti(4);
          Carica_Situazione_Reparti(4);
         end;
      end;
   5: begin   // Provinciale Teramo TE050;
       if CheckGrantSitFor('TE050') then
         begin
          SGforza.Columns[1].Title.Caption:= 'PROVINCIALE TERAMO';
          ElaboraSitForzaReparti(5);
          Carica_Situazione_Reparti(5);
         end;
      end;
   6: begin   // ROAN PESCARA - PE052;
       if CheckGrantSitFor('PE052') then
         begin
          SGforza.Columns[1].Title.Caption:= 'ROAN';
          ElaboraSitForzaReparti(6);
          Carica_Situazione_Reparti(6);
         end;
      end;
   7: begin   // REPARTO T.L.A. ABRUZZO - AQ052;
       if CheckGrantSitFor('AQ052') then
         begin
          SGforza.Columns[1].Title.Caption:= 'RTLA';
          ElaboraSitForzaReparti(7);
          Carica_Situazione_Reparti(7);
         end;
      end;
   8: begin   //Centro Addestramento - AQ053;
       if CheckGrantSitFor('AQ022') then
         begin
          SGforza.Columns[1].Title.Caption:= 'CENTRO ADDESTRAMENTO';
          ElaboraSitForzaReparti(8);
          Carica_Situazione_Reparti(8);
         end;
      end;
 end;
end;

procedure TFmSituazioneForza.Carica_Situazione;
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= '  SELECT * from SITUAZIONEFORZA ';
 SGforza.Clear;
 SGforza.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGforza.RowCount:= SGforza.RowCount + 1;
          riga:= SGforza.RowCount - 1;
          for col:= 0 to 19 do
            SGforza.Cells[col,riga] := dm.DSetTemp.Fields[col].AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
end;

procedure TFmSituazioneForza.Carica_Situazione_Reparti(idsitforza: smallint);
Var riga: integer;
    col:integer;
    st:string;
begin
 st:= 'SELECT a.IDREPARTO, a.REPARTO,a.ORG_ISP_ORD, a.EFF_ISP_ORD, a.DIF_ISP_ORD,';
 st:= st + 'a.ORG_ISP_MAR, a.EFF_ISP_MAR, a.DIF_ISP_MAR, a.ORG_SOV_ORD, a.EFF_SOV_ORD, a.DIF_SOV_ORD,';
 st:= st + 'a.ORG_SOV_MAR, a.EFF_SOV_MAR, a.DIF_SOV_MAR, a.ORG_MIL_ORD, a.EFF_MIL_ORD, a.DIF_MIL_ORD, ';
 st:= st + 'a.ORG_MIL_MAR, a.EFF_MIL_MAR, a.DIF_MIL_MAR ';
 st:= st + 'FROM REPARTI a where a.idsitforza > 0 and  a.idsitforza = ' + IntToStr(idsitforza);
// il campo idsitforza viene posto a 0 quando il reparto viene soppresso o viene elvato di rango

 SGforza.Clear;
 SGforza.RowCount:= 1;
 if EseguiSQLDS(dm.DSetTemp,st,Open,'') then
   begin
     while not dm.DSetTemp.Eof do
       begin
          SGforza.RowCount:= SGforza.RowCount + 1;
          riga:= SGforza.RowCount - 1;
          for col:= 0 to 19 do
            SGforza.Cells[col,riga] := dm.DSetTemp.Fields[col].AsString;
          dm.DSetTemp.Next;
       end;
     dm.DSetTemp.First;
   end;
   dm.tr.Commit;
end;

procedure TFmSituazioneForza.ElaboraSitForzaRegionale;
Var st:string;
begin
 st:= ' select * from Elabora_sitforza_regionale';
 dm.QTemp.SQL.Text:= st;
 dm.QTemp.Open;
// dm.QTemp.Close(etmCommit);
end;

procedure TFmSituazioneForza.ElaboraSitForzaReparti(idsitforza: smallint);
Var st:string;
begin
 st:= ' select * from Elabora_sitforza_reparti(' + IntToStr(idsitforza) + ')';
 dm.QTemp.SQL.Text:= st;
 dm.QTemp.Open;
// dm.QTemp.Close(etmCommit);
end;

procedure TFmSituazioneForza.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  if (button)then
    SGforza.Options:= SGforza.Options + [goEditing]
  else
   SGforza.Options:= SGforza.Options - [goEditing];
  end;


procedure TFmSituazioneForza.ExcelSitForzaReparti(idsitforza: smallint);
Var st:string;
    rigaSG,rigaXLS,colXLS,nr: integer;
    rep,cat:string;
    ReadFile: string;
    MyWorkbook: TsWorkbook;
    MyWorksheet: TsWorksheet;
begin

 st:= ' select * from VIEW_MILITARIPRESENTI r ';
 if idsitforza > 0 then   //se idsitforza è > 0 allora applico il filtro per il reparto
   begin
     st:= st + 'WHERE r.idsitforza = ' + IntToStr(idsitforza) ;
     st:= st + 'ORDER BY r.reparto,r.ordinegrado desc, r.cognome, r.nome ';
   end
 else
   begin
     st:= st + 'ORDER BY r.ordinegrado desc, r.cognome, r.nome ';
   end;
 dm.QTemp.SQL.Text:= st;
 dm.QTemp.Open();
 if dm.QTemp.Fields.RecordCount > 0 then
   begin
     ReadFile := ExtractFilePath(ParamStr(0)) + 'excel\cpm.xls';
     MyWorkbook := TsWorkbook.Create;
      MyWorkbook.Options := MyWorkbook.Options + [boReadFormulas];
      MyWorkbook.ReadFromFile(ReadFile);
     try
//       MyWorksheet := MyWorkbook.GetFirstWorksheet;
       MyWorksheet := MyWorkbook.GetWorksheetByName('Situazioneforza');
       rigaXLS:= 7;
       for rigaSG:= 1 to SGforza.RowCount -1 do
         begin
           for colXLS:= 1 to 19 do
            if colXLS = 1 then
              MyWorksheet.WriteText(rigaXLS,colXLS,SGforza.Cells[colXLS,rigaSG])
            else
              MyWorksheet.WriteNumber(rigaXLS,colXLS,StrToInt(SGforza.Cells[colXLS,rigaSG]));
           INC(rigaXLS);
         end;
       //inserisco le formule per la somma delle colonne
       for colXLS:= 2 to 19 do
         MyWorksheet.WriteRPNFormula(16, colXLS, FormulaSum(7,colXLS,15,colXLS));

       MyWorksheet := MyWorkbook.GetWorksheetByName('Nominativi');
       // stampa l'elenco dei militari
       rigaXLS:= 2;
       rep:= '';
       cat:= '';
       while not dm.QTemp.Eof do
        begin
          if idsitforza > 0 then   //se idsitforza è > 0 allora controllo il reparto
            begin
              if rep <> dm.QTemp.Fields.ByNameAsString['reparto'] then //se il reparto è differente scrivo il reparto ed incremento di una riga
                begin
                  Inc(rigaXLS);
                  MyWorksheet.MergeCells(rigaXLS, 1, rigaXLS, 7);  // first row, first column, last row, last column
                  MyWorksheet.WriteFontStyle(rigaXLS,1, [fssBold]);

                  MyWorksheet.WriteText(rigaXLS,1,dm.QTemp.Fields.ByNameAsString['reparto']);
                  rep:= dm.QTemp.Fields.ByNameAsString['reparto'];
                  Inc(rigaXLS);
                end;
            end;
          if cat <> dm.QTemp.Fields.ByNameAsString['cat'] then //se la categoria  è differenteincremento di due righe
            begin
              cat:= dm.QTemp.Fields.ByNameAsString['cat'];
              rigaXLS:= rigaXLS + 1;
              nr:= 1;
            end;

          MyWorksheet.WriteText(rigaXLS,1,IntToStr(nr));
          MyWorksheet.WriteText(rigaXLS,2,dm.QTemp.Fields.ByNameAsString['matrmec']);
          MyWorksheet.WriteText(rigaXLS,3,dm.QTemp.Fields.ByNameAsString['grado']);
          MyWorksheet.WriteText(rigaXLS,4,dm.QTemp.Fields.ByNameAsString['cont']);
          MyWorksheet.WriteText(rigaXLS,5,dm.QTemp.Fields.ByNameAsString['cognome']);
          MyWorksheet.WriteText(rigaXLS,6,dm.QTemp.Fields.ByNameAsString['nome']);
          MyWorksheet.WriteText(rigaXLS,7,dm.QTemp.Fields.ByNameAsString['reparto']);
          MyWorksheet.WriteText(rigaXLS,8,dm.QTemp.Fields.ByNameAsString['articolazione']);
          MyWorksheet.WriteText(rigaXLS,9,dm.QTemp.Fields.ByNameAsString['note']);
          inc(nr); //incremente il numero progressivo della categoria
          Inc(rigaXLS); //incremento la riga di excel
          dm.QTemp.Next;
        end;
 finally
    if FileExists(user.FileTemp) then
         DeleteFile(user.FileTemp);
    MyWorkbook.WriteToFile(user.FileTemp,sfExcel8,True);
    MyWorkbook.Free;
   OpenDocument(user.FileTemp);
 end;
end;
end;

procedure TFmSituazioneForza.SalvaDati;
Var riga:integer;
    st,st1,where:string;
begin
  if TCforza.TabIndex = 0 then // aggiorno tabella situazione forza
    begin
      st1:= ' update  situazioneforza set ';
      where:= ' where kssitforza = '
    end
  else  // aggiorno tabella reparti
  begin
    st1:= ' update reparti set ';
    where:= ' where idreparto = '
  end;
  for riga := 1 to SGforza.RowCount - 1 do
     begin
       if SGforza.Cells[20,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
         begin
            st:= st1;
            st:= st + 'ORG_ISP_ORD = ' + SGforza.Cells[2,riga] + ', ';
            st:= st + 'ORG_ISP_MAR = ' + SGforza.Cells[5,riga] + ', ';
            st:= st + 'ORG_SOV_ORD = ' + SGforza.Cells[8,riga] + ', ';
            st:= st + 'ORG_SOV_MAR = ' + SGforza.Cells[11,riga] + ', ';
            st:= st + 'ORG_MIL_ORD = ' + SGforza.Cells[14,riga]+ ', ';
            st:= st + 'ORG_MIL_MAR = ' + SGforza.Cells[17,riga];
            st:= st + where +  SGforza.Cells[0,riga];
            dm.QTemp.SQL.Text:= st;
            dm.QTemp.Open();
         end;
     end;
  dm.TR.Commit;
end;

function TFmSituazioneForza.CheckGrantSitFor(Rep: string): Boolean;
Var x:integer;
begin
 SBedit.Visible:=True;
 Result:= False;
 for x:= 0 to autorizzato.Count -1 do
   begin
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'AMMINISTRATORE' then
       begin
          result:= True;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'VISTA GLOBALE' then
       begin
         SBedit.Visible:=False;
         result:= True;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'MODIFICA GLOBALE' then
       begin
         result:= True;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'VISTA REPARTO' then
       begin
//         if Rep = user.codreparto then
//           begin
             SBedit.Visible:=False;
             result:= True;
//           end;
       end;
     //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     if autorizzato[x] = 'MODIFICA REPARTO' then
       begin
         if Rep = user.codreparto then
           result:= True;
       end;
   end;
end;

function TFmSituazioneForza.FormulaSum(Riga, Col, Riga2, Col2: smallint   ): TsRPNFormula;
Var MyRPNFormula: TsRPNFormula;
begin
  SetLength(MyRPNFormula, 2);
    MyRPNFormula[0].ElementKind := fekCellRange;
  MyRPNFormula[0].Row := Riga;   // A1
  MyRPNFormula[0].Col := Col;
  MyRPNFormula[0].Row2 := Riga2;  // C10
  MyRPNFormula[0].Col2 := Col2;
  MyRPNFormula[0].RelFlags := [rfRelRow, rfRelCol, rfRelRow2, rfRelCol2];
  MyRPNFormula[1].ElementKind := fekFunc;
  MyRPNFormula[1].FuncName := 'SUM';
  MyRPNFormula[1].ParamsNum := 1;      // 1 argument used in SUM
Result:=MyRPNFormula;
end;



end.

