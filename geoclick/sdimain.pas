unit Sdimain;

interface

uses Windows, Classes, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, AMReg, MPlayer, IceLock, stringfns,
   uOvalButtonsPanel, RxMenus, ImgList;

type
  TSDIAppForm = class(TForm)
    SDIAppMenu: TRxMainMenu;
    FileMenu: TMenuItem;
    UserItem: TMenuItem;
    ExitItem: TMenuItem;
    N1: TMenuItem;
    Help1: TMenuItem;
    SpeedPanel: TPanel;
    NewBtn: TSpeedButton;
    UserBtn: TSpeedButton;
    ExitBtn: TSpeedButton;
    StatusBar: TStatusBar;
    OptionsItem: TMenuItem;
    HotspotsItem: TMenuItem;
    Environment: TMenuItem;
    DifficultyItem: TMenuItem;
    ContentsItem: TMenuItem;
    NewgameItem: TMenuItem;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    AMReg: TAMReg;
    SpeedButton4: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Timer1: TTimer;
    Label1: TLabel;
    View1: TMenuItem;
    Maps1: TMenuItem;
    Scores1: TMenuItem;
    DifficultySpeedButton: TSpeedButton;
    SpeedButton5: TSpeedButton;
    MediaPlayer1: TMediaPlayer;
    About1: TMenuItem;
    N2: TMenuItem;
    Registration1: TMenuItem;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    DownloadMenuItem: TMenuItem;
    SpeedButton8: TSpeedButton;
    ImageList1: TImageList;
    RxMainMenu1: TRxMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    procedure ShowHint(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure UserItemClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HotspotsItemClick(Sender: TObject);
    procedure EnvironmentClick(Sender: TObject);
    procedure MapsMenuItemClick(Sender: TObject);
    procedure Debug1Click(Sender: TObject);
    procedure NewgameItemClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DifficultyItemClick(Sender: TObject);
    procedure Scores1Click(Sender: TObject);
    procedure Registration1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ContentsItemClick(Sender: TObject);
    procedure DownloadMenuItemClick(Sender: TObject);
    procedure SDIAppMenuGetImageIndex(Sender: TMenu; Item: TMenuItem;
      State: TMenuOwnerDrawState; var ImageIndex: Integer);
  private
    QuizChanged, NeverListShown : Boolean;
  protected
    procedure DisableAll;
  public
    procedure ShowLevel(Level,Score : integer);
    procedure LoadQuiz(NT : integer; NS : Integer);
    procedure Wait;
    procedure GameOver;
  end;

var
  SelectedHsfFiles : TStrings;
  SDIAppForm: TSDIAppForm;

implementation

uses SysUtils, About, uOptionsForm, uUserForm, uColorForm, uListBrowseMaps,
  uDebugForm, uQuizMaps, uGeoController, uGeoGame, uDifficultyForm,
  uScoreForm, uRegisterForm, uGeoClickAbout, uMaplist;

{$R *.DFM}

procedure TSDIAppForm.ShowHint(Sender: TObject);
begin
  StatusBar.SimpleText := Application.Hint;
end;

procedure TSDIAppForm.ShowLevel(Level, Score : Integer);
begin
  Label1.Caption := 'Level '+IntToStr(Level) +Chr(13)+Chr(10)+
     'Score '+IntToStr(Score);
end;

procedure TSDIAppForm.ExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TSDIAppForm.UserItemClick(Sender: TObject);
begin
  UserForm.Show;
end;

procedure TSDIAppForm.About1Click(Sender: TObject);
begin
  GeoClickAboutBox.Show;
end;

procedure TSDIAppForm.FormCreate(Sender: TObject);
begin
  Application.OnHint := ShowHint;
  QuizChanged := True;
  
end;

procedure TSDIAppForm.HotspotsItemClick(Sender: TObject);
begin
  OptionsForm.Show;

  QuizChanged := OptionsForm.FormChanged;
end;

procedure TSDIAppForm.EnvironmentClick(Sender: TObject);
begin
  ColorForm.Show;
end;

procedure TSDIAPPForm.LoadQuiz(NT : integer; NS : Integer);
begin

  {if (CurrGame.Level = 1) then begin
    QuizMaps.Init; // importante!
  end;}
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

procedure TSDIAppForm.MapsMenuItemClick(Sender: TObject);
begin

  ListBrowseMaps.Init; // importante!
  ListBrowseMaps.Show;
end;

procedure TSDIAppForm.Debug1Click(Sender: TObject);
begin
  DebugForm.Show;
end;

procedure TSDIAppForm.NewgameItemClick(Sender: TObject);
begin
  if GeoController.CanStartGame then begin
    //UserForm.ShowModal;
    CurrGame := TGeoGame.Create(Self,GeoController.Difficulty);

    CurrGame.NextLevel;

  end else begin
    MessageBox(0,'No maps selected!','Warning',0);
    OptionsForm.Show;
  end;
end;

procedure TSDIAppForm.Wait;
begin

  Timer1.Enabled := True;
end;


procedure TSDIAppForm.DisableAll;
begin
  NewBtn.OnClick := nil;
  NewGameItem.OnClick := nil;
  RegisterForm.Show;
  GeoClickAboutBox.Show;

end;

procedure TSDIAppForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if (not RegisterForm.Registered) and (RegisterForm.Times > (TimeToRegister div 2)) and (((Currgame.Level-1)*Geocontroller.qpl) > ((TimeToRegister-RegisterForm.Times)*7) )then begin
    DisableAll;
    MessageBox(0,'Thank you for trying Geoclick! Click to terminate','Bye',0);
    Application.Terminate;
  end else


    CurrGame.StartLevel;
end;

procedure TSDIAppForm.DifficultyItemClick(Sender: TObject);
begin
  DifficultyForm.Show;
end;

procedure TSDIAppForm.Scores1Click(Sender: TObject);
begin
  ScoreForm.Show;
end;

procedure TSDIAppForm.GameOver;
begin
  Label1.Caption := 'GAME OVER' +Chr(13)+Chr(10)+
     'Score '+IntToStr(Currgame.Score);
  ScoreForm.AddScore(GeoController.Username,Currgame.Score);
  ScoreForm.Save;
  Application.CreateForm(TListBrowseMaps,ListBrowseMaps);
end;

procedure TSDIAppForm.Registration1Click(Sender: TObject);
begin
  RegisterForm.Show;
  if RegisterForm.Registered then
    Caption := 'Geoclick by Diego Amicabile';

end;

procedure TSDIAppForm.FormShow(Sender: TObject);
begin                                       
  if (not RegisterForm.Registered) and (RegisterForm.Times > TimeToRegister) then Application.Terminate;
  if RegisterForm.Registered then
    Caption := 'Geoclick by Diego Amicabile'
  else
    Caption := 'Geoclick by Diego Amicabile - EVALUATION VERSION';
  Label1.Top := (Height - Label1.Height-50) div 2;
  Label1.Left := (Width - Label1.Width-120) div 2;


end;

procedure TSDIAppForm.ContentsItemClick(Sender: TObject);
begin
  ShowWebPage(ExtractFilePath(Application.Exename)+'Geoclick1.chm');
end;

procedure TSDIAppForm.DownloadMenuItemClick(Sender: TObject);
begin
//  ShowWebPage('http://clickit.pair.com/maps/');
  MapListForm.Show;
end;

procedure TSDIAppForm.SDIAppMenuGetImageIndex(Sender: TMenu;
  Item: TMenuItem; State: TMenuOwnerDrawState; var ImageIndex: Integer);
begin
  if Item = NewGameItem then
    ImageIndex :=  0
  else if Item = UserItem then
    ImageIndex :=  1
  else if Item = ExitItem then
    ImageIndex :=  11
  else if Item = HotspotsItem then
    ImageIndex :=  2
  else if Item = Environment then
    ImageIndex :=  3
  else if Item = DifficultyItem then
    ImageIndex :=  4
  else if Item = Maps1 then
    ImageIndex :=  5
  else if Item = Scores1 then
    ImageIndex :=  6
 
  else if Item = ContentsItem then
    ImageIndex := 8
  else if Item = DownloadMenuItem then
    ImageIndex := 9
  else if Item = Registration1 then
    ImageIndex := 7


end;

end.

