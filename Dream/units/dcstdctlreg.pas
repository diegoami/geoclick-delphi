{*********************************************************}
{                                                         }
{  "Dream Controls" standard components registration unit }
{                                                         }
{  Copyright (c) 1997-2000 Dream Company                  }
{  http://www.dream-com.com                               }
{  e-mail: contact@dream-com.com                          }
{                                                         }
{*********************************************************}

unit dcStdCtlReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, dcstdctl, dccontrols, dcGen;

procedure Register;
begin
  RegisterVisualProperty(SVerbItemsEditor,TDCCheckListBox,'Items'); //don't resource

end;

end.