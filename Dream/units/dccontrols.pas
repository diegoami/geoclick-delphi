{**************************************************}
{                                                  }
{  Common Library                                  }
{                                                  }
{  Copyright (c) 1997-2000 Dream Company           }
{  http://www.dream-com.com                        }
{  e-mail: contact@dream-com.com                   }
{                                                  }
{**************************************************}
unit dccontrols;

interface
uses
  windows, classes, forms, controls, graphics, messages, extctrls, dclib;

type
  THintState = (hsShow, hsHide, hsBeginShow);

  TDCHint = class(TComponent)
  private
    FAutoHide         : boolean;
    FHintWindow       : THintWindow;
    FHintTimer        : TTimer;
    FHintRect         : TRect;
    FBoldFont         : TFont;
    FCaption          : string;
    FHintState        : THintState;
    FTimerDelay       : integer;
    FImmediate        : boolean;
    FHintDelta        : integer;
    FOnVisibleChanged : TNotifyEvent;
    FVersion          : TDCVersion;

    function  GetInterval : integer;
    procedure SetInterval(Value : integer);
    function  GetVisible : boolean;
    procedure SetVisible(Value : boolean);
    procedure SetBoldFont(Value : TFont);
    procedure SetCaption(Value : string);
    procedure OnHintTimer(Sender: TObject);
    procedure HideHintWindow;
    procedure DrawHintWindow;
    procedure FontChanged(Sender : TObject);
  protected
    procedure ExecHintTimer; virtual;
    procedure VisibleChanged; virtual;
    function  IsHintInRect(R : TRect; Point : TPoint) : boolean; virtual;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy;  override;
    procedure ActivateHintAtPos(const Point : TPoint; const S : string);
    procedure ActivateHint(const S : string);
    procedure CancelHint;
    property  HintWindow  : THintWindow read FHintWindow;

  published
    property AutoHide  : boolean read FAutoHide write FAutoHide default true;
    property Interval  : integer read GetInterval write SetInterval;
    property Immediate : boolean read FImmediate write FImmediate;
    property BoldFont  : TFont read  FBoldFont write SetBoldFont;
    property Visible   : boolean read GetVisible write SetVisible;
    property Caption   : string read FCaption write SetCaption;
    property Version : TDCVersion read FVersion write FVersion stored false;
    property OnVisibleChanged : TNotifyEvent read FOnVisibleChanged write FOnVisibleChanged;
  end;

  TBkgndOption = (boNone, boStretch , boCenter, boTile, boHorzGradient, boVertGradient);

  TControlBackground = class(TPersistent)
  private
    FOwner              : TCustomControl;
    FBackground         : TBitmap;
    FBkgndOption        : TBkgndOption;
    FGradientBeginColor : TColor;
    FGradientEndColor   : TColor;
    FTempBackground     : TBitmap;
    procedure SetBackground(Value : TBitmap);
    procedure SetBkgndOption(Value : TBkgndOption);
    procedure SetGradientBeginColor(Value : TColor);
    procedure SetGradientEndColor(Value : TColor);
  protected
    procedure BackgroundChanged(Sender : TObject);
    function  GetPaintRect : TRect; virtual;
    function  GetPaintBrush : HBrush; virtual;
  public
    function  NeedPaint : boolean;
    procedure Assign(Source : TPersistent); override;
    constructor Create(Owner : TCustomControl);
    destructor Destroy; override;
    procedure PaintBackground; virtual;
    property Owner : TCustomControl read FOwner;
    property  TempBackground : TBitmap read FTempBackground;
  published
    property Background : TBitmap read FBackground write SetBackground;
    property BkgndOption : TBkgndOption read FBkgndOption write SetBkgndOption default boNone;
    property GradientBeginColor : TColor read FGradientBeginColor write SetGradientBeginColor default clBlue;
    property GradientEndColor : TColor read FGradientEndColor write SetGradientEndColor default clBlack;
  end;

  TLeftRightAlign = (lrLeftJustify, lrRightJustify);

function CalcStringSize(DC : HDC; Font , BoldFont : TFont ; const S : string) : TSize;
function ExtractColumn(const S : string; var Pos: Integer): string;
function GetStringExtent(DC: HDC; const S : string) : TSize;
function ExtractBoldPos(const S : string; var BoldPos , BoldLen : integer): string;
procedure DrawWithSelection(DC : HDC; Font , BoldFont : TFont ; Rect : TRect;
          const S : string; BoldPos, BoldLen : integer ; Align : TLeftRightAlign);
procedure FillGradient(DC : HDC; Width, Height : integer; StartColor, EndColor : TColor; IsVertical : boolean);

const
  SSeparatorTag = '|';
  SBoldTag : char = '~';
  SReturn = #13#10;


implementation

const
  HintSpace = 4;

type

  TDCHintWindow = class(THintWindow)
  private
    FBoldFont       : TFont;
    FDisableUpdate  : Boolean;
    FStrings        : TStrings;
    function  CalcSize(const s : string) : TSize;
    procedure DrawBorder;
  protected
    procedure Paint; override;
    procedure CreateWnd; override;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    procedure WMERASEBKGND(var Message: TMessage); message WM_ERASEBKGND;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure UpdateSize;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure ActivateHint(Rect: TRect; const AHint: string); override;
  end;



{-----------TDCHintWindow--------------------------------------}

constructor TDCHintWindow.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FBoldFont := TFont.Create;
  FStrings  := TStringList.Create;
end;

{-----------------------------------------------------------}

destructor TDCHintWindow.Destroy;
begin
  FBoldFont.Free;
  FStrings.Free;
  inherited Destroy;
end;

{-----------------------------------------------------------}

procedure TDCHintWindow.CreateWnd;
begin
  inherited CreateWnd;
  Color := Application.HintColor;
  FBoldFont.Assign(Canvas.Font);
  FBoldFont.Style := [fsBold];
end;

{-----------------------------------------------------------}

procedure TDCHintWindow.WMERASEBKGND(var Message: TMessage);
begin
  inherited;
end;

{-----------------------------------------------------------}

procedure TDCHintWindow.DrawBorder;
var
  DC :  HDC;
  R  : TRect;
begin
  DC := GetWindowDC(Handle);
  try
    R := Rect(0, 0, Width, Height);
    DrawEdge(DC, R, BDR_RAISEDOUTER, BF_RECT);
  finally
    ReleaseDC(Handle, DC);
  end;
end;

{-----------------------------------------------------------}

procedure TDCHintWindow.WMNCPaint(var Message: TMessage);
begin
  DrawBorder;
end;

{-----------------------------------------------------------}

procedure TDCHintWindow.Paint;
var
  R       : TRect;
  S       : string;
  i       : integer;
  BoldPos : integer;
  BoldLen : integer;
begin
  Canvas.Font.Color := clInfoText;

  with Canvas do
  begin

    R := ClientRect;

    inc(R.Left, 2);
    with FStrings do
      if Count <> 0 then
        for i := 0 to Count - 1 do
        begin
          S := ExtractBoldPos(Strings[i], BoldPos , BoldLen);
          DrawWithSelection(Handle, Font , FBoldFont, R, S, BoldPos, BoldLen, lrLeftJustify);
          inc(R.Top, integer(Objects[i]));
        end
      else
      begin
        S := ExtractBoldPos(Caption , BoldPos , BoldLen);
        DrawWithSelection(Handle, Font , FBoldFont, R, S, BoldPos, BoldLen, lrLeftJustify);
      end;
  end;
  DrawBorder;
end;

{-----------------------------------------------------------}

function  TDCHintWindow.CalcSize(const s : string) : TSize;
var
  P    : integer;
  i    : integer;
  R    : TRect;
  Size : TSize;

  {---------------------------------------------}

  function GetStringSize(const s : string) : TSize;
  begin
    result := CalcStringSize(Canvas.Handle, Font , FBoldFont, s);
    inc(result.cx, HintSpace * 2);
  end;

  {---------------------------------------------}

begin
  P := Pos(SReturn , s);
  FStrings.Clear;
  if P <> 0 then
  begin
    R := Rect(0, 0, 0, 0);
    DrawText(Canvas.Handle, PChar(s), Length(s), R, DT_CALCRECT);
    result.cy := R.Bottom;
    result.cx := 0;
    with FStrings do
    begin
      Text := s;
      for i := 0 to Count - 1 do
      begin
        Size := GetStringSize(Strings[i]);
        Objects[i] := Pointer(Size.cy);
        result.cx := Max(result.cx, Size.cx);
      end;
    end;
  end
  else
    result := CalcStringSize(Canvas.Handle, Font , FBoldFont, s);
end;

{-----------------------------------------------------------}

procedure TDCHintWindow.UpdateSize;
var
  Size : TSize;
begin
  if HandleAllocated then
  begin
    Size := CalcSize(Caption);
    Width := Size.cx + 4 ;
    Height := Size.cy + 4;
  end;
end;

{-----------------------------------------------------------}

procedure TDCHintWindow.CMTextChanged(var Message: TMessage);
begin
  if FDisableUpdate  then
    Exit;
  UpdateSize;
end;

{-----------------------------------------------------------}

procedure TDCHintWindow.ActivateHint(Rect: TRect; const AHint: string);
begin
  FDisableUpdate := Caption = AHint;
  try
    Caption := AHint;
    Inc(Rect.Bottom, 4);
    UpdateBoundsRect(Rect);
    if Rect.Top + Height > Screen.Height then
      Rect.Top := Screen.Height - Height;
    if Rect.Left + Width > Screen.Width then
      Rect.Left := Screen.Width - Width;
    if Rect.Left < 0 then
      Rect.Left := 0;
    if Rect.Bottom < 0 then
      Rect.Bottom := 0;

    SetWindowPos(Handle, HWND_TOPMOST, Rect.Left, Rect.Top, Width, Height,
                 SWP_SHOWWINDOW or SWP_NOACTIVATE);
//    Invalidate;
  finally
    FDisableUpdate := False;
  end;
end;


{-----------TDCHint-------------------------------------------}

constructor TDCHint.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FHintTimer := TTimer.Create(self);
  FHintTimer.Enabled  := false;
  FHintTimer.Interval := 50;
  FHintTimer.OnTimer  := OnHintTimer;
  FHintWindow := TDCHintWindow.Create(Self);
  FAutoHide := true;
  FImmediate := true;
  FBoldFont := TFont.Create;
  FBoldFont.Assign(FHintWindow.Canvas.Font);
  FBoldFont.Style := [fsBold];
  FBoldFont.OnChange := FontChanged;
end;

{-----------------------------------------------------------}

destructor TDCHint.Destroy;
begin
  FBoldFont.Free;
  inherited Destroy;
end;

{-----------------------------------------------------------}

function  TDCHint.GetInterval : integer;
begin
  result := FHintTimer.Interval;
end;

{-----------------------------------------------------------}

procedure TDCHint.SetInterval(Value : integer);
begin
  FHintTimer.Interval := Value;
end;

{-----------------------------------------------------------}

procedure TDCHint.ActivateHint(const S : string);
var
  Point : TPoint;
begin
  GetCursorPos(Point);
  ActivateHintAtPos(Point, S);
  FHintDelta := 20;//GetSystemMetrics(SM_CYCURSOR);
end;

{-----------------------------------------------------------}

function  TDCHint.GetVisible : boolean;
begin
  result := IsWindowVisible(FHintWindow.Handle);
end;

{-----------------------------------------------------------}

procedure TDCHint.SetVisible(Value : boolean);
begin
  if Value <> GetVisible then
    if Value then
      ActivateHint(FCaption)
    else
      CancelHint;
end;

{-----------------------------------------------------------}

procedure TDCHint.SetCaption(Value : string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    if Visible then
    begin
      FHintWindow.Caption := Value;
      FHintWindow.Repaint;
    end;
  end;
end;

{-----------------------------------------------------------}

procedure TDCHint.SetBoldFont(Value : TFont);
begin
  FBoldFont.Assign(Value);
  FontChanged(Self);
end;

{-----------------------------------------------------------}

procedure TDCHint.FontChanged(Sender : TObject);
begin
  TDCHintWindow(FHintWindow).FBoldFont.Assign(FBoldFont);
end;

{-----------------------------------------------------------}

procedure TDCHint.ActivateHintAtPos(const Point : TPoint; const S : string);
var
  ASize   : TSize;
begin
  if S = '' then
    CancelHint
  else
  begin
    with TDCHintWindow(FHintWindow) do
      ASize := CalcSize(S);
    with Point do
      FHintRect := Rect(X, Y, X + ASize.cx + HintSpace * 2, Y + ASize.cy);
    FHintTimer.Enabled := true;
    FHintState := hsBeginShow;
    FCaption := S;
    if Immediate then
      ExecHintTimer;
  end;
  FHintDelta := 0;
end;

{-----------------------------------------------------------}

procedure TDCHint.OnHintTimer(Sender: TObject);
begin
  ExecHintTimer;
end;

{-----------------------------------------------------------}

procedure TDCHint.VisibleChanged;
begin
  if Assigned(FOnVisibleChanged) then
    FOnVisibleChanged(Self);
end;

{-----------------------------------------------------------}

procedure TDCHint.HideHintWindow;
begin
  if IsWindowVisible(FHintWindow.Handle) then
    ShowWindow(FHintWindow.Handle, SW_HIDE);
  VisibleChanged;
end;

{-----------------------------------------------------------}

function TDCHint.IsHintInRect(R : TRect; Point : TPoint) : boolean;
begin
  with R do
    result := PtInRect(Rect(left , 2 * top - bottom  , right , bottom ), Point) ;
end;

{-----------------------------------------------------------}

procedure TDCHint.ExecHintTimer;
var
  Point     : TPoint;
  InRect    : boolean;
  ADelay    : integer;
  HintPause : integer;
begin

  ADelay := FTimerDelay * integer(FHintTimer.Interval);
  GetCursorPos(Point);
  InRect := IsHintInRect(FHintRect, Point);

  case FHintState of
    hsBeginShow :
      begin
        if fAutoHide and not InRect then
          FHintState := hsHide
        else
        begin
          if IsWindowVisible(FHintWindow.Handle) then
            HintPause := Application.HintShortPause
          else
            HintPause := Application.HintPause;
          if FImmediate  or (ADelay >= HintPause) then
          begin
            DrawHintWindow;
            FTimerDelay := 0;
            FHintState := hsShow;
          end
          else
            inc(FTimerDelay);
        end;
      end;
    hsShow :
      begin
        if (FAutoHide) and (not InRect or (ADelay > Application.HintHidePause)) then
        begin
          HideHintWindow;
          FTimerDelay := 0;
          FHintState := hsHide;
        end
        else
          inc(FTimerDelay);
      end;
    hsHide:
      begin
        HideHintWindow;
        FTimerDelay := 0;
        if not InRect then
          FHintTimer.Enabled := false;
      end;
  end;
end;
{-----------------------------------------------------------}

procedure  TDCHint.DrawHintWindow;
var
  OldVisible : boolean;
begin
  with FHintWindow, FHintRect do
  begin
    OldVisible := GetVisible;
    ActivateHint(Rect(Left , Top + FHintDelta, Right , Bottom + FHintDelta), FCaption);
    if not OldVisible then
      VisibleChanged;
  end;
end;

{-----------------------------------------------------------}

procedure TDCHint.CancelHint;
begin
  HideHintWindow;
  FTimerDelay := 0;
  FHintTimer.Enabled := false;
end;

{--------TControlBackground-------------------------------------------}

procedure TControlBackground.SetBackground(Value : TBitmap);
begin
  FBackground.Assign(Value);
end;

{------------------------------------------------------------------}

procedure TControlBackground.SetBkgndOption(Value : TBkgndOption);
begin
  if FBkgndOption <> Value then
  begin
    FBkgndOption := Value;
    BackgroundChanged(Self);
    FOwner.Invalidate;
  end;
end;

{------------------------------------------------------------------}

procedure TControlBackground.SetGradientBeginColor(Value : TColor);
begin
  if FGradientBeginColor <> Value then
  begin
    FGradientBeginColor := Value;
    BackgroundChanged(Self);
  end;
end;

{-------------------------------------------------------------}

procedure TControlBackground.SetGradientEndColor(Value : TColor);
begin
  if FGradientEndColor <> Value then
  begin
    FGradientEndColor := Value;
    BackgroundChanged(Self);
  end;
end;

{------------------------------------------------------------------}

procedure TControlBackground.BackgroundChanged(Sender : TObject);
begin
  if NeedPaint then
    PaintBackground;
end;

{------------------------------------------------------------------}

function  TControlBackground.NeedPaint : boolean;
begin
  result := not IsRectEmpty(GetPaintRect);
  if result and not (FBkgndOption in [boHorzGradient, boVertGradient]) then
    with FBackground do
      result := (FBkgndOption <> boNone) and (Width <> 0) and (Height <> 0);
end;

{------------------------------------------------------------------}

function  TControlBackground.GetPaintRect : TRect;
begin
  if FOwner.HandleAllocated then
    result := FOwner.ClientRect
  else
    result := Rect(0, 0, 0, 0);  
end;

{------------------------------------------------------------------}
type
  TMCustomControl = class(TCustomControl);

function  TControlBackground.GetPaintBrush : HBrush;
begin
  result := TMCustomControl(FOwner).Canvas.Brush.Handle;
end;

{------------------------------------------------------------------}

procedure  TControlBackground.PaintBackground;
var
  R        : TRect;
  StartX   : integer;
  Ax       : integer;
  AY       : integer;
  i        : integer;
  j        : integer;

  {--------------------------------------------------}

  function _GetSize(A, B : integer) : integer;
  begin
    result := B div A;
    if B mod A <> 0 then
      inc(result);
  end;

  {--------------------------------------------------}


begin

  if not NeedPaint then
    exit;


  with FBackground, FTempBackground.Canvas do
  begin
    R := GetPaintRect;
    StartX := R.Left;

    FTempBackground.Width  := R.Right - R.Left;
    FTempBackground.Height := R.Bottom - R.Top;


    case FBkgndOption of
      boStretch : StretchDraw(R, FBackground);
      boCenter  :
      begin
        Windows.FillRect(Handle, R, GetPaintBrush);
        Draw(R.Left + (FTempBackground.Width - StartX - Width) div 2,
        R.Top + (FTempBackground.Height - Height) div 2, FBackground);
      end;
      boTile    :
      begin
        AX := _GetSize(Width, FTempBackground.Width - StartX);
        AY := _GetSize(Height, FTempBackground.Height);
        for i := 0 to AX do
          for j := 0 to AY do
            Draw(StartX + i * Width , j * Height, FBackground);
      end;
      boHorzGradient  :
        with FTempBackground do
          FillGradient(Canvas.Handle, Width, Height, FGradientBeginColor, FGradientEndColor, false);
      boVertGradient :
        with FTempBackground do
          FillGradient(Canvas.Handle, Width, Height, FGradientBeginColor, FGradientEndColor, true);
    end;
  end;
  FOwner.Invalidate;
end;

{------------------------------------------------------------------}

constructor TControlBackground.Create(Owner : TCustomControl);
begin
  inherited Create;
  FOwner := Owner;
  FBackground := TBitmap.Create;
  FBackground.OnChange := BackgroundChanged;
  FTempBackground  := TBitmap.Create;
  FGradientBeginColor := clBlue;
  FGradientEndColor   := clBlack;

end;

{------------------------------------------------------------------}

procedure TControlBackground.Assign(Source : TPersistent);
begin
  if Source is TControlBackground then
    with TControlBackground(Source) do
    begin
      Background := Self.Background;
      BkgndOption := Self.BkgndOption;
      GradientBeginColor := Self.GradientBeginColor;
      GradientEndColor := Self.GradientEndColor;
    end
  else
    inherited Assign(Source);
end;

{------------------------------------------------------------------}

destructor TControlBackground.Destroy;
begin
  FBackground.Free;
  FTempBackground.Free;
  inherited Destroy;
end;

{------------------------------------------------------------------}

procedure DrawWithSelection(DC : HDC; Font , BoldFont : TFont ; Rect : TRect;
          const S : string; BoldPos, BoldLen : integer ; Align : TLeftRightAlign);
const
  AlignArray : array[TLeftRightAlign] of integer = (DT_LEFT, DT_RIGHT);

var
  str1    : string;
  str2    : string;
  str3    : string;

  size    : TSize;
  OldFont : THandle;
  Style   : integer;

  {-------------------------------------------------------}

  procedure  DrawSubString(const S : string);
  begin
    if s <> '' then
    begin
      DrawText(DC , pchar(s), length(s) , Rect,  Style);
      GetTextExtentPoint(DC, PChar(s), length(s) , size);
      if Align = lrLeftJustify then
        inc(Rect.Left, size.cx)
      else
        dec(Rect.Right, size.cx)
    end;
  end;

  {-------------------------------------------------------}

  procedure DrawSubStrings(const s1, s2, s3 : string);
  begin
    OldFont := SelectObject(DC, Font.Handle);
    DrawSubString(s1);
    if s2 <> '' then
    begin
      SelectObject(DC, BoldFont.Handle);
      DrawSubString(s2);
      SelectObject(DC, Font.Handle);
    end;
    DrawSubString(s3);
    SelectObject(DC, OldFont);
  end;

  {-------------------------------------------------------}

begin
  if (BoldPos > 0)  then
  begin
    str1  := copy(S, 1, BoldPos - 1 );
    str2 := copy(S, BoldPos , BoldLen);
    str3 := copy(S, BoldPos +  BoldLen ,length(s) - BoldPos - BoldLen + 1);
  end
  else
  begin
    str1 := s;
    str2 := '';
    str3 := '';
  end;

  Style := AlignArray[Align];
  if Align = lrLeftJustify then
    DrawSubStrings(str1, str2, str3)
  else
    DrawSubStrings(str3, str2, str1);
end;

{------------------------------------------------------------------}

function CalcStringSize(DC : HDC; Font , BoldFont : TFont ; const S : string) : TSize;
var
  OldFont : THandle;
  BoldPos : integer;
  BoldEnd : integer;
  str     : string;
  Size    : TSize;
begin
  OldFont := SelectObject(DC, Font.Handle);
  BoldPos := Pos(SBoldTag, S);
  if (BoldPos > 0)  then
    str  := copy(S, 1, BoldPos - 1 )
  else
    str := s;
  result := GetStringExtent(DC, str);
  if BoldPos > 0  then
  begin
    inc(BoldPos, Length(SBoldTag));

    BoldEnd := PosEx(SBoldTag, S, BoldPos);
    if BoldEnd = 0 then
      BoldEnd := Length(S) + 1;

    SelectObject(DC, BoldFont.Handle);
    str := copy(S, BoldPos , BoldEnd - BoldPos);
    Size := GetStringExtent(DC, str);
    inc(result.cx, Size.cx);
    result.cy := Max(result.cy, Size.cy);
    SelectObject(DC, Font.Handle);
    inc(BoldEnd, Length(SBoldTag));
    str := copy(S, BoldEnd,length(s) - BoldEnd + 1);
    Size := GetStringExtent(DC, str);
    inc(result.cx, Size.cx);
    result.cy := Max(result.cy, Size.cy);
  end;
  SelectObject(DC, OldFont);
end;

{------------------------------------------------------------------}

function ExtractBoldPos(const S : string; var BoldPos , BoldLen : integer): string;
begin
  result := s;
  BoldPos := Pos(SBoldTag,S);
  if BoldPos <> 0 then
  begin
     delete(result, BoldPos, Length(SBoldTag));
     BoldLen := Pos(SBoldTag,result);
     if BoldLen <> 0 then
     begin
       delete(result, BoldLen, Length(SBoldTag));
       BoldLen := BoldLen - BoldPos;
     end
     else
       BoldLen := length(result) - BoldPos + 1;
  end
    else
      BoldLen := 0;
end;

{------------------------------------------------------------------}

function ExtractColumn(const S : string; var Pos: Integer): string;
var
  i : integer;
begin
  i := Pos;
  while (i <= Length(S)) and (S[i] <> SSeparatorTag) do
    inc(i);
  result := Copy(S, pos, i - Pos);
  if (i <= Length(S)) and (s[i] = SSeparatorTag) then
    inc(i);
  Pos := i;
end;

{------------------------------------------------------------------}

function GetStringExtent(DC: HDC; const S : string) : TSize;
begin
  if s = '' then
  begin
    result.cx := 0;
    result.cy := 0;
  end
  else
    GetTextExtentPoint(DC, PChar(s), length(s) , result);
end;

{-----------------------------------------------------------}

function MaxValue(Value1, Value2, Value3 : integer) : integer;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;

  if Value3 > Result then
    Result := Value3;
end;

{------------------------------------------------------------------}

procedure FillGradient(DC : HDC; Width, Height : integer; StartColor, EndColor : TColor; IsVertical : boolean);
var
  i          : integer;
  LenRed     : integer;
  LenGreen   : integer;
  LenBlue    : integer;
  StartRed   : Byte;
  StartGreen : Byte;
  StartBlue  : Byte;
  MaxLen     : integer;
  Step       : integer;
  ARect      : TRect;
  StepRed    : integer;
  StepGreen  : integer;
  StepBlue   : integer;
  StartRGB   : integer;
  EndRGB     : integer;
  Brush      : HBrush;
  R          : integer;
begin
  if not ((width > 0) and (height > 0)) then
    exit;

  StartRGB := ColorToRgb(StartColor);
  EndRGB := ColorToRgb(EndColor);

  StartRed := GetRValue(StartRGB);
  StartGreen := GetGValue(StartRGB);
  StartBlue := GetBValue(StartRGB);

  LenRed := GetRValue(EndRGB)- StartRed;
  LenGreen := GetGValue(EndRGB) - StartGreen;
  LenBlue := GetBValue(EndRGB) - StartBlue;
  MaxLen := MaxValue(Abs(LenRed), Abs(LenGreen), Abs(LenBlue)) + 1;
  if MaxLen = 0 then
    exit;
  if IsVertical then
  begin
    Step := Height div MaxLen  + 1;
    ARect := Rect(0, 0, Width, Step);
  end
  else
  begin
    Step := Width div MaxLen + 1;
    ARect := Rect(0, 0, Step, Height);
  end;
  StepRed := Step * LenRed;
  StepGreen := Step * LenGreen;
  StepBlue := Step * LenBlue;
  if IsVertical then
    R := Height
  else
    R := Width;
  for i := 0 to MaxLen - 1 do
  begin
    Brush := CreateSolidBrush(RGB(Round(StartRed  + (i * StepRed) div R),
                                  Round(StartGreen + (i * StepGreen) div R),
                                  Round(StartBlue + (i * StepBlue)  div R)));
    FillRect(DC, ARect, Brush);
    DeleteObject(Brush);

    with ARect do
      if IsVertical then
      begin
        inc(Top, Step);
        if Top > Height then
          break;
        inc(Bottom, Step);
      end
      else
      begin
        inc(Left, Step);
        if Left > Width then
          break;
        inc(Right, Step);
      end;

  end;

end;


end.
