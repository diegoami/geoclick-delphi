unit upainter;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, jpeg;

type
  TImageFrame = class(TFrame)
  private
    Image : TImage;
    FColor : TColor;
    FWidth : integer;
  public
    procedure SetWidth(NewWidth : integer);
    procedure SetColor(NewColor : TColor);
    procedure LoadImage(FileName : string);
    procedure PaintAt(X, Y : integer);

  end;

implementation

{$R *.DFM}

procedure TImageFrame.PaintAt(X, Y : integer);
begin
  Image.Canvas.Ellipse(X-FWidth, Y-FWidth, X+FWidth, Y+FWidth);
end;


procedure TImageFrame.SetColor(NewColor : TColor);
begin
  Image.Canvas.Pen.Color := NewColor;
  Image.Canvas.Brush.Color := NewColor;
  FColor := Color;
end;

procedure TImageFrame.SetWidth(NewWidth : integer);
begin
  FWidth := NewWidth;
end;



procedure TImageFrame.LoadImage(FileName : string);
begin
  Image.Picture.LoadFromFile(FileName);

end;

end.
