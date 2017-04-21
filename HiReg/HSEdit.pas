///////////////////////////////////////////////////////////////////////////////
//////////////////////////THyperImages Component V.2///////////////////////////
///////////////////Copyright © 1998-1999 Noatak Racing Team////////////////////
///////////////////////////////////////////////////////////////////////////////

unit HSEdit;
{$INCLUDE HyperIm.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, ShlObj, Menus, ExtDlgs, Buttons, ToolWin,
  Clipbrd, StdCtrls, Printers, CustomHImages{$ifdef HI_D4}, ImgList {$endif} ;

type
  THSEditForm = class(TForm)
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    FileSave: TMenuItem;
    N2: TMenuItem;
    HotspotMenu: TMenuItem;
    HotspotDefine: TMenuItem;
    FileCopyCode: TMenuItem;
    HotspotShowAll: TMenuItem;
    FormPopupMenu: TPopupMenu;
    PopupDelete: TMenuItem;
    PopupNew: TMenuItem;
    PopupExplore: TMenuItem;
    N3: TMenuItem;
    HotspotNew: TMenuItem;
    HotspotDelete: TMenuItem;
    popupdefine: TMenuItem;
    FileCancel: TMenuItem;
    StatusBar: TStatusBar;
    ToolBar: TToolBar;
    BtnSave: TSpeedButton;
    BtnCancel: TSpeedButton;
    ToolButton1: TToolButton;
    BtnNew: TSpeedButton;
    BtnDelete: TSpeedButton;
    ViewShowToolbar: TMenuItem;
    BtnDefine: TSpeedButton;
    BtnExplore: TSpeedButton;
    ToolButton2: TToolButton;
    BtnShowAll: TSpeedButton;
    ToolButton3: TToolButton;
    BtnHelp: TSpeedButton;
    ToolButton4: TToolButton;
    HelpMenu: TMenuItem;
    HelpContents: TMenuItem;
    N4: TMenuItem;
    HelpAbout: TMenuItem;
    ViewShowStatusbar: TMenuItem;
    FileSetPicturesDirectory: TMenuItem;
    BtnLoadPicture: TSpeedButton;
    ExplorerPanel: TPanel;
    VerticalSplitter: TSplitter;
    HorizontalSplitter: TSplitter;
    N1: TMenuItem;
    ViewMenu: TMenuItem;
    ViewShowExplorer: TMenuItem;
    CoordinatesGroupBox: TGroupBox;
    Coordinates: TListView;
    TreeGroupBox: TGroupBox;
    DisplayTree: TTreeView;
    PopupLoadPicture: TMenuItem;
    TreeHotspotPopupMenu: TPopupMenu;
    TreePopupRename: TMenuItem;
    TreePopupDelete: TMenuItem;
    TreeImagePopupMenu: TPopupMenu;
    TreePopupLoad: TMenuItem;
    TreePopupRemove: TMenuItem;
    TreeHyperImagesPopupMenu: TPopupMenu;
    TreePopupAbout: TMenuItem;
    N6: TMenuItem;
    FileReport: TMenuItem;
    TreePopupPrintReport: TMenuItem;
    HotspotRename: TMenuItem;
    N7: TMenuItem;
    HotspotRemoveImage: TMenuItem;
    FileClearPicture: TMenuItem;
    PopupClearPicture: TMenuItem;
    N8: TMenuItem;
    FileReportSaveToFile: TMenuItem;
    FileReportPrint: TMenuItem;
    SaveDialog1: TSaveDialog;
    TreePopupSaveReport: TMenuItem;
    FileCodeGenerateOnImageMouseDown: TMenuItem;
    FileCodeGenerateOnImageMouseUp: TMenuItem;
    FileCodeCopyToClipboard: TMenuItem;
    ScrollBox: TScrollBox;
    PaintBox1: TPaintBox;
    N9: TMenuItem;
    ViewZoomIn: TMenuItem;
    ViewZoomOut: TMenuItem;
    ViewZoom100: TMenuItem;
    N10: TMenuItem;
    PopupZoomIn: TMenuItem;
    PopUpZoomOut: TMenuItem;
    PopupZoom100: TMenuItem;
    BtnZoomIn: TSpeedButton;
    BtnZoomOut: TSpeedButton;
    BtnZoom100: TSpeedButton;
    BtnRoundRect: TSpeedButton;
    ToolButton5: TToolButton;
    BtnEllipse: TSpeedButton;
    BtnRectangle: TSpeedButton;
    BtnPolygon: TSpeedButton;
    N5: TMenuItem;
    Register1: TMenuItem;
    N11: TMenuItem;
    HTMLMap1: TMenuItem;
    CopyTagSnippet1: TMenuItem;
    SavetoHTMLFile1: TMenuItem;
    CopyImageandMapTagSnippet1: TMenuItem;
    N12: TMenuItem;
    LoadFromFile: TMenuItem;
    SaveToFile: TMenuItem;
    OpenDialog1: TOpenDialog;
    RemoveAllImages: TMenuItem;
    RemoveAllImages1: TMenuItem;
    LoadSelectedImage: TMenuItem;
    procedure HotspotNewClick(Sender: TObject);
    procedure ViewShowExplorerClick(Sender: TObject);
    procedure HotspotDeleteClick(Sender: TObject);
    procedure HotspotDefineClick(Sender: TObject);
    procedure HotspotShowAllClick(Sender: TObject);
    procedure FileMenuClick(Sender: TObject);
    procedure FormPopupMenuPopup(Sender: TObject);
    procedure FileCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileSaveClick(Sender: TObject);
    procedure HotspotMenuClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ViewShowToolbarClick(Sender: TObject);
    procedure HelpContentsClick(Sender: TObject);
    procedure ViewShowStatusbarClick(Sender: TObject);
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure FileLoadPictureClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FileSetPicturesDirectoryClick(Sender: TObject);
    procedure VerticalSplitterMoved(Sender: TObject);
    procedure DisplayTreeChange(Sender: TObject; Node: TTreeNode);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DisplayTreeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HelpAboutClick(Sender: TObject);
    procedure TreePopupLoadClick(Sender: TObject);
    procedure DisplayTreeDblClick(Sender: TObject);
    procedure HotspotRenameClick(Sender: TObject);
    procedure HotspotRemoveImageClick(Sender: TObject);
    procedure FileClearPictureClick(Sender: TObject);
    procedure FileReportPrintClick(Sender: TObject);
    procedure FileReportSaveToFileClick(Sender: TObject);
    procedure FileCodeCopyToClipboardClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ViewZoomInClick(Sender: TObject);
    procedure ViewZoomOutClick(Sender: TObject);
    procedure ViewZoom100Click(Sender: TObject);
    procedure FileCodeGenerateOnImageMouseDownClick(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnRoundRectDblClick(Sender: TObject);
    procedure ViewMenuClick(Sender: TObject);
    procedure Register1Click(Sender: TObject);
    procedure SavetoHTMLFile1Click(Sender: TObject);
    procedure CopyTagSnippet1Click(Sender: TObject);
    procedure CopyImageandMapTagSnippet1Click(Sender: TObject);
    procedure HTMLMap1Click(Sender: TObject);
    procedure SaveToFileClick(Sender: TObject);
    procedure LoadFromFileClick(Sender: TObject);
    procedure RemoveAllImagesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DisplayTreeDeletion(Sender: TObject; Node: TTreeNode);
    procedure DisplayTreeEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    {$ifdef HI_D5} 
      procedure DisplayTreeContextPopup(Sender: TObject; MousePos: TPoint;
        var Handled: Boolean);
    {$endif}
  private
    FHyperImages: TCustomHyperImages;
    FHandlesRegionsList: TList;
    FModified: Boolean;
    FSelectedIndex: Integer; //The index of the Selected hotspot in RegionsList
    OKToClose: Boolean;
    DesignMode: Boolean;
    FormCaption: String;
    SavedHintPointer: TNotifyEvent;
    FLoadingTree: Boolean;
    FClosed: Boolean;
    FZoom: Integer;
    FSaveToComponent: Boolean;
    TempPicturesDir: String;
    OpenPictureDialog: TOpenPictureDialog;
    ImageList: TImageList;
    procedure DisplayHint(Sender: TObject);
    procedure FillDisplay;
    procedure SaveHotspot;
    procedure RefreshTree;
    Function SaveHotSpotToStringList(Hotspot: THotspot;
                                  StringList: TStringList; RGN:HRGN): Integer;
    procedure SetSelectedIndex(Value: Integer);
    procedure SetModified(Value: Boolean);
    procedure SetPicturesDir(Value: String);
    function GetPicturesDir: String;
    procedure SetPictureFileName(Value: String);
    function GetPictureFileName: String;
    procedure ScaleFormToImage(AImage: TImage; Center: Boolean);
    procedure ShowFigureHandles;
    procedure CreateFigureHandles;
    procedure DestroyFigureHandles;
    procedure DrawFigure(Hotspot: THotspot);
    procedure DrawAllFigures;
    procedure Initfornewpoly(const Savedbinfo : boolean);
    procedure HaveNewpoly(Canceled: Boolean);
    procedure Line(const P1, P2 : TPoint);
    function ZoomPoint(APoint: TPoint): TPoint;
    function UnZoomPoint(APoint: TPoint): TPoint;
    procedure UpdateTreeGroupBoxCaption;
    procedure RefreshRegionsList(AHotspotsDef: TStringList);
    procedure LoadHyperImages(AFilename: String);
    function CreateProgressForm(ACaption: String): TForm;
    procedure MakeReport(AFileName: String);
    function ValidateTargetName(AName, AOldName, APictureFileName: String): Boolean;
    function DeleteSelectedHotspot: Boolean;
    procedure SetZoom(Value: Integer);
    procedure MoveHotspot(var Hotspot: THotspot; dx, dy: Integer);
    procedure MoveHandle(var Hotspot: THotspot; dx, dy: Integer; KeepProportions: Boolean);
    procedure SetCoordinatesCaption(const Hotspot: THotspot);
    procedure FillCoordinates(const Hotspot: THotspot);
    procedure ExpandVertices(var Hotspot: THotspot; P1, P2: TPoint);
    procedure UpdateButtonsState;
    procedure CheckForPicturesDir;
  public
    constructor CreateEditor(AOwner: TComponent; AHyperImages: TCustomHyperImages); virtual;
    procedure UpdateRoundRectCorner;   
    procedure ScannerToken(Sender: TObject);
    procedure GenerateMapSnippet(MapSnippet: TStringList;SingleImage: Boolean);
    procedure GenerateCodeTemplate(CodeListing: TStringList);
    property Modified: Boolean read FModified write SetModified;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex;
    property PicturesDir: String read GetPicturesDir write SetPicturesDir;
    property PictureFileName: String read GetPictureFileName write SetPictureFileName;
    property Zoom: Integer read FZoom write SetZoom;
  end;

var
  HSEditForm   : THSEditForm;


function EditHyperImages(HI: TCustomHyperImages; SaveToComponent: Boolean): Boolean;

function BrowseForDir(var CallerWnd: HWND; var AInitialDir, ACaption,
                      APrompt: String): String;
procedure GetVersions(var AComponentVersion, ADelphiVersion: String);
procedure ShowAbout;


implementation

uses About, RoundRectOpt, HImages {$ifdef USEEXPERTS}, Experts {$endif} ;

{$R *.DFM} {$R HOTIMIC.RES}

//////////////////////////////////////////////////////////////////////////
//////////////////////////////HSEditForm///////////////////////////////////
//////////////////////////////////////////////////////////////////////////

var
  ProgressForm: TForm;
  ProgressBar : TProgressBar;
  HotVertexIndex: Integer;
  Prevvertex      : TPoint;
  DrawingFigure, MovingFigure, SizingFigure, HotspotMoved  : Boolean;
  BrowseDialogInitialDir: String;

const
  MinHeight = 260;
  MinWidth = 480;
  ToolbarHeight = 32;
  StatusbarHeight = 19;
  SplitterWidth = 8;
  ExplorerWidth = 160;
  TreeGroupBoxHeight = 180;
  MaxZoom = 500;
  MinZoom = 25;
  crHandGrab = 4;
  crSizeAll = 5;
  crDrawPoly =6;
  crDrawEllipse =7;
  crDrawRect = 8;
  crDrawRoundRect = 9;

procedure GetVersions(var AComponentVersion, ADelphiVersion: String);
begin
  AComponentVersion := ComponentVersion;
  ADelphiVersion := DelphiVersion;
end;

procedure ShowAbout;
begin
  AboutForm := TAboutForm.Create(Application);
  with AboutForm do
  try
    ShowModal;
  finally
    Free;
  end;
end;

//Custom sort to match the order of the tree with the one of HospotsDef
function CustomSortProc(Node1, Node2: TTreeNode; Data: Longint): integer; stdcall;
var
  S1, S2: String;
  c: Char;
begin
  case Data of
    0: c := '/';   //Sort the Image Filename
    1: c := '=';   //Sort the Image + Hotspot
  end;
  S1 := Node1.Text + c;
  S2 := Node2.Text + c;
  Result := AnsiCompareText(S1, S2);
end;

function EditHyperImages(HI: TCustomHyperImages; SaveToComponent: Boolean): Boolean;
var i: Integer;
begin
  Result := False;
  HSEditForm := THSEditForm.CreateEditor(Application, HI);
  with HSEditForm do
    try
      FSaveToComponent := SaveToComponent;
      if (ShowModal = mrOK) and (FSaveToComponent) then begin
        if HSEditForm.Modified then begin
          HI.HotspotsDef.Clear;
          HI.HotspotsDef.Assign(HSEditForm.FHyperImages.HotspotsDef);
          if (HSEditForm.FHyperImages.PictureFileName <> HI.PictureFileName) then begin
            if TheImage = Nil then
              HI.Picture := Nil else
                if TheImage.Picture.Graphic <> Nil then begin
                  HI.Picture.Assign(TheImage.Picture.Graphic);
                end;
            HI.PictureFileName := HSEditForm.FHyperImages.PictureFileName;
          end;
          if (HSEditForm.FHyperImages.PicturesDir <> HI.PicturesDir)  then
            HI.PicturesDir := HSEditForm.FHyperImages.PicturesDir;
        Result := True
        end;
      end;
    finally
      Free;
    end;
end;

procedure Deleteregion(var ARegion : HRGN);
begin
  if ARegion = 0 then Exit;
  if DeleteObject(ARegion) then
      ARegion := 0
    else
      MessageDlg('Unable to delete region.',mtWarning,[mbOK],0);
end;

procedure Clearhotspot(var Hotspot : tHotspot);
begin
  fillchar(Hotspot,sizeof(Hotspot),0);
end;

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

procedure SetNodeImageIndex(Node: TTreeNode; Index: Integer);
begin
  Node.ImageIndex := Index;
  Node.SelectedIndex := Index;
end;

function ImageIndexInTree(AName: String; ATree: TTreeview; AbsoluteIndex: Boolean): Integer;
var
  Node: TTreeNode;
begin
  Result := -1;
  Node := ATree.Items[0].GetFirstChild;
  while Node <> Nil do begin
    if Node.Text = AName then begin
      if AbsoluteIndex then
        Result := Node.AbsoluteIndex else
        Result := Node.Index;
      Exit;
    end;
    Node := ATree.Items[0].GetNextChild(Node);
  end;
end;

function NodeToHotspotDefIndex(Node: TTreeNode): Integer;
begin
  if Node.ImageIndex = 2 then
    Result := Node.AbsoluteIndex - Node.Parent.Index -2
  else Result := -1;
end;

function HotspotDefIndexToNode(Index: Integer): TTreeNode;
begin
  with HSEditForm do begin
    if (FHyperImages.HotspotsDef.Count <= 0) or (Index = - 1) then
      Result := Nil
    else
      Result := DisplayTree.Items[Index + 2 +
      ImageIndexInTree(FHyperImages.ExtractPicture(FHyperImages.HotspotsDef.Strings[Index]),
      DisplayTree, False)];
  end;
end;

{$ifdef HI_D5}
    procedure THSEditForm.DisplayTreeContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: Boolean);
    begin
      DisplayTreeMouseUp(DisplayTree, mbRight, [], MousePos.X, MousePos.Y);
    end;
{$endif}

procedure THSEditForm.Line(const P1, P2 : TPoint);
begin
  with PaintBox1.Canvas do begin
    with P1 do MoveTo(X,Y);
    with P2 do LineTo(X,Y);
  end;
end;


function THSEditForm.ZoomPoint(APoint: TPoint): TPoint;
begin
  Result := Point(APoint.X  * FZoom div 100, APoint.Y  * FZoom div 100);
end;

function THSEditForm.UnZoomPoint(APoint: TPoint): TPoint;
begin
  Result := Point(APoint.X  * 100 div FZoom, APoint.Y  * 100 div FZoom);
end;

function CreateHotspotRegion(Hotspot: THotspot; var RGN: HRGN): Boolean;
begin
  with Hotspot do begin
    case FigureType of
              ftPolygon: RGN := CreatePolygonRgn(Vertices, VertexCount, ALTERNATE);
              ftRectangle: RGN := CreateRectRgn(Vertices[1].x, Vertices[1].y,
                                  Vertices[3].x, Vertices[3].y);
              ftEllipse: RGN := CreateEllipticRgn(Vertices[1].x, Vertices[1].y,
                                  Vertices[3].x, Vertices[3].y);
              ftRoundRectangle: RGN := CreateRoundRectRgn(Vertices[1].x, Vertices[1].y,
                                  Vertices[3].x, Vertices[3].y, Vertices[5].x, Vertices[5].y);
    end;
    if RGN = 0 then begin
      Raise Exception.Create('Could not create region in editor for target "' +
      Target + '".');
      Result := False;
    end else
      Result := True;
  end;
end;

function THSEditForm.CreateProgressForm(ACaption: String): TForm;
begin
    Result := TForm.Create(Self);
  with Result do begin
    Left := 231;
    Top := 254;
    BorderIcons := [];
    BorderStyle := bsDialog;
    Caption := ACaption;
    ClientHeight := 96;
    ClientWidth := 355;
    Position := poScreenCenter;
    ModalResult := mrNone;
    ProgressBar := TProgressBar.Create(Result);
    with ProgressBar do begin
      Parent := Result;
      Left := 25;
      Top := 16;
      Width := 305;
      Height := 25;
      Min := 0;
      Max := 100;
    end;
    with TButton.Create(Result) do begin
      Parent := Result;
      Left := 140;
      Top := 55;
      Width := 75;
      Height := 25;
      Caption := 'Cancel';
      TabOrder := 0;
      ModalResult := mrAbort;
    end;
  end;
end;

constructor THSEditForm.CreateEditor(AOwner: TComponent; AHyperImages: TCustomHyperImages);
var
 i: Integer;
 Bitmap: TBitmap;
begin
  inherited Create(AOwner);
  ImageList := TImageList.Create(Self);
  Bitmap := TBitmap.Create;
  with Bitmap do
    try
      {$ifdef HI_D4}
        ImageList.Masked := True;
        ImageList.DrawingStyle := dsNormal;
        Bitmap.LoadFromResourceName(hInstance, 'HYPERIMAGE');
        ImageList.AddMasked(Bitmap, clWhite);
        Bitmap.LoadFromResourceName(hInstance, 'IMAGE');
        ImageList.AddMasked(Bitmap, clWhite);
        Bitmap.LoadFromResourceName(hInstance, 'HOTSPOT');
        ImageList.AddMasked(Bitmap, clWhite);
        Bitmap.LoadFromResourceName(hInstance, 'SELIMAGE');
        ImageList.AddMasked(Bitmap, clWhite);
      {$else}
        ImageList.Masked := False;
        ImageList.DrawingStyle := dsTransparent;
        Bitmap.LoadFromResourceName(hInstance, 'HYPERIMAGE');
        ImageList.Add(Bitmap, Nil);
        Bitmap.LoadFromResourceName(hInstance, 'IMAGE');
        ImageList.Add(Bitmap, Nil);
        Bitmap.LoadFromResourceName(hInstance, 'HOTSPOT');
        ImageList.Add(Bitmap, Nil);
        Bitmap.LoadFromResourceName(hInstance, 'SELIMAGE');
        ImageList.Add(Bitmap, Nil);
      {$endif}
    finally
      Free;
    end; 
  DisplayTree.Images := ImageList;
  Screen.Cursors[crHandGrab] := LoadCursor(HInstance, 'HANDGRAB');
  Screen.Cursors[crSizeAll] := LoadCursor(HInstance, 'SIZEALL');
  Screen.Cursors[crDrawPoly] := LoadCursor(HInstance, 'DRAWPOLY');
  Screen.Cursors[crDrawEllipse] := LoadCursor(HInstance, 'DRAWELLIPSE');
  Screen.Cursors[crDrawRect] := LoadCursor(HInstance, 'DRAWRECT');
  Screen.Cursors[crDrawRoundRect] := LoadCursor(HInstance, 'DRAWROUNDRECT');
  RoundRectOptionsForm := TRoundRectOptionsForm.Create(Self);
  PaintBox1.Canvas.Brush.Style := bsClear;
  PaintBox1.Canvas.Pen.Mode := pmNot;
  FModified := False;
  FSelectedIndex := -1;
  OKToClose := False;
  FClosed := False;
  FormCaption := Caption;
  FZoom := 100;
  FHandlesRegionsList := TList.Create;
  DesignMode := csDesigning in AHyperImages.ComponentState;
  FHyperImages := TCustomHyperImages.Create(Self);
  with FHyperImages do begin
    Name := AHyperImages.Name;
    for i := 0 to AHyperImages.HotspotsDef.Count - 1 do
      HotspotsDef.Add(AHyperImages.HotspotsDef[i]);
    HotspotsDef.Sorted := True;
    HotspotsDef.Duplicates := dupError;
    if AHyperImages.Picture <> Nil then
      if AHyperImages.Picture.Graphic <> Nil then
        Picture.Graphic := AHyperImages.Picture.Graphic;
    PicturesDir := AHyperImages.PicturesDir;
    PictureFileName := AHyperImages.PictureFileName;
  end;
  PaintBox1.Left := 0;
  PaintBox1.Top := 0;
  SavedHintPointer := Application.OnHint;
  Application.OnHint := DisplayHint;
  TreeGroupBox.Height := TreeGroupBoxHeight;
  UpdateTreeGroupBoxCaption;
  if FHyperImages.Picture <> Nil then
    if FHyperImages.Picture.Graphic <> Nil then begin
      TheImage := TImage.Create(Self);
      with TheImage do begin
        Picture := FHyperImages.Picture;
        Autosize := True;
        PaintBox1.ClientWidth := Width;
        PaintBox1.ClientHeight := Height;
        with FHyperImages  do
          CreateAllRegions(HotspotsDef, RegionsList, PictureFileName);
        BtnNew.Enabled := True;
      end;
    end;
  OpenPictureDialog := TOpenPictureDialog.Create(Self);
  if FHyperImages.PicturesDir <> '' then
    OpenPictureDialog.InitialDir := FHyperImages.PicturesDir;
  Cursor := crArrow;
  TheRegion := 0;
  Clearhotspot(TheHotspot);
  DrawingFigure := False;
  MovingFigure := False;
  SizingFigure := False;
  HotspotNew .Enabled := True;
  ViewShowExplorer.Enabled := True;
  ExplorerPanel.Width := ExplorerWidth;
  Toolbar.Height := ToolbarHeight;
  Statusbar.Height := StatusbarHeight;
  Statusbar.Invalidate;
end;

procedure THSEditForm.FormCreate(Sender: TObject);
begin
  {$ifndef USEEXPERTS}
    FileCodeGenerateOnImageMouseDown.Enabled := False;
    FileCodeGenerateOnImageMouseUp.Enabled := False;
  {$endif}
  {$ifdef HI_D5}
    DisplayTree.OnContextPopup := DisplayTreeContextPopup;
  {$endif}
end;

procedure THSEditForm.SetModified(Value: Boolean);
begin
  if FModified <> Value then begin
    FModified := Value;
    if FModified then begin
      Statusbar.Panels[1].Text := 'Modified';
      BtnSave.Enabled := True;
    end else
      Statusbar.Panels[1].Text := '';
  end;
end;


procedure THSEditForm.SetSelectedIndex(Value: Integer);
var RGN: HRGN;
    AFileName: String;
begin
  if (Value > FHyperImages.HotspotsDef.Count - 1) or
  (Value < -1) then
    Exit;
  DestroyFigureHandles;
  if Value = -1 then begin
    TheRegion := 0;
    Statusbar.panels[3].Text := '';
    FSelectedIndex := Value;
  end else begin
    RGN := StrToInt(FHyperImages.RegionsList.Strings[Value]);
    if RGN = 0 then
      Exit;
    TheRegion := RGN;
    FHyperImages.LoadHotspotFromLineDef(
          FHyperImages.HotspotsDef.Strings[Integer(FHyperImages.RegionsList.Objects[Value])],
          AFileName, TheHotspot, True );
    FSelectedIndex := Value;
    CreateFigureHandles;
    Statusbar.panels[3].Text := TheHotspot.Target;
  end;
  UpdateButtonsState;
  RoundRectOptionsForm.SetUpdateState(Self);
  PaintBox1.Invalidate;
end;

procedure THSEditForm.PaintBox1Paint(Sender: TObject);
begin
  if TheImage <> nil then
    with TheImage do
      PaintBox1.Canvas.StretchDraw(PaintBox1.ClientRect, Picture.Graphic);
  if not HotspotShowAll.Checked then begin
    if SelectedIndex > -1 then
      DrawFigure(TheHotspot);
  end else begin
    DrawAllFigures;
    if MovingFigure then
      DrawFigure(TheHotspot);
  end;
  ShowFigureHandles;
end;

procedure  THSEditForm.ScaleFormToImage(AImage: TImage; Center: Boolean);
var
  P: TWindowPlacement;
  W, H: Integer;
begin
  if AImage = Nil then
    Exit;
  with AImage do begin
    P.Length := SizeOf(TWindowPlacement);
    GetWindowPlacement(Self.Handle, @P);
    W := Min(Max(Width + ExplorerPanel.Width + VerticalSplitter.Width, MinWidth) +
     Self.Width - Self.ClientWidth, Screen.Width);
    H := Min(Max(Height + Statusbar.Height + Toolbar.Height, MinHeight) +
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
    ScrollBox.AutoScroll := False;
    ScrollBox.AutoScroll := True;
    with AImage do
      PaintBox1.Canvas.StretchDraw(PaintBox1.ClientRect, Picture.Graphic);
  end;
end;

procedure THSEditForm.SetPicturesDir(Value: String);
begin
  if Value <> '' then
    if (Value[Length(Value)] <> '\') then
      Value := Value + '\';
  if (Value <> FHyperImages.PicturesDir) then begin
    FHyperImages.PicturesDir := Value;
    Statusbar.Invalidate;
  end;
end;

function THSEditForm.GetPicturesDir: String;
begin
  Result := FHyperImages.PicturesDir;
end;

procedure THSEditForm.SetPictureFileName(Value: String);
begin
    FHyperImages.PictureFileName := Value;
    if Value = '' then
      Self.Caption := FormCaption else
      Self.Caption := FormCaption + ' - '+ Value +
      ' [' + IntToStr(FZoom) + ' %'+ ']';
    RefreshTree;
end;

function THSEditForm.GetPictureFileName: String;
begin
  Result := FHyperImages.PictureFileName;
end;

procedure THSEditForm.ViewShowToolbarClick(Sender: TObject);
var W: TWindowPlacement;
begin
  W.length := sizeof(TWindowPlacement);
  GetWindowPlacement(Handle, @W);
  if ViewShowToolbar.Checked then begin
    Toolbar.Height := 0;
    W.rcNormalPosition.Bottom := Max(MinHeight, W.rcNormalPosition.Bottom - ToolbarHeight);
    SetWindowPlacement(Handle, @W) ;
  end else begin
    Toolbar.Height := ToolbarHeight;
    W.rcNormalPosition.Bottom := Min(Screen.Height, W.rcNormalPosition.Bottom + ToolbarHeight);
    SetWindowPlacement(Handle, @W) ;
  end;
  ViewShowToolbar.Checked := not ViewShowToolbar.Checked;
  Invalidate;
end;

procedure THSEditForm.DisplayHint(Sender: TObject);
begin
  if Application.Hint = '' then begin
    Statusbar.SimplePanel := false
  end else begin
    Statusbar.SimpleText := Application.Hint;
    Statusbar.SimplePanel := true;
  end;
end;

procedure THSEditForm.FillDisplay;
var i, d, CurPicIndex: Integer;
    S, PrevPic, AFileName, ATarget: String;
begin
  PrevPic := '';
  FLoadingTree := True;
  with DisplayTree.Items do
    for d := 0 to FHyperImages.HotspotsDef.Count - 1 do begin
      S := FHyperImages.Hotspotsdef.Strings[d];
      i := 1;
      AFileName := '';
      ATarget := '';
      while S[i] <> '/' do begin
        AFileName := AFileName + S[i];
        Inc(i);
      end;
      Inc(i);
      while S[i] <> '=' do begin
         ATarget := ATarget + S[i];
        Inc(i);
      end;
      if PrevPic <> AFileName then begin //New Picture
        if AFileName <> FHyperImages.PictureFileName then
          SetNodeImageIndex(AddChild(Item[0], AFileName), 1) else
          SetNodeImageIndex(AddChild(Item[0], AFileName), 3);
        CurPicIndex := Count - 1;
      end;
      SetNodeImageIndex(AddChild(Item[CurPicIndex], ATarget), 2);
      PrevPic := AFileName;
      ProgressBar.Position := 100 * d div FHyperImages.HotspotsDef.Count - 1;
      Application.ProcessMessages;
      if ProgressForm.ModalResult = mrAbort then
        Abort;
   end; //d for loop
  DisplayTree.Items[0].Expand(False);
  FLoadingTree := False;
end;

procedure THSEditForm.ViewShowStatusbarClick(Sender: TObject);
var W: TWindowPlacement;
begin

  W.length := sizeof(TWindowPlacement);
  GetWindowPlacement(Handle, @W);
  if ViewShowStatusbar.Checked then begin
    Statusbar.Height := 0;
    W.rcNormalPosition.Bottom := Max(MinHeight, W.rcNormalPosition.Bottom - StatusbarHeight);
    SetWindowPlacement(Handle, @W) ;
  end else begin
    Statusbar.Height := StatusbarHeight;
    W.rcNormalPosition.Bottom := Min(Screen.Height, W.rcNormalPosition.Bottom + StatusbarHeight);
    SetWindowPlacement(Handle, @W) ;
  end;
  ViewShowStatusbar.Checked := not ViewShowStatusbar.Checked;
  Invalidate;
end;

procedure THSEditForm.Initfornewpoly(const Savedbinfo : boolean);
var
  Savetarget : string;
  Index: Integer;
begin
  if HotspotShowAll.Enabled then
    DrawFigure(TheHotspot);
  DestroyFigureHandles;
  if Savedbinfo then with TheHotspot do begin
      SaveTarget := Target;
      Clearhotspot(TheHotspot);
      Target := SaveTarget;
      Index := FHyperImages.HotspotsDef.IndexOfObject(Pointer(TheRegion));
      if Index <> -1 then begin
        FHyperImages.HotspotsDef.Delete(Index);
        RefreshRegionsList(FHyperImages.HotspotsDef);
        DrawFigure(TheHotspot);
        DeleteRegion(TheRegion);
        DrawingFigure := True;
        DisplayTree.Selected.Delete;
      end;
  end else
    Clearhotspot(TheHotspot);
  DisplayTree.Selected := DisplayTree.Items.GetFirstNode;
  TheRegion := 0;
  if BtnPolygon.Down then
    Screen.Cursor := crDrawPoly else
  if BtnRectangle.Down then
    Screen.Cursor := crDrawRect else
  if BtnRoundRect.Down then
    Screen.Cursor := crDrawRoundRect else
  if BtnEllipse.Down then
    Screen.Cursor := crDrawEllipse;
  DrawingFigure := True;
  UpdateButtonsState;
end;

procedure THSEditForm.HaveNewpoly(Canceled: Boolean);
begin
  with HSEditForm do begin
    DrawingFigure := False;
    Screen.Cursor := crDefault;
    if not Canceled then
      if ((TheHotspot.FigureType <> ftPolygon) and
      ((TheHotspot.Vertices[1].X <> TheHotspot.Vertices[3].X) or
      (TheHotspot.Vertices[1].Y <> TheHotspot.Vertices[3].Y))) or
      (TheHotspot.FigureType = ftPolygon) then begin
      SaveHotspot;
      ShowFigureHandles;
      end;
    UpdateButtonsState;
  end;
end;

procedure THSEditForm.UpdateButtonsState;
begin
  BtnDelete.Enabled := SelectedIndex > -1;
  BtnDefine.Enabled := SelectedIndex > -1;
  BtnNew.Enabled := Not DrawingFigure and (TheImage <> Nil);
  BtnShowAll.Enabled := Not DrawingFigure and (TheImage <> Nil);
  BtnExplore.Enabled := Not DrawingFigure;
  BtnSave.Enabled := Not DrawingFigure;
  BtnLoadPicture.Enabled := Not DrawingFigure;
  BtnZoomIn.Enabled:= Not DrawingFigure and (TheImage <> Nil);
  BtnZoomOut.Enabled:= Not DrawingFigure and (TheImage <> Nil);
  BtnZoom100.Enabled:= Not DrawingFigure and (TheImage <> Nil);
  BtnPolygon.Enabled := Not DrawingFigure and (TheImage <> Nil);
  BtnRectangle.Enabled := BtnPolygon.Enabled;
  BtnRoundRect.Enabled := BtnPolygon.Enabled;
  BtnEllipse.Enabled := BtnPolygon.Enabled;
  BtnSave.Enabled := FModified;
end;

procedure THSEditForm.ShowFigureHandles;
var
  I: Integer;
  RGN: HRGN;
begin
  with FHandlesRegionsList do begin
     for I := 0 to Count - 1 do begin
       RGN := Integer(Items[I]);
       InvertRgn(PaintBox1.Canvas.Handle, RGN);
     end;
  end;
end;

procedure THSEditForm.CreateFigureHandles;
var
  I, Count : Integer;
  RGN: HRGN;
procedure CreateHandle(P: TPoint);
begin
  RGN := CreateRectRgn(P.X * FZoom div 100  -3,P.Y * FZoom div 100  -3,
                       P.X * FZoom div 100  +3, P.Y * FZoom div 100  +3);
  FHandlesRegionsList.Add(Pointer(RGN));
end;

begin
  if FHandlesRegionsList.Count <> 0 then
    Exit;
  with TheHotspot do begin
    if FigureType = ftPolygon then
      Count := VertexCount else
      Count := 4;
    for I := 1 to Count do
      CreateHandle(Vertices[I]);
  end;
end;

procedure THSEditForm.DestroyFigureHandles;
var
  I: Integer;
  RGN: HRGN;
begin
    with FHandlesRegionsList do begin
       for I := 0 to Count - 1 do begin
         RGN := Integer(Items[I]);
         InvertRgn(PaintBox1.Canvas.Handle, RGN);
         DeleteRegion(RGN);
       end;
       FHandlesRegionsList.Clear;
   end;
end;

procedure THSEditForm.DrawFigure(Hotspot: THotspot);
var
  I : integer;
begin
  with Hotspot, PaintBox1.Canvas do begin
    Pen.Mode := pmNot;
    Brush.Style := bsClear;
    case FigureType of
      ftPolygon: begin
        if VertexCount >= 2 then with PaintBox1.Canvas do begin
            with Vertices[1] do MoveTo(X * FZoom div 100, Y * FZoom div 100);
            for I := 2 to VertexCount do
              with Vertices[I] do LineTo(X * FZoom div 100, Y * FZoom div 100);
            if not DrawingFigure then
              with Vertices[1] do LineTo(X * FZoom div 100, Y * FZoom div 100);
               { Do final segment. }
            end;
        if DrawingFigure and (VertexCount > 0) and (@Hotspot = @TheHotspot) then
          Line(ZoomPoint(Vertices[VertexCount]), PrevVertex);
      end;
      ftRectangle: begin
        Rectangle(ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y);
      end;
      ftEllipse: begin
        Ellipse(ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y);
      end;
      ftRoundRectangle: begin
        Windows.RoundRect(handle, ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y,
                  ZoomPoint(Vertices[5]).X,  ZoomPoint(Vertices[5]).Y);
      end;
    end;
  end;
end;

procedure THSEditForm.DrawAllFigures;
var i: Integer;
    Hotspot: THotspot;
    AFileName: String;
begin
  for i := 0 to FHyperImages.RegionsList.Count - 1 do begin
    FHyperImages.LoadHotspotFromLineDef(
    FHyperImages.HotspotsDef.Strings[Integer(FHyperImages.RegionsList.Objects[i])], AFileName,
    Hotspot, True);
    DrawFigure(Hotspot);
  end;
end;

procedure THSEditForm.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

var RGN: HRGN;
    i: Integer;
function Vertexfinishespolygon(const V : TPoint): boolean;
begin
  with TheHotspot do begin
    Vertexfinishespolygon :=
        (Vertexcount = Maxvertexcount)
      or {else}
        (
            (Vertexcount > 2)
          and {then}
            (Dist(V, ZoomPoint(Vertices[1])
           ) < 10)
           );
    if result then begin
        { Erase previous line, and close the polygon. }
        Line(ZoomPoint(Vertices[Vertexcount]),Prevvertex);
        Line(ZoomPoint(Vertices[Vertexcount]),ZoomPoint(Vertices[1]));
    end else begin
      { Add the vertex. }
      inc(Vertexcount);
      Vertices[VertexCount] := UnZoomPoint(V);
    end;
  end;
end;

var
  Vertex : TPoint;
begin
  with TheHotspot, PaintBox1.Canvas do begin
    if DrawingFigure and (Button = mbLeft) then begin  //drawing mode
      if BtnPolygon.Down then begin
       {Start new side from this vertex if still open. }
        Vertex := Point(X,Y);
        if Vertexfinishespolygon(Vertex) then
          Havenewpoly(False);
        Prevvertex := Vertex;
      end else begin
        Vertices[1] := UnZoomPoint(Point(X,Y));
        Vertices[3] := UnZoomPoint(Point(X,Y));
        if BtnRectangle.Down then begin
          FigureType := ftRectangle;
          VertexCount := 4;
          Rectangle(ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                    ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y);
        end else
        if BtnEllipse.Down then begin
          FigureType := ftEllipse;
          VertexCount := 4;
          Ellipse(ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                    ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y);
        end else
        if BtnRoundRect.Down then begin
          FigureType := ftRoundRectangle;
          VertexCount := 5;
          Vertices[5].x := RoundRectOptionsForm.CornerWidthSpinEdit.Value;
          Vertices[5].y := RoundRectOptionsForm.CornerHeightSpinEdit.Value;
          Windows.RoundRect(Handle, ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                    ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y,
                    ZoomPoint(Vertices[5]).X,  ZoomPoint(Vertices[5]).Y);
        end;
      end;
    end else if (Screen.Cursor = crSizeAll) then begin
      FHyperImages.HotspotsDef.Delete(Integer(FHyperImages.RegionsList.Objects[SelectedIndex]));
      RefreshRegionsList(FHyperImages.HotspotsDef);
      DeleteRegion(TheRegion);
      SizingFigure := True;
    end else begin
      for i := 0 to FHyperImages.RegionsList.Count - 1 do begin
        RGN := StrToInt(FHyperImages.RegionsList.Strings[i]);
        if PtInRegion(RGN, X * 100 div FZoom,
                      Y * 100 div FZoom) then begin
          MovingFigure := True;
          HotspotMoved := False;
          if SelectedIndex <> Integer(FHyperImages.RegionsList.Objects[i]) then begin
            DisplayTree.Selected := HotspotDefIndexToNode(
            Integer(FHyperImages.RegionsList.Objects[i])) ;
          end;
          Screen.Cursor := crHandGrab;
          FHyperImages.HotspotsDef.Delete(Integer(FHyperImages.RegionsList.Objects[i]));
          RefreshRegionsList(FHyperImages.HotspotsDef);
          DeleteRegion(TheRegion);
          PrevVertex := Point(X, Y);
          Break;
        end;
      end;
    end;
  end;
end;

procedure THSEditForm.ExpandVertices(var Hotspot: THotspot; P1, P2: TPoint);
begin
  with Hotspot do begin
    Vertices[1].X := P1.X;
    Vertices[1].Y := P1.Y;
    Vertices[3].X := P2.X;
    Vertices[3].Y := P2.Y;
    Vertices[2].X := P2.X;
    Vertices[2].Y := P1.Y;
    Vertices[4].X := P1.X;
    Vertices[4].Y := P2.Y;
  end;
end;

procedure THSEditForm.PaintBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
 Statusbar.Panels[2].Text :=
 Format('X: %4d, Y: %4d', [X * 100 div FZoom, Y * 100 div FZoom]);
 if  DrawingFigure then begin
  with TheHotspot, PaintBox1.Canvas do begin
    pen.Mode := pmNot;
    brush.Style := bsClear;
    if (x < 0) or (Y < 0) or (X * 100 div FZoom > PaintBox1.Width) or
    (Y * 100 div FZoom > PaintBox1.Height) then
      Exit;
    if BtnPolygon.Down then begin
      if (VertexCount = 0) then Exit;
      Line(ZoomPoint(Vertices[VertexCount]), PrevVertex);
      PrevVertex := Point(X,Y);
      Line(ZoomPoint(Vertices[VertexCount]), PrevVertex);
    end else
    if BtnRectangle.Down then begin
      if FigureType <> ftRectangle then Exit;
      if ssShift in Shift then
        Y := X - ZoomPoint(Vertices[1]).X + ZoomPoint(Vertices[1]).Y;
      Rectangle(ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y);
      ExpandVertices(TheHotspot, Vertices[1], UnZoomPoint(Point(X,Y)));
      Rectangle(ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y);
    end else
    if BtnEllipse.Down then begin
      if FigureType <> ftEllipse then Exit;
      if ssShift in Shift then
        Y := X - ZoomPoint(Vertices[1]).X + ZoomPoint(Vertices[1]).Y;
      Ellipse(ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y);
      ExpandVertices(TheHotspot, Vertices[1], UnZoomPoint(Point(X,Y)));
      Ellipse(ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y);
    end else
    if BtnRoundRect.Down then begin
      if FigureType <> ftRoundRectangle then Exit;
      if ssShift in Shift then
        Y := X - ZoomPoint(Vertices[1]).X + ZoomPoint(Vertices[1]).Y;
      Windows.RoundRect(Handle, ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y,
                ZoomPoint(Vertices[5]).x, ZoomPoint(Vertices[5]).y);
      ExpandVertices(TheHotspot, Vertices[1], UnZoomPoint(Point(X,Y)));
      Windows.RoundRect(Handle, ZoomPoint(Vertices[1]).X, ZoomPoint(Vertices[1]).Y,
                  ZoomPoint(Vertices[3]).X,  ZoomPoint(Vertices[3]).Y,
                ZoomPoint(Vertices[5]).x, ZoomPoint(Vertices[5]).y);
    end;
  end;
 end else
 if MovingFigure then begin
     DrawFigure(TheHotspot);
   DestroyFigureHandles;
   if (PrevVertex.x <> x) or (PrevVertex.y <> y) then begin
     MoveHotspot(TheHotspot, 100 * (x - PrevVertex.x) div FZoom, 100 * (y - PrevVertex.y) div FZoom);
     PrevVertex := Point(X, Y);
     DrawFigure(TheHotspot);
     HotspotMoved := True;
     Modified := True;
     if (X < 0) or (Y < 0) or (X > PaintBox1.Width) or (Y > PaintBox1.Height) then
       PaintBox1MouseUp(Self, mbLeft,[], X, Y);
   end;
     CreateFigureHandles;
     ShowFigureHandles;
 end else if SizingFigure then begin
   DrawFigure(TheHotspot);
   DestroyFigureHandles;
   if ssShift in Shift then
     MoveHandle(TheHotspot, (100 * x div FZoom) - TheHotspot.Vertices[HotVertexIndex].x ,
              (100 * y div FZoom) - TheHotspot.Vertices[HotVertexIndex].y, True)
   else
     MoveHandle(TheHotspot, (100 * x div FZoom) - TheHotspot.Vertices[HotVertexIndex].x ,
              (100 * y div FZoom) - TheHotspot.Vertices[HotVertexIndex].y, False);
   DrawFigure(TheHotspot);
   CreateFigureHandles;
   ShowFigureHandles;
   Modified := True;
   if (X < -3) or (Y < -3) or (X > PaintBox1.Width + 3) or (Y > PaintBox1.Height + 3) then
     PaintBox1MouseUp(Self, mbLeft,[], X, Y);
 end else with FHandlesRegionsList do
   for I := 0 to Count -1 do begin
     if PtInRegion(Integer(Items[I]),x ,y) then begin
       Screen.Cursor := crSizeAll;
       HotVertexIndex := I + 1;
       Break;
     end else
      Screen.Cursor := crDefault;
 end;
end;

procedure THSEditForm.PaintBox1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if DrawingFigure then begin
    if (TheHotspot.FigureType <> ftPolygon) then
      HaveNewPoly(False);
  end else if MovingFigure or SizingFigure then begin
    Screen.Cursor := crDefault;
    if (not HotspotMoved) and MovingFigure then begin
      CreateFigureHandles;
    end;
    MovingFigure := False;
    SizingFigure := False;
    CreateHotspotRegion(TheHotspot, TheRegion);
    SaveHotSpotToStringList(TheHotspot,
    FHyperImages.Hotspotsdef, TheRegion);
    RefreshRegionsList(FHyperImages.HotspotsDef);
    FillCoordinates(TheHotspot);
  end;
end;

procedure THSEditForm.UpdateRoundRectCorner;
begin
  with TheHotspot, RoundRectOptionsForm do begin
    if (FigureType <> ftRoundRectangle) or
    (SelectedIndex = -1) or
    (CornerWidthSpinEdit.Value >= (Vertices[3].X - Vertices[1].X) ) or
    (CornerHeightSpinEdit.Value >= (Vertices[3].Y - Vertices[1].Y)) then
      Exit;
    FHyperImages.HotspotsDef.Delete(Integer(FHyperImages.RegionsList.Objects[SelectedIndex]));
    RefreshRegionsList(FHyperImages.HotspotsDef);
    DeleteRegion(TheRegion);
    DrawFigure(TheHotspot);
    DestroyFigureHandles;
    Vertices[5].X := CornerWidthSpinEdit.Value;
    Vertices[5].Y := CornerHeightSpinEdit.Value; 
    CreateHotspotRegion(TheHotspot, TheRegion);
    SaveHotSpotToStringList(TheHotspot,
    FHyperImages.Hotspotsdef, TheRegion);
    RefreshRegionsList(FHyperImages.HotspotsDef);
    FillCoordinates(TheHotspot);
    DrawFigure(TheHotspot);
    CreateFigureHandles;
    ShowFigureHandles;
    Modified := True;
  end;
end;

procedure THSEditForm.MoveHandle(var Hotspot: THotspot; dx, dy: Integer;
KeepProportions: Boolean);
var
  Maxdx, Maxdy, Mindx, Mindy: Integer;
  Prop: Extended;
begin
  with Hotspot do begin
    if KeepProportions and (FigureType <> ftPolygon) and
    (Vertices[4].y <> Vertices[1].y) then begin
        Prop := (Vertices[2].x - Vertices[1].x) /
        (Vertices[4].y - Vertices[1].y);

     if HotVertexIndex mod 2 = 1 then
       dx := Round(Prop * dy) else
       dx :=  - Round(Prop * dy);
    end;
    if not ptInRect(Bounds(0, 0, TheImage.Width, TheImage.Height),
      Point(Vertices[HotVertexIndex].x+dx, Vertices[HotVertexIndex].y+dy)) then begin
        Maxdx := TheImage.Width - Vertices[HotVertexIndex].x;
        Mindx := - Vertices[HotVertexIndex].x;
        Maxdy := TheImage.Height - Vertices[HotVertexIndex].y;
        Mindy := - Vertices[HotVertexIndex].y;
        dx := Min(dx, Maxdx);
        dx := Max(dx, Mindx);
        dy := Min(dy, Maxdy);
        dy := Max(dy, Mindy);
      end;
    Inc(Vertices[HotVertexIndex].x, dx);
    Inc(Vertices[HotVertexIndex].y, dy);
    if FigureType <> ftPolygon then begin
      if HotVertexIndex mod 2 = 1 then begin
        Inc(Vertices[((HotVertexIndex + 2) mod 4) + 1].x, dx);
        Inc(Vertices[((HotVertexIndex) mod 4) + 1].y, dy);
      end else begin
        Inc(Vertices[(HotVertexIndex + 1) mod 4].x, dx);
        Inc(Vertices[(HotVertexIndex + 3) mod 4].y, dy);
      end;
    end;
  end;
end;

procedure THSEditForm.MoveHotspot(var Hotspot: THotspot; dx, dy: Integer);
var
  i, Count, Maxdx, Maxdy, Mindx, Mindy: Integer;
begin
  with Hotspot do begin
    if FigureType = ftPolygon then
      Count := VertexCount else
      Count := 4;
    for i := 1 to Count do begin
      if not ptInRect(Bounds(0, 0, TheImage.Width, TheImage.Height),
      Point(Vertices[i].x+dx, Vertices[i].y+dy)) then begin
        Maxdx := TheImage.Width - Vertices[i].x;
        Mindx := - Vertices[i].x;
        Maxdy := TheImage.Height - Vertices[i].y;
        Mindy := - Vertices[i].y;
        dx := Min(dx, Maxdx);
        dx := Max(dx, Mindx);
        dy := Min(dy, Maxdy);
        dy := Max(dy, Mindy);
      end;
    end;
    for i := 1 to Count do begin
      Inc(Vertices[i].x, dx);
      Inc(Vertices[i].y, dy);
    end;
  end;
end;

Procedure THSEditForm.UpdateTreeGroupBoxCaption;
begin
  Case FHyperImages.HotspotsDef.Count of
    0: TreeGroupBox.Caption := 'No Hotspot';
    1: TreeGroupBox.Caption := '1 Hotspot'
    else TreeGroupBox.Caption := IntToStr(FHyperImages.HotspotsDef.Count) + ' Hotspots';
  end

end;

procedure THSEditForm.RefreshTree;
var N: TTreeNode;
    SavedIndex: Integer;
begin
  SavedIndex := 0;
  with DisplayTree.Items do
    if Count > 0 then begin
      N := Item[0].GetFirstChild;
      while N <> Nil do begin
        if N.Text = FHyperImages.PictureFileName then begin
          SetNodeImageIndex(N, 3);
          SavedIndex := N.AbsoluteIndex;
        end else
          SetNodeImageIndex(N, 1);
        N := Item[0].GetNextChild(N);
      end;
      Item[0].Expand(False);
      if SavedIndex <> 0 then
        Item[SavedIndex].Expand(False);
      DisplayTree.Invalidate;
    end;

end;

procedure THSEditForm.RefreshRegionsList(AHotspotsDef: TStringList);
var
  i: Integer;
begin
  FHyperImages.RegionsList.BeginUpdate;
  try
    FHyperImages.RegionsList.Clear;
    for i := 0  to AHotspotsDef.Count - 1 do
      if AHotspotsDef.Objects[i] <> Nil then
        FHyperImages.RegionsList.AddObject(IntToStr(Integer(AHotspotsDef.Objects[i])),
                                            Pointer(i));
  finally
    FHyperImages.RegionsList.EndUpdate;
  end;
end;

function THSEditForm.ValidateTargetName(AName, AOldName, APictureFileName: String): Boolean;
var
  i: Integer;
  APicture, ATarget, Msg: String;
begin
  Result := False;
  AName := Trim(AName);
  if AName = '' then
    Exit;
  if AName = AOldName then
    Exit;
  if Length(AName) > 128 then begin
    MessageDlg('You can only use up to 128 characters.',mtError,[mbOK],0);
      Exit;
  end;
  for i := 1 to Length(AName) do
    if not (((ANAme[i] >= 'a') and (ANAme[i] <= 'z')) or
            ((ANAme[i] >= 'A') and (ANAme[i] <= 'Z')) or
            ((ANAme[i] >= '0') and (ANAme[i] <= '9')) or
            (ANAme[i] = ' ')) then begin
      MessageDlg('A target name can only contain letters, numbers or spaces.',mtError,[mbOK],0);
      Exit;
    end;
  for i := 0 to FHyperImages.HotspotsDef.Count - 1 do begin
    FHyperImages.ExtractPictureAndTarget(FHyperImages.HotspotsDef.Strings[i],
    APicture, ATarget);
    if APicture = APictureFileName then
      if (CompareText(ATarget, AName) = 0) and
      (CompareText(AOldName, AName) <> 0) then begin
        if ATarget = AName then
          Msg := Format('There is already a hotspot named %s for picture %s.'#13 +
          'Do you want to add one?', [AName, APicture]) else
          Msg := Format('There is a hotspot named %s for picture %s.'#13 +
          'This may cause the explorer tree not to be sorted correctly.'#13 +
          'Do you want add %s anyway?', [ATarget, APicture, AName]);
        if MessageDlg(Msg, MtConfirmation, [mbYes, mbNo], 0) <> mrYes then
          Exit;
      end;
  end;
  Result := True;
end;

procedure THSEditForm.HotspotNewClick(Sender: TObject);
begin
  Initfornewpoly(false);
  Statusbar.panels[3].Text := 'Drawing New Hotspot. Press Esc to cancel.';
end;

procedure THSEditForm.ViewShowExplorerClick(Sender: TObject);
 var W: TWindowPlacement;
begin
  W.length := sizeof(TWindowPlacement);
  GetWindowPlacement(Handle, @W);
  if ViewShowExplorer.Checked then begin
    ExplorerPanel.Width := 0;
    VerticalSplitter.Width := 0;
    W.rcNormalPosition.Right := Max(MinWidth, W.rcNormalPosition.Right
    - ExplorerWidth - SplitterWidth);
    SetWindowPlacement(Handle, @W) ;
  end else begin
    ExplorerPanel.Width := ExplorerWidth;
    VerticalSplitter.Width := SplitterWidth ;
    W.rcNormalPosition.Right := Min(Screen.Width, W.rcNormalPosition.Right
    + ExplorerWidth + SplitterWidth);
    SetWindowPlacement(Handle, @W) ;
  end;
  ViewShowExplorer.Checked := not ViewShowExplorer.Checked;
  Invalidate;
end;

procedure THSEditForm.SaveHotspot;
  procedure SaveToTree;
  var S, LineTemp: String;
      v, ImageIndex: Integer;
  ImageNode, TargetNode: TTreeNode;
  begin
    S := '';
    with TheHotSpot, DisplayTree.Items do begin //find the Image
      ImageIndex := ImageIndexInTree(FHyperImages.PictureFileName, DisplayTree, True);
      if ImageIndex = -1 then begin
        ImageNode := AddChild(Item[0], FHyperImages.PictureFileName);
        SetNodeImageIndex(ImageNode, 1);
        Item[0].CustomSort(@CustomSortProc, 0);
      end else
        ImageNode := DisplayTree.Items[ImageIndex];
      TargetNode := AddChild(ImageNode, Target);
      ImageNode.CustomSort(@CustomSortProc, 1);
      SetNodeImageIndex(TargetNode, 2);
      UpdateTreeGroupBoxCaption;
      RefreshTree;
      DisplayTree.Selected := TargetNode ;
    end;
  end;
var
  Temp : string;
  Accepted, Validated: Boolean;
begin
  Accepted := False;
  Validated := False;
  if TheHotspot.Target = '' then begin
    While not (Accepted and Validated) do begin
      Accepted := InputQuery('Enter Target',
                  'Enter a Target string of up to 128 characters:', Temp);
      if Accepted then
        Validated := ValidateTargetName(Temp, '', PictureFileName);
      if not Accepted then
        if Messagedlg('Cancel edition of this hotspot?',mtConfirmation,
        [mbYes,mbNo], 0) = mrYes then begin
          Accepted := True;
          Validated := True;
          Exit;
        end;
    end;
    TheHotspot.Target := Temp;
  end;
      CreateHotspotRegion(TheHotspot, TheRegion);
      SaveHotSpotToStringList(TheHotspot,
      FHyperImages.Hotspotsdef, TheRegion);
      RefreshRegionsList(FHyperImages.HotspotsDef);
      SaveToTree;
      Modified := True;
end;

Function THSEditForm.SaveHotSpotToStringList(Hotspot: THotspot;
                                  StringList: TStringList; RGN:HRGN): Integer;
var S: String;
    i: Integer;
begin
  S := '';
  with HotSpot, StringList do begin
    case FigureType of
      ftPolygon: begin
        if Vertexcount > 2 then begin
          for i := 1 to Vertexcount do
            S := S + IntToStr(Vertices[i].x) + ',' + IntToStr(Vertices[i].y) + ';';
          if FigureType <> ftPolygon then
            VertexCount := -ord(FigureType);
          S := FHyperImages.PictureFileName + '/' + Target + '=' + IntToStr(Vertexcount) + ';' + S;
        end;
      end;
      ftRoundRectangle: begin
        S := IntToStr(Vertices[1].x) + ',' +  IntToStr(Vertices[1].y) + ';' +
             IntToStr(Vertices[3].x) + ',' +  IntToStr(Vertices[3].y) + ';' +
             IntToStr(Vertices[5].X) + ',' + IntToStr(Vertices[5].Y) + ';';
        S := FHyperImages.PictureFileName + '/' + Target + '=' + IntToStr(- Ord(FigureType)) + ';' + S;
      end;
      ftRectangle, ftEllipse: begin
        S := IntToStr(Vertices[1].x) + ',' +  IntToStr(Vertices[1].y) + ';' +
             IntToStr(Vertices[3].x) + ',' +  IntToStr(Vertices[3].y) + ';';
        S := FHyperImages.PictureFileName + '/' + Target + '=' + IntToStr(- Ord(FigureType)) + ';' + S;
      end;
    end;
    try
      Result := AddObject(S, Pointer(RGN));
    except
      on EStringListError do begin
        DeleteRegion(RGN);
        MessageDlg('Not Hotspot was added', mtError, [mbOk], 0);
        Raise;
      end;
    end;
  end;
end;

function THSEditForm.DeleteSelectedHotspot: Boolean;
var
  Index: Integer;
begin
  Result := False;
  if DisplayTree.Selected = Nil then
    Exit;
  Index := NodeToHotspotDefIndex(DisplayTree.Selected);
  if Index <> -1 then begin
    FHyperImages.HotspotsDef.Delete(Index);
    RefreshRegionsList(FHyperImages.HotspotsDef);
    if DisplayTree.Selected.Parent.ImageIndex = 3 then begin
      DrawFigure(TheHotspot);
      DestroyFigureHandles;
      DeleteRegion(TheRegion);
      Clearhotspot(TheHotspot);
    end;
    DisplayTree.Selected.Delete;
    DisplayTree.Selected := Nil;
    Modified := True;
    Result := True;
  end;
end;

procedure THSEditForm.HotspotDefineClick(Sender: TObject);
begin
  if TheHotspot.Target = '' then
    HotspotNewClick(Self)
  else begin
    { Same as ...NewClick, but we don't disable
      deletion like ...NewClick does.  This allows
      you to delete an edited hotspot while rubber-
      banding a revision. }
    Initfornewpoly(True);
    Modified := True;
    Statusbar.panels[3].Text := 'Redefining: '+TheHotspot.Target;
  end;
end;


procedure THSEditForm.HotspotShowAllClick(Sender: TObject);
begin
  HotspotShowAll.Checked := not HotspotShowAll.Checked;
  BtnShowAll.Down := HotspotShowAll.Checked;
  PaintBox1.Invalidate;
end;

procedure THSEditForm.FileMenuClick(Sender: TObject);
begin
  FileCopyCode.Enabled := (FHyperImages.HotspotsDef.Count > 0) and
  not DrawingFigure;
  FileSave.Enabled := not DrawingFigure;
  ViewShowToolbar.Enabled := not DrawingFigure;
  ViewShowStatusbar.Enabled := not DrawingFigure;
  FileReport.Enabled := (FHyperImages.HotspotsDef.Count > 0) and
  not DrawingFigure;
  FileClearPicture.Enabled := TheImage <> Nil;
  FileSave.Enabled := FModified;
  SaveToFile.Enabled := FileReport.Enabled;
  HTMLMap1.Enabled := SaveToFile.Enabled;
end;

procedure THSEditForm.ViewMenuClick(Sender: TObject);
begin
  ViewZoomIn.Enabled := TheImage <> Nil;
  ViewZoomOut.Enabled := TheImage <> Nil;
  ViewZoom100.Enabled := TheImage <> Nil;
end;

procedure THSEditForm.HotspotMenuClick(Sender: TObject);
begin
  HotspotDelete.Enabled := TheRegion <> 0;
  HotspotDefine.Enabled := TheRegion <> 0;
  HotspotNew.Enabled := not DrawingFigure and (TheImage <> Nil);
  HotspotShowAll .Enabled := not DrawingFigure and (TheImage <> Nil);
  HotspotRename.Enabled := TheRegion <> 0;
  FileReport.Enabled := (FHyperImages.HotspotsDef.Count > 0) and
  not DrawingFigure;
  RemoveAllImages.Enabled := FileReport.Enabled;
  if DisplayTree.Selected <> Nil then begin
    HotspotRemoveImage.Enabled := (DisplayTree.Selected.ImageIndex in [1,3]);
    LoadSelectedImage.Enabled := DisplayTree.Selected.ImageIndex = 1;
  end else begin
     HotspotRemoveImage.Enabled := False;
     LoadSelectedImage.Enabled := False;
  end;
end;

procedure THSEditForm.FormPopupMenuPopup(Sender: TObject);
begin
  if DrawingFigure then
    Abort;
  if ExplorerPanel.Width = 0 then
    PopupExplore.Caption := 'Show &Explorer' else
    PopupExplore.Caption := 'Hide &Explorer';
  PopupDelete.Enabled := (TheRegion <> 0) and (TheImage <> Nil);
  PopupDefine.Enabled := (TheRegion <> 0) and (TheImage <> Nil);
  PopupNew.Enabled :=  TheImage <> Nil;
  PopupClearPicture.Enabled := TheImage <> Nil;
  PopupZoomIn.Enabled := TheImage <> Nil;
  PopupZoomOut.Enabled := TheImage <> Nil;
  PopupZoom100.Enabled := TheImage <> Nil;
end;

procedure THSEditForm.HotspotDeleteClick(Sender: TObject);
begin
  if (DisplayTree.Selected =  Nil) or (DisplayTree.Selected.ImageIndex <> 2) then
    Exit;
  if  MessageDlg(
   'Delete the hotspot: ' + DisplayTree.Selected.Text +'?',
    mtWarning, [mbYes,mbNo], 0) <> mrYes then
      Exit;
  DeleteSelectedHotspot;
end;

procedure THSEditForm.FileCancelClick(Sender: TObject);
begin
  OKToClose := True;
  Close;
end;

procedure THSEditForm.FormDestroy(Sender: TObject);
begin
  FHyperImages.DestroyAllRegions(FHyperImages.HotspotsDef, FHyperImages.RegionsList);
  Application.OnHint := SavedHintPointer;
  TheImage.Free;
  TheImage := Nil;
  DestroyFigureHandles;
  FHandlesRegionsList.Free;
  FHandlesRegionsList := Nil;
  FHyperImages.Free;
  RoundRectOptionsForm.Free;
  RoundRectOptionsForm := Nil;
 end;

procedure THSEditForm.FileSaveClick(Sender: TObject);
begin
  OKToClose := True;
  ModalResult := mrOK;
end;

procedure THSEditForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if FSaveToComponent then begin
    if (not OKToClose) and Modified then
      case MessageDlg('Do you want to save changes to ' + FHyperImages.Name + '?',
      mtConfirmation, [mbYes, mbNo, mbCancel], 0)  of
          mrYes : FileSaveClick(Self);
          mrCancel : CanClose := False;
        end;
  end else begin
    if (not OKToClose) and Modified then
      if MessageDlg('Changes have been made and not saved. Exit anyway?',
      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        CanClose := False;
  end;
end;

procedure THSEditForm.HelpContentsClick(Sender: TObject);
var
  P: PChar;
begin
  P := 'Editor';
  if DesignMode then
    WinHelp (Handle, 'HyperImages.Hlp', HELP_KEY , Integer(P)) else
    WinHelp (Handle, 'Editor.Hlp', HELP_KEY , Integer(P));
end;

procedure THSEditForm.Register1Click(Sender: TObject);
var
  P: PChar;
begin
  P := 'Register THyperImages';
  WinHelp (Handle, 'HyperImages.Hlp', HELP_KEY	, Integer(P));
end;

procedure THSEditForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var S: String;
    R: TRect;
begin
  R := Rect;
  if Panel = Statusbar.Panels[0] then begin
    if PicturesDir = '' then
      S := 'No Pictures Directoy' else
      S := FHyperImages.PicturesDir;
  end;
    DrawTextEx(Statusbar.Canvas.Handle, PChar(S), -1, R,
               DT_SINGLELINE or DT_LEFT or DT_PATH_ELLIPSIS or DT_VCENTER, Nil);
end;

procedure THSEditForm.CheckForPicturesDir;
begin
  if (PicturesDir = '') then begin
    if MessageDlg(Format('You did not specify a Pictures Directory.'#13+
    'Do you want to assign this path to the pictures directory?'#13'%s', [TempPicturesDir]),
    mtConfirmation, [mbYes,mbNo], 0) <> mrYes then
      Abort else
      PicturesDir := TempPicturesDir;
   end;
end;

procedure THSEditForm.LoadHyperImages(AFilename: String);
begin
  if not FileExists(AFilename) then
    CheckForPicturesDir;
  TheImage.Free;
  TheImage := Nil;
  FHyperImages.DestroyAllRegions(FHyperImages.HotspotsDef, FHyperImages.RegionsList);
  DestroyFigureHandles;
  TheImage := TImage.Create(Self);
  with TheImage do begin
    AutoSize := True;
    Picture.LoadFromFile(AFilename);
    PaintBox1.ClientWidth := Width;
    PaintBox1.ClientHeight := Height;
    ScaleFormToImage(TheImage, False);
  end;
  PictureFileName := ExtractFileName(AFilename);
  with FHyperImages do CreateAllRegions(HotspotsDef, RegionsList, PictureFileName);
  DisplayTree.Selected := Nil;
  ClearHotspot(TheHotSpot);
  Zoom := 100;
  UpdateButtonsState;
  if FSaveToComponent then
    Modified := True;
end;

procedure THSEditForm.FileLoadPictureClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then begin
    LoadHyperImages(OpenPictureDialog.Filename);
    TempPicturesDir := ExtractFilePath(OpenPictureDialog.FileName);
  end;
end;

procedure THSEditForm.FormShow(Sender: TObject);
begin
  if TheImage <> Nil then
    ScaleFormToImage(TheImage, True);
  SetNodeImageIndex(DisplayTree.Items.AddFirst(Nil, FHyperImages.Name), 0);
  PictureFileName := FHyperImages.PictureFileName;
  ProgressForm := CreateProgressForm('Loading Hotspots...');
  Register1.Visible := DesignMode;
  N5.Visible := DesignMode;
  FileCopyCode.Visible := DesignMode;
  N2.Visible := DesignMode;
  BtnSave.Visible := FSaveToComponent;
  BtnCancel.Visible := FSaveToComponent;
  if not FSaveToComponent then begin
    BtnSave.Width := 0;
    BtnCancel.Width := 0;
  end;
  N1.Visible := FSaveToComponent;
  FileSave.Visible := FSaveToComponent;
  FileCancel.Visible := FSaveToComponent;
  with ProgressForm do
  try
    Show;
    FillDisplay;
  finally
    Free;
  end;
  UpdateButtonsState;
end;

procedure THSEditForm.FileSetPicturesDirectoryClick(Sender: TObject);
var Directory: String;
    AHandle: HWnd;
begin
  AHandle := Self.Handle;
  if FHyperImages.PicturesDir <> '' then
    BrowseDialogInitialDir := PathWithoutBackSlash(FHyperImages.PicturesDir) else
    BrowseDialogInitialDir := PathWithoutBackSlash(
    ExtractFilePath(OpenPictureDialog.FileName));
  Directory := BrowseForDir(AHandle, BrowseDialogInitialDir, BrowseDialogCaption,
                            BrowseDialogPrompt);
  if Directory <> '' then begin
    if Directory[Length(Directory)] <> '\' then
      Directory := Directory + '\';
    PicturesDir := Directory ;
    OpenPictureDialog.InitialDir := PicturesDir;
    Modified := True;
  end;
end;


procedure THSEditForm.VerticalSplitterMoved(Sender: TObject);
begin
  ScaleFormToImage(TheImage, False);
end;

procedure THSEditForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) then
    if DrawingFigure then begin
      HaveNewPoly(True);
      if DisplayTree.Selected <> Nil then
        DisplayTree.Selected := Nil else
        DisplayTreeChange(Self, Nil);
      //SelectedIndex := -1;
    end;
    Key := 0;
end;
///////////////////////////////////////////////////////////////////
///////////////////////Tree Management/////////////////////////////
////////////////////// ////////////////////////////////////////////


procedure THSEditForm.SetCoordinatesCaption(const Hotspot: THotspot);
begin
  case Hotspot.FigureType of
    ftPolygon:
      CoordinatesGroupBox.Caption := 'Polygon ' + IntToStr(Hotspot.VertexCount) + ' Vertices';
    ftRectangle:  CoordinatesGroupBox.Caption := 'Rectangle';
    ftEllipse: CoordinatesGroupBox.Caption := 'Ellipse';
    ftRoundRectangle: CoordinatesGroupBox.Caption := 'Rounded Rectangle';
  end;
end;

procedure THSEditForm.FillCoordinates(const Hotspot: THotspot);
var Count: Integer;
begin
  Coordinates.Items.Clear;
      for Count := 1 to Hotspot.VertexCount do
        with Coordinates.Items.Add, Hotspot do begin
          Caption := IntToStr(Vertices[Count].X);
          Subitems.Add(IntToStr(Vertices[Count].Y));
        end;
end;

procedure THSEditForm.DisplayTreeChange(Sender: TObject; Node: TTreeNode);
var
  i, HotspotDefIndex: Integer;
  Hotspot: THotspot;
  CurPic: String;
  RGNPointer: Pointer;

begin
  if (not FLoadingTree) and (not FClosed) then begin
    Coordinates.Visible := False;
    Coordinates.Items.Clear;
    CoordinatesGroupBox.Caption := '';
    if Node = Nil then begin
      SelectedIndex := -1;
      Exit;
    end;
    if Node.ImageIndex = 2 then begin
      HotspotDefIndex := NodeToHotspotDefIndex(Node);
      FHyperImages.LoadHotspotFromLineDef(FHyperImages.HotspotsDef[HotspotDefIndex],
      CurPic, Hotspot, True);
      FillCoordinates(Hotspot);
      //Select the hotspot in editor only if loaded picture
      if Node.Parent.ImageIndex = 3 then begin
        RGNPointer := FHyperImages.HotspotsDef.Objects[HotspotDefIndex];
        if RGNPointer <> Nil then begin
          if Not DrawingFigure then
            HSEditForm.SelectedIndex :=
            FHyperImages.RegionsList.IndexOf(IntToStr(Integer(RGNPointer)))
        end else
          if not DrawingFigure then
            HSEditForm.SelectedIndex := -1;
        DisplayTree.ReadOnly := False;
      end else begin
        if not DrawingFigure then begin
        HSEditForm.SelectedIndex := -1;
        end;
      end;
      SetCoordinatesCaption(Hotspot);
    end else begin
      if Not DrawingFigure then begin
        HSEditForm.SelectedIndex := -1;
      end;
      DisplayTree.ReadOnly := True;
    end;
    Coordinates.Visible := True;
  end;
end;

procedure THSEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FClosed := True;
end;

procedure THSEditForm.DisplayTreeMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Pt: TPoint;
begin
  if DrawingFigure then
    Abort;
  Pt := DisplayTree.ClientToScreen(Point(X, Y));
  if (Button = mbRight) and (Shift = []) then begin
    if DisplayTree.GetNodeAt(X, Y) = Nil then
      Exit;
    DisplayTree.Selected := DisplayTree.GetNodeAt(X, Y);
      if DisplayTree.Selected <> Nil then begin
        if DisplayTree.Selected.ImageIndex = 2 then
          TreeHotspotPopupMenu.Popup(Pt.X, Pt.Y)
        else
        if DisplayTree.Selected.ImageIndex in [1,3] then begin
          TreePopupLoad.Enabled := DisplayTree.Selected.ImageIndex =1;
          TreeImagePopupMenu.Popup(Pt.X, Pt.Y);
        end else
        if DisplayTree.Selected.ImageIndex = 0 then begin
          TreePopupSaveReport.Enabled := FHyperImages.Hotspotsdef.Count > 0;
          TreePopupPrintReport.Enabled := TreePopupSaveReport.Enabled;
          RemoveAllImages1.Enabled := TreePopupSaveReport.Enabled;
          TreeHyperImagesPopupMenu.Popup(Pt.X, Pt.Y);
        end;
      end;
  end;
end;

procedure THSEditForm.HelpAboutClick(Sender: TObject);
begin
  ShowAbout;
end;

procedure THSEditForm.DisplayTreeDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  if not FClosed then
    UpdateTreeGroupBoxCaption;
end;

procedure THSEditForm.DisplayTreeEdited(Sender: TObject; Node: TTreeNode;
  var S: String);
var
   TheString, ThePicture, TheName: String;
   i: Integer;
begin
  if DisplayTree.Selected =  Nil then Exit;
  if DisplayTree.Selected.ImageIndex <> 2 then Exit;
  if Node.Parent = Nil then Exit;
  if not ValidateTargetName(S, Node.Text, Node.Parent.Text) then begin
    S := Node.Text;
    Exit;
  end;
  i := NodeToHotspotDefIndex(DisplayTree.Selected);
  TheString := FHyperImages.HotspotsDef.Strings[i];
  FHyperImages.ExtractPictureAndTarget(TheString, ThePicture, TheName);
  Delete(TheString, 1, Length(ThePicture)+ Length(TheName) + 1);
  FHyperImages.HotspotsDef.Delete(i);
  TheHotspot.Target := S;
  i := FHyperImages.HotspotsDef.AddObject(ThePicture + '/' + S + TheString, Pointer(TheRegion));
  RefreshRegionsList(FHyperImages.HotspotsDef);
  Node.Text := S;
  if Node.Parent <> Nil then
  Node.Parent.CustomSort(@CustomSortProc, 1);
  DisplayTreeChange(Self, Node);
  HSEditForm.Modified := True;
end;

procedure THSEditForm.TreePopupLoadClick(Sender: TObject);
begin
  if (DisplayTree.Selected.ImageIndex <> 1) then
    Exit;
  LoadHyperImages(PicturesDir + DisplayTree.Selected.Text);
  PaintBox1.Invalidate;
end;

procedure THSEditForm.DisplayTreeDblClick(Sender: TObject);
begin
  if DisplayTree.Selected.ImageIndex = 1 then
    TreePopupLoadClick(Self);
end;

procedure THSEditForm.GenerateMapSnippet(MapSnippet: TStringList;SingleImage: Boolean);
var
  AHotspot: THotspot;
  APicture, PrevPic, PictureStr, HotspotsStr, FigureStr, S, CoordStr: String;
  i, j: Integer;
  Center: TPoint;
begin
  with HSEditForm.FHyperImages.HotspotsDef, AHotspot do begin
    for i := 0 to Count -1 do begin
      S := Strings[i];
      FHyperImages.LoadHotspotFromLineDef(S, APicture, AHotspot, True);
      if SingleImage and (APicture <> PictureFileName) then
        Continue;
      if PrevPic <> APicture then begin
        if MapSnippet.Count > 0 then begin //add end of last map and blank line
          MapSnippet.Add('</MAP>');
          MapSnippet.Add('');
        end;
        MapSnippet.Add(Format('<MAP NAME="%s"><!--to activate click on a hotspot Replace NOHREF by HREF="your link"-->', [ChangeFileExt(APicture, '')]));
      end;
      PrevPic := APicture;
      case FigureType of
        FtPolygon: FigureStr := 'POLY';
        FtRectangle : FigureStr := 'RECT';
        FtRoundRectangle : Raise Exception.Create
        ('Round Rectangles are not currently supported in image maps');
        FtEllipse : begin
          if (Vertices[2].X - Vertices[1].X) <> (Vertices[4].Y - Vertices[1].Y) then
            Raise Exception.Create(Format(
            'Invalid ellipse (%s). Only circles are currently supported in image maps',
            [Target]));
          FigureStr := 'CIRCLE';
        end;
      end;
      System.Delete(S, 1,
      Length(APicture) + Length(Target) + Length(IntToStr(VertexCount)) + 3);
      if FigureType <> ftPolygon then
        System.Delete(S, 1, 1);
      if FigureType= ftEllipse then begin  //coordStr = center.x, center.y, radius
        Center.X := Vertices[1].X + ((Vertices[2].X - Vertices[1].X) div 2);
        Center.Y := Vertices[1].Y + ((Vertices[4].Y - Vertices[1].Y) div 2);
        CoordStr := Format('%d,%d,%d', [Center.X, Center.Y, (Vertices[2].X - Vertices[1].X) div 2]);
      end else begin
        j:= Pos(';', S);
        while j <> 0 do begin
          S[j] := ',';
          j:= Pos(';', S);
        end;
        System.Delete(S, Length(S), 1);
        CoordStr := S;
      end;
      MapSnippet.Add(Format('<AREA TITLE="%s" SHAPE="%s" COORDS="%s" NOHREF >',
      [Target, FigureStr, CoordStr]));
    end;
    MapSnippet.Add('</MAP>');
  end;
end;

procedure THSEditForm.SavetoHTMLFile1Click(Sender: TObject);
var
  SnippetSL, FileSL: TStringList;
begin
  with SaveDialog1 do begin
    Filter := 'HTML Files (*.htm,*.html)|*.htm;*.html|All Files (*.*)|*.*';
    DefaultExt := 'htm';
    if Execute then
      if FileName <> '' then begin
        FileSL := TStringList.Create;
        try
          FileSL.Add('<HTML>');
          FileSL.Add('<HEAD>');
          FileSL.Add('  <TITLE>Image Map</TITLE>');
          FileSL.Add('</HEAD>');
          FileSL.Add('<BODY>');
          SnippetSL := TStringList.Create;
          try
            GenerateMapSnippet(SnippetSL, False);
            FileSL.AddStrings(SnippetSL);
          finally
            SnippetSL.Free;
          end;
          FileSL.Add('</BODY>');
          FileSL.Add('</HTML>');
          FileSL.SaveToFile(FileName);
        finally
          FileSL.Free;
          end;
      end;
  end;
end;

procedure THSEditForm.HTMLMap1Click(Sender: TObject);
begin
  CopyImageandMapTagSnippet1.Enabled :=
  (UpperCase(ExtractFileExt(PictureFileName)) = '.GIF') or
  (UpperCase(ExtractFileExt(PictureFileName)) = '.JPG') or
  (UpperCase(ExtractFileExt(PictureFileName)) = '.JPEG');
end;

procedure THSEditForm.CopyTagSnippet1Click(Sender: TObject);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  with SL do
    try
      GenerateMapSnippet(SL, False);
      Clipboard.AsText := SL.Text;
      MessageDlg('The tag snippet has been copied to the clipboard.', mtInformation, [mbOK], 0);
    Finally
      Free;
    end;
end;

procedure THSEditForm.CopyImageandMapTagSnippet1Click(Sender: TObject);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  with SL do
    try
      GenerateMapSnippet(SL, True);
      Sl.Insert(0, Format('<IMG SRC="%s" BORDER=0 ALT="%s" USEMAP="#%s">', [PictureFileName,
      PictureFileName, ChangeFileExt(PictureFileName, '')]));
      Clipboard.AsText := SL.Text;
      MessageDlg('The tag snippet has been copied to the clipboard.', mtInformation, [mbOK], 0);
    Finally
      Free;
    end;
end;

procedure THSEditForm.MakeReport(AFileName: String);
var
  PrintText: TextFile;
  AHotspot: THotspot;
  APicture, PrevPic, PictureStr, HotspotsStr, S: String;
  PicturesCount, i: Integer;
begin
  if AFileName = '' then
    AssignPrn(PrintText) else
    AssignFile(PrintText, AFileName);
  Rewrite(PrintText);
  try
    with HSEditForm.FHyperImages.HotspotsDef, AHotspot do begin
      PicturesCount := 0;
      PrevPic := '';
      for i := 0 to Count - 1 do begin
       APicture := FHyperImages.ExtractPicture(Strings[i]);
       if APicture <> PrevPic then
         Inc(PicturesCount);
       PrevPic := APicture;
      end;
      if PicturesCount > 1 then
        PictureStr := 'Pictures' else
        PictureStr := 'Picture';
      if Count > 1 then
        HotspotsStr := 'Hotspots' else
        HotspotsStr := 'Hotspot';
      Writeln(PrintText);
      Writeln(PrintText);
      Write(PrintText, FHyperImages.Name);
      Write(PrintText, '                                ');
      Writeln(PrintText, FormatDateTime(ShortDateFormat, Date));
      Writeln(PrintText);
      Writeln(PrintText, '     ' + IntToStr(PicturesCount) + '  ' + PictureStr);
      Writeln(PrintText, '     ' + IntToStr(Count) + '  ' + HotspotsStr);
      Writeln(PrintText, '');
      PrevPic := '';
      for i := 0 to Count -1 do begin
        S := Strings[i];
        FHyperImages.LoadHotspotFromLineDef(S, APicture, AHotspot, False);
        if PrevPic <> APicture then begin
          Writeln(PrintText);
          Writeln(PrintText, 'Picture: ' + APicture);
        end;
        PrevPic := APicture;
        case FigureType of
          FtPolygon: Writeln(PrintText, '     Polygon: ' + Target +
                     ' (' + IntToStr(VertexCount) + ' Vertices)');
          FtRectangle : Writeln(PrintText, 'Rectangle ' + Target);
          FtRoundRectangle : Writeln(PrintText, 'Rounded Rectangle ' + Target);
          FtEllipse : Writeln(PrintText, 'Ellipse ' + Target);
        end;
        System.Delete(S, 1,
        Length(APicture) + Length(Target) + Length(IntToStr(VertexCount)) + 3);
        if FigureType <> ftPolygon then
          System.Delete(S, 1, 1);
        Writeln(PrintText, '          ' + S);
        ProgressBar.Position := 100 * i div FHyperImages.HotspotsDef.Count - 1;
        Application.ProcessMessages;
        if AFileName = '' then
          if ProgressForm.ModalResult = mrAbort then
            Abort;
      end;
    end;
  finally
    CloseFile(PrintText);
  end;
end;

procedure THSEditForm.FileReportPrintClick(Sender: TObject);
begin
ProgressForm := CreateProgressForm('Printing Hotspots of ' + FHyperImages.Name + '...');
  with ProgressForm do
  try
    Show;
    MakeReport('');
  finally
    Free;
  end;
end;

procedure THSEditForm.FileReportSaveToFileClick(Sender: TObject);
begin
  with SaveDialog1 do begin
    Filter := 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
    DefaultExt := 'txt';
    if Execute then
      if FileName <> '' then
        MakeReport(FileName);
  end;
end;

procedure THSEditForm.SaveToFileClick(Sender: TObject);
begin
  CheckForPicturesDir;
  with SaveDialog1 do begin
    Filter := Format('Hotspots Files (*%s)|*%s', [HotspotsFileExt,HotspotsFileExt]);
    DefaultExt := Copy(HotspotsFileExt, 2, Length(HotspotsFileExt) - 1);
    if Execute then
      FHyperImages.SaveToFile(FileName);
  end;
  if not DesignMode then
    Modified := False;
end;

procedure THSEditForm.LoadFromFileClick(Sender: TObject);
begin
  if FModified and (FHyperImages.HotspotsDef.Count > 0) then
    if MessageDlg('Loading a hotspots file will overwrite current hotspots definition.'#13+
    'Do you want to proceed?',mtConfirmation,[mbYes,mbNo],0) <> mrYes then
      Abort;
  with OpenDialog1 do begin
    Filter := Format('Hotspots Files (*%s)|*%s', [HotspotsFileExt,HotspotsFileExt]);
    DefaultExt := Copy(HotspotsFileExt, 2, Length(HotspotsFileExt) - 1);
    if Execute then begin
    ProgressForm := CreateProgressForm('Loading Hotspots...');
      with ProgressForm do
      try
        Show;
        FHyperImages.LoadFromFile(FileName);
        PicturesDir := FHyperImages.PicturesDir;
        PictureFileName := FHyperImages.PictureFileName;
        TheImage.Free;
        TheImage := Nil;
        ClearHotspot(TheHotspot);
        DeleteRegion(TheRegion);
        DisplayTree.Items.Clear;
        SetNodeImageIndex(DisplayTree.Items.AddFirst(Nil, FHyperImages.Name), 0);
        FillDisplay;
        Modified := True;
        UpdateTreeGroupBoxCaption;
        PaintBox1.Invalidate;
      finally
        Free;
      end;
    end;
  end;
end;

procedure THSEditForm.HotspotRenameClick(Sender: TObject);
begin
  if (DisplayTree.Selected =  Nil) or (DisplayTree.Selected.ImageIndex <> 2)then
    Exit;
  DisplayTree.Selected.EditText;
end;


procedure THSEditForm.RemoveAllImagesClick(Sender: TObject);
begin
  if MessageDlg('Delete all Hotspots and all Pictures?',
  mtConfirmation,[mbYes,mbNo],0) <> mrYes then
    Exit;
  DisplayTree.Selected := DisplayTree.Items[0];
  with FHyperImages do begin
    DestroyAllRegions(HotspotsDef, RegionsList);
    HotspotsDef.Clear;
  end;
  TheImage.Free;
  TheImage := Nil;
  PaintBox1.Invalidate;
  ClearHotspot(TheHotspot);
  DisplayTree.Items.Clear;
  SetNodeImageIndex(DisplayTree.Items.AddFirst(Nil, FHyperImages.Name), 0);
  PictureFileName := '';
  Modified := True;
end;

procedure THSEditForm.HotspotRemoveImageClick(Sender: TObject);
var
  Pic: String;
  PicNode: TTreeNode;

  function PictureHasHotspots(APicture: String): Boolean;
  var
    HotspotNode: TTreeNode;
  begin
    Result := False;
    HotspotNode := PicNode.GetFirstChild;
    if HotspotNode <> Nil then begin
      DisplayTree.Selected := HotspotNode;
      Result := True;
    end;
  end;

begin
  Pic := DisplayTree.Selected.Text;
  PicNode := DisplayTree.Selected;
  if MessageDlg('Delete all Hotspots of Picture: '
  + Pic + '?',mtConfirmation,[mbYes,mbNo],0) <> mrYes then
    Exit;
  While PictureHasHotspots(Pic) do
    DeleteSelectedHotspot;
  PicNode.Delete;
  if Pic = FHyperImages.PictureFileName then begin
    TheImage.Free;
    TheImage := Nil;
  end;
end;

procedure THSEditForm.FileClearPictureClick(Sender: TObject);
begin
  DisplayTree.Selected := Nil;
  TheRegion := 0;
  ClearHotspot(TheHotSpot);
  TheImage.Free;
  TheImage := Nil;
  PaintBox1.Invalidate;
  PictureFileName := '';
  Modified := True;
end;

procedure THSEditForm.SetZoom(Value: Integer);
var
  SavedIndex: Integer;
begin
  if Value <> FZoom then begin
    SavedIndex := SelectedIndex;
    SelectedIndex := -1;
    FZoom := Value;
    PaintBox1.ClientWidth := TheImage.Picture.Width * Zoom div 100;
    PaintBox1.ClientHeight := TheImage.Picture.Height * Zoom div 100;
    SetPictureFileName(PictureFileName);
    SelectedIndex := SavedIndex;
    PaintBox1.Invalidate;
  end;
end;

procedure THSEditForm.ViewZoomInClick(Sender: TObject);
begin
  if Zoom <= MaxZoom - 25 then
    Zoom := FZoom + 25;
end;

procedure THSEditForm.ViewZoomOutClick(Sender: TObject);
begin
  if Zoom >= MinZoom + 25 then
    Zoom := FZoom - 25;
end;

procedure THSEditForm.ViewZoom100Click(Sender: TObject);
begin
  Zoom := 100;
end;

procedure THSEditForm.BtnRoundRectDblClick(Sender: TObject);
var
  P: TPoint;
begin
  with RoundRectOptionsForm do begin
    Hide;
    P := Toolbar.ClientToScreen(Point(BtnRoundRect.Left, BtnRoundRect.Top));
    Left := Max(0, Min(Screen.Width - Width, P.X - (Width div 2)));
    Top := Max(0, Min(Screen.Height - Height, P.Y - (Height div 2)));
    Show;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Code Expert Stuff////////////////////////////
//////////////////////////////////////////////////////////////////////////////

procedure THSEditForm.GenerateCodeTemplate(CodeListing: TStringList);
var i: Integer;
    PictureSt, PrevPicSt, TargetSt: String;
begin
  if FHyperImages.HotspotsDef.Count <= 0 then
    Exit;
  i := 0;
with CodeListing do begin
Clear;
Add(
'var');
Add(
'  S: String;');
Add(
'begin');
Add(
'  with ' + FHyperImages.Name + ' do begin');
Add(
'    if PointIsOnTarget(X, Y, S) then begin');
  while i < FHyperImages.HotspotsDef.Count do begin
    FHyperImages.ExtractPictureAndTarget(FHyperImages.HotspotsDef.Strings[i] ,PictureSt, TargetSt);
    if PrevpicSt <> PictureSt then begin
      if i <> 0 then begin
Add(
'        end;');
Add(
'      end else');
      end;
Add(
'      if PictureFileName = ' + '''' + PictureSt + '''' + ' then begin');
    end;
    if PrevpicSt = PictureSt then
Add(
'        end else');
Add(
'        if S = ' + '''' + TargetSt  + '''' + ' then begin');
Add(
'          {Your code for Target: ' + TargetSt + '}');
    PrevpicSt := PictureSt;
    inc(i);
  end;
Add(
'        end;');
Add(
'      end;');
Add(
'    end else begin');
Add(
'      {Your code when no target is hit}');
Add(
'    end;');
Add(
'  end;');
Add(
'end;');
end;
end;

procedure THSEditForm.FileCodeCopyToClipboardClick(Sender: TObject);
var
  CodeListing: TStringlist;
begin
  CodeListing := TStringlist.Create;
  try
    GenerateCodeTemplate(CodeListing);
    Clipboard.SetTextBuf(PChar(CodeListing.Text));
    MessageDlg('The code template has been copied to the clipboard.' + #13 +
    'You can paste it as the OnImageMouseUp or OnImageMouseDown even of this control and ' +
    'complete it to get the desired action for each hopspot',mtInformation,[mbOK],0);
  finally
    CodeListing.Free;
  end;
end;

procedure THSEditForm.ScannerToken(Sender: TObject);
begin
  {$ifdef USEEXPERTS}
  with Scanner do begin
    if IsIdentifier(TheClass) then
      InTypeDec := True
    else if InTypeDec and (UpperCase(Token) = 'CLASS') then
      InClassDec:= True
    else if InClassDec and (not InTheClassDec) and (TokenType = ';') then
      InClassDec := False
    else if InClassDec and (not InTheClassDec) and (TokenType <> ';') then
      InTheClassDec:= True
    else if InTheClassDec and (
    (UpperCase(Token) = 'PRIVATE') or
    (UpperCase(Token) = 'PROTECTED') or
    (UpperCase(Token) = 'PUBLIC') or
    (UpperCase(Token) = 'PUBLISHED') or
    (UpperCase(Token) = 'AUTOMATED') or
    (UpperCase(Token) = 'END') or
    (UpperCase(Token) = 'USES') or
    (UpperCase(Token) = 'CONST') or
    (UpperCase(Token) = 'VAR') or
    (UpperCase(Token) = 'IMPLEMENTATION')
    ) then begin
     MethodDeclarationPos := Position;
     InTheClassDec:= False;
     InClassDec:= False;
     InTypeDec := False;
     end
     else if (UpperCase(Token) = 'END.') or (TokenType = '.') then
       MethodImplementationPos := Position;
  end;
  {$endif}
end;

procedure THSEditForm.FileCodeGenerateOnImageMouseDownClick(
  Sender: TObject);
begin
  {$ifdef USEEXPERTS}
  if Sender = FileCodeGenerateOnImageMouseDown then
    RunExpert(FHyperImages.Name, 'OnImageMouseDown') else
    RunExpert(FHyperImages.Name, 'OnImageMouseUp');
  {$endif}
end;
/////////////////////////////////////////////////////////////////////////
/////////////////Browse for folder functions/////////////////////////////
////////////////////////////////////////////////////////////////////////

{this callback function is called whenever an action takes
 place inside the browse for folder dialog box}
function BrowseCallback(hWnd: HWND; uMsg: UINT; lParam: LPARAM;
                        lpData: LPARAM): Integer;  export; stdcall;
var
  PathName: array[0..MAX_PATH] of Char;  // holds the path name
begin
  {if the selection in the browse for folder
   dialog box has changed...}
  case uMsg of
    BFFM_SELCHANGED :
    begin
      {...retrieve the path name from the item identifier list}
      SHGetPathFromIDList(PItemIDList(lParam), @PathName);

      {display this path name in the status line of the dialogf box}
      SendMessage(hWnd, BFFM_SETSTATUSTEXT, 0, Longint(PChar(@PathName)));

      Result := 0;
    end;
    BFFM_INITIALIZED :
    begin
      SetWindowtext(hWnd, PChar(BrowseDialogCaption));
      SendMessage(hWnd, BFFM_SETSELECTION, wParam(True), LongInt(PChar(BrowseDialogInitialDir)));
      Result := 0;
    end;
  end;
end;

function BrowseForDir(var CallerWnd: HWND; var
                      AInitialDir, ACaption, APrompt: String): String;
var
  IDList: PItemIDList;                     // an item identifier list

  BrowseInfo: TBrowseInfo;                 // the browse info structure
  PathName: array[0..MAX_PATH] of char;    // the path name
  DisplayName: array[0..MAX_PATH] of char; // the file display name
begin
  BrowseDialogInitialDir := AInitialDir;
  BrowseDialogCaption := ACaption;
  {initialize the browse information structure}
  BrowseInfo.hwndOwner      := CallerWnd;
  BrowseInfo.pidlRoot       := nil;
  BrowseInfo.pszDisplayName := DisplayName;
  BrowseInfo.lpszTitle      := PChar(APrompt);
  BrowseInfo.ulFlags        := BIF_STATUSTEXT or BIF_RETURNONLYFSDIRS;
  BrowseInfo.lpfn           := @BrowseCallback;
  BrowseInfo.lParam         := 0;

  {show the browse for folder dialog box}
  IDList := SHBrowseForFolder(BrowseInfo);
  if IdList = Nil then
    Result := ''
  else begin
  {retrieve the path from the item identifier list
   that was returned}
    SHGetPathFromIDList(IDList, @PathName);

  {display the pathname and display name of
   the selected folder}

    Result := PathName;
  end;
end;


end.
