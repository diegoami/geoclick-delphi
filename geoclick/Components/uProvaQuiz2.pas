unit uProvaQuiz2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HyperImagesScrollBox, ExtCtrls, ComCtrls, OvalButtonsPanel,
  dcDTree, uDCBrowseTreeView, uSimpleBrowseTreeView, uDCNewBrowseTreeVie,
  uHyperImagesTreeView, uHSFTreeView;
{

type
  TProvaQuiz = class(TForm)
    ZoomerPanel1: TZoomerPanel;
    HYperImagesTreeView1 : THyperImagesTreeView;
    Panel1: TPanel;
    ScrollBox1 : TScrollBox;
    OvalButtonsPanel1: TOvalButtonsPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure HyperImagesScrollBox1HotSpotClicked(HotSpot: String) ;
    procedure OvalButtonsPanel1Resize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OvalButtonsPanel1AllGuessed;
    procedure OnTreeChange(Sender: TObject; Node: TTreeNode);
    procedure LoadQuiz;
    procedure ScrollBox1Resize(Sender: TObject);
  private
    HSFTreeView : THsfTreeView;
    HyperList : TList;
    CHIP : THyperImagesScrollBox;
    //procedure LoadImages(Dir : String; NOde : TTreeNode);
    
    procedure AddHyperImage(Node : TTreeNode);
    function CreateHyperImage(Dir, Name : String; TreeView : THsfTreeView ) : THyperImagesScrollBox;

  public
    function AddHyperImages(Treeview : THsfTreeView) : boolean;

    //procedure LoadTree(TreeView : TDCBrowseTreeView);
  end;

var
  ProvaQuiz: TProvaQuiz;
}
implementation

{$R *.DFM}
{
procedure TProvaQuiz.HyperImagesScrollBox1HotSpotClicked(HotSpot: String);
begin
  //StatusBar1.SimpleText := HotSpot;
  if OvalButtonsPanel1.GetCurrentString = HotSpot then
    OvalButtonsPanel1.Guessed;
end;

procedure TProvaQuiz.OvalButtonsPanel1Resize(Sender: TObject);
begin
  OvalButtonsPanel1.OnResize(Self);
end;

procedure TProvaQuiz.FormCreate(Sender: TObject);

begin

  HyperList := TList.Create;
  HyperImagesTreeView1 := THyperImagesTreeView.Create(Self);
  with HyperImagesTreeView1 do begin
    Align := AlClient;
    Width := 200;
    Height := 430;
    Parent := Panel1;

  with BrowseTreeView do begin
    MaskColor := clRed;
    AcceptedFiles := Accepted;

  end;
  end;
//  HyperImagesScrollBox1.Parent := Nil;

end;

function TProvaQuiz.CreateHyperImage(Dir, Name : String; TreeView : THsfTreeView ) : THyperImagesScrollBox;
var HIS : THyperImagesScrollBox;
begin
  HIS := THyperImagesScrollBox.Create(Self);
  HyperList.Add(HIS);
  with HIS do begin
    Align := AlClient;
    PicturesDir := Dir;
    HotSpotFiles := HSFTreeView.GetHsfFilesForDir(Dir);
    OnHotSpotClicked := HyperImagesScrollBox1HotSpotClicked;

  end;
  HIS.LoadImage(Name);
  result := HyperList.Last;
end;

procedure TProvaQuiz.LoadQuiz;
var i : integer;
  TSL : TStrings;
begin
  TSL := TStringList.Create;
  for i := 0 to HyperList.Count-1 do
    TSL.AddStrings(THyperImagesScrollBox(HyperList.Items[i]).GetHotspotsList);
  OvalButtonsPanel1.PossibleValuesList := TSL;
  OvalButtonsPanel1.GenerateTest(OvalButtonsPanel1.NButtons);
end;


procedure TProvaQuiz.AddHyperImages(Treeview : THsfTreeView);
begin
  HSFTreeView := TreeView;
  with HyperImagesTreeView1 do begin
    Directory := 'C:\Programme\Borland\Delphi 3\Miei\Geotest 2\';
    PruneDataNotInDirs(TreeView.GetCheckedDirs);

    IterateTree(AddHyperImage);
    OnChange := OnTreeChange;
    OnChange(Self,Items.Item[Items.Count-1]);
  end;
end;

procedure TProvaQuiz.AddHyperImage(Node : TTreeNode);
var CName : String;

begin
  with HyperImagesTreeView1 do
    if not IsDir(Node) then begin
      CName := String(Node.Data);
      Node.Data := CreateHyperImage(ExtractFilePath(Cname), ExtractFileName(Cname), HSFTreeView);
    end;
end;



procedure TProvaQuiz.OvalButtonsPanel1AllGuessed;
begin
  MessageBox(0,'Bravissimo','Messaggio',0);
  OvalButtonsPanel1.NButtons := OvalButtonsPanel1.NButtons+1;
  OvalButtonsPanel1.GenerateTest(OvalButtonsPanel1.NButtons);
end;

procedure TProvaQuiz.OnTreeChange(Sender: TObject;
  Node: TTreeNode);
var Compon : TWinControl;
begin
  if (Node.Data <> nil) and (NOde.ImageIndex <> 0) then
  try
    if CHIP <> nil then
      CHIP.Parent := nil;
    (TWinControl(Node.Data)).Parent := Self;
    CHIP := Node.Data;
    ZoomerPanel1.HYperImages := CHIP.HyperImages;
    ZoomerPanel1.ZoomScrollBar.Position := CHIP.HyperImages.Scale;
  except on Exception do end;
end;

procedure TProvaQuiz.ScrollBox1Resize(Sender: TObject);
begin
  OvalButtonsPanel1.Height := ScrollBox1.Height;
  OvalButtonsPanel1.OnResize(ScrollBox1);
end;
      ´}
end.
