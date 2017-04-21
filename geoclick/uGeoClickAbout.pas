unit uGeoClickAbout;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, stringfns;

type             
  TGeoClickAboutBox = class(TForm)
    Panel1: TPanel;
    OKButton: TButton;
    ProductName: TLabel;
    Copyright: TLabel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    procedure OKButtonClick(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GeoClickAboutBox: TGeoClickAboutBox;

implementation

{$R *.DFM}

procedure TGeoClickAboutBox.OKButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TGeoClickAboutBox.Label2Click(Sender: TObject);
begin
  ShowWebPage('mailto:diegoami@yahoo.it');
end;

procedure TGeoClickAboutBox.Label1Click(Sender: TObject);
begin
  ShowWebPage('http://clickit.pair.com');
end;

procedure TGeoClickAboutBox.BitBtn1Click(Sender: TObject);
begin
  Close
end;

end.

