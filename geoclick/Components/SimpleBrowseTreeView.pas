unit SimpleBrowseTreeView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type
  TBrowseTreeView = class(TTreeView)
  private
    ClosedBitmap, OpenBitmap : TBitmap;
  protected
    FNodeBitmap : TBitmap;
    procedure SetNodeBitmap(Bitmap : TBitmap);
  public

    constructor Create(AOwner : TComponent) ; override;
  published
    property NodeBitmap : TBitmap read FNodeBitmap write setNodeBitmap;
  end;

procedure Register;

implementation

constructor TBrowseTreeView.Create(AOwner :TCOmponent);

begin
  inherited Create(AOwner);
  Images:= TImageList.Create(AOwner);
  try
    ClosedBitmap.LoadFromFile('ftv2folderclosed.bmp');
  except on Exception do end;
  Images.Add(ClosedBitmap,nil);
  try
    OpenBitmap.LoadFromFile('ftv2folderopen.bmp');
  except on Exception do end;
  Images.Add(OpenBitmap,nil);
end;

procedure TBrowseTreeView.SetNodeBitmap(Bitmap : TBitmap);
begin
  FNodeBitmap := Bitmap;
  Images.Add(FNodeBitmap);
end;

function TBrowseTreeView.AddFolder(Description : String; Obj : Pointer; Where : TTreeNode) : TTreeNode;
var  addednode            : TTreeNode;
begin
  if Where = nil then
    Where = Selected;
  Addednode  := Items.AddChildObject(Where, Description, Obj);
  Addednode.ImageIndex    := 0;
  Addednode.SelectedIndex := 1;
  Selected := Addednode;
  Result := Addednode;
end;

procedure TBrowseTreeView.AddNode(Description : String; Obj : Pointer; Where : TTreeNode);
var  addednode            : TTreeNode;
begin
  if Where = nil then
    Where = Selected;
  Addednode  := Items.AddChildObject(Where, Description, Obj);
  Addednode.ImageIndex    := 2;
  if ImageList.Count > 2 then
    Addednode.SelectedIndex := 3;
end;




procedure Register;
begin
  RegisterComponents('Additional', [TSimpleBrowseTreeView]);
end;

end.
