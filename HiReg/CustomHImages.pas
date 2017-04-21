///////////////////////////////////////////////////////////////////////////////
//////////////////////////THyperImages Component V.2///////////////////////////
///////////////////Copyright © 1998-1999 Noatak Racing Team////////////////////
///////////////////////////////////////////////////////////////////////////////

unit CustomHImages;
{$INCLUDE HyperIm.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

Const
  ComponentVersion = '2.2.0';
   {$ifdef HI_D5} DelphiVersion = '5'; {$else}
     {$ifdef HI_D4} DelphiVersion = '4'; {$else}
       {$ifdef HI_D3} DelphiVersion = '3';
       {$endif}
     {$endif}
   {$endif}  
  BrowseDialogPrompt: String =  //Used to pass to the browse for folder callback
  'If you type it in the Object Inspector or set it programatically, a backslash will be added.';
  MaxVertexCount = 100;
  MaxPolygons = 10;
  HotspotsFileExt = '.hsf';

type  
  TName = string[128];
  TFigureType = (ftPolygon, ftRectangle, ftRoundRectangle, ftEllipse, ftPolyPolygon);
  //for rect, ellipse: 4 corners in vertices
  //for roundrect 4 corners and 1 more point for the round
  THotspot = record
              Target: TName;
              VertexCount: Integer;
              Vertices: array[1..MaxVertexCount] of Tpoint;
              case FigureType: TFigureType of
                ftPolyPolygon: (Polygons: array[1..MaxPolygons] of Integer;)
              end;

  TCustomHyperImages = class(TCustomPanel)
  private
    FImage: TImage;
    FHotspotsDef: TStringList; //Def of Hotspots FileName/Target=VertexCount;Vertices[].x,Vertices[].y;...
    FRegionsList: TStringList; //String: IntToStr of Region; Object: pointer to index in HotspotsDef
    FPictures: TStringList;    //List of the pictures at run time
    FScale: Integer;
    FAutoScaleImage: Boolean;
    FAutoScalePanel: Boolean;
    FHotCursor: TCursor;
    FInvertOnHot: Boolean;
    FHintOnHot: Boolean;
    FImageHint: String;
    FInvertedRgn: HRGN;
    FInvertedRgnIndex: Integer;
    FPicturesDir: String;
    FPictureFileName: String;
    FOnImageMouseDown: TMouseEvent;
    FOnImageMouseUp: TMouseEvent;
    FOnImageMouseMove: TMouseMoveEvent;
    FOnImageClick: TNotifyEvent;
    FOnImageDblClick: TNotifyEvent;
    FShowHotspots: Boolean;
    FHotspotsPen: TPen;
    FPaintBox: TPaintBox;
    procedure SetScale(Value: Integer);
    procedure SetAutoScaleImage(Value: Boolean);
    procedure SetAutoScalePanel(Value: Boolean);
    procedure SetHotCursor(Value: TCursor);
    procedure SetInvertOnHot(Value: Boolean);
    procedure SetHintOnHot(Value: Boolean);
    procedure SetImageHint(Value: String);
    procedure SetHotspotsDef(Value: TStringList);
    procedure SetRegionsList(Value: TStringList);
    procedure SetShowHotspots(Value: Boolean);
    procedure SetHotspotsPen(Value: TPen);
    function GetHotspotsCount: Integer;
    function CreatePictures: TStringList;
    procedure SetPicturesDir(Value: String);
    function GetPicture: TPicture;
    procedure SetPicture(Value: TPicture);
    procedure SetPictureFileName(Value: String);
    function  GetIncrementalDisplay: Boolean;
    procedure SetIncrementalDisplay(Value: Boolean);
    function GetImageCanvas: TCanvas;
    procedure ImageMouseDown(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseUp(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ImageClick(Sender: TObject);
    procedure ImageDblClick(Sender: TObject);
    procedure ImageChanged(Sender: TObject);
    procedure DrawPolygons;
    procedure HotspotsPenDoChange(Sender: TObject);
    function CreateHotspotRegion(AHotspot: THotspot): HRGN;
    procedure PaintBoxDoPaint(Sender: TObject);
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure CreateWnd; override;
    procedure ReCreateWnd;
    procedure Loaded; override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    property AutoScaleImage: Boolean read FAutoScaleImage write SetAutoScaleImage default False;
    property AutoScalePanel: Boolean read FAutoScalePanel write SetAutoScalePanel default False;
    property HotCursor: TCursor read FHotCursor write SetHotCursor default crDefault;
    property InvertOnHot: Boolean read FInvertOnHot write SetInvertOnHot default False;
    property HintOnHot: Boolean read FHintOnHot write SetHintOnHot default False;
    property HotspotsPen: TPen read FHotspotsPen write SetHotspotsPen ;
    property ImageHint: String read FImageHint write SetImageHint ;
    property IncrementalDisplay: Boolean read GetIncrementalDisplay write SetIncrementalDisplay;
    property Image: TImage read FImage write FImage;
    property PaintBox: TPaintBox read FPaintBox write FPaintBox;
    property HotspotsCount: Integer read GetHotspotsCount;
    property Pictures: TStringList read FPictures;
    property Scale: Integer read FScale write SetScale default 100;
    property ShowHotspots: Boolean read FShowHotspots write SetShowHotspots default False;
    property OnImageClick: TNotifyEvent read FOnImageClick write FOnImageClick;
    property OnImageDblClick: TNotifyEvent read FOnImageDblClick write FOnImageDblClick;
    property OnImageMouseDown: TMouseEvent read FOnImageMouseDown write FOnImageMouseDown;
    property OnImageMouseUp: TMouseEvent read FOnImageMouseUp write FOnImageMouseUp;
    property OnImageMouseMove: TMouseMoveEvent read FOnImageMouseMove write FOnImageMouseMove;
  public
    procedure CheckPictureFileExt(AFileName: String);
    procedure CreateAllRegions(AHotspotsDef, ARegionsList: TStringList;
                               APictureFileName: String);
    procedure DestroyAllRegions(AhotspotsDef, ARegionsList: TStringList);
    function ExtractPicture(S: String): String;
    procedure ExtractPictureAndTarget(S: String; var APicture, ATarget: String);
    procedure LoadHotspotFromLineDef(Line: String; var AFileName: String;
                               var Hotspot : tHotspot; LoadPoints: Boolean);
    procedure LoadImageFromFile(AFileName: String);
    procedure DeleteInverted;
    function PointIsOnTarget(X, Y: Integer; var ATarget: String): Boolean;
    function PointIsOnTargets(X, Y: Integer; var Targets: TStringList): Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(FileName: String);
    procedure SaveToFile(FileName: String);
    procedure InvertHotspot(Hotspot : String);
    function GetPosition(HS : String) : Tpoint;
    property HotspotsDef: TStringList read FHotspotsDef write SetHotspotsDef;
    property ImageCanvas: TCanvas read GetImageCanvas;
    property Picture: TPicture read GetPicture write SetPicture;
    property PictureFileName: String read FPictureFileName write SetPictureFileName;  
    property PicturesDir: String read FPicturesDir write SetPicturesDir;
    property RegionsList: TStringList read FRegionsList write SetRegionsList;
  end;



var
  TheHotspot   : tHotspot;
  TheRegion    : HRGN;
  TheImage     : TImage;
  BrowseDialogCaption: String = //Used to pass to the browse for folder callback
  'Select A Folder For The Pictures';
  Unregistered: Boolean;

function PathWithoutBackSlash(S: String): String;


implementation

uses stringfns;

function PathWithoutBackSlash(S: String): String;
begin
  Result := S;
  if S = '' then
    Exit;
  if Result[Length(Result)] = '\' then
    Delete(Result, Length(Result), 1);
end;


/////////////////////////////////////////////////////////////////////
///////////////////////////////TCustomHyperImages/////////////////////////////
/////////////////////////////////////////////////////////////////////

procedure TCustomHyperImages.ExtractPictureAndTarget(S: String; var APicture, ATarget: String);
var
  i: Integer;
begin
  APicture := '';
  ATarget := '';
  i := 1;
  while (S[i] <> '/') and (i <= Length(S)) do begin
    APicture :=  APicture + S[i];
    Inc(i);
  end;
  Inc(i);
   while (S[i] <> '=') and (i <= Length(S)) do begin
    ATarget :=  ATarget + S[i];
    Inc(i);
  end;
end;

function TCustomHyperImages.ExtractPicture(S: String): String;
var
  P: Integer;
begin
    Result := S;
    P := AnsiPos('/', Result);
    if P <> 0 then
      SetLength(Result, P-1) else
      SetLength(Result, 0);
end;

Constructor TCustomHyperImages.Create(AOwner: TComponent);
begin
  Unregistered := False;
  inherited Create(AOwner);
  Width := 105;
  Height := 105;
  FScale := 100;
  FAutoScaleImage := False;
  FAutoScalePanel := False;
  FHotCursor := crDefault;
  FInvertOnHot := False;
  FHintOnHot := False;
  FInvertedRgn := 0;
  FInvertedRgnIndex := -1;
  FPictureFileName := '';
  FImage := TImage.Create(Self);
  with FImage do begin
    Stretch := True;
    Center := True;
  end;
  FPaintBox := TPaintBox.Create(Self);
  FHotspotsPen := TPen.Create;
  with FPaintBox do begin
    Parent := Self;
    Left := 1;
    Top := 1;
    Width := 103;
    Height := 103;
    Visible := True;
  end;
  FHotspotsDef := TStringList.Create;
  FHotspotsDef.Sorted := True;
  FRegionsList := TStringList.Create;
  FPaintBox.OnMouseDown := ImageMouseDown;
  FPaintBox.OnMouseUp := ImageMouseUp;
  FPaintBox.OnMouseMove := ImageMouseMove;
  FPaintBox.OnClick := ImageClick;
  FPaintBox.OnDblClick := ImageDblClick;
  FPaintBox.OnPaint := PaintBoxDoPaint;
  FShowHotspots := False;
  FHotspotsPen.OnChange := HotspotsPenDoChange;
end;

Destructor TCustomHyperImages.Destroy;
begin
  if not (csDesigning in ComponentState) then
    DestroyAllRegions(FhotspotsDef, FRegionsList);
  FHotspotsDef.Free;
  FRegionsList.Free;
  FPictures.Free;
  FHotspotsPen.Free;
  inherited Destroy;
end;

procedure TCustomHyperImages.LoadFromFile(FileName: String);

var
  SG: TStringList;
  i : integer;
  PS : String;
begin
  SG := TStringList.Create;
  try
    if UpperCase(ExtractFileExt(FileName)) <> UpperCase(HotspotsFileExt) then
      Raise Exception.CreateFmt('The extention of hotspots files is %s.',
    [HotspotsFileExt]);
    SG.LoadFromFile(FileName);

{    PicturesDir := SG.Strings[0];
    SG.Delete(0); }
    FHotSpotsDef.Assign(SG);
    //DestroyAllRegions(FHotspotsDef, FRegionsList);
    PictureFileName := '';
  finally
    SG.Free;
  end;
end;


procedure TCustomHyperImages.SaveToFile(FileName: String);
var
  SG: TStringList;
begin
  if FHotspotsDef.Count = 0 then
    Raise Exception.Create('No hotspot has been defined.');
  if (PicturesDir = '') then
    Raise Exception.Create('You did not specify a Pictures Directory.');
  SG := TStringList.Create;
  try
    if ExtractFileExt(FileName) <> HotspotsFileExt then
      ChangeFileExt(FileName, HotspotsFileExt);
    SG.Assign(FHotSpotsDef);
    SG.Insert(0, FPicturesDir);
    SG.SaveToFile(FileName);
  finally
    SG.Free;
  end;
end;

procedure TCustomHyperImages.SetScale(Value: Integer);
begin
  if Value = 0 then
    Exit;
  FScale := Value;
  ImageChanged(Self);
end;

procedure TCustomHyperImages.SetAutoScaleImage(Value: Boolean);
begin
  if Value <> FAutoScaleImage then begin
    if Value = True then
      FAutoScalePanel := False;
    FAutoScaleImage := Value;
    ImageChanged(Self);
  end;
end;

procedure TCustomHyperImages.SetAutoScalePanel(Value: Boolean);
begin
  if Value <> FAutoScalePanel then begin
    if Value = True then
      FAutoScaleImage := False;
    FAutoScalePanel := Value;
    ImageChanged(Self);
  end;
end;

procedure TCustomHyperImages.SetHotCursor(Value: TCursor);
begin
  if Value <> FHotCursor then
    FHotCursor := Value;
end;

procedure TCustomHyperImages.SetInvertOnHot(Value: Boolean);
begin
  if Value <> FInvertOnHot then
    FInvertOnHot := Value;
end;

procedure TCustomHyperImages.SetHintOnHot(Value: Boolean);
begin
  if Value <> FHintOnHot then
    FHintOnHot := Value;
  if Value = True then
    FPaintBox.ShowHint := True else
    FPaintBox.ShowHint := False;
end;

procedure TCustomHyperImages.SetImageHint(Value: String);
begin
  if Value <> FImageHint then
    FImageHint := Value;
end;

procedure TCustomHyperImages.ImageChanged(Sender: TObject);
var MaxWidth, MaxHeight, BevelToAdd, BorderToAdd: Integer;
    ScalingFactor: Single;
begin
  if FImage.Picture = Nil then
    Exit else
  if (FImage.Picture.Width = 0) or (FImage.Picture.Height = 0) then
    Exit;
  BevelToAdd := 0;
  if BevelInner <> bvNone then
    BevelToAdd := BevelWidth;
  if BevelOuter <> bvNone then
    BevelToAdd := BevelToAdd + BevelWidth;
  BevelToAdd := BevelToAdd + BorderWidth;
  if BorderStyle = bsSingle then
    BorderToAdd := 2 else
    BorderToAdd := 0;
  if AutoScalePanel then begin
    FPaintBox.Width := FImage.Picture.Width * FScale div 100;
    FPaintBox.Height := FImage.Picture.Height * FScale div 100;
    Width := FPaintBox.Width + (2 * (BevelToAdd + BorderToAdd));
    Height := FPaintBox.Height + (2 * (BevelToAdd + BorderToAdd));
    FPaintBox.Left := BevelToAdd ;
    FPaintBox.Top := FPaintBox.Left;
  end else begin
    if AutoScaleImage then begin
      MaxWidth := Width - (2 * (BevelToAdd + BorderToAdd));
      MaxHeight := Height - (2 * (BevelToAdd + BorderToAdd));
      if (MaxWidth = 0) or (MaxHeight = 0) then
        Exit;
      if (FImage.Picture.Width > MaxWidth) or (FImage.Picture.Height > MaxHeight) then begin // Decrease Size
        ScalingFactor := MaxWidth / FImage.Picture.Width  ;
        if Round(FImage.Picture.Height * ScalingFactor) > MaxHeight then
          ScalingFactor := MaxHeight / FImage.Picture.Height ;
        ScalingFactor := ScalingFactor * 100;
      end else
      if (FImage.Picture.Width < MaxWidth) and (FImage.Picture.Height < MaxHeight) then begin // IncreaseSize
        ScalingFactor := MaxWidth / FImage.Picture.Width  ;
        if Round(FImage.Picture.Height * ScalingFactor) > MaxHeight then
          ScalingFactor :=  MaxHeight / FImage.Picture.Height;
        ScalingFactor := ScalingFactor * 100;
      end else
        ScalingFactor := 100;
    end else
      ScalingFactor := FScale;
    if ScalingFactor <> 0 then
      FScale := Round(ScalingFactor);
    FPaintBox.Width := Round(FImage.Picture.Width * ScalingFactor / 100);
    FPaintBox.Height := Round(FImage.Picture.Height * ScalingFactor / 100);
    FPaintBox.Left := (Width - FPaintBox.Width) div 2 - BorderToAdd;
    FPaintBox.Top := (Height - FPaintBox.Height ) div 2 - BorderToAdd;
    if FPaintBox.Width = MaxWidth - 1 then
      FPaintBox.Width := FPaintBox.Width + 1;
    if FPaintBox.Height = MaxHeight - 1 then
      FPaintBox.Height := FPaintBox.Height + 1;
  end;
  Invalidate;
end;

procedure TCustomHyperImages.ReCreateWnd;
begin
  ImageChanged(Self);
  if Handle <> 0 then Perform(CM_RECREATEWND, 0, 0);
end;

procedure TCustomHyperImages.AlignControls(AControl: TControl; var Rect: TRect);
begin
  ImageChanged(Self);
  inherited  AlignControls(AControl, Rect);
end;

procedure TCustomHyperImages.ImageMouseDown(Sender: TObject;
          Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned (FOnImageMouseDown) then
    FOnImageMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCustomHyperImages.ImageMouseUp(Sender: TObject;
          Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned (FOnImageMouseUp) then
    FOnImageMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCustomHyperImages.ImageMouseMove(Sender: TObject;
          Shift: TShiftState; X, Y: Integer);
var
  i, j: Integer;
  APicture, ATarget, AFileName: String;
  AHotspot: THotspot;
begin
  if (FHotCursor <> crDefault) or FInvertOnHot or FHintOnHot then
    for i := 0 to FRegionsList.Count - 1 do
      if PtInRegion(StrToInt(FRegionsList[i]), X * 100 div FScale, Y * 100 div FScale) then begin
        if FHotCursor <> crDefault then
          FPaintBox.Cursor := FHotCursor;
        if FHintOnHot then begin
          ExtractPictureAndTarget(FHotspotsDef[Integer(FRegionsList.Objects[i])],
          APicture, ATarget);
          if FPaintBox.Hint <> ATarget then begin
            Application.CancelHint;
            FPaintBox.Hint := ATarget;
          end;
        end;
        if FInvertOnHot  and (FInvertedRgnIndex <> i) then begin
          if FInvertedRgn <> 0 then begin
            InvertRgn(Canvas.Handle, FInvertedRgn);
            DeleteObject(FInvertedRgn);
            FInvertedRgn := 0;
            FInvertedRgnIndex := -1;
          end;
          LoadHotspotFromLineDef(FHotspotsDef[Integer(FRegionsList.Objects[i])],
          AFileName, AHotspot, True);
          with AHotspot do
            for j := 1 to VertexCount do begin
              Vertices[j].X := (Vertices[j].X * FScale div 100);
              Vertices[j].Y := (Vertices[j].Y * FScale div 100);
            end;
          FInvertedRgn := CreateHotspotRegion(AHotspot);
          OffsetRgn(FInvertedRgn, FPaintBox.Left, FPaintBox.Top);
          Application.ProcessMessages;
          if InvertRgn(Canvas.Handle, FInvertedRgn) then
            FInvertedRgnIndex := i;
        end;
        Break;
      end else begin
        if FHotCursor <> crDefault then
          FPaintBox.Cursor := crDefault;
        if FHintOnHot and (i = FRegionsList.Count - 1) then
          if FPaintBox.Hint <> FImageHint then begin
            Application.CancelHint;
            FPaintBox.Hint := FImageHint;
          end;
        if (FInvertOnHot = True) and (i = FRegionsList.Count - 1) then begin
          InvertRgn(Canvas.Handle, FInvertedRgn);
          DeleteObject(FInvertedRgn);
          FInvertedRgn := 0;
          FInvertedRgnIndex := -1;
        end;
  end;
  if Assigned (FOnImageMouseMove) then
    FOnImageMouseMove(Self, Shift, X, Y);
end;

procedure TCustomHyperImages.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FInvertedRgn <> 0 then begin
    InvertRgn(Canvas.Handle, FInvertedRgn);
    DeleteObject(FInvertedRgn);
    FInvertedRgn := 0;
    FInvertedRgnIndex := -1;
  end;
end;

procedure TCustomHyperImages.ImageClick(Sender: TObject);
begin
  if Assigned (FOnImageClick) then
    FOnImageClick(Self);
end;

procedure TCustomHyperImages.ImageDblClick(Sender: TObject);
begin
  if Assigned (FOnImageDblClick) then
    FOnImageDblClick(Self);
end;

function TCustomHyperImages.GetHotspotsCount: Integer;
begin
  Result := FHotspotsDef.Count;
end;

function TCustomHyperImages.CreatePictures: TStringlist;
var
  i: Integer;
  APicture, PrevPic: String;
begin
  Result := TStringList.Create;
  PrevPic := '';
  for i := 0 to HotspotsDef.Count - 1 do begin
    APicture := ExtractPicture(HotspotsDef.Strings[i]);
    if APicture <> PrevPic then
      Result.Add(APicture);
    PrevPic := APicture;
  end;
end;

procedure TCustomHyperImages.SetPicturesDir(Value: String);
begin
  if Value <> '' then
    if (Value[Length(Value)] <> '\') then
      Value := Value + '\';
  if (Value <> FPicturesDir) then
    FPicturesDir := Value;
end;

procedure TCustomHyperImages.SetPicture(Value: TPicture);
begin
  FImage.Picture.Assign(Value);
  ImageChanged(Self);
end;

function TCustomHyperImages.GetPicture: TPicture;
begin
  Result := FImage.Picture;
end;

procedure TCustomHyperImages.SetHotspotsDef(Value: TStringList);
begin
  FHotspotsDef.Assign(Value);
end;

procedure TCustomHyperImages.SetRegionsList(Value: TStringList);
begin
  FRegionsList.Assign(Value);
end;

function  TCustomHyperImages.GetIncrementalDisplay: Boolean;
begin
  Result := FImage.IncrementalDisplay;
end;

function TCustomHyperImages.GetImageCanvas: TCanvas;
begin
  Result := FPaintBox.Canvas;
end;

procedure TCustomHyperImages.SetShowHotspots(Value: Boolean);
begin
  if Value <> FShowHotspots then begin
    FShowHotspots := Value;
  if not (csDesigning in ComponentState) then
    Invalidate;
  end;
end;

procedure TCustomHyperImages.HotspotsPenDoChange(Sender: TObject);
begin
  if not (csDesigning in ComponentState) then
    if ShowHotspots then begin
      ShowHotSpots := False;
      ShowHotspots := True;
  end;
end;

procedure TCustomHyperImages.SetHotspotsPen(Value: TPen);
begin
  if Value <> Nil then begin
    FHotspotsPen.Assign(Value);
    HotspotsPenDoChange(Self);
  end;
end;

procedure TCustomHyperImages.SetIncrementalDisplay(Value: Boolean);
begin
  if Value <> FImage.IncrementalDisplay then
    FImage.IncrementalDisplay := Value;
end;

procedure TCustomHyperImages.SetPictureFileName(Value: String);
begin
  if Value <> FPictureFileName then
    FPictureFileName := Value;
end;

function TCustomHyperImages.CreateHotspotRegion(AHotspot: THotspot): HRGN;
begin
  with AHotspot do begin
    case FigureType of
      ftPolygon: Result := CreatePolygonRgn(Vertices, VertexCount, ALTERNATE);
      ftRectangle: Result := CreateRectRgn(Vertices[1].x, Vertices[1].y,
                          Vertices[3].x, Vertices[3].y);
      ftEllipse: Result := CreateEllipticRgn(Vertices[1].x, Vertices[1].y,
                          Vertices[3].x, Vertices[3].y);
      ftRoundRectangle: Result := CreateRoundRectRgn(Vertices[1].x, Vertices[1].y,
                          Vertices[3].x, Vertices[3].y, Vertices[5].x, Vertices[5].y);
    end;
  end;
end;

procedure TCustomHyperImages.CreateAllRegions(AHotspotsDef, ARegionsList: TStringList;
                                              APictureFileName: String);
var
  i, RGN: Integer;
  Hotspot: THotspot;
  AFileName: String;
begin
  with AHotspotsDef, Hotspot do begin
    BeginUpdate;
    try
      for i := 0 to Count - 1 do begin
        if ExtractPicture(AHotspotsDef.Strings[i]) = APictureFileName then begin
            LoadHotspotFromLineDef(AHotspotsDef.Strings[i], AFileName,
          Hotspot,True);
            RGN := CreateHotspotRegion(Hotspot);
            ARegionsList.AddObject(IntToStr(RGN),
                                  Pointer(i));
            AHotspotsDef.Objects[i] := Pointer(RGN);
        end;
      end;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TCustomHyperImages.LoadHotspotFromLineDef(Line: String; var AFileName: String;
                               var Hotspot : tHotspot; LoadPoints: Boolean);
var SubS, ATarget: String;
    i, v, l: Integer;
begin
  if Line ='' then
    Exit;
  if Line[Length(Line)] <> ';' then
    Line := Line + ';';
  fillchar(Hotspot,sizeof(Hotspot),0);;
  SubS := '';
  i := 1;
  v := 1;
  with Hotspot do begin
    ExtractPictureAndTarget(Line, AFileName, ATarget);
    Target := ATarget;
    Delete(Line, 1, Length(ATarget)+ Length(AFileName) + 2);
    l := Length(Line);
    while (Line[i] <> ';') and (i < l) do begin   //get VertexCount
      SubS := SubS + Line[i];
      Inc(i);
    end;
    if StrToInt(SubS) > 0 then   //We have a polygon
      VertexCount := StrToInt(SubS)
    else begin
      FigureType := TFigureType(-Ord(StrToInt(SubS)));
      if FigureType = ftRoundRectangle then
        VertexCount := 5 else
        VertexCount := 4;
    end;
    Inc(i);
    SubS := '';
    if LoadPoints then
      while i < l do begin     //Get vertices
        while Line[i] <> ',' do begin  //Get the x coordinate
          SubS := SubS + Line[i];
          Inc(i);
        end;
        Vertices[v].X := StrToInt(SubS);
        inc(i);
        SubS := '';
        while Line[i] <> ';' do begin  //Get the y coordinate
          SubS := SubS + Line[i];
          Inc(i);
        end;
        Vertices[v].Y := StrToInt(SubS);
        inc(v);
        inc(i);
        SubS := '';
      end;
      if FigureType <> ftPolygon then begin
        if FigureType = ftRoundRectangle then begin
          Vertices[5].X := Vertices[3].X;
          Vertices[5].Y := Vertices[3].Y;
        end;

        Vertices[3].X := Vertices[2].X;
        Vertices[3].Y := Vertices[2].Y;
        Vertices[2].X := Vertices[3].X;
        Vertices[2].Y := Vertices[1].Y;
        Vertices[4].X := Vertices[1].X;
        Vertices[4].Y := Vertices[3].Y;
      end;
  end;
end;

procedure TCustomHyperImages.DestroyAllRegions(AhotspotsDef, ARegionsList: TStringList);
var
  i, RGN: Integer;
begin
  with ARegionsList do begin
    AHotspotsDef.BeginUpdate;
    try
      for i := 0 to Count - 1 do begin
        RGN := StrToInt(ARegionsList.Strings[i]);
        AHotspotsDef.Objects[Integer(ARegionsList.Objects[i])] := Nil;
        //Free the pointers to the regionList indexes in HotspotsDef
        if RGN <> 0 then
          if DeleteObject(RGN) then
            RGN := 0{
          else
            MessageDlg('Unable to delete region.',mtWarning,[mbOK],0)};
      end;
      Clear;
    finally
      AHotspotsDef.EndUpdate;
    end;
  end;
end;

procedure TCustomHyperImages.Loaded;
begin
  inherited Loaded;
    if not (csDesigning in ComponentState) then begin
      if FImage.Picture <> Nil then
        if FImage.Picture.Graphic <> Nil then begin
          CreateAllRegions(FHotspotsDef, FRegionsList, FPictureFileName);
        end;
      FPictures := CreatePictures;
      Invalidate;
    end;
end;

procedure TCustomHyperImages.CreateWnd;
begin
  Caption := '';
  inherited CreateWnd;
end;

function TCustomHyperImages.PointIsOnTarget(X, Y: Integer;
                                 var ATarget: String): Boolean;
var i: Integer;
    RGN: HRGN;
    APicture: String;
begin
  Result := False;
  for i := 0 to FRegionsList.Count - 1 do begin
    RGN := StrToInt(FRegionsList.Strings[i]);
    if PtInRegion(RGN, X * 100 div FScale, Y * 100 div FScale) then begin
      ExtractPictureAndTarget(FHotspotsDef.Strings[Integer(FRegionsList.Objects[i])],
                              APicture, ATarget);
      Result := True;
      Exit;
    end;
  end;
end;

function TCustomHyperImages.PointIsOnTargets(X, Y: Integer;
                                 var Targets: TStringList): Boolean;
var i: Integer;
    RGN: HRGN;
    APicture, ATarget: String;

begin
  if Targets = nil then
    Targets := TStringList.Create
  else
    Targets.Clear;
  Result := False;
  for i := 0 to FRegionsList.Count - 1 do begin
    RGN := StrToInt(FRegionsList.Strings[i]);
    if PtInRegion(RGN, X * 100 div FScale, Y * 100 div FScale) then begin
      ExtractPictureAndTarget(FHotspotsDef.Strings[Integer(FRegionsList.Objects[i])],
                              APicture, ATarget);
      Result := True;
      Targets.Add(ATarget);
    end;
  end;
end;


procedure TCustomHyperImages.LoadImageFromFile(AFileName: String);
begin
  CheckPictureFileExt(AFileName);
  AFileName := ExtractFileName(AFileName);
  If not FileExists(PicturesDir + AFileName) then begin
    if PicturesDir = '' then
      MessageDlg('File ' + AFileName + ' not found.' + #13 +
      'The PicturesDir property is not set.',mtError,[mbOk],0) else
      MessageDlg('File ' + AFileName + ' not found.' + #13 +
      'The file should be in directory :' + #13 +
      PicturesDir,mtError,[mbOk],0);
    Exit;
  end;
  DestroyAllRegions(FhotspotsDef, FRegionsList);
  FImage.Picture.LoadFromFile(PicturesDir + AFileName);
  if FImage.Picture <> Nil then
    if FImage.Picture.Graphic <> Nil then
      CreateAllRegions(FHotspotsDef, FRegionsList, AFileName);
  FPictureFileName := AFileName;
  Imagechanged(Self);
end;

procedure TCustomHyperImages.DrawPolygons;
  procedure Drawpolygon(AHotspot: THotspot);
  var
    I : Integer;
  begin
    with AHotspot, FPaintBox.Canvas do begin
      Brush.Style := bsClear;
      case FigureType of
        ftPolygon: begin
          if VertexCount >= 2 then  begin
              with Vertices[1] do MoveTo(X ,Y);
              for I := 2 to VertexCount do
                  with Vertices[I] do LineTo(X, Y);
                  with Vertices[1] do LineTo(X, Y); { Do final segment. }
              end;
        end;
        ftRectangle: begin
          Rectangle(Vertices[1].X, Vertices[1].Y,
                    Vertices[3].X,  Vertices[3].Y);
        end;
        ftEllipse: begin
          Ellipse(Vertices[1].X, Vertices[1].Y,
                    Vertices[3].X,  Vertices[3].Y);
        end;
        ftRoundRectangle: begin
          Windows.RoundRect(handle, Vertices[1].X, Vertices[1].Y,
                    Vertices[3].X,  Vertices[3].Y,
                    Vertices[5].X,  Vertices[5].Y);
        end;
      end;
    end;
  end;
var i : Integer;
    Hotspot: THotspot;
    AFileName: String;
    Painting: Boolean;
    SavePen: TPen;
begin
  if FImage.Picture = Nil then
    Exit else
  if FImage.Picture.Graphic = Nil then
    Exit;
  if ShowHotspots and not (csDesigning in ComponentState)then begin
    SavePen := Nil;
    if FPaintBox.Canvas.Pen <> Nil then
      SavePen := FPaintBox.Canvas.Pen;
    FPaintBox.Canvas.Pen := FHotspotsPen;
    for i := 0 to RegionsList.Count - 1 do begin
      LoadHotspotFromLineDef(
      HotspotsDef.Strings[Integer(RegionsList.Objects[i])], AFileName,
      Hotspot, True);
      DrawPolygon(Hotspot);
    end;
    if SavePen <> Nil then
      FPaintBox.Canvas.Pen := SavePen;
  end;
end;

procedure TCustomHyperImages.CheckPictureFileExt(AFileName: String);
begin
  {if UpperCase(ExtractFileExt(AFileName)) <> '.BMP' then
  Raise Exception.Create('You can only load bitmap files in THyperImages'); }
end;

procedure TCustomHyperImages.PaintBoxDoPaint(Sender: TObject);
var
  Rect: TRect;
  SaveBkMode, SaveBkColor: Integer;
begin
  if FImage.Picture <> nil then
    if FImage.Picture.Graphic <> nil then begin
      with FPaintBox do begin
        if FImage.Picture.Graphic is TIcon then
          DrawIconEx(Canvas.Handle, ClientRect.Left, ClientRect.Top,
          FImage.Picture.Icon.Handle,
          ClientRect.Right - ClientRect.Left,
          ClientRect.Bottom - ClientRect.Top, 0, 0, DI_NORMAL) else
          Canvas.StretchDraw(ClientRect, FImage.Picture.Graphic);
      end;
      DrawPolygons;
      if Unregistered then begin
        Rect := FPaintBox.ClientRect;
        SaveBkMode := GetBkMode(FPaintBox.Canvas.Handle);
        SaveBkColor := GetBkColor(FPaintBox.Canvas.Handle);
        SetBkMode(FPaintBox.Canvas.Handle, OPAQUE);
        SetBkColor(FPaintBox.Canvas.Handle, ClWhite);
        DrawText(FPaintBox.Canvas.Handle, 'THyperImages - Unregistered Version', -1,
             Rect, DT_SINGLELINE or DT_BOTTOM or DT_CENTER);
        SetBkMode(FPaintBox.Canvas.Handle, SaveBkMode);
        SetBkColor(FPaintBox.Canvas.Handle, SaveBkColor);
      end;
    end;
end;

function TCustomHyperImages.GetPosition(HS : String) : Tpoint;
var i, RGN : integer;
  APicture, ATarget, FN : String;
  RealHs : THotSpot;
  RR : TRect;
begin
  for i := 0 to FRegionsList.Count - 1 do begin
    RGN := StrToInt(FRegionsList.Strings[i]);
    ExtractPictureAndTarget(FHotspotsDef.Strings[Integer(FRegionsList.Objects[i])],
                              APicture, ATarget);

     if Atarget = HS then begin
       LoadHotspotFromLineDef(FHotspotsDef.Strings[Integer(FRegionsList.Objects[i])], FN,
                               RealHS, true);

       //Rgn := CreateHotspotRegion(RealHS);
       //RegionsList.AddObject(IntToStr(RGN),
//                                  Pointer(i));
       //HotspotsDef.Objects[i] := Pointer(RGN);

       GetRgnBox(Rgn,RR);
       result := Point((RR.left + (RR.right-RR.left) div 2)*FScale div 100, (RR.Bottom+(RR.Top-RR.Bottom) div 2)*FScale div 100);
       //DeleteObject(Rgn);

       //FInvertedRgn := RGN;
       exit;
     end;
  end;
end;

procedure TCustomHyperImages.DeleteInverted;
begin
   if FInvertedRgn <> 0 then begin
     InvertRgn(Canvas.Handle, FInvertedRgn);
     DeleteObject(FInvertedRgn);
     FInvertedRgn := 0;
     FInvertedRgnIndex := -1;
   end;
end;

procedure TCustomHyperImages.InvertHotspot(Hotspot : String);
var i,j, RGN : integer;
  APicture, ATarget, AFileName : String;
  AhotSpot : THotSpot;
  RR : TRect;
begin
  { if FInvertedRgn <> 0 then begin
     InvertRgn(Canvas.Handle, FInvertedRgn);
     DeleteObject(FInvertedRgn);
     FInvertedRgn := 0;
     FInvertedRgnIndex := -1;
   end;}
   for i := 0 to FRegionsList.Count - 1 do begin
     RGN := StrToInt(FRegionsList.Strings[i]);
     ExtractPictureAndTarget(FHotspotsDef.Strings[Integer(FRegionsList.Objects[i])],
                              APicture, ATarget);
     if ATarget = HotSpot then begin
       if FInvertedRgn <> 0 then begin
         InvertRgn(Canvas.Handle, FInvertedRgn);
         DeleteObject(FInvertedRgn);
         FInvertedRgn := 0;
         FInvertedRgnIndex := -1;
       end;
       LoadHotspotFromLineDef(FHotspotsDef[Integer(FRegionsList.Objects[i])],
          AFileName, AHotspot, True);
       with AHotspot do
         for j := 1 to VertexCount do begin
           Vertices[j].X := (Vertices[j].X * FScale div 100);
           Vertices[j].Y := (Vertices[j].Y * FScale div 100);
         end;
        FInvertedRgn := CreateHotspotRegion(AHotspot);
//         FInvertedRgn := StrToInt(FRegionsList[i]);
{               RegionsList.AddObject(IntToStr(FInvertedRGN),
                                  Pointer(i));
      HotspotsDef.Objects[i] := Pointer(FInvertedRgn);

 }
         OffsetRgn(FInvertedRgn, FPaintBox.Left, FPaintBox.Top);
        {GetRgnBox(FInvertedRgn,RR);
         Left := RR.left + (RR.right-RR.left) div 2;
         Top := RR.Bottom+(RR.Top-RR.Bottom) div 2;
         }
         Application.ProcessMessages;
         if InvertRgn(Canvas.Handle, FInvertedRgn) then
           FInvertedRgnIndex := i;
         exit;
     end;
   end;
end;
end.
