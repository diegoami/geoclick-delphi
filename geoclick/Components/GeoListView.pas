unit GeoListView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, uGeoController;

type
  //TOnChangeName = procedure(Filename : String; Oldname, NewName : String) of object;
  TGeoListView = class(TListView)
  private
    ListLoaded : Boolean;
    TSL : TStringList;
    TotalNames : TStrings;
    FFileName : String;

  protected
    FCheckedItems : boolean;
//    procedure GeoChanging(Sender: TObject; Item: TListItem; Change: TItemChange; var AllowChange: Boolean) ;
    procedure GeoChange(Sender: TObject; Item: TListItem; Change: TItemChange);
  public
    constructor Create(Sender : TComponent);
    procedure LoadNamesFromFile(HFileName : String);
    procedure Load(currnode : boolean);
    procedure WriteHotSpotToFile(FileName : String; Oldname, Newname : String);

  published
    property CheckedItems : boolean read FCheckedItems write FCheckedItems;
    property FileName : String read FFileName write LoadNamesFromFile;
    //property OnChangeName : TOnChangeName read FOnChangeName write FOnChangeName;
  end;

procedure Register;

implementation

uses stringfns;
                                  {
procedure TGeoListView.ConvertToMute(SG : TStrings);
var PS, PR : String;
   i : integer;
begin

  if isMute then
    for i := 0 to SG.Count-1 do begin
      PS := HyperImages.ExtractPicture(SG.Strings[i]);
      PR := Copy(PS,1,Length(PS)-4)+'_mute'+Copy(PS,length(PS)-3,4);
      SG.Strings[i] := ReplaceStr(SG.Strings[i],PS,PR);
    end;
end;
                                   }

procedure TGeoListView.LoadNamesFromFile(HFileName : String);

var i : integer;
  currstr : String;

  pose, poss : integer;
  sta : String;
begin
  TotalNames.Clear;
  TSL.Clear;
  try
    TSL.LoadFromFile(HFileName);
    FFileName := HFileName;
    for i := 0 to TSL.Count-1 do begin
      currstr := TSL.Strings[i];
      pose := Pos('=',currstr);
      poss := Pos('/',currstr);
      if pose > 0 then begin
        sta := Copy(Currstr,poss+1,pose-poss-1);
        if TotalNames.IndexOf(STA) = -1 then
          TotalNames.Add(STA);
      end;
    end;
      except on EFOpenError do
    TSL.Free;
  end;
end;

procedure TGeoListView.WriteHotSpotToFile(FileName : String; Oldname, Newname : String);
var i : integer;
  currstr : AnsiString;
  pose, poss : integer;
  currhot : AnsiString;
  S : String;
begin



  for i := 0 to TSL.Count-1 do begin
    currstr := TSL.Strings[i];
    pose := Pos('=',currstr);
    poss := Pos('/',currstr);
    currhot := Copy(Currstr,poss+1,pose-poss-1);
    if currHot = OldName then begin
      TSL.Sorted := False;
      S := ReplaceStr(CurrStr,OldName,NewName);
      TSL.Strings[i] := S;
      TSL.Sorted := True;
      break;
    end;
  end;
  try
    TSL.SaveToFile(FileName);
  except on EFOpenError do
    //Log('Could not change hotspot file '+ PicturesDir+Filename);
  end;
end;


procedure TGeoListView.GeoChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if Change = ctState then begin
    if ListLoaded and CheckedItems then
      if Item.Checked then GeoController.Include(Item.Caption)
        else GeoController.Exclude(Item.Caption)
  end

end;




constructor TGeolistView.Create(Sender : TComponent);
begin
  inherited Create(Sender);
  TSL := TStringList.Create;
  TotalNAmes := TStringList.Create;
  ListLoaded := False;
  OnChange := GeoChange;
  ViewStyle := vsSmallIcon;
  //Checkboxes := True;

end;

procedure TGeoListView.Load(CurrNode : Boolean);
var j : integer;
  ListItem : TListItem;
  i : integer;
begin
  ListLoaded := false;
  Items.Clear;
  for j := 0 to TotalNames.COunt-1 do begin
    ListItem := Items.Add;
    ListItem.Caption := TotalNames.Strings[j];
    if CheckedITems then
      ListItem.Checked := (not GeoController.IsExcluded(TotalNames.Strings[j])) and currNode ;
  end;
  for i := 0 to Columns.Count-1 do
      Column[i].Width := 300;

  ListLoaded := true;
end;




procedure Register;
begin
  RegisterComponents('Geoclick', [TGeoListView]);
end;

end.
