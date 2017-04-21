unit uOptionsForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, dcDTree,  StdCtrls, uSimpleBrowseTreeView,
  uDCNewBrowseTreeVie, uHSFTreeView, ExtCtrls, uGeoController,
  GeoListView, Buttons;

type
  TOptionsForm = class(TForm)
    ListViewPanel: TPanel;
    Panel2: TPanel;
    OkButton: TBitBtn;
    CancelButton: TBitBtn;
    Splitter1: TSplitter;
//    OvalButtonsPanel1: TOvalButtonsPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure TreeViewClickCheck(Sender: TObject; Node: TTreeNode);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    ForExcluded : TStrings;
    OldChange : TLVChangeEvent;
  public
    FormChanged : Boolean;
    HSFTreeView : THsfTreeView;
    ListView1: TGeoListView;
    procedure ListChange(Sender: TObject; Item: TListItem; Change: TItemChange);

  end;

var
  OptionsForm: TOptionsForm;

implementation



{$R *.DFM}


procedure TOptionsForm.ListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
var i : integer;
   Lit : TListItem;
begin
  FormChanged := True;
  OldChange(Sender,Item,Change);
  if (Change = ctState) and (Item.Checked) then begin
    TDrawNode(HSFTreeView.Selected).CheckState := csChecked;
    for i := 0 to ListView1.Items.Count -1 do begin
      Lit := ListView1.Items[i];
      if not lit.Checked then
        GeoController.Exclude(lit.Caption)
      else
        GeoController.Include(lit.Caption)
    end;
  end;
end;


procedure TOptionsForm.FormCreate(Sender: TObject);

begin
  ListView1 := TGeoListView.Create(ListViewPanel);
  OldChange := ListView1.OnChange;
  ListView1.OnChange := ListChange;

  ListView1.IconOptions.Arrangement := iaLeft;
  ForExcluded := TSTringList.Create;
  HSFTreeView := THSfTreeView.Create(Self);
  with HSFTreeView do begin
    Align := AlClient;

    Parent := Self;
    Directory := ExtractFilePath(Application.Exename);

    OnClickCheck := TreeViewClickCheck;
    OnChange := TreeViewChange;
    FullExpand;

  end;
  GeoController.AllFiles.Assign(HSFTreeView.AllFiles);
  GeoController.AllDirs.Assign(HSFTreeView.AllDirs);
  if GeoController.HsfFiles.Count = 0 then
    GeoController.HsfFiles.Assign(HSFTreeView.AllFiles);
  with Listview1 do begin
    Align := alClient;
    Parent := ListViewPanel;
    CheckedItems := True;
  end;
end;

procedure TOptionsForm.Button1Click(Sender: TObject);
begin
  //BrowseTreeView.PruneUnCheckedTreeNodes;
  {if HSFTreeView.GetCheckedFiles.Count > 0 then begin
    ProvaQuiz.AddHyperImages(HSFTreeView);
    ProvaQuiz.Show;
    ProvaQuiz.LoadQuiz;
  end;}
end;


procedure TOptionsForm.OkButtonClick(Sender: TObject);
begin
  GeoController.HsFFiles.Assign(HsfTreeView.GetCheckedFiles);
  GeoController.SaveExclusions;
  with AReg do begin
    Active := True;
    WSInteger('Forms','OptionsLeft',Left);
    WSInteger('Forms','OptionsTop',Top);
    WSInteger('Forms','OptionsWidth',Width);
    WSInteger('Forms','OptionsHeight',Height);
    WSInteger('Forms','OptionsListWidth',ListViewPanel.Width);
    WSInteger('Forms','OptionsSelected',HSFTreeView.Selected.AbsoluteIndex);
    WSInteger('Forms','OptionsTopItem',HSFTreeView.TopItem.AbsoluteIndex);

    Active := False;
  end;
  Close;
end;

procedure TOptionsForm.CancelButtonClick(Sender: TObject);
begin
  Geocontroller.ExcludeNames.Clear;
  Geocontroller.ExcludeNames.Assign(ForExcluded);
  Close;
end;

procedure TOptionsForm.TreeViewClickCheck(Sender: TObject;
  Node: TTreeNode);
begin
  //LoadListOfStrings;
  Listview1.Load(TDrawNode(HSFTreeView.Selected).CheckState = csChecked);

end;

procedure TOptionsForm.TreeViewChange(Sender: TObject;
  Node: TTreeNode);
begin
  //TotalNames.Clear;
  FormChanged := True;
  if not HSFTreeView.IsDir(Node) then begin
    ListView1.LoadNamesFromFile(String(Node.Data));

    ListView1.Load(TDrawNode(HSFTreeView.Selected).CheckState = csChecked);
  end;

end;

procedure TOptionsForm.FormShow(Sender: TObject);
begin
  HSFTreeView.CheckBoxes := True;
  ListView1.CheckBoxes := True;
  FormChanged := False;
  with AReg do begin
    Active := True;
    Left := RSInteger('Forms','OptionsLeft',Left);
    Top := RSInteger('Forms','OptionsTop',Top);
    Width := RSInteger('Forms','OptionsWidth',Width);
    Height := RSInteger('Forms','OptionsHeight',Height);
    ListViewPanel.Width := RSInteger('Forms','OptionsListWidth',ListViewPanel.Width);
    HSFTreeView.Selected := HSFTreeView.Items[RSInteger('Forms','OptionsSelected',0)];
    HSFTreeView.TopItem := HSFTreeView.Items[RSInteger('Forms','OptionsTopItem',0)];
    Active := False;
  end;
  GeoController.LoadExclusions;
  ForExcluded.Assign(GeoController.ExcludeNames);
  HSFTreeView.CheckNodesInStrings(GeoController.HsfFiles);
  HSFTreeView.OnChange(Self,HSFTreeView.Selected);

end;

procedure TOptionsForm.Splitter1Moved(Sender: TObject);
begin
  ListView1.Arrange(arAlignLeft);
end;

procedure TOptionsForm.SpeedButton1Click(Sender: TObject);
begin
  HsfTreeView.SetChecked;
end;

procedure TOptionsForm.SpeedButton2Click(Sender: TObject);
begin
  HsfTreeView.SetUnChecked;
end;

end.
