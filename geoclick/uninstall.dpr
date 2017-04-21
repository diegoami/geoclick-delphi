program uninstall;

uses
  uDaUnInstaller in '..\dauninst\uDaUnInstaller.pas';

var DaUnInstaller : TDAUninstaller;

{$R *.res}
begin

  DaUnInstaller := TDaUninstaller.Create;
  //if ParamCount < 1 then exit;
 // DaUninstaller.ApplicationName := ParamStr(1);
 DaUninstaller.ApplicationName := 'Geoclick';
  DaUninstaller.Execute;

end.
