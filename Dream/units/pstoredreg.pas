{*******************************************************}
{                                                       }
{  PropertyStore Component registration unit            }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}

unit PStorEdReg;

interface

procedure Register;

implementation
{$I dc.inc}
uses
  Classes,
  dsgnintf,
  dcconsts, dcCommon, dcstrled, pstored;

type
  TDCPropStoreEditor = class (TDefaultEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

{------------------------------------------------------------------}

function TDCPropStoreEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0:Result:=SVerbEditPropList;
    1:Result:=SVerbPropOrder;
  end;
end;

{------------------------------------------------------------------}

function TDCPropStoreEditor.GetVerbCount: Integer;
begin
  result := 2;
end;

{------------------------------------------------------------------}

procedure TDCPropStoreEditor.ExecuteVerb(index : integer);
begin
  if index = 0 then
    EditPropStore(Component as TDCPropStore)
  else
    EditStrings((Component as TDCPropStore).PropList, SCapEditing + Component.Name);
end;

{------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponentEditor(TDCPropStore, TDCPropStoreEditor);
end;

end.