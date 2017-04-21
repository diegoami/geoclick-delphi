{*******************************************************}
{                                                       }
{  TreeView items property editor Registration          }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcTreeEdReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, dctreeed;

procedure Register;
begin
  RegisterComponents(SPalDreamTree, [TWindowList]);
end;

end.