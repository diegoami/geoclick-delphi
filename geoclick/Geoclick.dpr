program Geoclick;

uses

  Forms,
  sysutils,

  uGeoClickAbout in 'uGeoClickAbout.pas' {GeoClickAboutBox},
  uOptionsForm in 'Components\uOptionsForm.pas' {OptionsForm},
  uGeoController in 'uGeoController.pas',
  uDCNewBrowseTreeVie in 'Components\uDCNewBrowseTreeVie.pas',
  uUserForm in 'uUserForm.pas' {UserForm},
  uColorForm in 'uColorForm.pas' {ColorForm},
  HyperImagesScrollBox in 'Components\HyperImagesScrollBox.pas',
  uBrowseMaps in 'uBrowseMaps.pas' {BrowseMaps},
  uHSFTreeView in 'Components\uHSFTreeView.pas',
  uDebugForm in 'Components\uDebugForm.pas' {DebugForm},
  uSimpleBrowseTreeView in 'Components\uSimpleBrowseTreeView.pas',
  uHyperImagesTreeView in 'Components\uHyperImagesTreeView.pas',
  GeoListView in 'Components\GeoListView.pas',
  uListBrowseMaps in 'uListBrowseMaps.pas' {ListBrowseMaps},
  uQuizMaps in 'uQuizMaps.pas' {QuizMaps},
  uGeoGame in 'uGeoGame.pas',
  uDifficultyForm in 'uDifficultyForm.pas' {DifficultyForm},
  uScoreForm in 'uScoreForm.pas' {ScoreForm},
  uRegisterForm in 'uRegisterForm.pas' {RegisterForm},

  AMReg in '..\..\AmReg\amrec\AMReg.pas',
  OvalBtn in '..\..\Buttons\Oval\32Bit\OvalBtn.pas',
  uWebUrl in 'uWebUrl.pas' {WebForm},
  uOvalButtonsPanel in 'Components\uOvalButtonsPanel.pas',
  CustomHImages in '..\Hireg\CustomHImages.pas',
  HImages in '..\Hireg\HImages.pas',
  Utils in '..\MyLibs\Utils.pas',
  uMaplist in 'uMaplist.pas' {MaplistForm},
  HSEdit in 'HSEdit.pas' {HSEditForm},
  upainter in '..\Mylibs\Painter\upainter.pas' {ImageFrame: TFrame},
  uTxtField in 'uTxtField.pas' {TextFieldDialog};

{$R *.RES}

var TT : integer;
  MM : String;
begin

  Application.Title := 'Geoclick';
  Application.CreateForm(TListBrowseMaps, ListBrowseMaps);
  Application.CreateForm(TGeoClickAboutBox, GeoClickAboutBox);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TUserForm, UserForm);
  Application.CreateForm(TColorForm, ColorForm);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.CreateForm(TQuizMaps, QuizMaps);
  Application.CreateForm(TDifficultyForm, DifficultyForm);
  Application.CreateForm(TScoreForm, ScoreForm);
  Application.CreateForm(TRegisterForm, RegisterForm);
  Application.CreateForm(TBrowseMaps, BrowseMaps);
  Application.CreateForm(TWebForm, WebForm);
  Application.CreateForm(TMaplistForm, MaplistForm);
  Application.CreateForm(THSEditForm, HSEditForm);
  RegisterForm.Areg := AReg;

  RegisterForm.CheckRegister;
  if not RegisterForm.Registered then begin
    TT := RegisterForm.Times;
    if TT <= (TimeToRegister div 2) then begin
      MM := 'Welcome! You can use this Application another ' + IntToStr(TimeToWarn-TT) +' times before registering';
      Application.MessageBox(Pchar(MM),'',0)

    end else if TT > (TimeToRegister div 2) then begin
      MM := ' You have used this Application '+IntToStr(TT)+ ' times. Please Register!';
      Application.MessageBox(PChar(MM),'',0);
      GeoClickAboutBox.Show;
      if TT > TimeToRegister then begin
        RegisterForm.ShowModal;
      end;
    end;

  end;
  Application.HintHidePause := 10000;
  Application.Run;
end.
