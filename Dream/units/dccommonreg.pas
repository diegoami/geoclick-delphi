{*******************************************************}
{                                                       }
{  Common Registration                                  }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dccommonreg;

interface
uses
  classes, dsgnintf, dccommon, dcsystem, dclib, dcconsts;

procedure Register;

type
  TKeyMappingEdit = class(TStringProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function  GetAttributes: TPropertyAttributes; override;
  end;

implementation

{******************************************************************}

procedure TKeyMappingEdit.GetValues(Proc: TGetStrProc);
var
  List : TList;
  i    : integer;
begin
  List := TList.Create;
  try
    GetRegisteredClasses(TObject,List);
    with List do
      for i:= 0 to Count - 1 do
        if TObjectParamListItem(Items[i]).Params[SParKeyboardID]=
          SParKeyboardID then
            Proc(TObjectParamListItem(Items[i]).Params[SParKeyboardInitName]);
  finally
    List.Free;
  end;
end;

{-------------------------------------------------------------}

function  TKeyMappingEdit.GetAttributes: TPropertyAttributes;
begin
  result := inherited GetAttributes;
  result := result + [paReadOnly,paValueList]-[paMultiSelect];
end;

{-------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents(SPalDream, [TVerbDispatcher]);
  RegisterPropertyEditor(TypeInfo(string),TDCCustomControl,'KeyMapping',TKeymappingEdit);//don't resource
end;

end.
