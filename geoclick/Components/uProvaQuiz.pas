unit uProvaQuiz;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HyperImagesScrollBox, ExtCtrls, ComCtrls, OvalButtonsPanel;

type
  TProvaQuiz = class(TForm)
    ZoomerPanel1: TZoomerPanel;
    HyperImagesScrollBox1: THyperImagesScrollBox;
    StatusBar1: TStatusBar;
    Splitter1: TSplitter;
    OvalButtonsPanel1: TOvalButtonsPanel;
    procedure HyperImagesScrollBox1HotSpotClicked(HotSpot: String);
    procedure OvalButtonsPanel1Resize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OvalButtonsPanel1AllGuessed;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProvaQuiz: TProvaQuiz;

implementation

{$R *.DFM}

procedure TProvaQuiz.HyperImagesScrollBox1HotSpotClicked(HotSpot: String);
begin
  StatusBar1.SimpleText := HotSpot;
  if OvalButtonsPanel1.GetCurrentString = HotSpot then
    OvalButtonsPanel1.Guessed;
end;

procedure TProvaQuiz.OvalButtonsPanel1Resize(Sender: TObject);
begin
  OvalButtonsPanel1.OnResize(Self);
end;

procedure TProvaQuiz.FormCreate(Sender: TObject);

begin
  HyperImagesScrollBox1.PicturesDir := ExtractFilePath(Application.ExeName) + 'europe\';
  HyperImagesScrollBox1.HotSpotFile := 'countries.hsf';
  HyperImagesScrollBox1.ImageFileName := 'europe.jpg';
  OvalButtonsPanel1.PossibleValuesList := HyperImagesScrollBox1.GetHotspotsList;
  OvalButtonsPanel1.GenerateTest(OvalButtonsPanel1.NButtons);

end;

procedure TProvaQuiz.OvalButtonsPanel1AllGuessed;
begin
  MessageBox(0,'Bravissimo','Messaggio',0);
  OvalButtonsPanel1.NButtons := OvalButtonsPanel1.NButtons+1;
  OvalButtonsPanel1.GenerateTest(OvalButtonsPanel1.NButtons);
end;

end.
