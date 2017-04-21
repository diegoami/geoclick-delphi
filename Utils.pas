unit Utils;

interface

uses graphics, windows;

procedure Swap(var a, b : integer);
function min(a,b :integer) : integer;
function TerOp(cond : boolean; a,b : integer) : integer;
function InInterval(a,x,b :integer) : Integer;
function NVLInteger(Value, Def : integer) : INteger;
function NVLString(Value, Def : String) : String;
function FontStyleToInt(fs : TFontStyles) : integer;
function IntToFontStyle(ii : integer) : TFontStyles;
procedure getRGB(Color : TColor; var R,G,B : integer);

implementation

function min(a,b :integer) : integer;
begin
  if a < b then result := a else result := b;
end;



function FontStyleToInt(fs : TFontStyles) : integer;
begin
  result := 0;
  if fsBold in fs then result := result or 1;
  if fsItalic in fs then result := result or 2;
  if fsUnderline in fs then result := result or 4;
  if fsStrikeOut in fs then result := result or 8;
end;

function IntToFontStyle(ii : integer) : TFontStyles;
begin
  result := [];
  if (ii and 1) = 1 then result := result + [fsBold];
  if (ii and 2) = 2 then result := result + [fsItalic];
  if (ii and 4) = 4 then result := result + [fsUnderline];
  if (ii and 8) = 8 then result := result + [fsStrikeOut];
end;

function NVLInteger(Value, Def : integer ) : INteger;
begin

  if Value = 0 then
    result := Def
  else result := VAlue;
end;

function NVLString(Value, Def : String ) : String;
begin
  if Value = '' then
    result := Def
  else result := VAlue;
end;




function InInterval(a,x,b :integer) : Integer;
begin
  if x < a then result := a
  else if x > b then result := b
  else result := x;
end;

procedure Swap(var a, b : integer);
var x : integer;

begin
  x := a;
  a := b;
  b := x;
end;

function TerOp(cond : boolean; a,b : integer) : integer;
begin
  if cond then
    result := a
  else
    result := b;
end;

procedure getRGB(Color : TColor; var R,G,B : integer);
begin
  R := getRValue(Color);
  G := getGValue(Color);
  B := getBValue(Color);
end;




end.
