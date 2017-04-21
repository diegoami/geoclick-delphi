unit uHSFTreeVie;
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

  TDCNewBrowseTreeView = class(TDCSimpleBrowseTreeView)
   private
    FDirectory : String;
    LSTrings : TSTrings;
    procedure LoadFiles(Node : TTreeNode; Dir : String);
    procedure LoadAcceptedFiles;
    procedure CheckedToFIles(Node : TTreeNode);
  protected
    FAcceptedFiles : TStrings;

    function GetCheckedFiles : TStrings;
    procedure SetDirectory(Dir: String);
    procedure SetAcceptedFiles(Accepts : TStrings);
  public
    AllFiles : TStrings;
    AllDirs : TStrings;


    constructor Create(AOwner : TComponent) ; override;
    constructor CreateCond(Dirs : TStrings);
    procedure Load(Dir : String; Node : TTreeNode);
    procedure Loaded; override;
    procedure PruneTextNotInStrings(ExtS : TStrings);

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
end;

function TDCNewBrowseTreeView.GetCheckedFiles : TStrings;
begin
  CheckedToFiles.Clear;
  IterateProc(CheckedToFiles)
  result := CheckedFiles;
end;

procedure TDCNewBrowseTreeView.CheckedToFIles(Node : TTreeNode);
begin
  if TDrawNode(Node).Checkstate = CsChecked then
    CheckedToFiles.Add(String(Node.Data));
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
  FDirectory := Dir;
  if FAcceptedFiles.Count > 0 then begin
    LoadAcceptedFiles;
    Load(Dir,nil);
  end;
  SetChecked;
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


begin

  if (FindFirst(Dir+'*.*', faAnyFile, Sr) = 0) then
    ProcessSearchRec(sr);
  while (FindNext(sr) = 0) do
    ProcessSearchRec(sr);

end;


procedure TDCNewBrowseTreeView.PruneTextNotInStrings(ExtS : TStrings);
begin
  LStrings := Exts;
  IterateTree(CheckInStrings);
end;

procedure TDCNewBrowseTreeView.CheckTextInStrings(Node : TTreeNode);
begin
  if LStrings.IndexOf(Node.Text) = -1 then
    Items.Delete(Node);
end;

procedure Register;
begin
  RegisterComponents('Additional', [TDCNewBrowseTreeView]);
end;

end.
