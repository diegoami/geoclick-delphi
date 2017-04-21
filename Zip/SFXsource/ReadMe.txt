Information about the delzip sfx : (last changes made : Oct 03,1998)
(C) 1997-1998 Carl Bunton, Eric W. Engler, Markus Stephany


Credits to:
- Thomas Hoelzer (thoelzer@cityweb.de) for correcting an error while
extraction of directory names 090198

- Deepu Chandy Thomas (deepuct@hotmail.com) for adding the
SHBROWSEFORFOLDER routines (083198)

- Todd Fast (tfast@eden.com) for permission to use his source code to
add a button to the SHBrowseForFolder dialog.

- Didier Havelange (Didier.Havelange@ping.be) for adding the autorun feature 
100298

Contents:

1. compilation notes
2. the structure of a zipsfx-file
3. disclaimer
         

1. ****************************************** compilation notes :

IMPORTANT NOTES YOU MUST READ!!!

This project has not been tested with Delphi 4.  We expect Delphi
4 to give much larger code, so it is not recommended to use
Delphi 4.

To compile this project under Delphi2/3 correctly, you should do
the following :

- compiling the sfx source without having the original SFX.DOF
  increases the size of the executable.  I am now including the
  original SFX.DOF file.  Do NOT modify the .DOF file unless
  you don't mind a larger executable!

- if the project-options are displayed (not even changed!)
  within the Delphi IDE, the size will increase, too.

- to get the sfx running properly, you should first compile it to
  determine the size of your .EXE file.  After that, edit the file:
  "dialogsel.pas", and make sure "startoffile" is set to the size
  of YOUR new SFX.EXE file.

  To find the location in DIALOGSEL.PAS to put the size of the
  SFX.EXE size, find procedure "getdefaultparams". Then look for
  this line:
     startoffile := 37888;

  Change this line to show the new size of your SFX.EXE file.
  Then, compile the project again.

- after recompiling the SFX project, do NOT let Delphi save the
  changes!  If you let it save the changes, it'll screw up the .DOF
  file, and your next executable will be larger!  If you want to
  modify the code and save it, make sure you restore the original
  .DOF file later so you can have a smaller .EXE!

- after recompiling the SFX project, rename SFX.EXE to ZIPSFX.BIN,
  and copy it over the top of your last version of ZIPSFX.BIN
  (normally in the WINDOWS SYSTEM folder).


2. ********************************* the structure of a zipsfx-file :

- zipsfx-executable code (0-xxxxx)
- signature "MPU"                         
  zip-archive
              |_ rest of the special header
-                                             |_ zip-archive

the structure of the special-header :
Byte 0..2   : signature "MPU"

Byte    3   : Bit 0 (val  1) : if set, user can disable running the
                             command line after extraction (if any)
              Bit 1 (val  2) : if set, user can choose what files
                             to extract
              Bit 2 (val  4) : if set, user cannot change the
                             overwrite-mode (confirm, overwrite, skip)
              Bit3-4(val 8,16) : default-overwrite mode
                     0 : confirm overwriting existing files
                     8 : overwrite existing files
                    16 : skip existing files
              Bit5 (val 32) : only set if NO size checking wanted
              Bit6 (val 64) : if set, then automatically extract all files 
                              (autorun)
	      HINT : autorun works only if the first char of the filename is a "!" !	
  
Byte    4   : length of user-defined caption / 0=default caption
        5   : length of default-extraction-path / 0=current directory
        6   : length of command line to start after extraction / 0=none


Byte 7..m   : the dialog's caption, if byte 4 <> 0 ( without terminating zero)

     m+1..n : the default-extraction-path, if byte 5 <> 0 (dito)

              ++++added  march 01,98 if set to "><", then use temp-dir

     n+1..x : the command line to execute after successfull
              extraction, if byte 6 <> 0 (dito)
              format : 
                The command line has a special format.

              1) If the string "><" (greater than+less than) is
              somewhere in the command line, it will be replaced with
              the path where the archive has been extracted to.
              (e.g. "><readme\test.txt" after an extraction to the
              path "C:\Program files\unpacked" means :
              "c:\progra~1\unpacked\readme\test.txt") <- the short
              path will be created by zipsfx.

              2) if the pipe "|" is in the command-line, the part to
              the left will get the application to run
              and the part to the right will be it's argument;
              if the archive is extracted to e.g. "d:\unpack", then
              we will get the following :

              "><setup\setup.exe|><install.inf" will parse to :
              run "d:\unpack\setup\setup.exe" with parameters
              "d:\unpack\install.inf".

              "c:\windows\notepad.exe|><readme.txt" will parse to :
              run "c:\windows\notepad.exe" with parameters
              "d:\unpack\readme.txt".

              "><readme.txt" will parse to :
              open "d:\unpack\readme.txt" with its associated
              program, if there is any.

              "><setup.exe" will run "d:\unpack\setup.exe" without
              special parameters.
              ...

Since the special header always has a size of 256 bytes, it must be
filled to fit (and if the three strings are too long, there will
occur some problems)


3. ****************************************** disclaimer :

This software is provided "as is" without warranty of any kind, 
either expressed or implied.  the entire risk as to the
quality and performance of the software is with you.  should the
software prove defective, you assume the cost of all necessary
servicing, repair, or correction.  in no event shall the author,
copyright holder, or any other party who may redistribute the
software be liable to you for damages, including any general,
special, incidental, or consequential damages arising out of
the use or inability to use the software (including, but not
limited to, loss of data, data being rendered inaccurate, loss of
business profits, loss of business information, business 
interruptions, loss sustained by you or third parties, or a 
failure of the software to operate with any other software) even
if the author, copyright holder, or other party has been advised
of the possibility of such damages.

                      distribution policy
              guidelines for legal re-distribution

  1) this applies to both end-users and developers.
    
  2) you must not charge money for any part of the sfx package.
     warning:  the primary concern here is if you will market a
     new package that is only slightly more than a verbatim copy 
     of this package, or one of it's demos.  any release you sell
     is ok as long as you charge only for the changes you make.

  3) you must handle product support with your own end-users.
     this is imperative, because i don't have enough time to
     do support for end-users.

  4) i will handle support issues with programmers using this 
     package on a time-available basis. since this is being
     distributed as freeware, you can't expect the kind of 
     support you'd get from a commercial vendor.  please limit
     your questions to those that directly pertain to this
     sfx package.

all the best from markus stephany         oct 03, 1998

    mirbir.st@t-online.de
    http://home.t-online.de/home/mirbir.st

