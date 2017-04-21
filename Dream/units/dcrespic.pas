{*******************************************************}
{                                                       }
{  Unit with pictures for components                    }
{                                                       }
{  Copyright (c) 1998-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcrespic;

interface

{$I dc.inc}
{$I prod.inc}


implementation

{$IFDEF DREAMDESIGNER}
  {$R 'vclqrbmp.dcr'}
  {$R 'VCLDBBMP.DCR'}
  {$R 'vclstdbmp.DCR'}
  {$R 'vclsysbmp.dcr'}
  {$R 'vclwinbmp.dcr'}

  {$IFDEF D4}
    {$R 'vcl4bmp.dcr'}
  {$ENDIF}
{$ENDIF}

{$IFDEF DREAMLIB}
  {$R 'dcregbmp.dcr'}
  {$R 'dcfree.dcr'}
{$ENDIF}

{$IFDEF DREAMTREE}
  {$R dcinfotree.dcr}
{$ELSE}
  {$IFDEF DREAMINFOTREE}
    {$R dcinfotree.dcr}
  {$ENDIF}
{$ENDIF}
  
end.
