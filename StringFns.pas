unit StringFns;

interface

uses sysutils, windows, shellapi;
function Instr(str:string;substr:string):integer;
function LeftStr(instring:string;index:integer):String;
function RightStr(instring:string;numchars:byte):String;
function MidStrToEnd(instring:string;index:integer):string;
function ReplaceStr(str,old,new:string):string;
function StringStripAll(instring,charac:string):string;
function StringStripLeading(instring,charac:string):string;
function StringStripTrailing(instring,charac:string):string;
function Capitalize(instring : String) : String;
function CharCount(s : string; c : char) : integer;
function RomanToArabic(S : string) : String;
function SpacesToLines(aString : String) : String;
function Quote( const SQLString: String ): String;
function GetWinDir : String;
procedure ShowWebPage(WebPage : String);
procedure PlayWav(SoundFileName : String);
function GetSpaces(N :integer) : String;
function PosFrom(Substr: String; Str : String; Start : integer) : integer;
function PosN(Substr: String; Str : String; N : integer) : integer;
function PosLast(Substr: String; Str : String) : integer;

implementation

uses mmsystem;

function PosFrom(Substr: String; Str : String; Start : integer) : integer;
var i : integer;
    tmpStr : String;
begin
  tmpStr := Copy(Str,Start,Length(Str)-Start+1);
  result := Pos(SubStr, TmpStr);
end;

function PosN(Substr: String; Str : String; N : integer) : integer;
var P,i : integer;
    tmpStr : String;

begin
  P := 1;
  TmpStr := Str;
  for i := 1 to N do begin
    P := PosFrom(SubStr,TmpStr,P);
    TmpStr := Copy(TmPStr,P,Length(TmpStr)-p+1)
  end;
  result := P
end;

function PosLast(Substr: String; Str : String) : integer;
var P,i, NewP : integer;
    tmpStr : String;

begin
  P := 1;
  TmpStr := Str;
  repeat

    NewP := Pos(SubStr,TmpStr);
    if (NewP > 0) then begin
      TmpStr := Copy(TmPStr,NewP+1,Length(TmpStr)-Newp);
      P := P+NewP;
    end;
  until NewP <= 0;
  result := P-1
end;

function GetSpaces(N :integer) : String;
var i : integer;
begin
  result := '';
  for i := 1 to N do
    result := result + ' ';
end;


function CharCount(s : string; c : char) : integer;
var i, count : integer;
begin
     count := 0;
     for i := 1 to Length(s) do
         if s[i] = c then inc(count);
     result := count;
end;



procedure ShowWebPage(WebPage : String);

begin
     Shellexecute(0,nil,Pchar(WebPage),nil,nil,SW_NORMAL);
end;


function Quote( const SQLString: String ): String;
begin
   if ( SQLString = '' ) then
        Result := ''
   else
        Result := Chr(39) + SQLString + Chr(39);
end;



function SpacesToLines(aString : String) : String;
var i : integer;
begin
  for i := 1 to length(aString) do
     if aString[i] = ' ' then
        aString[i] :='_';
     result := aString;
end;

function RomanToArabic(S : string) : String;
var value : integer;
    psfound : integer;

begin
     value := 0;
     psfound := 1;
     if (Pos('CD',S) > 0) or (Pos('CM',S) > 0) then
        value := value-200;

     value := value + 100*Charcount(S,'C');
      if Pos('D',S) > 0 then
        value := value + 500;
      value := value + 1000*Charcount(S, 'M');
      while s[psfound] in ['M','D', 'C', ' '] do
            inc(psfound);
      s := copy(s,psfound,length(s)-psfound+1);
      psfound := 1;
      if (Pos('XL',S) > 0) or (Pos('XC',S) > 0) then
        value := value-20;

      value := value + 10*Charcount(S,'X');
      if Pos('L',S) > 0 then
        value := value + 50;
      while s[psfound] in ['L', 'X', ' ','C'] do
            inc(psfound);
      s := copy(s,psfound,length(s)-psfound+1);

     if Pos('IV',S) > 0 then
        value := value - 2;
     if Pos('IX',S) > 0 then
        value := value - 2;
     value := value+CharCount(S,'I');
     if Pos('V',S) > 0 then
        value := value + 5;


      result := IntToStr(Value);
end;

function Instr(str:string;substr:string):integer;
Begin
     Instr:=pos(substr,str);
end;

function LeftStr(instring:string;index:integer):String;
Begin
    LeftStr:=copy(instring,1,index);
end;

function RightStr(instring:string;numchars:byte):String;
Var
   index:byte;
Begin
     If numchars>=Length(instring)then
        RightStr:=instring
     else
         Begin
              index:=Length(instring)-numchars+1;
              RightStr:=Copy(instring,index,numchars)
         end
end;

function MidStrToEnd(instring:string;index:integer):string;
Begin
   MidStrToEnd:=copy(instring,index,Length(instring)-index+2);
end;

function ReplaceStr(str,old,new:string):string;
Var
   pos:integer;
   first,last:string[255];
Begin
   pos:=Instr(str,old);
   if (pos > 0) then begin
     first:=Leftstr(str,Instr(str,old)-1);
     last:=copy(str,pos+Length(old),Length(str)-pos);
     ReplaceStr:=first+new+ReplaceStr(last,old,new);
   end else
     ReplaceStr := str;
end;

function StringStripAll(instring,charac:string):string;
Var
   done:Boolean;
   posit:integer;
Begin
   Repeat
         posit:=Instr(instring,charac);
         If posit>0 then
            Begin
               done:=False;
               delete(instring,posit,1);
            end
         else
            done:=True;
         {endif}
   Until done;
   StringStripAll:=instring;
end;

function StringStripLeading(instring,charac:string):string;
Begin
while LeftStr(instring,1) = LeftStr(charac,1) do
  instring:= midstrtoend(instring,2);
result:=instring;
end;

function Capitalize(instring : String) : String;
var outstring, tempString : string;
begin
   if Length(instring) > 0 then begin
     outstring := StringStripLeading(LowerCase(instring),' ');
     TempString := Copy(UpperCase(outstring),1,1);
     outstring[1] := TempString[1];
   end else
       outstring := '';

     result   := outstring;
end;


function GetWinDir : String;
var WindowString  : String;
begin
  SetLength(WindowString,250+1);
  SetLength(WindowString,GetWindowsDirectory(PChar(WindowString),MAX_PATH));
  result := WindowString;
end;

function StringStripTrailing(instring,charac:string):string;
Begin
while RightStr(instring,1) = LeftStr(charac,1) do
  instring:=LeftStr(instring,Length(instring) - 1);
result:=instring;
end;

procedure PlayWav(SoundFileName : String);


begin

    PlaySound(PChar(SoundFileName),0,SND_ASYNC or SND_FILENAME);
end;
end.
