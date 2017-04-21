///////////////////////////////////////////////////////////////////////////////
//////////////////////////THyperImages Component V.2///////////////////////////
///////////////////Copyright © 1998-1999 Noatak Racing Team////////////////////
///////////////////////////////////////////////////////////////////////////////

unit Experts;
{$INCLUDE HyperIm.inc}

interface
{$ifdef USEEXPERTS}

uses
  Forms, Windows, Classes, SysUtils, dialogs;

const
  DefaultBufferSize = 8192;

const
  ttNull = #0;             { special token types }
  ttIdentifier = #1;
  ttString = #2;
  ttInteger = #3;
  ttFloat = #4;
  ttLE = #5;               { <= }
  ttGE = #6;               { >= }
  ttNE = #7;               { <> }
  ttDotDot = #8;           { .. }
  ttAssign = #9;           { := }

type
  TTokenType = Char;
  TPascalScanner = class(TComponent)
  private
    fBuffer: PChar;       { input buffer }
    fBufPtr: PChar;       { current buffer read position }
    fBufEnd: PChar;       { end of buffer }
    fBufSize: Cardinal;
    fStream: TStream;
    fToken: string;
    fTokenType: TTokenType;
    fNewLine: Boolean;    { at start of a new line? }
    fPosition: LongInt;   { position of start of token }
    fOnEndOfStream: TNotifyEvent;
    fOnFillBuffer: TNotifyEvent;
    fOnToken: TNotifyEvent;
    procedure SetBufSize(Value: Cardinal);
  protected
    procedure FillBuffer;
    function GetChar(var Ch: Char): Boolean;
    property Stream: TStream read fStream;
    function NextToken: Boolean;
    procedure DoToken; virtual;
    procedure DoEndOfStream; virtual;
    procedure GetNumber(FirstChar: Char);
    procedure CheckSymbol(Ch1: Char);
    procedure GetIdentifier(FirstChar: Char);
    procedure GetString(Delim: Char);
    function SkipWhiteSpace(var Ch: Char): Boolean;
    procedure SkipComment(CommentType: Char);
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure Scan(Stream: TStream);
    function IsIdentifier(Check: string): Boolean;

    property Position: LongInt read fPosition;
    property NewLine: Boolean read fNewLine;
    property Token: string read fToken;
    property TokenType: TTokenType read fTokenType;
  published
    property BufferSize: Cardinal read fBufSize write SetBufSize default DefaultBufferSize;
    property OnEndOfStream: TNotifyEvent read fOnEndOfStream write fOnEndOfStream;
    property OnFillBuffer: TNotifyEvent read fOnFillBuffer write fOnFillBuffer;
    property OnToken: TNotifyEvent read fOnToken write fOnToken;
  end;

{ List class that owns its items. }
type
  TOwnerList = class
  private
    fList: TList;
    function GetItem(Index: Integer): TObject;
    procedure SetItem(Index: Integer; Item: TObject);
    function GetCount: Integer;
  protected
    property Items[Index: Integer]: TObject read GetItem write SetItem;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(Item: TObject): Integer; virtual;
    procedure Clear; virtual;
    procedure Delete(Index: Integer); virtual;
    function IndexOf(Item: TObject): Integer; virtual;
    function Remove(Item: TObject): Integer;
    property Count: Integer read GetCount;
  end;

var
  Scanner: TPascalScanner;
  InTypeDec, InClassDec, InTheClassDec: Boolean;
  MethodDeclarationPos, MethodImplementationPos: LongInt;
  TheClass: String;



procedure RunExpert(AComponentName, AEventName: String);
procedure Register;
{$endif}

implementation
{$ifdef USEEXPERTS}
uses
  ExptIntf, ToolIntf, Proxies, EditIntf, HSEdit;

type  
THyperImagesHelpExpert = class(TIExpert)
  public
    function GetIDString: String; override;
    function GetStyle: TExpertStyle; override;
    function GetState: TExpertState; override;
    function GetMenuText: String; override;
    function GetName: String; override;
    procedure Execute; override;
    function GetGlyph: HICON;  override;
    function GetAuthor: string;  override;
    function GetPage: string;
  end;

THyperImagesCodeExpert = class(TIExpert)
  public
    procedure Execute; override;
    function GetAuthor: string; override;
    function GetComment: string; override;
    function GetGlyph: HICON; override;
    function GetIDString: string; override;
    function GetMenuText: string; override;
    function GetName: string; override;
    function GetPage: string; override;
    function GetState: TExpertState; override;
    function GetStyle: TExpertStyle; override;
  end;

TEditReaderStream = class(TStream)
  private
    fSize: LongInt;
    fPosition: LongInt;
    fReader: TIEditReader;
    function GetSize: LongInt;
  public
    constructor Create(EditIntf: TIEditorInterface);
    destructor Destroy; override;
    function Read(var Buffer; Count: LongInt): LongInt; override;
    function Seek(Offset: LongInt; Origin: Word): LongInt;
        override;
    function Write(const Buffer; Count: LongInt): LongInt; override;
    property Size: LongInt read GetSize;
  end;  

TEditorStrings = class(TStrings)
  private
    fStrings: TStrings;
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const Str: string); override;
    procedure PutObject(Index: Integer; Obj: TObject); override;
    function GetPosition(Index: Integer): LongInt; virtual;
    function GetCharPos(Index: Integer): TCharPos; virtual;
    property Strings: TStrings read fStrings;
  public
    constructor Create(Editor: TIEditorInterface);
    destructor Destroy; override;
    procedure LoadFromEditor(Editor: TIEditorInterface);
    procedure SaveToEditor(Editor: TIEditorInterface);
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const Str: string); override;
    function PosToCharPos(Pos: LongInt): TCharPos;
    function CharPosToPos(CharPos: TCharPos): LongInt;
    property Position[Index: Integer]: LongInt read GetPosition;
    property CharPos[Index: Integer]: TCharPos read GetCharPos;
  end;


////////////////////////////Scanner//////////////////////////////

constructor TPascalScanner.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  fBufSize := DefaultBufferSize;
end;

{ Free the buffer, just in case something went wrong. }
destructor TPascalScanner.Destroy;
begin
  FreeMem(fBuffer);
  inherited Destroy;
end;

{ The caller can change the buffer size only when the
  scanner has no buffer. In other words while parsing a
  stream, the buffer size is fixed. }
procedure TPascalScanner.SetBufSize(Value: Cardinal);
begin
  if fBuffer = nil then
    fBufSize := Value
end;

{ Read another buffer from the stream. }
procedure TPascalScanner.FillBuffer;
begin
  fBufEnd := fBuffer + Stream.Read(fBuffer^, BufferSize);
  fBufPtr := fBuffer;
  if Assigned(fOnFillBuffer) then
    fOnFillBuffer(Self);
end;

{ Read one character; return True for success, False
  for end of file. }
function TPascalScanner.GetChar(var Ch: Char): Boolean;
begin
  if fBufPtr >= fBufEnd then
    FillBuffer;
  if fBufPtr >= fBufEnd then
    Result := False
  else
  begin
    Ch := fBufPtr^;
    Inc(fBufPtr);
    Result := True;
  end;
end;

{ Skip over a comment. The CommentType argument specifies
  the comment style:
    '{': curly braces
    '*': up to '*)'
    '/': C++ style on a single line
}
procedure TPascalScanner.SkipComment(CommentType: Char);
var
  Ch: Char;
begin
  case CommentType of
  '{':
    while GetChar(ch) and (Ch <> '}') do
      ;
  '/':
    begin
      while GetChar(Ch) and not (Ch in [#10, #13]) do
        ;
      { Let the main reading routine find the newline }
      Dec(fBufptr);
    end;
  '*':
    begin
      while GetChar(Ch) do
        if Ch = '*' then
        begin
          if not GetChar(Ch) then
            Exit
          else if Ch = ')' then
            Exit
          else
            Dec(fBufPtr);
        end;
    end;
  else
    raise Exception.CreateFmt('Cannot happen, CommentType=%s', [CommentType]);
  end;
end;

{ Skip over white space and comments. }
function TPascalScanner.SkipWhiteSpace(var Ch: Char): Boolean;
var
  Ch2: Char;
begin
  Result := False;

  if not GetChar(ch) then
    Exit;

  while True do
  begin
    case Ch of
    #10, #13:
      fNewLine := True;
    #0..#9, #11, #12, #14..' ':
      ; { skip the control or space character }
    '{':
      SkipComment(Ch);
    '(':
      begin
        { Look for '(*' style comment }
        if not GetChar(Ch2) then
          Exit;
        if Ch2 = '*' then
          SkipComment(Ch2)
        else
        begin
          { Nope, put back the char }
          Dec(fBufPtr);
          Break;
        end;
      end;
    '/':
      begin
        { Look for // style comment }
        if not GetChar(Ch2) then
          Exit;
        if Ch2 = '/' then
          SkipComment(Ch2)
        else
        begin
          { Nope, put back the char }
          Dec(fBufPtr);
          Break;
        end;
      end;
    else
      { Not a white space or comment character }
      Break;
    end;
    if not GetChar(Ch) then
      Exit;
  end;
  Result := True;
end;

{ Read a string token. }
procedure TPascalScanner.GetString(Delim: Char);
var
  Ch, Ch2: Char;
begin
  fTokenType := ttString;
  while GetChar(Ch) do
  begin
    fToken := fToken + Ch;
    if Ch in [#10, #13] then
    begin
      { unterminated string }
      Dec(fBufPtr);
      Exit;
    end;
    if Ch = Delim then
    begin
      { Check for double string delimiter }
      if not GetChar(Ch2) then
        Exit;
      if Ch2 <> Delim then
      begin
        { Nope, read one character too many. }
        Dec(fBufPtr);
        { Strip the string delimiter. }
        Delete(fToken, Length(fToken)-1, 1);
        Break;
      end;
    end;
  end;
end;

{ Read an alphanumeric identifier or keyword. }
procedure TPascalScanner.GetIdentifier(FirstChar: Char);
var
  Ch: Char;
begin
  fToken := FirstChar;
  fTokenType := ttIdentifier;
  while GetChar(Ch) do
  begin
    if not (Ch in ['a'..'z', 'A'..'Z', '0'..'9', '_', '.']) then
    begin
      { push back the character that ends the token }
      Dec(fBufPtr);
      Break;
    end;
    fToken := fToken + Ch;
  end;
end;

{ Check for a double-character symbol. }
type
  TDoubleChar = record
    C1, C2: Char;
    TT: TTokenType;
  end;
const
  DoubleChars: array[1..7] of TDoubleChar =
  (
    (C1: ':'; C2: '='; TT: ttAssign),
    (C1: '<'; C2: '='; TT: ttLE),
    (C1: '<'; C2: '>'; TT: ttNE),
    (C1: '>'; C2: '='; TT: ttGE),
    (C1: '('; C2: '.'; TT: '['),
    (C1: '.'; C2: ')'; TT: ']'),
    (C1: '.'; C2: '.'; TT: ttDotDot)
  );

procedure TPascalScanner.CheckSymbol(Ch1: Char);
var
  Ch2: Char;
  I: Integer;
begin
  if not GetChar(Ch2) then
    Exit;
  for I := Low(DoubleChars) to High(DoubleChars) do
    with DoubleChars[I] do
     if (C1 = Ch1) and (C2 = Ch2) then
     begin
       fTokenType := TT;
       fToken := Ch1 + Ch2;
       Exit;
     end;
  fToken := Ch1;
  fTokenType := Ch1;
  Dec(fBufPtr);  { put back Ch2 }
end;

{ Read a number (integer or floating point). }
procedure TPascalScanner.GetNumber(FirstChar: Char);
var
  Ch: Char;
begin
  fToken := FirstChar;
  fTokenType := ttInteger;
  { Read an initial digit string. }
  while GetChar(Ch) and (Ch in ['0'..'9']) do
    fToken := fToken + Ch;

  if Ch = '.' then
  begin
    { Look for an optional fraction.}
    fTokenType := ttFloat;
    fToken := fToken + Ch;
    while GetChar(Ch) and (Ch in ['0'..'9']) do
      fToken := fToken + Ch;
  end;
  if Ch in ['e', 'E'] then
  begin
    { Look for an optional exponent. }
    fTokenType := ttFloat;
    fToken := fToken + Ch;
    if GetChar(Ch) and (Ch in ['+', '-']) then
      fToken := fToken + Ch;
    while Ch in ['0'..'9'] do
    begin
      fToken := fToken + Ch;
      if not GetChar(Ch) then
        Break;
    end;
  end;
end;

{ Read the next token and return True for success,
  or False for end of file. }
function TPascalScanner.NextToken: Boolean;
var
  Ch: Char;
begin
  fNewLine := False;
  Result := False;

  { Skip white space. }
  if not SkipWhiteSpace(Ch) then
    Exit;

  { Account for buffer position }
  fPosition := Stream.Position - (fBufEnd-fBufPtr) - 1;
  
  case Ch of
  '''', '"':
    GetString(Ch);
  'a'..'z', 'A'..'Z', '_':
    GetIdentifier(Ch);
  '0'..'9':
    GetNumber(Ch);
  '.', ':', '<', '>', '(':
    CheckSymbol(Ch);
  else
    begin
      { Single character symbol }
      fToken := Ch;
      fTokenType := Ch;
    end;
  end;
  Result := True;
end;

{ Compare the current token with Check. Return True if
  they are the same. Case is not significant. }
function TPascalScanner.IsIdentifier(Check: string): Boolean;
begin
  Result := (TokenType = ttIdentifier) and (CompareText(Token, Check) = 0)
end;

{ Call DoToken for each token. Let derived classes override
  this function do something different. }
procedure TPascalScanner.DoToken;
begin
  if Assigned(fOnToken) then
    fOnToken(Self);
end;

procedure TPascalScanner.DoEndOfStream;
begin
  if Assigned(fOnEndOfStream) then
    fOnEndOfStream(Self);
end;

{ Scan the entire stream, calling the OkToken callback
  for each token. Call OnEndOfStream at the end. }
procedure TPascalScanner.Scan(Stream: TStream);
var
  TmpBuf: PChar;
begin
  fStream := Stream;
  try
    GetMem(fBuffer, BufferSize);
    try
      fNewLine := True;
      fPosition := Stream.Position;
      fToken := '';
      FillBuffer;
      while NextToken do
        DoToken;
      DoEndOfStream;
    finally
      TmpBuf := fBuffer; { Make sure fBuffer never points to invalid memory. }
      fBuffer := nil;
      FreeMem(TmpBuf);
    end;
  finally
    fStream := nil;
  end;
end;
////////////////////////////TOwnerList//////////////////////////////

constructor TOwnerList.Create;
begin
  inherited Create;
  fList := TList.Create;
end;

destructor TOwnerList.Destroy;
begin
  if fList <> nil then
    Clear;
  fList.Free;
  inherited Destroy;
end;

function TOwnerList.GetItem(Index: Integer): TObject;
begin
  Result := fList[Index]
end;

procedure TOwnerList.SetItem(Index: Integer; Item: TObject);
var
  OldItem: TObject;
begin
  OldItem := fList[Index];
  if OldItem <> Item then
  begin
    fList[Index] := nil;
    OldItem.Free;
  end;
  fList[Index] := Item;
end;

function TOwnerList.GetCount: Integer;
begin
  Result := fList.Count
end;

function TOwnerList.Add(Item: TObject): Integer;
begin
  Result := fList.Add(Item)
end;

{ Delete items starting at the end of the list because that is
  much faster than starting at the beginning of the list. }
procedure TOwnerList.Clear;
var
  I: Integer;
begin
  for I := fList.Count-1 downto 0 do
    Delete(I);
end;

procedure TOwnerList.Delete(Index: Integer);
var
  Item: TObject;
begin
  Item := fList[Index];
  fList.Delete(Index);
  Item.Free;
end;

function TOwnerList.IndexOf(Item: TObject): Integer;
begin
  Result := fList.IndexOf(Item);
end;

function TOwnerList.Remove(Item: TObject): Integer;
begin
  Result := IndexOf(Item);
  if Result >= 0 then
    Delete(Result);
end;

////////////////////////////Help Expert//////////////////////////////

function THyperImagesHelpExpert.GetPage: string;
begin
  Result := ''
end;

function THyperImagesHelpExpert.GetGlyph: HICON;
begin
  Result := 0;
end;

function THyperImagesHelpExpert.GetAuthor: string;
begin
  Result := 'Jacques PHILIP; Noatak Racing Team';
end;

function THyperImagesHelpExpert.GetIDString: String;
begin
  Result := 'HyperImagesHelpExpert';
end;

function THyperImagesHelpExpert.GetStyle: TExpertStyle;
begin
  Result := esStandard;
end;

function THyperImagesHelpExpert.GetState: TExpertState;
begin
  Result := [esEnabled];
end;

function THyperImagesHelpExpert.GetMenuText: String;
begin
  Result := 'THyperImages Help';
end;

function THyperImagesHelpExpert.GetName: String;
begin
  Result := 'THyperImages Help Expert';
end;

procedure THyperImagesHelpExpert.Execute;
var
  OldHelpFile: String;
begin
  if not Assigned(ToolServices) then Exit;
  try
    OldHelpFile := Application.HelpFile;
    Application.HelpFile := 'HyperImages.hlp';
    Application.HelpJump('Contents');
  finally
     WinHelp (Application.Handle, 'HyperImages.Hlp', HELP_CONTENTS, 0);
  end;
end;


/////////////////////////////// ///////////////////////////////////////////
/////////////////////////////TEditReaderStream/////////////////////////////
////////////////////////////// ///////////////////////////////////////////

{ Construct the stream from an editor interface. }
constructor TEditReaderStream.Create(EditIntf: TIEditorInterface);
begin
  inherited Create;
  fReader := EditIntf.CreateReader;
  fSize := -1; { size is unknown }
end;

{ Destroy the stream and free all the interfaces that the stream
  created. }
destructor TEditReaderStream.Destroy;
begin
  fReader.Free;
  inherited Destroy;
end;
{ Read from the file stream or the editor. }
function TEditReaderStream.Read(var Buffer; Count: LongInt): LongInt;
const
  MaxCount = 31*1024;
var
  NRead: Integer;
  NRequest: Integer;
  BufPtr: PChar;
begin
  { The initial release of D3 does not handle calls to GetText
    where Count >= 32K. It returns a result equal to Count
    without actually retrieving any text. To circumvent this
    problem, grab buffers of 31K at a time. }
  Result := 0;
  BufPtr := @Buffer;
  while Count > 0 do
  begin
    if Count > MaxCount then
      NRequest := MaxCount
    else
      NRequest := Count;
    NRead := fReader.GetText(fPosition, BufPtr, NRequest);
    Inc(fPosition, NRead);
    Inc(BufPtr, NRead);
    Inc(Result, NRead);
    Dec(Count, NRead);
    { Partially completed read means end-of-buffer, so remember
      the buffer size. If NRead = 0, the position might be past
      the end of file, so save the size only when NRead > 0. }
    if (fSize < 0) and (NRead > 0) and (NRead < NRequest) then
      fSize := fPosition;
  end;
end;

{ Seek to a new position. }
function TEditReaderStream.Seek(Offset: LongInt; Origin: Word):
  LongInt;
begin
  case Origin of
  soFromBeginning:    fPosition := Offset;
  soFromCurrent:      fPosition := fPosition + Offset;
  soFromEnd:          fPosition := Size + Offset;
  else
    raise Exception.CreateFmt('Invalid seek origin, %d', [Origin]);
  end;
  Result := fPosition;
end;

function TEditReaderStream.Write(const Buffer; Count: LongInt):
  LongInt;
begin
  raise Exception.Create('Attempt to write to readonly stream!');
end;
{ If the stream user must seek relative to the end of the
  stream, then you need to know the size of the stream.
  There is no simple way to determine this. Instead, use
  a binary search to find a position where a single byte
  read is valid, and a read of the subsequent byte is invalid.
  Since this is such a pain, cache the size after the first call,
  and return the cached size for subsequent calls. }
function TEditReaderStream.GetSize: LongInt;
var
  Hi, Lo, Mid: LongInt;
  Ch: Char;
begin
  if fSize < 0 then
  begin
    Hi := High(LongInt);
    Lo := 0;
    while Lo <= Hi do
    begin
      Mid := (Hi + Lo) div 2;
      if fReader.GetText(Mid, @Ch, 1) = 1 then
        Lo := Mid+1
      else
        Hi := Mid-1;
    end;
    fSize := Lo;
  end;
  Result := fSize;
end;

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////TEditorStrings///////////////////////////////
//////////////////////////////////////////////////////////////////////////////

{ Create an edit reader string list. }
constructor TEditorStrings.Create(Editor: TIEditorInterface);
begin
  inherited Create;
  fStrings := TStringList.Create;
  LoadFromEditor(Editor);
end;

destructor TEditorStrings.Destroy;
begin
  Strings.Free;
  inherited Destroy;
end;

{ Load a string list from an editor interface. Read the edit
  reader as a stream. As each line is added to the string list,
  remember the position of that line in the stream. }
procedure TEditorStrings.LoadFromEditor(Editor: TIEditorInterface);
var
  ERStream: TEditReaderStream;
  StrStream: TStringStream;
  Str: PChar;
  Pos, I: Integer;
begin
  ERStream := TEditReaderStream.Create(Editor);
  try
    StrStream := TStringStream.Create('');
    try
      { Read the entire buffer into StrStream. }
      StrStream.CopyFrom(ERStream, 0);
      { Copy every line from StrStream to the string list. }
      Strings.Text := StrStream.DataString;

      { Scan the string to find the buffer position of each line. }
      Str := PChar(StrStream.DataString);
      Pos := 0;
      for I := 0 to Count-1 do
      begin
        Strings.Objects[I] := TObject(Pos);
        Inc(Pos, Length(Strings[I]));
        if Str[Pos] = #13 then
          Inc(Pos);
        if Str[Pos] = #10 then
          Inc(Pos);
      end;
    finally
      StrStream.Free;
    end;
  finally
    ERStream.Free;
  end;
end;

{ Save the string list to an editor interface. The string list
  does not keep track of specific changes, so replace the entire
  file with the text of the string list. }
procedure TEditorStrings.SaveToEditor(Editor: TIEditorInterface);
var
  Writer: TIEditWriter;
begin
  Writer := Editor.CreateUndoableWriter;
  try
    Writer.DeleteTo(High(LongInt));
    Writer.Insert(PChar(fStrings.Text));
  finally
    Writer.Free;
  end;
end;

{ Get a string. }
function TEditorStrings.Get(Index: Integer): string;
begin
  Result := Strings[Index]
end;

{ Get an object, which is really the string position. }
function TEditorStrings.GetObject(Index: Integer): TObject;
begin
  Result := Strings.Objects[Index]
end;

{ Set a string. }
procedure TEditorStrings.Put(Index: Integer; const Str: string);
begin
  Strings[Index] := Str
end;

{ Set a string's position. }
procedure TEditorStrings.PutObject(Index: Integer; Obj: TObject);
begin
  Objects[Index] := Obj;
end;

{ Return the number of lines in the list. }
function TEditorStrings.GetCount: Integer;
begin
  Result := Strings.Count
end;

procedure TEditorStrings.Clear;
begin
  Strings.Clear;
end;

procedure TEditorStrings.Delete(Index: Integer);
begin
  Strings.Delete(Index)
end;

procedure TEditorStrings.Insert(Index: Integer; const Str: string);
begin
  Strings.Insert(Index, Str);
end;

{ For convenience, return a position as an integer. }
function TEditorStrings.GetPosition(Index: Integer): LongInt;
begin
  Result := LongInt(Strings.Objects[Index]);
end;

{ Return a position as a character position. }
function TEditorStrings.GetCharPos(Index: Integer): TCharPos;
begin
  Result := PosToCharPos(GetPosition(Index));
end;

{ Get the buffer position given a character position.
  The character position position specifies a line of text.
  Retrieve the buffer position for the start of that line,
  and add the character index. If the character index is
  past the end of line, return the position of the line
  ending. }
function TEditorStrings.CharPosToPos(CharPos: TCharPos): LongInt;
var
  Text: string;
begin
  { CharPos.Line is 1-based; Strings list is 0-based. }
  Text := Strings[CharPos.Line-1];
  if CharPos.CharIndex > Length(Text) then
    Result := Position[CharPos.Line-1] + Length(Text)
  else
    Result := Position[CharPos.Line-1] + CharPos.CharIndex;
end;

{ Convert a buffer position to a character position.
  Search for the line such that Pos is between the start
  and end positions of the line. That specifies the line
  number. The char index is the offset within the line.
  If Pos lies within a line ending, return the character
  index of the end of the line.

  Line indices are 1-based, and string list indices are
  0-based, so add 1 to get the true line number.

  Use binary search to locate the desired line quickly. }
function TEditorStrings.PosToCharPos(Pos: LongInt): TCharPos;
var
  Lo, Mid, Hi: Integer;
begin
  Lo := 0;
  Hi := Strings.Count-1;
  while Lo <= Hi do
  begin
    Mid := (Lo + Hi) div 2;
    if Position[Mid] <= Pos then
      Lo := Mid+1
    else
      Hi := Mid-1
  end;

  Result.Line := Lo;
  if Pos >= Position[Lo-1]+Length(Strings[Lo-1]) then
    Result.CharIndex := Length(Strings[Lo-1])
  else
    Result.CharIndex := Pos - Position[Lo-1];
end;

/////////////////////////////////Code Expert///////////////////////////////

function THyperImagesCodeExpert.GetComment: string;
begin
  Result := ''
end;

function THyperImagesCodeExpert.GetPage: string;
begin
  Result := ''
end;

function THyperImagesCodeExpert.GetGlyph: HICON;
begin
  Result := 0;
end;

function THyperImagesCodeExpert.GetAuthor: string;
begin
  Result := 'Jacques PHILIP; Noatak Racing Team';
end;

function THyperImagesCodeExpert.GetIDString: String;
begin
  Result := 'HyperImagesCodeExpert';
end;

function THyperImagesCodeExpert.GetStyle: TExpertStyle;
begin
  Result := esAddIn;
end;

function THyperImagesCodeExpert.GetState: TExpertState;
begin
  Result := [];
end;

function THyperImagesCodeExpert.GetMenuText: String;
begin
  Result := '';
end;

function THyperImagesCodeExpert.GetName: String;
begin
  Result := 'THyperImages Code Expert';
end;

procedure THyperImagesCodeExpert.Execute;
begin
end;

procedure RunExpert(AComponentName, AEventName: String);
var
  ModIntf: TIModuleInterface;
  FormIntf: TIFormInterface;
  CompIntf, FormCompIntf: TIComponentInterface;
  EditIntf: TIEditorInterface;
  TheMethod: TMethod;
  MethodName: String ;
  CompHandle, FormHandle: Pointer;
  EdStrings: TEditorStrings;
  EditReader: TStringStream;
  CodeListing: TStringList;
  View: TIEditView;
  DeclarationInsertLine, ImplementationInsertLine, i: Integer;
  CharPos: TCharPos;
  Editpos: TEditPos;
begin
  if not Assigned(ToolServices) then Exit;
  InTypeDec := False;
  InClassDec := False;
  InTheClassDec := False;
  MethodName := AComponentName + Copy(AEventName, 3, Length(AEventName) - 2);
  with ToolServices do
    ModIntf := GetModuleInterface(ChangeFileExt(GetCurrentFile, '.pas'));
  if ModIntf <> nil then
    try
      //ModIntf.ShowForm; { make sure form is visible }
      FormIntf := ModIntf.GetFormInterface;
      if FormIntf = Nil then
        Abort else
        try
          CompIntf := FormIntf.FindComponent(AComponentName);
          if CompIntf <> Nil then
            try
              FormCompIntf :=FormIntf.GetFormComponent;
              if FormCompIntf <> Nil then
                try
                  TheClass := FormCompIntf.GetComponentType;
                  CompIntf.GetPropValueByName(AEventName, TheMethod);
                  if TheMethod.Code <> Nil then
                    Raise Exception.Create('There is already an event hanler for ' +
                    AEventName + '.');
                  FormHandle := FormCompIntf.GetComponentHandle;
                  TheMethod.Data := FormHandle;
                  TheMethod.Code := CreateSubClassMethod(TForm(TheMethod.Data), MethodName);
                  CompIntf.SetPropByName(AEventName, TheMethod);
                finally
                  FormCompIntf.Free;
                end;
                EditIntf := ModIntf.GetEditorInterface;
                if EditIntf <> Nil then
                  try
                    EdStrings := TEditorStrings.Create(EditIntf);
                      try
                        EdStrings.LoadFromEditor(EditIntf);
                          EditReader := TStringStream.Create(EdStrings.Text);
                          try
                            Scanner := TPascalScanner.Create(Application);
                              try
                                Scanner.OnToken := HSEditForm.ScannerToken;
                                Scanner.Scan(EditReader);
                                DeclarationInsertLine := EdStrings.PosToCharPos
                                (MethodDeclarationPos).Line - 1;
                                ImplementationInsertLine := EdStrings.PosToCharPos
                                (MethodImplementationPos).Line - 1;
                                CharPos := EdStrings.CharPos[ImplementationInsertLine] ;
                                EdStrings.Insert(DeclarationInsertLine,
'    procedure ' + MethodName + '(Sender: TObject;');
                                EdStrings.Insert(DeclarationInsertLine + 1,
'      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);');
                                EdStrings.Insert(ImplementationInsertLine + 2,
'procedure ' + TheClass + '.' + MethodName + '(Sender: TObject;');
                                EdStrings.Insert(ImplementationInsertLine + 3,
'  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);');
                                CodeListing := TStringlist.Create;
                                  try
                                    HSEditForm.GenerateCodeTemplate(CodeListing);
                                    for i := 0 to CodeListing.Count - 1 do
                                      EdStrings.Insert(ImplementationInsertLine + 4 + i,
                                      CodeListing[i]);
                                    EdStrings.Insert(ImplementationInsertLine + 4 + i, '');
                                    MessageDlg('The code template has been created.',
                                    mtInformation, [mbOK], 0);
                                  finally
                                    CodeListing.Free;
                                  end;
                              finally
                                Scanner.Free;
                              end;
                          finally
                            EditReader.Free;
                          end;
                          EdStrings.SaveToEditor(EditIntf);
                      finally
                        EdStrings.Free;
                      end;
                      if EditIntf.GetViewCount = 0 then
                        Abort;
                      View := EditIntf.GetView(0);
                      try
                        View.ConvertPos(False, EditPos, CharPos);
                        if (EditPos.Line + 2 <= EditIntf.LinesInBuffer) then begin
                          Inc(EditPos.Line, 2);
                          EditPos.Col := 1;
                          View.TopPos := EditPos;
                          if (EditPos.Line + 9 <= EditIntf.LinesInBuffer) then begin
                            Inc(EditPos.Line, 9);
                            EditPos.Col := 11;
                            View.CursorPos := Editpos;
                          end;
                        end;
                      finally
                        View.Free;
                      end;
                finally
                  EditIntf.Free;
                end;
            finally
              CompIntf.Free;
            end;
        finally
          FormIntf.Free;
        end;
    finally
      ModIntf.Free;
    end;
end;

procedure Register;
begin
  RegisterLibraryExpert(THyperImagesCodeExpert.Create);
  RegisterLibraryExpert(THyperImagesHelpExpert.Create);
end;
{$endif}
end.
