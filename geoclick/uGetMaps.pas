unit uGetMaps;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, HTMLParser, URLTreeViewFiller;

type
  TForm1 = class(TForm)
    HTMLTreeViewPArser1: THTMLTreeViewPArser;
    TreeView1: TTreeView;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var SL : TStringList;
begin
  SL :=TStringList.Create;
  if OpenDialog1.Execute then begin
    SL.LoadFromFile(OpenDialog1.FileName);
    HTMLTreeViewPArser1.ParseAndFillTreeView(SL.Text)
  end;
end;

end.
