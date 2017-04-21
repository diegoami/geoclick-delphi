///////////////////////////////////////////////////////////////////////////////
//////////////////////////THyperImages Component V.2///////////////////////////
///////////////////Copyright © 1998-1999 Noatak Racing Team////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////Property and component editors//////////////////////////////
///////////////////////////////////////////////////////////////////////////////

unit PropEdit;

interface

uses Windows, Classes, Graphics;

procedure Register;

implementation
uses DsgnIntf, CustomHImages, HImages, HSEdit;

type
  TDirNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  THotPictureProperty = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  THotSpotEditor = Class(TComponentEditor)
    procedure Edit; override;
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

  TPictureFileNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
  end;


//////////TPictureFileNameProperty/////////////

function TPictureFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paReadOnly];
end;

///////////TDirNameProperty/////////////

function TDirNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TDirNameProperty.Edit;
var Directory, InitDir: String;
    AHandle: HWnd;
begin
  Ahandle := GetActiveWindow;
  InitDir := PathWithoutBackSlash((GetComponent(0) as THyperImages).PicturesDir);
  Directory := BrowseForDir(Ahandle, InitDir, BrowseDialogCaption, BrowseDialogPrompt);
  if Directory <> '' then begin
    (GetComponent(0) as THyperImages).PicturesDir := Directory ;
    if Directory[Length(Directory)] <> '\' then
      Directory := Directory + '\';
    Modified;
  end;
end;

///////////THotPictureProperty/////////////

function THotPictureProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure THotPictureProperty.Edit;
begin
  if  EditHyperImages(GetComponent(0) as THyperImages, True) then
    with (GetComponent(0) as THyperImages) do
      Self.Modified;
end;

///////////THotSpotEditor////////////////

procedure THotSpotEditor.Edit;
begin
   if EditHyperImages(Component as THyperImages, True) then begin
    with (Component as THyperImages) do begin
      Scale := Scale ;  //To force repaint of the Image;
      Designer.Modified;
    end;
  end;
end;

function THotSpotEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

function THotSpotEditor.GetVerb(Index: Integer): string;
begin
  case index of
    0 : Result := '&Edit Hot Spots...';
    1:  Result := 'Abou&t...';
  end;
end;

procedure THotSpotEditor.ExecuteVerb(Index: Integer);
begin
  case index of
    0 : Edit;
    1:  ShowAbout;
  end;
end;

//////////////////////////////////////////////

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(String), THyperImages, 'PicturesDir', TDirNameProperty);
  RegisterPropertyEditor(TypeInfo(String), THyperImages, 'PictureFileName', TPictureFileNameProperty);
  RegisterPropertyEditor(TypeInfo(TPicture), THyperImages, 'Picture', THotPictureProperty);
  RegisterPropertyEditor(TypeInfo(TStringList), THyperImages, 'HotspotsDef', THotPictureProperty);
  RegisterComponentEditor(THyperImages, THotSpotEditor);
end;
end.
 