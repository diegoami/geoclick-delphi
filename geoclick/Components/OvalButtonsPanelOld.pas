unit OvalButtonsPanelOld;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Hemibtn;
const
  MAXBUTTONS = 50;
type
  ENoValues = class(Exception);
  TOvalDirection = (OvalVertical, OvalHorizontal, OvalNone);
  TAllGuessed = procedure of Object;

  TOvalButtonsPanel = class(TPanel)
    procedure ButtonClick(Sender: TObject);
  private
    FAllGuessed : TAllGuessed;
    CurrentButton : THemisphereButton;
    FOValDirection : TOvalDirection;
    procedure SetNButtons(NB : integer);
    procedure SetFaceColor(BuColor : TColor);
  protected
    FButtonWidth : integer;
    FSelectColor, FDisableColor : TColor;
    FPossibleValuesList : TStrings;
    FNButtons : integer;
    FFaceColor : TColor;
    Buttons : array[1..MAXBUTTONS] of THemisphereButton;
    FValueList : TStrings;
    FDisappear : boolean;
    function Order(CurrBtn :  THemisphereButton) : integer;
    procedure SetValueList(VL : TStrings);
    procedure SetPossibleValuesList(VL : TStrings);
  public
    procedure Guessed;
    procedure GenerateTest(NQuestions : integer);
    procedure SetFont(FsFont : TFont);
    constructor Create(AOwner : TComponent); override;
    function GetCurrentString : String;
    function GetCurrOrdButton : integer;

    procedure Loaded; override;
    destructor Destroy; override;
    procedure Resize; override;
    procedure SelectFirst;
  published
    property ButtonWidth : integer read FButtonWidth write FButtonWidth;

    property OvalDirection : TOvaldirection read FOvalDirection write FOvalDirection;
    property SelectColor : TColor read FSelectColor write FSelectColor;
    property DisableColor : TColor read FDisableColor write FDisableColor;
    property NButtons : integer read FNButtons write SetNButtons;
    property PossibleValuesList : TStrings read FPossibleValuesList write SetPossibleValuesList;

    property ValueList : TStrings read FValueList write SetValueList;
    property FaceColor : TColor read FFaceColor write SetFaceColor;
    property OnAllGuessed : TAllGuessed read FAllGuessed write FAllGuessed;
    property Disappear : boolean read FDisappear write FDisappear;


  end;

procedure Register;

implementation

constructor TOvalButtonsPanel.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  fValueList := TStringList.Create;
  fPossibleValuesList := TStringList.Create;
  //OnResize := Resize;
  //OnResize(Self);
  Resize;
end;

destructor TOvalButtonsPanel.Destroy;
var i : integer;
begin
  fValueList.Free;
  fPossibleValuesList.Free;
  for i := 1 to NButtons do
    Buttons[i].Free;
  inherited;

end;


procedure TOvalButtonsPanel.ButtonClick(Sender: TObject);
begin
  if CurrentButton <> nil then
    CurrentButton.FaceColor := FFaceColor;
  CurrentButton := Sender As THemisphereButton;
  CurrentButton.FaceColor := FSelectColor;

end;

procedure TOvalButtonsPanel.SetNButtons(NB : integer);
var i : integer;
begin
  
  for i := 1 to NB do begin
    if Buttons[i] = nil then begin
      Buttons[i] := THemisphereButton.Create(Self);
      Buttons[i].FaceShaded := False;
      with Buttons[i] do begin
        Parent := Self;
        GroupIndex := 0;
        OnClick := ButtonClick;
      end;
    end;
    Buttons[i].FaceColor := FFaceColor;
    Buttons[i].Font := Font;
  end;
  FNButtons := NB;
  If NB >= 1 then
    ButtonClick(Buttons[1]);
end;

procedure  TOvalButtonsPanel.Resize;

procedure VerticalResize;
var xgrid, ygrid : integer;
    i,j  : integer;
begin
  xgrid := Width div 4;
  ygrid := Height div (4+(FNButtons-1)*3);
  j := 0;
  for i := 1 to FNButtons do if Buttons[i] <> nil then
    with Buttons[i] do begin
      inc(j);
      Left := Xgrid;
      Width := XGrid*2;
      Height := YGrid*2;
      Top := (1 + (j-1)*3)*YGrid;
    end;

end;


procedure HorizontalResize;
var xgrid, ygrid : integer;
    i,j  : integer;
begin
  ygrid := Height div 4;
  xgrid := ButtonWidth div 2;
  j := 0;
  for i := 1 to FNButtons do if Buttons[i] <> nil then {ci sono bottoni nil che non vengomo mostrati}
    with Buttons[i] do begin
      inc(j);
      Top := Ygrid;
      Width := XGrid*2;
      Height := YGrid*2;
      Left := (1 + (j-1)*3)*XGrid;
    end;
  Width := ButtonWidth*2*j;

end;

begin
  if OvalDirection = OvalVertical then
    VerticalResize
  else
    HorizontalResize;
end;

procedure TOvalButtonsPanel.SetFaceColor(BuColor : TColor);
var i : Integer;
begin
  for i := 1 to FNButtons do
    if (Buttons[i] <> nil) and (Buttons[i].Enabled) then
      Buttons[i].FaceColor := BuColor;
  FFaceColor := BuColor;
end;

procedure TOvalButtonsPanel.SetValueList(VL : TStrings);
var i : integer;
begin
  FValueList.Assign(VL);
  for i := 1 to FNButtons do begin
    Buttons[i].Caption := VL.Strings[i-1];
    Buttons[i].ShowHint := True;
    Buttons[i].Hint := VL.Strings[i-1];
  end;

end;


procedure TOvalButtonsPanel.SetPossibleValuesList(VL : TStrings);
var i : integer;
begin
  if VL <> nil  then begin
    FPossibleValuesList.Assign(VL);
  end;
end;

procedure TOvalButtonsPanel.Loaded;
var i : integer;
begin
  if (FValueList <> nil) and (FValueList.Count >= FNButtons ) then begin
    for i := 1 to FNButtons do begin
      Buttons[i].Caption := FValueList.Strings[i-1];
      Buttons[i].ShowHint := True;
      Buttons[i].Hint := FValueList.Strings[i-1];

      Buttons[i].FaceColor := FFaceColor;
      Buttons[i].Enabled := True;
      Buttons[i].Font := Font;
    end;
    CurrentButton := Buttons[1];
 //   ButtonClick(Buttons[1]);
    Resize;
  end;
end;

procedure TOvalButtonsPanel.SetFont(FsFont : TFont);
var i : Integer;
begin
  for i := 1 to FNButtons do
    Buttons[i].Font := fsFont;
end;


function TOvalButtonsPanel.GetCurrentString : String;
begin
  if CurrentButton = nil then
    result := ''
  else
    result := CurrentButton.Caption;
end;

function TOvalButtonsPanel.GetCurrOrdButton : integer;
begin
  result := Order(CurrentButton);
end;

function TOvalButtonsPanel.Order(CurrBtn :  THemisphereButton) : integer;
var curr : integer;
begin
  for curr := 1 to NButtons do
    if (Buttons[curr] <> nil) and (CurrBtn = Buttons[curr]) then begin
      result := curr;
      exit;
    end;
    result := 0;
end;


procedure TOvalButtonsPanel.Guessed;
var AllGuessed : Boolean;

  function GetNextEnabled(Curr : integer) : THemisphereButton;
  var cicl : integer;
  begin
    cicl := curr+1;
    if Cicl > NButtons then
        cicl := 1;
    while (curr <> cicl) and  ((Buttons[cicl] = nil) or (Buttons[cicl].Enabled = false) ) and (curr <> cicl)  do begin
      Inc(cicl);
      if Cicl > NButtons then
        cicl := 1;
    end;
    result := Buttons[cicl];
    if cicl = curr then
      Allguessed := true
    else
      Allguessed := False;

  end;

var NextButton : THemisphereButton;
  curr : integer;

begin
  if CurrentButton <> nil then begin
    curr := Order(CurrentButton);
    NextButton := GetNextEnabled(curr);
    CurrentButton.Enabled := False;
    if Disappear then begin
      CurrentButton.Free;
      Buttons[curr] := nil;

    end else

      CurrentButton.FaceColor := FDisableColor;
    if Allguessed then begin
      CurrentButton := nil;
      if Assigned(FAllGuessed) then
        FAllGuessed;
    end else begin
        NextButton.FAceColor := FSelectColor;
        CurrentButton := NextButton;
        Resize;
    end;
  end;
end;

procedure TOvalButtonsPanel.GenerateTest(NQuestions : integer);
var AlrGen, curr : integer;
  strpr : String;
  Added : boolean;
begin
  if (PossibleValuesList = nil) or (PossibleValuesList.Count < NQuestions ) then begin
    raise ENoValues.Create('No values to generate test');
    exit;
  end;
  Randomize;
  FValueList.Clear;
  for AlrGen := 1 to NQuestions do begin

    Added := False;
    repeat
      curr := Random(PossibleValuesList.Count);
      strpr := FPossibleValuesList[curr];
      if FValueList.IndexOf(strpr) = -1 then begin

        //FValueList.AddObject(strpr, FPossibleValuesList.Objects[curr]);
        FValueList.Add(strpr);
        Added := True;
      end;
    until Added;

  end;
  Loaded;
  ButtonClick(Buttons[1]);
  Buttons[1].FaceColor := FSelectColor;
  CurrentButton := Buttons[1];
end;

procedure TOvalButtonsPanel.SelectFirst;
begin
  Buttons[1].FaceColor := FSelectColor;
end;


procedure Register;
begin
  RegisterComponents('Additional', [TOvalButtonsPanel]);
end;

end.
