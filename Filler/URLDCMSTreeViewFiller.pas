unit URLDCMSTreeViewFiller;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HTMLParser, HTMLMisc, Misc, extctrls, comctrls, UrlFiller, uDaUrlLink, dcdtree;

type




  TOnHeaderFound = procedure (Sender : TObject; Name : String; Lev : Integer) of object;
  TOnLinkFound = procedure (Sender : TObject; Title : String; Url : String) of object;

  THTMLDCMSTreeViewPArser = class(THTMLFullPArser)
  private

    FTreeView : TDCMSTreeView;
    FOnHeaderFound : TOnHeaderFound;
    FOnLinkFound : TOnLinkFound;

  protected
    procedure FIllTreeView(RootNode : TTreeNode = nil);

  public
    procedure ParseAndFillTreeView(PageStr : string; RootNode : TTreeNode = nil);
  published
    property TreeView : TDCMSTreeView read FTreeView write FTreeView;

  end;

procedure Register;

implementation

const MAX_NODES = 18;
      ceHeaders = 'h1|h2|h3|h4|h5|h6';


procedure THTMLDCMSTreeViewParser.ParseAndFillTreeView(PageStr : String; RootNode : TTreeNode = nil);
begin
  Parse(PageStr);
  if Assigned(FTreeView) then
    FillTreeView(RootNode);
end;

procedure THTMLDCMSTreeViewParser.FillTreeView(RootNode : TTreeNode = nil);
var Counter : integer;
  Level : integer;
  NodeArray : array[0..MAX_NODES] of TTreeNode;
  CurrLink : TDAURLLink;
  lastHeader, lastLink : String;
  WasLink, WasParagr : Boolean;

// ----------------

  function CreateLink(DURL, DTitle : String) : TDAUrlLink;
  begin
    if (DURL = '') or (DTitle = '') then exit;
    CurrLink := TDaUrlLink.Create;

    CurrLink.URL := DURL;
    CurrLink.Title := DTitle;
    if Pos('http',DURL) > 0 then
      CurrLink.LocationType := TOFRAME
    else
      CurrLink.LocationType := LOCAL;
//    NodeArray[Level+1] := FTreeView.Items.AddChildObject(NodeArray[Level],DTitle,CurrLink);
    result := CurrLink;
    if Assigned(FOnLinkFound) then
      FonLinkFound(Self,DTitle, Durl);
  end;

  function AddLink(Description : String) : TDAUrlLink;

  begin
    CurrLink.Description := Description;
    NodeArray[Level+1] := FTreeView.Items.AddChildObject(NodeArray[Level],CurrLink.Title,CurrLink);
    result := CurrLInk;
  end;

  function CreateHeader(DTitle : String) : TDAUrlLink;
  begin
    CurrLink := TDaUrlLink.Create;
    CurrLink.Title := DTitle;
    NodeArray[Level+1] := FTreeView.Items.AddChildObject(NodeArray[Level],DTitle,CurrLink);
    result := CurrLink;
      if Assigned(FOnHeaderFound) then
        FOnHeaderFound(Self,DTitle, Level);
  end;


  procedure AddTags( Tag : TTagNode);

  var
    Counter : integer;
    NewLevel : integer;
    PF : integer;

    CTAg : TTagNode;
  begin
    PF := Pos(LowerCase(Tag.Caption),ceHeaders) ;
    if (PF > 0) then begin
      LastLink := '';
      LastHeader := Trim(HTMLDecode(RemoveCRLFs(Tag.GetPCData)));
         WasParagr := False;
      WasLink := False;
      for Counter := 0 to Tag.ChildCount - 1 do begin
        CTag := Tag.Children[Counter];
        If CompareText(CTag.Caption,'a') = 0 then
          LastLink := CTag.Params.Values['href'];
      end;
    end else


    if CompareText(Tag.Caption,'DL') = 0 then begin
      CurrLink := CreateHeader(LastHeader);
      if (Length(LastLink) > 0) then
        CurrLink.Url := LastLink;
      Inc(Level);

      WasParagr := False;
      WasLink := False;

      for Counter := 0 to Tag.ChildCount - 1 do
        AddTags(Tag.Children[Counter]);
      Dec(level);
    end else begin
      If Tag.NodeType = nteElement then begin
        If CompareText(Tag.Caption,'a') = 0 then begin
          CurrLink := CreateLink(Tag.Params.Values['href'],Trim(HTMLDecode(RemoveCRLFs(Tag.GetPCData))));
          WasLink := True;
          WasParagr := False;

        end else if (CompareText(Tag.Caption,'p') = 0) and (CurrLink <> nil) and WasLink then begin
          CurrLink := AddLInk(Trim(HTMLDecode(RemoveCRLFs(Tag.GetPCData))));
          WasParagr := True;
          WasLink := False;
        end else if WasLInk and (not WasParagr) then begin
          CurrLink := AddLink('');
          WasLink := false;
          WasParagr := false;
        end  else begin
          WasParagr := False;
          WasLink := False;
        end;

      end;



      for Counter := 0 to Tag.ChildCount - 1 do
        AddTags(Tag.Children[Counter]);



    end;
end;

begin
  WasLink := False;
  WasParagr := False;

  if RootNode = nil then
     FTreeView.Items.Clear;
  Level := 0;
  for Counter := 0 to MAX_NODES do
    NodeArray[Counter] := RootNode;
  for Counter := 0 to Tree.ChildCount - 1 do
    AddTags(Tree.Children[Counter]);
end;

procedure Register;
begin
  RegisterComponents('Diego Amicabile', [THTMLDCMSTreeViewParser]);
end;

end.
