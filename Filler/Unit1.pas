unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, HTMLParser, URLTreeViewFiller, StdCtrls, OleCtrls, SHDocVw,
  HTMLContainerFromTreeView, URLFiller;

type
  TForm1 = class(TForm)
    HTMLTreeViewPArser1: THTMLTreeViewPArser;
    TreeView1: TTreeView;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Memo1: TMemo;
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
var SS : TStrings;
  htm : THTMLContainerFromTreeView;
begin
  if OpenDialog1.Execute then begin
    SS := TStringList.Create;
    SS.LoadFromFile(OPenDialog1.FileName);
    HTMLTreeViewPArser1.ParseAndFillTreeView(SS.Text)
  end;
  htm := THTMLContainerFromTreeView.Create;
  htm.ReadANdFiLL(TreeView1);
  Memo1.Lines.Text := htm.AsHtml;
end;

end.
