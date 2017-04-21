unit uOvalButtonsPanel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, stdctrls, OvalBtn;
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
    NotFirst : Boolean;
    //CurrenTOvalButton : TOvalButton;
     CurrenTOvalButton : TOvalButton;
    FOValDirection : TOvalDirection;
    ButtonToFree : TOvalButton;
    prevCurr : integer;
    procedure SetNButtons(NB : integer);
    procedure SetFaceColor(BuColor : TColor);
  protected
    FButtonWidth : integer;
    FSelectColor, FDisableColor : TColor;
    FPossibleValuesList : TStrings;
    FNButtons : integer;
    FFaceColor : TColor;
    Buttons : array[1..MAXBUTTONS] of TOvalButton;
    FValueList : TStrings;
    FDisappear : boolean;
    function Order(CurrBtn :  TOvalButton) : integer;
    procedure SetValueList(VL : TStrings);
    procedure SetPossibleValuesList(VL : TStrings);
    procedure SetButtonWidth(W : integer);

  public
    EndRush : Boolean;
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
    property ButtonWidth : integer read FButtonWidth write setButtonWidth;

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
  if CurrenTOvalButton <> nil then
    CurrenTOvalButton.Color := FFaceColor;
  CurrenTOvalButton := Sender As TOvalButton;
  CurrenTOvalButton.Color := FSelectColor;

end;

procedure TOvalButtonsPanel.SetNButtons(NB : integer);
var i : integer;
begin

   for i := 1 to MAXBUTTONS do
      if Buttons[i] <> nil then begin
        Buttons[i].Free;
        Buttons[i] := nil
      end;



  for i := 1 to NB do begin
    if Buttons[i] = nil then begin
      Buttons[i] := TOvalButton.Create(Self);
//      Buttons[i].Shape := shOval;

      with Buttons[i] do begin
        Parent := Self;
        //GroupIndex := 0;
        OnClick := ButtonClick;
      end;
    end;
    Buttons[i].Color := FFaceColor;
    Buttons[i].Font := Font;
  end;
  FNButtons := NB;
{  If NB >= 1 then
    ButtonClick(Buttons[1]);}
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
      Buttons[i].Color := BuColor;
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
      Buttons[i].Caption := Copy(FValueList.Strings[i-1],1,(ButtonWidth div Font.Size) +2);
      Buttons[i].ShowHint := True;
      Buttons[i].Hint := FValueList.Strings[i-1];

      Buttons[i].Color := FFaceColor;
      Buttons[i].Enabled := True;
      Buttons[i].Font := Font;
    end;
    CurrenTOvalButton := Buttons[1];
 //   ButtonClick(Buttons[1]);
    Resize;
  end;
end;

procedure TOvalButtonsPanel.SetFont(FsFont : TFont);
var i : Integer;
begin
  Font := FsFont;
  for i := 1 to FNButtons do if Buttons[i] <> nil then
    Buttons[i].Font := fsFont;
end;


function TOvalButtonsPanel.GetCurrentString : String;
begin
  if CurrenTOvalButton = nil then
    result := ''
  else
    result := CurrenTOvalButton.Hint;
end;

function TOvalButtonsPanel.GetCurrOrdButton : integer;
begin
  result := Order(CurrenTOvalButton);
end;

function TOvalButtonsPanel.Order(CurrBtn :  TOvalButton) : integer;
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

  function GetNextEnabled(Curr : integer) : TOvalButton;
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

var NexTOvalButton : TOvalButton;
  curr : integer;

begin
  if CurrenTOvalButton <> nil then begin
    curr := Order(CurrenTOvalButton);

    NexTOvalButton := GetNextEnabled(curr);
//    CurrenTOvalButton.Enabled := False;


    {if (EndRush) and  (notfirst) then begin

      if Buttons[PreVCurr] <> nil then

        Buttons[PrevCurr].Enabled := false;
      //Buttons[Prevcurr] := nil;
    end else }if EndRush then
      begin
        if Buttons[Curr] <> nil then

          Buttons[Curr].Enabled := false;

    end else begin
      Buttons[Curr].Free;
      Buttons[curr] := nil;

    end;

    PrevCurr := curr;
    if Allguessed then begin

      CurrenTOvalButton := nil;

      if Assigned(FAllGuessed) then
        FAllGuessed;
    end else begin
      NexTOvalButton.Color := FSelectColor;
      NextOvalButton.Repaint;
//      ButtonToFree := CurrentOvalButton;
      CurrenTOvalButton := NexTOvalButton;
      Resize;

    end;
  end;
end;

procedure TOvalButtonsPanel.SetButtonWidth(W : integer);
begin
  FButtonWidth := W;
  GenerateTest(FNButtons);
end;

procedure TOvalButtonsPanel.GenerateTest(NQuestions : integer);
var AlrGen, curr : integer;
  strpr : String;
  Added : boolean;
begin
  if FNBUttons < 1 then exit;
  FValueList.Clear;
  PrevCurr := 1;
  NotFirst := False;
  if (PossibleValuesList = nil) or (PossibleValuesList.Count < NQuestions ) then begin
    raise ENoValues.Create('No values to generate test');
    exit;
  end;
  Randomize;

  for AlrGen := 1 to NQuestions do begin

    Added := False;
    repeat
      curr := Random(PossibleValuesList.Count);
      strpr := FPossibleValuesList[curr];
      if FValueList.IndexOf(strpr) = -1 then begin

        //FValueList.AddObject(strpr, FPossibleValuesList.Objects[curr]);
        //FValueList.Add(strpr);
         FValueList.Add(strpr);
        Added := True;
      end;
    until Added;

  end;
  Loaded;
  ButtonClick(Buttons[1]);
  Buttons[1].Color := FSelectColor;
  CurrenTOvalButton := Buttons[1];
end;

procedure TOvalButtonsPanel.SelectFirst;
begin
  Buttons[1].Color := FSelectColor;
end;


procedure Register;
begin
  RegisterComponents('Additional', [TOvalButtonsPanel]);
end;

end.
