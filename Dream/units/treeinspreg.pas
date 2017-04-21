{*******************************************************}
{                                                       }
{  TreeInspector Form Registration                      }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit TreeInspReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, treeinsp {$IFNDEF D3}, dcsystem, dcmenu, dctsrc{$ENDIF};

procedure Register;
begin
{$IFNDEF D3}
  if UnderDelphiIDE then
  begin
    RegisterPropertyEditor(TypeInfo(TCollection),TDCMenu,'',TModalCollectEdit);
    RegisterPropertyEditor(TypeInfo(TDCNamedItems),TPersistent,'',TModalCollectEdit);
    RegisterPropertyEditor(TypeInfo(TCollection),TDCMultiSource,'',TModalCollectEdit);
  end;
{$ENDIF}
end;

end.