unit uDCBrowseTreeView;
{per caricare questo albero si puo assegnare la proprieta Directory
  oppure usare Assign per i Treenodes da un altro albero, assegnare
  AllFiles da CheckFiles dell'altro albero e poi effettuare
  un potaggio in base all'estensione.
  E' uno schifo lo so.
  Nel caricamento il campo data e' una stringa.
  Il casino deriva dall'avere voluto usare lo stesso oggetto per due
  alberi aventi due funzionalita sostanzialmente diverse, il primo per
  selezionare quali file caricare, il secondo per muoversi tra i vari file
  di immagini.
  TO do : un ripensamento di questa (pessima) soluzione.
}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dcDTree, DcTree, comctrls;

type
  TTVAddedEvent = procedure(Sender: TObject; Dir, Name : String; Node : TTreeNode) of object;

  TIterateProc = procedure(Node : TTreeNode) of object;

  TDCBrowseTreeView = class(TDCMSTreeView)
   private
    ClosedBitmap, OpenBitmap : TBitmap;
    FMaskColor : TColor;
    FDirectory : String;
    procedure SetChecked;
    procedure CheckNode(Node : TTreeNode);
    procedure IterateTree(IterateProc : TIterateProc);
    procedure LoadAcceptedFiles;
    procedure RemoveUnchecked(Node : TTreeNode);
  protected
    FAcceptedFiles : TStrings;
    FAddedNode : TTVAddedEvent;


    //procedure SetNodeBitmap(Bitmap : TBitmap);
    //procedure SetNegNodeBitmap(Bitmap : TBitmap);
    CheckedFiles : TStrings;

    procedure SetDirectory(Dir: String);
    procedure SetAcceptedFiles(Accepts : TStrings);
  public
    AllFiles, Alldirs : TStrings;
    function GetCheckedFiles : TStrings;
    procedure PruneNotInAll(Exte : String);
    {procedure PruneTreeNodes(INstrings : TStrings);}

    function  AddNode(Description : String; Obj : Pointer; Where : TTreeNode;Index : integer) : TTreeNode;
    function AddFolder(Description : String;  Where : TTreeNode) : TTreeNode;
    constructor Create(AOwner : TComponent) ; override;
    procedure Load(Dir : String; Node : TTreeNode);
    procedure Loaded; override;
  published
    property MaskColor : TColor read FMaskColor write FMaskColor;
    property AcceptedFiles : TStrings read FAcceptedFiles write SetAcceptedFiles;
    property OnAddedNode: TTVAddedEvent read FAddedNode write FAddedNode;
    property Directory : String read FDirectory write SetDirectory;
  end;

procedure Register;

implementation

constructor TDCBrowseTreeView.Create(AOwner :TCOmponent);

begin
  inherited Create(AOwner);
  FAcceptedFiles := TStringList.Create;
  AllFiles := TStringList.Create;
  CheckedFiles := TStringList.Create;
  AllDirs := TStringList.Create;
end;

procedure TDCBrowseTreeView.RemoveUnchecked(Node : TTreeNode);
var S : String;
begin
  if (Node.ImageIndex <> 0) and (TDrawNode(Node).Checkstate = csUnchecked) then begin
    S := String(Node.Data);
    CheckedFiles.Delete(CheckedFiles.IndexOf(S));
  end;
end;


function TDCBrowseTreeView.GetCheckedFiles : TStrings;
begin
  CheckedFiles.Assign(AllFiles);
  IterateTree(RemoveUnchecked);
  result := CheckedFiles;
end;

function TDCBrowseTreeView.AddFolder(Description : String; Where : TTreeNode) : TTreeNode;
var  addednode            : TTreeNode;
begin
  {if Where = nil then
    Where := TTreeNode(Selected;}
  Addednode  := TTreeNode(Items.AddChild(Where , Description));

  Addednode.ImageIndex    := 0;
  Addednode.SelectedIndex := 1;
  Selected := Addednode;
  Result := Addednode;
end;

function TDCBrowseTreeView.AddNode(Description : String; Obj : Pointer; Where : TTreeNode; Index : integer) : TTreeNode;
var  addednode            : TTreeNode;
begin
  {if Where = nil then
    Where := Selected;}
  Addednode  := TTreeNode(Items.AddChildObject(Where, Description,Obj));

  Addednode.ImageIndex    := Index+2;
  Addednode.SelectedIndex := Index+2;
  Result := AddedNode;
end;

procedure TDCBrowseTreeView.SetAcceptedFiles(Accepts : TStrings);
begin
  FAcceptedFiles.Assign(Accepts);
  LoadAcceptedFiles;
end;

procedure TDCBrowseTreeView.IterateTree(IterateProc : TIterateProc);


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

procedure TDCBrowseTreeView.CheckNode(Node : TTreeNode);
  begin
    if not (Node.ImageIndex = 0) then begin

      TDrawNode(Node).CheckState:= csChecked;
    end else begin
      TDrawNode(Node).CheckState := csNone;
      if Node.HasChildren = False then
        Items.Delete(Node);
    end;
  end;


procedure TDCBrowseTreeView.SetChecked;

begin
  IterateTree(CheckNode);
end;

procedure TDCBrowseTreeView.SetDirectory(Dir : String);
var  Node, CNode : TTreeNode;
  PSTring : PChar;
begin

  FDirectory := Dir;
  if FAcceptedFiles.Count > 0 then begin
    Node := AddFolder(Dir,nil);
    PString := PChar(AllDirs.Strings[AllDirs.Add(Dir)]);
    Node.Data := PString;
    LoadAcceptedFiles;
    Load(Dir,Node);
  end;
  SetChecked;
end;

procedure TDCBrowseTreeView.Loaded;
var Node : TTreeNode;
  i : integer;

begin
  Images := TImageList.Create(Self);
  ClosedBitmap := TBitmap.Create;
  try
    ClosedBitmap.LoadFromFile('ftv2folderclosed.bmp');
  except on Exception do end;
  Images.AddMasked(ClosedBitmap,clRed);
  OpenBitmap := TBitmap.Create;
  try
    OpenBitmap.LoadFromFile('ftv2folderopen.bmp');
  except on Exception do end;
  Images.AddMasked(OpenBitmap,clRed);

end;

procedure TDCBrowseTreeView.LoadAcceptedFiles;
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


procedure TDCBrowseTreeView.Load(Dir : String; Node : TTreeNode);
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
       PString := PChar(AllDirs.Strings[AllDirs.Add(DataString)]);
       if AddedNode <> nil then
         AddedNode.Data := PString;
      Load(Dir+sr.Name+'\',AddedNode);
    end else if ((sr.Attr and faDirectory) <= 0) then begin
      Ext := ExtractFileExt(sr.name);
      IExt := FAcceptedFiles.IndexOf(Ext);
      if IExt > -1 then begin
         NoExt := Copy(Sr.Name,1,Length(Sr.Name)-4);

         AddedNode := AddNode(Sr.Name,nil,Node,IExt);
         DataString := Dir+sr.Name;
         PString := PChar(AllFiles.Strings[AllFiles.Add(DataString)]);
         if AddedNode <> nil then
           AddedNode.Data := Pstring;


         if Assigned(FAddedNode) then
            FAddedNode(Self,Dir, Sr.Name, AddedNode);

      end;
    end;
  end;

var sr: TSearchRec;

var i : integer;

begin

  if (FindFirst(Dir+'*.*', faAnyFile, Sr) = 0) then
    ProcessSearchRec(sr);
  while (FindNext(sr) = 0) do
    ProcessSearchRec(sr);

end;

procedure TDCBrowseTreeView.PruneNotInAll(Exte : String);
var DrawNode, NextNode : TDrawNode;
  //Nodes : TTreeNodes;
  i : integer;
  ISS: integer;

  S, Ext : STring;
begin
  DrawNode := TDrawNode(Items.Item[0]);
  while DrawNode <> nil do begin
    NextNode := TDrawNode(DrawNode.GetNext);

    if (DrawNode.ImageIndex <> 0) then begin
      Ext := ExtractFileExt(DrawNode.Text);
      if (Ext = Exte) and (AllFiles.IndexOf(String(DrawNode.Data)) = -1 ) then
      Items.Delete(DrawNode);

    end;

    DrawNode := NextNode;
  end;
                                 
  DrawNode := TDrawNode(Items.Item[0]);
  while DrawNode <> nil do begin
    NextNode := TDrawNode(DrawNode.GetNext);

    if (DrawNode.Checkstate = csNone) and (not DrawNode.hasChildren) then
      Items.Delete(DrawNode);
    DrawNode := NextNode;
  end;

end;




procedure Register;
begin
  RegisterComponents('Additional', [TDCBrowseTreeView]);
end;

end.
