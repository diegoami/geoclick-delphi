{*******************************************************}
{                                                       }
{  TDCHistoryEditor Component                           }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit histed;

interface
{$I dc.inc}

uses
  windows, classes, sysutils, messages, controls, stdctrls, registry, dcsystem;

type
  TDCHistoryEditor = class(TComboBox)
  private
    FRegName: string;
    function GetRegName: string;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure DestroyWnd; override;
    procedure HistoryChanged; virtual;
    procedure KeyPress(var Key: Char); override;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure CMWANTSPECIALKEY(var Message : TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  public
    procedure SaveHistory; virtual;
    procedure LoadHistory; virtual;
    procedure EmptyHistory;
  published
    property Align;
    property RegName: string read FRegName write FRegName;
  end;

//const
  //SErrUnknRegType = 'This type isn''t supported by WriteToRegistry';

procedure Register;

implementation
{$R *.dcr}


{---------TDCHistoryEditor---------------------------------}

procedure TDCHistoryEditor.Loaded;
begin
  inherited;
  LoadHistory;

end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.CreateWnd;
begin
  inherited;
  LoadHistory;
//  Text := '';
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.DestroyWnd;
begin
  SaveHistory;
  inherited;
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.SaveHistory;
begin
  WriteToRegistry(GetRegName, Items.Text);
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.LoadHistory;
begin
  Items.Text := ReadFromRegistry(GetRegName, '');
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.EmptyHistory;
begin
  Items.Clear;
end;

{----------------------------------------------------------}

function TDCHistoryEditor.GetRegName: string;
begin
  result := FRegName;
  if result = '' then
  begin
    result := GetCompName(Self.Owner) + GetCompName(Self);
    if result = '' then
      result := 'Default';
  end;
  result := 'EditHistory\' + result;
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.HistoryChanged;
var
  Index: integer;
  s: string;
begin
  s := Text;
  with Items do
  begin
    Index := IndexOf(s);
    if Index >= 0 then
      Delete(Index);
    if s <> '' then
      Insert(0, s);
    Self.Text := s;
  end;
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.KeyPress(var Key: Char);
begin
  if Key = #13 then
  begin
    if DroppedDown then
      DroppedDown := false
    else
      HistoryChanged;
    Key := #0;
  end
  else
  if (Key = #27) and not DroppedDown then
    Key := #0;
  inherited;
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.CMExit(var Message: TCMExit);
begin
  HistoryChanged;
  inherited;
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.WMDestroy(var Message: TWMDestroy);
begin
  SaveHistory;
  inherited;
end;

{----------------------------------------------------------}

procedure TDCHistoryEditor.CMWANTSPECIALKEY(var Message : TCMWantSpecialKey);
begin
  if Message.CharCode = VK_RETURN then
    HistoryChanged;
  inherited;
end;

{----------------------------------------------------------}

procedure Register;
begin
  RegisterComponents('Dream Edit', [TDCHistoryEditor]);
end;

end.

