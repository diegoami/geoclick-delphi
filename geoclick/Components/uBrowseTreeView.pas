unit uBrowseTreeView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type

  TTVAddedEvent = procedure(Sender: TObject; Dir, Name : String) of object;

  TOBjString = class(TComponent)
    public
      str : String;

      constructor Create(Astr : String); 
  end;


  TBrowseTreeView = class(TTreeView)
  private
    ClosedBitmap, OpenBitmap : TBitmap;
    FMaskColor : TColor;
    FDirectory : String;
  protected
    FAcceptedFiles : TStrings;
    FAddedNode : TTVAddedEvent;

    FNodeBitmap, FNegNodeBitmap : TBitmap;
    //procedure SetNodeBitmap(Bitmap : TBitmap);
    //procedure SetNegNodeBitmap(Bitmap : TBitmap);
    procedure SetDirectory(Dir: String);
    procedure SetAcceptedFiles(Accepts : TStrings);
  public
    function  AddNode(Description : String; Obj : Pointer; Where : TTreeNode;Index : integer) : TTreeNode;
    function AddFolder(Description : String;  Where : TTreeNode) : TTreeNode;
    constructor Create(AOwner : TComponent) ; override;
    procedure Load(Dir : String; Node : TTreeNode);
  published
    property MaskColor : TColor read FMaskColor write FMaskColor;
    //property NodeBitmap : TBitmap read FNodeBitmap write setNodeBitmap;
    //property NegNodeBitmap : TBitmap read FNegNodeBitmap write setNegNodeBitmap;
    property AcceptedFiles : TStrings read FAcceptedFiles write SetAcceptedFiles;
    property OnAddedNode: TTVAddedEvent read FAddedNode write FAddedNode;
    property Directory : String read FDirectory write SetDirectory;
  end;

procedure Register;

implementation

constructor TObjString.Create(Astr : String);
begin
  inherited Create(nil);
  Str := Astr;
end;


constructor TBrowseTreeView.Create(AOwner :TCOmponent);

begin
  inherited Create(AOwner);
  FAcceptedFiles := TStringList.Create;
  Images := TImageList.Create(AOwner);
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
                   {
procedure TBrowseTreeView.SetNodeBitmap(Bitmap : TBitmap);
begin
  FNodeBitmap := Bitmap;
  Images.AddMasked(FNodeBitmap,FMaskColor);
end;                }

{
procedure TBrowseTreeView.SetNegNodeBitmap(Bitmap : TBitmap);
begin             
  FNegNodeBitmap := Bitmap;
  Images.AddMasked(FNegNodeBitmap,FMaskColor);
end;

}
function TBrowseTreeView.AddFolder(Description : String; Where : TTreeNode) : TTreeNode;
var  addednode            : TTreeNode;
begin
  if Where = nil then
    Where := Selected;
  Addednode  := Items.AddChildObject(Where, Description, nil);
  Addednode.ImageIndex    := 0;
  Addednode.SelectedIndex := 1;
  Selected := Addednode;
  Result := Addednode;
end;



function TBrowseTreeView.AddNode(Description : String; Obj : Pointer; Where : TTreeNode; Index : integer) : TTreeNode;
var  addednode            : TTreeNode;
begin
  if Where = nil then
    Where := Selected;
  Addednode  := Items.AddChildObject(Where, Description, Obj);
  Addednode.ImageIndex    := Index+2;
  Addednode.SelectedIndex := Index+2;
  Result := AddedNode;
end;

procedure TBrowseTreeView.SetAcceptedFiles(Accepts : TStrings);
var i : integer;
  Bitmap : TBitmap;
  Ext : String;
begin
  FAcceptedFiles.Assign(Accepts);
  for i := 0 to Accepts.Count-1 do begin
    Ext := Accepts.Strings[i];
    Bitmap := Accepts.Objects[i] As TBitmap;
    Images.AddMasked(Bitmap,FMaskColor);
  end;
end;

procedure TBrowseTreeView.SetDirectory(Dir : String);
var Node : TTreeNode;
begin
  FDirectory := Dir;
  Items.Clear;
  Node := AddFolder(Dir,nil);

  Load(Dir,Node);

end;

procedure TBrowseTreeView.Load(Dir : String; Node : TTreeNode);

  procedure ProcessSearchRec(Sr : TSearchRec);
  var AddedNode : TTreeNode;
      Ext : String;
      IExt : integer;
      NoExt : String;
      Alloc : Pointer;
  begin
    if ((sr.Attr and faDirectory) > 0) and (sr.Name <> '.') and (sr.Name <> '..') then begin
      AddedNode := AddFolder(sr.Name,Node);
      Load(Dir+sr.Name+'\',AddedNode);
      AddedNode.Data := TObjString.Create(Dir+sr.Name+'\');
    end else if ((sr.Attr and faDirectory) <= 0) then begin
      Ext := ExtractFileExt(sr.name);
      IExt := FAcceptedFiles.IndexOf(Ext);
      if IExt > -1 then begin
         NoExt := Copy(Sr.Name,1,Length(Sr.Name)-4);
         AddedNode := AddNode(NoExt,nil,Node,IExt);
         
         AddedNode.Data :=  TObjString.Create(Dir+sr.Name);
                        TObject.Create;
         if Assigned(FAddedNode) then
            FAddedNode(Self,Dir, Sr.Name);
      end;
    end;
  end;

var sr: TSearchRec;

begin
  if (FindFirst(Dir+'*.*', faAnyFile, Sr) = 0) then 
    ProcessSearchRec(sr);
  while (FindNext(sr) = 0) do
    ProcessSearchRec(sr);
end;

procedure Register;
begin
  RegisterComponents('Additional', [TBrowseTreeView]);
end;

end.
