unit fmnote_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls;

type

  { TFmNote }

  TFmNote = class(TForm)
    Image1: TImage;
    Memo: TMemo;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBok: TSpeedButton;
    procedure SBcancelClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FmNote: TFmNote;

implementation

{$R *.lfm}

{ TFmNote }

procedure TFmNote.SBokClick(Sender: TObject);
begin
  ModalResult:=mrOK;
end;

procedure TFmNote.SBcancelClick(Sender: TObject);
begin
  ModalResult:=mrIgnore;
end;

end.

