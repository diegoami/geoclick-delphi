unit uListBrowseMaps;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  uBrowseMaps, ComCtrls, ExtCtrls, HyperImagesScrollBox, GeoListView,
  dccommon, utils, Buttons, Menus, RxMenus, UGeogame, MPlayer, OvalButtonsPanel,
  dccontrols, ImgList, ActnList;

type
  TListBrowseMaps = class(TBrowseMaps)
    Panel2: TPanel;
    TabControl1: TDCTabControl;
       RxMainMenu1: TRxMainMenu;
        MenuItem4: TMenuItem;
    ExitItem: TMenuItem;
    UserItem: TMenuItem;
    MenuItem6: TMenuItem;
    HotspotsItem: TMenuItem;
    Environment: TMenuItem;
    DifficultyItem: TMenuItem;
    MenuItem10: TMenuItem;
    NewGameItem: TMenuItem;
    Maps1: TMenuItem;
    Scores1: TMenuItem;
    MenuItem13: TMenuItem;
    About1: TMenuItem;
    ContentsItem: TMenuItem;
    MenuItem16: TMenuItem;
    DownloadMenuItem: TMenuItem;
    Registration1: TMenuItem;
    ImageList2: TImageList;
    Timer1: TTimer;
    N1: TMenuItem;
    ZoomInMenuItem: TMenuItem;
    ZoomOutMenuItem: TMenuItem;
    ActionList1: TActionList;
    HotSpotEditAction: TAction;
    EditHotSpotSpeedButton: TSpeedButton;
    AddTabAction: TAction;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    DeteteTabAction: TAction;
    procedure TabControl1Change(Sender: TObject);


    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure UserBtnClick(Sender: TObject);
    procedure RxMainMenu1GetImageIndex(Sender: TMenu; Item: TMenuItem;
      State: TMenuOwnerDrawState; var ImageIndex: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure EditHotSpotSpeedButtonClick(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure HotSpotEditActionExecute(Sender: TObject);
    procedure AddTabActionExecute(Sender: TObject);
    procedure DeteteTabActionExecute(Sender: TObject);
  private
    isWindowClosing : boolean;
    mustCenter : boolean;
    FormerCaption : String;
    StatusBarStrings : TStrings;
    willIncrement : boolean;
    function GetCurrentPartialFileName : String;
    function GetTotalFileName : String;
  protected
    FileImg : String;
    ListView : TGeoListView;
    FCUrrFile : String;
    procedure OnTreeChange(Sender: TObject; Node: TTreeNode); override;
    procedure ListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ListEdited(Sender: TObject; Item: TListItem; var S: string);
    procedure HyperImagesScrollBox1HotSpotClicked(Sender : TObject; HotSpot: String; X, Y :integer); override;
    procedure AddHyperImages; override;

  public
    procedure Init; override;
    procedure GameOver;
    procedure LoadQuiz(NT : integer; NS : Integer);
    procedure Wait;

  end;

var
  ListBrowseMaps: TListBrowseMaps;

implementation

uses uGeoController, uOptionsForm, uUserForm, uQuizMaps, uScoreForm,
  uRegisterForm, uWebUrl, uMaplist, HSedit, uTxtField;

{$R *.DFM}

procedure TListBrowseMaps.AddHyperImages;
var i : Integer;
begin
  inherited;
  with HyperImagesTreeView1 do begin
    for i := Items.Count-1 downto 0 do
                // deletes file name stuff
      if Items[i].ImageIndex = 3 then
        Items[i].Delete
  end;
end;

procedure TListBrowseMaps.LoadQuiz(NT : integer; NS : Integer);
begin
  if (CurrGame.Level = 1) then begin
    QuizMaps.Init; // importante!
  end;
  try
    QuizMaps.LoadQuiz(NT,NS);
    QuizMaps.Show;
    QuizMaps.OvalButtonsPanel1.Resize;
  except on ENoValues do begin
    GameOver;
    raise;
    end;
  end;


end;

procedure TListBrowseMaps.GameOver;
begin
  ShowMessage('GAME OVER' +Chr(13)+Chr(10)+
     'Score '+IntToStr(Currgame.Score));
  ScoreForm.AddScore(GeoController.Username,Currgame.Score);
  ScoreForm.Save;

end;

procedure TListBrowseMaps.OnTreeChange(Sender: TObject; Node :TTreeNode);
var
  i, j : integer;
  AllHSF : TStrings;
begin
  inherited;
  if (GeoController = nil) then
    raise EBrowseMapsException.Create('TListBrowseMaps.OnTreeChange - Geocontroller was nil');
  if node = nil then exit;
  TabControl1.Tabs.Clear;
  // adds tabs
  if CurrentHyperImagesScrollBox <> nil then begin
    TabControl1.Tabs.AddStrings(GeoController.GetAllFilesForDirWithoutExt(CurrentHyperImagesScrollBox.PicturesDir));
    TabControl1Change(Self);
  end;
end;

function TListBrowseMaps.GetCurrentPartialFileName : String;
var partialFileName : String;
begin
  result := TabControl1.Tabs[TabControl1.TabIndex]+'.hsf';
end;

function TListBrowseMaps.GetTotalFileName : String;
var totalFileName : String;
begin
  result := CurrentHyperImagesScrollBox.PicturesDir +GetCurrentPartialFileName;
end;


procedure TListBrowseMaps.TabControl1Change(Sender: TObject);
var partialFileName : String;
begin
  inherited;
  if CurrentHyperImagesScrollBox = nil then
    raise EBrowseMapsException.Create('TListBrowseMaps.TabControl1Change - CurrentHyperImagesScrollBox was nil');
  ListView.OnChange := nil;
  ListView.OnEdited := nil;
  PartialFileName := GetCurrentPartialFileName;
  FCurrFile := GetTotalFileName;
  CurrentHyperImagesScrollBox.ReadHotSpotFromFile(PartialFileName,true);
  ListView.LoadNamesFromFile(FCurrFile);
  ListView.Load(false);
  ListView.OnChange := ListChange;
  ListView.OnEdited := ListEdited;
  ActiveControl := ListView;
end;

procedure TListBrowseMaps.Init;
begin
  inherited;
  ListView := TGeoListView.Create(TabControl1);
  ListView.IconOptions.Arrangement := iaTop;
  with ListView do begin
    ReadOnly := False;
    Align := alClient;
    Parent := TabControl1;
    CheckedItems := false;
    OnChange := ListChange;
    OnEdited := ListEdited;
  end;
  with AReg do begin
    Active := True;
    Panel2.Height := RSInteger('Forms','ListBrowsePanel2',120);
    Active := False;
  end;

end;

procedure TListBrowseMaps.ListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
var MP : Tpoint;

begin
  if (CurrentHyperImagesScrollBox = nil) or (ListView = nil) or isWindowClosing then exit;
  if (ListView.Items.Count > 0) then begin
    CurrentHyperImagesScrollBox.ShowHotSpot(Item.Caption,mustCenter);
    StatusBarStrings.Clear;
    StatusBarStrings.Add(Item.Caption);
    UpdateStatusBars(StatusBarStrings);
  end;
end;

// changes hot spot name

procedure TListBrowseMaps.ListEdited(Sender: TObject; Item: TListItem; var S: string);
begin
  if CurrentHyperImagesScrollBox = nil then
    raise EBrowseMapsException.Create('TListBrowseMaps.ListEdited - CurrentHyperImagesScrollBox was nil');

  CurrentHyperImagesScrollBox.WriteHotSpot(Item.Caption,S);
  ListView.WriteHotSpotToFile(FCurrFile,Item.Caption,S);
end;


procedure TListBrowseMaps.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  with AReg do begin
    Active := True;
    WSInteger('Forms','ListBrowsePanel2',Panel2.Height);
    if HyperImagesTreeView1 <> nil then begin
      if HyperImagesTreeView1.Selected <> nil then
        WSInteger('Forms','HyperSelected',HyperImagesTreeView1.Selected.AbsoluteIndex);
      if HyperImagesTreeView1.TopItem <> nil then
        WSInteger('Forms','HyperTopItem',HyperImagesTreeView1.TopItem.AbsoluteIndex);
    end;
    Active := False;
  end;

  inherited;

  isWindowClosing := True;
  TabControl1.Tabs.Clear;
  ListView.Free;
  StatusBarStrings.Free;
  if WillIncrement then
    RegisterForm.DoLeave


end;



procedure TListBrowseMaps.FormShow(Sender: TObject);
begin
  inherited;
  Init;
  if (not RegisterForm.Registered) and (RegisterForm.Times > TimeToRegister) then Application.Terminate;
  isWindowClosing := false;
  with AReg do begin
    Active := True;
    try
      HyperImagesTreeView1.Selected := HyperImagesTreeView1.Items[RSInteger('Forms','HyperSelected',HyperImagesTreeView1.Items.Count-1)];

      HyperImagesTreeView1.TopItem := HyperImagesTreeView1.Items[RSInteger('Forms','HyperTopItem',0)];
    except on ETreeViewError do
      Active := False;
    end;
  end;
  // now tries to show a mp
  while ( HyperImagesTreeView1.Selected = nil) or (CurrentHyperImagesScrollBox = nil) do begin
    HyperImagesTreeView1.Selected := HyperImagesTreeView1.Items[HyperImagesTreeView1.Items.Count-1];
    OnTreeChange(Self,HyperImagesTreeView1.Selected);
  end;
end;

procedure TListBrowseMaps.HyperImagesScrollBox1HotSpotClicked(Sender : TObject; HotSpot: String; X, Y :integer);
var ListItem : TListItem;
begin
  inherited;
  mustCenter := False;     // not Centering
  ListItem := ListView.FindCaption(0,HotSpot,false,true,false);
  mustCenter := True;
  if ListItem <> nil then begin

    ListItem.MakeVisible(True);
    ListView.Selected := ListItem;

  end;
end;



procedure TListBrowseMaps.SpeedButton1Click(Sender: TObject);
begin
  Close;

end;

procedure TListBrowseMaps.NewBtnClick(Sender: TObject);
begin
  if (GeoController = nil) then
    raise EBrowseMapsException.Create('TListBrowseMaps.NewBtnClick - Geocontroller was nil');

   if GeoController.CanStartGame then begin
    //UserForm.ShowModal;
    CurrGame := TGeoGame.Create(Self,GeoController.Difficulty);

    CurrGame.NextLevel;
    WillIncrement := True;

  end else begin
    MessageBox(0,'No maps selected!','Warning',0);
    OptionsForm.Show;
  end;

end;

procedure TListBrowseMaps.UserBtnClick(Sender: TObject);
begin
  UserForm.Show;

end;

procedure TListBrowseMaps.RxMainMenu1GetImageIndex(Sender: TMenu;
  Item: TMenuItem; State: TMenuOwnerDrawState; var ImageIndex: Integer);
begin

begin
  if Item = NewGameItem then
    ImageIndex :=  0
  else if Item = UserItem then
    ImageIndex :=  1
  else if Item = ExitItem then
    ImageIndex :=  12
  else if Item = HotspotsItem then
    ImageIndex :=  2
  else if Item = Environment then
    ImageIndex :=  3
  else if Item = DifficultyItem then
    ImageIndex :=  4
  else if Item = Maps1 then
    ImageIndex :=  11
  else if Item = Scores1 then
    ImageIndex :=  5

  else if Item = ContentsItem then
    ImageIndex := 7
  else if Item = DownloadMenuItem then
    ImageIndex := 8
  else if Item = Registration1 then
    ImageIndex := 6
   else if Item = ZoomInMenuItem then
    ImageIndex := 9
  else if Item = ZoomOutMenuItem then
    ImageIndex := 10



end;


end;

procedure TListBrowseMaps.Timer1Timer(Sender: TObject);
begin
  inherited;
  Timer1.Enabled := False;
  CurrGame.StartLevel;
end;

procedure TListBrowseMaps.Wait;

begin
  Timer1.Enabled := true;
end;


procedure TListBrowseMaps.ExitBtnClick(Sender: TObject);
begin

  if Application.MessageBox('Are you sure you want to leave?', 'Confirmation', MB_OKCANCEL)
    = ID_OK then Close

end;

procedure TListBrowseMaps.EditHotSpotSpeedButtonClick(Sender: TObject);
begin
  inherited;
  AddHyperImages
end;

procedure TListBrowseMaps.SpeedButton11Click(Sender: TObject);
begin
  inherited;
  WebForm.Show
end;

procedure TListBrowseMaps.SpeedButton4Click(Sender: TObject);
var CA : TCloseAction;
    OldTreeChange : TTVChangedEvent;
begin
  inherited;
  OptionsForm.FormCreate(Self);
  FormClose(Self,CA);
  FormShow(Self);
end;

procedure TListBrowseMaps.FormCreate(Sender: TObject);
begin
  inherited;

  WillIncrement := false;
  mustCenter := True;
  StatusBarStrings := TStringList.Create

end;

procedure TListBrowseMaps.SpeedButton8Click(Sender: TObject);
begin
  inherited;
  MapListForm.SHowModal;
  if MapListForm.Modified then
    SpeedButton4Click(Self);
end;

procedure TListBrowseMaps.HotSpotEditActionExecute(Sender: TObject);
var pfn : String;
begin
  inherited;
  EditHyperImages(CurrentHyperImagesScrollBox.HyperImages,true, CurrentHyperImagesScrollBox.HyperImages.PicturesDir);
  pfn := GetTotalFileName;
  if (HSEditForm.Modified) then begin
    ListView.OnChange := nil;
    ListView.OnEdited := nil;

    CurrentHyperImagesScrollBox.HyperImages.HotspotsDef.SaveToFile(pfn);
    ListView.LoadNamesFromFile(pfn);
    ListView.Load(true);
    ListView.OnChange := ListChange;
    ListView.OnEdited := ListEdited;

  end;


end;

procedure TListBrowseMaps.AddTabActionExecute(Sender: TObject);
var TextFieldDialog : TTextFieldDialog;
        F: TextFile;

begin
  inherited;
  TextFieldDialog := TTextFieldDialog.Create(self);
  TextFieldDialog.ShowModal;
  if (not TextFieldDialog.Canceled) then begin
    TabControl1.Tabs.Add(TextFieldDialog.Text);
    TabControl1.TabIndex := TabControl1.Tabs.Count-1;


    AssignFile(F, GetTotalFileName);
    Rewrite(F);
    CloseFile(F);
    TabControl1Change(TabControl1);


  end;
  TextFieldDialog.Free;
end;




procedure TListBrowseMaps.DeteteTabActionExecute(Sender: TObject);
begin
  inherited;
  if ((ListView.Items.Count <= 0) and
       (Application.MessageBox('Are you sure you want to remove this definition file? ',
                              'Question'          ,  MB_OKCANCEL + MB_DEFBUTTON1) = IDOK)
      ) then begin

    DeleteFile(GetTotalFileName);
    TabControl1.Tabs.Delete(TabControl1.TabIndex);

    if (TabControl1.Tabs.Count > 0) then begin
      TabControl1.TabIndex := 0;
      TabControl1Change(TabControl1);
    end;

  end;


end;

end.
