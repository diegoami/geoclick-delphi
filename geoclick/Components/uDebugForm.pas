unit uDebugForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TDebugForm = class(TForm)
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DebugForm: TDebugForm;
procedure Log(S : String);

procedure LogStrings(TS : TStrings);


implementation



{$R *.DFM}

procedure TDebugForm.FormShow(Sender: TObject);
begin
  //Memo1.Lines.Assign(OptionsForm.HSFTreeView.AllDirs);
end;

procedure LogStrings(TS : TStrings);
begin
  DebugForm.Memo1.Lines.AddStrings(TS);
end;


procedure Log(S : String);
begin
  DebugForm.Memo1.Lines.Add(S);
end;

end.
