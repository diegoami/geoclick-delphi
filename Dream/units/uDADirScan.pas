{*****************************************************************************
 *
 *  uDADirScan.pas - Directory scanning component
 *
 *  Copyright (c) 2000 Diego Amicabile
 *
 *  Author:     Diego Amicabile
 *  E-mail:     diegoami@yahoo.it
 *  Homepage:   http://www.geocities.com/diegoami
 *
 *  This component is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation;
 *
 *  This component is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this component; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
 *
 *****************************************************************************}

unit uDADirScan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;


const MAXLEVELS = 15;
      MINLEVELS = 2;

type
  TSearchRecClass = class
     Time: Integer;
     Size: Integer;
     Attr: Integer;
     Name, FullName: String;
  end;

  TDAFileFoundEvent = procedure(Sender : TObject; FileName : STring;  var CanAdd : boolean) of object;
  TDAFileAddedEvent = procedure(Sender : TObject; FileName : STring) of object;
  TDADirFoundEvent = procedure(Sender : TObject; DirName : String; var CanAdd : boolean) of object;
  TDADirAddedEvent = procedure(Sender : TObject; DirName : String ) of object;
  TDADirEndEvent = procedure(Sender : TObject; DirName : String;  FilesFound: integer) of object;

  TDADirScan = class(TComponent)
  private
    FOnFileFound : TDAFileFoundEvent;
    FOnDirFound : TDADirFoundEvent;
    FOnFileAdded : TDAFileAddedEvent;
    FOnDirAdded : TDADirAddedEvent;
    FOnDirEnd : TDADirEndEvent;
    FRecursiveScan : Boolean;
    FCompleteData : Boolean;
    FAcceptedFiles : TStrings;
    FDirectory : String;
    FCopyToDir : String;
    IsCopying : Boolean;


    procedure InitDirImages;
    procedure SetLevels(Lev : Integer);
  protected
    AllStrings : TStrings;
    FLevels : integer;
    CurrentLevel : integer;
    FIlist : TImageList;
    fIBigList : TImageList;
    fiFolN, fiFolS : integer;
    fiBigFolN, fiBigFols : integer;
    function AddNode(S : String; SRC : TSEarchRecClass) : TOBject;


    property OnDirEnd : TDADirEndEvent read FOnDirEnd write FOnDirEnd;
    function AddSearchRec(SR : TSearchRec; Dir : String) : TSearchRecClass;

    procedure DeleteCurrentDir; virtual;
    procedure ScanDirectory(Dir : String; var FilesInThisDir : integer); virtual;
    function IsFileAcceptable(FileName : String) : boolean;
    procedure AddFile(Dirname, Filename : String; sr : TSearchRec); virtual;
    procedure AddDir(Dirname : String; sr : TSearchRec); virtual;
    procedure EndOfDir(DirName : String; MustDec : Boolean; FilesFound : Integer); virtual;
    procedure SetAcceptedFiles(AF : TStrings);
    procedure ClearTarget; virtual;
    procedure SetDirectory(Dir : String); virtual;
    class function GetLastDir(Dir : String) : String;
    function GetIndexOfImage(FileName : String; BigIcon : Boolean) : integer;
    class procedure AddBSlash ( var Val : string );
    class function DelBSlash ( const Val : string ) : string;
    function HasSubDirs(Dir : String) : boolean;

  public
    CurrDir : String;
    procedure ClearAll; dynamic;

    class function GetFirstDir(Dir : String) : String;
    class function IsADir(Name : String) : boolean;
    destructor Destroy; override;
    procedure Reload;
    constructor Create(AOwner : TComponent); override;
    property Directory : String read FDirectory write SetDirectory;


  published
    property OnDirFound : TDADirFoundEvent read FOnDirFound write FOnDirFound;
    property OnDirAdded : TDADirAddedEvent read FOnDirAdded write FOnDirAdded;
    property OnFileFound : TDAFileFoundEvent read FOnFileFound write FOnFileFound;
    property OnFileAdded : TDAFileAddedEvent read FOnFileAdded write FOnFileAdded;
    property Levels : integer read FLevels write setLevels; // how deep the directory tree is scanned
    property RecursiveScan : boolean read FRecursiveScan write FRecursiveScan; // whether the directory tree is recursively scanned
    property AcceptedFiles : TStrings read FAcceptedFiles write SetAcceptedFiles; // accepted extension
    property CompleteData : boolean read FCompleteData write FCompleteData; //not used
  end;

procedure Register;

implementation

{$R DADIRSCAN.DCR}

uses shellapi;


procedure TDADirScan.ClearAll;
begin

end;


function GetRelative(TotalPath : String; PartialPath : String) : String;
var LL : integer;
begin
  LL := Length(PartialPath);
  result := Copy(TotalPath,LL+1,Length(TotalPath)-LL)
end;





class function TDADirScan.IsADir(Name : String) : boolean;
begin
  result := Name[Length(Name)] = '\'
end;

function TDADirScan.AddNode(S : String; SRC : TSEarchRecClass) : TOBject;
begin
  result :=   TObject(AllStrings.Strings[AllStrings.AddObject(S, SRC)]);
end;

procedure TDADirScan.SetLevels(Lev : Integer);
{ how deep the directory tree is scanned }
begin
  FLevels := Lev;
  if Lev > MAXLEVELS then
    FLevels := MAXLEVELS;
  if Lev < MINLEVELS then
    FLevels := MINLEVELS;

{  if FDirectory <> '' then
    SetDirectory(FDirectory); }
end;

function TDADirScan.GetIndexOfImage(FileName : String; BigIcon : boolean) : integer;
var sfi : TSHFileInfo;
    flags : integer;

begin
  if BigIcon then
    flags := SHGFI_ICON or SHGFI_LARGEICON
  else
    flags := SHGFI_ICON or SHGFI_SMALLICON;
  SHGetFileInfo(PChar(FileName),0,sfi,SizeOf(TSHFileInfo),
    flags); // get the shell's image list's handle
  result := sfi.iIcon;
end;


class procedure TDADirScan.AddBSlash ( var Val : string );
 // code written by Markus Stephany
begin
     if Val <> ''
     then
        if Val[Length(Val)] <> '\'
        then
           Val := Val+'\';
end;


function TDADirScan.AddSearchRec(SR : TSearchRec; Dir : String) : TSearchRecClass;
var SRC : TSearchRecClass;
begin
  SRC := TSearchRecClass.Create;
  SRC.Time := SR.TIME;
  SRC.Attr := Sr.Attr;
  SRC.Name := SR.Name;
  SRC.Size := SR.Size;
  if (Sr.Attr and faDirectory) > 0then
    SRC.FullName := Dir
  else
    SRC.FullName := Dir+Sr.Name;

//  SearchRecList.Add(SRC);
  result := SRC;
end;

// remove a trailing backslash from val if there is one
class function TDADirScan.DelBSlash ( const Val : string ) : string;
// code written by Markus Stephany
begin
     Result := Val ;
     if Val <> ''
     then
         if Val[Length(Val)] = '\'
         then
             Delete ( Result , Length ( Val ) , 1 );
end;


procedure TDADirScan.Reload;
begin
  ClearAll;
  SetDirectory(FDirectory)
end;

procedure TDADirScan.SetDirectory(Dir : String);
var FilesInDir : integer;
begin
  FDirectory := Dir;
  ClearTarget;
  ScanDirectory(Dir, FilesInDir)
end;

procedure TDADirScan.SetAcceptedFiles(AF : TStrings);
{ strings are in form .BMP, .TXT }
var i : integer;
begin
 if AF = nil then
    FAcceptedFiles.Clear
  else
    FAcceptedFiles.Assign(AF);
  for i := 0 to FAcceptedFiles.COunt-1 do
    if Pos('.',FAcceptedFiles.Strings[i]) = 0 then
      FAcceptedFiles.Strings[i] := '.'+FAcceptedFiles.Strings[i];
  //InitOtherImages;
end;


procedure TDADirScan.InitDirImages;
 // code written by Markus Stephany
var fWinDir : String;
    sfi : TSHFileInfo;

begin
  SetLength ( fWinDir , MAX_PATH );
  SetLength ( fWinDir , GetWindowsDirectory(PChar ( fWinDir ),MAX_PATH));
  AddBSlash(fWinDir);
  FIList.Handle :=
    SHGetFileInfo(PChar ( fWinDir ),0,sfi,SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON); // get the shell's image list's handle
  fIList.ShareImages := True; // don't free the shell's image list on destroying our copy !
  fIFolN := sfi.iIcon;
  SHGetFileInfo(PChar ( fWinDir ),0,sfi,SizeOf(TSHFileInfo), SHGFI_OPENICON or
       SHGFI_SYSICONINDEX or SHGFI_SMALLICON); // get the shell's image list's handle
  fIFolS := sfi.iIcon;

  FIBigList.Handle :=
    SHGetFileInfo(PChar ( fWinDir ),0,sfi,SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_LARGEICON); // get the shell's image list's handle
  fIBigList.ShareImages := True; // don't free the shell's image list on destroying our copy !
  fIBigList.ShareImages := True;

  fIBigFolN := sfi.iIcon;
  SHGetFileInfo(PChar ( fWinDir ),0,sfi,SizeOf(TSHFileInfo), SHGFI_OPENICON or
       SHGFI_SYSICONINDEX or SHGFI_LARGEICON); // get the shell's image list's handle
  fIBigFolS := sfi.iIcon;

end;

constructor TDADirScan.Create(AOwner : TCOmponent);
begin
  inherited;
  FLevels := MAXLEVELS;
  AllStrings := TStringList.Create;
  FAcceptedFiles := TStringList.Create;
  FIList := TImageList.Create(Self);
  FIBigList := TImageList.Create(Self);
  InitDirImages;
end;

procedure TDADirScan.DeleteCurrentDir;
begin
end;

destructor TDADirScan.Destroy;

begin
  FAcceptedFiles.Free;
  AllStrings.Free;
  FIList.Free;
  FIBigList.Free;
  inherited;
end;

function TDADirScan.IsFileAcceptable(FileName : String) : Boolean;
var i : integer;
   FExt : String;
  CS : String;
  PP : Integer;
begin
{file must have one of the accepted extensions }
  result := false;
  if FAcceptedFiles = nil then exit;
  for i := 0 to FAcceptedFiles.Count-1 do begin
    CS := FAcceptedFiles.Strings[i];
    if Pos('*',CS) > 0 then begin
      result := true; break
    end;
    PP := Length(FileName)-Pos('.',FileName);
    FExt := Copy(Filename,Length(FileName)-PP,PP+1);
    if CompareText(FEXT,CS) = 0 then begin
      result := true; break
    end;
  end;
end;

class function TDADirScan.GetLastDir(Dir : String) : String;
  var PP : integer;
     CS : String;
{ gets last part of a dir }
  begin
    PP := Pos('\',Dir);
    CS := Copy(Dir,PP+1,Length(Dir)-PP);
    if CS = '' then
      result := DelBSlash(Dir)
    else
      result := GetLastDir(CS);
  end;

class function TDADirScan.GetFirstDir(Dir : String) : String;
{ gets first part of a dir }

  var
    CS : String;
     CL : integer;
  begin
    CL := Length(GetLastDir(Dir));

    CS := Copy(Dir,1,Length(Dir)-CL-1);
    result := CS;
  end;


procedure TDADirScan.ScanDirectory(Dir : String; var FilesInThisDir : integer);
var FilesFound : integer; // has this directory accepted files?

{ main part }
  procedure ProcessSearchRec(Sr : TSearchRec);
  var
      DataString : String;

      CanAdd : boolean;
      FilesInDir : integer;
  begin
    if ((sr.Attr and faDirectory) > 0) and (sr.Name <> '.') and (sr.Name <> '..') then begin
      DataString := Dir+sr.Name+'\';
      CanAdd := {(FRecursiveScan) and }(CurrentLevel < (FLevels));
      if Assigned(FOnDirFound) then

        FOnDirFound(Self,DataString, CanAdd);
      if CanAdd then begin

        AddDir(DataString, sr);
        if Assigned(FOnDirAdded) then
          FOnDirAdded(Self,DataString)
      end;

      if (FRecursiveScan) and (CurrentLevel < (FLevels)) then begin
        ScanDirectory(DataString, FilesInDir);
        inc(FilesFound, FilesInDir);
      end
      else begin

        if Assigned(FOnDirEnd) then //begin
          FOnDirEnd(Self, DataString,  FilesFound);
        EndOfDir(DataString, true, FilesFound);

      end

    end else if ((sr.Attr and faDirectory) <= 0) then begin
      DataString := Dir+sr.Name;
      if IsFileAcceptable(DataString)  then begin
        inc(FilesFound);
        CanAdd := True;
        if Assigned(FonFileFound) then
          FOnFileFound(Self,Dir+sr.Name,  canAdd);
        if CanAdd then begin
          AddFile(Dir,sr.Name,sr);
          if Assigned(FOnFileAdded) then
            FOnFileAdded(Self,Dir+sr.Name)
        end;
      end;
    end;
  end;

var sr: TSearchRec;


begin
  FilesFound := 0;
  CurrDir := Dir;
  if (FindFirst(Dir+'*.*', faAnyFile, Sr) = 0) then
    ProcessSearchRec(sr);
  while (FindNext(sr) = 0) do
    ProcessSearchRec(sr);
  FindClose(sr);
  if Assigned(FOnDirEnd) then
    FOnDirEnd(Self, Dir, FilesFound);
  EndOfDir(Dir,true, FilesFound);
  FilesInThisDir := FilesFound;
end;

function TDADirScan.HasSubDirs(Dir : String) : boolean;
var Sr : TSearchRec;
  FN : integer;
{ used when tree is not completely scanned to see if it can be expanded }
begin
  FindFirst(Dir+'*.*', faDirectory, Sr);
  repeat
    FN := FindNext(sr);
  until ((sr.Name <> '.') and (sr.Name <> '..') and ((sr.Attr and faDirectory) > 0))
    or IsFileAcceptable(sr.Name) or (FN <> 0);
  result := FN = 0;
  FindClose(sr)
end;

procedure TDADirScan.AddFile(Dirname, Filename : String; Sr : TSearchRec);
begin

end;

procedure TDADirScan.EndOfDir(DirName : String; MustDec : Boolean; FilesFound : Integer);
begin
  if RecursiveScan and MustDec then
    Dec(CurrentLevel);
end;




procedure TDADirScan.AddDir(Dirname : String; Sr : TSearchREc);

begin
  if RecursiveScan then
    Inc(CurrentLevel);
  if CurrentLevel < 0 then
    CurrentLevel := 0;
  if IsCopying then
    CreateDir(GetRelative(Directory,DirName));
end;

procedure TDADirScan.ClearTarget;
begin
  CurrentLevel := 1;
end;

procedure Register;
begin
  RegisterComponents('Diego Amicabile', [TDADirScan]);
end;

end.
