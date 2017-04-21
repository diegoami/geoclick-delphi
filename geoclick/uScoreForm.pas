unit uScoreForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls;

type
  TScoreForm = class(TForm)
    ListView1: TListView;
    OkButton: TButton;
    BestLabel: TLabel;
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure OkButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  protected
    procedure Load;

  public
    MaxEntries : integer;
    procedure Save;
    procedure AddScore(USer : String; Score : integer);
  end;

var
  ScoreForm: TScoreForm;

implementation

{$R *.DFM}

procedure TScoreForm.ListView1Compare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if StrToInt(Item1.SubItems.Strings[0]) < StrToInt(Item2.SubItems.Strings[0])
    then Compare := +1
  else if StrToInt(Item1.SubItems.Strings[0]) = StrToInt(Item2.SubItems.Strings[0])
    then Compare := 0
  else Compare := -1;
end;

procedure TScoreForm.AddScore(USer : String; Score : integer);
var Item : TListItem;
begin
  if Score <= 0 then exit;
  Item := ListView1.Items.Add;
  Item.Caption := User;
  Item.SubItems.Add(InTToStr(Score));
  Listview1.AlphaSort;
  if ListView1.Items.Count > MaxEntries then
    ListView1.Items.Delete(ListView1.Items.COunt-1);
end;

procedure TScoreForm.Save;
var TS : TStrings;
  i : integer;
  LI : TListItem;
begin
  TS := TStringList.Create;
  for i := 0 to ListView1.Items.Count-1 do begin
    LI := ListView1.Items[i];
    TS.Add(LI.Caption+'='+LI.Subitems.Strings[0]);
  end;

  TS.SaveToFile(ExtractFilePath(Application.Exename)+'score.dat');
end;

procedure TScoreForm.Load;
var TS : TStrings;
  i : integer;
  LI : TListItem;
  Pose : integer;
begin
  TS := TStringList.Create;
  try
    TS.LoadFromFile(ExtractFilePath(Application.Exename)+'score.dat');
    for i := 0 to TS.Count-1 do begin
      LI := ListView1.Items.Add;
      Pose := Pos('=',TS.Strings[i]);
      LI.Caption := Copy(TS.Strings[i],1,pose-1);
      LI.Subitems.Add(Copy(TS.Strings[i],pose+1,Length(TS.STrings[i])-pose));
    end;
  except on EFOpenError do end;
end;

procedure TScoreForm.OkButtonClick(Sender: TObject);
begin
  Save;
  Close;
end;

procedure TScoreForm.FormCreate(Sender: TObject);
begin
  MaxEntries := 30;
  Load;
end;

procedure TScoreForm.FormShow(Sender: TObject);
begin
  ListView1.AlphaSort;
end;

end.
