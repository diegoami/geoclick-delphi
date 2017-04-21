{****************************************************}
{                                                    }
{  Difference Maker registration unit                }
{                                                    }
{  Copyright (c) 1997-2000 Dream Company             }
{  http://www.dream-com.com                          }
{  e-mail: contact@dream-com.com                     }
{                                                    }
{****************************************************}

unit DiffMakeReg;

interface

procedure Register;

implementation
{$I dc.inc}
{$I prod.inc}
uses
  Classes,
  dsgnintf,
  dcgenreg,
  dcconsts, diffmake;

procedure Register;
begin
  RegisterComponents(SPalDream,[TDiffMaker]);
  RegisterPropertyEditor(TypeInfo(string), TDiffMaker, 'InFile', TFileNameEdit);
  RegisterPropertyEditor(TypeInfo(string), TDiffMaker, 'OutFile', TFileNameEdit);
  RegisterPropertyEditor(TypeInfo(string), TDiffMaker, 'UseFile', TFileNameEdit);
end;

end.