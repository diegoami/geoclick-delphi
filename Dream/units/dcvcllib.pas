{**************************************************}
{                                                  }
{              VCL Library functions               }
{                                                  }
{  Copyright (c) 1997-2000 Dream Company           }
{  http://www.dream-com.com                        }
{  e-mail: contact@dream-com.com                   }
{                                                  }
{**************************************************}
{ Search for:

  globproc  for section of global procedures and methods declaration
  globvar   for global variables declaration
  typedec   for types declaration
  _consts    for consts declaration
  msgconst  for message constants
}
unit dcVCLLib;

interface
{$I dc.inc}
uses
  classes,sysutils,windows,messages,typinfo,
  dsgnintf,
  dcconsts,dclib;

//=========================================================================
// typedec
// ------------------------ types declaration ------------------
type
  TLimitComponentProperty = class(TComponentProperty)
  private
    FProc : TGetStrProc;
    procedure AcceptProc(Const S: string);
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function AcceptComponent(AComponent : TComponent):boolean ;virtual;abstract;
  end;

{$IFDEF WIN}
  TDCVersionEditor = class(TStringProperty)
    function  GetAttributes: TPropertyAttributes; override;
    Function GetProductName:String;virtual;
    function  GetValue : string; override;
    procedure Edit; override;
  end;
{$ENDIF}

procedure Register;

implementation

{--------TLimitComponentProperty------------------------------------}

procedure TLimitComponentProperty.AcceptProc(const S: string);
var
  C: TComponent;
begin
  C := Designer.GetComponent(S);
  if Assigned(C) and  AcceptComponent(C) then
    FProc(S);
end;

{------------------------------------------------------------------}

procedure TLimitComponentProperty.GetValues(Proc: TGetStrProc);
begin
  FProc := Proc;
  inherited GetValues(AcceptProc);
end;


{$IFDEF WIN}
{-------TDCVersionEditor--------------------------------------------}

function TDCVersionEditor.GetAttributes: TPropertyAttributes;
begin
  result := inherited GetAttributes + [paReadOnly, paDialog];
end;

{-----------------------------------------------------------}

Function TDCVersionEditor.GetProductName:String;
Begin
  Result:='Dream Controls';
End;

{-----------------------------------------------------------}

function TDCVersionEditor.GetValue : string;
begin
  result := SDreamControlsVersion;
end;

{-----------------------------------------------------------}
//BeginSkipConst
procedure TDCVersionEditor.Edit;
var
  s : string;
begin
  s := GetProductName +' version '+ GetValue +
  #13#10#13#10'e-mail: contact@dream-com.com'#13#10+
  'WWW: http://www.dream-com.com'#13#10;
  MessageBox(0, pchar(s), pchar('About'), MB_ICONINFORMATION);
end;
//EndSkipConst
{$ENDIF}

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TDCVersion), nil, '' , TDCVersionEditor);
end;

end.

