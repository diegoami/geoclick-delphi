{$A-,B-,C-,D+,E-,F-,G+,H+,I-,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
(******************************************************************)
(* ZipSFX                                                         *)
(* Copyright 1997, Carl Bunton                                    *)
(* Home of ZipTV compression components for Delphi                *)
(* Email: Twojags@cris.com                                        *)
(* Web-page: http://www.concentric.net/~twojags                   *)
(*                                                                *)
(* This program was written in Delphi 2 because version 2         *) //## this release in delphi3
(* compiles a much smaller executable using the windows api.  It  *)
(* should be fully compatible with Delphi 3, but will produce a   *)
(* noticable increase of size in the final compiled program.      *)
(*                                                                *)
(*MODIFIED by M. Stephany mirbir.st@t-online.de  12/28/97-08/25/98*)
(* for some special purposes; modified lines are marked (##)      *)
(******************************************************************)

{ notes:

the initial release of zipsfx comes from Carl Bunton (see above).
he has created a powerful shareware vcl for delphi that can handle
almost all of the popular archive-formats like zip,lzh,arj...., called ziptv.

the first modifications came from Eric W. Engler, the author of the great freeware
delphi-vcl delzip that can handle zip-archives and -sfx's. (englere@swcp.com)

now i am trying to make the code a bit more sfx-creator- and sfx-user- friendly,
and i must say, eric is a very hard beta-tester :).

original zip-code comes from the infozip-group, they developped a free implementation
of the zip/unzip-code for unix and later for other platforms.
  Info-Zip home page:
  http://www.cdrom.com/pub/infozip/

regards, Markus Stephany, mirbir.st@t-online.de
Merkes' Pages at http://home.t-online.de/home/mirbir.st/

losheim am see, saarland, germany, jan 03 1998 ; mar 15, 1998 ; july 05 , 1998 ; august 13 , 1998

NOTE : !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                                                                                       !
TO GET ZIPSFX WORKING CORRECTLY, YOU SHOULD FIRST COMPILE IT ONCE AND THEN SET THE CORRECT VALUE FOR   !
StartOfFile IN LINE 440 IN DIALOGSEL.PAS. THIS MUST BE SET TO THE SIZE OF THE COMPILED EXE.            !
THIS VALUE CAN DIFFER DEPENDING ON THE DELPHI-VERSION (AND OTHER THINGS I DO NOT UNDERSTAND).          !
PLEASE USE THE INCLUDED SFX.DOF AS YOUR PROJECT'S OPTIONS FILE.                                        !
                                                                                                       !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

}

PROGRAM Sfx;   //#################### version 0.99a #####################


USES  Dialog,
  SFXgbls,
  SFXmisc,
  Windows,
  dialogsel,
  SFXStrings;

//## added dialogsel.pas

//{$R *.RES} //## renamed to sfx1.res (because of the delphi-created res-file)
{$R SFX1.res}

BEGIN
  (* Open the archive *)
  InFile := CreateFile( PChar( ParamStr( 0 ) ),
                       GENERIC_READ,
                       FILE_SHARE_READ,
                       NIL,
                       OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL,
                       0 );

  (* If error, notify and abort *)
  IF InFile = INVALID_HANDLE_VALUE THEN
  BEGIN
     MessageBox( 0, PChar( ParamStr( 0 ) ), STR_EARCHIVE, MB_ICONERROR );
     EXIT;
  END;

  New( CRC32Table );
  Make_CRC32Table;

  TRY
     (* Get the beginning offset OF the archive *)
     //StartOfFile := GetArchiveOffset;  -- moved to SFXGBLS.PAS, EWE -- moved to dialogsel.pas, MST
     (* Display the dialog *)
    getdefaultparams; //## read the special setup-header from the file, if any
    DialogBox( hInstance, STR_MAINDLG, 0, @MainDialogProc );
  FINALLY
     (* Close the archive *)
     IF NOT CloseHandle( InFile ) THEN
        MessageBox( 0, STR_CANNOTCLOSE, STR_E , MB_ICONERROR );
     Dispose( CRC32Table );
  END;
END.
