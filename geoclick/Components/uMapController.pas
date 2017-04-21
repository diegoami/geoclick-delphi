unit uMapController;

interface

uses CustomHImages, HImages, ExtCtrls, JPeg, StdCtrls,  Classes, Forms, UMapForm,
SysUtils, Controls;
type

TMapController = class
  constructor Create(Module : String);
  public
    PictureDir : String;
    PictureList : TStrings;
    function CreateNewMap(ImageFileName : String; Parent : TWinControl) : TForm;
//    procedure ShowDescription(HotSpotId : String; MapForm : TMapForm);
  protected
    ActiveMap : TMapForm;
    MapList : TList;
  private

    HotSpots : TStringList;
    function GetListOfBitmaps(SL : TStrings) : TStrings;

end;

var MapController : TMapController;


implementation

constructor TMapController.Create(Module : String);
var Hotspotfile : String;
begin
   PictureDir := ExtractFilePath(Application.ExeName) + Module + '\';
   HotSpotFile := PictureDir + Module +'.hsf';
   HotSpots := TStringList.Create;
   HotSpots.LoadFromFile(HotSpotFile);
   MapList := TList.Create;
   PictureList := GetListOfBitmaps(HotSpots) ;
end;


function TMapController.CreateNewMap(ImageFileName : String; Parent : TWinControl) : TForm;
var MapForm : TMapForm;
begin
     //
     Application.CreateForm(TMapForm, MapForm);
     //MapForm.Parent := Parent;
     //MapForm.Owner := Self;
     MapForm.HyperImages.PicturesDir := PictureDir;
     MapForm.HyperImages.HotSpotsDef := HotSpots;
     MapForm.HyperImages.LoadImageFromFile(ImageFileName);
     MapList.Add(TMapForm);
     MapForm.Show;
     result := MapForm;

end;
                       {
procedure TMapController.ShowDescription(HotSpotId : String; MapForm : TMapForm);
var TS : TStrings;
begin
  TS := TStringList.Create;
  TS.Add(HotSpotId);
  MapForm.ShowDesc(TS);
end;                     }

function TMapController.GetListOfBitmaps(SL : TStrings) : TStrings;
var i : integer;
    S, FS: string;
    Pi : integer;
    RL : TSTringList;

begin
  RL := TStringList.Create;
  for I := 0 to SL.Count-1 do begin
    S := SL.Strings[I];
    if Pos('=',S) > 0 then begin
      Pi := Pos('\',S);
      FS := Copy(S,1,Pi-1);
      if RL.IndexOf(FS) = -1 then
        RL.Add(FS);
    end;
  end;
  result := RL;
end;









end.
