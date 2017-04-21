unit URLFiller;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HTMLParser, HTMLMisc, Misc, extctrls, comctrls, uDaUrlLink;

type


  THTMLFullPArser = class(THTMLParser)
  private

    FTitle : String;

  protected
  public
    procedure FillParsed;
  published
    property Title : String read FTitle write FTitle;
  end;

procedure Register;

implementation




procedure THTMLFullPArser.FillParsed;
var Counter : integer;

// ----------------


  procedure AddTags( Tag : TTagNode);

  var
    Counter : integer;
  begin
    If Tag.NodeType = nteElement then
      If CompareText(Tag.Caption,'title') = 0 then
        FTitle := Trim(HTMLDecode(RemoveCRLFs(Tag.GetPCData)));
    for Counter := 0 to Tag.ChildCount - 1 do
      AddTags(Tag.Children[Counter]);
end;

begin
  for Counter := 0 to Tree.ChildCount - 1 do
    AddTags(Tree.Children[Counter]);
end;


procedure Register;
begin
  RegisterComponents('Diego Amicabile', [THTMLFullParser]);
end;

end.
