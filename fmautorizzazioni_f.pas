unit fmautorizzazioni_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, PairSplitter, DM_f, umEdit, LSystemTrita, Grids, LCLType,
  {xlsbiff8, fpspreadsheet,} fpspreadsheet, xlsbiff8, fpsTypes,
  LCLIntf, {fpsTypes,} WTComboBoxSql, WTStringGridSql;

type

  { TFmAutorizzazioni }

  TFmAutorizzazioni = class(TForm)
    CGtabelle: TCheckGroup;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    LabelTitolo: TLabel;
    LabelTitolo1: TLabel;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    Panel1: TPanel;
    Panel2: TPanel;
    CBLmilitari: TWTComboBoxSql;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    RGgrent: TRadioGroup;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBesporta: TSpeedButton;
    SBok: TSpeedButton;
    SGabilitati: TwtStringGridSql;
    procedure CBLmilitariChange(Sender: TObject);
    procedure CBLmilitariEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure RGgrentSelectionChanged(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBesportaClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGabilitatiMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
     Procedure FindAutorizzazione(matr:string);
     procedure VistadiDefault; // riporta la videata allo stato di quando è stata aperta per la prima volta
     procedure CleanTabelle; // pulisce le autorizzazioni per la vista parziale  delle tabelle
     procedure SelezionaLetture;
     function ChechName:Boolean; //controlla se il nome è già presente nella tabella delle autorizzazioni
  public
    { public declarations }
  end;

var
  FmAutorizzazioni: TFmAutorizzazioni;


implementation

uses main_f;

{$R *.lfm}

{ TFmAutorizzazioni }


procedure TFmAutorizzazioni.CBLmilitariChange(Sender: TObject);
begin
  if CBLmilitari.ValueLookField <> '' then
    begin
      if ChechName then
        begin

          //ShowMessage('<<<< Nominativo già inserito  >>>>');
          CBLmilitari.Text:= '';
        end
      else
        begin
          RGgrent.ItemIndex:= 7;
          SBok.Visible:=True;
          SBcancel.Visible:=True;
          RGgrent.SetFocus;
        end;
    end;
end;

procedure TFmAutorizzazioni.CBLmilitariEnter(Sender: TObject);
begin
   if SBcancel.Visible then  VistadiDefault;   // se sono ancora abilitati i botton li disabilito
end;




procedure TFmAutorizzazioni.FormShow(Sender: TObject);
begin
  SGabilitati.Active:=False;
  SGabilitati.Active:=True;
  RGgrent.Controls[8].Visible:= False;   //rendo invisibile la scelta nulla
  VistadiDefault;
end;

procedure TFmAutorizzazioni.Label1Click(Sender: TObject);
begin

end;


procedure TFmAutorizzazioni.RGgrentSelectionChanged(Sender: TObject);
begin
 if (RGgrent.Items[RGgrent.ItemIndex] = 'VISTA PARZIALE REPARTO')  or (RGgrent.Items[RGgrent.ItemIndex] = 'VISTA PARZIALE REGIONALE') then
   CGtabelle.Visible:= True
 else if (RGgrent.Items[RGgrent.ItemIndex] = 'VISTA REPARTO') or (RGgrent.Items[RGgrent.ItemIndex] = 'VISTA GLOBALE') then
   begin
     SelezionaLetture;
     CGtabelle.Visible:= True;
   end
 else
   begin
     CGtabelle.Visible:= False;
     CleanTabelle;
   end;
end;

procedure TFmAutorizzazioni.SelezionaLetture;
Var x:integer;
begin
  for x:= 0 to  CGtabelle.Items.Count -1 do
    begin
      if Pos('LETTURA',CGtabelle.Items[X]) > 0 then
       CGtabelle.Checked[x]:= True;
    end;
end;

procedure TFmAutorizzazioni.SBcancelClick(Sender: TObject);
begin
  VistadiDefault;
end;

procedure TFmAutorizzazioni.SBdelClick(Sender: TObject);
Var
  BoxStyle: Integer;
 st:  array[0..255] of Char;
begin
    BoxStyle := MB_ICONQUESTION + MB_YESNO;
    StrPCopy(st,'Confermi la cancellazione; ' +  SGabilitati.Cells[2,SGabilitati.Row]);
    if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
         st:= 'delete from autorizzazioni where matrmec = ''' + SGabilitati.Cells[0,SGabilitati.Row] + '''';
         EseguiSQL(dm.QTemp,st,Execute,'');
         SGabilitati.Active:=False;
         SGabilitati.Active:=True;
         VistadiDefault;
      end;

end;

procedure TFmAutorizzazioni.SBesportaClick(Sender: TObject);
Var
  MyWorkbook: TsWorkbook;
  MyWorksheet: TsWorksheet;
  riga,col:integer;
  st:string;
begin
 st:= ' SELECT distinct a.MATRMEC,a2.GRADO, a1.COGNOME,a1.NOME,a3.REPARTO FROM AUTORIZZAZIONI a ';
 st:= st + ' inner join ANAGRAFICA a1 on (a.MATRMEC = a1.MATRMEC) ';
 st:= st + ' inner join GRADI a2 on (a1.KSGRADO = a2.IDGRADI) ';
 st:= st + ' inner join REPARTI a3 on (a1.KSREPARTO = a3.IDREPARTO) ';
 st:= st + ' order by a1.cognome,a1.nome ';
 DM.DSetTemp.SQL.Text:=st;
 DM.DSetTemp.Open;
       riga:= 0;
       col:= 0;
       //  MyDir := ExtractFilePath(ParamStr(0));
       MyWorkbook := TsWorkbook.Create;
     //  MyWorkbook.ReadFromFile('c:\windows\temp\temp.xls',sfExcel8);
      // MyWorksheet := MyWorkbook.GetFirstWorksheet;
       MyWorksheet := MyWorkbook.AddWorksheet('Elenco Autorizzati');
       for col:= 0 to DM.DSetTemp.FieldCount - 1 do
        begin
           MyWorksheet.WriteText(0, col, DM.DSetTemp.Fields[col].DisplayName);// C5
        end;
      while not DM.DSetTemp.EOF do
        begin
         inc(riga);
         for col:= 0 to DM.DSetTemp.FieldCount - 1 do
           begin
              MyWorksheet.WriteText(riga, col, DM.DSetTemp.Fields[col].AsString);// C5
           end;
         DM.DSetTemp.Next;
        end;
     if FileExists(user.FileTemp) then
        DeleteFile(user.FileTemp);
      MyWorkbook.WriteToFile(user.FileTemp,sfExcel5,True);
      MyWorkbook.Free;
    OpenDocument(user.FileTemp);

end;

procedure TFmAutorizzazioni.SBokClick(Sender: TObject);

  Var st,matr,temp:string;
    x:Smallint;
begin

  if RGgrent.ItemIndex = 7 then   //se non è stato attribuito nessuna autorizzazione visualizzo
    begin
      ShowMessage('<<<< Attenzione non hai attribuito nessuna autorizzazione al militare scelto >>>>>');
      exit;
    end;
  //cerco la matricola da cbmilitari se il militare non esiste altrimenti dalla tabella autorizzazioni
  if CBLmilitari.Text <> '' then
      matr:= CBLmilitari.ValueLookField
  else
    matr:= SGabilitati.Cells[0,SGabilitati.Row];
  //cancello tutte le abilitazioni del militare per poi inzerire quelle nuove
  st:= 'delete from autorizzazioni where matrmec = ''' + matr + '''';
  EseguiSQL(dm.QTemp,st,Execute,'');

  //inserisco le nuove autorizzazioni
  st:= ' insert into autorizzazioni (matrmec,autorizzato) values (';
  st:= st + '''' + matr + '''';
  temp:= StringReplace(RGgrent.Items[RGgrent.ItemIndex],'''','''''',[rfReplaceAll]);
  st:= st   + ',''' + temp + ''')';
  EseguiSQL(dm.QTemp,st,Execute,'');
  for x:= 0 to CGtabelle.Items.Count - 1   do
    begin
      if CGtabelle.Checked[x] then
          begin
            st:= ' insert into autorizzazioni (matrmec,autorizzato) values (';
            st:= st + '''' + matr + '''';
            temp:= StringReplace(CGtabelle.Items[x],'''','''''',[rfReplaceAll]);
            st:= st   + ',''' + temp + ''')';
            EseguiSQL(dm.QTemp,st,Execute,'');
          end;
     end;
   dm.TR.Commit;
   SGabilitati.Active:=False;
   SGabilitati.Active:=True;
   dm.LoadAutorizzazioni;
   VistadiDefault;
 //  Close;  *)
end;


procedure TFmAutorizzazioni.SGabilitatiMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   FindAutorizzazione(SGabilitati.Cells[0,SGabilitati.Row]);
   SBok.Visible:=True;
   SBcancel.Visible:=True;
   SBdel.Visible:=True;

end;



procedure TFmAutorizzazioni.FindAutorizzazione(matr: string);
 Var st:string;
     indice:integer;
begin
   //pulisco il cgtabelle
   CleanTabelle;
   st:= 'select autorizzato from autorizzazioni where matrmec = ''' + matr + '''';
   EseguiSQL(dm.QTemp,st,Open,'');
   while not dm.QTemp.Eof do
   begin
     indice:=   RGgrent.Items.IndexOf(dm.QTemp.Fields.AsString[0]);
     if indice > -1 then
       RGgrent.ItemIndex:= indice
     else // leggo eventuali abilitazioni parziali
      begin
       indice:= CGtabelle.Items.IndexOf(dm.QTemp.Fields.AsString[0]);
       if indice > -1 then
         CGtabelle.Checked[indice]:= True;
      end;
     dm.QTemp.Next;
   end;
end;

procedure TFmAutorizzazioni.VistadiDefault;
begin
 CBLmilitari.Text:= '';
 CBLmilitari.ValueLookField:= '';
 SBok.Visible:=False;
 SBcancel.Visible:=False;
 SBdel.Visible:=False;
 RGgrent.ItemIndex:= 7;
 CleanTabelle;
end;

procedure TFmAutorizzazioni.CleanTabelle;
 Var x:integer;
begin
 for x:= 0 to CGtabelle.Items.Count - 1   do
   CGtabelle.Checked[x] := False;
end;


function TFmAutorizzazioni.ChechName: Boolean;
Var riga:integer;
begin
 SGabilitati.Row:= -1;
 result:= False;
 for riga := 1 to SGabilitati.RowCount -1 do
    if SGabilitati.Cells[0,riga] = CBLmilitari.ValueLookField then
      begin
         Result := True;
         SGabilitati.Row:= riga;
      end;

end;


end.

