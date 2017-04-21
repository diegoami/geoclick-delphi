(******************************************************************)
(* Copyright 1997, Microchip Systems / Carl Bunton                *)
(* Email: Twojags@cris.com                                        *)
(* Web-page: http://www.concentric.net/~twojags                   *)
(*                                                                *)
(* This program was written in Delphi 2 because version 2         *)  //## this release in delphi3
(* compiles a much smaller executable using the windows api.  It  *)
(* should be fully compatible with Delphi 3, but will produce a   *)
(* noticable increase of size in the final compiled program.      *)
(*                                                                *)
(*MODIFIED by M. Stephany mirbir.st@t-online.de  12/28/97-01/04/98*)
(* for some special purposes; modified lines are marked (##)      *)
(******************************************************************)

// bug with data_descriptor fixes in function readheader by mst 01/23/98. thanks to eric !
// correct filetime will now be set, thanks to angus johnson, ajohnson@rpi.net.au 15/03/98

// credits to thomas hoelzer (thoelzer@cityweb.de) for correcting an error while extraction of directory names 090198
UNIT SFXgbls;

{$A-}

INTERFACE

USES Messages, Windows;

TYPE
  TLocal = RECORD
     SignAtr        : LONGINT;
     VerNum         : WORD;  (* VersionMadeBy *)
     BitFlag        : WORD;
     CompressType   : WORD;
     FileDate       : LONGINT;
     crc32          : DWORD;
     PackedSize     : LONGINT;
     UnpackedSize   : LONGINT;
     FilenameLen    : WORD;
     ExtraFieldLen  : WORD;
  END;


TYPE
  pCRC32Table        = ^TCRC32;
  TCRC32             = Array[0..256] Of DWORD;

VAR
  CRC32Table  : pCRC32Table;
  Crc32Val    : DWORD;   { Running CRC (32 bit) value }

VAR
  key : ARRAY[0..2] OF LONGINT;
  HEADER_SIGNATURE: LongInt;

CONST
  WSIZE         = 32768;      { window size--must be a power OF two, and at least 32k}
  RAND_HEAD_LEN = 12;
  CRC_MASK      = $FFFFFFFF;

VAR
  Bytes_To_Go : LONGINT;
  InFile        : THandle;
  OutFile       : THandle;
  Header      : TLocal;

  FUNCTION  ReadHeader: BOOLEAN;

  //## the getarchiveoffset has been removed since this value is calculated in dialogsel.pas

  PROCEDURE ProcessArchive(DlgWin: hWnd; lb:integer; FillListBox: BOOLEAN);
 //## added paramter lb to fill more than one listbox with the archive's contents

  FUNCTION  decrypt_pw(Encrypt_Head: PCHAR; EncHead_len: BYTE;
     BitFlag: WORD; CRC, FileDate: LONGINT; password: STRING): BOOLEAN;
  FUNCTION  decrypt_byte: INTEGER;
  PROCEDURE seedk(passwd: STRING);
  PROCEDURE UDK(c: byte);
  PROCEDURE Make_CRC32Table;
  Function  UpdC32( Octet: Byte; Crc: DWORD ): DWORD;

IMPLEMENTATION

USES SFXinflt, Dialog, SFXmisc, SFXStrings, DialogSel;

(*--------------------------------------------------------------------------*)
FUNCTION  ReadHeader: BOOLEAN;
VAR
   BytesRead: DWORD;
BEGIN
   TRY
      Header.SignAtr := 0;
      ReadFile(InFile, Header, SIZEOF(Header), BytesRead, NIL);
      RESULT :=(Header.SignAtr = HEADER_SIGNATURE) OR (Header.SignAtr = $50000000);
      IF RESULT THEN
         Bytes_To_Go := Header.PackedSize
      ELSE begin
         Bytes_To_Go := 0;
         if header.signatr = $08074B50 then begin //## if there is a data-descriptor
            FSeek(filepos+16,FILE_BEGIN);         //## read over it
            result := readheader;                 //## and try again
         end;
      end;
   EXCEPT
      RESULT := FALSE;
   END;

// EWE DEBUG:
// if result then
//    MessageBox(0, 'found a valid zip header', 'DEBUG', mb_OK);
END (* ReadHeader *);




(*--------------------------------------------------------------------------*)
PROCEDURE ProcessArchive(DlgWin: hWnd;lb:integer; FillListBox: BOOLEAN);
VAR
   FN         : PCHAR;
   IsPassword : BOOLEAN;
   EncryptHDR : PCHAR;
   Directory  : STRING;
   Filename   : STRING;
   ExtractFile: STRING;
   hWndList   : hWnd;
   i          : BYTE;
   SavePos    : LONGINT;
   BytesRead  : DWORD;
   Msg        : TMsg;

LABEL ByPass;

BEGIN
   processresult := false; //## added to know whether there have occured problems or not (yes, it could also be a bool-function)

   // We store the local header signature in the file one greater than
   // the real value, so we don't falsely detect a zip file entry inside
   // the SFX code of the .EXE file
   HEADER_SIGNATURE:=$04034B51; // intentionally 1 higher than the real sig
   dec(HEADER_SIGNATURE);       // fix the sig in RAM only

   IsPassword := FALSE; // default
   IF FSeek(StartOfFile, FILE_BEGIN) = -1 THEN
   BEGIN
      MessageBox(0, STR_EARCHIVE, STR_E, MB_ICONERROR);
      Exit;
   END;
   (* Get handle of ArchiveFileListbox *)
   hWndList := GetDlgItem(DlgWin, lb); //## changed
   GetMem(FN, 256 + 2);
   TRY
      (* Start search at beginning of listbox *)
      Index := -1;
      HasStoredPaths := FALSE;
      (* Clear the listbox *)
      IF FillListBox THEN
         SendMessage(hWndList, LB_RESETCONTENT, 0, 0);
      WHILE ReadHeader do
      BEGIN
         SavePos := FilePos;
         ReadFile(InFile, FN^, Header.FilenameLen, BytesRead, NIL);
         Filename := PCharToStr(FN, Header.FilenameLen);
         IF Filename = '' THEN
         BEGIN
            MessageBox(0, STR_INVALIDNAME, STR_E, MB_ICONERROR);
            EXIT;
         END;
         IF NOT HasStoredPaths THEN
            IF (Pos(BSL, Filename) > 0) OR (Pos('/', Filename) > 0) THEN
               HasStoredPaths := TRUE;

         IF FillListBox THEN
            (* Add each string to the listbox *)
            SendMessage(hWndList, LB_ADDSTRING, 0, LONGINT(PCHAR(Filename)))
         ELSE
         BEGIN
            IF IsSelected(hWndList, PCHAR(Filename)) THEN
            BEGIN
               (* Default *)
               IsPassword := FALSE;
               IF (Header.BitFlag AND 1) = 1 THEN
               BEGIN
                  // password protected file
                  DEC(Bytes_To_Go, RAND_HEAD_LEN);
                  TRY
                     GetMem(EncryptHDR, RAND_HEAD_LEN * 2);
                     ReadFile(InFile, EncryptHDR^, RAND_HEAD_LEN, BytesRead, NIL);
                     (* make a working copy of encrypted header in upper half of buffer *)
                     Move(EncryptHDR[0], EncryptHDR[RAND_HEAD_LEN], RAND_HEAD_LEN);
                     TRY
                        IF PW <> '' then
                           IsPassword := decrypt_pw(EncryptHDR,
                                                    RAND_HEAD_LEN,
                                                    Header.BitFlag,
                                                    Header.CRC32,
                                                    Header.FileDate,
                                                    PW
                                                  );

                         IF NOT IsPassword THEN
                            FOR i := 0 TO 2 DO // 3 shots at getting pwd correct
                            BEGIN
                               DialogBox(hInstance, STR_PDLG, 0, @PwdProc);
                               PW := PCharToStr(Password, PWLen);
                               IsPassword := decrypt_pw(EncryptHDR,
                                                         RAND_HEAD_LEN,
                                                         Header.BitFlag,
                                                         Header.CRC32,
                                                         Header.FileDate,
                                                         PW
                                                       );

                               IF IsPassword THEN
                                  BREAK;
                            END;
                     FINALLY
                        FreeMem(EncryptHDR);
                     END;
                  EXCEPT
                  END;
               END
               ELSE
                  (* Not pw protected.. set value to extract *)
                  IsPassword := TRUE;

               IF IsPassword THEN
               BEGIN
                     ExtractFile := PCharToStr(RemoveDirTail(ExtPath), StrLen(AppendDirTail(ExtPath)))
                         +BSL+ Filename; // EWE: add '\' //## i don't know why, but we really need it sometimes

                  IF FileExists(PCHAR(ExtractFile)) THEN
                  BEGIN
                     CASE OverWriteMode OF
                        //0:              (* Overwrite *)
                        1: BEGIN          (* Skip *)
                              SendMessage (hWndList, LB_SETSEL, 0, Index);
                              GOTO ByPass;
                           END;

                        2: BEGIN          (* Confirm *)
                              CurrentFile := ExtractFilename(ExtractFile);
                              DialogBox(hInstance, STR_FILEEXISTS, 0, @FileExistsProc);
                              IF NOT OverWriteFile THEN
                              BEGIN
                                 SendMessage(hWndList, LB_SETSEL, 0, Index);
                                 GOTO ByPass;
                              END;
                           END;
                     END;
                  END
                  ELSE
                  BEGIN
                     Directory := ExtractFilePath(ExtractFile);
                     //MessageBox(0, PCHAR('trying to force dir: ' + Directory), 'EWE', mb_OK);
                     ForceDirectories(Directory);  (* removes trailing dir char *)
                     IF NOT FileExists(PCHAR(Directory)) THEN
                     BEGIN
                        MessageBox(0, PCHAR(Directory), STR_EDIRECTORY , MB_ICONERROR);
                        BREAK;
                     END;
                  END;
                  //MessageBox(0, PCHAR('trying to create file: ' + ExtractFile), 'EWE', mb_OK);
                  OutFile := CreateFile(PCHAR(ExtractFile),
                                         GENERIC_WRITE,
                                         FILE_SHARE_WRITE,
                                         NIL,
                                         CREATE_ALWAYS,
                                         FILE_ATTRIBUTE_NORMAL,
                                         0
                                       );

                  IF OutFile <> INVALID_HANDLE_VALUE THEN
                  BEGIN
                     TRY
                        TRY
                           (* Show extracting filename in status bar *)
                           SendMessage(GetDlgItem(DlgWin, CM_STATUS), WM_SETTEXT, 0, LONGINT(PCHAR(STR_PREXT + {ExtractFilename(} ExtractFile {)})));
                           PeekMessage(Msg, 0, 0, 0, PM_REMOVE);
                           TranslateMessage(Msg);
                           DispatchMessage(Msg);

                           CRC32Val := CRC_MASK;
                           Bytes_To_Go := Header.PackedSize;      (* assign to global *)

                           IF (Header.BitFlag AND 1) = 1 THEN
                              Dec(Bytes_To_Go, RAND_HEAD_LEN);
                           CASE Header.CompressType OF
                              0: UnStore;     (* Stored *)
                              8:  Inflate;    (* Inflate *)
                           ELSE
                           BEGIN
                              MessageBox(0, STR_ETYPE, STR_E, MB_ICONERROR);
                              EXIT;
                           END;
                        END;
                        (* Un-HiLight file in listbox *)
                        IF Header.CRC32 = (CRC32Val xor CRC_MASK)  THEN
                           SendMessage(hWndList, LB_SETSEL, 0, Index);
                     EXCEPT
                        //MessageBox(0, 'Error...', 'Error', mb_OK)
                     END;
                  FINALLY
                     FileSetDate ( Outfile , Header.FileDate ); //## added to set the correct file time
                     IF NOT CloseHandle(OutFile) THEN
                        MessageBox(0, PCHAR(ExtractFile) {FN}, STR_CANNOTCLOSE, MB_ICONERROR);
                  END;
               END
               ELSE
                  begin
                    //   Erweiterung von Thomas Hölzer
                    // Wenn der gerade bearbeitete Eintrag ein Verzeichnis ist,
                    // wird keine Messagebox "Kann Datei nicht öffnen" angezeigt und die Selektierung des
                    // Eintrags entfernt, so daß auch am Ende des Extraktionsvorgangs keine
                    // Fehler gemeldet werden.

                    IF GetFileAttributes(PChar(ExtractFile)) =
                        GetFileAttributes(PChar(ExtractFile))
                        and not FILE_ATTRIBUTE_DIRECTORY
                        then
                            MessageBox(0, PCHAR(ExtractFile) {FN}, STR_CANNOTOPEN, MB_ICONERROR)
                        else
                            SendMessage(hWndList,LB_SetSel,0,index);
                    //   Ende Erweiterung Thomas
                  end;
            END
            ELSE
               (* Terminate file processing if not password *)
               BREAK;
         END;
      END;

   ByPass: FSeek(SavePos +
                  SIZEOF(Header) +
                  Header.FilenameLen +
                  {Header.CommentLen +}
                  Header.PackedSize,
                  FILE_BEGIN
                );
  END;
  IF IsPassword AND NOT FillListBox THEN
  BEGIN
     IF SendMessage(hWndList, LB_GETSELCOUNT, 0, 0) = 0 THEN
     begin
        if not AutoRun
        then
            MessageBox(0, STR_ALLEXT, STR_OK, mb_OK);
        //## removed the setting of the status-text cause we want to close the main-dialog now.
        processresult := true;
     end
     ELSE
     begin
        MessageBox(0, STR_NOTSELEXT, STR_E, MB_ICONERROR);
        SendMessage(GetDlgItem(DlgWin, CM_STATUS), WM_SETTEXT, 0, LONGINT(PCHAR(STR_NOTSELEXT)));
        processresult := false;
     end
  END
  ELSE
     (* if listbox empty, exit program *)
     IF FillListBox THEN
        IF SendMessage(hWndList, LB_GETCOUNT, 0, 0) = 0 THEN
            MessageBox(0, STR_EARCHIVE, STR_E, MB_ICONERROR);
 FINALLY
   Freemem(FN);

 END;
END (* ProcessArchive *);

(*--------------------------------------------------------------------------*)
PROCEDURE Make_CRC32Table;
VAR
    i, j: WORD;
    r:    DWORD;
CONST
    CRCPOLY    = $EDB88320;
    UCHAR_MAX  = 255;
    CHAR_BIT   = 8;
BEGIN
    FOR i := 0 to UCHAR_MAX DO
    BEGIN
       r := i;
       FOR j := CHAR_BIT DOWNTO 1 DO
          IF (r AND 1) > 0 THEN
             r := (r SHR 1) XOR CRCPOLY
          ELSE
             r := r SHR 1;
       CRC32Table[i] := r;
    END;
END;

(*--------------------------------------------------------------------------*)
Function UpdC32( Octet: Byte; Crc: DWORD ): DWORD;
Begin
    Result := CRC32TABLE[ Byte( Crc XOR DWORD( Octet ) ) ] XOR ((Crc SHR 8) AND $00FFFFFF);
End;

(*--------------------------------------------------------------------------*)
(* Update the encryption keys with the next byte of plain text *)
PROCEDURE UDK(c: byte);
BEGIN
      key[0] := UpdC32(c, key[0]);
      key[1] := key[1] + key[0] AND $000000ff;
      key[1] := key[1] * 134775813 + 1;
      //key[2] := UpdC32(key[1] shr 24, key[2]);
      key[2] := UpdC32(HIBYTE(HIWORD(key[1])), key[2]);
END;

(*--------------------------------------------------------------------------*)
(* Initialize the encryption keys and the random header according to
     the given password. *)
PROCEDURE seedk(passwd: STRING);

VAR
    i: BYTE;
BEGIN
    key[0] := 305419896;
    key[1] := 591751049;
    key[2] := 878082192;
    FOR i := 1 to LENGTH(passwd) do
        udk(BYTE(passwd[i]));
END;

(*--------------------------------------------------------------------------*)
(* Return the next byte in the pseudo-random sequence *)
FUNCTION decrypt_byte: INTEGER;
VAR
    temp: WORD;
BEGIN
    temp := word(key[2] or 2);
    RESULT := integer(word((temp * (temp XOR 1)) SHR 8) AND $ff);
END;

(*--------------------------------------------------------------------------*)
FUNCTION decrypt_pw(Encrypt_Head: PCHAR; EncHead_len: BYTE;
                BitFlag: WORD; CRC, FileDate: LONGINT; password: STRING): BOOLEAN;
VAR
    i,c,b: BYTE;
BEGIN
    RESULT := FALSE;
    IF password = '' THEN
       EXIT;
    seedk(Password);
    FOR i := 0 to EncHead_len - 1 DO
    BEGIN
       c := byte(Encrypt_Head[i + EncHead_len]) XOR decrypt_byte;
       udk(c);
       Encrypt_Head[i] := char(c);
    END;

    (* version 2.0+ *)
    b := BYTE(Encrypt_Head[EncHead_len - 1]);

    IF NOT ((BitFlag AND 8) = 8) THEN
    BEGIN
       IF b = hibyte(hiword(crc)) THEN
            RESULT := TRUE;
    END
    ELSE
    BEGIN
       IF b = loword(FileDate) SHR 8 THEN
          RESULT := TRUE;
    END;
END;
(*--------------------------------------------------------------------------*)

END.
