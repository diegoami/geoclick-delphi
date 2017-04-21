unit uSimpleBrowseTreeView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  comctrls, dcDtree;

type
  TTVAddedEvent = procedure(Sender: TObject; Dir, Name : String; Node : TTreeNode) of object;

  TIterateProc = function(Node : TTreeNode) : boolean of object;

  TDCSimpleBrowseTreeView = class(TDCMSTreeView)
   private
    ClosedBitmap, OpenBitmap, MapBitmap : TBitmap;


    function CheckNode(Node : TTreeNode) : boolean;
    function UnCheckNode(Node : TTreeNode) : boolean;

    function RemoveUnChecked(Node : TTreeNode) : boolean;
    procedure LoadFolderImages;


  protected

    Pnode : TTreeNode;
    FMaskColor : TColor;
    FAddedNode : TTVAddedEvent;

    function DeleteNodeIfEmptyDir(Node : TTreeNode) : boolean; dynamic;
    procedure DeleteEmptyDirs;

    procedure IterateTreeBack(IterateProc : TIterateProc);

  public
    procedure Loaded; override;
    function IsDir(Node : TTreeNode) : boolean;
    procedure IterateTree(IterateProc : TIterateProc);
    procedure CheckIf(STreeView : TDCMSTreeView);
    procedure GetCheckedItems(MyNodes : TTreeNodes);
    procedure RemoveUnCheckedNodes;
    procedure SetChecked;
    procedure SetUnChecked;


    function  AddNode(Description : String; Obj : Pointer; Where : TTreeNode;Index : integer) : TTreeNode; dynamic;
    function AddFolder(Description : String;  Where : TTreeNode) : TTreeNode;
    constructor Create(AOwner : TComponent) ; override;
    destructor Destroy; override;
    procedure CopyFrom(Tree : TDCSimpleBrowseTreeView);

  published
    property MaskColor : TColor read FMaskColor write FMaskColor;
    property OnAddedNode: TTVAddedEvent read FAddedNode write FAddedNode;
  end;

procedure Register;

implementation

constructor TDCSimpleBrowseTreeView.Create(AOwner :TCOmponent);
begin
  inherited Create(AOwner);
  ReadOnly := True;
  LoadFolderImages;
end;

procedure  TDCSimpleBrowseTreeView.RemoveUnCheckedNodes;
begin
   IterateTree(RemoveUnChecked);
end;


procedure TDCSimpleBrowseTreeView.GetCheckedItems(MyNodes : TTreeNodes);
begin
  MyNodes.Assign(Items);
  IterateTree(RemoveUnChecked);
  IterateTree(DeleteNodeIfEmptyDir);
end;

function TDCSimpleBrowseTreeView.IsDir(Node : TTreeNode) : Boolean;
begin
  if Node = nil then result := false else
    Result := (Node.ImageIndex = 0);
end;

function TDCSimpleBrowseTreeView.AddFolder(Description : String; Where : TTreeNode) : TTreeNode;
var  addednode            : TTreeNode;
begin
  Addednode  := TTreeNode(Items.AddChild(Where , Description));
  Addednode.ImageIndex    := 0;
  Addednode.SelectedIndex := 1;
  Selected := Addednode;
  Result := Addednode;
end;



function TDCSimpleBrowseTreeView.AddNode(Description : String; Obj : Pointer; Where : TTreeNode; Index : integer) : TTreeNode;
var  addednode            : TTreeNode;
begin
  Addednode  := TTreeNode(Items.AddChildObjectFirst(Where, Description,Obj));
  Addednode.ImageIndex    := Index+2;
  Addednode.SelectedIndex := Index+2;
  Result := AddedNode;
end;

procedure TDCSimpleBrowseTreeView.IterateTree(IterateProc : TIterateProc);

var i : integer;
  CNode,NNode : TTreeNode;
begin

  CNode := Items.Item[0];
  while CNode <> nil  do begin

    NNode := CNode.GetNext;
    IterateProc(CNode);
    CNode := NNode;
  end;
end;

procedure TDCSimpleBrowseTreeView.IterateTreeBack(IterateProc : TIterateProc);

var i : integer;
  CNode,NNode : TTreeNode;
begin

  CNode := Items.Item[Items.Count-1];
  while CNode <> nil  do begin
    NNode := CNode.GetPrev;
    IterateProc(CNode);
    CNode := NNode;
  end;
end;

procedure TDCSimpleBrowseTreeView.CheckIf(STreeView : TDCMSTreeView);

var
  CNode,NNode : TTreeNode;
  CDNode, NDNode : TTreeNode;
  begin
  CDNode := Items.Item[0];
  CNode := STreeView.Items.Item[0];
  while CNode <> nil  do begin
    NNode := CNode.GetNext;
    NDNode := CDNode.GetNext;
    TDrawNode(CDNode).CheckState := TDrawNode(CNode).CheckState;
    CNode := NNode;
    CDNode := NDNode;
  end;
end;

function TDCSimpleBrowseTreeView.CheckNode(Node : TTreeNode) : boolean;
begin
  if not (IsDir(Node)) then begin
    TDrawNode(Node).CheckState:= csChecked;
  end else begin
    TDrawNode(Node).CheckState := csNone;
  end;
end;


function TDCSimpleBrowseTreeView.UnCheckNode(Node : TTreeNode) : boolean;
begin
  if not (IsDir(Node)) then begin
    TDrawNode(Node).CheckState:= csUnChecked;
  end else begin
    TDrawNode(Node).CheckState := csNone;
  end;
end;

function TDCSimpleBrowseTreeView.DeleteNodeIfEmptyDir(Node : TTreeNode) : boolean;
begin
  result := false;
  if (IsDir(Node)) then
    if Node.HasChildren = False then begin
      Items.Delete(Node);
      result := true;
    end;
end;

function TDCSimpleBrowseTreeView.RemoveUnChecked(Node : TTreeNode) : boolean;
begin
  result := false;
  if Node = nil then
    result := false

  else if (not (IsDir(Node))) and ((TDrawNode(Node)).CheckState = csUnChecked) then begin
    Items.Delete(Node);
    result := True;
  end;
end;

procedure TDCSimpleBrowseTreeView.CopyFrom(Tree : TDCSimpleBrowseTreeView);
begin
  Items.Assign(Tree.Items);
  ///CheckIf(Self);
  CheckIf(Tree);
  RemoveUnCheckedNodes;
  CheckBoxes := False;
end;

procedure TDCSimpleBrowseTreeView.SetChecked;
begin
  IterateTree(CheckNode);
end;

procedure TDCSimpleBrowseTreeView.SetUnChecked;
begin
  IterateTree(UnCheckNode);
end;


procedure TDCSimpleBrowseTreeView.DeleteEmptyDirs;
begin
  IterateTreeBack(DeleteNodeIfEmptyDir);
end;

destructor TDCSimpleBrowseTreeView.Destroy;
begin
  ClosedBitmap.Free;
  OpenBitmap.Free;
  Images.Free;
  inherited;
end;

procedure TDCSimpleBrowseTreeView.LoadFolderImages;
var ExeDir : String;
begin
  ExeDir := ExtractFilePath(Application.ExeName);
  Images := TImageList.Create(Self);
  ClosedBitmap := TBitmap.Create;
  OpenBitmap := TBitmap.Create;


  try
    OpenBitmap.LoadFromFile(ExeDir+'Components\map.bmp');
    Images.AddMasked(OpenBitmap,clRed);
  except on Exception do

    raise Exception.Create('Missing files. Please Reinstall');
  end;

    try
    ClosedBitmap.LoadFromFile(ExeDir+'Components\map.bmp');
    Images.AddMasked(OpenBitmap,clRed);
  except on Exception do

    raise Exception.Create('Missing files. Please Reinstall');
  end;


end;

procedure TDCSimpleBrowseTreeView.Loaded;
begin
  inherited;
end;

procedure Register;
begin
  RegisterComponents('Additional', [TDCSimpleBrowseTreeView]);
end;

end.
