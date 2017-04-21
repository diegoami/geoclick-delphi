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
(*MODIFIED by M. Stephany mirbir.st@t-online.de  12/28/97-08/25/98*)
(*                                                                *)
(******************************************************************)
UNIT Dialog;

INTERFACE

USES
    Messages,
    Windows;

FUNCTION MainDialogProc(DlgWin     : hWnd ;
                         DlgMessage : UINT;
                         DlgWParam  : WPARAM ;
                         DlgLParam  : LPARAM) : BOOL; STDCALL;

FUNCTION FileExistsProc(DlgWin      : hWnd;
                         DlgMessage : UINT;
                         DlgWParam  : WPARAM;
                         DlgLParam  : LPARAM) : BOOL; STDCALL;

FUNCTION PwdProc(DlgWin     : hWnd;
                         DlgMessage : UINT;
                         DlgWParam  : WPARAM;
                         DlgLParam  : LPARAM) : BOOL; STDCALL;

IMPLEMENTATION

USES  SFXgbls, SFXmisc,dialogsel,SFXStrings;//## MST added dialogsel



(*--------------------------------------------------------------------------*)
(*     FileExistsProc --- Handle messages for password dialog.              *)
(*--------------------------------------------------------------------------*)
FUNCTION FileExistsProc(DlgWin     : hWnd;
                        DlgMessage : UINT;
                        DlgWParam  : WPARAM;
                        DlgLParam  : LPARAM) : BOOL; STDCALL;
VAR
   Msg: STRING;
BEGIN
   RESULT := TRUE;
   CASE DlgMessage OF
      WM_COMMAND: CASE LOWORD(DlgWParam) OF
                     CM_YES, CM_NO: BEGIN
                        (* Noask Overwrite checked, show results in
                           affected option buttons *)
                        IF SendMessage(GetDlgItem(DlgWin, CM_NOASK), BM_GETCHECK, 0, 0) = 1 THEN
                        BEGIN
                           (* Set CM_CONFIRM to Unchecked *)
                           SendMessage(GetDlgItem(MainWin, CM_CONFIRM), BM_SETCHECK, 0, 0);
                           IF LOWORD(DlgWParam) = CM_YES THEN
                           BEGIN
                              (* Set CM_OVERWRITE to checked *)
                              SendMessage(GetDlgItem(MainWin, CM_OVERWRITE), BM_SETCHECK, 1, 0);
                              (* Don't ask for OverWrites *)
                              OverWriteMode := 0;
                              OverWriteFile := TRUE;
                           END
                           ELSE
                           BEGIN   (* CM_SKIP *)
                              (* Set CM_SKIP to checked *)
                              SendMessage(GetDlgItem(MainWin, CM_SKIP), BM_SETCHECK, 1, 0);
                              (* Don't ask... skip *)
                              OverWriteMode := 1;
                              OverWriteFile := FALSE;
                           END;
                        END // if sendmessage
                        ELSE
                           (* Set Mode *)
                           IF OverWriteMode > 0 THEN
                              OverWriteFile := LOWORD(DlgWParam) = CM_OK;
                        EndDialog(DlgWin, LOWORD(DlgWParam));
                        EXIT;
                     END;
                  ELSE; { else case }
                        { nothing }
                  END (* end CASE *);

         WM_INITDIALOG : BEGIN
                     CenterDialog(DlgWin);
                     Msg := CurrentFile + STR_EXISTS;
                     SendMessage(GetDlgItem(DlgWin, CM_EDIT1), WM_SETTEXT, 0, LONGINT(PCHAR(Msg)));
                  END;
   END;
   RESULT := FALSE;
END;

(*--------------------------------------------------------------------------*)
(*     PasswordProc --- Handle messages for password dialog.                *)
(*--------------------------------------------------------------------------*)
FUNCTION PwdProc(DlgWin     : hWnd;
                 DlgMessage : UINT;
                 DlgWParam  : WPARAM;
                 DlgLParam  : LPARAM) : BOOL; STDCALL;
BEGIN
   CASE DlgMessage OF
      WM_COMMAND    : CASE LOWORD(DlgWParam) OF
                         CM_OK     : BEGIN
                            PWLen := GetDlgItemText(DlgWin, CM_EDIT1, Password, fsMaxPassword);
                            Password[ PwLen ] := #0;
                            EndDialog(DlgWin, LOWORD(DlgWParam));
                         END;
                      ELSE;
                      END (* CASE *);
         WM_INITDIALOG : BEGIN
                         (* Center dialog on screen.       *)
                         CenterDialog(DlgWin);
                         (* Set input focus to the first   *)
                         (* edit field.                    *)
                         SetFocus(GetDlgItem(DlgWin , CM_EDIT1));
                      END;

   END;
   RESULT := FALSE;
END;

(*--------------------------------------------------------------------------*)
(*     MainDialogProc --- Handle messages for main window dialog.           *)
(*--------------------------------------------------------------------------*)
FUNCTION MainDialogProc(DlgWin     : hWnd ;
                         DlgMessage : UINT;
                         DlgWParam  : WPARAM ;
                         DlgLParam  : LPARAM) : BOOL; STDCALL;
VAR
// MyIcon : HICON;
   EditLen: LONGINT;
   cm1 : integer;
BEGIN (* MainDialogProc *)
   RESULT := TRUE;
   CASE DlgMessage OF
      WM_INITDIALOG : BEGIN
                     (* Center dialog on screen.       *)
//                     CenterDialog(DlgWin);  ## MST moved
                     (* Set the icon for the program.  *)
//                     MyIcon := LoadIcon(hInstance , 'MnIcon'); //## mainicon changed to mnicon
//                   SetClassLONG(DlgWin , GCL_HICON , MyIcon);
                     (* Set input focus to the first   *)
                     (* edit field.                    *)
//                   SetFocus(GetDlgItem(DlgWin , CM_EDIT1));
                     (* Set ExtractPath to CurDir *)

                     //## modified to give the ability to set a default path
                     // and to show a checkbox for running a command line after extraction

                     cm1 := getdlgitem(DlgWin, CM_runapp); // the run... checkbox
                     //## this is to get either the current dir or the stored def-path
                     if not usesp then GetCurrentDirectory(fsMaxPath, ExtPath) else
                        move(storedpath[0],extpath[0],strlen(storedpath)+1);

                     if not usecl then  //## no cmd-line, so hide the run... checkbox
                        showwindow(cm1, sw_hide) else
                       begin
                        //## give the run... checkbox a title
                        sendmessage(cm1,wm_settext,0,integer(pchar(STR_RUN+
                        extractfilename(getarg(1))+' '+extractfilename(getarg(2)))));

                        //## check it by default
                        sendmessage(cm1,bm_setcheck,1,0);
                        if not allowdcl then //## if not allowed to disable the cmd-line, hide the run... cb
                        showwindow(cm1, sw_hide);
                       end;
                     SendMessage(GetDlgItem(DlgWin, CM_EDIT1), WM_SETTEXT, 0, LONGINT(@ExtPath));
                     (* Hilite string in Edit1 control *)
                     SendMessage(GetDlgItem(DlgWin, CM_EDIT1), EM_SETSEL, 0, $7fff);

                     //## the selection-mode has been removed since we want all files to get extracted

                     (* Set overwrite as default option button *) //## modified
                     SendMessage(GetDlgItem(DlgWin, defovm), BM_SETCHECK, 1, 0); //## set the given overwrite-mode
                     OverWriteMode := defovm-501; //## and calculate the command fo the overwrite-mode

                     //## the use archive-stored-paths option has been deleted since we want to kepp
                     //   the archives-dir-structure

                     if hideovm then begin //## if we do not want to select another overwrite-mode, destroy the controls
                        destroywindow(GetDlgItem(DlgWin, cm_overwrite));
                        destroywindow(GetDlgItem(DlgWin, cm_skip));
                        destroywindow(GetDlgItem(DlgWin, cm_confirm));
                        destroywindow(GetDlgItem(DlgWin, cm_group));
                     end;
                     if usecap then setwindowtext(dlgwin,caption); //## if we have a stored caption for the dialog, use it
                     CenterDialog(DlgWin); //## now center the dialog
                     (* Fill the list box *)

                     //## added a parameter to the processarchive cause we have two listboxes (only 1 is visible)
                     ProcessArchive(DlgWin,cm_list, TRUE); //## first fill the multisel-listbox
                                                           // the name has changed from cm_filelist to cm_list

                     if allowsel then //## if the user can (de)select files
                        showwindow(GetDlgItem(DlgWin, cm_lbshow),sw_hide) //## hide the singlesel-listbox
                     else begin //## else
                        showwindow(GetDlgItem(DlgWin, cm_list),sw_hide); //## hide the multisel-lb
                        ProcessArchive(DlgWin,cm_lbshow, TRUE); //## and read the archive-contents to the singlesel-lb
                     end;
                     (* Select all items in the listbox *)
                     SendMessage(GetDlgItem(DlgWin, CM_LIST), LB_SETSEL, 1, -1);

                     if autorun // do the extraction automatically, if autorun = true
                     then
                         SendMessage(DlgWin,  WM_COMMAND, CM_OK, 0);

                     (* Assign to a global *)
                     MainWin := DlgWin;
                  END;
                 (* Handle button presses, etc. *)

         WM_COMMAND    : CASE LOWORD(DlgWParam) OF

                            //## added the ability to select a extract directory
                            // Modified by Deepu Chandy Thomas //
                            cm_browse:begin
                                           if SelectDir ( DlgWin , @extpath[0] )
                                           then
                                               if DialogBox( hInstance, 'DLGNEW', DlgWin, @newdirProc ) <> ID_OK
                                               then
                                                   GetDlgItemText ( DlgWin , CM_EDIT1 , ExtPath , fsMaxPath);
                                           SetDlgItemText ( DlgWin , CM_EDIT1 , extpath );

                                      end;


                            // show the copyright information
                            CM_ABOUT : MessageBox ( DlgWin , STR_ABOUT_MSG , STR_ABOUT_CAP , MB_OK );

                            //## removed storedpath-checkbox-handler cause this control has been removed

                            CM_OVERWRITE  : OverWriteMode := 0;
                            CM_SKIP       : OverWriteMode := 1;
                            CM_CONFIRM    : OverWriteMode := 2;
                            CM_OK     : BEGIN

                               //## if the user is not allowed to (de)selct files from the archive, then
                               //   select them all; hide the single-sel-lb and show the multisel-lb
                               //   to have the ability to show the user what files have not been extracted
                               if not allowsel then begin
                                  SendMessage(GetDlgItem(DlgWin, CM_LIST), LB_SETSEL, 1, -1);
                                  showwindow(GetDlgItem(DlgWin, CM_Lbshow),sw_hide);
                                  showwindow(GetDlgItem(DlgWin, CM_List),sw_show);
                               end;
                               EditLen := GetDlgItemText(DlgWin, CM_EDIT1, ExtPath, fsMaxPath);
                               ExtPath[ EditLen ] := #0;
                               removedirtail(extpath); //## cut a final \
                               IF ExtPath = '' THEN
                               BEGIN
                                  GetCurrentDirectory(fsMaxPath, ExtPath);
                                  SendMessage(GetDlgItem(DlgWin, CM_EDIT1), WM_SETTEXT, 0, LONGINT(@ExtPath));
                               END;
                               ProcessArchive(DlgWin,cm_list, FALSE);

                               //## processresult is set in processarchive, if true (all files have been extracted)
                               //   execute the command line (if any) and close the dialog
                               if processresult then begin
                                  executecmd(SendMessage(GetDlgItem(DlgWin, CM_runapp), BM_getCHECK, 0, 0));
                                  enddialog(dlgwin,idok);
                               end;

                               if autorun 
                               then 
                                   SendMessage(DlgWin,  WM_COMMAND, CM_CANCEL, 0);

                            END;
                            CM_CANCEL : BEGIN
                               EditLen := GetDlgItemText(DlgWin, CM_EDIT1, ExtPath, fsMaxPath);
                               Extpath[ EditLen ] := #0;
                               IF FileExists(ExtPath) THEN
                                  SetCurrentDirectory(ExtPath);
                               EndDialog(DlgWin, LOWORD(DlgWParam));
                               EXIT;
                            END;
                         ELSE      ;
                         END (* CASE *);
         ELSE          ;
     END (* CASE *);
     RESULT := FALSE;
END   (* MainDialogProc *);
(*--------------------------------------------------------------------------*)
END.
