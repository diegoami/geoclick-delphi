unit uMapForm2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CustomHImages, HImages, ExtCtrls, JPeg, StdCtrls, Buttons,
  HyperImagesScrollBox;

type

  TMapForm = class(TForm)
    RightPanel: TPanel;
    VerticalSplitter: TSplitter;
    BottomPanel: TPanel;
    HotSpotMemo: TMemo;
    HorizSplitter: TSplitter;
    TopPanel: TPanel;
    Image: TImage;
    ZoomInSpeedButton: TSpeedButton;
    ZoomOutSpeedButton: TSpeedButton;
    ZoomScrollBar: TScrollBar;
    HyperImagesScrollBox1: THyperImagesScrollBox;

    procedure ZoomInSpeedButtonClick(Sender: TObject);
    procedure ZoomOutSpeedButtonClick(Sender: TObject);
//    procedure ZoomScrollBarChange(Sender: TObject);
    procedure ZoomInSpeedButtonMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomOutSpeedButtonMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomOutSpeedButtonMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomInSpeedButtonMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HISSHotSpotClicked(HotSpot: String);
  private
    Timeclicked : TDateTime;
  public
    Owner : TObject;
    procedure ShowDesc(S : String);
  published

  end;

var
  MapForm: TMapForm;

implementation

{$R *.DFM}







procedure TMapForm.ShowDesc(S : String);
begin
     HotSpotMemo.Lines.Add(S);
end;

procedure TMapForm.ZoomInSpeedButtonClick(Sender: TObject);
begin
{
   HyperImages.Scale := HyperImages.Scale+5;
   ZoomScrollBar.Position := HyperImages.Scale;}
end;

procedure TMapForm.ZoomOutSpeedButtonClick(Sender: TObject);
begin
{  HyperImages.Scale := HyperImages.Scale-5;
  ZoomScrollBar.Position := HyperImages.Scale;}
end;
{
procedure TMapForm.ZoomScrollBarChange(Sender: TObject);
begin
   HyperImages.Scale := ZoomScrollBar.Position;
end;
}
procedure TMapForm.ZoomInSpeedButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TimeClicked := Now;
end;

procedure TMapForm.ZoomOutSpeedButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TimeClicked := Now;
end;

procedure TMapForm.ZoomOutSpeedButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var STA : integer;
begin
  STA := Round((Now - TimeClicked)*3600.0*50.0);
  HyperImagesScrollbox1.Zoom(-STA);
end;

procedure TMapForm.ZoomInSpeedButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var STA : integer;
begin
  STA := Round((Now - TimeClicked)*3600.0*50.0);
  HyperImagesScrollBox1.Zoom(STA);

end;


procedure TMapForm.HISSHotSpotClicked(HotSpot: String);
begin
  ShowDesc(HotSpot);
end;

end.
