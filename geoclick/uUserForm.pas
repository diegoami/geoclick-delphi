unit uUserForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uGeoController, Buttons;

type
  TUserForm = class(TForm)
    Label1: TLabel;
    OKButton: TBitBtn;
    CancelButton: TBitBtn;
    ComboBox1: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UserForm: TUserForm;

implementation

{$R *.DFM}

procedure TUserForm.FormShow(Sender: TObject);
begin

  ComboBox1.Items.Clear;
  ComboBox1.Items.Assign(GeoController.GetAllUsers);
  
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(GeoController.Username);
end;

procedure TUserForm.OKButtonClick(Sender: TObject);

begin

  //GeoController.Username := ComboBox1.Items[ComboBox1.ItemIndex];
  GeoController.Username := ComboBox1.Text;
  Close;
end;

procedure TUserForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

end.
