{*******************************************************}
{                                                       }
{  TDCAVIPlay registration unit                         }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}

unit AviPlayReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,  dcconsts, AviPlay,dcGenReg;

type
  { Property editor for filename property with AVI extension}
  TAVIFileNameEdit = class(TFileNameEdit)
    function  GetDefaultExtension : string; override;
    function  GetFilter : string; override;
  end;

function  TAVIFileNameEdit.GetDefaultExtension : string;
begin
  result := 'avi'; //don't resource
end;

{------------------------------------------------------------------}

function  TAVIFileNameEdit.GetFilter : string;
begin
  result := SAVIFilesFilter;
end;

{------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents(SPalDream,[TDCAVIPlay]);
  RegisterPropertyEditor(TypeInfo(string), TDCAVIPlay, 'FileName', TAVIFileNameEdit);//don't resource
end;

end.