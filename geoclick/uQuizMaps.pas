unit uQuizMaps;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  uBrowseMaps, ComCtrls, ExtCtrls, HyperImagesScrollBox, uGeoController,
  Buttons, utils, StdCtrls,  MPlayer, uOvalButtonsPanel, ImgList;

type
  TQuizMaps = class(TBrowseMaps)
    ProgressBar1: TProgressBar;

    ScrollBox1: TScrollBox;
   
    ProgressBarTimer: TTimer;
    CloseFormTimer: TTimer;
    EndLevelTimer: TTimer;
    Label1: TLabel;
    OvalButtonsPanel1: TOvalButtonsPanel;
    Timer1: TTimer;
    procedure ScrollBox1Resize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OvalButtonsPanel1AllGuessed;
    procedure ProgressBarTimerTimer(Sender: TObject);
    procedure CloseFormTimerTimer(Sender: TObject);
    procedure EndLevelTimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormHide(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure MediaPlayer1Notify(Sender: TObject);
  private
    CS : String;
    first, EndLevel, EndGame : Boolean;
    FS : TColor;
  protected
    function WhichHsf(Dir : String) : TStrings; override;
    procedure HyperImagesScrollBox1HotSpotClicked(Sender : TObject; HotSpot: String; X, Y :integer); override;
    procedure HyperImagesScrollBox1HotSpotsClicked(HotSpots: TStrings); override;
    procedure PruneBadDirs; override;
    procedure SetDisable;
    procedure AddHyperImages; override;
  public
    procedure LoadQuiz(NB : integer; Sec : Integer);
  end;

var
  QuizMaps: TQuizMaps;

implementation

uses uGeoGame, uListBrowseMaps;

procedure TQuizMaps.SetDisable;
var R,G,B : integer;
begin
  getRGB(GeoController.ButtonOptions.Font.Color,r,g,b);
  r := 255 - r;
  g := 255 - g;
  b := 255 - b;
  OvalButtonsPanel1.DisableColor := rgb(r,g,b);
end;


procedure TQuizMaps.LoadQuiz(NB : integer; Sec : Integer);
var i, ISS : integer;
  TSL,TRL : TStrings;
  ES : String;
begin
  OvalButtonsPanel1.NButtons := NB;

  ProgressBar1.Max := Sec;
  ProgressBar1.Position := Sec;
  ProgressBarTimer.Enabled := True;
  TRL := TStringList.Create;
  TSL := TStringList.Create; {
  for i := 0 to HyperList.Count-1 do
    TSL.AddStrings(THyperImagesScrollBox(HyperList.Items[i]).GetHotspotsList);}
  for i := 0 to GeoController.HSFFiles.Count-1 do begin
    TRL.Clear;
    THyperImagesScrollBox.AddHotspotFromFile(GeoController.HSFFiles.Strings[i],TRL);


    TSL.AddStrings(TRL);
  end;

  if (TSL.COunt <= NB)  then begin
    MessageBox(0,'Not enough hotspots!','Warning',0);
    if CurrGame <> nil then
      CurrGame.Gameover
  end;

  for i := 0 to GeoController.ExcludeNames.Count-1 do begin
    ES := GeoController.ExcludeNames.Strings[i];
    ISS := TSL.IndexOf(ES);
    if ISS <> -1 then
      TSL.Delete(ISS);
  end;
  try
    CurrGame.ScoreModifier := Round(TSL.Count)/100+(30-GeoController.spq)/10+(50-GeoController.qpl)/50;
  except on EinValidOP do
    CurrGame.ScoreModifier := 1
  end;

  OvalButtonsPanel1.PossibleValuesList := TSL;
  try
    OvalButtonsPanel1.GenerateTest(OvalButtonsPanel1.NButtons);
  except on ENoValues do begin

      CurrGame.GameOver;
      ProgressBarTimer.Enabled := False;
      raise;
    end;
  end;

  ScrollBox1Resize(Self);
  TSL.Free;
  TRL.Free;
end;
{$R *.DFM}

function TQuizMaps.WhichHsf(Dir : String) : TStrings;
begin
  result := GeoController.GEtCheckedFilesInDir(Dir);
end;

procedure TQuizMaps.AddHyperImages;
var i : Integer;
begin
   inherited;
   with HyperImagesTreeView1 do begin
     for i := Items.Count-1 downto 1 do
       if Items[i].ImageIndex = 3 then
         Items[i].Delete
   end;
end;


procedure TQuizMaps.PruneBadDirs;
begin
  HyperImagesTreeView1.PruneDataNotInDirs(GeoController.GEtCheckedDirs);
end;

procedure TQuizMaps.FormShow(Sender: TObject);
begin
  if CurrentHyperImagesScrollBox <> nil then
  //  CurrentHyperImagesScrollBox.HyperImages.DeleteInverted;
    with AReg do begin
    Active := True;
    //StatusPanel.Height := RSInteger('Forms','QuizMapsStatusPanel',20);
    //ScrollBox1.Height := RSInteger('Forms','QuizMapsScrollBox',120);

    Active := False;
  end;


  inherited;
  EndGame := False;
  EndLevel := False;
  OvalButtonsPanel1.EndRush := False;
  OvalButtonsPanel1.ButtonWidth := GeoController.ButtonOptions.Width;
  OvalButtonsPanel1.FaceColor := GeoController.ButtonOptions.FaceColor;
  OvalButtonsPanel1.SelectColor := GeoController.ButtonOptions.SelColor;
  OvalButtonsPanel1.SetFont(GeoController.ButtonOptions.Font);
  ScrollBox1Resize(Self);
  SetDisable;
  OvalButtonsPanel1.SelectFirst;




  StatusBar1.Font.Size := StatusBar1.Height div 3;
  HyperImagesTreeView1.Selected := HyperImagesTreeView1.Items[HyperImagesTreeView1.Items.COunt-1];
  OnTreeChange(Self,HyperImagesTreeView1.Selected);
end;

procedure TQuizMaps.ScrollBox1Resize(Sender: TObject);
begin
  OvalButtonsPanel1.Height := ScrollBox1.Height;
  OvalButtonsPanel1.Resize;
end;

procedure TQuizMaps.HyperImagesScrollBox1HotSpotClicked(Sender : TObject; HotSpot: String; X, Y : integer);
begin
  if EndLevelTimer.Enabled then exit;
  inherited;
  if not (OvalButtonsPanel1.GetCurrentString = HotSpot) then
    CurrGame.AddScore( - ((Sender As THyperImagesScrollBox).GetDistanceFrom(OvalButtonsPanel1.GetCurrentString,X,Y)) div 2);
  StatusBar1.Panels[3].Text := 'Score : ' + IntToStr(Currgame.Score);
end;

procedure TQuizMaps.HyperImagesScrollBox1HotSpotsClicked(HotSpots: TStrings);
var i : integer;
  HasGuessed : Boolean;
  CurrStr : String;
begin
  if EndLevelTimer.Enabled then exit;
  inherited;
  HasGuessed := False;
  for i := 0 to Hotspots.Count-1 do begin
    CurrStr := Hotspots.Strings[i];
    if CurrStr = OvalButtonsPanel1.GetCurrentString then
      HasGuessed := True
  end;
  if HasGuessed then begin

    CurrentHyperImagesScrollBox.ShowHotspot(OvalButtonsPanel1.GetCurrentString,false);
    OvalButtonsPanel1.Guessed;
    CurrGame.AddScore(100);

    StatusBar1.Panels[3].Text := 'Score : ' + IntToStr(Currgame.Score);
    GeoController.PlaySound('Whistle')
  end else
    //GeoController.PlaySound('Uugh1');
      GeoController.PlaySound('No2');
end;

procedure TQuizMaps.OvalButtonsPanel1AllGuessed;
begin
  CurrGame.AddEndScore(ProgressBar1.Position);
  StatusBar1.Panels[3].Text := 'Score : ' + IntToStr(CurrGame.Score);
  GeoController.PlaySound('Applaude');
  ProgressBarTimer.Enabled := False;
  EndLevel := True;
  CloseFormTimer.Enabled := True;

end;


procedure TQuizMaps.ProgressBarTimerTimer(Sender: TObject);
begin
  inherited;
  ProgressBar1.Position := ProgressBar1.Position-1;
  If ProgressBar1.Position = 0 then begin
    ProgressBarTimer.Enabled := False;
    ProgressBar1.Position := ProgressBar1.Max;
    First := True;
    EndLevelTimer.Enabled := True;
    GeoController.PlaySound('Sound10');

  end 
end;

procedure TQuizMaps.CloseFormTimerTimer(Sender: TObject);

begin
  inherited;
  CloseFormTimer.Enabled := False;

  ProgressBarTimer.Enabled := False;

  if not EndGame then begin
    CurrGame.NextLevel;

    Close;
  end else
    Close;
  
end;

procedure TQuizMaps.EndLevelTimerTimer(Sender: TObject);
var
  i : Integer;
  RS : THyperImagesScrollBox;
  NN : TTreeNode;
  COB : integer;
begin
  inherited;
  //EndLevelTimer.Interval := 2500;
  COB := OValButtonsPanel1.GetCurrOrdButton;
  OValButtonsPanel1.EndRush := True;
  if First then begin

    //FS := OvalButtonsPanel1.SelectColor;
    //OvalButtonsPanel1.SelectColor := OvalButtonsPanel1.FAceColor;

    OvalButtonsPanel1.OnAllGuessed := nil;
    OvalButtonsPanel1.Disappear := False;
  end;
  CS := OvalButtonsPanel1.GetCurrentString;

  RS := nil;
  if CS <> '' then begin
    for i := HyperImagesTreeView1.Items.Count-1 downto 0 do begin
      NN := HyperImagesTreeView1.Items.Item[i];
      if NN = nil then exit;
      if  (not (NN.Data = nil)) then begin
        RS := THyperImagesScrollBox(NN.data);
        if RS = nil then exit;
        if RS.IsHotSpotIn(CS) then
          break;
      end;
    end;
    if i = HyperImagesTreeView1.Items.Count then begin
      raise Exception.Create('Hotspot not found');
      exit;
    end;
    if (CurrentHyperImagesScrollBox <> nil) and (CurrentHyperImagesScrollBox <> RS) then begin

      CurrentHyperImagesScrollBox.Visible := False;
      CurrentHyperImagesScrollBox := RS;
      CurrentHyperImagesScrollBox.Visible := True;
      CurrentHyperImagesScrollBox.DoLoad
//      exit;
    end;{else begin }
      OvalButtonsPanel1.Guessed;
      if COB = 1 then
       ScrollBox1.HorzScrollBar.Position := 0
      else
        ScrollBox1.HorzScrollBar.Position := ScrollBox1.HorzScrollBar.Position+ OvalButtonsPanel1.ButtonWidth * 3 div 2;

      CurrentHyperImagesScrollBox.ShowHotSpot(CS,true);
      //ZoomerPanel1.HYperImages := CurrentHyperImagesScrollBox.HyperImages;
      //ZoomerPanel1.ZoomScrollBar.Position := CurrentHyperImagesScrollBox.HyperImages.Scale;
//    end;
    First := False;
  end else begin

    EndLevelTimer.Enabled := False;
    //EndLevelTimer.Interval := 500;
    ScrollBox1.HorzScrollBar.Position := 0;
    CurrentHyperImagesScrollBox.Visible := False;
    SetDisable;
//    OvalButtonsPanel1.SelectColor := FS;
    //OvalButtonsPanel1.Disappear := True;
    OvalButtonsPanel1.OnAllGuessed := OvalButtonsPanel1AllGuessed;

    {if CurrGame <> nil then
      CurrGame.GameOver;}
    EndLevel := False;
    EndGame := True;
//    CloseFormTimer.Enabled := True;
    Close;
  end;
end;

procedure TQuizMaps.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  if CloseFormTimer.Enabled or EndLevelTimer.Enabled then
    CanClose := False;

    if EndLevel then
      ProgressBarTimer.Enabled := False
    else if EndGame or ((MessageDlg('Abort Current Game ?', mtConfirmation,
     [mbYes, mbNo], 0) = mrYes)) then begin
       ProgressBarTimer.Enabled := False;
       if CurrGame <> nil then
         CurrGame.GameOver
    end else
      CanClose := False;


  {else begin
    if EndLevel then
      ProgressBarTimer.Enabled := False
    else if EndGame or ((MessageDlg('Abort Current Game ?', mtConfirmation,
     [mbYes, mbNo], 0) = mrYes)) then begin
       ProgressBarTimer.Enabled := False;
       if CurrGame <> nil then
       CurrGame.GameOver
    end else CanClose := False;


  end;        }

  {if CurrGame <> nil then
    CurrGame.GameOver;}
  //SpeedButton1Click(Sender);

end;

procedure TQuizMaps.FormHide(Sender: TObject);
begin
  inherited;
  with AReg do begin
    Active := True;
//    WSInteger('Forms','QuizMapsScrollBox',ScrollBox1.Height);
//    WSInteger('Forms','QuizMapsStatusPanel',StatusPanel.Height);
    Active := False;
  end;
{  if EndLevel then
      ProgressBarTimer.Enabled := False
    else if EndGame or ((MessageDlg('Abort Current Game ?', mtConfirmation,
     [mbYes, mbNo], 0) = mrYes)) then begin
       ProgressBarTimer.Enabled := False;
       if CurrGame <> nil then
       CurrGame.GameOver
    end;}
end;
procedure TQuizMaps.SpeedButton1Click(Sender: TObject);
begin
  if CloseFormTimer.Enabled or EndLevelTimer.Enabled then exit;
  inherited;

end;

procedure TQuizMaps.Timer1Timer(Sender: TObject);
begin
  inherited;
  try
    if ( GeoController.InterfaceOptions.MusicOn and  (Currgame <> nil) and (ListBrowseMaps.MediaPlayer1.Position >= ListBrowseMaps.MediaPlayer1.Length)) then begin
        ListBrowseMaps.MediaPlayer1.Stop;
        ListBrowseMaps.MediaPlayer1.FileName := Geocontroller.InterfaceOptions.MusicFileName;
        ListBrowseMaps.MediaPlayer1.Open;
        ListBrowseMaps.MediaPlayer1.Position := 0;
        ListBrowseMaps.MediaPlayer1.Start;
        ListBrowseMaps.MediaPlayer1.Play;

    end;
  except on EMCiDeviceError do
    exit
  end;
end;

procedure TQuizMaps.MediaPlayer1Notify(Sender: TObject);
begin
  inherited;
  if ( GeoController.InterfaceOptions.MusicOn and (MediaPlayer1.Mode in [mpPlaying,mpOpen]) and  (Currgame <> nil) and (MediaPlayer1.Position >= MediaPlayer1.Length)) then begin

        MediaPlayer1.Position := 0;

  end;
end;

end.
