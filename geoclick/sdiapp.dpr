program Sdiapp;

uses
  Forms,
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
  CustomHImages in '..\..\HiReg\CustomHImages.pas',
  Sdimain in 'sdimain.pas' {SDIAppForm},
  uListBrowseMaps in 'uListBrowseMaps.pas' {ListBrowseMaps},
  Utils in '..\..\LIB\Utils.pas',
  uQuizMaps in 'uQuizMaps.pas' {QuizMaps},
  OvalButtonsPanel in 'Components\OvalButtonsPanel.pas',
  uGeoGame in 'uGeoGame.pas';

{$R *.RES}

begin
  Application.CreateForm(TSDIAppForm, SDIAppForm);
  Application.Title := 'Geoclick';
  Application.CreateForm(TGeoClickAboutBox, GeoClickAboutBox);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TUserForm, UserForm);
  Application.CreateForm(TColorForm, ColorForm);
  Application.CreateForm(TBrowseMaps, BrowseMaps);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.CreateForm(TSDIAppForm, SDIAppForm);
  Application.CreateForm(TListBrowseMaps, ListBrowseMaps);
  Application.CreateForm(TQuizMaps, QuizMaps);
  Application.Run;
end.
 