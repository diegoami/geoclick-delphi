(******************************************************************)
(* Copyright 1997, Microchip Systems / Carl Bunton                *)
(* Email: Twojags@cris.com                                        *)
(* Web-page: http://www.concentric.net/~twojags                   *)
(*                                                                *)
(* This program was written in Delphi 2 because version 2         *)
(* compiles a much smaller executable using the windows api.  It  *)
(* should be fully compatible with Delphi 3, but will produce a   *)
(* noticable increase of size in the final compiled program.      *)
(*                                                                *)
(*MODIFIED by M. Stephany mirbir.st@t-online.de  12/28/97-08/25/98*)
(*                                                                *)
(******************************************************************)
UNIT SFXmisc;

INTERFACE

USES Messages, Windows;

CONST
  (* Dialog Control-IDs *)
  //## here some controls are removed
  CM_YES        = 1;
  CM_NO         = 2;
  CM_NOASK      = 401;
  CM_OK         = 1;
  CM_CANCEL     = 2;
  CM_EDIT1      = 101;
  CM_LIST       = 301;
  CM_OVERWRITE  = 501;
  CM_SKIP       = 502;
  CM_CONFIRM    = 503;
  CM_STATUS     = 601;
  CM_ABOUT      = 103;        // when the "about delzipsfx" button is pressed... in the main dialog

CONST
  fsMaxPath     = 256;
  fsMaxPassword = 80;

VAR
  Index         : LONGINT;
  HasStoredPaths: Boolean;
  ExtPath       : ARRAY[0..fsMaxPath-1] OF CHAR;
  Password      : ARRAY[0..fsMaxPassword-1] OF CHAR;
  PW            : STRING;
  PWLen         : LONGINT {BYTE};
  FilePos       : DWORD;
  StartOfFile   : DWORD;
  //startofstored : dword;
  OverWriteMode : BYTE;
  OverWriteFile : BOOLEAN;
  CurrentFile   : STRING;
  MainWin       : hWnd;
  processresult : boolean; //## added to get the result of a proccessarchive in sfxgbls.pas


 procedure FileSetDate ( Handle : Integer ; Age : Integer);
//## this has been added 03/15/98 to set the correct file time of  the extracted files (in sfxgbls.pas, line ~300
//## thanks to angus johnson, ajohnson@rpi.net.au

PROCEDURE Unstore;  {(FileLen: LONGINT);}
PROCEDURE CenterDialog(Wnd : hWnd);
PROCEDURE ForceDirectories(Dir: STRING);
Function  FSeek( Offset: LongInt; MoveMethod: WORD ): Integer;
Procedure Crc32_Buf( str: pChar; len: Integer; Var crc: DWORD );
FUNCTION  IsSelected (hWndList: hWnd; Filename: pchar): boolean;
FUNCTION  ExtractFileName(FileName: STRING): STRING;
FUNCTION  PCharToStr(p: PCHAR; Len: WORD): STRING;
FUNCTION  Min(CONST I1, I2: LONGINT): LONGINT;
FUNCTION  StrLen(Str: PCHAR): WORD;
FUNCTION  AppendDirTail(sDir: PCHAR) : PCHAR;
FUNCTION  RemoveDirTail(sDir: PCHAR) : PCHAR;
FUNCTION  FileExists(Filename: PCHAR): BOOLEAN;
FUNCTION  ExtractFilePath(Filename: STRING): STRING;
FUNCTION  StrToInt(CONST S: STRING): LONGINT;
//PROCEDURE ProcessMessages;

IMPLEMENTATION

USES SFXgbls;

(* to set the correct file date an time on extraction *)
procedure FileSetDate ( Handle : Integer ; Age : Integer);
var
  LocalFileTime, FileTime: TFileTime;
begin
    DosDateTimeToFileTime(Age shr 16, Age and $FFFF, LocalFileTime);
    LocalFileTimeToFileTime(LocalFileTime, FileTime);
    SetFileTime(Handle, nil, nil, @FileTime);
end;

(*--------------------------------------------------------------------------*)
(*     CenterDialog --- Center dialog on screen.                            *)
(*--------------------------------------------------------------------------*)
PROCEDURE CenterDialog(Wnd : hWnd);
VAR
   R : TRect;
BEGIN (* CenterDialog *)
   GetWindowRect(Wnd , R);
   R.Left := (GetSystemMetrics(sm_CXScreen) - R.right  + R.left) DIV 2;
   R.Top  := (GetSystemMetrics(sm_CYScreen) - R.bottom + R.top) DIV 2;
   SetWindowPos(Wnd, 0, R.left, R.top, 0, 0, Swp_NoSize OR Swp_NoZOrder);
END   (* CenterDialog *);

(*--------------------------------------------------------------------------*)
FUNCTION  StrToInt(CONST S: STRING): LONGINT;
VAR
   E: Integer;
BEGIN
   Val(S, Result, E);
END;

(*--------------------------------------------------------------------------*)
Procedure Crc32_Buf( str: pChar; len: Integer; Var crc: DWORD );
Begin
   While len > 0 Do
   Begin
      crc := UpdC32( Byte( str^ ), crc );
      Inc( str );
      Dec( len );
   End;
End;

(*--------------------------------------------------------------------------*)
FUNCTION  Min(CONST I1, I2: LONGINT): LONGINT;
BEGIN
   IF I2 < I1 THEN
      Min := I2
   ELSE
      Min := I1;
END;

(*--------------------------------------------------------------------------*)
FUNCTION  IsSelected (hWndList: hWnd; Filename: pchar): boolean;
BEGIN
   Index := SendMessage(hWndList, LB_FINDSTRINGEXACT, Index, LONGINT(Filename));
   RESULT := SendMessage(hWndList, LB_GETSEL, Index, 0) > 0;
END (* IsSelected *);

(*--------------------------------------------------------------------------*)
PROCEDURE Unstore;  {(FileLen: LONGINT);}
VAR
  i:         Integer;
  NumBytes:  DWORD;
  OutBuf:   pChar;
BEGIN
  GetMem(OutBuf, Min(Bytes_To_Go, WSIZE) + 2);
  TRY
     WHILE Bytes_To_Go > 0 DO
     BEGIN
        ReadFile(InFile, OutBuf^, Min(Bytes_To_Go, WSIZE), NumBytes, NIL);
        dec(Bytes_To_Go, NumBytes);
        IF (Header.BitFlag AND 1) = 1 THEN
           FOR i := 0 TO NumBytes - 1 DO
           BEGIN
              OutBuf[i] := char(byte(OutBuf[i]) XOR decrypt_byte);
              {update_keys}UDK(byte(OutBuf[i]));
           END;
        WriteFile(OutFile, OutBuf^, NumBytes, NumBytes, NIL);
        Crc32_Buf(outbuf, NumBytes, Crc32Val);
     END;
  FINALLY
     Dispose(OutBuf);
  END;
END (* Unstore *);

(*--------------------------------------------------------------------------*)
FUNCTION  StrLen(Str: PCHAR): WORD;
VAR
   i: WORD;
BEGIN
   i := 0;
   WHILE Str[i] <> #0 DO
      inc(i);
   RESULT := i;
END;

(*--------------------------------------------------------------------------*)
Function FSeek( Offset: LongInt; MoveMethod: WORD ): Integer;
Begin
   FSeek   := 0;
   FilePos := SetFilePointer( InFile, Offset, nil, MoveMethod );

   If (FilePos = $FFFFFFFF) And (GetLastError <> NO_ERROR) Then
      FSeek := -1;
End;

(*--------------------------------------------------------------------------*)
FUNCTION  ExtractFilePath(Filename: STRING): STRING;
VAR
  i: Integer;
BEGIN
  (* Handle archive relative paths *)
  i := Length(Filename);
  IF (i = 3) AND (Pos(':', Filename) > 0) THEN
     RESULT := Filename
  ELSE
  BEGIN
     WHILE (i > 0) AND NOT (Filename[ i ] IN ['\', '/', ':']) DO
        Dec(i);

     IF (Filename[ i ] = '\') OR (Filename[ i ] = '/') THEN
        IF i <> 3 THEN
           dec(i)
        ELSE
           IF Filename[ 2 ] <> ':' THEN
              dec(i);
     RESULT := Copy(Filename, 1, i);
  END;
END;

(*--------------------------------------------------------------------------*)
FUNCTION  ExtractFileName(FileName: STRING): STRING;
VAR
  I: Integer;
BEGIN
  (* Handle archive relative paths *)
  I := Length(FileName);
  WHILE (I > 0) AND NOT (FileName[I] IN ['\', '/', ':'])
     DO Dec(I);
  Result := Copy(FileName, I + 1, 255);
END;

(*--------------------------------------------------------------------------*)
FUNCTION  FixDirChar(s: PCHAR): PCHAR;
VAR
   i: BYTE;
BEGIN
   FOR i := 0 TO StrLen(s) DO
      IF s[i] = '/' THEN
         s[i] := '\';
   RESULT := s;
END;

(*--------------------------------------------------------------------------*)
FUNCTION  FileExists(Filename: PCHAR): BOOLEAN; //## this func has changed a bit
VAR
   SearchRec:  TWin32FindData;
   i, isav:    Integer;
   aHandle:    THandle;
   FN:        pChar;
BEGIN
   IF Filename[ StrLen(Filename) - 1 ] = '\' THEN
   BEGIN
      GETMEM(FN, 255);
      isav:=0;
      FOR i := 0 TO StrLen(Filename) - 1 DO
      begin
         isav:=i;
         FN[ i ] := Filename[ i ];
      end;
      i:=isav+1; //## here we should not use the resulting i, cause in d3 after a for, the value of the loop-var isn't always defined
      FN[ i  ] := '*';
      FN[ i + 1 ] := '.';
      FN[ i + 2 ] := '*';
      FN[ i + 3 ] := #0;

      TRY
         aHandle := FindFirstFile(FixDirChar(FN), SearchRec)
      FINALLY
         DISPOSE(FN);
      END;
   END
   ELSE
      aHandle := FindFirstFile(FixDirChar(Filename), SearchRec);

   FindClose( aHandle );
   RESULT :=  aHandle <> INVALID_HANDLE_VALUE;
END;

(*--------------------------------------------------------------------------*)
(* Set the contents of a STRING *)
FUNCTION  PCharToStr(p: PCHAR; Len: WORD): STRING;
VAR
   s: STRING;
BEGIN
  SetLength(s, Len);
  Move(p^, s[1], Len);
  IF POS(#0, s) > 0 THEN
    SetLength(s, POS(#0, s) - 1);
  RESULT := s;
END (* SetString *);

(*--------------------------------------------------------------------------*)
PROCEDURE ForceDirectories(Dir: STRING);
BEGIN
  IF Dir[ Length(Dir) ] = '\' THEN
     SetLength(Dir, Length(Dir) - 1);
  IF (Length(Dir) < 3) OR FileExists(PCHAR(Dir)) THEN
     EXIT;
  ForceDirectories(ExtractFilePath(Dir));
  MkDir(Dir);
END;

(*--------------------------------------------------------------------------*)
FUNCTION  AppendDirTail(sDir: PCHAR) : PCHAR;
VAR
   i: WORD;
BEGIN
   i := StrLen(sDir);
   IF sDir[ i - 1 ] <> '\' THEN
   BEGIN
      sDir[ i ] := '\';
      sDir[ i + 1 ] := #0;
   END;
   RESULT := sDir;
END;

(*--------------------------------------------------------------------------*)
FUNCTION  RemoveDirTail(sDir: PCHAR) : PCHAR;
VAR
   i: WORD;
BEGIN
   i := StrLen(sDir);

   IF sDir[ i - 1 ] = '\' THEN
      sDir[ i - 1 ] := #0;
   RESULT := sDir;
END;

//## we don't need the loadstr since we calculate the startoffile different.
(*--------------------------------------------------------------------------*)
(*FUNCTION  LoadStr(Ident: Word): STRING;
BEGIN
   //Result[0] := Char(LoadString(HInstance, Ident, @Result[1], 254));
   RESULT := Char(LoadString(HInstance, Ident, @Result[1], 254));
END;

(*--------------------------------------------------------------------------*)

{PROCEDURE ProcessMessages;
VAR
   Msg : TMsg;
BEGIN
   WHILE PeekMessage(Msg, 0, 0, 0, PM_REMOVE) DO
   BEGIN
      IF Msg.Message <> WM_QUIT THEN
      BEGIN
         TranslateMessage(Msg);
         DispatchMessage(Msg);
      END;
   END;
END; }

(*--------------------------------------------------------------------------*)

END.
