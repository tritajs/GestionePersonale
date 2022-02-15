unit frarma_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, StdCtrls,
  LSystemTrita, WTComboBox, WTMemo, umEdit;

type

  { TFrArma }

  TFrArma = class(TFrame)
    Image1: TImage;
    Iarma: TImage;
    ILarmi: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBedit: TSpeedButton;
    SBok: TSpeedButton;
    ksarma: TWTComboBox;
    MATRICOLAPISTOLA: TumEdit;
    MATRICOLACANNA: TumEdit;
    note: TWTMemo;
    umNumberEdit1: TumNumberEdit;
    procedure ksarmaChange(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
  private
    { private declarations }
    procedure VisibleTastiConferma(button:boolean);
    procedure SalvaDati;
    procedure ReadOnlyEdit(edit:boolean);
  public
    { public declarations }
    Procedure Esegui(grant:integer);
    procedure LeggeDati;
    procedure ClearDati;
  end;

implementation

uses DM_f, fmdatipersonali_f;

{$R *.lfm}

{ TFrArma }

procedure TFrArma.SBeditClick(Sender: TObject);
begin
  VisibleTastiConferma(True);
  ReadOnlyEdit(False);
  panel1.SetFocus;
end;

procedure TFrArma.SBcancelClick(Sender: TObject);
begin
  LeggeDati;
  VisibleTastiConferma(False);
  ReadOnlyEdit(True);
end;

procedure TFrArma.ksarmaChange(Sender: TObject);
begin
  if ksarma.ItemIndex <= 0 then
    Iarma.Picture.Clear
  else
   begin
      ILarmi.GetBitmap(ksarma.ItemIndex - 1,Iarma.Picture.Bitmap);
   end;
end;



procedure TFrArma.SBokClick(Sender: TObject);
begin
  SalvaDati;
  VisibleTastiConferma(False);
  ReadOnlyEdit(True);
  ksarmaChange(self);
end;

procedure TFrArma.VisibleTastiConferma(button: boolean);
begin
  Panel4.SetFocus;
  if button then
   begin
     SBok.Visible:= True;
     SBcancel.Visible:= True;
     SBedit.Visible:= False;
     FmDatiPersonali.WTnav.Enabled:= False;
     FmDatiPersonali.Pdati.TabStop:= True;
   end
  else
   begin
     SBok.Visible:= False;
     SBcancel.Visible:= False;
     SBedit.Visible:= True;
     FmDatiPersonali.WTnav.Enabled:= True;
     FmDatiPersonali.Pdati.TabStop:= False;
   end;
end;

procedure TFrArma.SalvaDati;
Var st:string;
begin
   st:= 'select * from AGGIORNAMENTO_ARMA(' ;

   St:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare
   if  ksarma.Caption = '' then  //KSARMA
     st:= st + '0,'
   else
     st:= st + IntToStr(ksarma.ItemIndex) + ',';

   if  MATRICOLAPISTOLA.Text = '' then  //MATRICOLAPISTOLA
     st:= st + 'null,'
   else
     st:= st + '''' + MATRICOLAPISTOLA.Text + ''',';
   if  MATRICOLACANNA.Text = '' then  //MATRICOLACANNA
     st:= st + 'null,'
   else
     st:= st + '''' + MATRICOLACANNA.Text + ''',';
   if note.Text = '' then  // note
     st:= st + 'null)'
    else
     st:=  st + '''' +  StringReplace(note.Text,'''','''''',[rfReplaceAll]) + ''')';
    dm.QTemp.SQL.Text:= st;
    dm.QTemp.Open();
    dm.TR.CommitRetaining;
end;

procedure TFrArma.LeggeDati;
Var st:string;
begin
  ClearDati;
  st:= ' select * from listaarmi ' ;
  st:= st + ' where ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
  if EseguiSQLDS(dm.DSetArma,st,Open,'') then
    begin
      ksarma.ItemIndex:=       dm.DSetArma.FieldByName('ksarma').AsInteger;
      MATRICOLAPISTOLA.Text:=  dm.DSetArma.FieldByName('MATRICOLAPISTOLA').AsString;
      MATRICOLACANNA.Text:=    dm.DSetArma.FieldByName('MATRICOLACANNA').AsString;
      NOTE.Text:=              dm.DSetArma.FieldByName('NOTE').AsString;
    end;
  ksarmaChange(self);
end;

procedure TFrArma.ClearDati;
begin
  Iarma.Picture.Clear;
  ksarma.ItemIndex:=     -1;
  MATRICOLAPISTOLA.Text:='';
  MATRICOLACANNA.Text:=  '';
  NOTE.Text:=            '';
end;

procedure TFrArma.ReadOnlyEdit(edit: boolean);
begin
  ksarma.Enabled:= not edit;
  ksarma.ReadOnly:= not edit;
  MATRICOLACANNA.ReadOnly:= edit;
  MATRICOLAPISTOLA.ReadOnly:= edit;
  note.ReadOnly:= edit;
end;

procedure TFrArma.Esegui(grant: integer);
begin
  LeggeDati;
  if Grant = 4 then //Solo Lettura
    begin
      SBedit.Visible:=False;
    end;
end;

end.

