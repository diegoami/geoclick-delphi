unit uGeoController;

interface

uses classes, graphics, sysutils, AmReg, utils, registry;

const
  ScoreIfCaught = 100;
type

  TDifficulty = (Easy, Medium, Hard);
  TButtonOptions = record
    Width : Integer;
    Font : TFont;
    SelColor, FaceColor : TColor;
  end;

  TInterfaceOptions = record
    NormalScroll : boolean;
    NormalZoom : boolean;
    MusicFileName : String;
    MusicOn : Boolean;
    SoundOn : Boolean;
  end;

  TGeoController = class(Tobject)
    private
      AllRs : TStrings;
      CheckedFiles : TStrings;
      CheckedDirs : TSTrings;
      FUSerName : String;
      procedure ReadButtonOptions;
      procedure ReadInterfaceOptions;
      procedure ReadDiffOptions;
    protected
      function GetUserName : String;
      procedure SetUserName(N : String);
    public

      Difficulty : TDifficulty;
      ButtonOptions : TButtonOptions;
      InterfaceOptions : TInterfaceOPtions;
      HsfFiles : TStrings;
      AllFiles : TStrings;
      AllDirs : TStrings;
      SDSTrings : TStrings;
      ExcludeNames : TStrings;
      qpl, spq : integer;
      ClearedMaps : boolean;
      property UserName : String read GetUserName write SetUserName;
      {procedure Guessed;
      procedure WrongGuess;
      procedure AllGuessed;}
      procedure PlaySound(Which : String);
      procedure SaveExclusions;
      function GetAllUsers : TStrings;
      procedure LoadExclusions;
      function CanStartGame : boolean;

      function GetCheckedDirs : TStrings;
      function isExcluded(S : String) : boolean;
      function GetCheckedFilesInDir(Dir : String) : TStrings;
      function GetAllFilesForDir(Dir : String) : TStrings;
      procedure WriteButtonOptions;
      procedure WriteDiffOptions;
      procedure WriteInterfaceOptions;

      procedure Exclude(S : String);
      procedure Include(S : String);
      function GetHsfFilesForDir(Dir : String) : TStrings;
      function GetHsfFilesForDirWithoutExt(Dir : String) : TStrings;
      function GetAllFilesForDirWithoutExt(Dir : String) : TStrings;

      constructor Create;
   end;

var GeoController : TGeoController;
  Rootname : String;
  Areg : TAMReg;

implementation

uses uOptionsForm, SdiMain, forms, uDebugForm, stringfns;

function TGeoController.GetUserName : string;
begin
  result := FUserName;
end;

function TGeoController.CanStartGame : boolean;
begin
  result := true;
  if HsfFiles.Count = 0 then
    result := false;
  
end;


function TGeoController.GetAllUsers : TStrings;
var i : integer;
  S : String;
begin
  AllRs.Clear;
  try
    with AREg do begin
      User := '';
      Active := True;

      GetAllKeys(AllRs);

      Active := False;
      User := FUserName;
    end;
  except on ERegistryException do
  end;
  i := 0;
  while i < AllRs.Count do begin
    S := AllRs.Strings[i];
    if (S = '1.0') or (S = 'ButtonOptions') or (S = 'InterfaceOptions') or (S = 'Forms') or (S = 'Difficulty') or (S = 'Scales' ) then
      AllRs.Delete(i)
    else
      inc(i);
  end;
  result := AllRs;
  //LogStrings(AllRs);
end;


procedure TGeoController.SetUserName(N : String);
begin
  if N = '' then N := 'default';

  FUSerName := N;

  AReg.User := '';
  with AReg do begin
    Active := True;
    WSString('','UserName',N);
    WSString(N,'(Standard)','');
    
    Active := False;
    AReg.USer := N;
  end;
  ReadButtonOptions;
  ReadInterfaceOptions;
  ReadDiffOptions;
  LoadExclusions;
end;

function TGeoController.IsExcluded(S : String) : boolean;
var b : boolean;
  i : integer;
begin
  i := ExcludeNames.IndexOf(S);
  b := i <> -1;
  result := b;
end;

function TGeoController.GetCheckedFilesInDir(Dir : String) : TStrings;
var i : integer;
  ind : integer;
begin
  CheckedFiles.Clear;
  for i := 0 to HSFFIles.COunt-1 do
    if ExtractFilePath(HSFFiles.Strings[i]) = Dir then
      CheckedFiles.Add(ExtractFileName(HSFFIles.Strings[i]));
  result := CheckedFiles;
end;

procedure TGeoController.ReadDiffOptions;
begin

  with AReg do begin
    Active := True;
    spq := RSInteger('Difficulty','SPQ',spq);
    qpl := RSInteger('Difficulty','QPL',qpl);
    ClearedMaps := RSBool('Difficulty','ClearedMaps',false);
    Active := False;
  end;

end;

procedure TGeoController.WriteDiffOptions;
begin
  with AReg do begin
    Active := True;
    WSInteger('Difficulty','SPQ',spq);
    WSInteger('Difficulty','QPL',qpl);
    WSBool('Difficulty','ClearedMaps',ClearedMaps);

    Active := False;
  end;
end;

procedure TGeoController.SaveExclusions;
begin
  try
    HSFFiles.SaveToFile(ExtractFilePath(Application.Exename)+FUserName+'.hsl');
    ExcludeNames.SaveToFile(ExtractFilePath(Application.Exename)+FUserName+'.exl');
  except on EFOpenError do end;
end;

procedure TGeoController.LoadExclusions;
begin
  try
    HSFFiles.LoadFromFile(ExtractFilePath(Application.Exename)+FUserName+'.hsl');
    ExcludeNames.LoadFromFile(ExtractFilePath(Application.Exename)+FUserName+'.exl');
  except on EFOpenError do if
    HSFFiles.Count = 0 then
      HSFFiles.Assign(AllFiles)
    else
      SaveExclusions;
  end;
end;


procedure TGeoController.ReadButtonOptions;

begin

  with ButtonOptions,AReg  do begin
      Active := True;

      Width := RSINteger('ButtonOptions','ButtonWidth',Width);
      SelColor := RSINteger('ButtonOptions','SelColor',SelColor);
      FaceColor := RSINteger('ButtonOptions','FaceColor',FaceColor);


      Font.Color := RSINteger('ButtonOptions','FontColor',Font.Color);
      Font.Size := RSINteger('ButtonOptions','FontSize',Font.Size);
      Font.Name := RSString('ButtonOptions','FontName',Font.Name);
      Font.Style := IntToFontStyle(RSInteger('ButtonOptions','FontStyle',FontStyleToInt(Font.Style)));
      
      Active := False;

  end;
end;

procedure TGeoController.WriteButtonOptions;
begin
  with ButtonOptions,AReg  do begin
    Active := TRue;
    WSINteger('ButtonOptions','SelColor',SelColor);
    WSINteger('ButtonOptions','ButtonWidth',Width);
    WSINteger('ButtonOptions','FaceColor',FaceColor);
    WSInteger('ButtonOptions','FontColor',Font.Color);
    WSINteger('ButtonOptions','FontSize',Font.Size);
    WSINteger('ButtonOptions','FontStyle',FontStyleToInt(Font.Style));

    WSString('ButtonOptions','FontName',Font.Name);
//    WSBinary('ButtonOptions', 'ButtonFont', Font);
    Active := False;
  end;
end;

procedure TGeoController.ReadInterfaceOptions;
var defFileName : String;
begin
    defFileName := ExtractFilePath(Application.Exename) +'Macaren2.mid';
    with InterfaceOptions, AReg do begin
      Active := True;
      NormalScroll := RSBool('InterfaceOptions','NormalScroll', NormalScroll);
      NormalZoom := RSBool('InterfaceOptions','NormalZoom', NormalZoom);
      MusicOn := RSBool('InterfaceOptions','MusicOn', MusicOn);
      SoundOn := RSBool('InterfaceOptions','SoundOn', SoundOn);
      MusicFileName := RSString('InterfaceOptions','MusicFileName',MusicFileName);
      Active := False;
    end;

end;

procedure TGeoController.WriteInterfaceOptions;
begin
  with InterfaceOptions, AReg do begin
    Active := True;
    WSBool('InterfaceOptions','NormalScroll',NormalScroll);
    WSBool('InterfaceOptions','NormalZoom', NormalZoom);
    WSBool('InterfaceOptions','MusicOn', MusicOn);
    WSBool('InterfaceOptions','SoundOn', SoundOn);
    WSString('InterfaceOptions','MusicFileName', MusicFileName);
    Active := False;
  end;
end;

procedure TGeoController.Exclude(S : String);
begin
  if ExcludeNames.Indexof(s) = -1 then
    ExcludeNames.Add(S);
end;

procedure TGeoController.Include(S : String);
begin
  if ExcludeNames.Indexof(s) <> -1 then
    ExcludeNames.Delete(ExcludeNames.IndexOf(S));
end;

constructor TGeoController.Create;
var defFilename : string;
begin
  inherited Create;
  CheckedFiles := TStringList.Create;
  ButtonOptions.Font := TFont.Create;
  with AReg do begin
    Active := True;
    FUserName := RSString('','UserName','default');
    Active := False;
    User := FUserName;
  end;
  HSfFiles := TStringList.Create;
  AllRs := TStringList.Create;
  CheckedDirs := TStringList.Create;
  ExcludeNames := TStringList.Create;
  SDStrings := TStringList.Create;
  AllFiles := TStringList.Create;
  AllDirs := TStringList.Create;
  with ButtonOptions do begin
      Font := TFont.Create;
      Width := 180;
      SelColor := clGreen;
      FaceColor := clYellow;
      Font.Color := clMaroon;
      Font.Size := 14;
      Font.Name := 'Arial';
  end;
  defFileName := ExtractFilePath(Application.Exename) +'Macaren2.mid';

  with InterfaceOptions do begin
      NormalScroll :=  False;
      NormalZoom := true;
      MusicOn := True;
      SoundOn := True;
      MusicFileName := defFileName;
  end;

  spq := 12;
  qpl := 8;


  ReadButtonOptions;
  ReadInterfaceOptions;
  ReadDiffOptions;
  LoadExclusions;
end;


function TGeoController.GetCheckedDirs : TStrings;
var i,j  : Integer;
  SD : String;
begin
  CheckedDirs.Clear;
  for i := 0 to HSFFiles.Count-1 do begin
    SD := ExtractFilePath(HSFFiles.Strings[i]);
    for J := 0 to AllDirs.Count-1 do
      if (Pos(AllDirs.Strings[j], SD) > 0) and (CheckedDirs.IndexOf(AllDirs.Strings[j]) = -1 )  then
        CheckedDirs.Add(AllDirs.Strings[j]);
  end;
  result := CheckedDirs;
end;


function TGeoController.GetAllFilesForDir(Dir : String) : TStrings;
var i : integer;
begin
  SDStrings.Clear;
  for i := 0 to AllFiles.COunt-1 do
    if ExtractFilePath(AllFiles.Strings[i])= Dir then
      SDStrings.Add(ExtractFileName(Allfiles.Strings[i]));
  result := SDStrings;
end;

function TGeoController.GetHsfFilesForDir(Dir : String) : TStrings;
var i : integer;
begin
  SDStrings.Clear;
  for i := 0 to HsfFiles.COunt-1 do
    if ExtractFilePath(HsfFiles.Strings[i])= Dir then
      SDStrings.Add(ExtractFileName(HSFfiles.Strings[i]));
  result := SDStrings;
end;

function TGeoController.GetHsfFilesForDirWithoutExt(Dir : String) : TStrings;

var i : integer;
  currhsffile : string;
begin
  SDStrings.Clear;
  for i := 0 to HsfFiles.COunt-1 do
    if ExtractFilePath(HsfFiles.Strings[i])= Dir then begin
      currhsffile := ExtractFileName(HSFfiles.Strings[i]);
      SDStrings.Add(Copy(Currhsffile,1,length(currhsffile)-4));
    end;
  result := SDStrings;
end;

procedure TGeoController.PlaySound(Which : String);
var GuessedFile : String;
begin
  try
    if InterfaceOptions.SoundOn then begin
      GuessedFile := ExtractFilePath(Application.ExeName)+'Sounds\'+Which+'.wav';
      PlayWav(GuessedFile);
    end;
  except on EFOpenError do end;
end;

{
procedure TGeoController.Guessed;
var GuessedFile : String;
begin
  if InterfaceOptions.SoundOn then begin
    GuessedFile := ExtractFilePath(Application.ExeName)+'Sounds\Whistle.wav';
    PlayWav(GuessedFile);
  end;
end;

procedure TGeoController.AllGuessed;
var GuessedFile : String;
begin
  if InterfaceOptions.SoundOn then begin
    GuessedFile := ExtractFilePath(Application.ExeName)+'Sounds\Applaude.wav';
    PlayWav(GuessedFile);
  end;
end;

procedure TGeoController.TimeOver;
var GuessedFile : String;
begin
  if InterfaceOptions.SoundOn then begin
    GuessedFile := ExtractFilePath(Application.ExeName)+'Sounds\Applaude.wav';
    PlayWav(GuessedFile);
  end;
end;

procedure TGeoController.WrongGuess;
var GuessedFile : String;
begin
  if InterfaceOptions.SoundOn then begin
    GuessedFile := ExtractFilePath(Application.ExeName)+'Sounds\Cough2.wav';
    PlayWav(GuessedFile);
  end;
end;
}

function TGeoController.GetAllFilesForDirWithoutExt(Dir : String) : TStrings;

var i : integer;
  currhsffile : string;
begin
  SDStrings.Clear;
  for i := 0 to AllFiles.COunt-1 do
    if ExtractFilePath(AllFiles.Strings[i])= Dir then begin
      currhsffile := ExtractFileName(Allfiles.Strings[i]);
      SDStrings.Add(Copy(Currhsffile,1,length(currhsffile)-4));
    end;
  result := SDStrings;
end;

initialization
  AReg := TAmReg.Create(nil);
  with AReg do begin
    Rootkey := HKeyLocalMachine;
    Group := 'Software';
    Company := 'Click It';
    Application := 'Geoclick';
    Reg := TRegistry.Create;
  end;
  GeoController := TGeoController.Create;

end.
