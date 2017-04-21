{*******************************************************}
{                                                       }
{  TDCCaptionButton Registration                        }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcCButReg;

interface
procedure Register;

implementation
{$I dc.inc}
uses
  Classes, Forms,
  dsgnintf,
  dcconsts, dccbut;

{$IFDEF D4}
Function GetComponentDesigner(AComponent:TComponent):IDesigner;
{$ELSE}
Function GetComponentDesigner(AComponent:TComponent):TDesigner;
{$ENDIF}
Begin
  Result:=Nil;
  While AComponent<>Nil Do
  Begin
    If AComponent Is TCustomForm Then
      Break;
    AComponent:=AComponent.Owner;
  End;

  If AComponent<>Nil then
    Result:=TCustomForm(AComponent).Designer;
End;

Procedure SelectComponentInDesigner(AComponent:TComponent);
Var
{$IFDEF D4}
  Designer:IDesignerNotify;
  DesignerIntf:IFormDesigner;
{$ELSE}
  Designer:TDesigner;
{$ENDIF}
begin
  If AComponent=Nil Then
    Exit;
  If Not (csDesigning In AComponent.ComponentState) Then
    Exit;
  Designer:=GetComponentDesigner(AComponent);
  If (Designer<>Nil) Then
  Begin
     {$IFDEF D4}
     Designer.QueryInterface(IFormDesigner,DesignerIntf);
     If DesignerIntf<>Nil Then
       DesignerIntf.SelectComponent(AComponent);
     {$ELSE}
     If (Designer Is TFormDesigner) Then
      (Designer As TFormDesigner).SelectComponent(AComponent);
     {$ENDIF}
  End;
end;

procedure Register;
begin
  RegisterComponents(SPalDream, [TDCCaptionButton]);
end;

Initialization
  SelectComponentInDesignerProc:=SelectComponentInDesigner;
end.