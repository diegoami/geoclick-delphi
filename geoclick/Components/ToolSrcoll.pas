unit ToolSrcoll;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CustomHImages, HImages, ExtCtrls, JPeg, HyperImagesScrollBox;

type
  TForm1 = class(TForm)
    ScrollBox1: TScrollBox;
    ZoomerPanel : TZoomerPAnel;
    Panel1: TPanel;
    HyperImagesScrollBox1: THyperImagesScrollBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  ZoomerPanel := TZoomerPanel.Create(Self);
  ZoomerPanel.Parent := Self;
  ZoomerPanel.Align := AlTop;
  HyperImagesScrollBox.ZoomerPanel := ZoomerPanel;

end;

end.
