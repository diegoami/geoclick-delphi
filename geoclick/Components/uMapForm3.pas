unit uMapForm3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CustomHImages, HImages, ExtCtrls, JPeg, StdCtrls, Buttons;

type

  TMapForm = class(TForm)
    RightPanel: TPanel;
    VerticalSplitter: TSplitter;
    HyperImageScrollBox: TScrollBox;
    HyperImages: THyperImages;
    BottomPanel: TPanel;
    HotSpotMemo: TMemo;
    HorizSplitter: TSplitter;
    TopPanel: TPanel;
    Image: TImage;
    ZoomInSpeedButton: TSpeedButton;
    ZoomOutSpeedButton: TSpeedButton;
    ZoomScrollBar: TScrollBar;

    procedure ZoomInSpeedButtonClick(Sender: TObject);
    procedure ZoomOutSpeedButtonClick(Sender: TObject);
    procedure ZoomScrollBarChange(Sender: TObject);
    procedure ZoomInSpeedButtonMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomOutSpeedButtonMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomOutSpeedButtonMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomInSpeedButtonMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    Timeclicked : TDateTime;
  public
    Owner : TObject;
    procedure ShowDesc(S : String);
  published

  end;
{
var
  MapForm: TMapForm;
 }
implementation

{$R *.DFM}

uses uMapController;



procedure TMapForm.HyperImagesImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var S : String;
begin
  if ssRight in Shift then begin
    StartDrag := True;
    FX := X;
    FY := Y;
  end else
    if HyperImages.PointIsOnTarget(X,Y,S) then begin
       if Assigned(FOnHotSpotClicked) then
          FOnHotSpotClicked(S);
          ShowDesc(S);
    end;

end;

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

procedure TMapForm.ZoomScrollBarChange(Sender: TObject);
begin
   HyperImages.Scale := ZoomScrollBar.Position;
end;

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
  HyperImages.Scale := HyperImages.Scale-STA;
end;

procedure TMapForm.ZoomInSpeedButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var STA : integer;
begin
  STA := Round((Now - TimeClicked)*3600.0*50.0);
  HyperImages.Scale := HyperImages.Scale+STA;

end;

procedure TMapForm.HyperImagesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     HyperImageScrollbox.VertScrollBar.Position :=
        HyperImageScrollbox.VertScrollBar.Position+YTM;
      HyperImageScrollbox.HorzScrollBar.Position :=
        HyperImageScrollbox.HorzScrollBar.Position+XTM;

{  if StartDrag then
    with HyperImages do begin
      HyperImageScrollbox.VertScrollBar.Position :=
        HyperImageScrollbox.VertScrollBar.Position+Y-FY;
      HyperImageScrollbox.HorzScrollBar.Position :=
        HyperImageScrollbox.HorzScrollBar.Position+X-FX;

      Application.ProcessMessages;
      FX := X;
      FY := Y;      }
    {
    if Left < -Picture.Graphic.Width+Width then
      Left := -Picture.Graphic.Width+Width;
    if Top < -Picture.Graphic.Height+Height then
      Top := -Picture.Graphic.Height+Height;       }

    StartDrag := False;
end;

procedure TMapForm.HyperImagesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

  if ssRight in Shift then begin
     StartDrag := True;
     XTM :=0;
     YTM := 0;


  end;
end;

procedure TMapForm.HyperImagesImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if StartDrag then
    with HyperImages do begin
      {HyperImageScrollbox.VertScrollBar.Position :=
        HyperImageScrollbox.VertScrollBar.Position+(Y-FY) div 4;
      HyperImageScrollbox.HorzScrollBar.Position :=
        HyperImageScrollbox.HorzScrollBar.Position+(X-FX) div 4;
       }
      YTM := YTM+Y-FY;
      XTM := XTM+X-FX;
      X := FX;
      Y := FY;

    end;


end;

end.
