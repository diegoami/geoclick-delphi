unit uWebUrl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GetURL, ComCtrls, dcDTree, HTMLParser, URLFiller, URLDCMSTreeViewFiller;

type
  TWebForm = class(TForm)
    HTMLDCMSTreeViewPArser1: THTMLDCMSTreeViewPArser;
    DCMSTreeView1: TDCMSTreeView;
    WIGetURL1: TWIGetURL;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebForm: TWebForm;

implementation

{$R *.DFM}

procedure TWebForm.FormShow(Sender: TObject);
var SS : TStrings;
begin
  //WIGetUrl1.Url := 'http://clickit.pair.com/maps/';
  SS := TStringList.Create;
  SS.LoadFromFile('c:\Documenti\Web\maps\index.htm');
  HTMLDCMSTreeViewPArser1.ParseAndFillTreeView(SS.Text)
end;

end.
