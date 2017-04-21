{*******************************************************}
{                                                       }
{  Filter property editor Registration                  }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit FltrEdReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, dcedit, fltred;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(string), TDCFileNameEdit, 'Filter',
    TFilterPropertyEdit); //don't resource
end;

end.