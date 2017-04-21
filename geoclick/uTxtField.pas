unit uTxtField;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TTextFieldDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Edit1: TEdit;
    Label1: TLabel;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    Canceled : Boolean;
    Text : String;
  end;



implementation

{$R *.DFM}

procedure TTextFieldDialog.OKBtnClick(Sender: TObject);
begin
  Canceled := False;
  Text := Edit1.Text;
  Hide;
end;

procedure TTextFieldDialog.CancelBtnClick(Sender: TObject);
begin
  Canceled := True;
  Hide;
end;

end.
