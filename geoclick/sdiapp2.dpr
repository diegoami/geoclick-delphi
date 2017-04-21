program sdiapp2;

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
  Sdimain in 'sdimain.pas' {SDIAppForm},
  uListBrowseMaps in 'uListBrowseMaps.pas' {ListBrowseMaps},
  Utils in '..\..\LIB\Utils.pas',
  uQuizMaps in 'uQuizMaps.pas' {QuizMaps},
  uGeoGame in 'uGeoGame.pas',
  uDifficultyForm in 'uDifficultyForm.pas' {DifficultyForm},
  uScoreForm in 'uScoreForm.pas' {ScoreForm},
  iLock332 in '..\..\register\Ilock\Ilock332.pas',
  IceLock in '..\..\register\Ilock\Icelock.pas',
  uRegisterForm in 'uRegisterForm.pas' {RegisterForm},
  StringFns in '..\..\..\..\..\DELPHITK\stringfn\StringFns.pas',
  CustomHImages in '..\..\HiReg\CustomHImages.pas',
  HImages in '..\..\HiReg\HImages.pas',
  AMReg in '..\..\AmReg\amrec\AMReg.pas',
  Hemibtn in '..\..\Hemi\delphi3\HemiBtn.pas',
  uOvalButtonsPanel in 'Components\uOvalButtonsPanel.pas',
  DsFancyButton in '..\..\Buttons\DsFancyButton.pas',
  OvalButtonsPanel in 'OvalButtonsPanel.pas',
  OvalBtn in '..\..\Buttons\Oval\32Bit\OvalBtn.pas';

{$R *.RES}

var TT : integer;
  MM : String;
begin
  Application.CreateForm(TSDIAppForm, SDIAppForm);
  Application.Title := 'Geoclick';
  Application.CreateForm(TSDIAppForm, SDIAppForm);
  Application.CreateForm(TGeoClickAboutBox, GeoClickAboutBox);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TUserForm, UserForm);
  Application.CreateForm(TColorForm, ColorForm);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.CreateForm(TListBrowseMaps, ListBrowseMaps);
  Application.CreateForm(TQuizMaps, QuizMaps);
  Application.CreateForm(TDifficultyForm, DifficultyForm);
  Application.CreateForm(TScoreForm, ScoreForm);
  Application.CreateForm(TRegisterForm, RegisterForm);
  RegisterForm.Areg := AReg;

  RegisterForm.CheckRegister;
  if not RegisterForm.Registered then begin
    TT := RegisterForm.Times;
    if TT <= (TimeToRegister div 2) then begin
      MM := 'Welcome! You can use this Application another ' + IntToStr(TimeToRegister-TT) +' times before registering';
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
 