unit HtmlContainerFromTreeView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    IHTML4, URLTreeViewFiller, comctrls, extctrls,uDaUrlLink;

type
  THtmlContainerFromTreeView = class(THtmlContainer)
  private
    FJSStrings : TStrings;
    FFileName : String;
    SS : TStrings;
  protected
    procedure CreateLink(UrlLInk : TDaURLLink; Level : Integer);
    procedure CreateHeader(S : String; Level : integer);
  public
    procedure ReadAndFill(FTreeView : TTreeView);
    constructor Create;
  published
    property JSStrings : TStrings read FJSStrings write FJSSTrings;
    property FileName : String read FFileName write FFIleName;
  end;


implementation




function Spaces(n : integer) : String;
var i : integer;
begin
  SetLength(result,n);
  for i := 1 to n do
    result[i]:= ' ';
end; { Spaces }

procedure THtmlContainerFromTreeView.ReadAndFill(FTreeView : TTreeView);
var  CurrUrlLink : TDAUrlLink;


  procedure ParseSubTree(Node : TTreeNode; Level : integer); forward;

  procedure ParseNode(Node : TTreeNode; Level : Integer);
  begin
     if Node.Data <> nil then begin
        CurrUrlLink := TDAUrlLink(Node.Data);
        CreateLink(CurrUrlLink,Level)
      end else begin
        CreateHeader(Node.Text,Level);
        ParseSubTree(Node,Level+1)
      end
  end;


  procedure ParseSubTree(Node : TTreeNode; Level : integer);
  var i : integer;
    CurrNode : TTreeNode;

  begin
    for i := 0 to Node.Count-1 do begin
      CurrNode := Node.Item[i];
      ParseNode(CurrNode,Level);

    end
  end;

var i : integer;
  CNode : TTreeNode;


begin

  if Assigned(FtreeView) and (FTreeView.Items.Count > 0) then begin
    CreateHeader(FFileName,0);
    for i := 0 to FTreeView.Items.Count-1 do begin
      CNode := FTreeView.Items[i];
      if CNode.Parent = nil then begin
         ParseNode(CNode,1)
      end
    end

  end;
  SS.Text := AsHTML;
  if FileName <> '' then
    SS.SaveToFile(FileName);
end;

constructor THtmlContainerFromTreeView.Create;
begin
  inherited;
  SS := TStringList.Create;
  FJSStrings := TStringList.Create;
end;



procedure THtmlContainerFromTreeView.CreateLink(UrlLInk : TDaURLLink; Level : Integer);
var VarParString, VarString : String;
  OutString : String;
begin
  if level = 0 then exit;
  VarParString :=  'aux'+IntToStr(level-1);
  VarString :='aux'+IntToStr(level);
  if Level = 1 then
      VarParString := 'foldersTree';
  OutString :=Spaces(level*3)+'insDoc('+VarParString+',gLnk('+IntToStr(Ord(URLLINK.locationtype))+',"'+URLLINK.Title+'","'+URLLINK.Url+'"))';
  FJSSTrings.Add(OutString);
  Add(THTMLLink.Create(UrlLink.URL, UrlLink.Title));
  Add(THTMLParagraph.Create(UrlLink.Description));
end;

procedure THtmlContainerFromTreeView.CreateHeader(S : String; Level : integer);
var VarParString, VarString : String;
  OutString : String;
begin
  VarParString :=  'aux'+IntToStr(level-1);
  VarString :='aux'+IntToStr(level);
  if Level = 0 then begin
    VarString := 'foldersTree';
    OutString := 'foldersTree = gFld("'+S+'","'+FFileName+'")'
  end else begin
    if Level = 1 then
      VarParString := 'foldersTree';
    OutString :=Spaces(level*3)+VarString+' = insFld('+VarParString+', gFld("'+S+'","'+'"))';
  end;
  FJSSTrings.Add(OutString);
  Add(THTMLHeading.Create(Level, S));
end;

end.
