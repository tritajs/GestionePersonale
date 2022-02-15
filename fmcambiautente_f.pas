unit fmcambiautente_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, DM_f, WTComboBoxSql;

type

  { TFmCambiaUtente }

  TFmCambiaUtente = class(TForm)
    CBLmilitari: TWTComboBoxSql;
    Image2: TImage;
    Label1: TLabel;
    LabelTitolo1: TLabel;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FmCambiaUtente: TFmCambiaUtente;

implementation

uses main_f;

{$R *.lfm}

{ TFmCambiaUtente }

procedure TFmCambiaUtente.SpeedButton1Click(Sender: TObject);
begin
   user.matr:= CBLmilitari.ValueLookField;
   dm.Accesso_Nominativo;
   dm.LoadAutorizzazioni;
   Close;
end;

end.

