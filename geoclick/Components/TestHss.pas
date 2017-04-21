unit TestHss;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HyperImagesScrollBox;

type
  TForm1 = class(TForm)
    HISS : THyperImagesScrollBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  HISS := THyperImagesScrollBox.Create(Self);
  HISS.Parent := Self;
  HISS.Align := alClient;
  HISS.PicturesDir := 'C:\Programme\Borland\Delphi 3\Miei\Geotest 2\Europe\';
  HISS.HotSpotFile := 'Europe.hsf';
  HISS.ImageFileName := 'Italy_pol96.jpg';

end;

end.
