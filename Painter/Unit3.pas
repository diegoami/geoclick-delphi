unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ToolWin, ComCtrls, upainter, StdCtrls, ExtCtrls;
const
    MinHeight = 260;
  MinWidth = 480;

type
  TForm3 = class(TForm)
    ToolBar1: TToolBar;
    SpeedButton1: TSpeedButton;
    ColorDialog1: TColorDialog;
    Edit1: TEdit;
    SpeedButton2: TSpeedButton;
    OpenDialog1: TOpenDialog;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    procedure SpeedButton1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure ImageFrame1ImageMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageFrame1ImageMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton2Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    PictureWidth : integer;
    procedure ScaleFormToImage(ABitmap: TBitmap; Center: Boolean);

  public
    procedure SetPaintColor(NEwColor : TColor);
    procedure PaintAt(X,Y : integer);

  end;

var
  Form3: TForm3;

implementation

uses jpeg;

var TheImage : TBitmap;

{$R *.DFM}

function Dist(const P1, P2 : TPoint): double;
begin
  Dist := sqrt(sqr(P2.X - P1.X) + sqr(P2.Y - P1.Y));
end;

function Min(x, y: Integer): Integer;
begin
  if x <= y then
    Result := x else
    Result := y;
end;

function Max(x, y: Integer): Integer;
begin
  if x >= y then
    Result := x else
    Result := y;
end;



procedure TForm3.SetPaintColor(NEwColor : TColor);
begin
  TheImage.Canvas.Brush.Color := NewColor;
  TheImage.Canvas.Pen.Color := NewColor;
  PaintBox1.Canvas.Brush.Color := NewColor;
  PaintBox1.Canvas.Pen.Color := NewColor;

end;


procedure TForm3.SpeedButton1Click(Sender: TObject);
begin
  if (ColorDialog1.Execute) then begin
    SetPaintColor(ColorDialog1.Color);

  end;
end;

procedure TForm3.Edit1Change(Sender: TObject);
begin
  PictureWidth := StrToInt(Edit1.Text);
end;

procedure TForm3.PaintAt(X,Y : integer);
var LX, LY : integer;
begin
  LX := X+ScrollBox1.HorzScrollBar.ScrollPos;
  LY := Y+ScrollBox1.VertScrollBar.ScrollPos;
  TheImage.Canvas.Ellipse(X-PictureWidth ,Y-PictureWidth,X+PictureWidth,Y+PictureWidth);
  PaintBox1.Canvas.Ellipse(X-PictureWidth ,Y-PictureWidth,X+PictureWidth,Y+PictureWidth);

//  PaintBox1.Invalidate;
end;

procedure TForm3.ImageFrame1ImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var LX, LY : integer;
begin
  LX := X+ScrollBox1.HorzScrollBar.ScrollPos;
  LY := Y+ScrollBox1.VertScrollBar.ScrollPos;

  if (Button = mbRight) then
    SetPaintColor(TheImage.Canvas.Pixels[X,Y])
  else
    PaintAt(X,Y);
end;

procedure TForm3.ImageFrame1ImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) then
    PaintAt(X,Y);

end;

procedure TForm3.ScaleFormToImage(ABitmap : TBitmap; Center: Boolean);
var
  P: TWindowPlacement;
  W, H: Integer;
begin
  if ABitmap = Nil then
    Exit;
    P.Length := SizeOf(TWindowPlacement);
    GetWindowPlacement(Self.Handle, @P);
    W := Min(Max(Width , MinWidth) +
     Self.Width - Self.ClientWidth, Screen.Width);
    H := Min(Max(Height , MinHeight) +
    Self.Height - Self.ClientHeight, Screen.Height);
    if Center then
      P.rcNormalPosition := Bounds(Max((Screen.Width - W) div 2, 0),
                                   Max((Screen.Height - H) div 2, 0), W, H)
    else
      with P.rcNormalPosition do begin
      if Left + W > Screen.Width then
        Left := Screen.Width - W;
      if Top + H > Screen.Height then
        Top := Screen.Height - H;
      P.rcNormalPosition := Bounds(P.rcNormalPosition.Left,
                                   P.rcNormalPosition.Top, W, H);
      end;
    SetWindowPlacement(Self.Handle, @P);
    ScrollBox1.AutoScroll := False;
    ScrollBox1.AutoScroll := True;
    PaintBox1.Canvas.StretchDraw(PaintBox1.ClientRect, ABitmap);
end;

procedure TForm3.SpeedButton2Click(Sender: TObject);
var BufferedImage : TJPegImage;
begin

  if (OpenDialog1.Execute) then begin
     BufferedImage := TJPEGImage.Create;
    TheImage := TBitmap.Create;
    //AutoSize := True;
    BufferedImage.LoadFromFile(OpenDialog1.Filename);
    TheImage.Width := BufferedImage.Width;
    TheImage.Height := BufferedImage.Height;
    TheImage.Canvas.Draw(0,0,BufferedImage);
    PaintBox1.ClientWidth := TheImage.Width;
    PaintBox1.ClientHeight := TheImage.Height;
  ScaleFormToImage(TheImage, false);
  end;
end;

procedure TForm3.PaintBox1Paint(Sender: TObject);
begin
  if TheImage <> nil then
    PaintBox1.Canvas.StretchDraw(PaintBox1.ClientRect, TheImage);

end;

end.
