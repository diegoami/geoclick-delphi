unit OvalBtn;

{ TOvalButton (C)opyright 1998 Version 1.2
  Autor : Simon Reinhardt
  eMail : S.Reinhardt@WTal.de
  Internet : http://sr-soft.wtal.de

  Die Komponente TOvalButton ist eine Weiterentwicklung der Komponente
  TRoundButton von Brendan Rempel, der so nett war, diese als Public Domain
  zu veröffentlichen.

  Auch diese Komponente TOvalButton ist Public Domain, das Copyright liegt
  aber beim Autor.}

interface

uses
  {$IFDEF WIN32} Windows, {$ELSE} WinTypes, WinProcs, {$ENDIF} Classes, Graphics,
  Controls, SysUtils, Messages, Dialogs, DsgnIntf;

const
  DefaultWidth  = 100;
  DefaultHeight = 50;

type

  TNumGlyphs = 1..4;
  TLayout    = (blGlyphLeft,blGlyphRight,blGlyphTop,blGlyphBottom);

type
  TAboutProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;

  TOvalButton = class(TGraphicControl)
  private
    FAbout:            TAboutProperty;
    FColor,
    FColorHighlight,
    FColorShadow:      TColor;
    FDown,IsDown,
    FFlat:             boolean;
    FEndColor:         TColor;
    FFont:             TFont;
    FGlyph:            TBitmap;
    FGroupIndex:       integer;
    FLayout:           TLayout;
    FMargin:           integer;
    FNumGlyphs:        TNumGlyphs;
    FSpacing:          integer;
    FStartColor:       TColor;
    FState:            integer;
    FTransparent:      boolean;
    FTransparentColor: TColor;

    FMouseDown:        boolean;
    FMouseInside:      boolean;
    FOnClick:          TNotifyEvent;
    FOnDblClick:       TNotifyEvent;
    FOnMouseEnter:     TNotifyEvent;
    FOnMouseExit:      TNotifyEvent;

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

  protected
    procedure Paint;  override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
       override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
       override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
       override;

    function  IsInsideButton(X,Y: Integer): boolean;

    procedure SetColor(newColor: TColor);
    procedure SetDown(Value: boolean);
    procedure SetEndColor(newColor: TColor);
    procedure SetFlat(Value: boolean);
    procedure SetFont(Value: TFont);
    procedure SetGlyph(newGlyph: TBitmap);
    procedure SetLayout(newLayout: TLayout);
    procedure SetMargin(Value: integer);
    procedure SetNumGlyphs(newNumGlyphs: TNumGlyphs);
    procedure SetSpacing(Value: integer);
    procedure SetStartColor(newColor: TColor);
    procedure SetTransparent(Value: boolean);
    procedure SetTransparentColor(newTransparentColor: TColor);

    procedure PaintBorder;
    procedure PaintButton;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CMTextChanged(var msg: TMessage);message CM_TEXTCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar);message CM_DIALOGCHAR;

  published
    property About: TAboutProperty read FAbout write FAbout;
    property Caption;
    property Color: TColor read FColor write SetColor;
    property Down: boolean read FDown write SetDown;
    property Enabled;
    property EndColor: TColor read FEndColor write SetEndColor;
    property Flat: boolean read FFlat write SetFlat;
    property Font: TFont read FFont write SetFont;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property GroupIndex: integer read FGroupIndex write FGroupIndex;
    property Layout: TLayout read FLayout write SetLayout;
    property Margin: integer read FMargin write SetMargin;
    property NumGlyphs: TNumGlyphs read FNumGlyphs write SetNumGlyphs default 1;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Spacing: integer read FSpacing write SetSpacing;
    property StartColor: TColor read FStartColor write SetStartColor;
    property Transparent: boolean read FTransparent write SetTransparent;
    property TransparentColor: TColor read FTransparentColor write SetTransparentColor;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseExit: TNotifyEvent read FOnMouseExit  write FOnMouseExit;
  end;

procedure Register;

implementation

function IsAccellerator(VK: Word; const Str: string): Boolean;
var
  P : Integer;
begin
  P := Pos('&', Str);
  Result := (P <> 0) and (P < Length(Str)) and
    (Upcase(Str[P + 1])=Upcase(Char(VK)));
end;

function ChangeBrightness(Color:TColor;Percentage:longint):TColor;
var RGBColor       : longint;
    Red,Green,Blue : byte;
    NewR,NewG,NewB : longint;
    Overflow       : longint;
begin
  RGBColor:=ColorToRGB(Color);
  Overflow:=0;
  {Rot}
  Red:=GetRValue(RGBColor);
  NewR:=Red+(Percentage*Red div 100);
  if NewR>255 then begin
    Overflow:=NewR-255;
    NewG:=Overflow;
    NewB:=Overflow;
  end
  else begin
    NewG:=0;
    NewB:=0;
  end;
  {Grün}
  Green:=GetGValue(RGBColor);
  NewG:=NewG+Green+(Percentage*Green div 100);
  if NewG>255 then begin
    Overflow:=NewG-255;
    NewR:=NewR+Overflow;
    NewB:=Overflow;
  end;
  {Blau}
  Blue:=GetBValue(RGBColor);
  NewB:=NewB+Blue+(Percentage*Blue div 100);
  if NewB>255 then begin
    Overflow:=NewB-255;
    if NewG<=255 then
      NewR:=NewR+Overflow;
  end;
  if NewR>255 then
    NewR:=255;
  if NewG>255 then
    NewG:=255;
  if NewB>255 then
    NewB:=255;
  if NewR<0 then
    NewR:=0;
  if NewG<0 then
    NewG:=0;
  if NewB<0 then
    NewB:=0;
  Result:=NewR+(NewG shl 8)+(NewB shl 16);
end;

procedure TAboutProperty.Edit;
const
  CarriageReturn = chr(13);
var Msg: string;
begin
  Msg := 'OvalButton Komponente v1.2';
  Msg:=Msg+CarriageReturn+CarriageReturn;
  Msg:=Msg+'Copyright © 1998 Simon Reinhardt, alle Rechte vorbehalten.';
  Msg:=Msg+CarriageReturn+CarriageReturn;
  Msg:=Msg+'  eMail: S.Reinhardt@WTal.de'+CarriageReturn+CarriageReturn;
  Msg:=Msg+'  Homepage: http://sr-soft.wtal.de'+CarriageReturn;
  ShowMessage(Msg);
end;

function TAboutProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paDialog, paReadOnly];
end;

function TAboutProperty.GetValue: string;
begin
  Result := 'Komponenten-Infos';
end;

constructor TOvalButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  {Vorgabewerte setzen}
  FColor:=clBtnFace;
  FColorHighlight:=ChangeBrightness(FColor,60);
  FColorShadow:=ChangeBrightness(FColor,-50);
  FDown:=false;
  FFlat:=false;
  FFont:=TFont.Create;
  FGlyph:=TBitmap.Create;
  FGroupIndex:=0;
  FNumGlyphs:=1;
  FSpacing :=4;
  FState:=1;
  FTransparent:=false;
  Height:=DefaultHeight;
  Width:=DefaultWidth;

  FMouseInside:=False;
  FMouseDown:=False;
end;

destructor  TOvalButton.Destroy;
begin
  FFont.Free;
  FGlyph.Free;
  inherited Destroy;
end;

procedure TOvalButton.SetColor(newColor: TColor);
begin
  FColor:=newColor;
  FColorHighlight:=ChangeBrightness(FColor,60);
  FColorShadow:=ChangeBrightness(FColor,-50);
  Invalidate;
end;

procedure TOvalButton.SetDown(Value: boolean);
begin
  FDown := Value;
  if FDown then
    FState := -1
  else begin
    if FFlat then
      FState := 0
    else
      FState := 1;
  end;
  Invalidate;
end;

procedure TOvalButton.SetEndColor(newColor: TColor);
begin
  FEndColor:=newColor;
  Invalidate;
end;

procedure TOvalButton.SetFlat(Value: boolean);
begin
  FFlat := Value;
  if FFlat then
    FState := 0
  else
    FState := 1;
  Invalidate;
end;

procedure TOvalButton.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
  Invalidate;
end;

procedure TOvalButton.SetGlyph(newGlyph: TBitmap);
begin
  if(Assigned(FGlyph)) then begin
    FGlyph.Assign(newGlyph);
    FTransparentColor:=FGlyph.Canvas.Pixels[0,FGlyph.Height-1];

    if (csDesigning in ComponentState) then begin
      { Glyph 1: Normal, 2: Disabled, 3: Down;
        Muß die Ausmaße (Height * NumGlyphs) = Width  haben}
      if (newGlyph.width mod newGlyph.height = 0) then
        FNumGlyphs:= newGlyph.width div newGlyph.height
      else
        FNumGlyphs:= 1;
    end;

    Invalidate;
  end;
end;

procedure TOvalButton.SetLayout(newLayout: TLayout);
begin
  FLayout:=newLayout;
  Invalidate;
end;

procedure TOvalButton.SetMargin(Value: integer);
begin
  FMargin:=Value;
  Invalidate;
end;

procedure TOvalButton.SetNumGlyphs(newNumGlyphs: TNumGlyphs);
begin
  FNumGlyphs:= newNumGlyphs;
  Invalidate;
end;

procedure TOvalButton.SetSpacing(Value: integer);
begin
  FSpacing:=Value;
  Invalidate;
end;

procedure TOvalButton.SetStartColor(newColor: TColor);
begin
  FStartColor:=newColor;
  Invalidate;
end;

procedure TOvalButton.SetTransparent(Value : boolean);
begin
  FTransparent:= Value;
  Invalidate;
end;

procedure TOvalButton.SetTransparentColor(newTransparentColor: TColor);
begin
  FTransparentColor:= newTransparentColor;
  Invalidate;
end;

function TOvalButton.IsInsideButton(X,Y: Integer): boolean;
var BtnEllipse : HRgn;
begin
  { Ist die Maus über der Button-Ellipse? }
  BtnEllipse := CreateEllipticRgn(0,0,Width,Height);
  Result := PtInRegion(BtnEllipse,X,Y);
  DeleteObject(BtnEllipse);
end;

procedure TOvalButton.Paint;
begin
  Canvas.Font.Assign(Font);
  with Canvas do begin
     if FTransparent then
       brush.Style:= bsClear
     else begin
       Brush.Style:= bsSolid;
       brush.color:= Color;
     end;
     if FFlat then
       pen.Style := psClear
     else begin
       pen.Style := psSolid;
       pen.color := clBlack;
     end;
     { Button mit Farbe füllen, schwarzen Rand zeichnen }
     Pen.Width:=1;
     Ellipse(0,0,width-1,height-1);
  end;

  { Den Rest zeichnen }
  PaintButton;
end;

procedure TOvalButton.PaintBorder;
begin
  with Canvas do begin
    pen.style:= psSolid;
    { linke obere Ecke zeichnen }
    if FState=-1 then  {down}
      pen.color:= FColorShadow;
    if FState=1 then  {up}
      pen.color:= FColorHighlight;
    if FState=0 then  {flat}
      pen.style:= psClear;
    Arc(1,1,width-2,height-2,width div 5 * 4,height div 5,width div 5,height div 5 * 4);
    { rechte untere Ecke zeichnen }
    if FState=-1 then  {down}
      pen.color:= FColorHighlight;
    if FState=1 then   {up}
      pen.color:= FColorShadow;
    Arc(1,1,width-2,height-2,width div 5,height div 5 * 4,width div 5 * 4,height div 5);
    pen.style:= psSolid;
  end;
end;

procedure TOvalButton.PaintButton;
var
  Dest,Source,TextR  : TRect;
  outWidth,outHeight : integer;
  TextLeft,TextTop   : integer;
  outText            : array [0..79] of char;
begin
  {Glyph zeichnen ?}
  if Assigned(FGlyph) then begin
     with Source do begin
       { Source-Rechteck ermitteln }
       Left:=0;
       Right:=FGlyph.Width;
       Top:=0;
       Bottom:=FGlyph.Height;
       if FNumGlyphs>0 then
         Right:=Right div FNumGlyphs;
     end;
  end;

  PaintBorder;

  with Canvas do begin
    { Glyph anzeigen }
    outWidth:=  0;
    outHeight:= 0;
    if Assigned(FGlyph) and (FNumGlyphs > 0) then begin
      if(Not Enabled and (FNumGlyphs > 1)) then begin
        { disabled button }
        Source.Left:=  FGlyph.width div FNumGlyphs;
        Source.Right:= Source.Left shl 1;
      end;
      { Größe des Destination-Rechtecks }
      outWidth:=  Source.Right-Source.Left;
      outHeight:= Source.Bottom-Source.Top;
      { Glyph-Position ermitteln }
      if (Caption='') or (FLayout=blGlyphTop) or (FLayout=blGlyphBottom) then begin
        Dest.Left:=  ((Width  - outWidth)  shr 1);
        Dest.Right:= ((Width  - outWidth)  shr 1)+outWidth;
      end;
      if (Caption<>'') and (FLayout=blGlyphLeft) then begin
        Dest.Left:=  ((Width  - (outWidth + FSpacing + TextWidth(Caption)))  shr 1)-FMargin;
        Dest.Right:= Dest.Left + outWidth;
      end;
      if (Caption<>'') and (FLayout=blGlyphRight) then begin
        Dest.Left:=  ((Width  + (outWidth + FSpacing + TextWidth(Caption)))  shr 1)-outWidth+FMargin;
        Dest.Right:= Dest.Left + outWidth;
      end;
      if (Caption='') or (FLayout=blGlyphLeft) or (FLayout=blGlyphRight) then begin
        Dest.Top:=   ((Height - outHeight) shr 1);
        Dest.Bottom:=((Height - outHeight) shr 1)+outHeight;
      end;
      if (Caption<>'') and (FLayout=blGlyphTop) then begin
        Dest.Top:=  ((Height  - (outHeight + FSpacing + TextHeight(Caption)))  shr 1)-FMargin;
        Dest.Bottom:= Dest.Top + outHeight;
      end;
      if (Caption<>'') and (FLayout=blGlyphBottom) then begin
        Dest.Top:=  ((Height  + (outHeight + FSpacing + TextHeight(Caption)))  shr 1)-outHeight+FMargin;
        Dest.Bottom:= Dest.Top + outHeight;
      end;
      if FTransparent then
        Pen.Style := psClear
      else begin
        Pen.Style := psSolid;
        Pen.Color := Color;
      end;
      if FState=-1 then begin {down}
        { Glyph um 1 Pixel nach rechts unten verschieben }
        Inc(Dest.Left);
        Inc(Dest.Right);
        Inc(Dest.Top);
        Inc(Dest.Bottom);
        { verbleibende Up-Reste löschen }
        MoveTo(Dest.Left-1,Dest.Bottom);
        LineTo(Dest.Left-1,Dest.Top-1);
        LineTo(Dest.Right,Dest.Top-1);
      end
      else begin
        { verbleibende Down-Reste löschen }
        MoveTo(Dest.Right,Dest.Top);
        LineTo(Dest.Right,Dest.Bottom);
        LineTo(Dest.Left,Dest.Bottom);
      end;
      Pen.Style := psSolid;
      if ((FState=-1) and (FNumGlyphs > 2)) then begin
        { Glyph für gedrückten Zustand bestimmen }
        Source.Left:= FGlyph.width div FNumGlyphs * 2;
        Source.Right:=FGlyph.width div FNumGlyphs * 3;
      end;
      if FTransparent then
        Brush.Style:= bsClear
      else begin
        Brush.Style:= bsSolid;
        Brush.Color:= Color;
      end;

      { Glyph zeichnen }
      BrushCopy(Dest,FGlyph,Source,FTransparentColor);
    end;

    { Caption zeichnen }
    if Caption<>'' then begin
      {Position ermitteln}
      TextLeft:=(width -TextWidth(Caption)) shr 1;
      if Assigned(FGlyph) and (FNumGlyphs > 0) and (FLayout=blGlyphRight) then
        TextLeft:=Dest.Left-TextWidth(Caption)-FSpacing;
      if Assigned(FGlyph) and (FNumGlyphs > 0) and (FLayout=blGlyphLeft) then
        TextLeft:=Dest.Left+outWidth+FSpacing;
      TextTop:=(height - TextHeight(Caption)) shr 1;
      if Assigned(FGlyph) and (FNumGlyphs > 0) and (FLayout=blGlyphTop) then
        TextTop:=Dest.Top+outHeight+FSpacing;
      if Assigned(FGlyph) and (FNumGlyphs > 0) and (FLayout=blGlyphBottom) then
        TextTop:=Dest.Top-TextHeight(Caption)-FSpacing;
      if FState=-1 then
        inc(TextTop);
      {Text ausgeben}
      if FTransparent then
        Brush.Style := bsClear
      else begin
        Brush.Style := bsSolid;
        Brush.Color := Color;
      end;
      if FState=-1 then
        { verbleibende Up-Reste löschen }
        FillRect(Rect(TextLeft,TextTop,TextLeft+TextWidth(Caption),TextTop+TextHeight(Caption)))
      else
        { verbleibende Down-Reste löschen }
        FillRect(Rect(TextLeft+1,TextTop+1,TextLeft+1+TextWidth(Caption),TextTop+1+TextHeight(Caption)));
      TextR:=Rect(TextLeft,TextTop,TextLeft+TextWidth(Caption),TextTop+TextHeight(Caption));
      StrPCopy(outText,Caption);
      DrawText(Handle, outText, length(Caption), TextR, dt_center or dt_vcenter or dt_singleline);
    end;
  end;
end;

procedure TOvalButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do begin
    if IsAccellerator(CharCode, Caption) then begin
      if Enabled then
        Click;
      Result := 1;
    end
    else
      inherited;
  end;
end;

procedure TOvalButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Enabled and IsInsideButton(X,Y)) then begin
    IsDown:=FDown;
    { Im gedrückten Zustand neu zeichnen }
    FDown:=true;
    FState:= -1;
    if FTransparent then
      Invalidate
    else
      PaintButton;
  end;
  FMouseDown:= True;
end;

procedure TOvalButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Enabled and IsInsideButton(X,Y)) then begin
    { Im ungedrückten Zustand neu zeichnen }
    if GroupIndex=0 then begin
      FDown:=false;
      FState:= 1;
      if FTransparent then
        Invalidate
      else
        PaintButton;
    end
    else
      SetDown(not IsDown);
    { OnClick-Ereignis abfeuern }
    if Assigned(FOnClick) then
       FOnClick(Self);
  end;
  FMouseDown:= False;
end;

procedure TOvalButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FMouseDown then begin
    if not IsInsideButton(X,Y) then begin
      { Button.Down aufheben, falls Maus Button verlässt }
      if (FState=-1) and (GroupIndex=0) and FMouseInside then begin
        FDown:=false;
        FState:=1;
        PaintBorder;
      end;
      FMouseInside:=false;
    end
    else begin
      { Button.Down setzen, falls Maus über Button }
      if (FState=1) and (GroupIndex=0) then begin
        FMouseInside:=true;
        FDown:=true;
        FState:=-1;
        PaintBorder;
      end;
    end;
  end
  else begin
    if FFlat and not FDown then begin
      if not IsInsideButton(X,Y) then begin
        { Button flach }
        if FMouseInside then begin
          FMouseInside:=false;
          FState:=0;
          Invalidate;
        end;
      end
      else begin
        { Button erhaben }
        FMouseInside:=true;
        FState:=1;
        PaintBorder;
      end;
    end
    else
      FMouseInside:=IsInsideButton(X,Y);
  end;
end;

procedure TOvalButton.CMTextChanged(var msg: TMessage);
begin
  Invalidate;
end;

procedure TOvalButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
end;

procedure TOvalButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FMouseInside and Enabled then begin
    FMouseInside := False;
    if FFlat and not FDown then begin
      FState:=0;
      Invalidate;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Simon',[TOvalButton]);
  RegisterPropertyEditor(TypeInfo(TAboutProperty), TOvalButton, 'ABOUT', TAboutProperty);
end;

end.
