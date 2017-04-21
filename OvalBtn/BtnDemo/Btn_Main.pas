unit Btn_Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, OvalBtn, StdCtrls;

type
  TMainForm = class(TForm)
    Hintergrund: TImage;
    OvalButton1: TOvalButton;
    OvalButton2: TOvalButton;
    OvalButton3: TOvalButton;
    OvalButton4: TOvalButton;
    OvalButton5: TOvalButton;
    OvalButton6: TOvalButton;
    OvalButton7: TOvalButton;
    OvalButton8: TOvalButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure OvalButton2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.OvalButton2Click(Sender: TObject);
begin
  MessageBeep(0);
end;




end.
