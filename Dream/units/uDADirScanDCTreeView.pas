{*****************************************************************************
 *
 *  uDADirScanTreeView.pas - Directory scanning - TreeView filling component
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


unit uDADirScanDCTreeView;

interface



uses
  uDaDirScan, Windows, Messages, SysUtils, Classes, Graphics,
   Controls, Forms, Dialogs, comctrls , dcdtree 
   ;

type
  TDADirScanDCTreeView = class(TDADirScan)
  private
    FTreeView : TDCMSTreeView;

    FEmptyDirs : boolean;

    Nodes : array[0..MAXLEVELS] of  TTreeNode;
  protected
    procedure DeleteCurrentDir; override;
    procedure ScanDirectory(Dir : String; var FilesInThisDir : integer); override;
    procedure EndOfDir(DirName : String; MustDec : Boolean; FilesFound : integer); override;
    procedure AddFile(Dirname, Filename : String; Sr : TSearchRec); override;
    procedure AddDir(Dirname : String; Sr : TSearchRec); override;
    procedure ClearTarget; override;
    procedure SetDirectory(Dir : String); override;
  public
    CurrNode : TTreeNode;
    destructor Destroy; override;
    function GetFileNameAtNode(Node : TTreeNode) : String;
    procedure FillNode(Node : TTreeNode; DirName : String);
    constructor Create(AOwner : TComponent); override;
    procedure ClearAll; override;
  published
    property OnDirEnd;
    property EmptyDirs : boolean read FEmptyDirs write FEmptyDirs;
    property TreeView : TDCMSTreeView read FTreeView write FTreeView;
  end;

procedure Register;

implementation

{$R DADIRSCANTREEVIEW.DCR}

procedure TDaDirScanDCTreeView.ClearAll;
var i : integer;
begin
  if FtreeView = nil then exit;
  for i := FTreeView.Items.Count-1 downto 0 do
    TSearchRecClass(FTreeView.Items[i]).Free
end;

procedure TDaDirScanDCTreeView.SetDirectory(Dir : String);
begin
  if Assigned(FTreeView) then begin
    FTreeView.Items.BeginUpdate;
    inherited;
    FTreeView.Items.EndUpdate;

  end;
end;

procedure TDaDirScanDCTreeView.ScanDirectory(Dir : String; var FilesInThisDir : Integer);
begin
  inherited;
end;

function TDaDirScanDCTreeView.GetFileNameAtNode(Node : TTreeNode) : String;
begin
  if CompleteData then
    result := TSearchRecClass(Node.Data).FullName
  else
    result := '';
end;

procedure TDaDirScanDCTreeView.AddFile(Dirname, Filename : String; Sr : TSearchRec);
var SRC : TSearchRecClass;
begin
  SRC := AddSearchRec(SR,Dirname);

  if Assigned(FTreeView) then begin

    CurrNode := FTreeView.Items.AddChild(Nodes[CurrentLevel],FileName);
    CurrNode.ImageIndex    := GetIndexOfImage(DirName+FileName,false);
    CurrNode.SelectedIndex    := GetIndexOfImage(DirName+FileName,false );
    if CompleteData then
      CurrNode.Data := SRC;
  end;
end;

procedure TDaDirScanDCTreeView.DeleteCurrentDir;
//not used

begin
  inherited;
   if  not Currnode.Haschildren then
     CurrNode.Delete;
end;




constructor TDaDirScanDCTreeView.Create(AOwner : TComponent);
begin
  inherited;
  if Assigned(FTreeView) then begin
    FTreeView.Images := fIList;
    FTreeView.Items.Clear;
  end;
end;

destructor TDaDirScanDCTreeView.Destroy;

begin
  inherited;
end;


procedure TDaDirScanDCTreeView.EndOfDir(DirName : String; MUstDec : Boolean; FIlesFound : Integer);
begin
  inherited;
  if COmpleteData = false then exit;
  if (CurrNode <> nil) and IsaDir(GetFileNameAtNode(CurrNode))  then begin
    CurrNode.HasChildren := HasSubDirs(DirName)  ;
    if not ((CurrNode.HasChildren and (FilesFound > 0)) or FEmptyDirs ) then
      FTreeView.Items.Delete(CurrNode);
    CurrNode := Nodes[CurrentLevel];
  end;
end;

procedure TDaDirScanDCTreeView.AddDir(Dirname : String; Sr : TSearchRec);
var LastDir : String;
  SRC : TSearchRecClass;
begin
  SRC := AddSearchRec(SR,Dirname);

  if Assigned(FTreeView) then begin
    LastDir := GetLAstDir(DirName);
    Nodes[CurrentLevel+1] := FTreeView.Items.AddChild(Nodes[CurrentLevel],LastDir);
    CurrNode := Nodes[CurrentLevel+1];
    CurrNode.ImageIndex    := fiFolN;
    CurrNode.SelectedIndex := fiFolS;
    if CompleteData then
      CurrNode.Data := SRC;
  end;
  inherited;
end;

procedure TDaDirScanDCTreeView.FillNode(Node : TTreeNode; DirName : String);
var FilesInDir : Integer;
begin
  FilesInDir := 0;
  Node.DeleteChildren;
  CurrentLevel := Node.Level+1;
  FLevels := FLevels+Node.Level;
  CurrNode := Node;
  Nodes[CurrentLevel] := CurrNode;
  ScanDirectory(DirName, FilesInDir);
  FLEvels := FLevels - Node.Level;
end;

procedure TDaDirScanDCTreeView.ClearTarget;
var i : integer;
begin
  inherited;
  if Assigned(FTreeView) then begin
    FTreeView.Items.Clear;
    FTreeView.Images := fIList
  end;
  ClearAll;

  CurrNode := Nil;

  for i := 0 to MAXLEVELS do
    Nodes[i] := nil;
end;

procedure Register;
begin
  RegisterComponents('Diego Amicabile', [TDaDirScanDCTreeView]);
end;



end.
