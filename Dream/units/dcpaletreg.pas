{*******************************************************}
{                                                       }
{  Form with component palette Registration             }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dcPaletReg;

interface
{$I dc.inc}
uses
  Classes, ComCtrls,
  dsgnintf,
  dcconsts, dcsystem, dcpalet;

type
  TPageControlEditor = class(TDefaultEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TActivePageProperty = class(TComponentProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

procedure Register;

implementation

type
  TMPageControl=class(TPageControl)
  end;

{$IFDEF D4}
TFormDesigner = IFormDesigner;
{$ENDIF}

procedure TPageControlEditor.ExecuteVerb(Index: Integer);
var
  PageControl: TPageControl;
  Page: TTabSheet;
  Designer: TFormDesigner;
begin
  if Component is TTabSheet then
    PageControl := TTabSheet(Component).PageControl
  else
    PageControl := TPageControl(Component);

  If (PageControl is TDCPageControl) and (Index=0) then
    exit;

  if PageControl <> nil then
  begin
    Designer := Self.Designer;
    if Index = 0 then
    begin
      Page := TTabSheet.Create(Designer.Form);
      try
        Page.Name := Designer.UniqueName(system.copy(TTabSheet.ClassName, 2, MaxInt));
        Page.Parent := PageControl;
        Page.PageControl := PageControl;
      except
        Page.Free;
        raise;
      end;
      PageControl.ActivePage := Page;
      Designer.SelectComponent(Page);
      Designer.Modified;
    end else
    begin
      Page := PageControl.FindNextPage(PageControl.ActivePage,
        Index = 1, False);
      if (Page <> nil) and (Page <> PageControl.ActivePage) then
      begin
        PageControl.ActivePage := Page;
        if Component is TTabSheet then Designer.SelectComponent(Page);
        Designer.Modified;
      end;
    end;
    TMPageControl(PageControl).Change;
  end;
end;

{------------------------------------------------------------------}

const
  PageControlVerbs : array[0 .. 2] of string =
    (SVerbNewPage, SVerbNextPage, SVerbPreviousPage);


function TPageControlEditor.GetVerb(Index: Integer): string;
begin
  result := PageControlVerbs[index];
end;

{------------------------------------------------------------------}

function TPageControlEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

{******************************************************************}

function TActivePageProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList];
end;

{------------------------------------------------------------------}

procedure TActivePageProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Component: TComponent;
begin
  for I := 0 to Designer.Form.ComponentCount - 1 do
  begin
    Component := Designer.Form.Components[I];
    if (Component.Name <> '') and (Component is TTabSheet) and
      (TTabSheet(Component).PageControl = GetComponent(0)) then
      Proc(Component.Name);
  end;
end;

{------------------------------------------------------------------}

procedure _InstantRegister;
begin
  RegisterPropertyEditor(TypeInfo(TTabSheet), TPageControl, 'ActivePage', TActivePageProperty); //don't resource
  RegisterComponentEditor(TPageControl, TPageControlEditor);
  RegisterComponentEditor(TTabSheet, TPageControlEditor);

end;

procedure _Register;
begin
  RegisterOptionExt(TPaletteOptions);
  RegisterOptionExt(TNewFormOptions);
end;

procedure RunRegister;
begin
  RegisterForInstant(_InstantRegister);
  RegisterForDelphi(_Register);
end;

procedure Register;
begin
  RegisterComponents(SPalDream,[TDCCompPalette, TNewFormPageControl]);
  RegisterComponentEditor(TDCCompPalette,TComponentEditor);
  RegisterComponentEditor(TNewFormPageControl,TComponentEditor);
  RegisterClass(TDCPaletteSheet);
end;

initialization
  RunRegister;
end.