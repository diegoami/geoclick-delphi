{*******************************************************}
{                                                       }
{  Menu Enhancer registration unit                      }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}

unit dcMenuReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  SysUtils, dcconsts, dcmenu;

type  
  TPropEditCompEditor = class(TComponentProperty)
  private
    fProc : TGetStrProc;
    procedure getProc(const s : string);
  public
    procedure GetValues(Proc : TGetStrProc); override;
  end;

procedure TPropEditCompEditor.getProc(const s : string);
var
  i    : integer;
  info : TItemInfo;
begin
  info := TItemInfo(GetComponent(0));
  with info, Collection do
    for i := 0 to Count - 1 do
      if Assigned(TItemInfo(Items[i]).MenuItem) and
         (CompareText(s, TItemInfo(Items[i]).MenuItem.Name) = 0) then
        exit;

  fProc(s);
end;

{------------------------------------------------------------------}

procedure TPropEditCompEditor.GetValues(Proc : TGetStrProc);
begin
  fProc := Proc;
  inherited GetValues(getProc);
end;

{------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents(SPalDream,[TDCMenu]);
  RegisterPropertyEditor(TypeInfo(TComponent), TItemInfo, 'MenuItems', TPropEditCompEditor); //don't resource
end;

end.