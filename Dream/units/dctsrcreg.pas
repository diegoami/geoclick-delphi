{*******************************************************}
{                                                       }
{  Sources for TDCTree Registration                     }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcTSrcReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, dcgenreg, dctslite, dctsrc;

procedure Register;
begin
  RegisterComponents(SPalDreamTree,[TDCResViewSource,TDCMenuSource,TDCListViewSource,
                     TDCTreeViewSource,TDCCollectSource,TDCStringSource,TDCCompViewSource,
                     TDCFormSource,TDCStringSource,TDCImgListSource,TDCMultiSource]);
  RegisterPropertyEditor(TypeInfo(string),TDCCollectSource,'PropName',TCollPropName);
  RegisterPropertyEditor(TypeInfo(string),TDCStringSource,'PropName',TStringsPropName);
  RegisterPropertyEditor(TypeInfo(TPersistent),TDCCollectSource,'',TComponentProperty);
  RegisterPropertyEditor(TypeInfo(TPersistent),TDCStringSource,'',TComponentProperty);
  RegisterPropertyEditor(TypeInfo(string), TDCResViewSource, 'FileName', TFileNameEdit);
end;

end.