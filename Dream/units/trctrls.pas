{**************************************************}
{                                                  }
{  Transparent Controls                            }
{                                                  }
{  Copyright (c) 1997-2000 Dream Company           }
{  http://www.dream-com.com                        }
{  e-mail: contact@dream-com.com                   }
{                                                  }
{**************************************************}

Unit TrCtrls;

Interface
{$I dc.inc}
Uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

Const
  WM_UPDTRANS = WM_USER + 2; {this message is called by hook procedure when
                                 transparent control should be updated  }

Type

  TWinControlClass = class of TWinControl;

  TTransObject = Class(TObject)
  Private
    FControl: TWinControl;
    FTransparent: Boolean;
    FBackChanged: Boolean;
    ftempdc: THandle;
    ftempbitmap: THandle;
    foldbitmap: THandle;
    Procedure KillTempDC;
    Procedure SetTransparent(V: Boolean);
    Procedure InternalPaint;
    Procedure SaveBackGround;
    Procedure WMUPDATETRANS;
    Procedure WMMove;
  Protected
    Property Transparent: Boolean Read FTransparent Write SetTransparent Default True;
  Public
    Constructor Create(AControl: TWinControl);
    Destructor Destroy; override;
  End;



  TTrRadioButton = Class(TRadioButton)
  Private
    FObject: TTransObject;
    Function GetTransparent: Boolean;
    Procedure SetTransparent(V: Boolean);
  Protected
    Procedure WMUPDATETRANS(Var Msg: TMessage); message WM_UPDTRANS;
    Procedure BMSETCHECK(Var Msg: TMessage); message BM_SETCHECK;
    Procedure WMLBUTTONUP(Var Msg: TMessage); message WM_LBUTTONUP;
    Procedure WMMove(Var Msg: TMessage); message WM_MOVE;
    Procedure WMSize(Var Msg: TMessage); message WM_SIZE;
    Procedure WMPAINT(Var Msg: TWMPaint); message WM_PAINT;
    Procedure WMEraseBkgnd(Var Msg: TWMEraseBkgnd); message WM_EraseBkgnd;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  Published
    Property Transparent: Boolean Read GetTransparent Write SetTransparent;
  End;

  TCustomTrCheckBox = Class(TCustomCheckBox)
  Private
    FObject : TTransObject;
    Function GetTransparent: Boolean;
    Procedure SetTransparent(V: Boolean);
  Protected
    Procedure WMUPDATETRANS(Var Msg: TMessage); message WM_UPDTRANS;
    Procedure WMMove(Var Msg: TMessage); message WM_MOVE;
    Procedure WMSize(Var Msg: TMessage); message WM_SIZE;
    Procedure WMPAINT(Var Msg: TWMPaint); message WM_PAINT;
    Procedure WMEraseBkgnd(Var Msg: TWMEraseBkgnd); message WM_EraseBkgnd;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  Published
    Property Transparent: Boolean Read GetTransparent Write SetTransparent;
  End;

  TCustomTrGroupBox = Class(TCustomGroupBox)
  Private
    FObject : TTransObject;
  Protected
    Procedure WMUPDATETRANS(Var Msg: TMessage); message WM_UPDTRANS;
    Procedure WMMove(Var Msg: TMessage); message WM_MOVE;
    Procedure WMSize(Var Msg: TMessage); message WM_SIZE;
    Procedure WMPAINT(Var Msg: TWMPaint); message WM_PAINT;
    Procedure WMEraseBkgnd(Var Msg: TWMEraseBkgnd); message WM_EraseBkgnd;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  Published
  End;

  TTrGroupBox = Class(TCustomTrGroupBox)
  Published
    Property Align;
    Property Caption;
    Property Color;
    Property Ctl3D;
    Property DragCursor;
    Property DragMode;
    Property Enabled;
    Property Font;
    Property ParentColor;
    Property ParentCtl3D;
    Property ParentFont;
    Property ParentShowHint;
    Property PopupMenu;
    Property ShowHint;
    Property TabOrder;
    Property TabStop;
    Property Visible;
    Property OnClick;
    Property OnDblClick;
    Property OnDragDrop;
    Property OnDragOver;
    Property OnEndDrag;
    Property OnEnter;
    Property OnExit;
    Property OnMouseDown;
    Property OnMouseMove;
    Property OnMouseUp;
    Property OnStartDrag;
  End;

{---------------------------------------------------------}

  TTrCheckBox = Class(TCustomTrCheckBox)
  Published
    Property Transparent;
    Property Alignment;
    Property AllowGrayed;
    Property Caption;
    Property Checked;
    Property Color;
    Property Ctl3D;
    Property DragCursor;
    Property DragMode;
    Property Enabled;
    Property Font;
    Property ParentColor;
    Property ParentCtl3D;
    Property ParentFont;
    Property ParentShowHint;
    Property PopupMenu;
    Property ShowHint;
    Property State;
    Property TabOrder;
    Property TabStop;
    Property Visible;
    Property OnClick;
    Property OnDragDrop;
    Property OnDragOver;
    Property OnEndDrag;
    Property OnEnter;
    Property OnExit;
    Property OnKeyDown;
    Property OnKeyPress;
    Property OnKeyUp;
    Property OnMouseDown;
    Property OnMouseMove;
    Property OnMouseUp;
    Property OnStartDrag;
  End;

  TCustomTrRadioGroup = Class(TCustomTrGroupBox)
  Private
    FButtons: TList;
    FItems: TStrings;
    FItemIndex: Integer;
    FColumns: Integer;
    FReading: Boolean;
    FUpdating: Boolean;
    Procedure ArrangeButtons;
    Procedure ButtonClick(Sender: TObject);
    Procedure ItemsChange(Sender: TObject);
    Procedure SetButtonCount(Value: Integer);
    Procedure SetColumns(Value: Integer);
    Procedure SetItemIndex(Value: Integer);
    Procedure SetItems(Value: TStrings);
    Procedure UpdateButtons;
    Procedure CMEnabledChanged(Var Message: TMessage); message CM_ENABLEDCHANGED;
    Procedure CMFontChanged(Var Message: TMessage); message CM_FONTCHANGED;
    Procedure WMSize(Var Message: TWMSize); message WM_SIZE;
    Procedure WMPaint(Var Message: TWMSize); message WM_paint;
    Procedure WMUPDATETRANS(Var Msg: TMessage); message WM_UPDTRANS;
  Protected
    Procedure ReadState(Reader: TReader); override;
    Function CanModify: Boolean; virtual;
{$IFDEF D3}
    Procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
{$ELSE}
    Procedure GetChildren(Proc: TGetChildProc); override;
{$ENDIF}
    Property Columns: Integer read FColumns write SetColumns default 1;
    Property ItemIndex: Integer read FItemIndex write SetItemIndex default - 1;
    Property Items: TStrings read FItems write SetItems;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  End;

  TTrRadioGroup = Class(TCustomTrRadioGroup)
  Published
    Property Align;
    Property Caption;
    Property Color;
    Property Columns;
    Property Ctl3D;
    Property DragCursor;
    Property DragMode;
    Property Enabled;
    Property Font;
    Property ItemIndex;
    Property Items;
    Property ParentColor;
    Property ParentCtl3D;
    Property ParentFont;
    Property ParentShowHint;
    Property PopupMenu;
    Property ShowHint;
    Property TabOrder;
    Property TabStop;
    Property Visible;
    Property OnClick;
    Property OnDragDrop;
    Property OnDragOver;
    Property OnEndDrag;
    Property OnEnter;
    Property OnExit;
    Property OnStartDrag;
  End;

{---------------------------------------------------------}

Const
  DDF_HALFTONE = $1000;

Procedure ControlTransPaintEX(W: TWinControl; BackDC: THandle; Var FTransparent: Boolean; X, Y: Integer);
Procedure ControlTransPaint(W: TWinControl; BackDC: THandle; Var FTransparent: Boolean);
Procedure AddHook(o: TWinControl);
Procedure RemoveHook(o: TWinControl);
Procedure SaveBackground(A: TWinControl;
            Var FTempDC, FTempBitmap, FOldBitmap: THandle);
Procedure RegisterTransControl(W: TWinControlClass);
Function IsTransControl(W: TWinControl): Boolean;

procedure Register;

{---------------------------------------------------------}
Implementation

Const
  FDrawing  : Integer = 0;
  SPalDream : string = 'Dream Company';  //don't resource
{-------------------------------------------------------------}

function RectHeight(const R:TRect):Integer;
begin
  With R do
    Result := bottom - top;
end;

{-------------------------------------------------------------}

function RectWidth(const R:TRect):Integer;
begin
  With R do
    Result := right - left;
end;

{-------------------------------------------------------------}

Procedure TransparentBitBltEx(sourcedc, destdc: THandle; SrcRect,DstRect: TRect;
    atranscolor: longint);
Var
  monobitmap: THandle;
  oldbkcolor: longint;
  monodc: THandle;
  width: integer;
  height: integer;
  oldbitmap: THandle;
Begin
  With SrcRect do
  Begin
    width := right - left;
    height := bottom - top;
    monodc := CreateCompatibleDC(sourcedc);
    monobitmap := CreateCompatibleBitmap(monodc, width, height);
    oldbitmap := SelectObject(monodc, monobitmap);
    Try
      oldbkcolor := SetBkColor(sourcedc, atranscolor);
      BitBlt(monodc, 0, 0, width, height, sourcedc, 0, 0, SRCCOPY);
      SetBkColor(sourcedc, oldbkcolor);
      TransparentStretchBlt(destdc, DstRect.Left, DstRect.Top, RectWidth(DstRect),
        RectHeight(DstRect),
        SourceDC, left, top, width, height, monodc, 0, 0);
    Finally
      SelectObject(monodc, oldbitmap);
      DeleteDC(monodc);
      DeleteObject(monobitmap);
    End;
  End;
End;

{-------------------------------------------------------------}

Function GetTransparentColor(dc: THandle; const arect: TRect): longint;
Begin
  result := GetPixel(dc, arect.left, arect.bottom);
End;

{-------------------------------------------------------------}

Procedure TransparentBitBlt(sourcedc, destdc: THandle; arect: TRect;
    atranscolor: longint; aoriginX,aoriginY: Integer);
begin
  TransparentBitBltEx(sourcedc, destdc,arect,
    Rect(aoriginX,aoriginY,aoriginX+RectWidth(arect),aoriginY+RectHeight(arect)),
    atranscolor);
end;

{-------------------------------------------------------------}

Procedure TTrRadioButton.BMSETCHECK(Var Msg: TMessage);
Begin
  Inherited;
  Invalidate;
End;

{-------------------------------------------------------------}

Procedure TTrRadioButton.WMLBUTTONUP(Var Msg: TMessage);
Begin
  Inherited;
  Invalidate;
End;

Procedure TCustomTrRadioGroup.WMUPDATETRANS(Var Msg: TMessage);
Var
  i: integer;
Begin
  Inherited;
  For i := 0 to FButtons.Count - 1 do
  Begin
    TWInControl(FButtons[i]).Invalidate;
  End;
End;

{-------------------------------------------------------------}

Procedure TCustomTrRadioGroup.WMPaint(Var Message: TWMSize);
Var
  i: integer;
Begin
  Inherited;
  For i := 0 to FButtons.Count - 1 do
  Begin
    TWInControl(FButtons[i]).Invalidate;
  End;
End;

{--------------------------------------------}

Function GetParentDC(P: TWInControl): THandle;
Begin
  Result := 0;
  If P is TTrGroupBox then
    Result := TTrGroupBox(P).FObject.FTempDC else
    If P is TTrRadioGroup then
      Result := TTrRadioGroup(P).FObject.FTempDC;
End;

{-------------------------------------------------------------}

Procedure TTransObject.WMUPDATETRANS;
Begin
  If FTransparent then
  Begin
    fbackchanged := true;
    InternalPaint;
  End;
End;

{-------------------------------------------------------------}

Constructor TTransObject.Create(AControl: TWinControl);
Begin
  Inherited Create;
  FControl := AControl;
  FTransparent := True;
  fBackChanged := true;
  AddHook(AControl);
End;

{--------------------------------------------}

Procedure TTransObject.WMMove;
Begin
  If FTransparent then
  Begin
    FBackChanged := true;
    InternalPaint;
  End;
End;

{------------------------------------------------------------------}

Procedure TTransObject.KillTempDC;
Begin
  If FTempdc <> 0 then
  Begin
    SelectObject(ftempdc, foldbitmap);
    DeleteObject(ftempbitmap);
    DeleteDC(ftempdc);
    ftempdc := 0;
  End;
End;

{--------------------------------------------}

Procedure TTransObject.SaveBackGround;
Begin
  FBackChanged := false;
  Inc(FDrawing);
  TrCtrls.SaveBackground(FControl, FTempDC, FTempBitmap, FOldBitmap);
  Dec(FDrawing);
End;

{--------------------------------------------}

Procedure TTransObject.InternalPaint;
Var
  mParent: TWinControl;
  p: TPoint;
Begin
  If (Not FTransparent) or (FDrawing > 0) then exit;
  mParent := FControl.Parent;
  While (MParent <> Nil) and (IsTransControl(mParent.Parent))
    Do
    MParent := MParent.Parent;

  If (MParent <> Nil) and (isTransControl(mParent)) then
  Begin
    P.X := 0;
    P.Y := 0;
    P := FControl.ClientToScreen(P);
    P := mparent.ScreenToClient(P);
    ControlTransPaintEX(FControl, GetParentDC(mParent), FTransparent, P.X, P.Y);
  End else
  Begin
    If fBackChanged then
      SaveBackGround;
    ControlTransPaint(FCOntrol, FTempDC, FTransparent);
  End;
End;


{-------------------------------------------------------------}

Destructor TTransObject.Destroy;
Begin
  RemoveHook(FControl);
  KillTempDC;
  Inherited;
End;

{-------------------------------------------------------------}

Procedure TTransObject.SetTransparent(V: Boolean);
Begin
  If V <> FTransparent then
  Begin
    If FTransparent then RemoveHook(FControl);
    FTransparent := V;
    FBackChanged := True;
    FControl.Invalidate;
    InternalPaint;
    If FTransparent then AddHook(FControl);
  End;
End;

{--------------------------------------------}

Procedure TTrRadioButton.WMPAINT(Var Msg: TWMPaint);
Var
  ps: TPaintStruct;
  R: TRect;
Begin
  With FObject do
  Begin
    If FDrawing > 0 then exit;
    If not FTransparent then
      Inherited
    Else
    Begin
      GetUpdateRect(FControl.Handle, R, False);
      If IsRectEmpty(R) then
        exit;
      BeginPaint(FControl.handle, ps);
      Msg.result := 0;
      InternalPaint;
      EndPaint(FControl.handle, ps);
    End;
  End;
End;

{--------------------------------------------}

Procedure TtrRadioButton.WMEraseBkgnd(Var Msg: TWMEraseBkgnd);
Begin
  If FObject.FTransparent then
    Msg.Result := 1
  Else
    Inherited;
End;

{-------------------------------------------------------------}

Function TTrRadioButton.GetTransparent: Boolean;
Begin
  Result := FObject.Transparent;
End;

{-------------------------------------------------------------}

Procedure TTrRadioButton.SetTransparent(V: Boolean);
Begin
  FObject.Transparent := V;
End;

{-------------------------------------------------------------}

Constructor TTrRadioButton.Create(AOwner: TComponent);
Begin
  Inherited;
  FObject := TTransObject.Create(Self);
  ControlStyle := ControlStyle - [csopaque];
End;

{-------------------------------------------------------------}

Destructor TTrRadioButton.Destroy;
Begin
  FObject.Free;
  Inherited;
End;

{-------------------------------------------------------------}

Procedure TTrRadioButton.WMUPDATETRANS(Var Msg: TMessage);
Begin
  FObject.WMUPDATETRANS;
End;

{------------------------------------------------------------------}

Procedure TTrRadioButton.WMMove(Var Msg: TMessage);
Begin
  Inherited;
  FObject.WMMOVE;
End;
{-----------------------------------------------------------------}

Procedure TTrRadioButton.WMSize(Var Msg: TMessage);
Begin
  With FObject do
    If FTransparent then
    Begin
      KillTempDC;
      Inherited;
      WMMOVE;
    End else
      Inherited;
End;

{-------------------------------------------------------------}

Function TCustomTrCheckBox.GetTransparent: Boolean;
Begin
  Result := FObject.Transparent;
End;

{-------------------------------------------------------------}

Procedure TCustomTrCheckBox.SetTransparent(V: Boolean);
Begin
  FObject.Transparent := V;
End;

{-------------------------------------------------------------}

Constructor TCustomTrCheckBox.Create(AOwner: TComponent);
Begin
  Inherited;
  FObject := TTransObject.Create(Self);
  ControlStyle := ControlStyle - [csopaque];
End;

{-------------------------------------------------------------}

Destructor TCustomTrCheckBox.Destroy;
Begin
  FObject.Free;
  Inherited;
End;

{-------------------------------------------------------------}

Procedure TCustomTrCheckBox.WMUPDATETRANS(Var Msg: TMessage);
Begin
  FObject.WMUPDATETRANS;
End;

{--------------------------------------------}

Procedure TCustomTrCheckBox.WMPAINT(Var Msg: TWMPaint);
Var
  ps: TPaintStruct;
  R: TRect;
Begin
  With FObject do
  Begin
    If FDrawing > 0 then exit;
    If not FTransparent then
      Inherited
    Else
    Begin
      GetUpdateRect(FControl.Handle, R, False);
      If IsRectEmpty(R) then
        exit;
      BeginPaint(FControl.handle, ps);
      Msg.result := 0;
      InternalPaint;
      EndPaint(FControl.handle, ps);
    End;
  End;
End;

{--------------------------------------------}

Procedure TCustomTrCheckBox.WMEraseBkgnd(Var Msg: TWMEraseBkgnd);
Begin
  If FObject.FTransparent then
    Msg.Result := 1
  Else
    Inherited;
End;

{------------------------------------------------------------------}

Procedure TCustomTrCheckBox.WMMove(Var Msg: TMessage);
Begin
  FObject.WMMOVE;
  Inherited;
End;
{-----------------------------------------------------------------}

Procedure TCustomTrCheckBox.WMSize(Var Msg: TMessage);
Begin
  With FObject do
    If FTransparent then
    Begin
      KillTempDC;
      Inherited;
      WMMOVE;
    End else
      Inherited;
End;

{-------------------------------------------------------------}

Constructor TCustomTrGroupBox.Create(AOwner: TComponent);
Begin
  Inherited;
  FObject := TTransObject.Create(Self);
  ControlStyle := ControlStyle - [csopaque];
End;

{-------------------------------------------------------------}

Destructor TCustomTrGroupBox.Destroy;
Begin
  FObject.Free;
  Inherited;
End;

{-------------------------------------------------------------}

Procedure TCustomTrGroupBox.WMUPDATETRANS(Var Msg: TMessage);
Begin
  FObject.WMUPDATETRANS;
End;

{--------------------------------------------}

Procedure TCustomTrGroupBox.WMPAINT(Var Msg: TWMPaint);
Var
  ps: TPaintStruct;
  R: TRect;
Begin
  With FObject do
  Begin
    If FDrawing > 0 then exit;
    If not FTransparent then
      Inherited
    Else
    Begin
      GetUpdateRect(FControl.Handle, R, False);
      If IsRectEmpty(R) then
        exit;
      BeginPaint(FControl.handle, ps);
      Msg.result := 0;
      InternalPaint;
      EndPaint(FControl.handle, ps);
    End;
  End;
End;

{--------------------------------------------}

Procedure TCustomTrGroupBox.WMEraseBkgnd(Var Msg: TWMEraseBkgnd);
Begin
  If FObject.FTransparent then
    Msg.Result := 1
  Else
    Inherited;
End;

{------------------------------------------------------------------}

Procedure TCustomTrGroupBox.WMMove(Var Msg: TMessage);
Var
  i: integer;
Begin
  FObject.WMMOVE;
  Inherited;
  For i := 0 to ComponentCount - 1 do
    If (Components[i] is TWinControl) and
      (IsTransControl(TWinControl(Components[i]))) then
      PostMessage(TWinControl(Components[i]).Handle, WM_UPDTRANS, 0, 0);
End;

{-----------------------------------------------------------------}

Procedure TCustomTrGroupBox.WMSize(Var Msg: TMessage);
Begin
  With FObject do
    If FTransparent then
    Begin
      KillTempDC;
      Inherited;
      WMMOVE;
    End else
      Inherited;
End;

{-----------------------------------------------------------------------}

Var
  TransClasses: TList;

{-----------------------------------------------------------------------}

Function IsTransControl(W: TWinControl): Boolean;
Var
  i: Integer;
Begin
  Result := True;
  For i := 0 to TransClasses.Count - 1 do
    If W is TWinControlClass(TransClasses.Items[i]) then
    Begin
      exit;
    End;
  Result := False;
End;

{-----------------------------------------------------------------------}

Procedure RegisterTransControl(W: TWinControlClass);
Begin
  TransClasses.Add(W);
End;

{-----------------------------------------------------------------------}

Var
  WHook: HHook;
  hooks: TList;

Type TCWPStruct = Packed record
    lParam: LPARAM;
    wParam: WPARAM;
    message: integer;
    wnd: HWND;
  End;

Function CallWndProcHook(nCode: integer; wParam: Longint; Var Msg: TCWPStruct): longint; stdcall;
Var
  i: integer;
  r: TRect;
  r2: TRect;
  c: TWinControl;


  Function IsPaintMsg: boolean;
  Begin
    With TWinControl(hooks[i]) do
    Begin
      result := false;
      If not HandleAllocated then exit;
      If C = Owner then
      Begin
        If (msg.message = WM_MOVE) then exit;
        Result := True;
        exit;
      End;
      If C.Owner = Owner then
      Begin
        GetWindowRect(msg.wnd, r);
        GetWindowRect(handle, r2);
        result := IntersectRect(r, r, r2);
      End;
    End;
  End;

Begin
  Result := CallNextHookEx(WHook, nCode, wParam, Longint(@Msg));
  If ((msg.message > CN_BASE) and (msg.message < CN_BASE + 500)) or
    (msg.message = WM_PAINT) or (msg.message = WM_SIZE)
    Or (msg.message = WM_MOVE)
    Then
  Begin
    c := FindControl(msg.wnd);
    If (c = Nil) or (IsTransControl(c)) then exit;
    For i := 0 to hooks.Count - 1 do
    Begin
      If (IsPaintMsg) then
        SendMessage(TWinControl(hooks[i]).Handle, WM_UPDTRANS, 0, 0);
    End;
  End;
End;

{------------------------------------------------------------------}

Procedure AddHook(o: TWinControl);
Var
  i: integer;
Begin
  If hooks.Count = 0 then
    WHook := SetWindowsHookEx(WH_CALLWNDPROC, @CallWndProcHook, 0, GetCurrentThreadId);
  For i := 0 to Hooks.Count - 1 do
    If Hooks.Items[i] = o then exit;
  hooks.Add(o);
End;

{------------------------------------------------------------------}

Procedure RemoveHook(o: TWinControl);
Begin
  hooks.Remove(o);
  If hooks.Count = 0 then
    UnHookWindowsHookEx(WHook);
End;

{--------------------------------------------}

Procedure ControlTransPaint(W: TWinControl; BackDC: THandle; Var FTransparent: Boolean);
Begin
  ControlTransPaintEX(W, BackDC, FTransparent, 0, 0);
End;

{-------------------------------------------------------------}

Procedure ControlTransPaintEX(W: TWinControl; BackDC: THandle; Var FTransparent: Boolean; X, Y: Integer);
Var
  DC: THandle;
  memdc: THandle;
  formdc: THandle;
  fbitmap: THandle;
  oldfobject: THandle;
  bitmap: THandle;
  oldmemobject: THandle;
Begin
  With W do
  Begin
    If ([csReading, csLoading] * ComponentState <> []) or (Parent = Nil)
      Or ([csReading, csLoading] * Parent.ComponentState <> [])
      Or (Not HandleAllocated) or (Not (visible)) then
      exit;

    dc := GetDC(handle);
    memdc := CreateCompatibleDC(dc);
    formdc := CreateCompatibleDC(dc);

    fbitmap := CreateCompatibleBitmap(dc, width, height);
    oldfobject := SelectObject(formdc, fbitmap);
    bitmap := CreateCompatibleBitmap(dc, width, height);
    oldmemobject := SelectObject(memdc, bitmap);

    BitBlt(formdc, 0, 0, width, height, BackDC, x, y, SRCCOPY); {1}

    FTransparent := False;
    PaintTo(MemDC, 0, 0); {2}
    FTransparent := True;

    TransparentBitBlt(MemDC, FormDC, Rect(0, 0, width, height),
      GetTransparentColor(MemDC, Rect(0, 0, width - 1, height - 1)),0, 0); {3}

    BitBlt(dc, 0, 0, width, height, formDC, 0, 0, SRCCOPY); {4}

    SelectObject(formdc, oldfobject);
    DeleteObject(fbitmap);
    SelectObject(memdc, oldmemobject);
    DeleteObject(bitmap);

    ReleaseDC(handle, dc);
    DeleteDC(memdc);
    DeleteDC(formdc);
  End;
End;

{-----------------------------------------------------------------------}

Procedure SaveBackground(A: TWinControl; Var FTempDC, FTempBitmap, FOldBitmap: THandle);
Var
  dc: THandle;
  formdc: THandle;
  oldfbitmap: THandle;
  fbitmap: THandle;
  fdc: THandle;
Begin
  With A do
  Begin

    If Parent = Nil then
      exit;

    dc := GetDC(handle);
    fdc := GetDC(parent.handle);
    formdc := CreateCompatibleDC(fdc);
    fbitmap := CreateCompatibleBitmap(fdc, parent.width, parent.height);
    oldfbitmap := SelectObject(formdc, fbitmap);

    If ftempdc = 0 then
    Begin
      ftempdc := CreateCompatibleDC(dc);
      ftempbitmap := CreateCompatibleBitmap(dc, width, height);
      foldbitmap := SelectObject(ftempdc, ftempbitmap);
    End;
    IntersectClipRect(formdc, left, top, left + width + 1, top + height + 1);
    parent.PaintTo(formdc, 0, 0);
    BitBlt(ftempdc, 0, 0, width, height, formdc, left + 1, top + 1, SRCCOPY);
    SelectObject(formdc, oldfbitmap);
    DeleteObject(fbitmap);
    DeleteDC(formdc);
    ReleaseDC(Parent.Handle, fdc);
    ReleaseDC(handle, dc);
  End;
End;

{-----------------------------------------------------------------------}

{ TTrGroupButton }

Type
  TTrGroupButton = Class(TTrRadioButton)
  Private
    FInClick: Boolean;
    Procedure CNCommand(Var Message: TWMCommand); message CN_COMMAND;
  Protected
    Procedure ChangeScale(M, D: Integer); override;
    Procedure KeyDown(Var Key: Word; Shift: TShiftState); override;
    Procedure KeyPress(Var Key: Char); override;
  Public
    Constructor InternalCreate(RadioGroup: TCustomTrRadioGroup);
    Destructor Destroy; override;
  End;

{-----------------------------------------------------------------------}

Constructor TTrGroupButton.InternalCreate(RadioGroup: TCustomTrRadioGroup);
Begin
  Inherited Create(RadioGroup);
  RadioGroup.FButtons.Add(Self);
  Visible := False;
  Enabled := RadioGroup.Enabled;
  ParentShowHint := False;
  OnClick := RadioGroup.ButtonClick;
  Parent := RadioGroup;
  RemoveHook(Self);
End;

{-----------------------------------------------------------------------}

Destructor TTrGroupButton.Destroy;
Begin
  TCustomTrRadioGroup(Owner).FButtons.Remove(Self);
  Inherited Destroy;
End;

{-----------------------------------------------------------------------}

Procedure TTrGroupButton.CNCommand(Var Message: TWMCommand);
Begin
  If not FInClick then
  Begin
    FInClick := True;
    Try
      If ((Message.NotifyCode = BN_CLICKED) or
        (Message.NotifyCode = BN_DOUBLECLICKED)) and
          TCustomTrRadioGroup(Parent).CanModify then
        Inherited;
    Except
      Application.HandleException(Self);
    End;
    FInClick := False;
  End;
End;

{-----------------------------------------------------------------------}

Procedure TTrGroupButton.ChangeScale(M, D: Integer);
Begin
End;

{-----------------------------------------------------------------------}

Procedure TTrGroupButton.KeyPress(Var Key: Char);
Begin
  Inherited KeyPress(Key);
  TCustomTrRadioGroup(Parent).KeyPress(Key);
  If (Key = #8) or (Key = ' ') then
  Begin
    If not TCustomTrRadioGroup(Parent).CanModify then Key := #0;
  End;
End;

{-----------------------------------------------------------------------}

Procedure TTrGroupButton.KeyDown(Var Key: Word; Shift: TShiftState);
Begin
  Inherited KeyDown(Key, Shift);
  TCustomTrRadioGroup(Parent).KeyDown(Key, Shift);
End;


{-----------------------------------------------------------------------}

{ TCustomTrRadioGroup }

Constructor TCustomTrRadioGroup.Create(AOwner: TComponent);
Begin
  Inherited Create(AOwner);
  ControlStyle := [csSetCaption, csDoubleClicks];
  FButtons := TList.Create;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := ItemsChange;
  FItemIndex := -1;
  FColumns := 1;
End;

{-----------------------------------------------------------------------}

Destructor TCustomTrRadioGroup.Destroy;
Begin
  SetButtonCount(0);
  TStringList(FItems).OnChange := Nil;
  FItems.Free;
  FButtons.Free;
  Inherited Destroy;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.ArrangeButtons;
Var
  ButtonsPerCol, ButtonWidth, ButtonHeight, TopMargin, I: Integer;
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
  DeferHandle: THandle;
Begin
  If (FButtons.Count <> 0) and not FReading then
  Begin
    DC := GetDC(0);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    ButtonsPerCol := (FButtons.Count + FColumns - 1) div FColumns;
    ButtonWidth := (Width - 10) div FColumns;
    I := Height - Metrics.tmHeight - 5;
    ButtonHeight := I div ButtonsPerCol;
    TopMargin := Metrics.tmHeight + 1 + (I mod ButtonsPerCol) div 2;
    DeferHandle := BeginDeferWindowPos(FButtons.Count);
    For I := 0 to FButtons.Count - 1 do
      With TTrGroupButton(FButtons[I]) do
      Begin
        DeferHandle := DeferWindowPos(DeferHandle, Handle, 0,
          (I div ButtonsPerCol) * ButtonWidth + 8,
          (I mod ButtonsPerCol) * ButtonHeight + TopMargin,
          ButtonWidth, ButtonHeight,
          SWP_NOZORDER or SWP_NOACTIVATE);
        Visible := True;
      End;
    EndDeferWindowPos(DeferHandle);
  End;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.ButtonClick(Sender: TObject);
Begin
  If not FUpdating then
  Begin
    FItemIndex := FButtons.IndexOf(Sender);
{$IFDEF D3}
    Changed;
{$ENDIF}
    Click;
  End;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.ItemsChange(Sender: TObject);
Begin
  If not FReading then
  Begin
    If FItemIndex >= FItems.Count then FItemIndex := FItems.Count - 1;
    UpdateButtons;
  End;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.ReadState(Reader: TReader);
Begin
  FReading := True;
  Inherited ReadState(Reader);
  FReading := False;
  UpdateButtons;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.SetButtonCount(Value: Integer);
Begin
  While FButtons.Count < Value do TTrGroupButton.InternalCreate(Self);
  While FButtons.Count > Value do TTrGroupButton(FButtons.Last).Free;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.SetColumns(Value: Integer);
Begin
  If Value < 1 then Value := 1;
  If Value > 16 then Value := 16;
  If FColumns <> Value then
  Begin
    FColumns := Value;
    ArrangeButtons;
    Invalidate;
  End;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.SetItemIndex(Value: Integer);
Begin
  If FReading then FItemIndex := Value else
  Begin
    If Value < -1 then Value := -1;
    If Value >= FButtons.Count then Value := FButtons.Count - 1;
    If FItemIndex <> Value then
    Begin
      If FItemIndex >= 0 then
        TTrGroupButton(FButtons[FItemIndex]).Checked := False;
      FItemIndex := Value;
      If FItemIndex >= 0 then
        TTrGroupButton(FButtons[FItemIndex]).Checked := True;
    End;
  End;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.SetItems(Value: TStrings);
Begin
  FItems.Assign(Value);
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.UpdateButtons;
Var
  I: Integer;
Begin
  SetButtonCount(FItems.Count);
  For I := 0 to FButtons.Count - 1 do
    TTrGroupButton(FButtons[I]).Caption := FItems[I];
  If FItemIndex >= 0 then
  Begin
    FUpdating := True;
    TTrGroupButton(FButtons[FItemIndex]).Checked := True;
    FUpdating := False;
  End;
  ArrangeButtons;
  Invalidate;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.CMEnabledChanged(Var Message: TMessage);
Var
  I: Integer;
Begin
  Inherited;
  For I := 0 to FButtons.Count - 1 do
    TTrGroupButton(FButtons[I]).Enabled := Enabled;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.CMFontChanged(Var Message: TMessage);
Begin
  Inherited;
  ArrangeButtons;
End;

{-----------------------------------------------------------------------}

Procedure TCustomTrRadioGroup.WMSize(Var Message: TWMSize);
Begin
  Inherited;
  ArrangeButtons;
End;

{-----------------------------------------------------------------------}

Function TCustomTrRadioGroup.CanModify: Boolean;
Begin
  Result := True;
End;

{-----------------------------------------------------------------------}

{$IFDEF D3}
Procedure TCustomTrRadioGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
{$ELSE}
Procedure TCustomTrRadioGroup.GetChildren(Proc: TGetChildProc);
{$ENDIF}
Begin
End;

{-------------------------------------------------------------}

procedure Register;
begin
 RegisterComponents(SPalDream, [TTrRadioButton ,TTrGroupBox,
   TTrCheckBox, TTrRadioGroup]);
end;

{-------------------------------------------------------------}

initialization

  hooks := TList.Create;
  TransClasses := TList.Create;

  RegisterTransControl(TTrRadioButton);
  RegisterTransControl(TTrCheckBox);
  RegisterTransControl(TTrGroupBox);
  RegisterTransControl(TTrRadioGroup);
  RegisterTransControl(TTrGroupButton);

finalization
  If hooks.Count > 0 then
    UnHookWindowsHookEx(WHook);
  hooks.Free;
  TRansClasses.Free;

End.
