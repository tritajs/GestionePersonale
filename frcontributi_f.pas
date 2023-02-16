unit frcontributi_f;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, WTMemo, umEdit, Buttons, LSystemTrita;

type

  { TFrContributi }

  TFrContributi = class(TFrame)
    mm: TumNumberEdit;
    idcontributo: TumEdit;
    yy: TumNumberEdit;
    Image1: TImage;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    note: TWTMemo;
    Panel1: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBedit: TSpeedButton;
    SBok: TSpeedButton;
    dd: TumNumberEdit;
    procedure SBcancelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
  private
    procedure VisibleTastiConferma(button:boolean);
    procedure SalvaDati;
    procedure ReadOnlyEdit(edit:boolean);
  public
    procedure LeggeDati;
    procedure ClearDati;
    Procedure Esegui(grant:integer);
  end;

implementation

uses DM_f, fmdatipersonali_f;

{$R *.lfm}

{ TFrContributi }

procedure TFrContributi.SBeditClick(Sender: TObject);
begin
  VisibleTastiConferma(True);
  ReadOnlyEdit(False);
  Panel1.SetFocus;
  dd.SetFocus;
end;

procedure TFrContributi.SBcancelClick(Sender: TObject);
begin
  LeggeDati;
  VisibleTastiConferma(False);
  ReadOnlyEdit(True);
end;

procedure TFrContributi.SBokClick(Sender: TObject);
begin
  SalvaDati;
  VisibleTastiConferma(False);
  ReadOnlyEdit(True);
end;

procedure TFrContributi.VisibleTastiConferma(button: boolean);
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

procedure TFrContributi.SalvaDati;
Var st:string;
begin
   st:= 'select * from AGGIORNAMENTO_CONTRIBUTIESTERNI(' ;

   St:= st +  dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare

   if  dd.Text = '' then  //giorni
     st:= st + '0,'
   else
     st:= st + '''' + dd.Text + ''',';

   if  mm.Text = '' then  //mesi
     st:= st + '0,'
   else
     st:= st + '''' + mm.Text + ''',';

   if  mm.Text = '' then  //anni
     st:= st + '0,'
   else
     st:= st + '''' + yy.Text + ''',';

   if note.Text = '' then  // note
     st:= st + 'null)'
    else
     st:=  st + '''' +  StringReplace(note.Text,'''','''''',[rfReplaceAll]) + ''')';

   dm.QTemp.SQL.Text:= st;
   dm.QTemp.Open();
   dm.TR.CommitRetaining;
end;

procedure TFrContributi.LeggeDati;
Var st:string;
begin
  ClearDati;
  st:= ' select * from contributiesterni ' ;
  st:= st + ' where ksmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;  // ksmilitare
  if EseguiSQLDS(dm.DSetContributi,st,Open,'') then
    begin
      idcontributo.Text:=      dm.DSetContributi.FieldByName('idcontributo').AsString;
      dd.Text:=                dm.DSetContributi.FieldByName('dd').AsString; ;
      mm.Text:=                dm.DSetContributi.FieldByName('mm').AsString; ;
      yy.Text:=                dm.DSetContributi.FieldByName('yy').AsString; ;
      NOTE.Text:=              dm.DSetContributi.FieldByName('NOTE').AsString;
    end;
end;


procedure TFrContributi.ClearDati;
begin
  dd.Text:= '';
  mm.Text:= '';
  yy.Text:= '';
  note.Text:= ''
end;

procedure TFrContributi.ReadOnlyEdit(edit: boolean);
begin
  dd.ReadOnly:=    edit ;
  mm.ReadOnly:=    edit ;
  yy.ReadOnly:=    edit ;
  note.ReadOnly:=  edit ;
end;

procedure TFrContributi.Esegui(grant: integer);
begin
  LeggeDati;
  if Grant = 4 then //Solo Lettura
    begin
      SBedit.Visible:=False;
    end;
end;

end.

