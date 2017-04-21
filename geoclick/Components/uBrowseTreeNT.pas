unit uBrowseTreeNT;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TreeNT;

type

  TTVAddedEvent = procedure(Sender: TObject; Dir, Name : String) of object;

  TBrowseTreeNT = class(TTreeNT)
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
    function  AddNode(Description : String; Obj : Pointer; Where : TTreeNTNode;Index : integer) : TTreeNTNode;
    function AddFolder(Description : String;  Where : TTreeNTNode) : TTreeNTNode;
    constructor Create(AOwner : TComponent) ; override;
    procedure Load(Dir : String; Node : TTreeNTNode);
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

constructor TBrowseTreeNT.Create(AOwner :TCOmponent);

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
procedure TBrowseTreeNT.SetNodeBitmap(Bitmap : TBitmap);
begin
  FNodeBitmap := Bitmap;
  Images.AddMasked(FNodeBitmap,FMaskColor);
end;                }

{
procedure TBrowseTreeNT.SetNegNodeBitmap(Bitmap : TBitmap);
begin
  FNegNodeBitmap := Bitmap;
  Images.AddMasked(FNegNodeBitmap,FMaskColor);
end;

}
function TBrowseTreeNT.AddFolder(Description : String; Where : TTreeNTNode) : TTreeNTNode;
var  addednode            : TTreeNTNode;
begin
  if Where = nil then
    Where := Selected;
  Addednode  := Items.AddChildObject(Where, Description, nil);
  
  Addednode.ImageIndex    := 0;
  Addednode.SelectedIndex := 1;
  Selected := Addednode;
  Result := Addednode;
end;



function TBrowseTreeNT.AddNode(Description : String; Obj : Pointer; Where : TTreeNTNode; Index : integer) : TTreeNTNode;
var  addednode            : TTreeNTNode;
begin
  if Where = nil then
    Where := Selected;
  Addednode  := Items.AddChildObject(Where, Description, Obj);
  
  Addednode.ImageIndex    := Index+2;
  Addednode.SelectedIndex := Index+2;
end;

procedure TBrowseTreeNT.SetAcceptedFiles(Accepts : TStrings);
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

procedure TBrowseTreeNT.SetDirectory(Dir : String);
var Node : TTreeNTNode;
  i : integer;
begin
  FDirectory := Dir;
  Items.BeginUpdate;
  Items.Clear;

  Node := AddFolder(Dir,nil);

  Load(Dir,Node);
  for i := 0 to Items.Count-1 do  begin
    Node := Items.Item[i];
    if not (Node.ImageIndex = 0)  then
      Node.Parent.CheckType := ctCheckBox;

  end;
  Items.EndUpdate;

end;

procedure TBrowseTreeNT.Load(Dir : String; Node : TTreeNTNode);

  procedure ProcessSearchRec(Sr : TSearchRec);
  var AddedNode : TTreeNTNode;
      Ext : String;
      IExt : integer;
      NoExt : String;
  begin
    if ((sr.Attr and faDirectory) > 0) and (sr.Name <> '.') and (sr.Name <> '..') then begin
      AddedNode := AddFolder(sr.Name,Node);

      Load(Dir+sr.Name+'\',AddedNode);
    end else if ((sr.Attr and faDirectory) <= 0) then begin
      Ext := ExtractFileExt(sr.name);
      IExt := FAcceptedFiles.IndexOf(Ext);
      if IExt > -1 then begin
         NoExt := Copy(Sr.Name,1,Length(Sr.Name)-4);
         //AddedNode := AddNode(NoExt,Node,IExt);
         if Assigned(FAddedNode) then
            FAddedNode(Self,Dir, Sr.Name)
         else begin
            AddedNode := AddNode(NoExt,nil,Node,IExt);

         end;
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
  RegisterComponents('Additional', [TBrowseTreeNT]);
end;

end.
