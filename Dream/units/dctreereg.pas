{*******************************************************}
{                                                       }
{  TreeView & ListView Registration                     }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcTreeReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, dctree;

procedure Register;
begin
  RegisterComponents(SPalDreamTree,[TDCTreeView,TDCListView]);
end;

end.