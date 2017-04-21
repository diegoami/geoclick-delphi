unit uGeoGame;

interface


uses uGeoController, forms, sysutils, mplayer;
type


  TGeogame = class(TObject)
    level : integer;
    Difficulty : TDifficulty;
    Score : integer;
    ScoreModifier : real;
    ParForm : TForm;
    constructor Create(Form : TForm; DIff : TDifficulty);
    procedure AddScore(ScoreRel : real);
    procedure AddEndScore(ScoreRel : real);
    procedure GameOver;
    procedure StartLevel;
    procedure NextLevel;

  end;


var  CurrGame : TGeoGame;
implementation


uses uListBrowseMaps, uBrowseMaps;

constructor TGeoGame.Create(Form : TForm; DIff : TDifficulty);
begin
  ParForm := Form;
  Difficulty := Diff;
  ScoreModifier := 1;
  Level :=0;
  Score := 0;

end;

procedure TGeoGame.AddScore(ScoreRel : real);
var STA : real;
begin
  STA := ScoreRel*ScoreModifier;
  if not GeoController.ClearedMaps then
    STA := STA/10;
  Inc(Score,Round(STA));
end;


procedure TGeoGame.AddEndScore(ScoreRel : real);
var STA : integer;
begin
  with GeoController do
    STA := Round(ScoreRel-(qpl-1)*(spq-3));
  if STA > 0 then
    Inc(Score,STA);
end;

procedure TGeoGame.NextLevel;

begin
  Inc(Level);
  (ParForm As TBrowseMaps).ShowLevel(Level,Score);
  (ParForm As TListBrowseMaps).Wait;
  try
    with (ParForm As TBrowseMaps) do
      if GeoController.InterfaceOptions.MusicOn and ((Level = 1) or (MediaPlayer1.Position >= MediaPlayer1.Length)) then begin

        MediaPlayer1.FileName := Geocontroller.InterfaceOptions.MusicFileName;
        MediaPlayer1.Open;
        MediaPlayer1.Position := 0;
        MediaPlayer1.Start;
        MediaPlayer1.Play;
      end;
  except on EMCIDeviceError do end;
 
end;

procedure TGeoGame.StartLevel;
begin
  (ParForm As TListBrowseMaps).LoadQuiz(GeoController.qpl,GeoController.qpl*GeoController.spq-(Geocontroller.spq div 2));
end;

procedure TGeoGame.GameOver;
begin
  (ParForm As TListBrowseMaps).GameOver;
  if GeoController.InterfaceOptions.MusicOn then
    with (ParForm As TBrowseMaps) do begin
      try

        MediaPlayer1.Stop;
      except on EMCIDeviceError do end;
    end;

   inherited;
end;


end.
