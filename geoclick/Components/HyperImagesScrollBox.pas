unit HyperImagesScrollBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CustomHImages, HImages, DsgnIntf, JPeg, extctrls, buttons, stdctrls, utils;

type
  ENoHyperImage = class(Exception);

  TOnHotSpotClicked = procedure(Sender : TObject; HotSpot : STring;X, Y : integer) of object;
  TOnHotSpotsClicked = procedure(HotSpots : TStrings) of object;
  TOnNoHotSpotClicked = procedure(X, Y : integer) of object;


  TOnZoom =  procedure(Z : integer) of object;
  TZoomerPanel = class(TPanel)
    ZoomInSpeedButton, ZoomOutSpeedButton : TSpeedButton;
    ZoomScrollBar : TScrollBar;
    procedure SpeedButtonMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomOutSpeedButtonMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomInSpeedButtonMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ZoomScrollBarChange(Sender: TObject);
    procedure ZoomerPanelResize(Sender: TObject);

    private
      WasButton : boolean;
      Timeclicked : TDateTime;
      FOnZoomAbs, FOnZoomRel : TOnZoom;
      FHYperImages : THyperImages;
      FNormalZoom : boolean;
    public
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
      
    published
      property NormalZoom : Boolean read FNormalZoom write FNormalZoom;
      property HyperImages : THyperImages read FHyperImages write FHyperImages;
      property OnZoomAbs : TOnZoom read FOnZoomAbs write FOnZoomAbs;
      property OnZoomRel : TOnZoom read FOnZoomRel write FOnZoomRel;
  end;


  THyperImagesScrollBox = class(TScrollBox)


    procedure HyperImagesImageMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HyperImagesImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
    procedure HyperImagesImageMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ConvertToMute(HotspotDefinitions : TStrings);
  private
    FNormalScroll : Boolean;
    FHotSpotFile : String;
    FHOtSpotFiles : TStrings;
    FImageFileName : String;
    FOnHotSpotClicked : TOnHotSpotClicked;
    FOnHotSpotsClicked : TOnHotSpotsClicked;
    FOnNoHotSpotClicked : TOnHotSpotsClicked;

    FZoomerPanel : TZoomerPanel;
    FHOtspotsList : TStrings;
    isLoadedImage : boolean;

    function GetPicturesDir : String;
    procedure ReadHotSpotFromFiles(FileNames : TStrings);
    procedure SetPicturesDir(S : String);
    procedure SetZoomerPanel(ZP : TZoomerPanel);
  protected

    StartDrag : Boolean;
    XTM, YTM : integer;
    FX, FY : integer;

  public
    FileName : String;
    IsMute : boolean;
    HyperImages : THyperImages;
    procedure ReadHotSpotFromFile(FileName : String; doDelete : boolean);

    procedure ZoomIn;
    procedure ZoomOut;
    destructor Destroy; override;
    procedure ShowHotSpot( S : String; MustCenter : Boolean);
    function DoLoad : boolean;
    procedure LoadImage(AName : String);
    function GetDistanceFrom( S : String; X, Y : integer) : integer;
    class function AddHotSpotFromFile(FileName : String; HSL : TStrings) : TStrings;

    procedure WriteHotSpot(Oldname, Newname : String);

    function GetHotspotsList : TStrings;
    procedure ZoomRel(Z : integer);
    procedure ZoomAbs(Z : integer);
    constructor Create(AOwner : TComponent); override;
    procedure SetDefaultSize;
    procedure Center(XRel, YRel : real);
    function IsHotspotIn(SS : String) : boolean;


  published

    property PicturesDir : String read GetPicturesDir write SetPicturesDir;
    property HotSpotFiles : TStrings read FHotSpotFiles write ReadHotSpotFromFiles;

    property ImageFileName : String read FImageFileName write LoadImage;
    property OnHotSpotClicked : TOnHotSpotClicked read FOnHotSpotClicked write FOnHotSpotClicked;
    property OnHotSpotsClicked : TOnHotSpotsClicked read FOnHotSpotsClicked write FOnHotSpotsClicked;
    property ZoomerPanel : TZoomerPanel read FZoomerPanel write SetZoomerPanel;
    property NormalScroll : boolean read FNormalScroll write FNormalScroll;

  end;

  EHyperImagesScrollBoxException = class(Exception);

procedure Register;

implementation
uses stringfns;

constructor THyperImagesScrollBox.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  HyperImages := THyperImages.Create(Self);
  HyperImages.HotCursor := crHandPoint;
  FHotSpotFiles := TStringList.Create;
  FHotspotsList := TStringList.Create;
  with HyperImages do begin
    Parent := Self;
    AutoScalePanel := True;
    IncrementalDisplay := False;
    OnImageMouseDown := HyperImagesImageMouseDown;
    OnImageMouseMove := HyperImagesImageMouseMove;
    OnImageMouseUp := HyperImagesImageMouseUp;
  end;

end;

destructor THyperImagesScrollBox.Destroy;
begin

  HyperImages.Free;
  FhotSpotFiles.Free;
  FHotspotsList.Free;
  inherited;
end;

procedure THyperImagesScrollBox.SetDefaultSize;
begin

  HyperImages.Scale := 150 * Width div HyperImages.Width;
end;

procedure THyperImagesScrollBox.HyperImagesImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ((Button = mbRight) or FNormalScroll) and StartDrag then begin
     VertScrollBar.Position :=
        VertScrollBar.Position+YTM;
      HorzScrollBar.Position :=
        HorzScrollBar.Position+XTM;
      StartDrag := False;
      XTM := 0;
      YTM := 0;
      Screen.Cursor := crDefault;
  end;
end;

function THyperImagesScrollBox.GetPicturesDir;
begin
  if HyperImages <> nil then
    GetPicturesDir := HyperImages.PicturesDir
  else
    GetPicturesDIr := '';
end;

procedure THyperImagesScrollBox.HyperImagesImageMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

var S : TStringList;
    i : integer;
begin
  S := TStringList.Create;
  if (ssRight in Shift) or ( FNormalScroll) then begin
    StartDrag := True;
    XTM := 0;
    YTM := 0;
    FX := X;
    FY := Y;
    Screen.Cursor := crDrag;
  end;
  if ssLeft in Shift then
    if HyperImages.PointIsOnTargets(X,Y,S) then begin
       for i := 0 to S.Count-1 do
         if Assigned(FOnHotSpotClicked) then
           FOnHotSpotClicked(Self,S.Strings[i],X,Y);
      if Assigned(FOnHotSpotsClicked) then
        FOnHotSpotsClicked(S);
    end;
  S.Free;
end;

procedure THyperImagesScrollBox.HyperImagesImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if StartDrag and ((ssRight in Shift) or (NormalScroll))then
    with HyperImages do begin
      YTM := YTM+Y-FY;
      XTM := XTM+X-FX;
      X := FX;
      Y := FY;
    end;
end;

procedure THyperImagesScrollBox.ZoomIn;
begin
  HyperImages.Scale := HyperImages.Scale+5
end;

procedure THyperImagesScrollBox.ZoomOut;
begin
  HyperImages.Scale := HyperImages.Scale-5
end;

procedure THyperImagesScrollBox.SetPicturesDir(S : String);
begin
  if HyperImages <> nil then
    HyperImages.PicturesDir := S;
end;

procedure THyperImagesScrollBox.ReadHotSpotFromFile(FileName : String; doDelete : boolean);
var i : integer;
  currstr : String;
  TSL : TStrings;
  otherStr : String;
  pose, poss : integer;
begin
  TSL := TStringList.Create;
  try
    if HyperImages <> nil then begin
      if (doDelete) then
        HyperImages.DestroyAllRegions(HyperImages.HotspotsDef, HyperImages.RegionsList);
      TSL.LoadFromFile(PicturesDir+FileName);
      if IsMute then
        ConvertToMute(TSL);
      HyperImages.HotSpotsDef.Assign(TSL);
      FHotSpotFile := FileName;
      for i := 0 to HyperImages.HotspotsDef.Count-1 do begin
        currstr := HyperImages.HotspotsDef.Strings[i];
        pose := Pos('=',currstr);
        poss := Pos('/',currstr);
        if pose > 0 then begin
          otherStr := Copy(Currstr,poss+1,pose-poss-1);
          FHotspotsList.Add(otherStr);
        end;
      end;
    end;
    HyperImages.CreateAllRegions(HyperImages.HotspotsDef, HyperImages.RegionsList, HyperImages.PictureFilename);
  except on EFOpenError do
    FHotSpotFile := ''
  end;
    //Log('Could not open file '+ PicturesDir+Filename);
  TSL.Free;


end;

procedure THyperImagesScrollBox.WriteHotSpot(Oldname, Newname : String);
var i : integer;
  currstr : String;
  pose, poss : integer;
  currhot : String;
begin
  if HyperImages = nil then
    raise EHyperImagesScrollBoxException.CreateFmt('THyperImagesScrollBox.WriteHotSpot(%,%) called with HyperImages = nil', [OldName, NewName]);
  for i := 0 to HyperImages.HotspotsDef.Count-1 do begin
    currstr := HyperImages.HotspotsDef.Strings[i];
    pose := Pos('=',currstr);
    poss := Pos('/',currstr);
    currhot := Copy(Currstr,poss+1,pose-poss-1);
    if currHot = OldName then begin
      HyperImages.HotspotsDef.Sorted := False;
      HyperImages.HotspotsDef.Strings[i] := ReplaceStr(CurrStr,OldName,NewName);
      HyperImages.HotspotsDef.Sorted := True;
      break;
    end;
  end;

end;

function THyperImagesScrollBox.GetDistanceFrom( S : String; X, Y : integer) : integer;
var MP : TPoint;
  SX, SY : integer;
begin
  if HyperImages = nil then exit;
  if not IsHotSpotIn(S) then
    result := 100
  else begin

    MP :=HyperImages.GetPosition(S);
    SX := abs(MP.X - X) * 100 div HyperImages.Width;
    SY := abs(MP.Y-Y) * 100 div HyperImages.Height;
    result := Round(sqrt(SX*SY))
  end;
end;

// evindenzia Hot Spot

procedure THyperImagesScrollBox.ShowHotSpot( S : String; MustCenter : Boolean);
var  MP :TPoint;
     SC : REAL;
begin
  if HyperImages = nil then begin
    //Log('Showing Hotspot in empty HyperImages');
    raise ENoHyperImage.Create('Unassigned HyperImages');
    exit;
  end;
  MP :=HyperImages.GetPosition(S);
  SC := HyperImages.Scale;
  if MustCenter then begin
    HorzScrollBar.Position := -(InInterval(-HyperImages.Width+Width,Width div 2 -MP.X,
    0));
    VertScrollBar.Position := -(InInterval(-HyperImages.Height + Height,Height div 2-MP.Y,0));
  end;
  HyperImages.InvertHotSpot(S);

end;

procedure THyperImagesScrollBox.Center(XRel, YRel : real);
var X, Y : integer;
begin
  X := ROund(HyperImages.Width*XRel);
  Y := ROund(HyperImages.Height*YRel);
  HorzScrollBar.Position := -(InInterval(-HyperImages.Width+Width,Width div 2 -X,0));
  VertScrollBar.Position := -(InInterval(-HyperImages.Height + Height,Height div 2-Y,0));

end;



function THyperImagesScrollBox.IsHotspotIn(SS : String) : boolean;
begin
  result := false;
  if (FHotspotsList = nil) then
    raise EHyperImagesScrollBoxException.Create('THyperImagesScrollBox.IsHotspotIn called with FHotSpotsList = nil');
  result := FHotSpotsList.IndexOf(SS) <> -1;
end;

procedure THyperImagesScrollBox.ReadHotSpotFromFiles(FileNames : TStrings);
var i : Integer;
  S : String;
  TSL, TVL : TStrings;
begin
  TSL := TSTRingList.Create;
  TVL := TSTRingList.Create;

  FHotSpotFiles.Assign(FileNames);
  try
    for i := 0 to FileNames.Count - 1 do begin
      S := Filenames.Strings[i];
      TSL := ADDHotspotFromFile(PicturesDir+S,FHotspotsList);
      TVL.AddStrings(TSL);
    end;
    if IsMute then
      ConvertToMute(TVL);
    HyperImages.HotSpotsDef.Assign(TVL);
  finally
    TSL.Free;
    TVL.Free;
  end;
end;

procedure THyperImagesScrollBox.ConvertToMute(HotspotDefinitions : TStrings);
var PS, PR : String;
   i, ip : integer;
begin

  if isMute then
    for i := 0 to HotspotDefinitions.Count-1 do begin

      PS := HotspotDefinitions.Strings[i];
      if length(PS) = 0 then // skip empty lines
        continue;
      IP := Pos('.',PS);
      if IP = 0
        then continue;  // no . found on line
      PS[IP-1] := 'm';  // replace character before . with m
      HotspotDefinitions.Strings[i] := PS;
    end;
end;

class function THyperImagesScrollBox.AddHotSpotFromFile(FileName : String; HSL : TStrings) : TStrings;
var i : integer;
  currstr : String;
  pose, poss : integer;
  TSL : TStrings;
begin
  try
    TSL := TStringList.Create;
      TSL.LoadFromFile(FileName);
      for i := 0 to TSL.Count-1 do begin
        currstr := TSL.Strings[i];
        pose := Pos('=',currstr);
        poss := Pos('/',currstr);
        if pose > 0 then
          HSL.Add(Copy(Currstr,poss+1,pose-poss-1));
      //end;

    end;
  except on EFOpenError do
    TSL.Free;
    //Log('Could not open '+PicturesDir+FileName);
  end;
  result := TSL;
end;


procedure THyperImagesScrollBox.LoadImage(AName : String);
begin
  if HyperImages <> nil then begin
    try
      HyperImages.LoadImageFromFile(AName);
    except on EFOpenError do
      //Log('Could not open image file '+AName);
    end;
    FImageFileName := AName;
  end;
end;

function THyperImagesScrollBox.DoLoad : boolean;
begin
  result := false;
  if not FileExists(FileName) then exit; // may come from a strange situation
  if not IsLoadedImage then begin
    if FileName <> '' then begin
      result := true;
      LoadImage(ExtractFileName(FileName));
      isLoadedImage := True
    end
  end;
  result := IsLoadedImage
end;

procedure THyperImagesScrollBox.ZoomRel(Z : integer);
begin
  HyperImages.Scale := HyperImages.Scale+Z;
end;

procedure THyperImagesScrollBox.ZoomAbs(Z : integer);
begin
  HyperImages.Scale := Z;
end;

function THyperImagesScrollBox.GetHotspotsList : TStrings;
begin
  result := FHotspotsList;
end;

procedure Register;

begin
  RegisterComponents('Additional', [THyperImagesScrollBox, TZoomerPanel]);
  //RegisterPropertyEditor(TypeInfo(String), THyperImagesScrollBox, 'PicturesDir', TDirNameProperty);
end;

procedure TZoomerPanel.SpeedButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if NormalZoom then
    if Sender = ZoomInSpeedButton then
      HyperImages.Scale :=  HyperImages.Scale +10
    else
      HyperImages.Scale :=  HyperImages.Scale -10
  else
    TimeClicked := Now;
end;

procedure THyperImagesScrollBox.SetZoomerPanel(ZP : TZoomerPanel);
begin
  if (ZP <> nil) then begin
    ZP.OnZoomAbs := ZoomAbs;
    ZP.OnZoomRel := ZoomRel;
    FZoomerPanel := ZP;
  end;
end;


procedure TZoomerPanel.ZoomOutSpeedButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var STA : integer;
begin
  if not NormalZoom then begin
    STA := Round((Now - TimeClicked)*3600.0*200.0);
    if Assigned(FOnZoomRel) then
      OnZoomRel(-STA) ;
    if Assigned(FHyperImages) then
      FHyperImages.Scale :=    FHyperImages.Scale -STA;
  end;
  WasButton := True;
  ZoomScrollBar.Position := FHyperImages.Scale;
  WasButton := False;
end;

procedure TZoomerPanel.ZoomInSpeedButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var STA : integer;
begin
  if not NormalZoom then begin
    STA := Round((Now - TimeClicked)*3600.0*200.0);
    if Assigned(FOnZoomRel) then
      OnZoomRel(+STA) ;
    if Assigned(FHyperImages) then
      FHyperImages.Scale :=    FHyperImages.Scale +STA;
  end;
  WasButton := True;
  ZoomScrollBar.Position := FHyperImages.Scale;
  WasButton := False;
end;


constructor TZoomerPanel.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  WasButton := False;
  ZoomInSpeedButton := TSpeedButton.Create(Self);
  with ZoomInSpeedButton do begin
    Parent := Self;
    Left := 8;
    Width := 25;
    Height := 25;
    NumGlyphs := 2;
  try
    Glyph.LoadFromFile(ExtractFilePath(Application.Exename)+'Components/ZoomIn.bmp');
  except on EFOpenError do
    Caption := 'IN';
  end;

    OnMouseDown := SpeedButtonMouseDown;
    OnMouseUp := ZoomInSpeedButtonMouseUp;
  end;
  ZoomOutSpeedButton := TSpeedButton.Create(Self);
  with ZoomOutSpeedButton do begin
    Parent := Self;
    Left := 32;
    NumGlyphs := 2;
    Width := 25;
    Height := 25;
    try

      Glyph.LoadFromFile(ExtractFilePath(Application.Exename)+'Components/ZoomOut.bmp');
    except on EFOpenError do
      Caption := 'Out';
    end;

    OnMouseDown := SpeedButtonMouseDown;
    OnMouseUp := ZoomOutSpeedButtonMouseUp;
  end;
  ZoomScrollBar := TScrollBar.Create(Self);
  with ZoomScrollbar do begin
    Parent := Self;
    Left := 72;
    Top := 8;

    Height := 17;
    LargeChange := 10;
    Max := 200;
    Min := 40;
    Position := 100;
    OnChange := ZoomScrollBarChange;
  end;
  ZoomScrollBar.Width := Width - 192;
  OnResize := ZoomerPanelResize;
end;

destructor TZoomerPanel.Destroy;
begin
  ZoomInSpeedButton.Free;
  ZoomOutSpeedButton.Free;
  ZoomScrollBar.Free;
  inherited;
end;


procedure TZoomerPanel.ZoomScrollBarChange(Sender: TObject);
begin
  if Assigned(FOnZoomAbs) then
    FOnZoomAbs(ZoomScrollBar.Position);
  if (Assigned(FHyperImages) ) and ( not WasButton ) then
    FHyperImages.Scale := ZoomScrollBar.Position;
end;

procedure TZoomerPanel.ZoomerPanelResize(Sender: TObject);
begin
  ZoomScrollBar.Width := Width-192;
end;

end.
