unit Unit1;    { ViewZip - Demo4 of Delphi Zip v1.51 }
{ This is a Delphi example of how a small self-installing program
  might be written.  If it runs with an argument of /INSTALL, it automatically
  brings up the install menu.  If it runs with an argument of /UNINSTALL
  (such as when running from the Control Panel Uninstall option), it
  does the uninstall and exits.  If the argument is anything else, then
  it assumes it's a zip file and tries to open it.

  IMPORTANT!!!  The "InstUnit" is designed for Win95 Registry keys.  It
  should work on Win98, but it will likely require some tweaks for WinNT.
  YOU HAVE BEEN WARNED!
}
Interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, SortGrid, InstUnit, ZipMstr, ImgList;

{$IfDef VER90}
   type LPCTSTR = PChar;
{$EndIf}

// Prototypes for functions that we explicitly import from Kernel32.DLL
type PROCFREELIBRARY     = function( hInst: THandle ): Boolean; stdcall;
type PROCDELETEFILE      = function ( aFile: LPCTSTR ): Boolean; stdcall;
type PROCREMOVEDIRECTORY = function( aDir: LPCTSTR ): Boolean; stdcall;
type PROCEXITPROCESS     = procedure( aVal: DWORD ); stdcall;

// Data structure containing all the information we need to delete ourself,
// remove our containing directory, and terminate ourself.
type DELEXEINFO = packed record
   hInstExe:           THandle;
   pfnFreeLibrary:     PROCFREELIBRARY;
   pfnDeleteFile:      PROCDELETEFILE;
   FileName:           Array [0..MAX_PATH] of Char;
   pfnRemoveDirectory: PROCREMOVEDIRECTORY;
   Dir:                Array [0..MAX_PATH] of Char;
   pfnExitProcess:     PROCEXITPROCESS;
   ExitCode:           DWORD;
 end;
type pDELEXEINFO = ^DELEXEINFO;

type PROCDELEXE = procedure( pDEI: pDELEXEINFO ); stdcall;

type
  TForm1 = class( TForm )
    Panel1:      TPanel;
    OpenBut:     TButton;
    CancelBut:   TButton;
    InstBut:     TButton;
    Label1:      TLabel;
    Label2:      TLabel;
    ZipFName:    TLabel;
    Label4:      TLabel;
    OpenDialog1: TOpenDialog;
    SortGrid1:   TSortGrid;
    ZipDir1:     TZipMaster;
    ImageList1:  TImageList;

    procedure FormCreate( Sender: TObject );
    procedure FormActivate( Sender: TObject );
    procedure OpenButClick( Sender: TObject );
    procedure CancelButClick( Sender: TObject );
    procedure InstButClick( Sender: TObject );

  private
    { Private declarations }

  public
    { Public declarations }
    AutoUninstall: Boolean;

    procedure FillGrid;
  end;

const
  HEAP_ZERO_MEMORY = $00000008;   // Where defined?

var
  Form1: TForm1;

  procedure DelExeInjCode( pdei: PDELEXEINFO ); stdcall;
  procedure AfterDelExeInjCode; stdcall;
  procedure KillMySelf( exitcode: Integer; fRemoveDir: Boolean ); stdcall;

Implementation

{$R *.DFM}

procedure TForm1.FormCreate( Sender: TObject );
begin
   with SortGrid1 do
   begin
      Cells[0, 0]  := 'File Name';
      Cells[1, 0]  := 'Compr Size';
      Cells[2, 0]  := 'Uncmpr Size';
      Cells[3, 0]  := 'Date/Time';
   end;

   { Allowable Command Line parameters:
       a zip filename = display it's contents
       /install = bring up install menu automatically
       /uninstall = do the uninstall and quit (no menu)
   }
   if ParamCount > 0 then
   begin
      if UpperCase( ParamStr( 1 ) ) = '/INSTALL' then
      begin
         AutoUnInstall := False;
         InstButClick( Self );   { show install menu }
      end
      else if UpperCase( ParamStr( 1 ) ) = '/UNINSTALL' then
      begin
         AutoUnInstall := True;
         InstButClick( Self );  { do the un-install }
      end
      else
      begin
         { someone passed us an argument that is most likely
         the name of a zip file }
         if FileExists( ParamStr( 1 ) ) then
         begin
            ZipFName.Caption := ParamStr( 1 );
            { This assignment causes zipfile to be read: }
            ZipDir1.ZipFileName := ZipFName.Caption;
            FillGrid;
         end
         else
            ShowMessage( 'File Not Found: ' + ParamStr( 1 ) );
      end;
   end;
end;

procedure TForm1.FormActivate( Sender: TObject );
begin
   if AutoUnInstall then
      { The user just un-installed us: either from the Control Panel, or
        from our Install Menu.  Either way, he obviously doesn't want
        us to continue running now. }
      Close;
end;

procedure TForm1.OpenButClick( Sender: TObject );
begin
   if OpenDialog1.Execute then
   begin
      ZipFName.Caption := OpenDialog1.Filename;
      { This assignment causes zipfile to be read: }
      ZipDir1.ZipFileName := ZipFName.Caption;
      FillGrid;
   end;
end;

procedure TForm1.CancelButClick( Sender: TObject );
begin
   Close;
end;

procedure TForm1.InstButClick( Sender: TObject );
var
   InstForm: TInstForm;
begin
   InstForm := TInstForm.Create( Self );
   InstForm.ShowModal;
   InstForm.Destroy;
end;


//---------------------------------------------------------------------------
procedure TForm1.FillGrid;
var
  i:  Integer;
  so: TSortOptions;
begin
  with SortGrid1 do
  begin
    { Empty data from string grid }
    ClearFrom( 1 );
    RowCount := ZipDir1.Count + 1;
    if ZipDir1.Count = 0 then
       Exit;

    for i := 1 to ZipDir1.Count do
    begin
       with ZipDirEntry( ZipDir1.ZipContents[i - 1]^ ) do
       begin
          { The "-1" below is an offset for the row titles }
          Cells[0, i] := FileName;
          Cells[1, i] := IntToStr( CompressedSize );
          Cells[2, i] := IntToStr( UncompressedSize );
          Cells[3, i] := FormatDateTime( 'ddddd  t', FileDateToDateTime( DateTime ) );
       end; // end with
    end; // end for

    so.SortDirection := sdAscending;
    so.SortStyle     := ssAutomatic;
    so.SortCaseSensitive := False;
    SortByColumn( SortColumn, so );
  end; // end with
end;

//---------------------------------------------------------------------------
// Code to be injected into our own address space.
procedure DelExeInjCode( pdei: pDELEXEINFO ); stdcall;
begin
  // Remove the EXE file from our address space
  pdei.pfnFreeLibrary( pdei.hinstExe );

  // Delete the EXE file now that it is no longer in use
  pdei.pfnDeleteFile( pdei.FileName );

  if @pdei.pfnRemoveDirectory <> nil then // Remove the directory (which is now empty)
     pdei.pfnRemoveDirectory( pdei.Dir );

  // Terminate our process
  pdei.pfnExitProcess( pdei.ExitCode );
end;

// This function just marks the end of the previous function.
procedure AfterDelExeInjCode; stdcall
begin
end;

procedure KillMySelf( exitcode: Integer; fRemoveDir: Boolean ); stdcall
var
  dei:       DELEXEINFO;
  hinstKrnl: THandle;
  hheap:     THandle;
  FuncSize:  Integer;
  pfnDelExe: PROCDELEXE;
  P:         PChar;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
     Exit;

  hinstKrnl := GetModuleHandle( 'KERNEL32' );
  hheap	    := GetProcessHeap();

  // Calculate the number of bytes in the DelExeInjCode function.
  FuncSize := Integer(DWord(@AfterDelExeInjCode) - DWord(@DelExeInjCode));

  // From our process's default heap, allocate memory where we can inject our own function.
  @pfnDelExe := HeapAlloc( hheap, HEAP_ZERO_MEMORY, FuncSize );

  // Inject the DelExeInjCode function into the memory block
  CopyMemory( @pfnDelExe, @DelExeInjCode, FuncSize );

  // Initialize the DELEXEINFO structure.
  dei.hinstExe := GetModuleHandle( nil );
  @dei.pfnFreeLibrary := GetProcAddress( hinstKrnl, 'FreeLibrary' );

  // Assume that the subdirectory is NOT to be removed.
  dei.pfnRemoveDirectory := nil;
  @dei.pfnDeleteFile := GetProcAddress( hinstKrnl, 'DeleteFileA' );
  GetModuleFileName( dei.hinstExe, dei.FileName, MAX_PATH );

  if fRemoveDir then
  begin	// The subdirectory should be removed.
    @dei.pfnRemoveDirectory := GetProcAddress( hinstKrnl, 'RemoveDirectoryA' );
    StrCopy( dei.Dir, dei.FileName );
    P := StrRScan( dei.Dir, '\' );
    if P <> nil then
       P^ := #0;
  end;

  @dei.pfnExitProcess := GetProcAddress( hinstKrnl, 'ExitProcess' );
  dei.ExitCode := exitcode;

  pfnDelExe( @dei );
  // We never get here because pfnDelExe never returns.
end;

End.
