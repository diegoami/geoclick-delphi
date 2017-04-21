unit uHSFTreeView;
{per caricare questo albero si puo assegnare la proprieta Directory
  oppure usare Assign per i Treenodes da un altro albero, assegnare
  AllFiles da CheckFiles dell'altro albero e poi effettuare
  un potaggio in base all'estensione.
  E' uno schifo lo so.
  Nel caricamento il campo data e' una stringa.
  Il casino deriva dall'avere voluto usare lo stesso oggetto per due
  alberi aventi due funzionalita sostanzialmente diverse, il primo per
  selezionare quali file caricare, il secondo per muoversi tra i vari file
  di immagini.
  TO do : un ripensamento di questa (pessima) soluzione.
}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dcDTree, DcTree, comctrls, uDCNewBrowseTreeVie;

type

  THSFTreeView = class(TDCNewBrowseTreeView)
    private
      SDSTrings : TStrings;
      HsfBitmap : TBitmap;
    protected
      procedure SetDirectory(Dir: String); override;
    public
      procedure Loaded; override;
      function GetHsfFilesForDir(Dir : String) : TStrings;
      constructor Create(AOwner :TCOmponent); override;
      destructor Destroy; override;
    end;

procedure Register;

implementation

procedure THSFTreeView.SetDirectory(Dir: String);
begin
  inherited SetDirectory(Dir);
  DeleteEmptyDirs;
  SetChecked;
end;

procedure THsfTreeView.Loaded;
begin
  inherited Loaded;
  CheckBoxes := True;
end;


constructor THSFTreeView.Create(AOwner :TCOmponent);
var Accepted : TStrings;

  ExeFileName : String;
begin
  inherited Create(AOwner);
  EXeFileName := ExtractFilePath(Application.ExeName);
  SDStrings := TStringLIst.Create;
  try
    HsfBitmap := TBitmap.Create;
    HsfBitmap.LoadFromFile(ExeFileName+'Components\hsf2.bmp');
    Accepted := TStringList.Create;
    Accepted.AddObject('.hsf',HsfBitmap);
    AcceptedFiles.Assign(Accepted);
    Accepted.Free;
  except on Exception do
    
    raise Exception.Create('Missing files. Please reinstall');
  end;

end;

destructor THSFTreeView.Destroy;
begin
  SDStrings.Free;
  HsfBitmap.Free;
  
  inherited;
end;

function THSFTreeView.GetHsfFilesForDir(Dir : String) : TStrings;
var i : integer;

begin
  SDStrings.Clear;
  for i := 0 to AllFiles.COunt-1 do
    if ExtractFilePath(AllFiles.Strings[i])= Dir then
      SDStrings.Add(ExtractFileName(Allfiles.Strings[i]));
  result := SDStrings;
end;

procedure Register;
begin
  RegisterComponents('Geoclick', [THSFTreeView]);
end;

end.
