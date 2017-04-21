{*******************************************************}
{                                                       }
{  TreeViewSource for ActionList Registration           }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcActLstReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, dcgen, dcactlst{$IFDEF D4},actnlist{$ENDIF};

procedure Register;
begin
  RegisterDefaultTreeSource(TActionList,TDCActionListSource,'Actions');
end;

end.