(******************************************************************)
(* Copyright 1997,1998, Merkes' Pages (Markus Stephany)           *)
(* Email: mirbir.st@t-online.de                                   *)
(* Web-page: http://home.t-online.de/home/mirbir.st/              *)
(*                                                                *)
(* This program was written in Borland Delphi 3 (and should be    *)
(* fully compatible with Delphi 2 (I hope it !).                  *)
(*                                                                *)
(******************************************************************)

{ this is a part of the modified version of ZipSfx.
  initially, zipsfx has been written by :

(******************************************************************)
(* ZipSFX                                                         *)
(* Copyright 1997, Carl Bunton                                    *)
(* Home of ZipTV compression components for Delphi                *)
(* Email: Twojags@cris.com                                        *)
(* Web-page: http://www.concentric.net/~twojags                   *)
(******************************************************************)

the first modifications came from Eric W. Engler englere@swcp.com

he is the creator of the powerful freeware zip-vcl delzip for delphi 2? and 3.

now i am trying to make the code a bit more sfx-creator- and sfx-user- friendly,
and i must say, eric is a very hard beta-tester :).

credits to : Deepu Chandy Thomas (deepu@md3.vsnl.net.in) for adding the SHBROWSEFORFOLDER routines (083198)
credits to : didier havelange (Didier.Havelange@ping.be) for the autorun feature (100298)

}

UNIT Dialogsel;

INTERFACE

USES
    Messages, Windows , SFXMisc , ShellAPI;


procedure getdefaultparams; // reads the special header (s.b.), if any and sets some variables
procedure executecmd(int:integer); // execute the command-line read from the special header, if any
function getarg(index:integer):string; // splits the command line in application / parameters, if possible
function SelectDir ( Parent : HWND ; Path : Pointer ) : Boolean; // returns True, if the new-dir button has been clicked
FUNCTION newdirProc(dlgnew     : hWnd ;
                         DlgMessage : UINT;
                         DlgWParam  : WPARAM ;
                         DlgLParam  : LPARAM) : BOOL; STDCALL;


var  storedpath   : pchar;    // the default-directory stored in the special header (out)
     commandline  : pchar;    // the command line read from the special header
     caption      : pchar;    // the definable caption for the main dialog
const
     usecl        : Boolean = False;    // no cammand line
     usesp        : Boolean = False;    // no stored path
     usecap       : Boolean = False;   // no stored caption
     allowsel     : Boolean = True;  // user can choose files to extract
     allowdcl     : Boolean = True;  // user can disable execution of the command line
     hideovm      : Boolean = False;  // user can change the overwrite-mode
     defovm       : Integer = cm_confirm; // by default : confirm 
     AutoRun      : Boolean = False; // no automatic extraction by default

     cm_browse  = 775;        // the item-id for the "browse dir"-buutin in the main dialog
     cm_runapp  = 1007;       // for the "run xxx after extraction"-checkbox
     cm_lbshow  = 302;        // for the single-selection listbox that the user sees if he is not allowed to select what files to extract
     cm_group   = 509;        // for the "existing file(s)" -groupbox (just to hide it if necessary)
     CM_NEW     = 1277;       // for browsefoler-new


IMPLEMENTATION

uses sfxgbls,sfxstrings;

(* the structure of a zipsfx-file :
- zipsfx-executable code (0-xxxxx)
- signature "MPU"                        or                           zip-archive
-                |_ rest of the special header
-                                             |_ zip-archive

the structure of the special-header :
Byte 0..2   : signature "MPU"

Byte    3   : Bit 0 (val  1) : if set, user can disable running the command line after extraction (if any)
              Bit 1 (val  2) : if set, user can choose what files to extract
              Bit 2 (val  4) : if set, user cannot change the overwrite-mode (confirm, overwrite, skip)
              Bit3-4(val 8,16) : default-overwrite mode
                     0 : confirm overwriting existing files
                     8 : overwrite existing files
                    16 : skip existing files
              Bit5 (val 32) : internally used, if set, then do not check file size
              Bit6 (val 64) : if set, then automatically extract all files

Byte    4   : length of user-defined caption / 0=default caption
        5   : length of default-extraction-path / 0=current directory
        6   : length of command line to start after extraction / 0=none

Byte 7..m   : the dialog's caption, if byte 4 <> 0 ( without terminating zero)
     m+1..n : the default-extraction-path, if byte 5 <> 0 (dito)

              ++++added  march 01,98 if set to "><", then use  temp-dir

     n+1..x : the command line to execute after successfull extraction, if byte 6 <> 0 (dito)
              format : the command line has a special format
              if the string "><" (greater than+less than) is somewhere in the command line,
              it will be replaced with the path where the archive has been extracted to.
              (e.g. "><readme\test.txt" after an extraction to the path "C:\Program files\unpacked" means :
              "c:\progra~1\unpacked\readme\test.txt") <- the short path will be created by zipsfx.
              if the pipe "|" is in the command-line, the part to the left will get the application to run
              and the part to the right will be it's argument;
              if the archive is extracted to e.g. "d:\unpack", then we will get the following :
              "><setup\setup.exe|><install.inf" will parse to :
              run "d:\unpack\setup\setup.exe" with parameters "d:\unpack\install.inf".
              "c:\windows\notepad.exe|><readme.txt" will parse to :
              run "c:\windows\notepad.exe" with parameters "d:\unpack\readme.txt".
              "><readme.txt" will parse to :
              open "d:\unpack\readme.txt" with its associated program, if there is any.
              "><setup.exe" will run "d:\unpack\setup.exe" without special parameters.
              ...

since the special header always has a size of 256 bytes, it must be filled to fit (and if the three strings are too long,
there will occur some problems)

*)

// SHBrowseFor Folder Code Definitions start //
type
  TFNBFFCallBack = function(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
   {TSHItemID -- Item ID }
  TSHItemID = packed record           { mkid }
    cb: Word;                         { Size of the ID (including cb itself) }
    abID: array[0..0] of Byte;        { The item ID (variable length) }
  end;

{ TItemIDList -- List if item IDs (combined with 0-terminator) }

  PItemIDList = ^TItemIDList;
  TItemIDList = packed record         { idl }
     mkid: TSHItemID;
   end;
TBrowseInfo = packed record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: PAnsiChar;  { Return display name of item selected. }
    lpszTitle: PAnsiChar;       { text to go in the banner over the tree. }
    ulFlags: UINT;              { Flags that control the return stuff }
    lpfn: TFNBFFCallBack;
    lParam: LPARAM;             { extra info that's passed back in callbacks }
    iImage: Integer;            { output var: where to return the Image index. }
  end;
var
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..MAX_PATH] of char ;
  idBrowse : PItemIDList;
  WND_NEWBT : hwnd;
  FG_NEWBT  : Boolean;

 function SHBrowseForFolder(var lpbi: TBrowseInfo): PItemIDList; stdcall;external 'shell32.dll' name 'SHBrowseForFolderA';
 function SHGetPathFromIDList(pidl: PItemIDList; pszPath: PChar): BOOL; stdcall;external 'shell32.dll' name 'SHGetPathFromIDListA';
 // SHBrowseFor Folder Code Definitions end //




const
     ci_listbox = 2003;   // itemID of the directory-listbox in the select-dir dialog
     ci_label   = 2001;   // the directory-display - static text
     ci_net     = 2002;   // to connect a network-drive (not yet tested !!!)
     ci_new     = 2004;   // to show the create-dir dialog

     cn_path    = 3001;   // itemID of the current-path - display in the create-subdir dialog
     cn_edit    = 3002;   // of the enter-new-subdir edit



function getarg(index:integer):string; // gets an argument from the stored command line
//                1 : the part before the pipe (if there's no pipe, returns the whole command line)
//                2 : the part after the pipe (if no pipe, returns "")
//                all "><" will be replaced by the ectraction path
var pip:integer;
begin
     appenddirtail(extpath);
     result := pchartostr(commandline,strlen(commandline));
     pip := pos('|',result);
     if pip = 0 then begin
        if index = 2 then result := ''
     end else begin
         if index = 1 then result := copy(result,1,pip-1)
         else result := copy(result,pip+1,maxint);
     end;
     repeat
           pip := pos('><',result);
           if pip = 0 then break;
           result := copy(result,1,pip-1)+extpath+copy(result,pip+2,maxint);
     until false;
     // get the short (8+3)-filename (it seems that shellexecute has some problems with lfn)
     getshortpathname(pchar(result),pchar(result),length(result));

end;

function forcedirs(path1,path2:pchar):boolean; // check whether all directories can be created
var sr : string;
begin
     result := false;
     sr := pchartostr(path2,strlen(path2));
     if pos(':',sr) > 0 then exit;
     while (sr <> '') and (sr[1] = BSL) do delete(sr,1,1);
     if sr = '' then exit;
     forcedirectories(pchartostr(path1,strlen(path1))+sr);
     if fileexists(pchar(sr+BSL)) then begin
        setcurrentdirectory(pchar(sr));
        result := true;
     end;
end;


// window proc for the new-directory dialog
FUNCTION newdirProc(dlgnew     : hWnd ;
                         DlgMessage : UINT;
                         DlgWParam  : WPARAM ;
                         DlgLParam  : LPARAM) : BOOL; STDCALL;

var buffer : array [0..fsMAXPATH +1 ] of Char;
BEGIN (* newdirProc *)
   RESULT := FALSE;
   CASE DlgMessage OF
      WM_INITDIALOG : BEGIN
                      AppendDirTail ( extpath );
                     (* Center dialog on screen.       *)
                     CenterDialog(dlgnew);
                     setdlgitemtext(dlgnew,cn_path,extpath); // and set it in this dialog
                     setfocus(getdlgitem(dlgnew,cn_edit));
                  END;
                 (* Handle button presses, etc. *)

         WM_COMMAND    : CASE LOWORD(DlgWParam) OF
                            CM_OK     :
                            BEGIN

                               // make subdirs;
                               getdlgitemtext(dlgnew,cn_edit,buffer,max_path);
                               if strlen(buffer) <> 0
                               then
                                   if not forcedirs(extpath,buffer)
                                   then begin
                                        messagebox( dlgnew,STR_EDIRECTORY,STR_E,
                                                    mb_iconerror);
                                        Exit;
                                   end
                                   else
                                   begin
                                        if strlen(extpath)+strlen(buffer)+1 < fsmaxpath
                                        then
                                            move(buffer[0],extpath[strlen(extpath)],strlen(buffer)+1);

                                   end;
                                   EndDialog(dlgnew, LOWORD(DlgWParam));
                            END;
                           CM_CANCEL : BEGIN
                               EndDialog(dlgnew, LOWORD(DlgWParam));
                               //EXIT;
                            END;
                         ELSE      ;
                         END (* CASE *);
         ELSE          ;
     END (* CASE *);
END   (* newdirProc *);



procedure executecmd; // parses and shell-executes the stored command line after extraction
var sr1,sr2 : string;
begin
          if (int =1) and usecl then begin
             sr1 := getarg(1);
             sr2 := getarg(2);
             shellexecute(0,'open',pchar(sr1),pchar(sr2),'',sw_show);
             //messagebox(0,pchar(sr2),pchar(sr1),0);
          end;
end;

// hook-wnd-proc for shbrowseforfolder-dialog
function OwnWndProc( wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
     Result := 1;
     if (Msg=WM_COMMAND) and (wParam=CM_NEW)
     then begin
          FG_NEWBT := True; // if the new button is pressed, send an ok-click and remember the new-button
          PostMessage ( wnd , WM_COMMAND , 1  , 0)
     end
     else
         Result := DefDlgProc( wnd,Msg,wParam,lParam);
end;

// add a "new" button to the shbrowseforfolder
procedure AddNewButton ( wnd:HWND);
var
  tempwnd:hwnd;                   //hwnd for the child-windows of the dialog
  x1,y1,h1:integer;               //left,top,height of the button

  rct : trect;                    //storage for the ok-button's rect
  tp : tpoint;                    //point for screentoclient-api
begin
        //get the top, left and height of the ok-button

        SetWindowText( wnd , STR_BROWSECAP );
        tempwnd := GetDlgItem ( wnd , 1 ) ; //ok-button

        getwindowrect (tempwnd,rct);
        tp.x := rct.left;
        tp.y := rct.top;
        screentoclient(wnd,tp);
        x1 := tp.x-90; // our button's width is 75, so this should a bit bigger
        y1 := tp.y;
        h1 := rct.bottom-rct.top;

        //end of position-detection


        WND_NEWBT:=CreateWindow('BUTTON',STR_BTNFOLD,
        WS_CHILD or WS_CLIPSIBLINGS or WS_VISIBLE or WS_TABSTOP or BS_PUSHBUTTON,
        x1,y1,75,h1,wnd,CM_NEW,HInstance,nil);

        // get the ok-button's font and set it for our button
        PostMessage(WND_NEWBT,WM_SETFONT,SendMessage ( tempwnd , WM_GETFONT , 0 , 0 ) ,MAKELPARAM(1,0));

        // default -> disable, since we are on "my computer"
        EnableWindow ( WND_NEWBT , False );

        //hook a new window procedure to catch this button
	SetWindowLong( wnd , GWL_WNDPROC , Longint(@OwnWNDProc) );
end;

// callback proc for shbrowseforfolder
function BrowseCBProc(HWindow: HWND; uMsg: Integer; lParameter: LPARAM; lpBrowseFolder: LPARAM): Integer; stdcall ;
begin
     Result := 0;
	case uMsg of

		1{BFFM_INITIALIZED}: AddNewButton ( HWindow );

		2{BFFM_SELCHANGED}:
			begin
                             // test if the currently selected path is a valid file-system path
                             if not SHGetPathFromIDList ( PItemIDList ( lParameter ) , DisplayName )
                             then
                                 EnableWindow ( GetDlgItem ( HWindow , ID_OK ) , False );

                             // enable new-button only if ok-button is enabled
                             EnableWindow ( WND_NEWBT , IsWindowEnabled ( GetDlgItem ( HWindow , ID_OK )));
			end;
	end;
end;


function SelectDir ( Parent : HWND ; Path : Pointer ) : Boolean;
begin
     Result := False;
     with BrowseInfo
     do begin
          hWndOwner:=Parent;
          pidlRoot:=nil;
          pszDisplayName:=DisplayName;
          lpszTitle:=STR_EXPT;
          ulFlags:=$0001;
          lpfn:=@BrowseCBProc;
          lParam:=0;
     end;
     FG_NEWBT := False;
     idBrowse:=SHBrowseForFolder(BrowseInfo);
     if assigned(idBrowse) then
     Begin
          // convert pidl to folder name //
          SHGetPathFromIDList(idBrowse,Path);
          setcurrentdirectory(Path);
          Result := FG_NEWBT;
          { result is only true if new-button has been clicked.
            if cancel has been pressed, the original path won't be changed. not very nice, but works in our case}
     end;
end;

(* to check correct file size of the input file *) // +++ 08/13/98
procedure CheckFileSize;
var
   pSZ,pCT,pFP:  DWORD;
   pBU:         pChar;
const
   pFL: Boolean = False;
begin
   // get the needed size of the buffer ( max 65536+sizeof(eocd) , min sizeof(file) )
   pSZ := GetFileSize( InFile, nil ) - StartOfFile;
   if pSZ > 65558 then
      pSZ := 65558;

   if pSZ > 22 then  {if smaller, then no correct zip file}
   begin
      GetMem( pBU, pSZ );
      try
         FSeek( -pSZ, FILE_END );
         pFP := FilePos;
         ReadFile( InFile, pBU[0], pSZ, pCT, nil );
         if pCT = pSZ then
            for pCT := 0 to pSZ - 22 do
            begin
               if (pBU[pCT] = #$50) and (pBU[pCT + 1] = #$4b) and (pBU[pCT + 2] = #$05) and (pBU[pCT + 3] = #$06) then
               begin
                  // eocd is found, now check if size is correct ( = pos+22+eocd.commentsize)
                  if ( (Ord( pBU[pCT + 21] )* 256) + Ord ( pBU[pCT + 20] ) + pFP + pCT + 22 ) = GetFileSize( Infile, nil ) then
                  begin
                     // set ok flag and return to the correct file position
                     fSeek ( StartOfFile - 252, FILE_BEGIN );
                     pFL := True;
                     Break;
                  end;
               end;
            end;
      finally
         FreeMem( pBU, pSZ );
      end;
   end;

   if not pFL then
   begin
      MessageBox( 0, STR_EINC_SIZE, STR_E, mb_iconerror );
      CloseHandle( InFile );
      Halt;
   end;
end;


procedure getdefaultparams; // reads the values from the special header, if any
var sig:           Array [0..2] Of Char;
    br:            DWORD;
    spl, cll, cal: Byte;
begin
     StartOfFile := 38912;  // this is the size of the D4 original sfx-executable
     //startoffile := 34816; // this is the size of the D2 original sfx-executable

     fseek( StartOfFile, file_begin ); // let us look for a special-header signature directly after the sfx-code
     ReadFile( InFile, sig[0], 3, br, nil );
     if br = 3 then if sig = 'MPU' then begin   // okay, found
        Inc( StartOfFile, 256 );         // the archive will start 256 bytes behind the spec header
        ReadFile( infile, cll, 1, br, nil );          // read and evaluate the flags-byte
        if (cll and 1) = 0 then allowdcl := False;
        if (cll and 2) = 0 then allowsel := False;
        if (cll and 4) = 4 then hideovm  := True;
        case (cll and 24) of
             8 : defovm := cm_overwrite;
            16 : defovm := cm_skip;
        end;

        // +++ aug 13, 1998
        if (cll and 32) = 0
        then
            CheckFileSize;

        // +++ oct 02, 1998 (credits to didier havelange for this feature), filename must start with a "!" char
        // to enable autorun capability
        if ((cll and 64) = 64) and (Pos ('!',ExtractFileName(ParamStr(0))) = 1)
        then
            AutoRun := True;

        readfile(infile,cal,1,br,nil);          // read length of caption
        if cal > 0 then usecap := true;
        readfile(infile,spl,1,br,nil);          // read length of stored path
        if spl > 0 then usesp := true;
        readfile(infile,cll,1,br,nil);          // read length of command line
        if cll > 0 then usecl := true;

        // read the caption;
        if usecap then readfile(infile,caption^,cal,br,nil);
        caption[cal] := #0;
        // read the stored path;
        if usesp then begin
           readfile(infile,storedpath^,spl,br,nil);
           storedpath[spl] := #0;

           //+++++ added march 01,98 : if the def path = "><", then use temporary directory
           if storedpath = '><' then
              gettemppath(max_path,storedpath);
        end;
        // read the command line;
        if usecl then readfile(infile,commandline^,cll,br,nil);
        commandline[cll] := #0;
     end;
end;

initialization
              getmem(storedpath,max_path+1);
              getmem(commandline,max_path+1);
              getmem(caption,max_path+1);
finalization
            freemem(storedpath);
            freemem(commandline);
            freemem(caption);

END.
