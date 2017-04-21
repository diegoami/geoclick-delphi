{********************************************************}
{                                                        }
{  Project Manager and tree extensions registration unit }
{                                                        }
{  Copyright (c) 1997-2000 Dream Company                 }
{  http://www.dream-com.com                              }
{  e-mail: contact@dream-com.com                         }
{                                                        }
{********************************************************}

unit dcPManReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, dcpman;

procedure Register;
begin
  RegisterComponents(SPalDreamTree,[TDCProjectSource]);
end;

end.