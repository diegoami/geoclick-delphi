unit uHyperImagesTreeView;
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
  dcDTree, DcTree, comctrls, uDCNewBrowseTreeVie;

type

  THyperImagesTreeView = class(TDCNewBrowseTreeView)
    private

      HyperImagesBitmap : TBitmap;
 {     HSFTreeView : THSFTreeView;
      HyperList : TList;}
     //procedure AddHyperImage(Node : TTreeNode);
      function RemoveMuteNode(Node : TTreeNode) : boolean;
      function RemoveClearNode(Node : TTreeNode) : boolean;
    protected
      PNode : TTreeNode;
      procedure SetDirectory(Dir: String); override;
//      function CreateHyperImage(Dir, Name : String; TreeView : THsfTreeView ) : THyperImagesScrollBox;
    public

//      procedure AddHyperImages(Treeview : THsfTreeView);
//      function  AddNode(Description : String; Obj : Pointer; Where : TTreeNode;Index : integer) : TTreeNode;
      procedure Loaded; override;
      constructor Create(AOwner :TCOmponent);
      destructor Destroy; override;
      procedure RemoveMute;
      procedure RemoveClear;
    end;

procedure Register;

implementation

procedure THyperImagesTreeView.SetDirectory(Dir: String);
begin
  inherited SetDirectory(Dir);
 //  DeleteEmptyDirs;
//  SetChecked;
end;

procedure THyperImagesTreeView.Loaded;

begin
  inherited Loaded;
  CheckBoxes := True;
  PNode := Items.AddChild(nil,'Maps');
  PNode.ImageIndex := 1;
  PNode.SelectedIndex := 2;
end;


constructor THyperImagesTreeView.Create(AOwner :TCOmponent);
var Accepted : TStrings;
   Node : TTreeNode;

begin
  inherited Create(AOwner);


  HideSelection := false;
  HyperImagesBitmap := TBitmap.Create;
  try
    HyperImagesBitmap.LoadFromFile(ExtractFilePath(Application.ExeName)+'Components\jpg.bmp');
    Accepted := TStringList.Create;
    Accepted.AddObject('.bmp',HyperImagesBitmap);
    Accepted.AddObject('.jpg',HyperImagesBitmap);
    AcceptedFiles.Assign(Accepted);
    LoadAcceptedFiles;
    Accepted.Free;
  except on Exception do

    raise Exception.Create('Missing files . Please reinstall');
  end;



end;

destructor THyperImagesTreeView.Destroy;
begin
  HyperImagesBitmap.Free;
  inherited;
end;

function THyperImagesTreeView.RemoveClearNode(Node : TTreeNode) : boolean;
var name : String;
begin
  if (Node <> nil) and (not Isdir(Node) ) then begin
    Name := ExtractFileName(String(Node.Data));
    if Pos('m.', Name) = 0 then
      Items.Delete(Node)
  end;
end;


procedure THyperImagesTreeView.RemoveMute;
begin
  IterateTreeBack(RemoveMuteNode);
end;

procedure THyperImagesTreeView.RemoveClear;
begin
  IterateTreeBack(RemoveClearNode);
end;



function THyperImagesTreeView.RemoveMuteNode(Node : TTreeNode) : boolean;
var name : String;
begin
  if (Node <> nil) and (not Isdir(Node) ) then begin
    Name := ExtractFileName(String(Node.Data));
    if Pos('m.', Name) > 0 then
      Items.Delete(Node)
  end;
end;

procedure Register;
begin
  RegisterComponents('Geoclick', [THyperImagesTreeView]);
end;

end.
