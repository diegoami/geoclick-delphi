program BtnDemo;

uses
  Forms,
  Btn_Main in 'Btn_Main.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'TOvalButton - Demo';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
