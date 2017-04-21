program Project1;

uses
  Forms,
  upainter in 'UPAINTER.pas' {ImageFrame: TFrame},
  Unit3 in 'Unit3.pas' {Form3};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
