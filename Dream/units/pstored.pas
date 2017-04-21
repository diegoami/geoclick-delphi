{*******************************************************}
{                                                       }
{  PropertyStore Component                              }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit pstored;

interface

{$I dc.inc}
uses
  dcsystem, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, DcTree, dctsrc, ComCtrls, typinfo, dcgen, dccommon, StdCtrls,
  ExtCtrls, dclib, dcstdctl, dcconsts, consts, treemod
  {$IFDEF D3}, checklst, dctslite, dcdtree{$ENDIF} {$IFDEF D4}, dcactlst{$ENDIF}
  ,dsgnintf;

type
  TPropertySelect = class(TForm)
    DCTreeView1: TDCTreeView;
    CompSource: TDCCompViewSource;
    DCCheckListBox1: TDCCheckListBox;
    Panel1: TPanel;
    OkBut: TButton;
    CancelBut: TButton;
    SelectAll: TButton;
    UnSelectAll: TButton;
    DCSplitter1: TDCSplitter;
    procedure DCTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure DCCheckListBox1ClickCheck(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure UnSelectAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fOwner : TComponent;
    procedure SetOwnerComp(val : TComponent);
    procedure IterateProp(Instance:TPersistent;PropInfo:PPropInfo;UserData:Integer);
    procedure FillChecks;
    function  GetCurrentPrefix : string;
  public
    Info : TStrings;
    property OwnerComp : TComponent read fOwner write SetOwnerComp;
  end;

var
  PropertySelect: TPropertySelect;

procedure EditPropStore(PropStore : TDCPropStore);

implementation

{$R *.DFM}

procedure EditPropStore(PropStore : TDCPropStore);
var
  slist : TStringList;
  d     : TFormDesigner;
begin
  slist := TStringList.Create;
  with TPropertySelect.Create(nil) do
    try
      slist.Assign(PropStore.PropList);
      Info := slist;
      OwnerComp := PropStore.Owner;
      Caption := SCapEditing + PropStore.Name;
      if ShowModal = idOk then
        begin
          PropStore.PropList.Assign(slist);
          d := GetDesigner(PropStore);
          if d <> nil then
            d.Modified;
        end;
    finally
      Free;
      slist.Free;
    end;
end;

{******************************************************************}

procedure TPropertySelect.SetOwnerComp(val : TComponent);
begin
  fOwner := val;
  CompSource.Root := val;
end;

{------------------------------------------------------------------}

procedure TPropertySelect.IterateProp(Instance:TPersistent;PropInfo:PPropInfo;UserData:Integer);
begin
  DCCheckListBox1.Items.Add(PropInfo.Name);
end;

{------------------------------------------------------------------}

function TPropertySelect.GetCurrentPrefix : string;
var
  c : TComponent;
begin
  c := TComponent(DCTreeView1.InspectorControl);
  if c = OwnerComp then
    result := ''
  else
    result := c.Name + '.';
end;

{------------------------------------------------------------------}

procedure TPropertySelect.FillChecks;
var
  i : integer;
  prefix : string;
begin
  prefix := GetCurrentPrefix;
  with DCCheckListBox1,Items do
    for i := 0 to Count - 1 do
      Checked[i] := info.IndexOf(prefix + Strings[i]) >= 0;
end;

{------------------------------------------------------------------}

procedure TPropertySelect.DCTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  if DCTreeView1.InspectorControl = nil then
    exit;

  with DCCheckListBox1.Items do
    begin
      BeginUpdate;
      try
        Clear;
        IterateProps(DCTreeView1.InspectorControl,tkAny - tkMethods,
                     IterateProp, true,0);
        FillChecks;
      finally
        EndUpdate;
      end;
    end;
end;

{------------------------------------------------------------------}

procedure TPropertySelect.DCCheckListBox1ClickCheck(Sender: TObject);
var
  s : string;
  i : integer;
begin
  with DCCheckListBox1, Items do
    begin
      if ItemIndex < 0 then
        exit;
      s := GetCurrentPrefix + Strings[ItemIndex];
      i := Info.IndexOf(s);
      if Checked[ItemIndex] then
        begin
          if i < 0 then
            Info.Add(s);
        end
      else
        Info.Delete(i);
    end;
end;

{------------------------------------------------------------------}

procedure TPropertySelect.SelectAllClick(Sender: TObject);
var
  s : string;
  i : integer;
begin
  with DCCheckListBox1, Items do
    for i := 0 to Count - 1 do
      begin
        s := GetCurrentPrefix + Strings[i];
        if Info.IndexOf(s) < 0 then
          Info.Add(s);
        Checked[i] := true;
      end;
end;

{------------------------------------------------------------------}

procedure TPropertySelect.UnSelectAllClick(Sender: TObject);
var
  s   : string;
  i   : integer;
  idx : integer;
begin
  with DCCheckListBox1, Items do
    for i := 0 to Count - 1 do
      begin
        s := GetCurrentPrefix + Strings[i];
        idx := Info.IndexOf(s);
        if idx >= 0 then
          Info.Delete(idx);
        Checked[i] := false;
      end;
end;

{------------------------------------------------------------------}

procedure TPropertySelect.FormCreate(Sender: TObject);
begin
  SetFormFont(self);
  Caption := SPstoredEdit;
  SelectAll.Caption := SSelectAll;
  UnSelectAll.Caption := SUnSelectAll;
  OkBut.Caption := ResStr(SOKButton);
  CancelBut.Caption := ResStr(SCancelButton);
end;

{------------------------------------------------------------------}

procedure RunRegister;
begin

end;

{------------------------------------------------------------------}

initialization
  RunRegister;
end.
