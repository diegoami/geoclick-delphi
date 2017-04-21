unit URLTreeViewFiller;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HTMLParser, HTMLMisc,Misc, extctrls, comctrls, UrlFiller, uDaUrlLink;

type

  TOnHeaderFound = procedure (Sender : TObject; Name : String; Lev : Integer) of object;
  TOnLinkFound = procedure (Sender : TObject; Title : String; Url : String) of object;

  THTMLTreeViewPArser = class(THTMLFullPArser)
  private

    FTreeView : TTreeView;
    FOnHeaderFound : TOnHeaderFound;
    FOnLinkFound : TOnLinkFound;

  protected
    procedure FIllTreeView;
  public
    procedure ParseAndFillTreeView(PageStr : string);
  published
    property TReeView : TTreeView read FTreeView write FTreeView;
  end;

procedure Register;

implementation

const MAX_NODES = 18;
          ceHeaders = 'h1|h2|h3|h4|h5|h6';


procedure THTMLTreeViewPArser.ParseAndFillTreeView(PageStr : String);
begin
  Parse(PageStr);
  if Assigned(FTreeView) then
    FillTreeView;
end;

procedure THTMLTreeViewPArser.FillTreeView;
var Counter : integer;
  Level : integer;
  NodeArray : array[0..MAX_NODES] of TTreeNode;
  CurrLink : TDAURLLink;

// ----------------

  function CreateLink(DURL, DTitle : String) : TDAUrlLink;
  begin
    CurrLink := TDaUrlLink.Create;
    CurrLink.URL := DURL;
    CurrLink.Title := DTitle;
    NodeArray[Level+1] := FTreeView.Items.AddChildObject(NodeArray[Level],DTitle,CurrLink);
    result := CurrLink;
    if Assigned(FOnLinkFound) then
      FonLinkFound(Self,DTitle, Durl);
  end;

  procedure AddTags( Tag : TTagNode);

  var
    Counter : integer;
    NewLevel : integer;
    PF : integer;
    ST : String;
  begin
    PF := Pos(LowerCase(Tag.Caption),ceHeaders) ;
    if PF > 0 then begin
      NewLevel := StrToInt(Copy(ceHeaders,PF+1,1));
      ST := Trim(HTMLDecode(RemoveCRLFs(Tag.GetPCData)));
      if NewLevel > Level then begin
        NodeArray[Level+1] :=FTreeView.Items.AddChiLd(NodeArray[Level],ST);
        Inc(Level)
      end else begin
        if NewLevel < Level then begin
          Dec(Level)
        end;
        NodeArray[Level] :=FTreeView.Items.AddChiLd(NodeArray[Level-1],ST);
      end;
      if Assigned(FOnHeaderFound) then
        FOnHeaderFound(Self, ST, Level);
    end else
    If Tag.NodeType = nteElement then
      If CompareText(Tag.Caption,'a') = 0 then
        CurrLink := CreateLink(Tag.Params.Values['href'],Trim(HTMLDecode(RemoveCRLFs(Tag.GetPCData))))
      else if (CompareText(Tag.Caption,'a') = 0) and (CurrLink <> nil) then
        CurrLink.Description := Trim(HTMLDecode(RemoveCRLFs(Tag.GetPCData)));
    for Counter := 0 to Tag.ChildCount - 1 do
      AddTags(Tag.Children[Counter]);
end;

begin
  FTreeView.Items.Clear;
  Level := 0;
  for Counter := 0 to MAX_NODES do
    NodeArray[Counter] := nil;
  for Counter := 0 to Tree.ChildCount - 1 do
    AddTags(Tree.Children[Counter]);
end;

procedure Register;
begin
  RegisterComponents('Diego Amicabile', [THTMLTreeViewPArser]);
end;

end.
