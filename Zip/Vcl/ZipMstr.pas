Unit ZipMstr;
(* TZipMaster VCL by Chris Vleghert and Eric W. Engler v1.52k  May 21, 1999.
   e-mail: cvleghrt@WorldOnline.nl
   www:    http://www.geocities.com/SiliconValley/Orchard/8607/ or
   www:    http://members.tripod.lycos.nl/Vleghert/
   or
   e-mail: englere@swcp.com
   www:    http://www.geocities.com/SiliconValley/Network/2114/
   www:    http://members.tripod.com/englere/

  Changes in v1.52k:
   -Fixed a bug in the ZipDll that prevented the use of the Add option AddForceDOS.
   -Fixed a bug in the ZipDll that prevented the use of the Add option AddZipTime.
   -Fixed a bug in the SFX source code, re-compilation always resulted in the message
    Error reading Archive File. Found thanks to Patrick Gentemann.
   -Added a new Read Only property VersionInfo.
   -Fixed the message: 'Error reading ZipMaster1.AddStoresSuffixes: Property does not exist.'
    when opening some demo projects.
   -Moved the assignment of the FErrCode and FMessage one line up in the function ShowExceptionError
    This way the property ErrCode can be used inside the OnMessage event handling. (The parameter
    ErrCode in this event is sometimes 0 while ErrCode is not.)

  Changes in v1.52j:
   -Changed StrPCopy functions to StrPLCopy because of a bug in BCB1, Delphi2 and
    Delphi3 in these environments max. 255 characters are copied, reported by Tim Borman.
   -Added a line to WriteSpan to correctly read and write an existing archive comment.
    Found by Tim Borman.

  Changes in v1.52i:
   -Bug fix in List, ReadSpan to read to correct data when a disk change was neccessary.
    This prevented to open and read a spanned archive which had it's header data split
    across multiple disk(files). Found thanks to Alexander Hofmann.
   -Moved FreeLibrary which wasn't always called in DiskFreeAndSize.
   -Added a SetErrorMode because it wasn't always reset in IsDiskPresent.
   -Changed the function DirExists a little in case the given dir was an empty string. [Range error]
   -Added some properties to the SortGrid VC and as result removed some code from the demos.
   -A new constant UNZIPVERSION 160, now Zip and Unzip dll may have different version numbers.

  Bug Fixes in v1.52h:
   -In the function CheckForDisk in a format specifier '/n...' was used in stead of #13#10.
    thanks to Greg Nixon.
   -In the function WriteSplit a statement was missing that incremented the disk to use.
    This was most likely to happen when zipping to a large spanned archive, but also smaller
    archives could suffer from this this problem.
    thanks to Jim Hoops, Alexander Hofmann.

   Bug Fixes in v1.52g:
   -Small addition to IsRightDisk function to make it possible to open files with UNC prefix.
    (this should have been there in the e version but somehow it did not.)
   -Fixed a memory leak in CheckIfLastDisk thanks to Greg Lorriman.

   Version f Added Russian language support

   Bug Fix and change in v1.52e:
   -Better support for harddisks > 2Gb and UNC names.
    (Replacement function for DiskFree and DiskSize functions this also
     prevented opening files given with an UNC name.)

   Bug Fixes in v1.52d:
   -Reading of spanned disks written by WinZip did not work.

   Bug Fixes in v1.52c:
   -The messages DS_NotaDrive and DS_DriveNoMount expects a string as
    parameter but did in fact get an Integer and as result you would get
    a message: UnKnown error in function ReadSpan() or WriteSpan()
    Now there is an new exception constructor for these messages.
    Found by Tim Borman
   -When there was no disk in the drive no question was asked to put
    one in, instead an exception was raised an the spanning was aborted.
    Found by Tim Borman
   -If the size of the disk is not yet known there was still a question
    to put disk X of Y in the drive. Now this is changed in just Disk X.
    Not really a bug but annoying, Found by Tim Borman
    (Not translated yet)
   -The copy stage of the diskspan process is now a little faster.
    Thanks to Tim Borman
   -The function DiskSize returns in D4 an Int64 instead of an Integer.
    found by Sebastian Hildebrandt

   Bug Fix in v1.52b:
   -While using DiskSpan in encrypted mode an error 'A Local Header
    Signature is wrong' or 'A Central Header Signature is wrong' was given.
    Found by Sam Chan.

   Bug Fixes in v1.52a:
   -Changed the search direction for the EOC record.
    (If there was a zip file stored in a ziparchive within the last 64K
     the wrong archive directory was shown.)
   -Diskspanning with formatting with ConfirmErase = True did not work.

   Changed after Beta3
   - Changed Try Finally in Try Except in the Dll load procedures
     This could cause an exception when the dll's were not found in
     Demo1 and Demo 6.
   - Application.ProcessMessages() in the callback.
   - Formatting done differently because in W'98 an application could
     hang when an other task was started (Bug reported by Teus de Jong
     and Raymond Allan).
   - Demos 1 and 6 statusbar changed a little.
   - Demo6 changed ReadBttnClick; two backslashes were removed.
   - Added fNoRecurseFiles to the ZipParms1 and ZipParms2 record.
   - Removed the 4096 filespecification limit for Extract (and Test) method.
     (Also changed UnzDll.dll now version 1.52)
   - Added a check, in EraseFile(), if the file we want to delete is present
     on disk, SHFileOperation complains if a file does not exists while
     DeleteFile as used before did not.
     This was a problem in ReadSpan(), bug reported by Raymond Allan.

   Changed after Beta2
     Improvements suggested by: Teus de Jong (teusjdejong@wxs.nl)
   - In ConvertZip, ConvertSFX, CopyFile and ReadSpan the old files are no
     longer automaticly deleted. By using the new property HowToDelete its
     possible to choose: htdFinal or htdAllowUndo.
   - Above change lead to a new function which is also made public:
     EraseFile( FileName: String; How: DeleteOpts ): Integer;
   - A special check is made for WinZip self extracting files because they contain
     almost always garbage after the EOC record. This caused a 'very annoying'
     message and although technical speaking it was right, no message is given
     anymore.
   - Small name change of two members in ZipDirEntry record.

   *****************************************************************************
   Changed after Beta1 release 150.

   - During ReadSpan() and WriteSpan() there were still forward slashes showing.
   - ReadSpan() and WriteSpan() were declared private, now public.
   - New record passing to the ZipDll if version >= 151 needed to implement
     TempDir.
   - Changed ZipDll.dll version 151 to accommodate the TempDir property.
     Also prepared for future expansion.
   - Improved error handling in UnzDll.dll version 151.

   Bugs found and improvements suggested by:
     Teus de Jong (teusjdejong@wxs.nl)
   - DeleteSpanMem() caused, in some cases, an Access Violation, this
     occured before MDZD was created in ReadSpan and WriteSpan.
   - New property IsSpanned to indicate if an opened archive is a spanned one.
   - If there was an error in ReadSpan() the output file, that was not complete
     at that moment, was not deleted.
   - In ConvertSFX() and ConvertZip() the In-Out file size check changed in case
     there is garbage at the end of the file.

   Added some extra members to the ZipDirEntry record on request from:
    Almer.S. Tigelaar (almer-t@usa.net)
     . MadeByVersion
     . HostVersionNo
     . FileCommentLen
     . StartOnDisk
     . IntFileAttrib
     . ExtFileAttrib
     . RelOffLocalHdr

   *****************************************************************************

   The changes for this version were mostly done by Chris Vleghert
   (cvleghrt@worldonline.nl). Chris has doubled the size and scope of
   this project. In the past Chris did the BCB port, but now he is
   expanding and may take over the whole project soon!
   This is great news for most of us, because I simply don't have
   time to keep adding new features.


                         General Info About Codepages
                         ----------------------------
      Many programmers don't understand codepages.  These are basically
      just a character set.  The standard MS-DOS character set used
      codepage 850, which is called the "OEM" codepage.  I think Windows
      3.1 used this codepage also.  Most Windows 95 and Windows NT systems
      use codepage 1252, which is for America and Western Europe.  This one
      is called "ISO 8859-1, Latin 1", which I will call "ISO".  There are
      other ISO codepages, but I want to limit this discussion to 8859-1.

      Both the ISO and OEM codepages support the common accented charaters
      used in Western Europe.  However, the exact codes used for specific
      characters are differant.  Each of these also has some unique
      characters in the range $80-$9f.  We would like to be able to convert
      the accented character codes in the filenames when we extract them
      from a zip file.

      In these two codepages, ISO and OEM, the bottom 128 codes are the
      same.  Only the upper 128 codes are different.  These upper codes
      are used for accented characters, and box-drawing symbols, etc.
      Most ZIP files use only the lower 128 codes in their filenames, so
      the codepage used (of the two we support) is irrelevant.  It is only
      important when the non-English accented characters (or other upper
      codes) are used in filenames.

      Each zip file header includes an indicator of which Operating System
      (OS) was used when it was created.  We assume that the current OS is
      Win 95/98/NT using codepage 1252.  If the zip file was made on MS-DOS
      or Win 3.1 (codepage 850), then we can translate it so the extracted
      filenames will appear correctly.  Note that this conversion is not
      100% accurate because each of these character sets has some unique
      symbols.

      This is not an ideal world, though, and many zip files do not
      correctly identify which OS was used to make them.  And, even if we
      know the OS it was made on, they may not have used codepage 850,
      and we may not be using codepage 1252 right now!  So, I allow 4
      different settings of the CodePage property so you can have full
      control over conversions.

      In this release, you do not have the ability to convert text files
      made with one codepage to another codepage.  At this time, you can
      only convert filenames and zip file comments.

      What about the other codepages: Korean, Japanese, Hebrew, etc?
      I don't know any way of translating those codes to codepage 1252,
      because most of their characters do not exist in codepage 1252.
      However, if you are using the Korean codepage, and the people
      you give your zip files to are also using the Korean codepage,
      then no translation is necessary!  If you want to make a zip file
      for use by people in other countries, then you should make it
      using codepage 1252.
      ----------------------------------------------------------------

   Quick summary of changes in version 1.50:

   New properties:
      CodePage: values are cpAuto, cpNone or cpOEM.  This
             determines what character set translation to perform.
             This only affects extraction, and directory listing.
             The items that are translated: filenames/paths, and
             zip file comments.  Contents of files inside the zip
             archive can NOT be converted in this release.
         cpAuto - Attempt to determine automatically when a conversion
                  is needed between codepages 850 and 1252, and do it.
                  This option has proven to be unreliable in some
                  cases, so be careful!. The problem archives were
                  made by Norton Zip, which does not create the zip
                  file header correctly. This is the default.
         cpNone - do not make any conversions. This means we use the
                  local ISO code page to display regardless of how
                  it is stored in the zip file.
         cpOEM  - force OEM to ISO translation.

      New options for AddOptions:
         AddSeparateDirs - if set, add separate entries to the zip archive
              that will hold the name of each directory (no data for these
              entries).  To use this, you must also have AddZipDirs set.

         AddDiskSpan - if set, create a disk-spanning archive if there
              is not enough disk space on the specified drive

         AddDiskSpanErase - if set, create a disk-spanning archive if there
              is not enough disk space on the specified drive.  This option
              pops up a "format disk" dialog every time the user is prompted
              for the next disk (including the first disk).  Of course,
              this option can NOT be used on non-removable drives (user
              will get an error msg if he tries to use this option on a non-
              removable hard drive).

         NOTE: If AdddiskSpan or AddDiskSpanErase is set, you can NOT
            also use AddFreshen or AddUpdate, and you can not create an
            .EXE (SFX Self-extracting) archive. Also, you can not use
            "Unattended" mode to make disk-spanning archives.

     The following properties support disk-spanning:

      TempDir:  name of a temporary directory (full path).  This is
         optional.  If you don't set this, the Windows temp dir will be used.

      KeepFreeOnDisk1:  how many bytes you want left free on the first
         disk.  This gives you room for a setup/install program.

      MaxVolumeSize:  how much of each disk we can use.  If 0, then
         we will use as much as we can of each disk.

      MinFreeVolumeSize:  do not use a disk unless it has at least this
         many bytes free when we start.

      ConfirmErase:  true if you want us to warn the user before we
         erase (format) a disk.

         Due to our new support for disk-spanning, we had to change the way
      zip file directories are read.  In the past, we have used the local
      directory entries, but now we use the central directory entries.  For
      a set of disks, the central directory is usually on the last disk in
      the set.  One problem with doing business this way, is that we can't
      extract or list ANY files of a damaged archive.
         If you have a damaged archive, you can try to fix it with
      PKZIPFIX.EXE (one of the programs that comes with the MS-DOS PKZIP
      release).  We may write a program similar to this in the future.  The
      basic idea is to rebuild the central directory with info from the
      local directory entries.
         One good side-effect of using the central directory is speed. We
      can now read a zip file's contents very quickly.

      This release also lets you read the main zip file comments, and the
      comments for individual file entries.  However, these comments can
      only be read - you can not create zip comments with v1.50.

      These new read-only runtime properties tell you about the zip file.
      These are valid after a zip file's contents have been read (which
      happens when you assign something to ZipFilename).
        ZipFileSize: size of entire Zip file (if spanning, then size of
                     the last chunk)
        SFXOffset: size of the Self-extracting code at the beginning (only
                   used for non-spanning archives)
        ZipSOC:  Start-Of-Central-Dir location
        ZipEOC:  End-Of-Central-Dir location
        ZipComment: The text comment for this zip file. Up to 64K in size.

      If individual files have comments, you can read them from the ZipDirEntry
      record when you examine the zip directory.

   Two new action codes have been added to the Progress Event.  use the
   values you get from these callbacks instead of the GetTotalFileSize
   method introduced in v1.45.  These values are calculated in the DLLs,
   and they should be more accurate than the GetTotalFileSize method.
      TotalFiles2Process - the "FileSize" arg tells you how many files will be
         processed by this operation
      TotalSize2Process  - the "FileSize" arg tells you the total size of all
         files to be processed by this operation

   New SFX changes for this release:
    - copyright info is now hidden under the "About" button
    - the "Shell Browse for Folder" API is used to select a directory
    - a new SFXOption is SFXCheckSize.  By default this is on.  When on,
      the SFX code will do a quick Self-test before expanding the files.
      This detects the most common problem - where your .exe file has been
      cut short by an aborted download.

    NOTE: The SFX module has to be limited in size, and so we did NOT
    add support for disk-spanning to it.  You can, however, write your
    own setup program to re-assemble the pieces.  I recommend putting
    the files for disk1 into an SFX .EXE, and have it run your setup
    program after expanding those files on the user's hard drive.  Your
    setup program can then read the remaining disks.

   Also new in v1.50: we convert forward slashes in filenames to backslashes.
   We used to show you forward slashes because that's what Phil Katz (the
   inventor of pkzip) did, but we now show you the right slashes! Sorry
   Phil!


    There is a new requirement for programs that you write.  We have
    put most of our error messages put into a resource file.  You
    need to add the desired resource file to your project file.
    Simply add a line like this to your project file:

       {$R ZipMsgUS.res}

    You can see how this was done by checking Demo1's .DPR file.
    These are the languages we support at this time:

       ZipMsgBR.res - Brazilian (Portuguese)
       ZipMsgCZ.res - Czech
       ZipMsgNL.res - Dutch
       ZipMsgFR.res - French
       ZipMsgUS.res - English / US
       ZipMsgDE.res - German
       ZipMsgGR.res - Greek
       ZipMsgIT.res - Italian
       ZipMsgPL.res - Polish
       ZipMsgYU.res - Serbian (Yugoslavia)
       ZipMsgSP.res - Spanish
       ZipMsgTW.res - Taiwanese/Traditional Chinese
       ZipMsgRU.res - Russian
       ZipMsgCN.res - Chinese

    If you would like to port these error messages to another
    language, please e-mail me right away!


   ----------------------------------------------------------------------
   Quick summary of changes in version 1.45:
   bug fixes:
      Correct the bug in DateTime setting of CopyFile method
      Correct misc bugs in the SFX code

   new BCB features:
      Update BCB support to work with BCB v3

   new Delphi features:
      Add new "Unattended" property - all errors go to OnMessage error handler
         if this property is set True
      A new Error code list is being distributed with this release (helpful
         if you want to use the Unattended property)
      Add new ability to create an .EXE file directly
      Add a new demo program (demo5) to demo creation of an .EXE file
      Add function "GetTotalFileSize" to let you determine how big
         all the files are before starting a zip operation
      Update Demo1 to show 2 progress bars in Add: one "overall progress"
         and one "per file progress"

   ----------------------------------------------------------------------

   Quick summary of changes in version 1.40:
   bug fixes:
       Correct filenames are now given in the "skipping encrypted file..."
         error messages.  Thanks to: Markus Stephany, mirbir.st@saargate.de

       The SFX module now extracts more than 1 passworded file in an
         archive.   Thanks to: Markus Stephany, mirbir.st@saargate.de

       Correct progress events now generated for extraction of
         uncompressed files.  Thanks to: Esa Raita, eza@netlife.fi

   DLLDirectory property - allows manual specification of the dir
       used to hold ZIPDLL.DLL and UNZDLL.DLL.  Should NOT end
       in a slash.  This is an optional property. if used, it overrides
       the Windows search path for DLLs.  If you specify a dirname
       here, but the DLLs are not actually in that dir, then the
       std Windows search path will be consulted.
          The idea for this came from Thomas Hensle, thensle@t-online.de.

   In case SFXPath isn't set, DLLDirectory will also be consulted
   when trying to locate ZIPSFX.BIN.  Here's the order that will
   be used to locate ZIPSFX.BIN:
         1) location given by the SFXPath property
         2) the current directory
         3) the application directory (location of current .EXE file)
         4) the Windows System directory (where DLLs go)}
         5) the Windows directory (where DLLs go)
         6) location given by the DLLDirectory property

   These are the advanced options for creating more powerful Self-Extracting
   archives.  By using these options, you can turn the new .EXE archive into
   a small Self-contained setup program!

   The following three boolean options are set members of SFXOptions:

   SFXAskCmdLine     boolean   (only matters if a cmd line is present)
        If yes, allows user to de-select the command line checkbox.
        Once deselected, the command line will not be run.
        NOTE: The checkbox doesn't appear unless there is a command line
        specified.

   SFXAskFiles       boolean   (if yes, lets user modify list of files
        to be extracted)

   SFXHideOverWriteBox   boolean  (if yes, does NOT show the user the
        dialog box that lets him choose the overwrite action at runtime for
        files that already exist)

   SFXOverWriteMode  enum     dflt=ovrConfirm  (others: ovrAlways, ovrNever)
        This is the dflt overwrite option (if SFXHideOverWriteBox is true, then
        this option will be used during extraction)

   SFXCaption        String   dflt='Self-extracting Archive'
        Caption of the SFX dialog box at runtime.

   SFXDefaultDir     String   dflt=''
        Default target dir for extraction.  Can be changed at runtime.
        If you don't specify this, the user's current directory will
        be the default.

   SFXCommandLine    String   dflt=''
        This command line will be executed immediately after extracting the
        files.  Typically used to view the readme file, but can do anything.
        There is a predefined symbol that can be used in the command line
        to tell you which target directory was actually used.
        Special symbols: | is the command/arg separater
                        >< is the actual extraction dir selected by user
        Example:
           notepad.exe|><readme.txt
        Run notepad to show "readme.txt" in the actual extraction dir.

  ------------------------------------------------------------------------

   TZipMaster is a non-visual VCL wrapper for my freeware ZIP and
   UNZIP DLLs.  At run time, the DLL's: ZIPDLL.DLL and UNZDLL.DLL must
   be present on the hard disk - in C:\WINDOWS\SYSTEM or else in your
   application directory, or a directory in the PATH.

   These DLLs are based on the InfoZip Official Freeware Zip/Unzip
   source code, but they are NOT equivalent to InfoZip's DLLs.
   I have modified the InfoZip source code to enhance their
   ease-of-use, power, and flexibility for use with Delphi and
   C++ Builder.  Please do NOT contact InfoZip for issues
   regarding this port.

   To obtain the official InfoZip source code, consult their
   Web site:
               http://www.cdrom.com/pub/infozip/

   The six main methods that can be invoked are:
       Add      - add one or more files to a ZIP archive
       Delete   - delete one or more files from ZIP archive
       Extract  - expand one or more files from a ZIP archive
       List     - transfer "table of contents" of ZIP archive
                  to a StringList

       CopyFile - copies a file

       GetAddPassword  - prompt user for a password - does verify
       GetExtrPassword - prompt user for a password - does NOT verify

   NOTE: "Test" is a sub-option of Extract

   All of the methods above will work on regular .ZIP files, and
   on Self-extracting ZIP archives having a file extension of .EXE.

   Various properties exist to control the actions of the methods.

   Filespecs are specified in the FSpecArgs TStringList property, so you
   can easily combine many different filespecs into one Add, Delete, or
   Extract operation. For example:

      1. Add entries directly to the FSpecArgs property:
          ZipMaster1.FSpecArgs.Add( 'C:\AUTOEXEC.BAT' );
          ZipMaster1.FSpecArgs.Add( 'C:\DELPHI\BIN\DELPHI.EXE' );
          ZipMaster1.FSpecArgs.Add( 'C:\WINDOWS\*.INI' );
          ZipMaster1.FSpecArgs.Add( 'SYSTEM\*.DLL' );

      2. Take the filespecs from a StringList, just assign them all over
         to ZipMaster1.
       ZipMaster1.FSpecArgs.Assign(StringList1);

      3. Take the filespecs from a ListBox, just assign them all over
         to ZipMaster1.
       ZipMaster1.FSpecArgs.Assign(ListBox1.Items);

   You can specify either the MS-DOS backslash path symbol, or the one
   normally used by PKZIP (the Unix path separator: /).  They are treated
   exactly the same.

   All of your FSpecArgs accept MS-DOS wildcards.

   Add, Delete, and Extract are the only methods that use FSpecArgs.
   The List method doesn't - it just lists all files.


   Following is a list of all TZipMaster properties, events and methods:

   Properties
   ==========
     Verbose      Boolean     If True, ask for the maximum amount of "possibly
                              important" information from the DLLs.  The
                              informational messages are delivered to your
                              program via the OnMessage event, and the ErrCode
                              and Message properties. This is primarily used
                              to determine how much info you want to show your
                              "end-users" - developers can use the Trace
                              property to get additional infomation.

     Trace        Boolean     Similar to Verbose, except that this one is
                              aimed at developers.  It lets you trace the
                              execution of the C code in the DLLs.  Helps
                              you locate possible bugs in the DLLs, and
                              helps you understand why something is happening
                              a certain way.

     ErrCode      Integer     Holds a copy of the last error code sent to
                              your program by from DLL. 0=no error.
                              See the OnMessage event.  Most messages from
                              the DLLs will have an ErrCode of 0.

     Message      String      Holds a copy of the last message sent to your
                              program by the DLL.  See the OnMessage event.

     ZipContents  TList       Read-only TList that contains the directory
                              of the archive specified in the ZipFilename
                              property. Every entry in the list points to
                              a ZipDirEntry record.  This is automatically
                              filled with data whenever an assignment is
                              made to ZipFilename, and can be manually
                              filled by calling the List method.
                                 For your convenience, this VCL hides the
                              TList memory allocation issues from you.
                                 Automatic updates to this list occur
                              whenever this VCL changes the ZIP file.
                              Event OnDirUpdate is triggered for you
                              each time this list is updated - that is
                              your queue to refresh your directory display.

   ---------------------------------------------------------------------
   Each entry in the ZipContents TList is a ZipDirEntry record:

   ZipDirEntry = packed Record
     MadeByVersion               : Byte;
     HostVersionNo               : Byte;
     Version                     : WORD;
     Flag                        : WORD;
     CompressionMethod           : WORD;
     DateTime                    : Integer; { Time: Word; Date: Word; }
     CRC32                       : Integer;
     CompressedSize              : Integer;
     UncompressedSize            : Integer;
     FileNameLength              : WORD;
     ExtraFieldLength            : WORD;
     FileCommentLen              : Word;
     StartOnDisk                 : Word;
     IntFileAttrib               : Word;
     ExtFileAttrib               : LongWord;
     RelOffLocalHdr              : LongWord;
     FileName                    : String; // variable size
     FileComment                 : String; // variable size
   end;

   To get compression ratio:
   (code from Almer Tigelaar)
   var
      ratio: Integer;
   begin
      with ZipDirEntry1 do
         ratio:=Round((1-(CompressedSize/UnCompressedSize))*100);
   ---------------------------------------------------------------------

     Cancel       Boolean     If you set this to True, it will abort any
                              Add or Extract processing now underway.  There
                              may be a slight delay before the abort will
                              take place.  Note that a ZIP file can be
                              corrupted if an Add operation is aborted.

     ZipBusy      Boolean     If True, a ZIP operation is underway - you
                              must delay your next Add/Delete operation
                              until this is False.  You won't need to be
                              concerned about this in most applications.
                              This can be used to syncronize Zip operations
                              in a multi-threaded program.

     UnzBusy      Boolean     If True, an UNZIP operation is underway -
                              you must delay your next Extract operation
                              until this is False.  You won't need to be
                              concerned about this in most applications.
                              This can be used to syncronize UnZip
                              operations in a multi-threaded program.

     AddCompLevel Integer     Compression Level.  Range 0 - 9, where 9
                              is the tightest compression.  2 or 3 is a
                              good trade-off if you need more speed. Level 0
                              will just store files without compression.
                              I recommend leaving this at 9 in most cases.

     AddOptions   Set         This property is used to modify the default
                              action of the Add method.  This is a SET of
                              options.  If you want an option to be True,
                              you need to add it to the set.  This is
                              consistant with the way Delphi deals with
                              "options" properties in general.

        AddDirNames           If True, saves the pathname with each fname.
                              Drive IDs are never stored in ZIP file
                              directories. NOTE: the root directory name is
                              never stored in a pathname; in other words,
                              the first character of a pathname stored in
                              the zip file's directory will never be a slash.

        AddForceDOS           If True, force all filenames that go into
                              the ZIP file to meet the DOS 8x3 restriction.
                              If false, long filenames are supported.
                              WARNING: name conflicts can occur if 2 long
                              filenames reduce to the same 8x3 filename!

        AddZipTime            If True, set ZIP timestamp to that of the newest
                              file in the archive.

        AddRecurseDirs        If True, subdirectories below EACH given fspec
                              will be included in the fspec. Defaults to False.
                              This is potentially dangerous if the user does
                              this from the root directory (his hard drive
                              may fill up with a huge zip file)!

        AddHiddenFiles        If True, files with their Hidden or System
                              attributes set will be included in the Add
                              operation.

        AddEncrypt            If True, add the files with standard zip
                              encryption.  You will be prompted for the
                              password to use.

        NOTE: You can not have more than one of the following three options
              set to "True".  If all three are False, then you get a standard
              "add": all files in the fspecs will be added to the archive
              regardless of their date/time stamp.  This is also the default.

        AddMove               If True, after adding to archive, delete orig
                              file.  Potentially dangerous.  Use with caution!

        NOTE: Freshen and Update can only work on pre-existing archives. Update
        can add new files to the archive, but can't create a new archive.

        AddFreshen            If True, add newer files to archive (only for
                              files that are already in the archive).

        AddUpdate             If True, add newer files to archive (but, any
                              file in an fspec that isn't already in the
                              archive will also be added).

     ExtrBaseDir  String      This base directory applies only to "Extract"
                              operations.  The UNZIP DLL will "CD" to this
                              directory before extracting any files. If you
                              don't specify a value for this property, then the
                              directory of the ZipFile itself will be the
                              base directory for extractions.

     ExtrOptions  Set         This property is used to modify the default
                              action of the Extract method.  This is a SET
                              of options.  If you want an option to be
                              True, you need to add it to the set.

        ExtrDirNames          If True, extracts and recreates the relative
                              pathname that may have been stored with each file.
                              Empty dirs stored in the archive (if any) will
                              also be recreated.

        ExtrOverWrite         If True, overwrite any pre-existing files during
                              Extraction.

        ExtrFreshen           If True, extract newer files from archive (only
                              for files that already exist).  Won't extract
                              any file that isn't already present.

        ExtrUpdate            If True, extract newer files from archive (but,
                              also extract files that don't already exist).
                              IMPORTANT! You must also set ExtrOverWrite if
                              you use this.

        ExtrTest              If True, only test the archive to see if the
                              files could be sucessfully extracted.  This is
                              done by extracting the files, but NOT saving the
                              extracted data.  Only the CRC code of the files
                              is used to determine if they are stored correctly.
                              To use this option, you will also need to define
                              an Event handler for OnMessage.
                                 IMPORTANT: In this release, you must test all
                              files - not just some of them.

     NOTE: there is no decryption property for extraction.
     If an encrypted file is encountered, the user will be
     automatically prompted for a password.

     FSpecArgs    TStrings    Stringlist containing all the filespecs used
                              as arguments for Add, Delete, or Extract
                              methods. Every entry can contain MS-DOS wildcards.
                              If you give filenames without pathnames, or if
                              you use relative pathnames with filenames, then
                              the base drive/directory is assumed to be that
                              of the Zipfile.

     ZipFilename  String      Pathname of a ZIP archive file.  If the file
                              doesn't already exist, you will only be able to
                              use the Add method.  I recommend using a fully
                              qualified pathname in this property, unless
                              your program can always ensure that a known
                              directory will be the "current" directory.

     Count        Integer     Number of files now in the Zip file.  Updated
                              automatically, or manually via the List method.

     SuccessCnt   Integer     Number of files that were successfully
                              operated on (within the current ZIP file).
                              You can read this after every Add, Delete, and
                              Extract operation.

     ZipVers      Integer     The version number of the ZIPDLL.DLL.  For
                              example, 140 = version 1.40.

     UnzVers      Integer     The version number of the UNZDLL.DLL.  For
                              example, 140 = version 1.40.

     Password     String      The user's encryption/decryption password.
                              This property is not needed if you want to
                              let the DLLs prompt the user for a password.
                              This is only used if you want to prompt the
                              user yourself.
                                 WARNING! If you set the password in the
                              Object Inspector, and you never change the
                              password property at runtime, then your
                              users will never be able to use any other
                              password.  If you leave it blank, the DLLs
                              will prompt users each time a password is
                              needed.

     DLLDirectory String      Allows manual specification of the directory
                              used to hold ZIPDLL.DLL and UNZDLL.DLL.  Should
                              NOT end in a slash.  This is an optional
                              property. If used, it overrides the Windows
                              search path for DLLs.  If you specify a dirname
                              here, but the DLLs are not actually in that dir,
                              then the standard Windows search path will be
                              consulted, anyway.

     SFXPath      String      Points to the ZIPSFX.BIN file.  Must include
                              the whole pathname, filename, and extension.
                              This is only used by the ConvertSFX method.
                              As a convenience for you, ZipMaster will
                              look in the Windows dir, and in the Windows
                              System dir for this file, in case you don't
                              want to use this property.

     SFXOverWriteMode  enum   This is the default overwrite option for what
                              the SFX program is supposed to do if it finds
                              files that already exist.  If option
                              "SFXHideOverWriteBox" is true, then this option
                              will be used during extraction.
                                 These are the possible values for this
                              property:
                                ovrConfirm - ask user when each file is found
                                ovrAlways - always overwrite existing files
                                ovrNever - never overwrite - skip those files
                              The default is "ovrConfirm".

     SFXCaption      String   The caption of the SFX program's dialog box at
                              runtime. The default is 'Self-extracting Archive'.

     SFXDefaultDir   String   The default target directory for extraction of
                              files at runtime.  This can be changed at
                              runtime through the dialog box. If you don't
                              specify a value for this optional property, the
                              user's current directory will be the default.

     SFXCommandLine  String   This command line will be executed immediately
                              after extracting the files.  Typically used to
                              show the the readme file, but can do anything.
                              There is a predefined symbol that can be used
                              in the command line to tell you which target
                              directory was actually used (since the user can
                              always change your default).
                              Special symbols: "|" is the command/arg separator,
                              "><" is the actual extraction dir selected by user
                              Example:
                                  notepad.exe|><readme.txt
                              Run notepad to show "readme.txt" in the actual
                              extraction directory.
                                This is an optional property.

     SFXOptions   Set         This property is used to modify the default
                              action of the ConvertSFX method.  This is a
                              SET of options.  If you want an option to be
                              True, you need to add it to the set.  This is
                              consistant with the way Delphi deals with
                              "options" properties in general.

        SFXAskCmdLine         If true, allows user (at runtime) to de-select
                              the SFX program's command line checkbox. Once
                              de-selected, the command line will not be run.
                              NOTE: The checkbox doesn't appear unless there
                              is a command line specified.

        SFXAskFiles           If true, lets user (at runtime) modify the
                              SFX program's list of files to be extracted.

        SFXHideOverWriteBox   If true, does NOT show the user (at runtime)
                              the SFX program's dialog box that lets him
                              choose the overwrite action for files that
                              already exist.

        SFXCheckSize          If true, check to make sure this archive was
                              not "cut short" before trying to expand the
                              files.


   Events
   ======
     OnDirUpdate              Occurs immed. after this VCL refreshes it's
                              TZipContents TList.  This is your queue to
                              update the screen with the new contents.

     OnProgress               Occurs during compression and decompression.
                              Intended for "status bar" or "progress bar"
                              updates.  Criteria for this event:
                                - starting to process a new file (gives you
                                    the filename and total uncompressed
                                    filesize)
                                - every 32K bytes while processing
                                - completed processing on a batch of files
                              See Demo1 to learn how to use this event.

     OnMessage                Occurs when the DLL sends your program a message.
                              The Message argument passed by this event will
                              contain the message. If an error code
                              accompanies the message, it will be in the
                              ErrCode argument.
                                 The Verbose and Trace properties have a
                              direct influence on how many OnMessage events
                              you'll get.
                                 See Also: Message and ErrCode properties.

   Methods
   =======
     Add                      Adds all files specified in the FSpecArgs
                              property into the archive specified by the
                              ZipFilename property.
                                Files that are already compressed will not be
                              compressed again, but will be stored "as is" in
                              the archive. This applies to .GIF, .ZIP, .LZH,
                              etc. files. Note that .JPG files WILL be
                              compressed, since they can still be squeezed
                              down in size by a notable margin.

     Extract                  Extracts all files specified in the FSpecArgs
                              property from the archive specified by the
                              ZipFilename property. If you don't specify
                              any FSpecArgs, then all files will be extracted.
                              Can also test the integrity of files in an
                              archive.
                                If you set the ExtrTest option of ExtrOptions,
                              then ALL files in the arive will be tested.
                              This will cause them to be extracted, but not
                              saved to the hard disk.  Their CRC will be
                              verified, and results will go to the SuccessCnt
                              property, and the OnMessage event handler.

     Delete                   Deletes all files specified in the FSpecArgs
                              property from the archive specified by the
                              ZipFilename property.

     List                     Refreshes the contents of the archive into
                              the ZipContents TList property.  This is
                              a manual "refresh" of the "Table of Contents".

     CopyFile                 This copies any file to any other file.
                              Useful in many application programs, so
                              it was included here as a method.  This returns
                              0 on success, or else one of these errors:
                                  -1   error in open of outfile
                                  -2   read or write error during copy
                                  -3   error in open of infile
                                  -4   error setting date/time of outfile
                                  -9   general failure during copy
                              Can be used to make a backup copy of the
                              ZipFile before an Add operation.
                              Sample Usage:
                                with ZipMaster1 do
                                begin
                                   ret = CopyFile( ZipFilename, 'C:\TMP$$.ZIP' );
                                   if ret < 0 then
                                      ShowMessage( 'Error making backup' );
                                end;

     NOTE: A -4 error is non-fatal.  The copied file will still be correct,
     except that the datetime stamp will be wrong.

     IMPORTANT note regarding CopyFile: The destination must include
     a filename (you can't copy fname.txt to C:\).  Also, Wildcards are
     not allowed in either source or dest.

     ------------------------------------------------------------------------

     Encrypted Archive Support

     Thanks to Mike Wilkey <mtw@allways.net> for his very useful source
     code and helpful comments.  He basically got this functionality
     working by himself.  I just plugged in his Result to TZipMaster.
     The source for the actual encryption algorithm is the overseas link
     pointed-to by InfoZip.  I have learned that this is NOT being controlled
     by the US government, so I am including it with this release.

     GetAddPassword           Prompt user for a password.  The password
                              will be accepted twice - the second time to
                              verify it.  If both of them match, it will
                              be saved in the Password property, or else
                              the Password property will be cleared.
                                The use of this method is not required.
                              If you want to make your own password prompt
                              dialog box, you can just put the password
                              into the password property yourself.  Also,
                              you can take the easiest route by leaving the
                              password property blank, and letting the
                              DLLs prompt the user for the password.

     GetExtrPassword          Prompt user for a password.  The password
                              will only be accepted once. It will be
                              saved in the Password property.
                                The use of this method is not required.
                              If you want to make your own password prompt
                              dialog box, you can just put the password
                              into the password property yourself.  Also,
                              you can take the easiest route by leaving the
                              password property blank, and letting the
                              DLLs prompt the user for the password.


     IMPORTANT notes about Password:

     - The "GetAddPassword" and "GetExtrPassword" methods are optional.
       You have 3 different ways of getting a user's password:

        1) Call the "GetAddPassword" and/or the "GetExtrPassword" methods,
           just before add or extract.

        2) Use your own code to set the "Password" property.  It's your
           choice how you obtain the password.
             - This is useful if the password comes from a file or table.
             - It's also good for letting you enforce constraints on the
           password - you can require it to be over 6 chars, require it
           to have at least one special char, etc.  Of course, you'd only
           want to enforce constrainst on "Add" operations.  A word of
           caution: many users don't like password constraints, so give
           them the option to turn them off.

        3) Don't set one at all, and let the DLLs prompt the user.
           It's easy, and it works.

     - Passwords can not be longer than 80 characters.  A zero-length
       password is the same as no password at all.

     - To "zero out" the password, set it's property to an empty string.
       If it is zero'd out, but the AddEncrypt option is set, then the
       user will be prompted for a new password by the DLLs. So, if you
       don't want a password used, make sure you turn off "AddEncrypt",
       and you zero-out the password.

     - If you set a password for an Extract, but it is incorrect, then
       the DLLs will NOT prompt the user for another password.

     - If the user enters a password at an automatic prompt generated
       by the DLL, then you can NOT get access to that password from
       your program.  If you want to know what it is, you need to prompt
       for it yourself.

     - To Force the DLL to AVOID decrypting an encrypted file, you must
       set the password property to an unlikely password (all periods,
       for example).  If adding, make sure AddEncrypt is NOT set.

     -------------------------------------------------------------------------

     Self Extracting Archive Support

     Thanks to Carl Bunton for the original SFX code.  This is a very big
     undertaking, and he did a great job.  He also makes good compression
     VCLs (called ZipTV) for Delphi.  They are shareware, but his profits
     go to a children's hospital.  He supports many archive formats, not
     just ZIP.  Check out his Web site:
                    http://www.ziptv.com/

     Currently, the SFX code is being maintained by Markus Stephany.
     His e-mail address is:  mirbir.st@t-online.de

     ConvertSFX               Convert zip archive to Self-extracting .EXE.
                              The resulting .EXE is a Win32 program.
                              Uses the same base name and path already
                              used by the zipfile - only the file extension
                              is changed to .EXE. This is accompished by
                              prepending the SFX code onto the front of
                              the zip file, and then changing it's extension.

     IMPORTANT! - before using ConvertSFX, you may want to first set the
       SFXPath property to the full pathname of the SFX code: ZIPSFX.BIN.
       If you don't set this property, ZipMaster will automatically look for
       this file in the Windows and Windows System directories.

     ConvertZIP               Convert Self-extracting .EXE to .ZIP archive.
                              Converts a Self-extracting .exe file into a
                              zip archive.  This is accomplished by removing
                              the SFX code from the beginning, and then
                              changing it's extension.

     WARNING: The use of ConvertZip can NOT be guaranteed to work with
        all Self-extracting archive formats.  It will work on MS-DOS "pkzip"
        (product of pkware) Self-extracting zip archives, and on those made
        by "WinZip" (product of Nikko Mak Computing), but some Self-extracting
        formats are not even based on zip compression.
           For example, the freeware "ASetup" program uses the .LZH
        compression format.  In fact, most setup programs use compression
        formats that aren't zip compatible.
           If you try to use ConvertZip on an archive that doesn't
        conform to the zip standard, you will get errors.  If fact, you
        can't even list the contents of an .EXE archive if it's not a
        standard zip format.

   --------------------------------------------------------------------

                       DLL Loading and Unloading

   This table show you which DLL is needed for each method:
       Add        requires ZIPDLL.DLL
       Delete     requires ZIPDLL.DLL
       Extract    requires UNZDLL.DLL
       List            none (internal code in this VCL)
       CopyFile        none (internal code in this VCL)
       GetAddPassword  none (internal code in this VCL)
       GetExtrPassword none (internal code in this VCL)
       ConvertSFX      none (internal code to this VCL)
       ConvertZIP      none (internal code to this VCL)
   NOTE: "Test" is a sub-option of extract.

   The following 4 methods give you explicit control over loading and
   unloading of the DLLs.  For simplicity, you can do the loads in
   your form's OnCreate event handler, and do the unloads in your
   form's OnDestroy event handler.

      Load_Zip_Dll    --  Loads ZIPDLL.DLL, if not already loaded
      Load_Unz_Dll    --  Loads UNZDLL.DLL, if not already loaded
      Unload_Zip_Dll  --  Unloads ZIPDLL.DLL
      Unload_Unz_Dll  --  Unloads UNZDLL.DLL

   For compatibility with older programs, and because I'm a nice
   guy, I'll handle the loads and unloads automatically if your
   program doesn't do it.  This can, however, incur a perfomance
   penalty because it will reload the needed DLL for each operation.

   Advanced developers will want to carefully consider their load
   and unload strategy so they minimize the number of loads, and
   keep the DLLs out of memory when they're not needed. There is a
   traditional speed vs. memory trade-off.
  --------------------------------------------------------------------
*)

{$IFDEF VER110}  // if BCB3
   {$ObjExportAll On}
{$ENDIF}
{$IFDEF VER120}  // if Delphi4
   {$Define VERD4B4}
{$ENDIF}
{$IFDEF VER125}  // if BCB4
   {$ObjExportAll On}
   {$Define VERD4B4}
{$ENDIF}

Interface

Uses
  forms, WinTypes, WinProcs, SysUtils, Classes, Messages, Dialogs, Controls,
  ZipDLL, UnzDLL, ZCallBck, ZipMsg, ShellApi;

{$IfDef VERD4B4}  // D4B4
Type  LargeInt =  Int64;
Type pLargeInt = ^Int64;
{$Else}          // D2, D3
Type  LargeInt =  Comp;
Type pLargeInt = ^Comp;
{$EndIf}

{$IfNDef VERD4B4}  // if not Delphi 4 or BCB4
Type CWPRETSTRUCT = packed record
   lResult: LRESULT;
   lParam:  LPARAM;
   wParam:  WPARAM;
   message: DWORD;
   hwnd:    HWND;
end;
{$EndIf}

Type
  LongWord = Cardinal;

Type ZipLocalHeader = packed record
  HeaderSig          : LongWord;
  VersionNeed        : Word;
  Flag               : Word;
  ComprMethod        : Word;
  ModifTime          : Word;
  ModifDate          : Word;
  CRC32              : LongWord;
  ComprSize          : LongWord;
  UnComprSize        : LongWord;
  FileNameLen        : Word;
  ExtraLen           : Word;
end;

Type ZipDirEntry = packed record         // fixed part size = 42
  MadeByVersion      : Byte;    //(1) RCV Added
  HostVersionNo      : Byte;    //(1) RCV Added
  Version            : Word;    //(2)
  Flag               : Word;    //(2)
  CompressionMethod  : Word;    //(2)
  DateTime           : Integer; //(4) Time: Word; Date: Word; }
  CRC32              : Integer; //(4)
  CompressedSize     : Integer; //(4)
  UncompressedSize   : Integer; //(4)
  FileNameLength     : Word;    //(2)
  ExtraFieldLength   : Word;    //(2)
  FileCommentLen     : Word;    //(2) RCV added
  StartOnDisk        : Word;    //(2) RCV added
  IntFileAttrib      : Word;    //(2) RCV added
  ExtFileAttrib      : LongWord;//(4) RCV added
  RelOffLocalHdr     : LongWord;//(4) RCV added
  FileName           : String;  // variable size
  FileComment        : String;  // variable size
end;

// An entry in the central dir:
Type ZipCentralHeader = packed record //fixed part size : 42 bytes
  HeaderSig          : LongWord; // hex: 02014B50(4)
  VersionMadeBy0     : Byte;     //version made by(1)
  VersionMadeBy1     : Byte;     //host number(1)
  VersionNeed        : Word;     // version needed to extract(2)
  Flag               : Word;     //generalPurpose bitflag(2)
  ComprMethod        : Word;     //compression method(2)
  ModifTime          : Word;     // modification time(2)
  ModifDate          : Word;     // modification date(2)
  CRC32              : LongWord; //Cycling redundancy check (4)
  ComprSize          : LongWord; //compressed file size  (4)
  UnComprSize        : LongWord; //uncompressed file size (4)
  FileNameLen        : Word;     //(2)
  ExtraLen           : Word;     //(2)
  FileComLen         : Word;     //(2)
  DiskStart          : Word;     //starts on disk number xx(2)
  IntFileAtt         : Word;     //internal file attributes(2)
  ExtFileAtt         : LongWord; //external file attributes(4)
  RelOffLocal        : LongWord; //relative offset of local file header(4)
  // not used as part of this record structure:
  // filename, extra data, file comment
end;

Type ZipEndOfCentral = packed record  //Fixed part size : 22 bytes
  HeaderSig          : LongWord; //(4)  hex=06054B50
  ThisDiskNo         : Word;     //(2)This disk's number
  CentralDiskNo      : Word;     //(2)Disk number central dir start
  CentralEntries     : Word;     //(2)Number of central dir entries on this disk
  TotalEntries       : Word;     //(2)Number of entries in central dir
  CentralSize        : LongWord; //(4)Size of central directory
  CentralOffSet      : LongWord; //(4)offsett of central dir on 1st disk
  ZipCommentLen      : Word;     //(2)
  // not used as part of this record structure:
  // ZipComment
end;

Type ZipDataDescriptor = packed record
  DataDescSig        : LongWord; // Should be 0x08074B50
  CRC32              : LongWord;
  ComprSize          : LongWord;
  UnComprSize        : LongWord;
end;

Type MDZipData = record  // MyDirZipData
  Diskstart          : Word;     //(2)The disk number where this file begins
  RelOffLocal        : LongWord; //(4)offset from the start of the first disk
  FileNameLen        : Word;     //(2)length of current filename
  // EWE: My newest change is below:
  FileName           : Array[0..254] of Char; //pChar;   //(4)ptr to current filename
  CRC32              : LongWord; //(4)
  ComprSize          : LongWord; //(4)
  UnComprSize        : LongWord; //(4)
end;

Type
  pZipDirEntry = ^ZipDirEntry;

Const   { these are stored in reverse order }
  LocalFileHeaderSig     = $04034b50; { 'PK'34  (in file: 504b0304) }
  CentralFileHeaderSig   = $02014b50; { 'PK'12 }
  EndCentralDirSig       = $06054b50; { 'PK'56 }
  ExtLocalSig            = $08074b50; { 'PK'78 }
  BufSize                = 8192;      // Keep under 12K to avoid Winsock problems on Win95.
                                      // If chunks are too large, the Winsock stack can
                                      // lose bytes being sent or received.
  RESOURCE_ERROR: String = 'ZipMsgXX.res is probably not bound to executable' + #10 + 'Missing String ID is: ';
  ZIPMASTERVERSION: String = '1.52 K';

  { From DLL version 151 and up we use a new ZipDLL parameter type
    and from DLL version 152 and up we use a new UnzZipDLL parameter type.
    These changes were needed to pass extended information to the DLL's.
    The DLL's and ZipMaster can still handle the old parameter types if neccessary.
    This implies we can have the following situations:
    Component >=151 and DLL >= 151 New Type will be used and in all other cases
    the old Type will be used. }
  ZIPVERSION             = 154;
  UNZIPVERSION           = 152;

Type
  TBuffer = Array[0..BufSize - 1] of Byte;
  pBuffer = ^TBuffer;

Type
  EZipMaster = class( Exception )
    public
      FDisplayMsg: Boolean;   // We do not always want to see a message after an exception.
      // We also save the Resource ID in case the resource is not linked in the application.
      FResIdent: Integer;

      constructor CreateResDisp( Const Ident: Integer; Const Display: Boolean );
      constructor CreateResDisk( Const Ident: Integer; Const DiskNo: Integer );
      constructor CreateResDrive( Const Ident: Integer; Const Drive: String );
  end;

//------------------------------------------------------------------------
Type
  ProgressType = ( NewFile, ProgressUpdate, EndOfBatch, TotalFiles2Process,
                   TotalSize2Process );

  AddOptsEnum = ( AddDirNames, AddRecurseDirs, AddMove, AddFreshen, AddUpdate,
                  AddZipTime,  AddForceDOS, AddHiddenFiles, AddEncrypt,
                  AddSeparateDirs,  AddDiskSpan, AddDiskSpanErase);
  AddOpts = Set of AddOptsEnum;

  ExtrOptsEnum = ( ExtrDirNames, ExtrOverWrite, ExtrFreshen, ExtrUpdate,
                   ExtrTest );
  ExtrOpts = Set of ExtrOptsEnum;

  SFXOptsEnum = ( SFXAskCmdLine, SFXAskFiles, SFXAutoRun, SFXHideOverWriteBox,
                  SFXCheckSize );
  SFXOpts = Set of SFXOptsEnum;

  OvrOpts = ( OvrConfirm, OvrAlways, OvrNever );

  CodePageOpts = (cpAuto, cpNone, cpOEM);

  DeleteOpts = ( htdFinal, htdAllowUndo );

  TProgressEvent = procedure(Sender : TObject;
          ProgrType: ProgressType;
          Filename: String;
          FileSize: Integer) of object;

  TMessageEvent = procedure(Sender : TObject;
          ErrCode: Integer;
          Message : String) of object;

  pTZipMaster = ^TZipMaster;
  FormatThread = class;

  TZipMaster = class( TComponent )
  private
    { Private versions of property variables }
    FHandle:             Integer;
    FVerbose:            Boolean;
    FTrace:              Boolean;
    FErrCode:            Integer;
    FFullErrCode:        Integer;
    FMessage:            String;
    FZipContents:        TList;
    FExtrBaseDir:        String;
    FCancel:             Boolean;
    FZipBusy:            Boolean;
    FUnzBusy:            Boolean;
    FAddOptions:         AddOpts;
    FExtrOptions:        ExtrOpts;
    FSFXOptions:         SFXOpts;
    FFSpecArgs:          TStrings;
    FZipFilename:        String;
    FSuccessCnt:         Integer;
    FAddCompLevel:       Integer;
    FPassword:           ShortString;
    FSFXPath:            String;
    FEncrypt:            Boolean;
    FSFXOffset:          Integer;
    FDLLDirectory:       String;
    FUnattended:         Boolean;

    AutoExeViaAdd:       Boolean;
    FVolumeName:         String;
    FSizeOfDisk:         LargeInt;  { Int64 or Comp }
    FDiskFree:           LargeInt;  // RCV150199
    FDiskSerial:         Integer;
    FDrive:              String;
    FDriveNr:            Integer;

    FHowToDelete:        DeleteOpts;
    FTotalSizeToProcess: Cardinal;
    FInteger:            Integer;
    FDiskNr:             Integer;
    FTotalDisks:         Integer;
    FNewDisk:            Boolean;
    FFileSize:           Integer;
    FRealFileSize:       Cardinal;
    FWrongZipStruct:     Boolean;
    FInFileName:         String;
    FOutFileName:        String;
    FInFileHandle:       Integer;
    FOutFileHandle:      Integer;
    FVersionMadeBy1:     Integer;
    FVersionMadeBy0:     Integer;
    FDateStamp:          Integer;  // DOS formatted date/time - use Delphi's
                                   // FileDateToDateTime function to give you TDateTime
                                   // format.

    FSFXOverWriteMode:   OvrOpts; // ovrConfirm  (others: ovrAlways, ovrNever)
    FSFXCaption:         String;  // dflt='Self-extracting Archive'
    FSFXDefaultDir:      String;  // dflt=''

    FSFXCommandLine:     String;  // dflt=''

    FTempDir:            String;
    FShowProgress:       Boolean;
    FIsSpanned:          Boolean;
    FFreeOnDisk:         LargeInt;   // RCV150199
    FDiskWritten:        Integer;
    FFreeOnDisk1:        Integer;
    FMaxVolumeSize:      Integer;
    FMinFreeVolSize:     Integer;
    FConfirmErase:       Boolean;
    FCodePage:           CodePageOpts;
    FZipEOC:             Integer; // End-Of-Central-Dir location
    FZipSOC:             Integer; // Start-Of-Central-Dir location
    FZipComment:         String;
    { Used in diskspanning functions }
    MDZD:                TList;
    MDZDp:              ^MDZipData;
    { New v1.5 'format' }
    Fhwnd:               HWND;
    FBeginFormat:        Boolean;
    FFound:              Integer;
    FFormatResult:       Integer;
    Fft:                 FormatThread;
    FVersionInfo:        String;

    { misc private vars }
    ZipParms:            ZipParms0;  { declare an instance of ZipParms 1 or 2 }
    UnZipParms:          UnzParms0;  { declare an instance of UnZipParms 1 or 2 }

    { Event variables }
    FOnDirUpdate:        TNotifyEvent;
    FOnProgress:         TProgressEvent;
    FOnMessage:          TMessageEvent;

    { Property get/set functions }
    function  GetCount: Integer;
    procedure SetFSpecArgs( Value: TStrings );
    procedure SetFilename( Value: String );
    function  GetZipVers: Integer;
    function  GetUnzVers: Integer;
    procedure SetDLLDirectory( Value: String );
    function  GetZipComment: String;
    procedure SetVersionInfo( Value: String );

    { Private "helper" functions }
    procedure FreeZipDirEntryRecords;
    procedure SetZipSwitches( var NameOfZipFile: String );
    procedure SetUnZipSwitches( var NameOfZipFile: String );
    procedure ShowExceptionError( Const ZMExcept: EZipMaster );
    function  LoadZipStr( Ident: Integer; DefaultStr: String ): String;
    function  ConvCodePage( Source: String ): String;
    function  IsDiskPresent: Boolean;
    function  CheckForDisk: Integer;
    function  CheckIfLastDisk( var EOC: ZipEndOfCentral; DoExcept: Boolean ) : Boolean;
    function  IsRightDisk( drt: Integer ): Boolean;
    procedure GetNewDisk( DiskSeq: Integer );
    function  ReplaceForwardSlash( aStr: String ): String;
    function  CopyBuffer( InFile: Integer; OutFile: Integer; ReadLen: Integer ):Integer;
    function  RWCentralDir( OutFile:Integer; EOC: ZipEndOfCentral; OffsetChange: Integer ):Integer;
    function  MakeString( Buffer: pChar; Size: Integer ): String;
    procedure WriteSplit( Buffer: pChar; Len: Integer; MinSize: Integer );
    procedure AllocSpanMem( TotalEntries: Integer );
    procedure DeleteSpanMem;
    function  FindZipEntry( Entries: Integer; Filename: String ): Integer;
    procedure WriteJoin( Buffer: pChar; BufferSize, DSErrIdent: Integer );
    procedure RWSplitData( Buffer: pChar; ReadLen, ZSErrVal: Integer );
    procedure RWJoinData( Buffer: pChar; ReadLen, DSErrIdent: Integer );
    function  ZipFormat: Integer;
    procedure DiskFreeAndSize( Action: Integer );   // RCV150199

  public
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;

    { Public Properties (run-time only) }
    property Handle:       Integer   read  FHandle
                                     write FHandle;
    property ErrCode:      Integer   read  FErrCode;
    property Message:      String    read  FMessage;
    property ZipContents:  TList     read  FZipContents;
    property Cancel:       Boolean   read  FCancel
                                     write FCancel;
    property ZipBusy:      Boolean   read  FZipBusy;
    property UnzBusy:      Boolean   read  FUnzBusy;

    property Count:        Integer   read  GetCount;
    property SuccessCnt:   Integer   read  FSuccessCnt;

    property ZipVers:      Integer   read  GetZipVers;
    property UnzVers:      Integer   read  GetUnzVers;

    { new in v1.50 }
    property SFXOffset:    Integer   read  FSFXOffset;
    property ZipSOC:       Integer   read  FZipSOC
                                     default 0;
    property ZipEOC:       Integer   read  FZipEOC
                                     default 0;
    property IsSpanned:    Boolean   read  FIsSpanned
                                     default False;
    property ZipComment:   String    read  GetZipComment;
    property ZipFileSize:  Cardinal  read  FRealFileSize
                                     default 0;
    property FullErrCode:  Integer   read  FFullErrCode;
    property TotalSizeToProcess: Cardinal read FTotalSizeToProcess;

    { Public Methods }
    { NOTE: Test is an sub-option of extract }
    procedure Add;
    procedure Delete;
    procedure Extract;
    procedure List;
    procedure Load_Zip_Dll;
    procedure Load_Unz_Dll;
    procedure Unload_Zip_Dll;
    procedure Unload_Unz_Dll;
    function  CopyFile( Const InFileName, OutFileName: String ): Integer;
    function  EraseFile( Const Fname: String; How: DeleteOpts ): Integer;
    function  ConvertSFX: Integer;
    function  ConvertZIP: Integer;
    procedure GetAddPassword;
    procedure GetExtrPassword;
    function  GetTotalFileSize( var ProgMax: Integer ): LongInt; { Kenan }
    function  AppendSlash( sDir: String ): String;
    procedure ShowZipMessage( Ident: Integer; UserStr: String );
    function  WriteSpan( InFileName, OutFileName: String ): Integer;
    function  ReadSpan( InFileName: String; var OutFilePath: String ): Integer;

  published
    { Public properties that also show on Object Inspector }
    property Verbose:      Boolean  read  FVerbose
                                    write FVerbose;
    property Trace:        Boolean  read  FTrace
                                    write FTrace;
    property AddCompLevel: Integer  read  FAddCompLevel
                                    write FAddCompLevel;
    property AddOptions:   AddOpts  read  FAddOptions
                                    write FAddOptions;
    property ExtrBaseDir:  String   read  FExtrBaseDir
                                    write FExtrBaseDir;
    property ExtrOptions:  ExtrOpts read  FExtrOptions
                                    write FExtrOptions;
    property SFXOptions:   SfxOpts  read  FSFXOptions
                                    write FSFXOptions
                                    default [SFXCheckSize];
    property FSpecArgs:    TStrings read  FFSpecArgs
                                    write SetFSpecArgs;
    property Unattended:   Boolean  read  FUnattended
                                    write FUnattended;

    { At runtime: every time the filename is assigned a value,
      the ZipDir will automatically be read. }
    property ZipFilename: String        read  FZipFilename
                                        write SetFilename;

    property Password:     ShortString  read  FPassword
                                        write FPassword;
    property SFXPath:      String       read  FSFXPath
                                        write FSFXPath;
    property DLLDirectory: String       read  FDLLDirectory
                                        write SetDLLDirectory;
    property SFXOverWriteMode: OvrOpts  read  FSFXOverWriteMode
                                        write FSFXOverWriteMode;
    property SFXCaption:       String   read  FSFXCaption
                                        write FSFXCaption;
    property SFXDefaultDir:    String   read  FSFXDefaultDir
                                        write FSFXDefaultDir;
    property SFXCommandLine:   String   read  FSFXCommandLine
                                        write FSFXCommandLine;

    { ver 1.50 }
    property TempDir: String            read  FTempDir
                                        write FTempDir;
    property KeepFreeOnDisk1: Integer   read  FFreeOnDisk1
                                        write FFreeOnDisk1;
    property MaxVolumeSize: Integer     read  FMaxVolumeSize
                                        write FMaxVolumesize
                                        default 0;
    property MinFreeVolumeSize: Integer read  FMinFreeVolSize
                                        write FMinFreeVolSize
                                        default 65536;
    property ConfirmErase: Boolean      read  FConfirmErase
                                        write FConfirmErase
                                        default True;
    property CodePage: CodePageOpts     read  FCodePage
                                        write FCodePage
                                        default cpAuto;
    { ver 1.51 }
    property HowToDelete: DeleteOpts    read  FHowToDelete
                                        write FHowToDelete
                                        default htdAllowUndo;
    { ver 1.52k }
    property VersionInfo: String        read  FVersionInfo
                                        write SetVersionInfo;

    { Events }
    property OnDirUpdate         : TNotifyEvent   read  FOnDirUpdate
                                                  write FOnDirUpdate;
    property OnProgress          : TProgressEvent read  FOnProgress
                                                  write FOnProgress;
    property OnMessage           : TMessageEvent  read  FOnMessage
                                                  write FOnMessage;
  end;

  {---SHFormatDrive-----------------------------------------------------------
   Return values:
    Ok=6 NoFormat=-3, Cancel=-2, Error=-1
   Drive:
    0=A:\ 1=B:\ etc.
   FormatID:
    0=1,44 and 1,2Mb 3=360Kb 5=720 Kb FFFF=default size
   Options:
    0=Quick 1=Full 2=SysOnly }
  FormatThread = class( TThread )
    protected
      procedure   Execute; override;

    public
      constructor CreateFT( var myParent: TZipMaster; CreateSuspended: Boolean ); virtual;
      destructor  Destroy; override;
  end;


procedure Register;

{ Define the functions that are not part of the TZipMaster class. }
{ The callback function must NOT be a member of a class. }
{ We use the same callback function for ZIP and UNZIP. }
function ZCallback( ZCallBackRec: PZCallBackStruct ): LongBool; stdcall; export;
function EnumThreadWndProc( winh: HWND; var mythis: TZipMaster ): Boolean; stdcall; export;
function CallWndRetProc( code: Integer; wp: WPARAM; lp: LPARAM ): LRESULT; stdcall; export;

Var SHFormatDrive: function( wnd: HWND; drive: Integer; size: Cardinal; action: Integer ): Integer; stdcall;

Implementation

function DirectoryExists( Const Name: string ): Boolean;
var
   Code: Integer;
begin
   Code := GetFileAttributes( pChar( Name ) );
   Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

Var
  ParentMaster  : TZipMaster = nil;
  Fhhk          : HHOOK;

{ Dennis Passmore (Compuserve: 71640,2464) contributed the idea of passing an
  instance handle to the DLL, and, in turn, getting it back from the callback.
  This lets us referance variables in the TZipMaster class from within the
  callback function.  Way to go Dennis! }
function ZCallback( ZCallBackRec: PZCallBackStruct ): LongBool; stdcall; export;
var
  Msg: String;
begin
   with ZCallBackRec^, (TObject(Caller) as TZipMaster) do
   begin
      if ActionCode = 1 then
         { progress type 1 = starting any ZIP operation on a new file }
         if Assigned( FOnProgress ) then
            FOnProgress( Caller, NewFile, ReplaceForwardSlash( FilenameOrMsg ), FileSize );

      if ActionCode = 2 then
         { progress type 2 = increment bar }
         if Assigned( FOnProgress ) then
            FOnProgress( Caller, ProgressUpdate, '', FileSize );

      if ActionCode = 3 Then
         { end of a batch of 1 or more files }
         if Assigned( FOnProgress ) then
            FOnProgress( Caller, EndOfBatch, '', 0 );

      if ActionCode = 4 Then
      begin
         { a routine status message }
         Msg := ReplaceForwardSlash( TrimRight( FilenameOrMsg ) );
         FMessage := Msg;
         if ErrorCode <> 0 then  // W'll always keep the last ErrorCode
         begin
            FErrCode     := Integer( Char( ErrorCode and $FF ) );
            FFullErrCode := ErrorCode;
         end;
         if Assigned( FOnMessage ) then
            FOnMessage( Caller, ErrorCode, Msg );
      end;

      { 5 and 6 are new in v1.50 }
      if ActionCode = 5 Then
         { total number of files to process }
         if Assigned( FOnProgress ) then
            FOnProgress( Caller, TotalFiles2Process, '', FileSize );

      if ActionCode = 6 Then
      begin
         FTotalSizeToProcess := FileSize;
         { total size of all files to be processed }
         if Assigned( FOnProgress ) then
            FOnProgress( Caller, TotalSize2Process, '', FileSize );
      end;
      { If you return TRUE, then the DLL will abort it's current
        batch job as soon as it can. }
      Result := fCancel;
    end; { end with }
    Application.ProcessMessages;
end;

{ Implementation of TZipMaster class member functions }
{-----------------------------------------------------}
constructor TZipMaster.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  FZipContents      := TList.Create;
  FFSpecArgs        := TStringList.Create;
  FHandle           := Application.Handle;
  ZipParms.zp1      := nil;
  FZipFilename      := '';
  FPassword         := '';
  FSFXPath          := 'ZipSFX.bin';
  FEncrypt          := False;
  FSuccessCnt       := 0;
  FAddCompLevel     := 9;     { dflt to tightest compression }
  FDLLDirectory     := '';
  FSFXOverWriteMode := ovrConfirm;
  FSFXCaption       := 'Self-extracting Archive';
  FSFXDefaultDir    := '';
  FSFXCommandLine   := '';
  AutoExeViaAdd     := False;
  FUnattended       := False; { new in v1.45}

  { following are new in v1.50 }
  FRealFileSize	    := 0;
  FSFXOffset        := 0;
  FZipSOC           := 0;
  FFreeOnDisk1      := 0;       // Don't leave any freespace on disk 1.
  FMaxVolumeSize    := 0;       // Use the maximum disk size.
  FMinFreeVolSize   := 65536;   // Reject disks with less free bytes than...
  FConfirmErase     := True;
  FCodePage         := cpAuto;
  FIsSpanned        := False;
  FZipComment       := '';      // read-only
  FSFXOptions       := [SFXCheckSize]; // select this opt by default
  MDZD              := nil;
  { following are new in v1.51 }
  HowToDelete       := htdAllowUndo;
  FVersionInfo      := ZIPMASTERVERSION;
end;

destructor TZipMaster.Destroy;
begin
  FreeZipDirEntryRecords;
  FZipContents.Free;
  FFSpecArgs.Free;
  inherited Destroy;
end;

procedure TZipMaster.ShowZipMessage( Ident: Integer; UserStr: String );
var
   Msg: String;
begin
   Msg      := LoadZipStr( Ident, RESOURCE_ERROR + IntToStr( Ident ) ) + UserStr;
   FMessage := Msg;
   FErrCode := Ident;

   if FUnattended = False then
      ShowMessage( Msg );

   if Assigned( FOnMessage ) then
      FOnMessage( Self, 0, Msg );  // No ErrCode here else w'll get a msg from the application
end;

function TZipMaster.LoadZipStr( Ident: Integer; DefaultStr: String ): String;
begin
   Result := LoadStr( Ident );

   if Result = '' then
      Result := DefaultStr;
end;

//---------------------------------------------------------------------------
// Somewhat different from ShowZipMessage() because the loading of the resource
// string is already done in the constructor of the exception class.
procedure TZipMaster.ShowExceptionError( Const ZMExcept: EZipMaster );
begin
  if (ZMExcept.FDisplayMsg = True) and (Unattended = False) then
     ShowMessage( ZMExcept.Message );

  FErrCode := ZMExcept.FResIdent;
  FMessage := ZMExcept.Message;

  if Assigned( FOnMessage ) then
     FOnMessage( Self, 0, ZMExcept.Message );
end;


{  Convert filename (and file comment string) into "internal" charset (ISO).
 * This function assumes that Zip entry filenames are coded in OEM (IBM DOS)
 * codepage when made on:
 *  -> DOS (this includes 16-bit Windows 3.1) (FS_FAT_  0 )
 *  -> OS/2                                   (FS_HPFS_ 6 )
 *  -> Win95/WinNT with Nico Mak's WinZip     (FS_NTFS_ 11 && hostver == "5.0" 50)
 *
 * All other ports are assumed to code zip entry filenames in ISO 8859-1.
 *
 * NOTE: Norton Zip v1.0 sets the host byte incorrectly. In this case you need
 * to set the CodePage property manually to cpOEM to force the conversion.
}
function TZipMaster.ConvCodePage( Source: String ): String;
Const
   FS_FAT:  Integer =  0;
   FS_HPFS: Integer =  6;
   FS_NTFS: Integer = 11;
var
   i: Integer;
begin
   SetLength( Result, Length( Source ) );
   if ((FCodePage = cpAuto) and (FVersionMadeBy1 = FS_FAT) or (FVersionMadeBy1 = FS_HPFS)
        or ((FVersionMadeBy1 = FS_NTFS) and (FVersionMadeBy0 = 50))) or (FCodePage = cpOEM) then
   begin
      for i := 1 to Length( Source ) do
         if Char( Source[i] ) < Char( $80 ) then
            Result[i] := Source[i]
         else
            OemToCharBuff( @Source[i], @Result[i], 1 );
   end
   else
      Result := Source;
end;

function TZipMaster.GetZipVers: Integer;
var
   AutoLoad: Boolean;
begin
   Result := 0;
   if ZipDllHandle = 0 then
   begin
      AutoLoad := True;   // user's program didn't load the DLL
      Load_Zip_Dll;       // load it
   end
   else
      AutoLoad := False;  // user's pgm did load the DLL, so let him unload it
   if ZipDllHandle = 0 then
      Exit;  // load failed - error msg was shown to user

   Result := GetZipDLLVersion;

   if AutoLoad then
      Unload_Zip_Dll;
end;

function TZipMaster.GetUnzVers: Integer;
var
   AutoLoad: Boolean;
begin
   Result := 0;
   if UnzDllHandle = 0 then
   begin
      AutoLoad:=True;     // user's program didn't load the DLL
      Load_Unz_Dll;       // load it
   end
   else
      AutoLoad := False;  // user's pgm did load the DLL, so let him unload it
   if UnzDllHandle = 0 then
      Exit;  // load failed - error msg was shown to user

   Result := GetUnzDLLVersion;

   if AutoLoad then
      Unload_Unz_Dll;
end;

{ We'll normally have a TStringList value, since TStrings itself is an
  abstract class. }
procedure TZipMaster.SetFSpecArgs( Value : TStrings );
begin
   FFSpecArgs.Assign( Value );
end;

procedure TZipMaster.SetFilename( Value : String );
begin
   FZipFilename := Value;
   if NOT (csDesigning in ComponentState) then
      List; { automatically build a new TLIST of contents in "ZipContents" }
end;

// NOTE: we will allow a dir to be specified that doesn't exist,
// since this is not the only way to locate the DLLs.
procedure TZipMaster.SetDLLDirectory( Value: String );
var
   ValLen: Integer;
begin
   if Value <> FDLLDirectory then
   begin
      ValLen := Length( Value );
      // if there is a trailing \ in dirname, cut it off:
      if ValLen > 0 then
         if Value[ValLen] = '\' then
            SetLength( Value, ValLen - 1 ); // shorten the dirname by one
      FDLLDirectory := Value;
   end;
end;

function TZipMaster.GetCount: Integer;
begin
   if FZipFilename <> '' then
      Result := FZipContents.Count
   else
      Result := 0;
end;

function TZipMaster.GetZipComment: String;
begin
   Result := ConvCodePage( FZipComment );
end;

// We do not want that this can be changed, but we do want to see it in the OI.
procedure TZipMaster.SetVersionInfo( Value: String );
begin
end;

{ Empty FZipContents and free the storage used for dir entries }
procedure TZipMaster.FreeZipDirEntryRecords;
var
   i: Integer;
begin
   if FZipContents.Count = 0 then
      Exit;
   for i:= (FZipContents.Count - 1) downto 0 do
   begin
      if Assigned( FZipContents[i] ) then
         // dispose of the memory pointed-to by this entry
         Dispose( PZipDirEntry( FZipContents[i] ) );
      FZipContents.Delete(i); // delete the TList pointer itself
   end; { end for }
   // The caller will free the FZipContents TList itself, if needed
end;

{ New in v1.50: We are now looking at the Central zip Dir, instead of
  the local zip dir.  This change was needed so we could support
  Disk-Spanning, where the dir for the whole disk set is on the last disk.}
{ The List method reads thru all entries in the central Zip directory.
  This is triggered by an assignment to the ZipFilename, or by calling
  this method directly. }
procedure TZipMaster.List;  { all work is local - no DLL calls }
var
  pzd:        pZipDirEntry;
  EOC:         ZipEndOfCentral;
  CEH:         ZipCentralHeader;
  OffsetDiff:  Integer;
  Name:        String;
  i, LiE:      Integer;
begin
  LiE := 0;
  if (csDesigning in ComponentState) then
     Exit;  { can't do LIST at design time }

  { zero out any previous entries }
  FreeZipDirEntryRecords;

  FRealFileSize :=  0;
  FZipSOC       :=  0;
  FSFXOffset    :=  0;  // must be before the following "if"
  FZipComment   := '';
  OffsetDiff    :=  0;
  FIsSpanned    := False;

  if NOT FileExists( FZipFilename ) then
  begin
     { let user's program know there's no entries }
     if Assigned( FOnDirUpdate ) then
        FOnDirUpdate( Self );
     Exit; { don't complain - this may intentionally be a new zip file }
  end;

  try
    Screen.Cursor := crHourglass;
    try
      FInFileName := FZipFilename;
      FDrive      := ExtractFileDrive( ExpandFileName( FInFileName ) ) + '\';

      if NOT IsDiskPresent then // Not present, raise an exception!
         raise EZipMaster.CreateResDrive( DS_DriveNoMount, FDrive );

      CheckIfLastDisk( EOC, True );    // Not last, w'll get an exception!

      // The function CheckIfLastDisk read the EOC record, and set some
      // global values such as FFileSize.  It also opens the zipfile
      // and left it's open handle in: FInFileHandle

      FTotalDisks := EOC.ThisDiskNo;   // Needed in case GetNewDisk is called.

      // This could also be set to True if it's the first and only disk.
      if EOC.ThisDiskNo > 0 then
         FIsSpanned := True;

      // Do we have to request for a previous disk first?
      if EOC.ThisDiskNo <> EOC.CentralDiskNo then
      begin
         GetNewDisk( EOC.CentralDiskNo );
			FFileSize  := FileSeek( FInFileHandle, 0, 2 );	//v1.52i
			OffsetDiff := EOC.CentralOffset;	//v1.52i
      end else	//v1.52i
        // Due to the fact that v1.3 and v1.4x programs do not change the archives
        // EOC and CEH records in case of a SFX conversion (and back) we have to
        // make this extra check.
        OffsetDiff := Longword(FFileSize) - EOC.CentralSize - SizeOf(EOC) - EOC.ZipCommentLen;
      FZipSOC := OffsetDiff;  // save the location of the Start Of Central dir
      FSFXOffset := FFileSize;  // initialize this - we will reduce it later
      if FFileSize = 22 then
         FSFXOffset := 0;

      FWrongZipStruct := False;
      if EOC.CentralOffset <> Longword(OffsetDiff) then
      begin
         FWrongZipStruct := True;     // We need this in the ConvertXxx functions.
         ShowZipMessage( LI_WrongZipStruct, '' );
      end;

      // Now we can go to the start of the Central directory.
      if FileSeek(FInFileHandle, OffsetDiff, 0) = -1 then
         raise EZipMaster.CreateResDisp( LI_ReadZipError, True );

      //ShowMessage( 0, 'entries in zip file: ' + IntToStr(EOC.TotalEntries));

      // Read every entry: The central header and save the information.
      for i := 0 to (EOC.TotalEntries - 1) do
      begin
         // Read a central header entry for 1 file
         while FileRead( FInFileHandle, CEH, SizeOf( CEH ) ) <> SizeOf( CEH ) do  //v1.52i
         begin
            // It's possible that we have the central header split up.
            if FDiskNr >= EOC.ThisDiskNo then
               raise EZipMaster.CreateResDisp( DS_CEHBadRead, True );
            // We need the next disk with central header info.
            GetNewDisk( FDiskNr + 1 );
         end;

         //validate the signature of the central header entry
         if CEH.HeaderSig <> CentralFileHeaderSig then
            raise EZipMaster.CreateResDisp( DS_CEHWrongSig, True );

         //ShowMessage( 'good CEH sig, i= ' + IntToStr( i ) );
         //ShowMessage( 'filename len= ' + IntToStr( CEH.FileNameLen ) );

         // Now the filename
         SetLength( Name, CEH.FileNameLen );
         if FileRead( FInFileHandle, Name[1], CEH.FileNameLen ) <> CEH.FileNameLen then
            raise EZipMaster.CreateResDisp( DS_CENameLen, True );

         // Save version info globally for use by codepage translation routine
         FVersionMadeBy0 := CEH.VersionMadeBy0;
         FVersionMadeBy1 := CEH.VersionMadeBy1;
         Name := ConvCodePage( Name );

         // Create a new ZipDirEntry pointer and add it to our contents table.
         New( pzd );  // These will be deleted in: FreeZipDirEntryRecords.
         FZipContents.Add( pzd );

         // Copy the needed file info from the central header
         CopyMemory( pzd, @CEH.VersionMadeBy0, 42 );
         pzd^.FileName := ReplaceForwardSlash( Name );

         // Seek past the extra field.
         if FileSeek( FInFileHandle, CEH.ExtraLen, 1 ) = -1 then
            raise EZipMaster.CreateResDisp( LI_ReadZipError, True );

         // Read the FileComment, if present, and save.
         if CEH.FileComLen > 0 then
         begin
            // get the file comment
            SetLength( pzd^.FileComment, CEH.FileComLen );
            if FileRead( FInFileHandle, pzd^.FileComment[1], CEH.FileComLen ) <> CEH.FileComLen then
               raise EZipMaster.CreateResDisp( DS_CECommentLen, True );
            pzd^.FileComment := ConvCodePage( pzd^.FileComment );
            //ShowMessage('File: ' + Name + '   File comment: ' + pzd^.FileComment);
         end;

         // Calculate the earliest Local Header start
         if Longword(FSFXOffset) > CEH.RelOffLocal then
            FSFXOffset := CEH.RelOffLocal;
      end;
      FTotalDisks := EOC.ThisDiskNo;   // We need this when we are going to extract.
    except
      on ezl: EZipMaster do            // Catch all Zip List specific errors.
         begin
           ShowExceptionError( ezl );
           LiE :=  1;
         end;
      on EOutOfMemory do
         begin
           ShowZipMessage( GE_NoMem, '' );
           LiE :=  1;
         end;
      else
         begin
	   ShowZipMessage( LI_ErrorUnknown, '' );
           LiE :=  1;
         end;
    end;
  finally
    Screen.Cursor := crDefault;
    if FInFileHandle <> -1 then
       FileClose( FInFileHandle );
    if LiE = 1 then
       begin
       	 FZipFilename := '';
         FSFXOffset   :=  0;
       end
    else
      FSFXOffset := FSFXOffset + (OffsetDiff - Integer( EOC.CentralOffset )); // Correct the offset for v1.3 and 1.4x

    //ShowMessage( 'SFX Offset = ' + IntToStr( FSFXOffset ) );

    // Let the user's program know we just refreshed the zip dir contents.
    if Assigned( FOnDirUpdate ) then
       FOnDirUpdate( Self );
  end;
end;

{************* Kenan *************}
// NOTE: Starting with v1.50, we have the DLLs calculate this info.
// You get the numbers from Progress callback action types 5 and 6.
// The DLLs are more accurate in unusual situations.
function FSize( FName: String; FAttr: Integer; var ProgMax: Integer; SubDirs: Boolean; ZFName: String ): LongInt;
var
   SearchRec:           TSearchRec;
   Ldir, xres:          Integer;
   FSz:                 LongInt;
   LastDir:             Array[0..50, 1..2] of String;
   xNext:               Boolean;
   xFDir, xFName,ZFile: String;
begin
   FSz     := 0;
   ProgMax := 0;
   xFDir := ExtractFileDir( FName );

   if xFDir = '' then
      xFDir := GetcurrentDir;
   if (Length( xFDir ) = 1) and (xFDir = '\') then
      xFDir := Copy( GetcurrentDir, 1, 2 );
   if (Length( xFDir ) = 3) and (Copy( xFDir, 2, 2 ) = ':\') then
      xFDir := Copy( xFDir, 1, 2 );
   xFName := ExtractFileName( FName );

   ZFile:=ExtractFileDir( ZFName );
   if ZFile='' then ZFile := GetCurrentDir;
   if (Length( ZFile ) = 3) and (Copy( ZFile, 2, 2 ) = ':\') then
      ZFile := Copy( ZFile, 1, 2 );
   if (Length( ZFile ) = 1) and (ZFile = '\') then
      ZFile := Copy( GetcurrentDir, 1, 2 );
   ZFile := ZFile + '\' + ExtractFileName( ZFName );

   xNext := False;
   ldir := 0;
   xres := 0;

   repeat
      if SubDirs then
      begin
         repeat
//          xres:=FindFirst(xFDir+'\*', faDirectory + faHidden + faReadOnly, SearchRec);
//          If recursion working properly please remark line below and unremark line above.
            xres:=FindFirst( xFDir + '\' + ExtractFileName( FName ), faDirectory + faHidden + faReadOnly, SearchRec );

            if xres = 0 then
            begin
               while (xres = 0)
                 and NOT ( (SearchRec.attr and faDirectory = faDirectory)
                  and (SearchRec.Name <> '.')
                  and (SearchRec.Name <> '..')
                  and (NOT xNext or (SearchRec.Name = xFName))) do
                      xres := FindNext( SearchRec );

               if xNext then
               begin
                  while (xres = 0)
                   and NOT ((SearchRec.attr and faDirectory = faDirectory)
                    and (SearchRec.Name <> xFName)) do
                       xres := FindNext( SearchRec );
                  xNext := False;
               end;

               if xres = 0 then
               begin
                  Inc( ldir );
                  LastDir[ldir, 1] := xFDir;
                  LastDir[ldir, 2] := SearchRec.Name;
                  xFDir := xFDir + '\' + SearchRec.Name;
               end
               else
                  xFName := ExtractFileName( FName );
            end; { if xres = 0 }
         until xres <> 0;
      end; { if subdirs }

      if FindFirst( xFDir + '\' + xFName, FAttr, SearchRec ) = 0 then
      begin
         if ZFile <> xFDir + '\' + SearchRec.Name then
         begin
            FSz := FSz + SearchRec.Size;
            if SearchRec.Size div 32768 > 1 then
               ProgMax := ProgMax + SearchRec.Size div 32768
            else
               ProgMax := ProgMax + 1;
         end;
         while FindNext( SearchRec ) = 0 do
         begin
            if ZFile <> xFDir + '\' + SearchRec.Name then
            begin
               FSz := FSz + SearchRec.Size;
               if SearchRec.Size div 32768 > 1 then
                  ProgMax := ProgMax + SearchRec.Size div 32768
               else
                  ProgMax := ProgMax + 1;
            end;
         end;
         xres := 1;
      end;

      if SubDirs then
      begin
         if ldir > 0 then
         begin
            xFDir  := LastDir[ldir,1];
            xFName := LastDir[ldir,2];
            Dec(ldir);
            xNext := True;
            xres  := 0;
         end
         else
            xres:=1;
      end; { if SubDirs }
   until xres <> 0;

   FindClose(SearchRec);
   Result := FSz;
end;

function TZipMaster.GetTotalFileSize( var ProgMax: Integer ): LongInt;
var
   i, PMax, Fattr: Integer;
   FS:             LongInt;
   SubDirs:        Boolean;
begin
   FS := 0;
   ProgMax := 0;
   FAttr := faArchive + faReadOnly;
   if AddHiddenFiles in AddOptions then
      Fattr := Fattr + faHidden;
   if AddRecurseDirs in AddOptions then
      SubDirs := True
   else
      SubDirs := False;
   for i := 0 to FSpecArgs.Count -1 do
   begin
      FS := FS + FSize( FSpecArgs.Strings[i], Fattr, PMax, SubDirs, ZipFileName );
      ProgMax := ProgMax + PMax;
   end;
   Result := FS;
end;
{************** Kenan *************************}

procedure TZipMaster.SetZipSwitches( var NameOfZipFile: String );
begin
   with ZipParms.zp1^ do
   begin
      Version  := ZIPVERSION;     // version we expect the DLL to be
      Caller   := Self;           // point to our VCL instance; returned in callback

      fQuiet   := True;  { we'll report errors upon notification in our callback }
                         { So, we don't want the DLL to issue error dialogs }

      ZCallbackFunc := ZCallback; // pass addr of function to be called from DLL
      fJunkSFX := False;          { if True, convert input .EXE file to .ZIP }
      fComprSpecial := False;     { if True, try to compr already compressed files }
      fSystem  := False;          { if True, include system and hidden files }
      fVolume  := False;          { if True, include volume label from root dir }
      fExtra   := False;          { if True, include extended file attributes-NOT SUPTED }

      fDate    := False;          { if True, exclude files earlier than specified date }
      { Date := '100592'; }       { Date to include files after; only used if fDate=TRUE }

      fLevel   := FAddCompLevel;  { Compression level (0 - 9, 0=none and 9=best) }
      fCRLF_LF := False;          { if True, translate text file CRLF to LF (if dest Unix)}
      fGrow    := True;           { if True, Allow appending to a zip file (-g)}

      fDeleteEntries := False;    { distinguish bet. Add and Delete }

      if fTrace then
         fTraceEnabled := True
      else
         fTraceEnabled := False;
      if fVerbose then
         fVerboseEnabled := True
      else
         fVerboseEnabled := False;
      if (fTraceEnabled and NOT fVerbose) then
         fVerboseEnabled := True;  { if tracing, we want verbose also }

      if FUnattended then
         Handle := 0
      else
         Handle := FHandle;

      if AddForceDOS in fAddOptions then
         fForce := True      { convert all filenames to 8x3 format }
      else
         fForce := False;
      if AddZipTime in fAddOptions then
         fLatestTime := True { make zipfile's timestamp same as newest file }
      else
         fLatestTime := False;
      if AddMove in fAddOptions then
         fMove := True       { dangerous, beware! }
      else
         fMove := False;
      if AddFreshen in fAddOptions then
         fFreshen := True
      else
         fFreshen := False;
      if AddUpdate in fAddOptions then
         fUpdate := True
      else
         fUpdate := False;
      if (fFreshen and fUpdate) then
         fFreshen := False;    { Update has precedence over freshen }

      if AddEncrypt in fAddOptions then
         fEncrypt := True      { DLL will prompt for password }
      else
         fEncrypt := False;

      { NOTE: if user wants recursion, then he probably also wants
        AddDirNames, but we won't demand it. }
      if AddRecurseDirs in fAddOptions then
         fRecurse := True
      else
         fRecurse := False;

      if AddHiddenFiles in fAddOptions then
         fSystem := True
      else
         fSystem := False;

      if AddSeparateDirs in fAddOptions then
         fNoDirEntries := False    { do make separate dirname entries - and also
                                     include dirnames with filenames }
      else
         fNoDirEntries := True;    { normal zip file - dirnames only stored
                                     with filenames }

      if AddDirNames in fAddOptions then
         fJunkDir := False       { we want dirnames with filenames }
      else
         fJunkDir := True;       { don't store dirnames with filenames }

      pZipFN := StrAlloc( Length( NameOfZipFile ) + 1 );   { allocate room for null terminated string }
      StrPLCopy( pZipFN, NameOfZipFile, Length( NameOfZipFile ) + 1 );   { name of zip file }
      pZipPassword := StrAlloc(  PWLEN + 1 );     { allocate room for null terminated string }
      StrPLCopy( pZipPassword, FPassword, PWLEN + 1 ); { password for encryption/decryption }
   end; { end with }
end;

procedure TZipMaster.SetUnZipSwitches( var NameOfZipFile: String );
begin
   with UnZipParms.up1^ do
   begin
      Version := UNZIPVERSION;  // version we expect the DLL to be
      Caller  := Self;          // point to our VCL instance; returned in callback

      fQuiet  := True;  { we'll report errors upon notification in our callback }
                        { So, we don't want the DLL to issue error dialogs }

      ZCallbackFunc := ZCallback; // pass addr of function to be called from DLL

      if fTrace then
         fTraceEnabled := True
      else
         fTraceEnabled := False;
      if fVerbose then
         fVerboseEnabled := True
      else
         fVerboseEnabled := False;
      if (fTraceEnabled and NOT fVerboseEnabled) then
         fVerboseEnabled := True;  { if tracing, we want verbose also }

      if FUnattended then
         Handle := 0
      else
         Handle := FHandle;   // used for dialogs (like the pwd dialogs)

      fQuiet    := True;      { no DLL error reporting }
      fComments := False;     { zipfile comments - not supported }
      fConvert  := False;     { ascii/EBCDIC conversion - not supported }

      if ExtrDirNames in fExtrOptions then
         fDirectories := True
      else
         fDirectories := False;
      if ExtrOverWrite in fExtrOptions then
         fOverwrite := True
      else
         fOverwrite := False;

      if ExtrFreshen in fExtrOptions then
         fFreshen := True
      else
         fFreshen := False;
      if ExtrUpdate in fExtrOptions then
         fUpdate := True
      else
         fUpdate := False;
      if fFreshen and fUpdate then
         fFreshen := False;  { Update has precedence over freshen }

      if ExtrTest in fExtrOptions then
         fTest := True
      else
         fTest := False;

      { allocate room for null terminated string }
      pZipFN       := StrAlloc( Length( NameOfZipFile ) + 1 );
      StrPLCopy( pZipFN, NameOfZipFile, Length( NameOfZipFile ) + 1 );    { name of zip file }
      pZipPassword := StrAlloc(  PWLEN + 1 );      { allocate room for null terminated string }
      StrPLCopy( pZipPassword, FPassword, PWLEN + 1 );  { password for encryption/decryption }
   end; { end with }
end;

procedure TZipMaster.GetAddPassword;
var
   s1, s2: ShortString;
begin
   FPassword := '';
   if FUnattended then
   begin
      ShowZipMessage( PW_UnatAddPWMiss, '' );
      Exit;
   end;
   s1 := InputBox( 'Password', 'Enter Password for New Archive','' );
   if (length(s1) >80) or (length(s1) = 0) then
      Exit;

   s2 := InputBox( 'Password', 'Confirm Password','' );
   if (length(s2) > 80) or (length(s2) = 0) then
      Exit;

   if CompareStr( s1, s2 ) <> 0 then
      ShowZipMessage( GE_WrongPassword, '' )
   else
      FPassword := s1;
end;

// Same as GetAddPassword, but does NOT verify
procedure TZipMaster.GetExtrPassword;
var
   s1: ShortString;
begin
   FPassword := '';
   if FUnattended then
   begin
      ShowZipMessage( PW_UnatExtPWMiss, '' );
      Exit;
   end;
   s1 := InputBox( 'Password', 'Enter Password', '' );
   if (length( s1 ) > 80) or (length( s1 ) = 0) then
      Exit;
   FPassword := s1;
end;

procedure TZipMaster.Add;
var
   i, L, DLLVers: Integer;
   AutoLoad:      Boolean;
   NewName:       Array [0..512] of Char;
   TmpZipName:    String;
   pFDS:         pFileData;
begin
   FSuccessCnt := 0;
   if fFSpecArgs.Count = 0 then
   begin
      ShowZipMessage( AD_NothingToZip, '' );
      Exit;
   end;
   { We must allow a zipfile to be specified that doesn't already exist,
     so don't check here for existance. }
   if FZipFilename = '' then   { make sure we have a zip filename }
   begin
      ShowZipMessage( GE_NoZipSpecified, '' );
      Exit;
   end;
   // We can not do an Unattended Add if we don't have a password.
   if FUnattended and (AddEncrypt in FAddOptions) and (FPassword = '') then
   begin
      ShowZipMessage( AD_UnattPassword, '' );
      Exit
   end;

   // If we are using disk spanning, first create a temporary file
   if (AddDiskSpan in FAddOptions) or (AddDiskSpanErase in FAddOptions) then
   begin
      // We can't do this type of Add() on a spanned archive.
      if (AddFreshen in FAddOptions) or (AddUpdate in FAddOptions) then
      begin
         ShowZipMessage( AD_NoFreshenUpdate, '' );
         Exit;
      end;
      // We can't make a spanned SFX archive
      if (UpperCase( ExtractFileExt( FZipFilename ) ) = '.EXE') then
      begin
         ShowZipMessage( DS_NoSFXSpan, '' );
         Exit;
      end;
      if FTempDir = '' then
      begin
         GetTempPath( MAX_PATH, @NewName );
         GetTempFileName( NewName, 'zip', 0, @NewName );
      end
      else
      begin
         FTempDir := AppendSlash( FTempDir );
         GetTempFileName( pChar( FTempDir ), 'zip', 0, @NewName );
      end;
      TmpZipName := NewName;
      DeleteFile( TmpZipName );  // make sure it doesn't exist already
      if FVerbose and Assigned( FOnMessage ) then
         FOnMessage( Self, 0, 'Temporary zipfile: ' + TmpZipName );
   end
   else
      TmpZipName := FZipFilename; // not spanned - create the outfile directly

   { Make sure we can't get back in here while work is going on }
   if FZipBusy then
      Exit;
   FZipBusy := True;
   FCancel  := False;

   if ( Uppercase( ExtractFileExt( FZipFilename ) ) = '.EXE')
     and (FSFXOffset = 0)
     and NOT FileExists( FZipFilename ) then
   begin
      { This is the first "add" operation following creation of a new
        .EXE archive.  We need to add the SFX code now, before we add
        the files. }
      AutoExeViaAdd := True;
      ConvertSFX;
      AutoExeViaAdd := False;
   end;

   if ZipDllHandle = 0 then
   begin
      AutoLoad := True;   // user's program didn't load the DLL
      Load_Zip_Dll;       // load it
   end
   else
      AutoLoad := False;  // user's pgm did load the DLL, so let him unload it
   if ZipDllHandle = 0 then
   begin
      FZipBusy := False;
      Exit;  // load failed - error msg was shown to user
   end;

   DLLVers := ZipVers;	// If DLL version < 151 we use the old ZipParams.
   try
      try
         if DLLVers < 151 then
         begin
            ZipParms.zp1 := AllocMem( SizeOf( ZipParms1 ) );
            SetZipSwitches( TmpZipName );
            with ZipParms.zp1^ do
            begin
               { Copy filenames from the Stringlist to new var's we will alloc
                 storage for.  This lets us append the null needed by the DLL. }
               for i := 0 to (fFSpecArgs.Count - 1) do
               begin
                  L := Length( fFSpecArgs[i] ) + 1;
                  PFilenames[i] := StrAlloc( L );  { alloc room for the filespec }
                  StrPLCopy( PFilenames[i], fFSpecArgs[i], L ); { file to add to archive }
               end;
               { argc is now the no. of filespecs we want deleted }
               Seven := 7;              { used to QC the data structure passed to DLL }
            end;  { end with }
         end else
         begin
            ZipParms.zp2 := AllocMem( SizeOf( ZipParms2 ) );
            SetZipSwitches( TmpZipName );
            with ZipParms.zp2^ do
            begin
               if Length( FTempDir ) <> 0 then   { New v1.51 }
               begin
                  fTempPath := StrAlloc( Length( FTempDir ) + 1 );
                  StrPLCopy( fTempPath, FTempDir, Length( FTempDir ) + 1 );
               end;
               fFDS := AllocMem( SizeOf( FileData ) * FFSpecArgs.Count );
               for i := 0 to (fFSpecArgs.Count - 1) do
               begin
                  pFDS := fFDS;
                  Inc( pFDS, i );
                  L := Length( fFSpecArgs[i] ) + 1;
                  pFDS.fFileSpec := StrAlloc( L );
                  StrPLCopy( pFDS.fFileSpec, fFSpecArgs[i], L );
               end;
               fSeven := 7;
            end;  { end with }
         end;  {end if < }
         ZipParms.zp1.argc := fSpecArgs.Count;
         { pass in a ptr to parms }
         fSuccessCnt := ZipDLLExec( Pointer( ZipParms.zp1 ) );
         // If Add was successful and we want spanning, copy the
         // temporary file to the destination.
         if (fSuccessCnt > 0) and
             ((AddDiskSpan in FAddOptions) or (AddDiskSpanErase in FAddOptions)) then
         begin
            // write the temp zipfile to the right target:
            if WriteSpan( TmpZipName, FZipFilename ) <> 0 then
               fSuccessCnt := 0;  // error occurred during write span
            DeleteFile( TmpZipName );
         end;
      except
         ShowZipMessage( GE_FatalZip, '' );
      end;
   finally
      fFSpecArgs.Clear;
      { Free the memory for the zipfilename and parameters }
      { we know we had a filename, so we'll dispose it's space }
      StrDispose( ZipParms.zp1.pZipFN );
      StrDispose( ZipParms.zp1.pZipPassword );
      if DLLVers < 151 then
      begin
         { loop thru each parameter filename and dispose it's space }
         for i := (ZipParms.zp1.argc - 1) downto 0 do
            StrDispose( ZipParms.zp1.pFilenames[i] );
         FreeMem( ZipParms.zp1 );
      end else
      begin
         with ZipParms.zp2^ do
         begin
            StrDispose( fTempPath );
            for i := (Argc - 1) downto 0 do
            begin
               pFDS := fFDS;
               Inc( pFDS, i );
               StrDispose( pFDS.fFileSpec );
            end;
            FreeMem( fFDS );
         end;
         FreeMem( ZipParms.zp2 );
      end;  { end if < }
      ZipParms.zp1 := nil;
   end;  {end try finally }

   if AutoLoad then
      Unload_Zip_Dll;

   FCancel  := False;
   FZipBusy := False;
   if fSuccessCnt > 0 then
      List;  { Update the Zip Directory by calling List method }
end;

procedure TZipMaster.Delete;
var
   i, L, DLLVers: Integer;
   AutoLoad:      Boolean;
   pFDS:         pFileData;
begin
   FSuccessCnt := 0;
   if fFSpecArgs.Count = 0 then
   begin
      ShowZipMessage( DL_NothingToDel, '' );
      Exit;
   end;
   if NOT FileExists( FZipFilename ) then
   begin
      ShowZipMessage( GE_NoZipSpecified, '' );
      Exit;
   end;

   { Make sure we can't get back in here while work is going on }
   if FZipBusy then
      Exit;
   FZipBusy := True;  { delete uses the ZIPDLL, so it shares the FZipBusy flag }
   FCancel  := False;

   if ZipDllHandle = 0 then
   begin
      AutoLoad := True;  // user's program didn't load the DLL
      Load_Zip_Dll;      // load it
   end
   else
      AutoLoad := False;  // user's pgm did load the DLL, so let him unload it
   if ZipDllHandle = 0 then
   begin
      FZipBusy := False;
      Exit;  // load failed - error msg was shown to user
   end;

   DLLVers := ZipVers;
   try
      try
         if DLLVers < 151 then
            ZipParms.zp1 := AllocMem( SizeOf( ZipParms1 ) )
 	 else
            ZipParms.zp2 := AllocMem( SizeOf( ZipParms2 ) );
         SetZipSwitches( fZipFileName );
         { override "add" behavior assumed by SetZipSwitches: }
         with ZipParms.zp1^ do
         begin
            fDeleteEntries := True;
            fGrow          := False;
            fJunkDir       := False;
            fMove          := False;
            fFreshen       := False;
            fUpdate        := False;
            fRecurse       := False;   // bug fix per Angus Johnson
            fEncrypt       := False;   // you don't need the pwd to delete a file
         end;
         if DLLVers < 151 then
         begin
            with ZipParms.zp1^ do
            begin
              { Copy filenames from the Stringlist to new var's we will alloc
                storage for.  This lets us append the null needed by the DLL. }
              for i := 0 to (fFSpecArgs.Count - 1) do
              begin
                 L := Length( fFSpecArgs[i] ) + 1;
                 PFilenames[i] := StrAlloc( L );  { alloc room for the filespec }
                 StrPLCopy( PFilenames[i], fFSpecArgs[i], L ); { file to del from archive }
              end;
              { argc is now the no. of filespecs we want deleted }
              Seven := 7;              { used to QC the data structure passed to DLL }
            end;  { end with }
         end else
         begin
            with ZipParms.zp2^ do
            begin
               if Length( FTempDir ) <> 0 then   { New v1.51 }
               begin
                  fTempPath := StrAlloc( Length( FTempDir ) + 1 );
                  StrPLCopy( fTempPath, FTempDir, Length( FTempDir ) + 1 );
               end;
               fFDS := AllocMem( SizeOf( FileData ) * FFSpecArgs.Count );
               for i := 0 to (fFSpecArgs.Count - 1) do
               begin
                  pFDS := fFDS;
                  Inc( pFDS, i );
                  L := Length( fFSpecArgs[i] ) + 1;
                  pFDS.fFileSpec := StrAlloc( L );
                  StrPLCopy( pFDS.fFileSpec, fFSpecArgs[i], L );
               end;
               fSeven := 7;
            end;  { end with }
         end;  {end if < }
         ZipParms.zp1.Argc := fSpecArgs.Count;
         { pass in a ptr to parms }
         fSuccessCnt := ZipDLLExec( Pointer( ZipParms.zp1 ) );
      except
         ShowZipMessage( GE_FatalZip, '' );
      end;
   finally
      fFSpecArgs.Clear;
      StrDispose( ZipParms.zp1.pZipFN );
      StrDispose( ZipParms.zp1.pZipPassword );
      if DLLVers < 151 then
      begin
         for i := (ZipParms.zp1.argc - 1) downto 0 do
            StrDispose( ZipParms.zp1.pFilenames[i] );
         FreeMem( ZipParms.zp1 );
      end else
      begin
         with ZipParms.zp2^ do
         begin
            StrDispose( fTempPath );
            for i := (Argc - 1) downto 0 do
            begin
               pFDS := fFDS;
               Inc( pFDS, i );
               StrDispose( pFDS.fFileSpec );
            end;
            FreeMem( fFDS );
         end;
         FreeMem( ZipParms.zp2 );
      end;
      ZipParms.zp1 := nil;
   end;

   if AutoLoad then
      Unload_Zip_Dll;
   FZipBusy := False;
   FCancel  := False;
   if fSuccessCnt > 0 then
      List;  { Update the Zip Directory by calling List method }
end;

procedure TZipMaster.Extract;
var
   i, L, UnzDLLVers: Integer;
   AutoLoad:         Boolean;
   TmpZipName:       String;
   pUFDS:           pUnzFileData;
   NewName:          Array [0..512] of Char;
begin
   FSuccessCnt := 0;
   if NOT FileExists( FZipFilename ) then
   begin
      ShowZipMessage( GE_NoZipSpecified, '' );
      Exit;
   end;

   { Make sure we can't get back in here while work is going on }
   if FUnzBusy then
      Exit;

   // We have to be carefull doing an unattended Extract when a password is needed
   // for some file in the archive.
   if FUnattended and (AddEncrypt in FAddOptions) and (FPassword = '') then
   begin
     // We set it to an unlikely password, this way encrypted files won't be extracted.
     FPassword := StringOfChar( '~', 79 );
     ShowZipMessage( EX_UnAttPassword, '' );
   end;

   FUnzBusy := True;
   FCancel  := False;

   if UnzDllHandle = 0 then
   begin
      AutoLoad := True;   // user's program didn't load the DLL
      Load_Unz_Dll;       // load it
   end
   else
      AutoLoad := False;  // user's pgm did load the DLL, so let him unload it
   if UnzDllHandle = 0 then
   begin
      FUnzBusy := False;
      Exit;  // load failed - error msg was shown to user
   end;

   // We do a check if we need UnSpanning first, this depends on
   // The number of the disk the EOC record was found on. ( provided by List() )
   // If we have a spanned set consisting of only one disk we don't use ReadSpan().
   if FTotalDisks <> 0 then
   begin
      if FTempDir = '' then
      begin
         GetTempPath( MAX_PATH, NewName );
         TmpZipName := NewName;
      end
      else TmpZipName := AppendSlash( FTempDir );
      if ReadSpan( FZipFilename, TmpZipName ) <> 0 then
         Exit;
      // We returned without an error, now  TmpZipName contains a real name.
   end
   else
      TmpZipName := FZipFilename;

   { Select the extract directory }
   if DirectoryExists( fExtrBaseDir ) then
      SetCurrentDir( fExtrBaseDir );
   UnzDLLVers := UnzVers;
   try
      try
         if UnzDLLVers < 152 then
         begin
            UnZipParms.up1 := AllocMem( SizeOf( UnZipParms1 ) );
            SetUnZipSwitches( TmpZipName );
            with UnzipParms.up1^ do
            begin
               { Copy filenames from the Stringlist to new var's we will alloc
                 storage for.  This lets us append the null needed by the DLL. }
               for i := 0 to (fFSpecArgs.Count - 1) do
               begin
                  L := Length( fFSpecArgs[i] ) + 1;
                  PFilenames[i] := StrAlloc( L );  { alloc room for the filespec }
                  StrPLCopy( PFilenames[i], fFSpecArgs[i], L ); { file to extr from archive }
               end;
               Seven := 7;
            end;
         end else
         begin
            UnZipParms.up2 := AllocMem( SizeOf( UnZipParms2 ) );
            SetUnZipSwitches( TmpZipName );
            with UnzipParms.up2^ do
            begin
               fUFDS := AllocMem( SizeOf(UnzFileData) * FFSpecArgs.Count );
               for i := 0 to (fFSpecArgs.Count - 1) do
               begin
                  pUFDS := fUFDS;
                  Inc( pUFDS, i );
                  L := Length( fFSpecArgs[i] ) + 1;
                  pUFDS.fFileSpec := StrAlloc( L );
                  StrPLCopy( pUFDS.fFileSpec, fFSpecArgs[i], L );
               end;
               fSeven := 7;
            end;
         end;
         { Set Argc to the no. of filespecs we want extracted }
         UnZipParms.up1.fArgc := fSpecArgs.Count;
         { pass in a ptr to parms }
         fSuccessCnt := UnzDLLExec( Pointer( UnZipParms.up1 ) );
         // If UnSpanned we still have this temporary file hanging around.
         if FTotalDisks > 0 then
            DeleteFile( TmpZipName );
      except
         ShowZipMessage(  EX_FatalUnZip, '' );
      end;
   finally
      fFSpecArgs.Clear;
      StrDispose( UnZipParms.up1.pZipFN );
      StrDispose( UnZipParms.up1.pZipPassword );
      { Free the memory }
      if UnzDLLVers < 152 then
      begin
         for i := (UnZipParms.up1.fArgc - 1) downto 0  do
            StrDispose( UnZipParms.up1.pFilenames[i] );
         FreeMem( UnZipParms.up1 );
      end else
      begin
         with UnZipParms.up2^ do
         begin
            for i := (fArgc - 1) downto 0 do
            begin
               pUFDS := fUFDS;
               Inc( pUFDS, i );
               StrDispose( pUFDS.fFileSpec );
            end;
            FreeMem( fUFDS );
         end;
         FreeMem( UnZipParms.up2 );
      end;
      UnZipParms.up1 := nil;
   end;

   if AutoLoad then
      Unload_Unz_Dll;
   FCancel  := False;
   FUnzBusy := False;
   { no need to call the List method; contents unchanged }
end;

//---------------------------------------------------------------------------
// Returns 0 if good copy, or a negative error code.
function TZipMaster.CopyFile( Const InFileName, OutFileName: String ): Integer;
const
   SE_CreateError   = -1;	{ Error in open or creation of OutFile. }
   SE_OpenReadError = -3;	{ Error in open or Seek of InFile.      }
   SE_SetDateError  = -4;	{ Error setting date/time of OutFile.   }
   SE_GeneralError  = -9;
var
   InFile, OutFile, InSize, OutSize: Integer;
begin
   InSize  := -1;
   OutSize := -1;
   Result  := SE_OpenReadError;

   if NOT FileExists( InFileName ) then Exit;
   Screen.Cursor := crHourGlass;
   InFile := FileOpen( InFileName, fmOpenRead or fmShareDenyWrite );
   if InFile <> -1 then
   begin
      if FileExists( OutFileName ) then
         EraseFile( OutFileName, FHowToDelete );
      OutFile := FileCreate( OutFileName );
      if OutFile <> -1 then
      begin
         Result := CopyBuffer( InFile, OutFile, -1 );
         if (Result = 0) and (FileSetDate( OutFile, FileGetDate( InFile ) ) <> 0 ) then
            Result := SE_SetDateError;
         OutSize := FileSeek( OutFile, 0, 2 );
         FileClose( OutFile );
      end else
         Result := SE_CreateError;
      InSize := FileSeek( InFile, 0, 2 );
      FileClose( InFile );
   end;
   // An extra check if the filesizes are the same.
   if (Result = 0) and ((InSize = -1) or (OutSize = -1) or (InSize <> OutSize)) then
      Result := SE_GeneralError;
   // Don't leave a corrupted outfile lying around. (SetDateError is not fatal!)
   if (Result <> 0) and (Result <> SE_SetDateError) then
      DeleteFile( OutFileName );

   Screen.Cursor := crDefault;
end;

{ Delete a file and put it in the recyclebin on demand. }
function TZipMaster.EraseFile( Const Fname: String; How: DeleteOpts ): Integer;
var
   SHF: TSHFileOpStruct;
begin
   Result := -1;
   // We need to be able to 'Delete' without getting an error
   // if the file does not exists as in ReadSpan() can occur.
   if NOT FileExists( Fname ) then
      Exit;
   With SHF do begin
      Wnd    := Application.Handle;
      wFunc  := FO_DELETE;
      pFrom  := pChar( Fname + #0 );
      pTo    := nil;
      fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
      if How = htdAllowUndo then
         fFlags := fFlags or FOF_ALLOWUNDO;
   end;
   Result := SHFileOperation( SHF );
end;

{ Convert an .ZIP archive to a .EXE archive. }
{ returns 0 if good, or else a negative error code }
function TZipMaster.ConvertSFX: Integer;
Const
   SE_CreateError   = -1;  { error in open of outfile }
   SE_CopyError     = -2;  { read or write error during copy }
   SE_OpenReadError = -3;  { error in open of infile }
   SE_SetDateError  = -4;  { error setting date/time of outfile }
   SE_GeneralError  = -9;
var
   InFile, OutFile:   Integer;
   Buffer:           pBuffer;
   OutFileName:       String;
   ZipSize, SFXSize:  Integer;
   OutSize:           Integer;
   i, j:              Integer;
   dirbuf:            Array [0..MAX_PATH] of Char;
   sfxblk:            Array [0..255] of Byte;
   cll:               Byte;
   EOC:               ZipEndOfCentral;
Begin
   Result  :=  SE_GeneralError;
   SFXSize := -1;
   ZipSize := -1;
   OutSize := -1;

   if (NOT FileExists( FZipFilename )) and (NOT AutoExeViaAdd) then
   begin
      ShowZipMessage( GE_NoZipSpecified, '' );
      Exit;
   end;

   { Do a simple validation to ensure that the 3 variable length text
     fields are small enough to fit inside the SFX control block. }
   i := Length( FSFXCaption ) + Length( FSFXDefaultDir ) + Length( FSFXCommandLine );
   if i > 249 then
   begin
      ShowZipMessage( SF_StringToLong, #13#10 + 'SFXCaption + SFXDefaultDir + SFXCommandLine = ' + IntToStr( i ) );
      Exit;
   end;

   // Try to find the SFX binary file: ZIPSFX.BIN
   // Look in the location given by the SFXPath property first.
   repeat
      if FileExists( FSFXPath ) then
         Break;
      // Try the current directory.
      FSFXPath := 'ZipSFX.bin';
      if FileExists( FSFXPath ) then
         Break;
      // Try the application directory.
      FSFXPath := ExtractFilePath( ParamStr( 0 ) ) + '\ZipSFX.bin';
      if FileExists( FSFXPath ) then
         Break;
      // Try the Windows System dir.
      GetSystemDirectory( dirbuf, MAX_PATH );
      FSFXPath := AnsiString( dirbuf ) + '\ZipSFX.bin';
      if FileExists( FSFXPath ) then
         Break;
      // Try the Windows dir.
      GetWindowsDirectory( dirbuf, MAX_PATH );
      FSFXPath := AnsiString( dirbuf ) + '\ZipSFX.bin';
      if FileExists( FSFXPath ) then
         Break;
      // Try the dir specified in the DLLDirectory property.
      FSFXPath := FDLLDirectory + '\ZipSFX.bin';
      if (FDLLDirectory <> '') and FileExists( FSFXPath ) then
         Break;
      ShowZipMessage( SF_NoZipSFXBin, '' );
      FSFXPath := '';
      Exit;
   until ( False );

   Screen.Cursor := crHourGlass;

   { Create the special SFX parameter block }
   FillChar( sfxblk, SizeOf(sfxblk), 0 );
   sfxblk[0] := Byte('M');
   sfxblk[1] := Byte('P');
   sfxblk[2] := Byte('U');

   { create a packed byte with various 1 bit settings }
   cll := 0;
   if SFXAskCmdLine in FSFXOptions then
      cll := 1;        // don't ask user if he wants to run cmd line
   if SFXAskFiles in FSFXOptions then
      cll := cll or 2; // allow user to edit files in selection box
   if SFXHideOverWriteBox in FSFXOptions then
      cll := cll or 4; // hide overwrite mode box at runtime
   case FSFXOverWriteMode of    // dflt = ovrConfirm
      ovrAlways: cll := cll or 8;
      ovrNever:  cll := cll or 16;
   end;
   if NOT (SFXCheckSize in FSFXOptions) then
      cll := cll or 32; // prevent the Self-check of SFX archive at expand time
   if SFXAutoRun in fSFXOptions then
      cll := cll or 64; // autorun

   sfxblk[3] := cll;

   sfxblk[4] := Length( FSFXCaption );
   sfxblk[5] := Length( FSFXDefaultDir );
   sfxblk[6] := Length( FSFXCommandLine );
   j:=6;

   // There are 249 remaining bytes in the control block to hold all
   // 3 variable length strings.  This should be enough.
   for i := 1 to Length( FSFXCaption ) do
      sfxblk[j + i] := Byte(FSFXCaption[i]);
   j := j + Length( FSFXCaption );
   for i := 1 to Length( FSFXDefaultDir ) do
      sfxblk[j + i] := Byte(FSFXDefaultDir[i]);
   j := j + Length( FSFXDefaultDir );
   for i := 1 to Length( FSFXCommandLine ) do
      sfxblk[j + i] := Byte(FSFXCommandLine[i]);

   if AutoExeViaAdd then
      { We're going to add SFX code to a new archive just created with
        an extension of .EXE }
      OutFileName := FZipFilename  // already ends in .exe
   else
   begin
      if UpperCase( ExtractFileExt( FZipFilename ) ) <> '.ZIP' then
      begin
         ShowZipMessage( SF_InputIsNoZip, '' );
         Exit;
      end;
      OutFileName := ChangeFileExt( FZipFilename, '.exe' );
   end;

   if FileExists( OutFileName ) then
      EraseFile( OutFileName, FHowToDelete );
   OutFile := FileCreate( OutFileName );
   if ( OutFile <> -1 ) then
   begin
      // Copy the SFX code to destination .EXE file.
      InFile := FileOpen( SFXPath, fmOpenRead or fmShareDenyWrite );
      if ( InFile <> -1 ) then
      begin
         Result  := CopyBuffer( InFile, OutFile, -1 );
         SFXSize := FileSeek( InFile, 0, 2 );
	 FileClose( InFile );
      end
      else Result := SE_OpenReadError;
      // Copy the special SFX block to the destination.
      if Result = 0 then
      begin
         Buffer := @sfxblk;
         if FileWrite( OutFile, Buffer^, 256 ) <> 256 then
            Result := SE_CopyError;
         if Result = 0 then
         begin
            if AutoExeViaAdd then
            begin
               FillChar( EOC, SizeOf(EOC), 0 );
               EOC.HeaderSig     := EndCentralDirSig;
               EOC.CentralOffset := SFXSize + 256;	// Central offset=EOC offset=end of SFX code.
               // Copy the EOC header to the .exe file.
               if FileWrite( OutFile, EOC, SizeOf( EOC ) ) <> SizeOf(EOC) then
                  Result := SE_CopyError;
               // Let's close the file and get out - we don't
               // have a zipfile to append in this case.
            end
            else begin
	       // Copy the ZIP file to the destination (BUG fix)
               try
                  CheckIfLastDisk( EOC, True );	// Read the EOC or we get an exception.
                  FileSeek( FInFileHandle, 0, 0 );
		  // If we got a warning in List() we assume it's a pre v1.5 .ZIP.
                  // (converted back from a .EXE ) and we will not change the offsets.
                  if FWrongZipStruct then
                  begin
                     Result  := CopyBuffer( FInFileHandle, OutFile, -1 );
                     ZipSize := FRealFileSize;
                  end else
                  begin
                     // Copy until we get at the start of the central header.
                     Result := CopyBuffer( FInFileHandle, OutFile, EOC.CentralOffset );
                     if Result = 0 then     // Now read all headers and change the offsets.
                        Result := RWCentralDir( OutFile, EOC, SFXSize + 256 );
                     ZipSize := FFileSize;  // Garbage is now removed if it were present.
                  end;
               except
                  Result := SE_OpenReadError;
               end;
               if FInFileHandle <> -1 then
                  FileClose(  FInFileHandle );
            end;
         end;
      end;
      OutSize := FileSeek( OutFile, 0, 2 );
      FileClose( OutFile );
   end else
      Result := SE_CreateError;

   if (Result <> 0) or (AutoExeViaAdd = False) then
   begin
      // An extra check if file is ok.
      if (Result = 0) and ((SFXSize = -1) or (ZipSize = -1) or (OutSize = -1) or (OutSize <> SFXSize + ZipSize + 256)) then
         Result := SE_GeneralError;

      if Result = 0 then
      begin
         EraseFile( FZipFilename, FHowToDelete );
         ZipFileName := OutFileName;   // The .EXE file is now the default archive andList() is invoked.
      end else
         DeleteFile( OutFileName );
   end;
   Screen.Cursor := crDefault;
End;


function TZipMaster.CopyBuffer( InFile: Integer; OutFile: Integer; ReadLen: Integer ): Integer;
Const
   SE_CopyError = -2;  // Write error or no memory during copy.
var
   SizeR, ToRead:  Integer;
   Buffer:        pBuffer;
begin
   // both files are already open
   Result := 0;
   ToRead := BufSize;
   Buffer := nil;
   try
      New( Buffer ); // RCV: Moved, EOutOfMemory is possible!!!
      repeat
         if ReadLen >= 0 then
         begin
            ToRead := ReadLen;
            if BufSize < ReadLen then ToRead := BufSize;
         end;
         // ShowMessage( 'ewe: copybuffer asked to read this many bytes: ' + IntToStr( ToRead ) );
         SizeR := FileRead( InFile, Buffer^, ToRead );
         if FileWrite( OutFile, Buffer^, SizeR ) <> SizeR then
         begin
            Result := SE_CopyError;
            break;
         end;
         if ReadLen > 0 then
            Dec( ReadLen, SizeR );
         Application.ProcessMessages; // Mostly for winsock.
      until( (ReadLen = 0) or (SizeR <> ToRead) );
   except
      Result := SE_CopyError;
   end;
   if Buffer <> nil then
      Dispose( Buffer );
   // leave both files open
end;

//---------------------------------------------------------------------------
// Function to copy the central header of an archive and change while copying
// the Local Header offsets and finally the Central Header offset.
// We return 0 if no error or -2 (SE_CopyError) in case something goes wrong.
function TZipMaster.RWCentralDir( OutFile:Integer; EOC: ZipEndOfCentral; OffsetChange: Integer ): Integer;
var
   CEH: ZipCentralHeader;
   i:   Integer;
begin
   Result := 0;
   try
      //ShowMessage( 'EWE: tot entries: ' + IntToStr(EOC.TotalEntries) );
      for i := 0 to (EOC.TotalEntries - 1) do
      begin
         // Read a central header (a dir entry for 1 file)
         if FileRead( FInFileHandle, CEH, SizeOf(CEH) ) <> SizeOf(CEH) then
            raise EZipMaster.CreateResDisp( DS_CEHBadRead, True );
         if CEH.HeaderSig <> CentralFileHeaderSig then
            raise EZipMaster.CreateResDisp( DS_CEHWrongSig, True );
         // Change the offset
         CEH.RelOffLocal := Integer(CEH.RelOffLocal) + OffsetChange;
         // Write this changed central header to disk
         if FileWrite( OutFile, CEH, SizeOf(CEH) ) <> SizeOf(CEH) then
            raise EZipMaster.CreateResDisp( DS_CEHBadWrite, True );
         // And the remaining bytes of the central header for this file
         if CopyBuffer( FInFileHandle, OutFile, CEH.FileNameLen + CEH.ExtraLen + CEH.FileComLen ) <> 0 then
            raise EZipMaster.CreateResDisp( DS_CEHBadCopy, True );
      end;

      // Skip the EOC record (we already have read it.)
      if FileSeek( FInFileHandle, SizeOf(EOC), 1 ) = -1 then
         raise EZipMaster.CreateResDisp( DS_EOCBadSeek, True );
      // Write the changed EndOfCentral directory record.
      EOC.CentralOffset := Integer(EOC.CentralOffset) + OffsetChange;
      if FileWrite( OutFile, EOC, SizeOf(EOC) ) <> SizeOf(EOC) then
         raise EZipMaster.CreateResDisp( DS_EOCBadWrite, True );
      // And finally the archive comment
      if CopyBuffer( FInFileHandle, OutFile, EOC.ZipCommentLen ) <> 0 then
         raise EZipMaster.CreateResDisp( DS_EOCBadCopy, True );
   except
      //ShowZipMessage( 0, 'Exception in RWCentralDir' );
      //ShowMessage( 'EWE:  i=' + IntToStr(i) );
      Result := -2;
   end;
end;

{ Convert an .EXE archive to a .ZIP archive. }
{ returns 0 if good, or else a negative error code }
function TZipMaster.ConvertZIP:Integer;
Const
   SE_CreateError   = -1;  { error in open of outfile }
   SE_CopyError     = -2;  { read or write error during copy }
   SE_OpenReadError = -3;  { error in open of infile }
   SE_GeneralError  = -9;
var
   OutFileName:              String;
   OutFile, InSize, OutSize: Integer;
   EOC:                      ZipEndOfCentral;
begin
   InSize  := -1;
   OutSize := -1;
   Result  := SE_GeneralError;

   if NOT FileExists( FZipFilename ) then
   begin
      ShowZipMessage( CZ_NoExeSpecified, '' );
      Result := SE_OpenReadError;
      Exit;
   end;

   if UpperCase( ExtractFileExt( FZipFilename ) ) <> '.EXE' then
   begin
      ShowZipMessage( CZ_InputNotExe, '' );
      Result := SE_OpenReadError;
      Exit;
   end;

   // The FSFXOffset is the location where the zip file starts inside
   // the .EXE archive.  It is calculated during a ZipMaster List operation.
   // Since a LIST is done when a filename is assigned, we know that
   // a LIST has already been done on the correct archive.
   // Note: FSFXOffset = SFXSize + 256
   if FSFXOffset = 0 then
   begin
      ShowZipMessage( CZ_SFXTypeUnknown, '' );
      Exit;
   end;

   // Create the destination.
   Screen.Cursor := crHourGlass;
   Result        := SE_CopyError;
   OutFileName   := ChangeFileExt( FZipFilename, '.zip' );

   if FileExists( OutFileName ) then
      EraseFile( OutFileName, FHowToDelete );
   OutFile := FileCreate( OutFileName );
   if ( OutFile <> -1 ) then
   begin
      try
         CheckIfLastDisk( EOC, True );   // Read the EOC record or we get an exception.
	 // Step over SFX code at the begin of the .EXE file.
         if FileSeek( FInFileHandle, FSFXOffset, 0 ) <> -1 then
         begin
            // If we got a warning in List() we assume it's a pre v1.5 .EXE.
            // and we will not change the offsets.
            if FWrongZipStruct = True then
            begin
               Result := CopyBuffer( FInFileHandle, OutFile, -1 );
               InSize := FRealFileSize;
            end else
            begin
               // Copy until the start of the first Central header.
               Result := CopyBuffer( FInFileHandle, OutFile, EOC.CentralOffset - Longword(FSFXOffset) );
               if Result = 0 then   // Now read all headers and change the offsets.
                  Result := RWCentralDir( OutFile, EOC, -FSFXOffset );
               InSize := FFileSize;
            end;
         end;
      except
         Result := SE_OpenReadError;
      end;
      if FInFileHandle <> -1 then
         FileClose( FInFileHandle );
      OutSize := FileSeek( OutFile, 0, 2 );
      FileClose( OutFile );
   end else
      Result := SE_CreateError;

   if (Result = 0) and ((InSize = -1) or (OutSize = -1) or (OutSize <> InSize - FSFXOffset)) then
      Result := SE_GeneralError;

   if Result = 0 then
   begin
      EraseFile( FZipFilename, FHowToDelete );
      ZipFileName := OutFileName;      // The .ZIP file is now the default archive and invoke List().
   end else
      DeleteFile( OutFileName );

   Screen.Cursor := crDefault;
end;

//---------------------------------------------------------------------------
// Function to find the EOC record at the end of the archive (on the last disk.)
// We can get a return value( true::Found, false::Not Found ) or an exception if not found.
function TZipMaster.CheckIfLastDisk( var EOC: ZipEndOfCentral; DoExcept: boolean ): boolean;
var
   Sig:                 Cardinal;
   DiskNo, Size, i, j:  Integer;
   ShowGarbageMsg:      Boolean;
   First:               Boolean;
   ZipBuf:             pChar;
begin
   FZipComment := '';
   First       := False;
   DiskNo      := 0;
   ZipBuf      := nil;
   FZipEOC     := 0;

   // Open the input archive, presumably the last disk.
   FInFileHandle := FileOpen( FInFileName, fmShareDenyWrite or fmOpenRead );
   if FInFileHandle = -1 then
   begin
      if DoExcept = True then
         raise EZipMaster.CreateResDisp( DS_NoInFile, True );
      ShowZipMessage( DS_FileOpen, '' );
      Result := False;
      Exit;
   end;

   // Get the volume number if it's disk from a set.
   if Pos( 'PKBACK# ', FVolumeName ) = 1 then
      DiskNo := StrToIntDef( Copy( FVolumeName, 9, 3 ), 0 );

   // First a check for the first disk of a spanned archive,
   // could also be the last so we don't issue a warning yet.
   if (FileRead( FInFileHandle, Sig, 4 ) = 4) and (Sig = ExtLocalSig) and
        (FileRead( FInFileHandle, Sig, 4 ) = 4) and (Sig = LocalFileHeaderSig) then
   begin
      First      := True;
      FIsSpanned := True;
   end;

   // Next we do a check at the end of the file to speed things up if
   // there isn't a Zip archive comment.
   FFileSize := FileSeek( FInFileHandle, -SizeOf( EOC ), 2 );
   if FFileSize <> -1 then
   begin
      Inc( FFileSize, SizeOf( EOC ) );    // Save the archive size as a side effect.
      FRealFileSize := FFileSize;         // There could follow a correction on FFileSize.
      if (FileRead( FInFileHandle, EOC, SizeOf( EOC ) ) = SizeOf( EOC )) and
        (EOC.HeaderSig = EndCentralDirSig ) then
      begin
         FZipEOC := FFileSize - SizeOf( EOC );
         Result  := True;
         Exit;
      end;
   end;

   // Now we try to find the EOC record within the last 65535 + sizeof( EOC ) bytes
   // of this file because we don't know the Zip archive comment length at this time.
   try
      Size := 65535 + SizeOf( EOC );
      if FFileSize < Size then
         Size := FFileSize;
      GetMem( ZipBuf, Size + 1 );
      if FileSeek( FInFileHandle, -Size, 2 ) = -1 then
         raise EZipMaster.CreateResDisp( DS_FailedSeek, True );
      if NOT (FileRead( FInFileHandle, ZipBuf^, Size ) = Size) then
         raise EZipMaster.CreateResDisp( DS_EOCBadRead, True );
      for i := Size - SizeOf( EOC )- 1 downto 0 do
      if (ZipBuf[i] = 'P') and (ZipBuf[i + 1] = 'K') and (ZipBuf[i + 2] = #$05) and (ZipBuf[i + 3] = #$06) then
      begin
         FZipEOC := FFileSize - Size + i;
         Move( ZipBuf[i], EOC, SizeOf( EOC ) );  // Copy from our buffer to the EOC record.
         // Check if we really are at the end of the file, if not correct the filesize
         // and give a warning. (It should be an error but we are nice.)
         if NOT (i + SizeOf( EOC ) + EOC.ZipCommentLen - Size = 0) then
         begin
            Inc( FFileSize, i + SizeOf( EOC ) + Integer( EOC.ZipCommentLen ) - Size );
            // Now we need a check for WinZip Self Extractor which makes SFX files which
            // allmost always have garbage at the end (Zero filled at 512 byte boundary!)
            // In this special case 'we' don't give a warning.
            ShowGarbageMsg := True;
            if (FRealFileSize - Cardinal(FFileSize) < 512) and ((FRealFileSize mod 512) = 0) then
            begin
               j := i + SizeOf( EOC ) + EOC.ZipCommentLen;
               while (ZipBuf[j] = #0) and (j <= Size) do Inc(j);
               if j = Size + 1 then
                  ShowGarbageMsg := False;
            end;
            if ShowGarbageMsg then
               ShowZipMessage( LI_GarbageAtEOF, '' );
         end;
         // If we have ZipComment: Save it, must be after Garbage check because a #0 is set!
         if NOT (EOC.ZipCommentLen = 0) then
         begin
            ZipBuf[ i + SizeOf( EOC ) + EOC.ZipCommentLen ] := #0;
            FZipComment := ZipBuf + i + SizeOf( EOC );   // No codepage translation yet, wait for CEH read.
         end;
         FreeMem( ZipBuf );
         Result := True;
         Exit;
      end;
      FreeMem( ZipBuf );
   except
      FreeMem( ZipBuf );
      if DoExcept = True then raise;
   end;
   if DoExcept = True then
   begin
      if (First = False) and (DiskNo <> 0) then
         raise EZipMaster.CreateResDisk( DS_NotLastInSet, DiskNo );
      if First = True then
         if DiskNo = 1 then
            raise EZipMaster.CreateResDisp( DS_FirstInSet, True )
         else
            raise EZipMaster.CreateResDisp( DS_FirstFileOnHD, True )
      else
         raise EZipMaster.CreateResDisp( DS_NoValidZip, True );
   end;
   Result := False;
end;

procedure TZipMaster.Load_Zip_Dll;
var
   fullpath: String;
begin
   // This is new code that tries to locate the DLL before loading it.
   // The user can specify a dir in the DLLDirectory property.
   // The user's dir is our first choice, but we'll still try the
   // standard Windows DLL dirs (Windows, Windows System, Current dir).
   fullpath := '';
   if FDLLDirectory <> '' then
      if FileExists( FDLLDirectory + '\ZIPDLL.DLL' ) then
         fullpath := FDLLDirectory + '\ZIPDLL.DLL';
   if fullpath = '' then
      fullpath := 'ZIPDLL.DLL';  // Let Windows search the std dirs

   SetErrorMode( SEM_FAILCRITICALERRORS or SEM_NOGPFAULTERRORBOX );
   try
      ZipDllHandle := LoadLibrary( pChar( fullpath ) );
      if ZipDllHandle > HInstance_Error then
      begin
         if FTrace then
            ShowZipMessage(  LZ_ZipDllLoaded, '' );
         @ZipDllExec := GetProcAddress( ZipDllHandle, 'ZipDllExec' );
         @GetZipDllVersion := GetProcAddress( ZipDllHandle, 'GetZipDllVersion' );
         if @ZipDllExec = nil then
            ShowZipMessage( LZ_NoZipDllExec, '' );
         if @GetZipDllVersion = nil then
            ShowZipMessage( LZ_NoZipDllVers, '' );
      end
      else
      begin
         ZipDllHandle := 0; {reset}
         ShowZipMessage(  LZ_NoZipDll, '' );
      end;
   except
   end;
   SetErrorMode( 0 );
end;

procedure TZipMaster.Load_Unz_Dll;
var
   fullpath: String;
begin
   // This is new code that tries to locate the DLL before loading it.
   // The user can specify a dir in the DLLDirectory property.
   // The user's dir is our first choice, but we'll still try the
   // standard Windows DLL dirs (Windows, Windows System, Current dir).
   fullpath := '';
   if FDLLDirectory <> '' then
      if FileExists( FDLLDirectory + '\UNZDLL.DLL' ) then
         fullpath := FDLLDirectory + '\UNZDLL.DLL';
   if fullpath = '' then
      fullpath := 'UNZDLL.DLL';  // Let Windows search the std dirs

   SetErrorMode( SEM_FAILCRITICALERRORS or SEM_NOGPFAULTERRORBOX );
   try
      UnzDllHandle := LoadLibrary( pChar( fullpath ) );
      if UnzDllHandle > HInstance_Error then
      begin
         if FTrace then
            ShowZipMessage( LU_UnzDllLoaded, '' );
         @UnzDllExec := GetProcAddress( UnzDllHandle, 'UnzDllExec' );
         @GetUnzDllVersion := GetProcAddress( UnzDllHandle, 'GetUnzDllVersion' );
         if @UnzDllExec = nil then
            ShowZipMessage(  LU_NoUnzDllExec, '' );
         if @GetUnzDllVersion = nil then
            ShowZipMessage(  LU_NoUnzDllVers, '' );
      end
      else
      begin
         UnzDllHandle := 0; {reset}
         ShowZipMessage( LU_NoUnzDll, '' );
      end;
   except
   end;
   SetErrorMode( 0 );
end;

procedure TZipMaster.Unload_Zip_Dll;
begin
   if ZipDllHandle <> 0 then
      FreeLibrary( ZipDllHandle );
   ZipDllHandle := 0;
end;

procedure TZipMaster.Unload_Unz_Dll;
begin
   if UnzDllHandle <> 0 then
      FreeLibrary( UnzDllHandle );
   UnzDllHandle := 0;
end;

{ Replacement for the functions DiskFree and DiskSize. }
{ This should solve problems with drives > 2Gb and UNC filenames. }
{ Path FDrive ends with a backslash. }
{ Action=1 FreeOnDisk, 2=SizeOfDisk, 3=Both }
procedure TZipMaster.DiskFreeAndSize( Action: Integer );   // RCV150199
var
   GetDiskFreeSpaceEx: function( RootName: pChar; var FreeForCaller, TotNoOfBytes: LargeInt; TotNoOfFreeBytes: pLargeInt ): BOOL; stdcall;
   SectorsPCluster, BytesPSector, FreeClusters, TotalClusters: DWORD;
   LDiskFree, LSizeOfDisk: LargeInt;
   Lib: THandle;
begin
   LDiskFree   := -1;
   LSizeOfDisk := -1;
   Lib := GetModuleHandle( 'Kernel32' );
   If Lib <> 0 then
   begin
      @GetDiskFreeSpaceEx := GetProcAddress( Lib, 'GetDiskFreeSpaceExA' );
      if ( @GetDiskFreeSpaceEx <> nil ) then   // We probably have W95+OSR2 or better.
         if GetDiskFreeSpaceEx( pChar( FDrive ), LDiskFree, LSizeOfDisk, nil ) then
         begin
            LDiskFree   := -1;
            LSizeOfDisk := -1;
         end;
      FreeLibrary( Lib );  //v1.52i
   end;
   if ( LDiskFree = -1 ) then   // We have W95 original or W95+OSR1 or an error.
   begin   // We use this because DiskFree/Size don't support UNC drive names.
      if GetDiskFreeSpace( pChar( FDrive ), SectorsPCluster, BytesPSector, FreeClusters, TotalClusters ) then
      begin
         LDiskFree   := {$IfDef VERD4B4}LargeInt( BytesPSector )
                        {$Else}        (1.0 * BytesPSector){$EndIf}
                      * SectorsPCluster * FreeClusters;
         LSizeOfDisk := {$IfDef VERD4B4}LargeInt( BytesPSector )
                        {$Else}        (1.0 * BytesPSector){$EndIf}
                      * SectorsPCluster * TotalClusters;
      end;
   end;
   if (Action and 1) <> 0 then
      FFreeOnDisk := LDiskFree;
   if (Action and 2) <> 0 then
      FSizeOfDisk := LSizeOfDisk;
end;

// Check to see if drive in FDrive is a valid drive.
// If so, put it's volume label in FVolumeName,
//        put it's size in FSizeOfDisk,
//        put it's free space in FDiskFree,
//        and return true.
// If not valid, return false.
// Called by List() and CheckForDisk().
function TZipMaster.IsDiskPresent: Boolean;
var
   SysFlags, OldErrMode: DWord;
   NamLen:               Cardinal;
   SysLen:               {$IfDef VERD4B4}Cardinal{$Else}Integer{$EndIf};
   VolNameAry:           Array[0..255] of Char;
   Num:                  Integer;
   Bits:                 Set of 0..25;
   DriveLetter:          Char;
begin
   NamLen      := 255;
   SysLen      := 255;
   FSizeOfDisk := 0;
   FDiskFree   := 0;
   FVolumeName := '';
   Result      := False;
   DriveLetter := UpperCase( FDrive )[1];

   //ShowMessage( 'in IsDiskPresent: drive: ' + FDrive );
   if DriveLetter <> '\' then  // Only for local drives
   begin
      if (DriveLetter < 'A') or (DriveLetter > 'Z') then
          raise EZipMaster.CreateResDrive( DS_NotaDrive, FDrive );

      Integer(Bits) := GetLogicalDrives();
      Num := Ord( DriveLetter ) - Ord( 'A' );
      if NOT (Num in Bits) then
         raise EZipMaster.CreateResDrive( DS_DriveNoMount, FDrive );
   end;

   OldErrMode := SetErrorMode( SEM_FAILCRITICALERRORS );   // Turn off critical errors:

   // Since v1.52c no exception will be raised here; moved to List() itself.
  // if NOT GetVolumeInformation( pChar( FDrive ), VolNameAry, NamLen, @FDiskSerial, SysLen, SysFlags, nil, 0 ) then
  // begin
      // W'll get this if there is a disk but it is not or wrong formatted
      // so this disk can only be used when we also want formatting.
    //  if (GetLastError() = 31) and (AddDiskSpanErase in FAddOptions) then
      //   Result := True;
      //SetErrorMode( OldErrMode );  //v1.52i
      //Exit;
   //end;

   FVolumeName := VolNameAry;
   { get free disk space and size. }
   DiskFreeAndSize( 3 );  // RCV150199

   SetErrorMode( OldErrMode );   // Restore critical errors:

   // -1 is not very likely to happen since GetVolumeInformation catches errors.
   // But on W95(+OSR1) and a UNC filename w'll get also -1, this would prevent
   // opening the file. !!!Potential error while using spanning with a UNC filename!!!
   if (DriveLetter = '\') or ( (DriveLetter <> '\') and (FSizeOfDisk <> -1) ) then
      Result := True;
end;


function TZipMaster.CheckForDisk: Integer;
var
   drt:           Integer;   // drive type
   Res, MsgFlag:  Integer;
   SizeOfDisk:    LargeInt;  // RCV150199
   MsgStr:        String;
begin
   Application.ProcessMessages;
   drt     := GetDriveType( pChar( FDrive ) );
   Res     := IDOK;
   MsgFlag := MB_OKCANCEL;
   //ShowMessage( 'in CheckForDisk, we have a drt of: ' + IntToStr( drt ) );

   // First check if we want a new one or if there is a disk (still) present.
   while ( ((Res = IDOK) and NOT IsDiskPresent) or FNewDisk ) do
   begin
      if ( (drt = DRIVE_FIXED) or (drt = DRIVE_REMOTE) ) then
      begin       // If it is a fixed disk we don't want a new one.
         FNewDisk := False;
         break;
      end;
      if FUnattended then
         raise EZipMaster.CreateResDisp( DS_NoUnattSpan, True );
      if FDiskNr < 0 then   // -1=ReadSpan(), 0=WriteSpan()
      begin
          MsgStr  := LoadZipStr( DS_InsertDisk, 'Please insert last disk in set' );
          MsgFlag := MsgFlag or MB_ICONERROR;
      end else
      begin
         if FZipBusy then   // Are we from ReadSpan() or WriteSpan()?
         begin
            // This is an estimate, we can't know if every future disk has the same space available and
            // if there is no disk present we can't determine the size unless it's set by MaxVolumeSize.
            SizeOfDisk := FSizeOfDisk;
            if (FMaxVolumeSize <> 0) and (FMaxVolumeSize < FSizeOfDisk) then
               SizeOfDisk := FMaxVolumeSize;

            FTotalDisks := FDiskNr;
            if (SizeOfDisk > 0) and (FTotalDisks < Trunc( (FFileSize + 4 + FFreeOnDisk1) / SizeOfDisk)) then  // RCV150199
               FTotalDisks := Trunc((FFileSize + 4 + FFreeOnDisk1) / SizeOfDisk);
            if SizeOfDisk > 0 then
               MsgStr := Format( LoadZipStr( DS_InsertVolume, 'Please insert disk volume %.1d of %.1d'), [FDiskNr + 1, FTotalDisks + 1] )
            else
               MsgStr := Format( LoadZipStr( DS_InsertAVolume, 'Please insert disk volume %.1d'), [FDiskNr + 1] );
         end else
            MsgStr := Format( LoadZipStr( DS_InsertVolume, 'Please insert disk volume %.1d of %.1d'), [FDiskNr + 1, FTotalDisks + 1] );
      end;
      MsgStr := MsgStr + Format( LoadZipStr( DS_InDrive, #13#10'in drive: %s' ), [FDrive] );

      Res := MessageBox( FHandle, pChar( MsgStr ), pChar( Application.Title ), MsgFlag );
      FNewDisk := False;
   end;
   // ShowMessage( 'out of the loop in checkfordisk - res=' + IntToStr( res ) + '  IDOK=' + IntToStr( IDOK ) );

   // Check if user pressed Cancel or memory is running out.
   if Res <> IDOK then
      raise EZipMaster.CreateResDisp( DS_Canceled, False );
   if Res = 0 then
      raise EZipMaster.CreateResDisp( DS_NoMem, True );
   Result := drt;
end;

//---------------------------------------------------------------------------
function TZipMaster.IsRightDisk( drt: Integer ): Boolean;
var
   Ext: String;
begin
   Result := False;
   // For fixed disks the disk is always right, we only need to change
   // the filename.
   if (drt = DRIVE_FIXED) or (drt = DRIVE_REMOTE) then
   begin
      // Get the file extension.
      Ext := ExtractFileExt( FInFileName );
      // Strip file extension and the last 3 numbers.
      SetLength( FInFileName, Length( FInFileName ) - 3 - Length( Ext ) );
      // Set the filename to the diskfile number we want now.
      FInFileName := FInFileName + Copy( IntToStr( 1001 + FDiskNr ), 2, 3 ) + Ext;
      Result := True;
      Exit;
   end;
   if FVolumeName = ( 'PKBACK# ' + Copy( IntToStr( 1001 + FDiskNr ), 2, 3 ) ) then
      Result := True;
end;

//---------------------------------------------------------------------------
procedure TZipMaster.GetNewDisk( DiskSeq: Integer );
var
   drt: Integer;
begin
   drt := DRIVE_REMOVABLE;
   FileClose( FInFileHandle ); // Close the file on the old disk first.
   FDiskNr := DiskSeq;
   repeat
      if FInFileHandle = -1 then
      begin
         if ( drt <> DRIVE_FIXED ) and ( drt <> DRIVE_REMOTE ) then
            ShowZipMessage( DS_NoInFile, '' )
         // This prevents and endless loop if for some reason spanned parts
         // on harddisk are missing.
         else
            raise EZipMaster.CreateResDisp( DS_NoInFile, True );
      end;
      repeat
         FNewDisk := True;
         drt      := CheckForDisk();
      until IsRightDisk( drt );

      // Open the the input archive on this disk.
      FInFileHandle := FileOpen( FInFileName, fmShareDenyWrite or fmOpenRead );
   until NOT ( FInFileHandle = -1 );
end;

function TZipMaster.AppendSlash( sDir: String ): String;
begin
   if sDir[Length( sDir )] <> '\' then
      Result := sDir + '\'
   else
      Result := sDir;
end;

function TZipMaster.ReplaceForwardSlash( aStr: String ): String;
var
   i: Integer;
begin
   SetLength( Result, Length( aStr ) );
   for i := 1 to Length( aStr ) do
      if aStr[i] = '/' then
         Result[i] := '\'
      else
         Result[i] := aStr[i];
end;



//---------------------------------------------------------------------------
function EnumThreadWndProc( winh: HWND; var mythis: TZipMaster ): Boolean; stdcall; export;
begin
   Result := True;
   if GetParent( winh ) = Application.Handle then
   begin
      mythis.Fhwnd  := winh;
      mythis.FFound := 1;
      Result        := False;
   end;
end;

//---------------------------------------------------------------------------
function TZipMaster.ZipFormat: Integer;
var
   func: function( winh: HWND; var mythis: TZipMaster ): Boolean; stdcall;
begin
   FFound        :=  0;
   FFormatResult := -3;   // NoFormat.
   Fft           := FormatThread.CreateFT( Self, False );
   func          := EnumThreadWndProc;

   if Assigned( Fft ) then
   begin
      repeat
         Application.ProcessMessages;
         EnumThreadWindows( Fft.ThreadID, @func, Integer(@Self) );
      until( FFound <> 0 );
      // W'll have to wait for formatting to finish (1)
      // or in case of an error (2) don't wait at all.
      // (It's possible that the thread is already gone.)
      if FFound = 1 then
         Fft.WaitFor;
   end;
   Result := FFormatResult;
end;

//---------------------------------------------------------------------------
// Function to read a Zip source file and write it back to one or more disks.
// Return values:
//  0           All Ok.
// -7           WriteSpan errors. See ZipMsgXX.rc
// -8           Memory allocation error.
// -9           General unknown WriteSpan error.
function TZipMaster.WriteSpan( InFileName, OutFileName: String ): Integer;
var
   LOH:             ZipLocalHeader;
   DD:              ZipDataDescriptor;
   CEH:             ZipCentralHeader;
   EOC:             ZipEndOfCentral;
   i, k:            Integer;
   MsgStr:          String;
   TotalBytesWrite: Integer;
   StartCentral:    Integer;
   CentralOffset:   Integer;
   Buffer:          Array[0..BufSize - 1] of Char;
begin
   Result         := 0;
   FZipBusy       := True;
   FDrive         := ExtractFileDrive( OutFileName ) + '\';
   FDiskNr        := 0;
   FFreeOnDisk    := 0;
   FNewDisk       := True;
   FDiskWritten   := 0;
   FInFileName    := InFileName;
   FOutFileName   := OutFileName;
   FOutFileHandle := -1;
   FShowProgress  := False;
   Screen.Cursor  := crHourGlass;
   CentralOffset  := 0;

   if FVerbose and Assigned( FOnMessage ) then
      FOnMessage( Self, 0, 'Now creating spanning chunks from ' + InfileName + ' to ' + OutFileName );

   try
      if NOT FileExists( InFileName ) then
         raise EZipMaster.CreateResDisp( DS_NoInFile, True );

      // The following function will read the EOC and some other stuff:
      CheckIfLastDisk( EOC, True );
      // ShowMessage( 'EWE - made it through CheckIfLastDisk' );

      // Get the date-time stamp and save for later.
      FDateStamp := FileGetDate( FInFileHandle );

      // go back to the start the zip archive.
      if ( FileSeek( FInFileHandle, 0, 0 ) = -1 ) then
         raise EZipMaster.CreateResDisp( DS_FailedSeek, True );

      //ShowMessage( 'EWE - about to AllocSpanMem' );
      AllocSpanMem( EOC.TotalEntries );  // Allocate other memory.
      //ShowMessage( 'EWE - made it past AllocSpanMem' );

      // Write extended local Sig. needed for a spanned archive.
      FInteger := ExtLocalSig;
      WriteSplit( @FInteger, 4, 0 );
      //ShowMessage( 'ewe - made it past writesplit' );

      // Read for every zipped entry: The local header, variable data, fixed data
      // and, if present, the Data decriptor area.
      FShowProgress := True;
      if Assigned( FOnProgress ) then
      begin
         FOnProgress( Self, TotalFiles2Process, '', EOC.TotalEntries );
         FOnProgress( Self, TotalSize2Process,  '', FFileSize );
      end;
      //ShowMessage( 'EWE - about to start the for loop' );

      for i := 0 to (EOC.TotalEntries - 1) do
      begin
         // First the local header.
         //ShowMessage( 'we''re going to read the LOH' );
         if NOT ( FileRead( FInFileHandle, LOH, SizeOf(LOH) ) = SizeOf(LOH) ) then
            raise EZipMaster.CreateResDisp( DS_LOHBadRead, True );
         if NOT ( LOH.HeaderSig = LocalFileHeaderSig ) then
            raise EZipMaster.CreateResDisp( DS_LOHWrongSig, True );

         //ShowMessage( 'we have a good LOH' );
         // Now the filename
         if NOT ( FileRead( FInFileHandle, Buffer, LOH.FileNameLen ) = LOH.FileNameLen ) then
            raise EZipMaster.CreateResDisp( DS_LONameLen, True );

         //ShowMessage( 'we read the filename' );
         // Save some information for later. ( on the last disk(s) ).
         MDZDp := MDZD.Items[i];
         MDZDp^.DiskStart   := FDiskNr;
         //ShowMessage( 'here''s the disk start:' + IntToStr(MDZDp^.DiskStart) );
         MDZDp^.FileNameLen := LOH.FileNameLen;

         // bug was here - the memory for MDZDp^.FileName was not alloc'd
         StrLCopy( MDZDp^.FileName, Buffer, LOH.FileNameLen ); // like makestring
         //ShowMessage( 'here''s the filename: ' +  MDZDp^.FileName );

         // Give message and progress info on the start of this new file read.
         MsgStr := LoadZipStr( GE_CopyFile, 'Copying: ' ) + ReplaceForwardSlash( MDZDp^.FileName );
         if Assigned( FOnMessage ) then
            FOnMessage( Self, 0, MsgStr );

         //ShowMessage( 'EWE - ' + MsgStr );
         TotalBytesWrite := SizeOf(LOH) + LOH.FileNameLen + LOH.ExtraLen + LOH.ComprSize;
         if ( LOH.Flag and Word(#$0008) ) = 8 then
            Inc( TotalBytesWrite, SizeOf(DD) );

         if Assigned( FOnProgress ) then
            FOnProgress( Self, NewFile, ReplaceForwardSlash( MDZDp^.FileName ), TotalBytesWrite );

         // Write the local header to the destination.
         WriteSplit( @LOH, SizeOf(LOH), SizeOf(LOH) + LOH.FileNameLen + LOH.ExtraLen );

         // Save the offset of the LOH on this disk for later.
         MDZDp^.RelOffLocal := FDiskWritten - SizeOf(LOH);

         // Write the filename.
         WriteSplit( Buffer, LOH.FileNameLen, 0 );

         // And the extra field
         RWSplitData( Buffer, LOH.ExtraLen, DS_LOExtraLen );

         // Read Zipped data !!!For now assume we know the size!!!
         RWSplitData( Buffer, LOH.ComprSize, DS_ZipData );

         // Read DataDescriptor if present.
         if ( LOH.Flag and Word(#$0008) ) = 8 then
            RWSplitData( @DD, SizeOf(DD), DS_DataDesc );
      end;

      //ShowMessage('EWE - all entries written to disk');

      // We have written all entries to disk.
      if Assigned( FOnMessage ) then
           FOnMessage( Self, 0, 'Copying: Central directory' );
      if Assigned( FOnProgress ) then
           FOnProgress( Self, NewFile, 'Central directory', EOC.CentralSize + SizeOf(EOC) + EOC.ZipCommentLen );

      // Now write the central directory with changed offsets.
      StartCentral := FDiskNr;
      for i := 0 to (EOC.TotalEntries - 1) do
      begin
         // Read a central header.
         if FileRead( FInFileHandle, CEH, SizeOf(CEH) ) <> SizeOf(CEH) then
            raise EZipMaster.CreateResDisp( DS_CEHBadRead, True );
         if CEH.HeaderSig <> CentralFileHeaderSig then
            raise EZipMaster.CreateResDisp( DS_CEHWrongSig, True );

         // Now the filename.
         if FileRead( FInFileHandle, Buffer, CEH.FileNameLen ) <> CEH.FileNameLen then
            raise EZipMaster.CreateResDisp( DS_CENameLen, True );

         // Change the central directory with information stored previously in MDZD.
         k := FindZipEntry( EOC.TotalEntries, MakeString( Buffer, CEH.FileNameLen ) );
         MDZDp := MDZD[k];
         CEH.DiskStart   := MDZDp^.DiskStart;
         CEH.RelOffLocal := MDZDp^.RelOffLocal;

         // Write this changed central header to disk
         // and make sure it fit's on one and the same disk.
         WriteSplit( @CEH, SizeOf(CEH), SizeOf(CEH) + CEH.FileNameLen + CEH.ExtraLen + CEH.FileComLen );

         // Save the first Central directory offset for use in EOC record.
         if i = 0 then
            CentralOffset := FDiskWritten - SizeOf(CEH);

         // Write to destination the central filename and the extra field.
         WriteSplit( Buffer, CEH.FileNameLen, 0 );

         // And the extra field
         RWSplitData( Buffer, CEH.ExtraLen, DS_CEExtraLen );

         // And the file comment.
         RWSplitData( Buffer, CEH.FileComLen, DS_CECommentLen );
      end;

      // Write the changed EndOfCentral directory record.
      EOC.CentralDiskNo := StartCentral;
      EOC.ThisDiskNo    := FDiskNr;
      EOC.CentralOffset := CentralOffset;
      WriteSplit( @EOC, SizeOf(EOC), SizeOf(EOC) + EOC.ZipCommentLen );

      // Skip past the original EOC to get to the ZipComment if present. v1.52j
      if ( FileSeek( FInFileHandle, SizeOf( EOC ), 1 ) = -1 ) then
         raise EZipMaster.CreateResDisp( DS_FailedSeek, True );

      // And finally the archive comment
      RWSplitData( Buffer, EOC.ZipCommentLen, DS_EOArchComLen );
      FShowProgress := False;
   except
     on ews: EZipMaster do                 // All WriteSpan specific errors.
       begin
         ShowExceptionError( ews );
         Result := -7;
       end;
     on EOutOfMemory do                    // All memory allocation errors.
       begin
         ShowZipMessage( GE_NoMem, '' );
	 Result := -8;
       end;
     else
       begin                               // The remaining errors, should not occur.
         ShowZipMessage( DS_ErrorUnknown, '' );
	 Result := -9;
       end;
   end;

   // Give the last progress info on the end of this file read.
   if Assigned( FOnProgress ) then
      FOnProgress( Self, EndOfBatch, '', 0 );

   DeleteSpanMem;

   FileSetDate( FOutFileHandle, FDateStamp );
   if FOutFileHandle <> -1 then
      FileClose( FOutFileHandle );
   if FInFileHandle <> -1 then
      FileClose( FInFileHandle );

   FZipBusy := False;
   Screen.Cursor := crDefault;
end;

function TZipMaster.MakeString( Buffer: pChar; Size: Integer ): String;
begin
   SetLength( Result, Size );
   StrLCopy( pChar( Result ), Buffer, Size );
end;

//---------------------------------------------------------------------------
// This function actually writes the zipped file to the destination while
// taking care of disk changes and disk boundary crossings.
// In case of an write error, or user abort, an exception is raised.
procedure TZipMaster.WriteSplit( Buffer: pChar; Len: Integer; MinSize: Integer );
var
   Res, MaxLen:     Integer;
   Buf:            pChar;    // Used if Buffer doesn't fit on the present disk.
   drt, DiskSeq:    Integer;
   DiskFile, MsgQ:  String;
begin
   Buf := Buffer;
   Application.ProcessMessages;
   if FCancel then
      raise EZipMaster.CreateResDisp( DS_Canceled, False );
   //ShowMessage( 'ewe - in writesplit' );
   while True do  // Keep writing until error or buffer is empty.
   begin
      //ShowMessage( 'ewe - made it past checkfordisk' );
      // Check if we have an output file already opened, if not: create one,
      // do checks, gather info.
      if FOutFileHandle = -1 then
      begin
         drt      := CheckForDisk();
         DiskFile := FOutFileName;

         // If we write on a fixed disk the filename must change.
         // We will get something like: FileNamexxx.zip where xxx is 001,002 etc.
         if (drt = DRIVE_FIXED) or (drt = DRIVE_REMOTE) then
         begin
            DiskFile := Copy( DiskFile, 1, Length( DiskFile ) - Length( ExtractFileExt( DiskFile ) ) ) +
                          Copy( IntToStr( 1001 + FDiskNr ), 2, 3) + ExtractFileExt( DiskFile );
            //ShowMessage( 'ewe - diskfile from inside the if: ' + DiskFile );
         end
         else if AddDiskSpanErase in FAddOptions then
         begin
            // Do we want a format first?
            FDriveNr    := Ord( UpperCase( FDrive )[1] ) - Ord( 'A' );
            FVolumeName := 'PKBACK# ' + Copy( IntToStr( 1001 + FDiskNr ), 2, 3 );
            // Ok=6 NoFormat=-3, Cancel=-2, Error=-1
            case ZipFormat of   // Start formating and wait until finished...
               -1:  raise EZipMaster.CreateResDisp( DS_Canceled, True );
               -2:  raise EZipMaster.CreateResDisp( DS_Canceled, False );
            end;
         end;

         // Do we want to overwrite an existing file?
         if FileExists( DiskFile ) then
         begin
            DiskSeq := StrToIntDef( Copy( FVolumeName, 9, 3 ), 1 );
            if Unattended then
                raise EZipMaster.CreateResDisp( DS_NoUnattSpan, True );  // we assume we don't.
            // A more specific check if we have a previous disk from this set.
            if ( FileAge( DiskFile ) = FDateStamp ) and ( Pred( DiskSeq ) < FDiskNr ) then
               MsgQ := Format( LoadZipStr( DS_AskPrevFile, 'Overwrite previous disk no %d' ), [DiskSeq] )
            else
               MsgQ := Format( LoadZipStr( DS_AskDeleteFile, 'Overwrite previous file %s' ), [DiskFile] );

            Res := MessageBox( FHandle, pChar( MsgQ ), pChar( 'Confirm' ), MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING );
            if (Res = 0) or (Res = IDCANCEL) then
               raise EZipMaster.CreateResDisp( DS_Canceled, False );

            if Res = IDNO then
            begin        // we will try again...
               FDiskWritten := 0;
               FNewDisk     := True;
               continue;
            end;
         end;
         //ShowMessage( 'ewe - diskfile outside the if: ' + DiskFile );

         // Create the output file.
         FOutFileHandle := FileCreate( DiskFile );
         if FOutFileHandle = -1 then
            raise EZipMaster.CreateResDisp( DS_NoOutFile, True );

         // Get the free space on this disk, correct later if neccessary.
         DiskFreeAndSize( 1 );  // RCV150199

         //ShowMessage( 'FFreeOnDisk= '+ IntToStr(FFreeOnDisk)+ '  MaxVolumeSize=' + IntToStr(MaxVolumeSize) );

         // Set the maximum number of bytes that can be written to this disk(file).
         if MaxVolumeSize > 0 then
            if MaxVolumeSize < FFreeOnDisk then
               FFreeOnDisk := MaxVolumeSize;

         // Reserve space on/in the first disk(file).
         if FDiskNr = 0 then
            FFreeOnDisk := FFreeOnDisk - KeepFreeOnDisk1;  // RCV150199

         // Do we still have enough free space on this disk.
         if FFreeOnDisk < MinFreeVolumeSize then  // No, too bad...
         begin
            FileClose( FOutFileHandle );
            DeleteFile( DiskFile );
            FOutFileHandle := -1;
            if FUnattended then
               raise EZipMaster.CreateResDisp( DS_NoUnattSpan, True );
            MsgQ := LoadZipStr( DS_NoDiskSpace, 'This disk has not enough free space available' );
            //ShowMessage( MsgQ );
            Res := MessageBox( FHandle, pChar(MsgQ), pChar( Application.Title ), MB_RETRYCANCEL or MB_ICONERROR );
            if Res = 0 then
                raise EZipMaster.CreateResDisp( DS_NoMem, True );
            if Res <> IDRETRY then
               raise EZipMaster.CreateResDisp( DS_Canceled, False );
            FDiskWritten := 0;
            FNewDisk     := True;
            continue;
         end;

         // Set the volume label of this disk if it is not a fixed one.
         if (drt <> DRIVE_FIXED) and (drt <> DRIVE_REMOTE) then
         begin
            FVolumeName := 'PKBACK# ' + Copy( IntToStr( 1001 + FDiskNr ), 2, 3 );
            if NOT SetVolumeLabel( pChar( FDrive ), pChar( FVolumeName ) ) then
               raise EZipMaster.CreateResDisp( DS_NoVolume, True );
         end;
      end; // END OF: if FOutFileHandle = -1

      //ShowMessage( 'minsize= ' + IntToStr( Minsize ) );
      // Check if we have at least MinSize available on this disk,
      // headers are not allowed to cross disk boundaries. ( if zero than don't care.)
      if (MinSize > 0) and (MinSize > FFreeOnDisk) then
      begin
         FileSetDate( FOutFileHandle, FDateStamp );
         FileClose( FOutFileHandle );
         FOutFileHandle := -1;
         FDiskWritten   :=  0;
         FNewDisk       := True;
         Inc( FDiskNr );  // RCV270299
         continue;
      end;

      // Don't try to write more bytes than allowed on this disk.
      MaxLen := {$IfDef VERD4B4}FFreeOnDisk{$Else}Trunc( FFreeOnDisk ){$EndIF};  // RCV150199
      if Len < FFreeOnDisk then
         MaxLen := Len;
      Res    := FileWrite( FOutFileHandle, Buf^, MaxLen );
      {ShowMessage( 'we just did a filewrite of maxlen=' + IntToStr(Maxlen) +
           ' res= ' + IntToStr(res) + ' len= '+ IntToStr(len) ); }

      // Sleep( 250 );  // This will keep the progress events more synchronised, but it's slower.
      // Give some progress info while writing
      // While processing the central header we don't want messages.
      if Assigned( FOnProgress ) and FShowProgress then
         FOnProgress( Self, ProgressUpdate, '', MaxLen );
      if Res = -1 then
         raise EZipMaster.CreateResDisp( DS_NoWrite, True ); // A write error (disk removed?)
      Inc( FDiskWritten, Res );
      FFreeOnDisk := FFreeOnDisk - MaxLen;  // RCV150199
      if MaxLen = Len then
         break;

      // We still have some data left, we need a new disk.
      //ShowMessage( 'We still have some data left, we need a new disk.' );
      FileSetDate( FOutFileHandle, FDateStamp );
      FileClose( FOutFileHandle );
      FOutFileHandle := -1;
      FFreeOnDisk    :=  0;
      FDiskWritten   :=  0;
      Inc( FDiskNr );
      FNewDisk := True;
      Inc( Buf, MaxLen );
      Dec( Len, MaxLen );
   end;
end;

//---------------------------------------------------------------------------
// Function to read a split up Zip source file from multiple disks and write it to one destination file.
// Return values:
// 0            All Ok.
// -7           ReadSpan errors. See ZipMsgXX.rc
// -8           Memory allocation error.
// -9           General unknown ReadSpan error.
function TZipMaster.ReadSpan( InFileName: String; var OutFilePath: String ): Integer;
var
   Buffer:            Array[0..BufSize - 1] of Char;
   TotalBytesToRead:  Integer;
   EOC:               ZipEndOfCentral;
   LOH:               ZipLocalHeader;
   DD:                ZipDataDescriptor;
   CEH:               ZipCentralHeader;
   i, k, drt, diskno: Integer;
   ExtendedSig:       Integer;
   MsgStr:            String;
   TotalBytesWrite:   Integer;
begin
   Result           := 0;
   TotalBytesToRead := 0;

   FUnzBusy         := True;
   FDrive           := ExtractFileDrive( InFileName ) + '\';
   FDiskNr          := -1;
   FNewDisk         := False;
   FShowProgress    := False;
   FInFileName      := InFileName;
   FInFileHandle    := -1;
   Screen.Cursor    := crHourGlass;

   try
      // If we don't have a filename we make one first.
      if ExtractFileName( OutFilePath ) = '' then
      begin
         // Make a temporary file name like: C:\...\zipxxxx.zip
         if GetTempFileName( pChar( OutFilePath ), pChar( 'zip' ), 0, Buffer ) = 0 then
             raise EZipMaster.CreateResDisp( DS_NoTempFile, True );
         OutFilePath := Buffer;
         DeleteFile( OutFilePath );
      end else
         EraseFile( OutFilePath, FHowToDelete );
      OutFilePath := ChangeFileExt( OutFilePath, '.zip' );

      // Create the output file.
      FOutFileHandle := FileCreate( OutFilePath );
      if FOutFileHandle = -1 then
          raise EZipMaster.CreateResDisp( DS_NoOutFile, True );

      // Try to get the last disk from the user.
      drt := DRIVE_REMOVABLE;
      repeat
         if ( drt = DRIVE_FIXED ) or ( drt = DRIVE_REMOTE ) then
         begin
            DiskNo := StrToIntDef( Copy( FInFileName,
                Length( FInFileName ) - 2 - Length( ExtractFileExt( FInFileName ) ), 3) , 0  );
            if DiskNo = 1 then
                raise EZipMaster.CreateResDisp( DS_FirstInSet, True );
            if DiskNo <> 1 then
                raise EZipMaster.CreateResDisk( DS_NotLastInSet, DiskNo );
         end;
         drt := CheckForDisk;
         FNewDisk := True;
      until CheckIfLastDisk( EOC, False );

      // Get the date-time stamp and save for later.
      FDateStamp := FileGetDate( FInFileHandle );

      // Now we now the number of zipped entries in the zip archive
      // and the starting disk number of the central directory.
      FTotalDisks := EOC.ThisDiskNo;
      if EOC.ThisDiskNo <> EOC.CentralDiskNo then
         GetNewDisk( EOC.CentralDiskNo );  // request a previous disk first
      // We go to the start of the Central directory. v1.52i
      if FileSeek( FInFileHandle, EOC.CentralOffset, 0 ) = -1 then
          raise EZipMaster.CreateResDisp( DS_FailedSeek, True );

      AllocSpanMem( EOC.TotalEntries );    // Allocate memory

      // Read for every entry: The central header and save information for later use.
      for i := 0 to ( EOC.TotalEntries - 1 ) do
      begin
         // Read a central header.
         while FileRead( FInFileHandle, CEH, SizeOf(CEH) ) <> SizeOf(CEH) do  //v1.52i
         begin
            // It's possible that we have the central header split up
            if FDiskNr >= EOC.ThisDiskNo then
                raise EZipMaster.CreateResDisp( DS_CEHBadRead, True );
            // We need the next disk with central header info.
            GetNewDisk( FDiskNr + 1 );
         end;

        if CEH.HeaderSig <> CentralFileHeaderSig then
            raise EZipMaster.CreateResDisp( DS_CEHWrongSig, True );

        // Now the filename.
        if FileRead( FInFileHandle, Buffer, CEH.FileNameLen ) <> CEH.FileNameLen then
            raise EZipMaster.CreateResDisp( DS_CENameLen, True );

        // Save the file name info in the MDZD structure.
        MDZDp := MDZD[i];
        MDZDp^.FileNameLen := CEH.FileNameLen;
        StrLCopy( MDZDp^.FileName, Buffer, CEH.FileNameLen );

        // Save the compressed size, we need this because WinZip sometimes sets this to
        // zero in the local header. New v1.52d
        MDZDp^.ComprSize := CEH.ComprSize;

        // We need the total number of bytes we are going to read for the progress event.
        TotalBytesToRead := TotalBytesToRead + Integer(CEH.ComprSize + CEH.FileNameLen + CEH.ExtraLen + CEH.FileComLen);

        // Seek past the extra field and the file comment.
        if FileSeek( FInFileHandle, CEH.ExtraLen + CEH.FileComLen, 1 ) = -1 then
            raise EZipMaster.CreateResDisp( DS_FailedSeek, True );
      end;

      // Now we need the first disk and start reading.
      GetNewDisk( 0 );

      FShowProgress := True;
      if Assigned( FOnProgress ) then
      begin
         FOnProgress( Self, TotalFiles2Process, '', EOC.TotalEntries );
         FOnProgress( Self, TotalSize2Process,  '', TotalBytesToRead );
      end;

      // Read extended local Sig. first; is only present if it's a spanned archive.
      if FileRead( FInFileHandle, ExtendedSig, 4 ) <> 4 then
          raise EZipMaster.CreateResDisp( DS_ExtWrongSig, True );
      if ExtendedSig <> ExtLocalSig then
          raise EZipMaster.CreateResDisp( DS_ExtWrongSig, True );

      // Read for every zipped entry: The local header, variable data, fixed data
      // and if present the Data decriptor area.
      for i := 0 to (EOC.TotalEntries - 1) do
      begin
         // First the local header.
         while FileRead( FInFileHandle, LOH, SizeOf(LOH) ) <> SizeOf(LOH) do
         begin
            // Check if we are at the end of a input disk not very likely but...
            if FileSeek( FInFileHandle, 0, 1 ) <> FileSeek( FInFileHandle, 0, 2 ) then
                raise EZipMaster.CreateResDisp( DS_LOHBadRead, True );
            // Well it seems we are at the end, so get a next disk.
            GetNewDisk( FDiskNr + 1 );
         end;
         if LOH.HeaderSig <> LocalFileHeaderSig then
             raise EZipMaster.CreateResDisp( DS_LOHWrongSig, True );

         // Now the filename, should be on the same disk as the LOH record.
         if FileRead( FInFileHandle, Buffer, LOH.FileNameLen ) <> LOH.FileNameLen then
             raise EZipMaster.CreateResDisp( DS_LONameLen, True );

         // Change some info for later while writing the central dir.
         k := FindZipEntry( EOC.TotalEntries, MakeString( Buffer, LOH.FileNameLen ) );
         MDZDp := MDZD[k];
         MDZDp^.DiskStart   := 0;
         MDZDp^.RelOffLocal := FileSeek( FOutFileHandle, 0, 1 );

         // Give message and progress info on the start of this new file read.
         MsgStr := LoadZipStr( GE_CopyFile, 'Copying: ' ) + ReplaceForwardSlash( MDZDp^.FileName );
         if Assigned( FOnMessage ) then
            FOnMessage( Self, 0, MsgStr );

         TotalBytesWrite := SizeOf(LOH) + LOH.FileNameLen + LOH.ExtraLen + LOH.ComprSize;
         if ( LOH.Flag and Word(#$0008) ) = 8 then
            Inc( TotalBytesWrite, SizeOf( DD ) );
         if Assigned( FOnProgress ) then
            FOnProgress( Self, NewFile, ReplaceForwardSlash( MDZDp^.FileName ), TotalBytesWrite );

         // Write the local header to the destination.
         WriteJoin( @LOH, SizeOf(LOH), DS_LOHBadWrite );

         // Write the filename.
         WriteJoin( Buffer, LOH.FileNameLen, DS_LOHBadWrite );

         // And the extra field
         RWJoinData( Buffer, LOH.ExtraLen, DS_LOExtraLen );

         // Read Zipped data, if the size is not known use the size from the central header.
         if LOH.ComprSize = 0 then
            LOH.ComprSize := MDZDp^.ComprSize;	// New v1.52d
         RWJoinData( Buffer, LOH.ComprSize, DS_ZipData );

         // Read DataDescriptor if present.
         if ( LOH.Flag and Word(#$0008) ) = 8 then
            RWJoinData( @DD, SizeOf( DD ), DS_DataDesc );
      end; // Now we have written al entries to the (hard)disk.

      // Now write the central directory with changed offsets.
      FShowProgress := False;
      for i := 0 to (EOC.TotalEntries - 1) do
      begin
         // Read a central header which can be span more than one disk.
         while FileRead( FInFileHandle, CEH, SizeOf(CEH) ) <> SizeOf(CEH) do
         begin
            // Check if we are at the end of a input disk.
            if FileSeek( FInFileHandle, 0, 1 ) <> FileSeek( FInFileHandle, 0, 2 ) then
                raise EZipMaster.CreateResDisp( DS_CEHBadRead, True );
            // Well it seems we are at the end, so get a next disk.
            GetNewDisk( FDiskNr + 1 );
         end;
         if CEH.HeaderSig <> CentralFileHeaderSig then
             raise EZipMaster.CreateResDisp( DS_CEHWrongSig, True );

         // Now the filename.
         if FileRead( FInFileHandle, Buffer, CEH.FileNameLen ) <> CEH.FileNameLen then
             raise EZipMaster.CreateResDisp( DS_CENameLen, True );

         // Save the first Central directory offset for use in EOC record.
         if i = 0 then
            EOC.CentralOffset := FileSeek( FOutFileHandle, 0, 1 );

         // Change the central header info with our saved information.
         k := FindZipEntry( EOC.TotalEntries, MakeString( Buffer, CEH.FileNameLen ) );
         MDZDp := MDZD[k];
         CEH.RelOffLocal := MDZDp^.RelOffLocal;
         CEH.DiskStart   := 0;

         // Write this changed central header to disk
         // and make sure it fit's on one and the same disk.
         WriteJoin( @CEH, SizeOf(CEH), DS_CEHBadWrite );

         // Write to destination the central filename and the extra field.
         WriteJoin( Buffer, CEH.FileNameLen, DS_CEHBadWrite );

         // And the extra field
         RWJoinData( Buffer, CEH.ExtraLen, DS_CEExtraLen );

         // And the file comment.
         RWJoinData( Buffer, CEH.FileComLen, DS_CECommentLen );
      end;

      // Write the changed EndOfCentral directory record.
      EOC.CentralDiskNo := 0;
      EOC.ThisDiskNo    := 0;
      WriteJoin( @EOC, SizeOf(EOC), DS_EOCBadWrite );

      // And finally the archive comment
      RWJoinData( Buffer, EOC.ZipCommentLen, DS_EOArchComLen );
   except
      on ers: EZipMaster do     // All ReadSpan specific errors.
        begin
          ShowExceptionError( ers );
          Result := -7;
        end;
      on EOutOfMemory do	// All memory allocation errors.
        begin
          ShowZipMessage( GE_NoMem, '' );
      	  Result := -8;
        end;
      else
        begin			// The remaining errors, should not occur.
          ShowZipMessage( DS_ErrorUnknown, '' );
	  Result := -9;
        end;
   end;

   // Give final progress info at the end.
   if Assigned( FOnProgress ) then
      FOnProgress( Self, EndOfBatch, '', 0 );

   DeleteSpanMem;

   if FInFileHandle <> -1 then
      FileClose( FInFileHandle );
   if FOutFileHandle <> -1 then
   begin
      FileSetDate( FOutFileHandle, FDateStamp );
      FileClose( FOutFileHandle );
      if Result <> 0 then   // An error somewhere, OutFile is not reliable.
      begin
         DeleteFile( OutFilePath );
         OutFilePath := '';
      end;
   end;

   FUnzBusy := False;
   Screen.Cursor := crDefault;
end;

//---------------------------------------------------------------------------
procedure TZipMaster.AllocSpanMem( TotalEntries: Integer );
var
   i: Integer;
begin
   MDZD := TList.Create;

   MDZD.Capacity := TotalEntries;
   for i := 1 to TotalEntries do
   begin
      New( MDZDp );
      MDZDp^.FileName := '';
      MDZD.Add( MDZDp );
   end;
end;

//---------------------------------------------------------------------------
procedure TZipMaster.DeleteSpanMem;
var
   i: Integer;
begin
   if NOT Assigned( MDZD ) or (MDZD.Count = 0) then
      Exit;
   for i := (MDZD.Count - 1) downto 0 do
   begin
      if Assigned( MDZD[i] ) then
      begin
         // dispose of the memory pointed-to by this entry
         MDZDp := MDZD[i];
         Dispose( MDZDp );
      end;
      MDZD.Delete( i ); // delete the TList pointer itself
   end;
   MDZD.Free;
   MDZD := nil;
end;

//---------------------------------------------------------------------------
// Find a local dir entry in the internal MDZD structure.
// Needed because the central and local header info is not always in sync.
function TZipMaster.FindZipEntry( Entries: Integer; Filename: String ): Integer;
var
   k: Integer;
begin
   for k := 0 to (Entries - 1) do
   begin
      MDZDp := MDZD[k];
      if CompareText( Filename, MDZDp^.FileName ) = 0 then // case insensitive compare
         break;
   end;

   // Should not happen, but maybe in a bad archive...
   if k = Entries then
      raise EZipMaster.CreateResDisp( DS_EntryLost, True );
   Result := k;
end;

//---------------------------------------------------------------------------
procedure TZipMaster.WriteJoin( Buffer: pChar; BufferSize, DSErrIdent: Integer );
begin
   if FileWrite( FOutFileHandle, Buffer^, BufferSize ) <> BufferSize then
      raise EZipMaster.CreateResDisp( DSErrIdent, True );

   // Give some progress info while writing.
   // While processing the central header we don't want messages.
   if Assigned( FOnProgress ) and FShowProgress then
      FOnProgress( Self, ProgressUpdate, '', BufferSize );
end;

//---------------------------------------------------------------------------
// Read data from the input file with a maximum of 8192(BufSize) bytes per read
// and write this to the output file.
// In case of an error an Exception is raised and this will
// be caught in WriteSpan.
procedure TZipMaster.RWSplitData( Buffer: pChar; ReadLen, ZSErrVal: Integer );
var
   SizeR, ToRead: Integer;
begin
   while ReadLen > 0 do
   begin
      ToRead := BufSize;
      if ReadLen < BufSize then
         ToRead := ReadLen;
      SizeR  := FileRead( FInFileHandle, Buffer^, ToRead );
      if SizeR <> ToRead then
         raise EZipMaster.CreateResDisp( ZSErrVal, True );
      WriteSplit( Buffer, SizeR, 0 );
      Dec( ReadLen, SizeR );
   end;
end;

//---------------------------------------------------------------------------
procedure TZipMaster.RWJoinData( Buffer: pChar; ReadLen, DSErrIdent: Integer );
var
   SizeR, ToRead: Integer;
begin
   while ReadLen > 0 do
   begin
      ToRead := BufSize;
      if ReadLen < BufSize then
         ToRead := ReadLen;
      SizeR  := FileRead( FInFileHandle, Buffer^, ToRead );
      if SizeR <> ToRead then  //v1.52i2
      begin
         // Check if we are at the end of a input disk.
         if FileSeek( FInFileHandle, 0, 1 ) <> FileSeek( FInFileHandle, 0, 2 ) then
             raise EZipMaster.CreateResDisp( DSErrIdent, True );
         // It seems we are at the end, so get a next disk.
         GetNewDisk( FDiskNr + 1 );
      end;
      WriteJoin( Buffer, SizeR, DSErrIdent );
      Dec( ReadLen, SizeR );
   end;
end;

//---------------------------------------------------------------------------
// The default exception constructor used in the List(), ReadSpan() and WriteSpan() functions.
constructor EZipMaster.CreateResDisp( Const Ident: Integer; Const Display: Boolean );
begin
  inherited CreateRes( Ident );

  if Message = '' then Message := RESOURCE_ERROR + IntToStr( Ident );
  FDisplayMsg := Display;
  FResIdent   := Ident;
end;

constructor EZipMaster.CreateResDisk( Const Ident: Integer; Const DiskNo: Integer );
begin
  inherited CreateRes( Ident );

  if Message = '' then Message := RESOURCE_ERROR + IntToStr( Ident )
  else Message := Format( Message, [DiskNo] );
  FDisplayMsg := True;
  FResIdent   := Ident;
end;

constructor EZipMaster.CreateResDrive( Const Ident: Integer; Const Drive: String );
begin
  inherited CreateRes( Ident );

  if Message = '' then Message := RESOURCE_ERROR + IntToStr( Ident )
  else Message := Format( Message, [Drive] );
  FDisplayMsg := True;
  FResIdent   := Ident;
end;

//---------------------------------------------------------------------------
//***************************ZipShellFormat**********************************
constructor FormatThread.CreateFT( var MyParent: TZipMaster; CreateSuspended: Boolean );
begin
   inherited Create( CreateSuspended );

   if NOT Assigned( ParentMaster ) then
   begin
      ParentMaster    := MyParent;
      FreeOnTerminate := True;
      Priority        := tpNormal;
      ParentMaster.FBeginFormat := True;
   end else
      Terminate;   // We can't have two or more ZipMasters do a format simultaniously.
end;

//---------------------------------------------------------------------------
destructor FormatThread.Destroy;
begin
   ParentMaster := nil;
   inherited Destroy;
end;

//---------------------------------------------------------------------------
procedure FormatThread.Execute();
var
   OldMode:        Integer;
   SHFormatHandle: THandle;
   func: function( code: Integer; wp: WPARAM; lp: LPARAM ): LRESULT; stdcall;
begin
   OldMode := SetErrorMode( SEM_FAILCRITICALERRORS or SEM_NOGPFAULTERRORBOX );
   func    := CallWndRetProc;

   if Terminated = False then
   begin
      SHFormatHandle := LoadLibrary( 'Shell32.dll' );
      if SHFormatHandle <> 0 then
      begin
         @SHFormatDrive := GetProcAddress( SHFormatHandle, 'SHFormatDrive' );
         if @SHFormatDrive <> nil then
         begin
            Fhhk := SetWindowsHookEx( WH_CALLWNDPROCRET, func, 0, ThreadID );
            if Fhhk <> 0 then
            begin
               // The next call is a modal one, when we continue either format is ready,
               // canceled by the user or there is an error.
               ParentMaster.FFormatResult := SHFormatDrive( Application.Handle, ParentMaster.FDriveNr, $FFFF, 0 );
               UnhookWindowsHookEx( Fhhk );
            end;
            @SHFormatDrive := nil;
         end;
         FreeLibrary( SHFormatHandle );
      end;
   end else
      ParentMaster.FFormatResult := -1;	// Error.
   ParentMaster.FFound := 2;            // Always stop no matter what.
   SetErrorMode( OldMode );
end;

//---------------------------------------------------------------------------
// This works for W95, W98 english and dutch version; No garantees for any other OS.
function CallWndRetProc( Code: Integer; wp: WPARAM; lp: LPARAM ): LRESULT; stdcall; export;
var
   Msg:     ^CWPRETSTRUCT;
   th:       HWND;
   Itemstr:  Array[0..11] of Char;
begin
   Msg := Pointer( lp );

   if Code >= 0 then
   begin
      Sleep( 1 );
      // First thing we do when the format window gets created.
      if (Msg.message = WM_SHOWWINDOW) or (Msg.message = WM_ENABLE) then
      begin
         th := GetDlgItem( ParentMaster.Fhwnd, 35 );
         if th = Msg.hwnd then
            EnableWindow( th, False );   // Disable copy system files.
         th := GetDlgItem( ParentMaster.Fhwnd, 39 );
         if th = Msg.hwnd then
         begin
            CheckDlgButton( ParentMaster.Fhwnd, 39, BST_CHECKED );   // We always want a label.
            EnableWindow( th, False );                               // Disable the use of the label.
         end;
         th := GetDlgItem( ParentMaster.Fhwnd, 38 );
         if th = Msg.hwnd then
            EnableWindow( th, False );        // Disable the edit of the label.
         th := GetDlgItem( ParentMaster.Fhwnd, 41 );
         if th = Msg.hwnd then
            PostMessage( th, BM_SETCHECK, BST_UNCHECKED, 0 );        // No summary by default.
      end;
      // Click the Ok button.
      if (Msg.message = $0402) and (ParentMaster.ConfirmErase = False) and ParentMaster.FBeginFormat then
      begin
         th := GetDlgItem( ParentMaster.Fhwnd, 1 );
         PostMessage( th, BM_CLICK, 0, 0 );
         ParentMaster.FBeginFormat := False;
      end;
      // And reset the label to what it was.
      if (Msg.message = WM_SETTEXT) and (GetDlgItem( ParentMaster.Fhwnd, 38 ) = Msg.hwnd) then
      begin
         GetDlgItemText( ParentMaster.Fhwnd, 38, Itemstr, 12 );
         if StrComp( Itemstr, pChar(ParentMaster.FVolumeName) ) <> 0 then
            SetDlgItemText( ParentMaster.Fhwnd, 38, pChar(ParentMaster.FVolumeName) );
      end;
      // Close the format window.
      if (Msg.message = BM_SETSTYLE) and (ParentMaster.ConfirmErase = False) and (Msg.wParam = BS_PUSHBUTTON) then
      begin
         th := GetDlgItem( ParentMaster.Fhwnd, 2 );
         if th = Msg.hwnd then
            PostMessage( th, BM_CLICK, 0, 0 );
      end;
   end;
   Result := CallNextHookEx( Fhhk, Code, wp, lp );
end;


procedure Register;
begin
  RegisterComponents( 'Samples', [TZipMaster] );
end;

end.

