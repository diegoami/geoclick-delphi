{*******************************************************}
{                                                       }
{                    Input Form                         }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcinpfrm;

interface
{$I dc.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, dccommon, dcedit,dcsystem, dclib, dcconsts,consts;

type
  TInputLineForm = class(TForm)
    Panel1: TPanel;
    InputLabel: TLabel;
    PropEdit: TEdit;
    Panel2: TPanel;
    OkBut: TButton;
    CancelBut: TButton;
    HelpBut: TButton;
    procedure FormCreate(Sender: TObject);
    procedure OkButClick(Sender: TObject);
  end;

var
  InputLineForm: TInputLineForm;

function ReadInteger(Const FormCaption,InputCaption:String;HelpCtx:Integer;
           Var IntValue:Integer):boolean;
function CreateInputForm(const FormCaption,InputCaption:String;
           HelpCtx:Integer):TInputLineForm;

function ReadString(Const FormCaption,InputCaption:String;HelpCtx:Integer;
           Var StrValue:String):boolean;

function ReadScaleFactor(Var ScaleFactor:Extended):boolean;

implementation
{$R *.DFM}

function ReadScaleFactor(Var ScaleFactor:Extended):boolean;
begin
  ScaleFactor:=1;
  with CreateInputForm(SCapScale,SCapScalingFactor,0) do
  begin
    PropEdit.Text:='100'; //don't resource
    try
      Result:=ShowModal = idOK;
      if Result then
        ScaleFactor := StrtoInt(PropEdit.Text) / 100;
    finally
      Free;
    end;
  end;
end;

{---------------------------------------------------}

function CreateInputForm(const FormCaption,InputCaption:String;HelpCtx:Integer):TInputLineForm;
begin
  Result:=TInputLineForm.Create(Application);
  With Result do
  begin
    Caption:=FormCaption;
    InputLabel.Caption:=InputCaption;
    HelpContext:=HelpCtx;
  end;
end;

{---------------------------------------------------}

function ReadString(Const FormCaption,InputCaption:String;HelpCtx:Integer;
           Var StrValue:String):boolean;
begin
  With CreateInputForm(FormCaption,InputCaption,HelpCtx) do
  begin
    PropEdit.Text:=StrValue;
    Try
      Result:=ShowModal=mrOk;
      If Result then
        StrValue:=PropEdit.Text;
    finally
      Free;
    end;
  end;
end;

{---------------------------------------------------}

function ReadInteger(Const FormCaption,InputCaption:String;HelpCtx:Integer;
           Var IntValue:Integer):boolean;
begin
  With CreateInputForm(FormCaption,InputCaption,HelpCtx) do
  begin
    PropEdit.Text:=IntToStr(IntValue);
    Try
      Result:=ShowModal=mrOk;
      If Result then
        IntValue:=StrToInt(PropEdit.Text);
    finally
      Free;
    end;
  end;
end;

procedure TInputLineForm.FormCreate(Sender: TObject);
begin
  SetFormFont(self);
  Caption := SCapGotoLineNumber;
  InputLabel.Caption := SCapEnterNewLine;
  OkBut.Caption := ResStr(SOKButton);
  CancelBut.Caption := ResStr(SCancelButton);
  HelpBut.Caption := ResStr(SHelpButton);
end;

procedure TInputLineForm.OkButClick(Sender: TObject);
begin
  //
end;

end.
