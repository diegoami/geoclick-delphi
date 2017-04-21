unit uBrowseMaps;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HyperImagesScrollBox, ExtCtrls, ComCtrls, OvalButtonsPanel,
  dcDTree,  uSimpleBrowseTreeView, uDCNewBrowseTreeVie,
  uHyperImagesTreeView, uHSFTreeView, uGeoController, Buttons, utils,
  Menus, RxMenus, UGeogame, MPlayer, ImgList;

type
  TBrowseMaps = class(TForm)
    Panel1: TPanel;
    Splitter2: TSplitter;
    Splitter1: TSplitter;
    ImageList1: TImageList;
    StatusPanel: TPanel;
    StatusBar1: TStatusBar;
    SpeedPanel: TPanel;
    NewBtn: TSpeedButton;
    UserBtn: TSpeedButton;
    ExitBtn: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    DifficultySpeedButton: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;

    ZoomerPanel1: TZoomerPanel;
    SpeedButton1: TSpeedButton;
    MediaPlayer1: TMediaPlayer;
    Panel3: TPanel;
    Splitter3: TSplitter;
    Image1: TImage;
    ZoomInSpeedButton: TSpeedButton;
    ZoomOutSpeedButton: TSpeedButton;

    procedure FormShow(Sender: TObject);
    function WhichHsf(Dir : String) : TStrings; dynamic;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure StatusPanelResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure UserBtnClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure DifficultySpeedButtonClick(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZoomInSpeedButtonClick(Sender: TObject);
    procedure ZoomOutSpeedButtonClick(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);

  private
    PCHandle : integer;
    CurrFullText : String;
    CurrValNode : TTreeNode;
    function AddHyperImage(Node : TTreeNode) : boolean;

    function CreateHyperImage(Dir, Name : String) : THyperImagesScrollBox;
  protected
    FileImg : String;
    HyperList : TList;
    CurrentHyperImagesScrollBox : THyperImagesScrollBox;
    procedure UpdateStatusBars(SS : TStrings);
    procedure HyperImagesScrollBox1HotSpotClicked(Sender : TObject; HotSpot: String; X,Y : integer) ; dynamic;
    procedure HyperImagesScrollBox1HotSpotsClicked(HotSpots: TStrings) ; dynamic;
    procedure PruneBadDirs; dynamic;
    procedure OnTreeChange(Sender: TObject; Node: TTreeNode); dynamic;
    procedure CreateTreeView(var TreeView : THyperImagesTreeView);
    procedure AddHyperImages; dynamic;
  public
    HYperImagesTreeView1 : THyperImagesTreeView;
    procedure Init; dynamic;
    procedure ShowLevel(Level, Score : Integer);
  end;

EBrowseMapsException = class(Exception);

var
  BrowseMaps: TBrowseMaps;

implementation

{$R *.DFM}
uses uOptionsForm, uDebugForm, uUserForm, uColorForm, uDifficultyForm,
  uScoreForm, uRegisterForm, uGeoClickAbout, stringfns, uMaplist, Math;

var EmptyStringList : TStrings;

procedure TBrowseMaps.HyperImagesScrollBox1HotSpotsClicked(HotSpots: TStrings);
begin
  UpdateStatusBars(Hotspots);
end;

procedure TBrowseMaps.UPdateStatusBars(SS : TStrings);
var i : integer;

begin
  for i := 0 to StatusBar1.Panels.count-2 do
    StatusBar1.Panels[i].Text := '';
  for i := 0 to min(SS.count-1,2) do
    StatusBar1.Panels[i].Text := SS.Strings[i];
end;



function TBrowseMaps.WhichHsf(Dir : String) : TStrings;
begin
  result := EmptyStringList;
end;


procedure TBrowseMaps.HyperImagesScrollBox1HotSpotClicked(Sender : TObject; HotSpot: String; X,Y : integer) ;
begin
end;

{
  CreateHyperImages is equal both, what happens after an Image is Loaded
  is driven by the methods
  WhichHSF
}


function TBrowseMaps.CreateHyperImage(Dir, Name : String) : THyperImagesScrollBox;
var HIS : THyperImagesScrollBox;
    FormatMessage : String;
begin
  FormatMessage := 'TBrowseMaps.CreateHyperImage(%,%) - % is nil';
  if (HyperList = nil) then
    raise EBrowseMapsException.CreateFmt(FormatMessage,['HyperList']);
  if (GeoController = nil) then
    raise EBrowseMapsException.CreateFmt(FormatMessage,['GeoController']);

  HyperList.Add(THyperImagesScrollBox.Create(Self));
  HIS := HyperList.Last;
  with HIS do begin
    Align := AlClient;
    PicturesDir := Dir;
    IsMute := GeoController.ClearedMaps;
    HotSpotFiles := WhichHsf(Dir);
    NormalScroll := GeoController.InterfaceOptions.NormalScroll;
    OnHotSpotClicked := HyperImagesScrollBox1HotSpotClicked;
    OnHotSpotsClicked := HyperImagesScrollBox1HotSpotsClicked;
    Parent := Self;
    Visible := False;
  end;
  HIS.FileName := Dir+Name;
  with AReg, HIS do begin
    Active := True;
    HyperImages.Scale := RSInteger('Scales',ExtractFileName(FileName),100);
    Active := False;
  end;
  result := HIS;
end;

procedure TBrowseMaps.PruneBadDirs;
begin
  if (GeoController = nil) then
    raise EBrowseMapsException.CreateFmt('TBrowseMaps.PruneBadDirs - % is nil',['GeoController']);

  HyperImagesTreeView1.PruneDataNotInDirs(GeoController.AllDirs);
end;

procedure TBrowseMaps.ShowLevel(Level, Score : Integer);
begin
  ShowMessage('Level '+IntToStr(Level) +Chr(13)+Chr(10)+
     'Score '+IntToStr(Score));
end;

procedure TBrowseMaps.AddHyperImages;
var i : integer;
begin
  with HyperImagesTreeView1 do begin
    OnChange := nil;
    Items.Clear;
    BeginUpdate;
    Directory := ExtractFilePath(Application.ExeName);
    PruneBadDirs; //prima!
    IterateTree(AddHyperImage); // dopo!
    CurrentHyperImagesScrollBox := nil;
    EndUpdate;
    OnChange := OnTreeChange;
  end;
end;
{
procedure TBrowseMaps.UpdateHyperImages;
var i : integer;
begin
  with HyperImagesTreeView1 do begin
    OnChange := nil;
    Items.Clear;
    BeginUpdate;
    Directory := ExtractFilePath(Application.ExeName);
    PruneBadDirs; //prima!
    IterateTree(AddHyperImage); // dopo!
    CurrentHyperImagesScrollBox := nil;
    EndUpdate;
    OnChange := OnTreeChange;
  end;
end;

}
function TBrowseMaps.AddHyperImage(Node : TTreeNode) : boolean;
var CName : String;

  {
    given a string, checks if as a FileName is the right mute property
  }

  function IsValidMute( FileName : String) : boolean;
  var isMute : boolean;
  begin
    IsMute := Pos('m.',FileName) > 0;
    result :=  GeoController.ClearedMaps = IsMute;
  end;

  {
    compares a file name with the node text, replacing the m subfix if necessary
  }

  procedure CheckEqual(Node : TTreeNode;  FileName : String);
  var PosM: integer;
      NodeText : String;
  begin
    if (Node = nil) then
      raise EInvalidArgument.Create('CheckEqual - Node is null');
    if (FileName = '') then
      exit; // nothing to change
    NodeText := Node.Text;
    if Length(FileName) <> Length(NodeText) then
      exit; // nothing to change


    if GeoController.ClearedMaps then begin
      PosM := Length(NodeText);
      if (NodeText[PosM] = 'm') and (Copy(NodeText,1,PosM-1) = Copy(FileName,1,Posm-1)) then begin
        NodeText[Posm] := FileName[Posm];
        Node.Text := Node.Text;
      end;
    end;
  end;


begin
  if (HyperImagesTreeView1 = nil) then
    raise EBrowseMapsException.Create('TBrowseMaps.AddHyperImage - HyperImagesTreeView1 is nil');
  if (Node = nil) then
    raise EBrowseMapsException.Create('TBrowseMaps.AddHyperImage - Node is nil');
  if (CurrFullText = '') then begin
    Node.Data := nil;
    CurrFullText := String(Node.Text);
    exit;
  end;
       // the original tree is a file directory, the image is coupled with the directory where it is put
       // very difficult to understand

  with HyperImagesTreeView1 do begin
    CName := String(Node.Data);
    // preloads all HyperImages just for sutre
    Node.Data := CreateHyperImage(ExtractFilePath(Cname), ExtractFileName(Cname));

    if not Node.HasChildren then begin
      if IsValidMute(CName) then begin
        if Node.Parent <> nil then
          Node.Parent.Data := Node.Data;

        CurrValNode := Node;
        //  CurrFullText is set for the following loop
        CheckEqual(CurrValNode,CurrFullText);

      end
      else begin
        CurrFullText := String(Node.Text);
      end;
    end;
  end;
end;



procedure TBrowseMaps.OnTreeChange(Sender: TObject;
  Node: TTreeNode);
var
  CNode : TTreeNode;
  CName : String;
  NewHyperImagesScrollbox : THyperImageSSCrollBox;
begin
  if Node <> nil then begin
    if (Node.Data <> nil) then begin
      NewHyperImagesScrollbox := THyperImageSSCrollBox(Node.Data);

      if not NewHyperImagesScrollbox.DoLoad then
        exit;
      if CurrentHyperImagesScrollBox <> nil then
        CurrentHyperImagesScrollBox.Visible := false;
      CurrentHyperImagesScrollBox := NewHyperImagesScrollbox;
      CurrentHyperImagesScrollBox.Visible := True;

      // updats suts Burs
      with CurrentHyperImagesScrollBox do begin
        HorzScrollBar.Position := (HyperImages.Width - Width) div 2;
        VertScrollBar.Position := (HyperImages.Height - Height) div 2;
      end;


      // updates zoomer stuff
      ZoomerPanel1.HYperImages := CurrentHyperImagesScrollBox.HyperImages;
      ZoomerPanel1.ZoomScrollBar.Position := CurrentHyperImagesScrollBox.HyperImages.Scale;

      FileImg := NewHyperImagesScrollbox.PicturesDir+NewHyperImagesScrollbox.ImageFileName;
      if (not FileExists(FileImg)) then
        exit;           // Data could come form the node below
      // loads images in the small Image on the right bottom

      Image1.Picture.LoadFromFile(FileImg);

    end;
  end;
end;

// Creates Tree View on load
procedure TBrowseMaps.CreateTreeView(var TreeView : THyperImagesTreeView);
begin
  if TreeView = nil then begin
    TreeView := THyperImagesTreeView.Create(Self);
    with TreeView do begin
      Align := AlClient;
      Parent := Panel1;
    end
  end;
end;

procedure TBrowseMaps.Init;
begin
  CreateTreeView(HyperImagesTreeView1);
  AddHyperImages;           // dopo
  if HyperImagesTreeView1.Items.Count <= 1 then
    HyperImagesTreeView1.Visible := false else
    HyperImagesTreeView1.Visible := true;
//  CurrFullText := '';
end;

procedure TBrowseMaps.FormShow(Sender: TObject);
var i : integer;
  Node : TTreeNode;
  HyperImagesScrollBox : THyperImagesScrollBox;

begin
  Init;
  for i := 0 to HyperImagesTreeView1.Items.Count-1 do begin
    Node :=  HYperImagesTreeView1.Items[i];
    if (Node.Data <> Nil) then begin
      HyperImagesScrollBox := THyperImagesScrollBox(Node.Data);
      with AReg, HyperImagesScrollBox  do begin
        Active := True;
        HyperImages.Scale := RSInteger('Scales',ExtractFileName(FileName),100);
        Active := False;
      end;
    end;
  end;
  ZoomerPanel1.NormalZoom := GeoController.InterfaceOptions.NormalZoom;
  with AReg do begin
    Active := True;
    Panel1.Width := RSInteger('Forms','TreePanelWidth',Panel1.Width);
    Left := RSinteger('Forms','BrowseMapsLeft',Left);
    Top := RSinteger('Forms','BrowseMapsTop',Top);
    Width := RSinteger('Forms','BrowseMapsWidth',Width);
    Height := RSinteger('Forms','BrowseMapsHeight',Height);
    Active := False;
  end;
  HyperImagesTreeView1.Selected := HyperImagesTreeView1.Items[HyperImagesTreeView1.Items.Count-1];

end;



procedure TBrowseMaps.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TBrowseMaps.FormClose(Sender: TObject; var Action: TCloseAction);
var i : integer;
  HyperImagesScrollBox : THyperImagesScrollBox;
  Node : TTreeNode;

begin

  for i := 0 to HYperImagesTreeView1.Items.Count-1 do begin
    Node :=  HyperImagesTreeView1.Items[i];
    If Node.Data <> Nil then begin
      HyperImagesScrollBox := THyperImagesScrollBox(Node.Data);
      with AReg, HyperImagesScrollBox do begin
        Active := True;
        WSInteger('Scales',ImageFileName,HyperImages.Scale);
        Active := false;
      end;
      HyperImagesScrollBox.Free;
    end;
  end;
  HyperList.Clear;
  HyperImagesTreeView1.Free;
  HyperImagesTreeView1 := nil


end;

procedure TBrowseMaps.FormResize(Sender: TObject);
begin
  SpeedButton1.Left := Width-40;
end;

procedure TBrowseMaps.StatusPanelResize(Sender: TObject);
begin
  StatusBar1.Font.Size := StatusBar1.Height div 3;
end;

procedure TBrowseMaps.FormCreate(Sender: TObject);
begin
  PCHANDLE := 5;
  HyperList := TList.Create;
  try
    Screen.Cursors[PCHandle] := LoadCursorFromFile('pointer.cur');
    Image1.Cursor := PCHandle
  except on Exception do
    ShowMessage('Missing Cursor file');
  end;
end;

procedure TBrowseMaps.FormHide(Sender: TObject);
var i  : integer;
  HyperImagesScrollBox : THyperImagesScrollBox;
begin
  with AReg do begin
    Active := True;
    WSInteger('Forms','TreePanelWidth',Panel1.Width);
    WSinteger('Forms','BrowseMapsLeft',Left);
    WSinteger('Forms','BrowseMapsTop',Top);
    WSinteger('Forms','BrowseMapsWidth',Width);
    WSinteger('Forms','BrowseMapsHeight',Height);
    Active := False;
  end;

  for i := 0 to HyperList.Count-1 do begin
    HyperImagesScrollBox := HyperList.Items[i];
    with AReg, HyperImagesScrollBox do begin
      ACtive := True;
      WSInteger('Scales',ImageFileName,HyperImages.Scale);
      Active := false;
    end;

  end;

end;

procedure TBrowseMaps.NewBtnClick(Sender: TObject);
begin
 if GeoController.CanStartGame then begin
    CurrGame := TGeoGame.Create(Self,GeoController.Difficulty);
    CurrGame.NextLevel;

  end else begin
    MessageBox(0,'No maps selected!','Warning',0);
    OptionsForm.Show;
  end;
end;

procedure TBrowseMaps.UserBtnClick(Sender: TObject);
begin
  UserForm.Show;
end;

procedure TBrowseMaps.SpeedButton2Click(Sender: TObject);
begin
  OptionsForm.Show;
end;

procedure TBrowseMaps.SpeedButton3Click(Sender: TObject);
begin
  ColorForm.Show;
end;

procedure TBrowseMaps.DifficultySpeedButtonClick(Sender: TObject);
begin
    DifficultyForm.Show;
end;

procedure TBrowseMaps.SpeedButton6Click(Sender: TObject);
begin
  ScoreForm.Show;
end;

procedure TBrowseMaps.SpeedButton7Click(Sender: TObject);
begin
  RegisterForm.Show;
  if RegisterForm.Registered then
    Caption := 'Geoclick by Diego Amicabile';

end;

procedure TBrowseMaps.SpeedButton5Click(Sender: TObject);
begin
  ShowWebPage(ExtractFilePath(Application.Exename)+'Geoclick1.chm');
end;

procedure TBrowseMaps.SpeedButton8Click(Sender: TObject);
begin
//   ShowWebPage('http://clickit.pair.com/maps/');

end;


procedure TBrowseMaps.SpeedButton9Click(Sender: TObject);
begin
  GeoClickAboutBox.Show;
end;

procedure TBrowseMaps.ExitBtnClick(Sender: TObject);
begin
   Close
end;


procedure TBrowseMaps.Image1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var XREL,YREL : Real;
begin
  XREL := Round(X)/Round(Image1.Width);
  YREL := Round(Y)/Round(Image1.Height);
  if CurrentHyperImagesScrollBox <> nil then
    CurrentHyperImagesScrollBox.Center(XREL,YREL)
end;

procedure TBrowseMaps.ZoomInSpeedButtonClick(Sender: TObject);
begin
  if CurrentHyperImagesScrollBox <> nil then
    CurrentHyperImagesScrollBox.Zoomin
end;

procedure TBrowseMaps.ZoomOutSpeedButtonClick(Sender: TObject);
begin
  if CurrentHyperImagesScrollBox <> nil then
    CurrentHyperImagesScrollBox.ZoomOut
end;

procedure TBrowseMaps.SpeedButton4Click(Sender: TObject);
begin
  AddHyperImages
end;


initialization
  EmptyStringList := TStringList.Create;

end.
