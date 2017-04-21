///////////////////////////////////////////////////////////////////////////////
//////////////////////////THyperImages Component V.2///////////////////////////
///////////////////Copyright © 1998-1999 Noatak Racing Team////////////////////
///////////////////////////////////////////////////////////////////////////////

unit About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TAboutForm = class(TForm)
    Image1: TImage;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    CopyLabel: TLabel;
    VersionLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses ShellAPI, CustomHImages;

{$R *.DFM}

procedure TAboutForm.FormCreate(Sender: TObject);
var
  D, M, Y: Word;
begin
  DecodeDate(Now, Y, M, D);
  VersionLabel.Caption := 'Version ' + ComponentVersion + ' for Delphi '
  + Copy(DelphiVersion, 1, 1);
  CopyLabel.Caption := '© Noatak Racing Team - 1998-' + IntToStr(Y)  + #13#10 +
  'HC 33 box 32930'#13#10 +
  'Nenana, AK, 99760'#13#10 +
  'USA'
end;

procedure TAboutForm.Label1Click(Sender: TObject);
begin
  ShellExecute(Self.Handle, 'open', PChar(Label1.Caption), nil, nil,
                SW_SHOWNORMAL);
end;

end.
