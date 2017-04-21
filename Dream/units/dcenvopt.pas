{*******************************************************}
{                                                       }
{              Environment Options                      }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcenvopt;

interface

uses
  Messages, Forms, StdCtrls, Controls, ExtCtrls, Classes, ComCtrls;

const
  CM_PAGEUPDATED = WM_USER + 1;

type
  TEnvForm = class(TForm)
    PageProps: TPageControl;
    pnlButtons: TPanel;
    Panel2: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    HelpBut: TButton;
    procedure FormCreate(Sender: TObject);
  public
    procedure CMPAGEUPDATED(var Msg: TMessage); message CM_PAGEUPDATED;
  end;

var
  EnvForm: TEnvForm;

function ShowEnvOptions(OptForms: TList): Boolean;
procedure ShowEnvOptionsExcept(ExceptForms: TList);
procedure ShowEnvironmentOptions;
procedure FillPages(PageControl: TPageControl; Forms: TList);

implementation

uses Windows, dcStdCtl, dcSystem, dcCommon, dcLib, dcConsts;

{$R *.DFM}

procedure TEnvForm.CMPAGEUPDATED(var Msg: TMessage);
var
  page: TDCFormTabSheet;
  w: integer;
  h: integer;
begin
  page := TDCFormTabSheet(Msg.WParam);

  W := page.Form.Width + PageProps.Width - page.ClientWidth;
  H := page.Form.Height + PageProps.Height - page.ClientHeight;

  if ClientHeight < H + pnlButtons.Height then
    ClientHeight := H + pnlButtons.Height;
  if ClientWidth < W then
    ClientWidth := W;
end;

type
  TDCFormTabSheet2 = class(TDCFormTabSheet)
  protected
    procedure CreateHandle; override;
  public
    EnvFormClass: TCustomFormClass;

    destructor Destroy; override;
  end;

{------------------------------------------------------------------}

destructor TDCFormTabSheet2.Destroy;
begin
  Form.Free;
  Form := nil;
  inherited;
end;

procedure TDCFormTabSheet2.CreateHandle;
var
  msg: TMessage;
begin
  inherited;
  Form := EnvFormClass.Create(nil);
  msg.Msg := CM_PAGEUPDATED;
  msg.wParam := integer(self);
  GetParentForm(self).Dispatch(msg);
end;

{------------------------------------------------------------------}

function CreateFormTabSheet(PageControl: TPageControl): TDCFormTabSheet2;
begin
  result := TDCFormTabSheet2.Create(PageControl.Owner);
  try
    result.PageControl := PageControl;
  except
    result.Free;
    raise;
  end;
end;

{------------------------------------------------------------------}

procedure FillPages(PageControl: TPageControl; Forms: TList);
var
  i: integer;
begin
  for i := 0 to Forms.Count - 1 do
    with CreateFormTabSheet(PageControl) do
    begin
      EnvFormClass := Forms[i];
      Caption := GetOptionsFormCaption(TCustomFormClass(Forms[i]));
    end;
end;

{------------------------------------------------------------------}

function ShowEnvOptionsForm(Form: TCustomForm; PageProps: TPageControl;
  OptForms: TList): boolean;
var
  i: integer;
  M: TMessage;
  H, W: integer;
begin
  with TEnvForm(Form) do
  begin
    FillPages(PageProps, OptForms);
    with PageProps do
      if PageCount > 0 then
      begin
        W := TDCFormTabSheet(Pages[0]).Width + Width - Pages[0].ClientWidth;
        H := TDCFormTabSheet(Pages[0]).Height + Height - Pages[0].ClientHeight;

        ClientHeight := H + pnlButtons.Height; // added for bottom buttons
        ClientWidth := W;
      end;

    result := ShowModal = idOk;

    M.Msg := CM_CANCELOPTIONS;
    if result then
      M.Msg := CM_APPLYOPTIONS;

    with PageProps do
      for i := 0 to PageCount - 1 do
        if TDCFormTabSheet(Pages[i]).Form <> nil then
          TDCFormTabSheet(Pages[i]).Form.Dispatch(M);
  end;
end;

{------------------------------------------------------------------}

function ShowEnvOptions(OptForms: TList): boolean;
var
  optform: TEnvForm;
begin
  optform := TEnvForm.Create(nil);
  try
    result := ShowEnvOptionsForm(optform, optform.PageProps, OptForms);
  finally
    optform.Free;
  end;
end;

{------------------------------------------------------------------}

var
  EnvLock: Boolean = False;

procedure ShowEnvOptionsExcept(ExceptForms: TList);
var
  i: integer;
  forms: TList;
begin
  if EnvLock then
    exit;

  EnvLock := true;
  try
    forms := TList.Create;

    try
      with OptionFormClasses do
        for i := 0 to Count - 1 do
          if ExceptForms.IndexOf(Objects[i]) < 0 then
            forms.Add(Objects[i]);
      ShowEnvOptions(forms);
    finally
      forms.Free;
    end;
  finally
    EnvLock := false;
  end;
end;

{------------------------------------------------------------------}

procedure ShowEnvironmentOptions;
var
  i: integer;
  forms: TList;
begin
  if EnvLock then
    exit;

  EnvLock := true;
  try
    forms := TList.Create;

    try
      with OptionFormClasses do
        for i := 0 to Count - 1 do
          forms.Add(Objects[i]);
      //forms.Add(TCustomFormClass(Objects[i]).Create(nil));

      ShowEnvOptions(forms);
    finally
      {for i := 0 to forms.Count - 1 do
        TCustomForm(forms[i]).Free;}

      forms.Free;
    end;
  finally
    EnvLock := false;
  end;
end;

{------------------------------------------------------------------}

procedure TEnvForm.FormCreate(Sender: TObject);
begin
  Caption := SProperties;
  OkButton.Caption := SOkButton;
  CancelButton.Caption := SCancelButton;
  HelpBut.Caption := SHelpButton;
end;

initialization
  RegisterVerb('Tools.EnvironOptions', nil, ShowEnvironmentOptions); //don't resource
end.
