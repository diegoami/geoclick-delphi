unit hHTMLOps;

interface

uses HTMLParser, classes;

function GetStringsFromDir(Directory : String) : TStrings;


implementation

function GetStringsFromDir(Directory : String) : TStrings;
var HtmlParser : THtmlParser;
begin
  HtmlParser := THtmlParser.Create(nil);
  HtmlParser.Parse(Directory);
end;

initialization



end.

