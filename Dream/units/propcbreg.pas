{*******************************************************}
{                                                       }
{  TDCPropCheck Registration Unit                       }
{                                                       }
{  Copyright (c) 1999-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit PropCBReg;

interface
{$I dc.inc}
uses Classes, DsgnIntf;

type
  {$IFDEF D3}
  TCompEditor = class(TComponentProperty)
    procedure GetValues(Proc: TGetStrProc); override;
  end;
  {$ENDIF}

  TPropNameEditor = class(TStringProperty)
  private
    FProc: TGetStrProc;
    procedure PropNameProc(Prop: TPropertyEditor);
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

procedure Register;

implementation
{$R *.dcr}

uses
  TypInfo, SysUtils, Forms, PropCB, dcConsts {$IFDEF D5}, Contnrs{$ENDIF};

procedure Register;
begin
  RegisterComponents(SPalDreamEdit, [TDCPropCheck]);
  {$IFDEF D3}
  RegisterPropertyEditor(TypeInfo(TPersistent), TDCPropCheck, 'Component',
    TCompEditor);
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(string), TDCPropCheck, 'PropName',
    TPropNameEditor);
end;

{$IFDEF D3}
{*** TCompEditor *********************************************}

procedure TCompEditor.GetValues(Proc: TGetStrProc);
begin
  Proc(TComponent(GetComponent(0)).Owner.Name);
  inherited GetValues(Proc);
end;
{$ENDIF}

{*** TPropNameEditor *********************************************}

function TPropNameEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paRevertable];
end;

procedure TPropNameEditor.GetValues(Proc: TGetStrProc);
var
  CList: {$IFDEF D5}TDesignerSelectionList{$ELSE}TComponentList{$ENDIF};
  Comp: TPersistent;
begin
  Comp := (GetComponent(0) as TDCPropCheck).Component;
  if Comp <> nil then
  begin
    CList := {$IFDEF D5}TDesignerSelectionList{$ELSE}TComponentList{$ENDIF}.Create;
    try
      CList.Add(TComponent(Comp));
      FProc := Proc;
      GetComponentProperties(CList, tkProperties, Designer, PropNameProc);
    finally
      CList.Free;
    end;
  end;
end;

procedure TPropNameEditor.PropNameProc(Prop: TPropertyEditor);
begin
  if Assigned(FProc) and (CompareText(Prop.GetPropType.Name, 'Boolean') = 0) then
    FProc(Prop.GetName); //add only Boolean properties
  Prop.Free;
end;

end.
