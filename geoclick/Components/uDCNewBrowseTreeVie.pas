unit uDCNewBrowseTreeVie;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dcDTree, DcTree, comctrls, uSimpleBrowseTreeView;

type

  TDCNewBrowseTreeView = class(TDCSimpleBrowseTreeView)
   private
    FDirectory : String;
    FCDir : String;
    LSTrings : TSTrings;
    function CheckedToFIles(Node : TTreeNode) : boolean;
    function CheckedToAllFIles(Node : TTreeNode) : boolean;

    function HasCheckedChildren(Node : TTreeNode) : boolean;
    function CheckDataInDirs(Node : TTreeNode) : boolean;
    function CheckTextInStrings(Node : TTreeNode) : boolean;
    function CheckIfInStrings(Node : TTreeNode) : boolean;

  protected
    FAcceptedFiles : TStrings;
    function IsCheckedChildren(Node : TTreenode) : boolean;
        procedure LoadAcceptedFiles;

    function DeleteNodeIfEmptyDir(Node : TTreeNode) : boolean; override;
    procedure SetDirectory(Dir: String); virtual;
    procedure SetAcceptedFiles(Accepts : TStrings);
  public
    AllFiles : TStrings;
    AllDirs : TStrings;
    CheckedFiles, CheckedDirs : Tstrings;
    destructor Destroy; override;
    function GetCheckedFiles : TStrings;
    function GetCheckedDirs : TStrings;
    function GetCheckedFilesInDir(Dir : String) : TStrings;
    constructor Create(AOwner : TComponent) ; override;
    procedure Load(Dir : String; Node : TTreeNode);
    procedure Loaded; override;
    procedure PruneTextNotInStrings(ExtS : TStrings);
    procedure PruneDataNotInDirs(ExtS : TStrings);
    procedure CheckNodesInStrings(SS : TStrings);


  published
    property Files : TStrings read AllFiles;
    property AcceptedFiles : TStrings read FAcceptedFiles write SetAcceptedFiles;
    property Directory : String read FDirectory write SetDirectory;
  end;

procedure Register;

implementation

constructor TDCNewBrowseTreeView.Create(AOwner :TCOmponent);

begin
  inherited Create(AOwner);
  FAcceptedFiles := TStringList.Create;
  AllFiles := TStringList.Create;
  AllDirs := TStringList.Create;
  CheckedFiles := TStringList.Create;
  CheckedDirs := TStringList.Create;
  LStrings := TStringList.Create;
end;

destructor TDCNewBrowseTreeView.Destroy;
begin
  FAcceptedFiles.Free;
  AllFiles.Free;
  AllDirs.Free;
  CheckedFiles.Free;
  CheckedDirs.Free;
  LStrings.Free;
  inherited;
end;

function TDCNewBrowseTreeView.GetCheckedFiles : TStrings;
begin
  CheckedFiles.Clear;
  IterateTree(CheckedToAllFiles);
  result := CheckedFiles;
end;

function TDCNewBrowseTreeView.GetCheckedFilesInDir(Dir : String) : TStrings;
var i : integer;
  ind : integer;
begin
  FCDir := Dir;
  CheckedFiles.Clear;
  IterateTree(CheckedToFiles);
  result := CheckedFiles;
end;

function TDCNewBrowseTreeView.CheckedToFIles(Node : TTreeNode) : boolean;
begin
  if Node = nil then
    exit;
  if TDrawNode(Node).Checkstate = CsChecked then
    if ExtractFilePath(String(Node.Data)) = FCDir then
      CheckedFiles.Add(String(Node.Data));
end;

function TDCNewBrowseTreeView.CheckedToAllFIles(Node : TTreeNode) : boolean;
begin
  if Node = nil then
    exit;
  if TDrawNode(Node).Checkstate = CsChecked then
    CheckedFiles.Add(String(Node.Data));
end;


function TDCNewBrowseTreeView.DeleteNodeIfEmptyDir(Node : TTreeNode) : boolean;
var IOS : integer;
  S : String;
begin
  S := String(Node.Data);
  if inherited DeleteNodeIfEmptyDir(Node) then begin
    IOS := AllDirs.IndexOf(S) ;
    if IOS <> -1 then
      AllDirs.Delete(IOS);
  end;
end;


function TDCNewBrowseTreeView.GetCheckedDirs : TStrings;
begin
  CheckedDirs.Clear;
  IterateTree(HasCheckedChildren);
  result := CheckedDirs;
end;

function TDCNewBrowseTreeView.HasCheckedChildren(Node : TTreeNode) : boolean;
var i : integer;
begin
  if Node = nil then exit;
  for i := 0 to Node.count-1 do
    if TDrawNode(Node.Item[i]).CheckState = csChecked then
      if CheckedDirs.IndexOf(String(Node.Data)) = -1 then
        CheckedDirs.Add(String(Node.Data));
end;

procedure TDCNewBrowseTreeView.SetAcceptedFiles(Accepts : TStrings);
begin
  FAcceptedFiles.Assign(Accepts);
  LoadAcceptedFiles;
end;

procedure TDCNewBrowseTreeView.SetDirectory(Dir : String);
var  Node, CNode : TTreeNode;
  PSTring : PChar;
begin
  PNode := AddFolder('Maps',nil);
  FDirectory := Dir;
  if FAcceptedFiles.Count > 0  then begin
    LoadAcceptedFiles;
    if Images.Count > 1 then
      Load(Dir,PNode);
  end;
end;

procedure TDCNewBrowseTreeView.Loaded;
var Node : TTreeNode;
  i : integer;
begin
  inherited Loaded;
  LoadAcceptedFiles;
end;

procedure TDCNewBrowseTreeView.LoadAcceptedFiles;
var i : integer;
  Bitmap : TBitmap;
  Ext : String;

begin
  if Images.Count < 3 then
    for i := 0 to FAcceptedFiles.Count-1 do begin
      Ext := FAcceptedFiles.Strings[i];
      Bitmap := FAcceptedFiles.Objects[i] As TBitmap;
      Images.AddMasked(Bitmap,FMaskColor);
    end;
end;

procedure TDCNewBrowseTreeView.Load(Dir : String; Node : TTreeNode);
  procedure ProcessSearchRec(Sr : TSearchRec);
  var AddedNode : TTreeNode;
      Ext : String;
      IExt : integer;
      NoExt : String;
      DataString : String;
      PString : PChar;
  begin
    if ((sr.Attr and faDirectory) > 0) and (sr.Name <> '.') and (sr.Name <> '..') then begin
      AddedNode := AddFolder(sr.Name,Node);
      DataString := Dir+sr.Name+'\';
      AllDirs.Add(DataString);
//      PString := PChar(AllDirs.Strings[AllDirs.Add(DataString)]);
      if AddedNode <> nil then
        AddedNode.Data := TObject(DAtaString);
      Load(Dir+sr.Name+'\',AddedNode);
    end else if ((sr.Attr and faDirectory) <= 0) then begin
      Ext := ExtractFileExt(sr.name);
      IExt := FAcceptedFiles.IndexOf(Ext);
      if IExt > -1 then begin
         NoExt := Copy(Sr.Name,1,Length(Sr.Name)-4);
         AddedNode := AddNode(NoExt,nil,Node,IExt);
         DataString := Dir+sr.Name;
         AllFiles.Add(DataString);

//         PString := PChar(AllFiles.Strings[AllFiles.Add(DataString)]);
         if AddedNode <> nil then
           AddedNode.Data := Tobject(Datastring);
         if Assigned(FAddedNode) then
            FAddedNode(Self,Dir, Sr.Name, AddedNode);
      end;
    end;
  end;

var sr: TSearchRec;

begin
  if (FindFirst(Dir+'*.*', faAnyFile, Sr) = 0) then
    ProcessSearchRec(sr);
  while (FindNext(sr) = 0) do
    ProcessSearchRec(sr);
  FindClose(sr);
end;

procedure TDCNewBrowseTreeView.PruneTextNotInStrings(ExtS : TStrings);
begin
  LStrings.Clear;
  LStrings.AddStrings(Exts);
  IterateTree(CheckTextInStrings);
end;

function TDCNewBrowseTreeView.CheckTextInStrings(Node : TTreeNode) : boolean;
begin
  if LStrings.IndexOf(Node.Text) = -1 then
    Items.Delete(Node);
end;

procedure TDCNewBrowseTreeView.PruneDataNotInDirs(ExtS : TStrings);
begin
  LStrings.Clear;
  LStrings.AddStrings(Exts);
  IterateTreeBack(CheckDataInDirs);
  DeleteEmptyDirs;
end;

function TDCNewBrowseTreeView.CheckDataInDirs(Node : TTreeNode) : boolean;
var TP : Boolean;
  i : Integer;
  EFP : String;
  LS : STring;
begin
  if IsDir(Node) then exit;
  for i := 0 to LStrings.Count-1 do begin
    EFP := ExtractFilePath(String(Node.Data));
    LS := LSTrings.Strings[i];
    if  (EFP = LS)  then
      exit;
  end;
  Items.Delete(Node);
end;

procedure TDCNewBrowseTreeView.CheckNodesInStrings(SS : TStrings);
begin
  LStrings.Assign(SS);
  IterateTree(CheckIfInStrings);
end;

function TDCNewBrowseTreeView.CheckifInStrings(Node : TTreeNode) : boolean;
begin
  if Node = nil then exit;
  if not IsDir(Node) then if
    (LStrings.IndexOf(String(Node.Data)) <> - 1 ) then
      TDrawNode(Node).CheckState := csChecked
    else
      TDrawNode(Node).CheckState := csUnChecked;
end;

function TDCNewBrowseTreeView.IsCheckedChildren(Node : TTreenode) : boolean;
var i : integer;
   pr : boolean;
begin
  result := false;
  for i := 0 to Node.Count-1 do begin
    if Isdir(Node.Item[i]) then
      pr := HasCheckedChildren(Node.Item[i])
    else
      pr := (TDrawNode(Node).CheckState = csChecked);
    if pr = true then begin
      result := true;
      break;
    end;
  end;
end;


procedure Register;
begin
  RegisterComponents('Geoclick', [TDCNewBrowseTreeView]);
end;

end.
