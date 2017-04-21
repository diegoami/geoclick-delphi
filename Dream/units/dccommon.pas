{**************************************************}
{                                                  }
{              Common functions                    }
{                                                  }
{  Copyright (c) 1997-2000 Dream Company           }
{  http://www.dream-com.com                        }
{  e-mail: contact@dream-com.com                   }
{                                                  }
{**************************************************}

unit dccommon;

interface
{$I dc.inc}
uses
  {$IFDEF D3}ActiveX{$ELSE}Ole2{$ENDIF}, windows, messages, classes, sysutils,
  {$IFDEF WIN}graphics, forms, controls,{$ENDIF}

  consts, typinfo,
  shellapi, menus, StdCtrls, buttons, comctrls, dcsystem, dclib, dcconsts,
  commctrl,
  {$IFDEF D4}ActnList,imglist, {$ENDIF}
{$IFNDEF SHELLOBJ}
  filectrl,
{$ENDIF}
  dcapi;

type
  TProcessChangesProc = procedure(Sender : TObject; var processed : boolean) of object;

{$IFDEF WIN}
type
  TDCCustomControl = class(TCustomControl)
  private
    FWantTabs:boolean;
    FWantReturns:boolean;
    FKeyboardInit : TKeyboardInitProc;
    FKeyMapping:String;
    FKeyState:Integer;
    FKeys:TKeyList;
    procedure SetKeyMapping(const V:String);
  protected
    procedure UpdateKeyMapping; virtual;
    procedure InitDefaultKeyMapping;virtual;abstract;
    procedure KeyDown(var Key: Word; Shift: TShiftState);override;
    procedure CNKeyDown(var Message: TWMKeyDown);message CN_KeyDown;
    procedure KeyPress(var Key: Char);override;
    procedure ClearKeys;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CNSysKeyDown(var Message: TWMKeyDown);message CN_SysKeyDown;
//    procedure CMChildKey(var Message: TCMChildKey); message CM_ChildKey;
    function InsertChar(Ch : Char):Boolean; virtual;
  public
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
    property Keys:TKeyList Read FKeys;
    property KeyState:Integer Read FKeyState Write FKeyState;
    property KeyMapping:String Read FKeyMapping Write SetKeyMapping;
    property WantReturns:boolean Read FWantReturns Write FWantReturns Default True;
    property WantTabs:boolean Read FWantTabs Write FWantTabs Default False;
  published
  end;

  THandleObject = class(TObject)
  private
    FWnd : HWnd;
  public
    constructor Create(WndProc: TWndMethod);
    destructor Destroy; override;
    property Handle : HWnd  read FWnd;
  end;
{$ENDIF WIN}
{$IFNDEF D3}
  TCustomForm=TForm;
{$ENDIF}

{$IFDEF WIN}
  TCustomFormClass = class of TCustomForm;
  TDataModuleClass = class of TDataModule;

  TDCHandleObject = class(THandleObject)
  private
    fObject : TObject;
    procedure WndProc(var Msg: TMessage);
  public
    constructor Create(AObject : TObject);
    procedure   PostMsg(Msg, wParam, lParam : integer);
  end;

  TPropStream = class(TMemoryStream)
  private
    FMode:Integer;
    FInstance:TPersistent;
    FPropName:String;
    FPropInfo:PPropInfo;
    FStrings:TStrings;
    FVersion : TDCVersion;
    function GetPropValue:String;
    procedure SetPropValue(const S:String);
    procedure UpdatePropInfo;
    procedure BadPropInfo;
  public
    constructor Create(Instance:TPersistent;const PropName:String;Mode:Integer);
    destructor Destroy;override;
  published
    property Version : TDCVersion read FVersion write FVersion stored false;
  end;

  TPropFileSystem = class(TFileSystem)
  private
    FPropName:String;
    FComponent:TComponent;
    procedure SetComponent(val : TComponent);
    procedure SetComponentPtr(const val : string);
    function  GetComponentPtr : string;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    function FileExists(const FileName: TFileName): Boolean;override;
    function GetFileStream(const FileName: TFileName; Mode: Integer): TStream;override;
    function GetFileSystemLevel:TFileSystemLevel;override;
    property Component : TComponent read fComponent write SetComponent;    
  published
    property ComponentPtr : string read GetComponentPtr write SetComponentPtr;
    property PropName:String Read FPropName Write FPropName;
  end;

  TVerbListItem = class;

  TAssignVerbProc = procedure(Comp:TComponent;VerbItem:TVerbListItem);

  TVerbListItem=class(TDCNamedItem)
  private
    FClearHandler:boolean;
    FAssignProc:TAssignVerbProc;
    FVerbStates:TVerbStates;
    FVerbName:String;
    FVerbComp:TComponent;
    FVerbGetState:TGetVerbStateProc;
    FVerbExecute:TExecuteVerbProc;
    FDesignGroup:Integer;
    function OwnerObject:TComponent;
    procedure SetVerbName(const Value:String);
    procedure SetVerbComp(Value:TComponent);
    procedure UpdateVerbObject;
  protected
  {$IFDEF D3}
    function GetDisplayName: string;override;
  {$ENDIF}
  public
    procedure UpdateControl;
    procedure VerbOnClick(Sender:TObject);
    destructor Destroy;override;
    property VerbStates:TVerbStates Read FVerbStates;
    property VerbGetState:TGetVerbStateProc Read FVerbGetState;
    property VerbExecute:TExecuteVerbProc Read FVerbExecute;
    property ClearHandler:boolean Read FClearHandler;
  published
    property VerbComp:TComponent Read FVerbComp Write SetVerbComp;
    property VerbName:String Read FVerbName Write SetVerbName;
  end;

  TVerbList=class(TDCNamedItems)
  private
    function GetItem(Index:Integer):TVerbListItem;
    procedure SetItem(Index:Integer;V:TVerbListItem);
  public
    property Items[Index:Integer]:TVerbListItem Read GetItem Write SetItem; default;
  end;

  TVerbDispatcher=class(TComponent)
  private
    FVerbList:TVerbList;
    FVersion : TDCVersion;
    procedure SetVerbList(Value:TVerbList);
  protected
    procedure CMIDECHANGED(Var Message:TMessage);message CM_IDECHANGED;
    procedure CMPROPCHANGED(Var Message:TMessage);message CM_PROPCHANGED;
    procedure CMFREEEDITGROUP(Var Message:TMessage);message CM_FREEEDITGROUP;
    procedure CMPACKAGELOADED(Var Message:TMessage);message CM_PACKAGELOADED;
    procedure Notification(AComponent:TComponent;Operation:TOperation);override;
  public
    procedure UpdateVerbObjects(Group:Integer);
    procedure UpdateControls;
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
  published
    property VerbList:TVerbList Read FVerbList Write SetVerbList;
    property Version : TDCVersion read FVersion write FVersion stored false;
  end;

  TDCPropStore = class(TComponent)
  private
    fIgnoreErrors : boolean;
    fPropNames : TStringList;
    fKey : string;
    FPropList : TStrings;
    fStorePos : boolean;
    fOldFormClose : TCloseQueryEvent;
    fOldOnDestroy : TNotifyEvent;
    fTmpProps : TList;
    FVersion : TDCVersion;

    fOnLoadChanges : TProcessChangesProc;
    fOnSaveChanges : TProcessChangesProc;

    procedure SetPropList(Value:TStrings);
    procedure ProcessAllProps(Filer : TFiler; WriteMode : boolean);
    procedure HookOnClose;
    procedure MyCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MyOnDestroy(Sender: TObject);
    procedure ReaderError(Reader: TReader; const Message: string; var Handled: Boolean);
    function  GetKey : string;
    procedure ReadSelectedProps(Instance : TComponent; Reader : TReader; PropNames : TStrings);
    procedure DummySetProc;
    procedure ProcessProp1(Instance : TPersistent; PropInfo : PPropInfo; UserData : Integer);
    procedure ProcessProp2(Instance : TPersistent; PropInfo : PPropInfo; UserData : Integer);
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure SaveToStream(Stream:TStream);
    procedure LoadFromStream(Stream:TStream);
    procedure Load; virtual;
    procedure Save; virtual;
  published
    property IgnoreErrors : boolean read fIgnoreErrors write fIgnoreErrors default true;
    property Key : string read GetKey write fkey;
    property PropList : TStrings  read FPropList write SetPropList;
    property StorePos : boolean read fStorePos write fStorePos default true;
    property Version : TDCVersion read FVersion write FVersion stored false;

    property OnLoadChanges : TProcessChangesProc read fOnLoadChanges write fOnLoadChanges;
    property OnSaveChanges : TProcessChangesProc read fOnSaveChanges write fOnSaveChanges;
  end;

  TDCTabControl = class(TTabControl)
  private
    FVersion : TDCVersion;
    function IsContainedControl: Boolean;
  protected
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
  published
    property Version : TDCVersion read FVersion write FVersion stored false;
  end;

  TCompFiler = class
  private
    _OldClassNamePtr:Pointer;
    _ClassNameStr:ShortString;
    _OldTable:PMethodTable;
    _S:TMemoryStream;
    FEventID:Integer;
    FEventNames:TStrings;
    FFixList:TStrings;
    fOnReaderError : TReaderError;
    fOnAfterLoad   : TNotifyEvent;


    fIgnoreDesignedForms : boolean;
    HandledAll           : boolean;
    FFilerErrors         : boolean;

    procedure CreateMethodTable(S:TStream; OldTable : PMethodTable);
    function  GlobalFindCompWithoutDesigned(const Name: string): TComponent;
    function  DoLoadFromStream(FormStream:TStream;Instance : TComponent):String;
  protected
    procedure CompLoaded;
  public
    NewFormStyle : TFormStyle;

    procedure Assign(Source : TCompFiler);
    procedure ReaderError(Reader: TReader; const Message: string; var Handled: Boolean);
    procedure ReaderOnMethod(Reader: TReader; const MethodName: string;
                var Address: Pointer; var Error: Boolean);
    function  AddEvent(Const EvName:String):Integer;
    procedure BeginMethodTrick(OwnerControl:TComponent;SkipMethodsWrite:boolean);
    procedure EndMethodTrick(OwnerControl:TComponent);
    procedure BeginClassNameTrick(OwnerControl:TComponent);
    procedure EndClassNameTrick(OwnerControl:TComponent);

    procedure BeginTrick(OwnerControl:TComponent;SkipMethodsWrite:boolean);
    procedure EndTrick(OwnerControl:TComponent);

    function  EventNameByID (ID : integer) : string;
    constructor Create;
    destructor Destroy;override;
    function  LoadFromStream(FormStream:TStream;Instance : TComponent):string;
    procedure SaveToStream(FormStream:TStream;Instance : TComponent);
    procedure LoadFromFile(const FileName : TFileName; Instance : TComponent);
    procedure SaveToFile(const FileName : TFileName; Instance : TComponent);
    function  CreateFromStream(S : TStream; ModuleClass : TComponentClass; SetDesigning : boolean) : TComponent;
    function  CreateFromFile(const FileName : TFileName; ModuleClass  :TComponentClass;SetDesigning:boolean):TComponent;

    property EventNames:TStrings Read FEventNames;
    property FilerErrors:boolean Read FFilerErrors;
    property IgnoreDesignedForms : boolean read fIgnoreDesignedForms write fIgnoreDesignedForms;
    property OnReaderError : TReaderError read fOnReaderError write fOnReaderError;
    property OnAfterLoad   : TNotifyEvent read fOnAfterLoad write fOnAfterLoad;
  end;

  TCustomDCOleControl=class(TCustomControl)
  private
    fOnEvent : TEventHandler;
  protected
    function GetOleName : string; virtual; abstract;
    function GetOleObject : IOleObject; virtual; abstract;
  public
    procedure   SetEvent(ID : integer; const HandlerName : string); virtual; abstract;
    function    GetEvent(ID : integer) : string; virtual; abstract;

    property OleName:String Read GetOleName;
    property OnEvent : TEventHandler read fOnEvent write fOnEvent;
    property OleObject : IOleObject read GetOleObject;
  end;

  TDCSpeedButton = class(TSpeedButton)
  private
    {$IFNDEF D3}
    fFlat : boolean;
    {$ENDIF}
    foldOnChange : TNotifyEvent;
    FVersion : TDCVersion;
    procedure GlyphChanged(Sender : TObject);
  public
    constructor Create(AOwner : TComponent); override;
  published
    {$IFNDEF D3}
    property Flat : boolean read fFlat write fFlat;
    {$ENDIF}
    property Version : TDCVersion read FVersion write FVersion stored false;
  end;

procedure UpdateParamsWithBorderStyle(var Params: TCreateParams;BorderStyle:TBorderStyle;Ctl3d:boolean);
function  GetMaxFontWidth(Font:TFont):Integer;
function  GetAveFontWidth(Font:TFont):Integer;
function  GetMaxFontHeight(Font:TFont):Integer;
function  GetMinFontHeight(Font:TFont):Integer;
function  IsFontMonoSpaced(Font : TFont) : boolean;
function  GetFontMetrics(Font:TFont):TTextMetric;

function  GetScrollPosEx(Wnd:THandle;fnBar:Integer):Integer;
procedure _SetScrollPos(W : HWND; Code, Value: Integer);
procedure _SetScrollSize(W : HWND; Code, MinPos, MaxPos, PageSize : Integer);
{$ENDIF}
function  CheckFileExt(const FileName,FileExt:String):boolean;
function  IsStringHot(const s : string) : boolean;
function  IsWWWString(const s : string) : boolean;
function  IsEmailString(const s : string) : boolean;

{$IFDEF WIN}
procedure DesignerModified(c : TPersistent);
procedure DesignerSelectComponent(c : TComponent);
procedure SetDesign(F:TComponent;Value:Boolean);

procedure CallCompOnCreate(Comp:TComponent);
function  FindFormWithClass(C:TClass):TCustomForm;
function  FormIsActive(F:TCustomForm):boolean;
function  FindOrCreateFormWithClass(C : TCustomFormClass; Owner : TComponent) : TCustomForm;
function  ScreenFormCount:Integer;
function  ScreenForms(i:Integer):TCustomForm;
procedure SetFormFont(Form : TCustomForm);
function  GlobalFindObject(Const FullName:String):TComponent;
function  GetPForm(c : TPersistent) : TCustomForm;
function  GetTopOwner(c : TPersistent) : TComponent;
function  GetFormResourceHandler(AClass:TClass):THandle;
function  CreateFormWithClass(FormClass:TComponentClass):TCustomForm;
function  CreateDataModuleWithClass(DataModuleClass : TComponentClass) : TDataModule;

procedure UpdateEditors(Control:TWinControl);
procedure WriteWinPosToReg(C:TWinControl;Const S:String);
procedure ReadWinPosFromReg(C:TWinControl;Const S:String);
procedure RegisterAssignVerbProc(CompClass:TComponentClass;AssignVerbProc:TAssignVerbProc);
procedure CalcEditorMinMaxInfo(Var Message:TMessage;Form:TCustomForm;MaxToFullScreen:Boolean);

procedure JumpToURL(const s : string);
procedure WriteToUs;
procedure HomePage;
procedure OnlineRegistration;

procedure ChangeTab(TabControl:TTabControl; ANext:Boolean);
procedure AddNewTab(TabControl:TTabControl; const TabCaption :String );
procedure ClearMenuSubItems(MenuItem:TMenuItem;DisableItem:boolean);
procedure RemoveExtraMenuSeparators(MenuItem:TMenuItem);
function  StreamContainsDataModule(S : TStream) : boolean;
{$ENDIF WIN}
procedure GetLoadedPackagesPaths(Strings:TStrings);
procedure ResModulesToList(List:TList);
procedure ModulesToList(List:TList);
function FileIsPackage(const FileName:String):boolean;

procedure MovePages(Source, Dest : TPageControl);
{$IFDEF WIN}
procedure ChangeImageList(Image: TCustomImageList; Bitmap: TBitmap; trColor: TColor; index: integer);

procedure CreateBrushPattern(Bitmap: TBitmap);
procedure CreateBrushPatternEx(Bitmap: TBitmap; Color1, Color2: TColor);

procedure StretchBltTransparent(DestDC: THandle; DestLeft, DestTop, DestWidth, DestHeight: Integer;
  SourceDC: THandle; SourceLeft, SourceTop, SourceWidth, SourceHeight: Integer; TransColor: TColor);
procedure DrawImage(Canvas: TCanvas; Image: TPersistent; Color: TColor;
  const ARect: TRect; ImageIndex: integer);
{$ENDIF}
{$IFDEF D4}
procedure SafeRegisterActions(const CategoryName: string; const AClasses: array of TBasicActionClass; Resource: TComponentClass);
{$ENDIF}

const
  cOtherIdentChars : TCharSet=['A'..'Z','a'..'z','_','0'..'9'];
  StdFontSizes : array [0..15] of integer =
    (8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72);

{$IFDEF WIN}
var
  FMainForm : TCustomForm = nil;
  UseOneFont : boolean = true; // if true then all forms has the same font

{$IFDEF D4}
type
  TDesigner = IDesigner;
{$ENDIF}

type
  TGetDesignerProc = function (Instance : TPersistent) : TDesigner;

var
  GetDesignerProc : TGetDesignerProc = nil;


function QueryDirectory(const ATitle : string; var ADirectory : string) : boolean;
function DropFiles(const Dirs , Multiselect: boolean ; DelimiterChar : char;
  var Message: TWMDropFiles):string;
{$ENDIF WIN}

function  IsTextStream(S : TStream) : boolean;
{$IFDEF WIN}
function GetOptionsFormCaption(OptionsFormClass : TCustomFormClass) : string;
procedure RegisterOptionsForm(OptionsFormClass : TCustomFormClass; const ACaption : string);
procedure RegisterOptionsFormOrder(OptionsFormClass : TCustomFormClass; Order : integer; const ACaption : string);
procedure UnregisterOptionsForm(OptionsFormClass : TCustomFormClass);

procedure SetFlatProp(const Ctrls:Array of TSpeedButton;V:Boolean);
procedure SetFlatPropToAll(Owner:TComponent;Value:boolean);

function  OptionFormClasses : TStringList;

procedure CorrectBitmap(Bitmap: TBitmap);
{$ENDIF}
type
  TReaderErrorHandler  = procedure (const Message : string ; Var Handled, HandledAll : boolean);
  TOnHotStringHandler = function (const s : string) : boolean;
var
  ReaderErrorHandler : TReaderErrorHandler;
  OnHotString : TOnHotStringHandler;
  HotCharSet  : TCharSet = [];

{$IFDEF WIN}
 { Instance of this class will be created when user opens form object }
  DefaultFormClassType:TCustomFormClass=TForm;
{$ENDIF}

Procedure Register;

implementation

function IsTextStream(S : TStream) : boolean;
var
  buffer : array[1..length('inherited')] of byte;

  function CheckIdent(const Ident : string) : boolean;
  begin
    result := CompareMem(@buffer, pointer(Ident), length(Ident));
  end;

var
  savepos   : integer;
begin
  savepos := S.Position;
  try
    S.ReadBuffer(buffer, sizeof(buffer));
    result := CheckIdent('object') or CheckIdent('inherited');
  finally
    S.Position := savepos;
  end;
end;

{------------------------------------------------------------------}

{$IFDEF WIN}
procedure CorrectBitmap(Bitmap: TBitmap);
var
  bmp: TBitmap;
begin
  if Bitmap = nil then
    exit;
  Bmp := TBitmap.Create;
  with Bmp, Canvas do
  try
    Width := Bitmap.Width;
    Height := Bitmap.Height;
    Draw(0, 0, Bitmap);
    Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;
end;

{------------------------------------------------------------------}

function QueryDirectory(const ATitle : string; var ADirectory : string) : boolean;
begin
{$IFDEF SHELLOBJ}
  result := QueryDir(ATitle, ADirectory, Application.Handle);
{$ELSE}
  result := SelectDirectory(ADirectory, [], 0);
{$ENDIF}
end;

{------------------------------------------------------------------}

function GetDesigner(Instance : TPersistent) : TDesigner;
var
  f : TCustomForm;
begin
  if Assigned(GetDesignerProc) then
    result := GetDesignerProc(Instance)
  else
    begin
      f := GetPForm(Instance);
      if f <> nil then
        result := f.Designer
      else
        result := nil;
    end;
end;

{--------------------------------------------}

procedure DesignerModified(c : TPersistent);
var
  Designer : TDesigner;
begin
  Designer := GetDesigner(c);
  if Designer <> nil then
    Designer.Modified;
end;

{--------------------------------------------}

procedure DesignerSelectComponent(c : TComponent);
begin

end;

{--------------------------------------------}

procedure UpdateEditors(Control : TWinControl);
var
  i       : integer;
begin
  with Control do
    for i := 0 to ControlCount - 1 do
      Controls[I].Perform(CM_UPDATEEDITORS, 0, 0);
end;

{--------------------------------------------}

procedure ChangeTab(TabControl:TTabControl;ANext:Boolean);
Var
  i:Integer;
begin
  With TabControl do
  begin
    I:=TabIndex;
    If ANext then
      inc(i)
    else
      dec(i);
    TabIndex:=i;
    If i<0 then
      TabIndex:=Tabs.Count-1
    else
    If i>=Tabs.Count then
      TabIndex:=0;
  end;
end;
{------------------------------------------------------------------}

procedure AddNewTab(TabControl:TTabControl;const TabCaption : String);
Var
  i:Integer;
begin
  With TabControl,Tabs do
  begin
    for i:=0 to Count-1 do
      if CompareText(TabCaption,Strings[i])=0 then
      begin
        TabIndex:=i;
        exit;
      end;
    TabIndex:=Add(TabCaption);
  end;
end;

{--------------------------------------------}

procedure RemoveExtraMenuSeparators(MenuItem:TMenuItem);
Var
  A:Integer;
begin
  With MenuItem do
    if Count > 0 then
      begin
        // Remove all separators from menu top
        While (Count>0) and (Items[0].Caption = '-') do
          Items[0].Free;

        // Remove all separators from menu bottom
        While (Count>0) and (Items[Count - 1].Caption='-') do
          Items[Count-1].Free;

        // Remove double separators
        a := Count - 2;
        While a >= 0 do
        begin
          if (Items[a].Caption = '-') and (Items[a + 1].Caption = '-') then
            Items[a].Free;
          dec(a);
        end;
      end;
end;

{--------------------------------------------}

procedure ClearMenuSubItems(MenuItem:TMenuItem;DisableItem:boolean);
begin
  If MenuItem=nil then
    exit;
  With MenuItem do
  begin
    While Count>0 do
      Items[0].Free;
    MenuItem.Enabled:=not DisableItem;
  end;
end;

{--------------------------------------------}

function GlobalFindObject(Const FullName:String):TComponent;
Var
  i:Integer;
  FormName,CompName:String;
begin
  Result:=nil;
  FormName:=ChangeFileExt(FullName,'');
  CompName:=RemoveCharSet(['.'],ExtractFileExt(FullName));

  for I:=0 to ScreenFormCount - 1 do
    if CompareText(FullName, ScreenForms(i).Name) = 0 then
      begin
        result := ScreenForms(i);
        exit;
      end
    else if CompareText(FormName, ScreenForms(i).Name) = 0 then
    begin
      Result:=ScreenForms(i).FindComponent(CompName);
      exit;
    end;

  With Screen do
  for i := 0 to DataModuleCount - 1 do
    if CompareText(FullName, DataModules[i].Name) = 0 then
      begin
        result := DataModules[i];
        exit;
      end
    else
      if CompareText(DataModules[i].Name,FormName)=0 then
        begin
          result := DataModules[i].FindComponent(CompName);
          exit;
        end;
end;

{--------------------------------------------}

function GetPForm(c : TPersistent) : TCustomForm;

  function _getpform(c : TControl) : TCustomForm;
  begin
    while not ((c = nil) or (c is TCustomForm)) do
      c := TControl(c).Parent;

    result := TCustomForm(c);
  end;

begin
  if c is TControl then
    begin
      result := _getpform(TControl(c));

      if result <> nil then
        exit;
    end;

{$IFNDEF D3}
  if not (c is TComponent) then
    begin
      result := nil;
      exit;
    end;
{$ENDIF}

  while (c <> nil) and not (c is TCustomForm) do
    c := GetOwner(c);

  result :=TCustomForm(c);
end;

{--------------------------------------------}

function GetFormResourceHandler(AClass:TClass):THandle;
var
  s : string;
begin
  S := AClass.ClassName;
  Result := FindResource(GetClassModule(AClass), PChar(S), RT_RCDATA);
end;

{------------------------------------------------------------------}

function CreateDataModuleWithClass(DataModuleClass : TComponentClass) : TDataModule;
begin
  if not DataModuleClass.InheritsFrom(TDataModule) then
    DataModuleClass := TDataModule;

  If GetFormResourceHandler(DataModuleClass) <> 0 then
    Result := TDataModuleClass(DataModuleClass).Create(nil)
  else
  {$IFDEF VER93}
    Result := TDataModuleClass(DataModuleClass).CreateNew(nil, 0);
  {$ELSE}
    Result := TDataModuleClass(DataModuleClass).CreateNew(nil);
  {$ENDIF}
end;

function CreateFormWithClass(FormClass:TComponentClass):TCustomForm;
begin
  if not FormClass.InheritsFrom(TCustomForm) then
    FormClass := TCustomForm;

  If GetFormResourceHandler(FormClass) <> 0 then
    Result := TCustomFormClass(FormClass).Create(nil)
  else
  {$IFDEF VER93}
    Result := TCustomFormClass(FormClass).CreateNew(nil, 0);
  {$ELSE}
    Result := TCustomFormClass(FormClass).CreateNew(nil);
  {$ENDIF}
end;

{------------------------------------------------------------------}

function GetTopOwner(c : TPersistent) : TComponent;
var
  pform : TCustomForm;
begin
  pform := GetPForm(c);
  while (c <> nil) and not (c is TDataModule) do
    c := GetOwner(c);
  if c = nil then
    result := pform
  else
    result := TComponent(c);
end;

{--------------------------------------------}

function FindFormWithClass(C:TClass):TCustomForm;
Var
  i:Integer;
begin
  for i:=0 to ScreenFormCount-1 do
    if ScreenForms(i).InheritsFrom(C) then
    begin
      Result:=ScreenForms(i);
      exit;
    end;
  Result:=nil;
end;

{--------------------------------------------}

function FormIsActive(F:TCustomForm):boolean;
var
  i : Integer;

  function FormIsOk(QueryForm:TCustomForm):boolean;
  Var
    M:TMessage;
  begin
    M.Msg:=cm_ToolBarForm;
    M.Result:=0;
    QueryForm.Dispatch(M);
    Result:=M.Result=0;
  end;

begin
  result := (f <> nil) and F.HandleAllocated and IsWindowVisible(F.Handle);
  if not result then
    exit;

  for i:=0 to ScreenFormCount-1 do
    with ScreenForms(i) do
      if HandleAllocated and
         IsWindowVisible(Handle) and
         ((ScreenForms(i) = F) or
          ((ScreenForms(i) <> Application.MainForm) and (ScreenForms(i) <> FMainForm) and
           FormIsOk(ScreenForms(i))))
      then
        begin
          result := ScreenForms(i) = f;
          exit;
        end;

  Result := False;
end;

{--------------------------------------------}

function  FindOrCreateFormWithClass(C : TCustomFormClass; Owner : TComponent) : TCustomForm;
begin
  result := FindFormWithClass(C);
  if result = nil then
    result := C.Create(Owner);
end;

{--------------------------------------------}

type
  TMControl = class(TControl)
  end;

procedure SetFormFont(Form : TCustomForm);
begin
  if UseOneFont and TMControl(Form).ParentFont and Assigned(Application.MainForm) then
    Form.Font := Application.MainForm.Font;
end;

{--------------------------------------------}

function ScreenFormCount:Integer;
begin
  {$IFDEF D3}
    Result:=Screen.CustomFormCount;
  {$ELSE}
    Result:=Screen.FormCount;
  {$ENDIF}
end;

{------------------------------------------------------------------}

function ScreenForms(i:Integer):TCustomForm;
begin
  {$IFDEF D3}
    Result:=Screen.CustomForms[i];
  {$ELSE}
    Result:=Screen.Forms[i];
  {$ENDIF}
end;

{--------------------------------------------}

procedure JumpToURL(const s : string);
begin
  ShellExecute(Application.Handle, nil, PChar(s), nil, nil, SW_SHOW);
end;
{------------------------------------------------------------------}

procedure WriteToUs;
begin
  JumpToURL(WriteToUsURL);
end;

{------------------------------------------------------------------}

procedure HomePage;
begin
  JumpToURL(CompanyURL);
end;

{------------------------------------------------------------------}

procedure OnlineRegistration;
begin
  JumpToURL(RegistrationURL);
end;

{--------------------------------------------}

const
  SWinPosKeyName='WinPos';//don't resource
  SWindowStateKeyName='WindowState';//don't resource

procedure ReadWinPosFromReg(C:TWinControl;Const S:String);
var
  KeyStr : String;
  WindowPlacement : TWindowPlacement;
begin
  if c = nil then
    exit;

  KeyStr := SFormRegPrefix+S+'\';
  if ReadBufFromRegistry(KeyStr+SWinPosKeyName, WindowPlacement,
       Sizeof(WindowPlacement)) = 0 then
    exit;

  with WindowPlacement do
    begin
      with rcNormalPosition do
        c.SetBounds(left, top, right - left, bottom - top);

      if c is TCustomForm then
        TCustomForm(c).WindowState:=TWindowState(
          ReadFromRegistry(KeyStr+SWindowStateKeyName, Integer(wsnormal)));

    end;
end;

{------------------------------------------------------------------}

procedure WriteWinPosToReg(C : TWinControl; Const S : String);
Var
  KeyStr:String;
  WindowPlacement: TWindowPlacement;
begin
  if c = nil then
    exit;

  KeyStr:=SFormRegPrefix+S+'\';
  If C.HandleAllocated then
  begin
    WindowPlacement.Length := SizeOf(WindowPlacement);
    GetWindowPlacement(C.Handle, @WindowPlacement);
    WriteBufToRegistry(KeyStr+SWinPosKeyName, WindowPlacement, Sizeof(WindowPlacement));

    If c is TCustomForm then
      WriteToRegistry(KeyStr+SWindowStateKeyName, Integer(TCustomForm(c).WindowState));
  end;
end;

{------------------------------------------------------------------}

Procedure CalcEditorMinMaxInfo(Var Message:TMessage;Form:TCustomForm;MaxToFullScreen:Boolean);
Const
  MinWindowSizeX=320;
  MinWindowSizeY=240;
Var
  BorderSizeX:Integer;
  BorderSizeY:Integer;
  FormBottom:Integer;
  DesktopRect:TRect;
  DesktopWidth:Integer;
  DesktopHeight:Integer;
Begin
  BorderSizeX:=GetSystemMetrics(SM_CXSIZEFRAME);
  BorderSizeY:=GetSystemMetrics(SM_CYSIZEFRAME);
  SystemParametersInfo(spi_GetWorkArea,0,@DesktopRect,0);
  DesktopWidth:=DesktopRect.Right-DesktopRect.Left;
  DesktopHeight:=DesktopRect.Bottom-DesktopRect.Top;

  With PMinMaxInfo(Message.lParam)^ do
  begin
    If Form<>nil then
    begin
      ptMaxPosition.X:=DesktopRect.Left-BorderSizeX;
      FormBottom:=Form.Top+Form.Height;
      If (Form.Top<DesktopHeight-FormBottom) And
         Not MaxToFullScreen Then
      Begin
        ptMaxPosition.y:=FormBottom;
        Dec(ptMaxSize.y,FormBottom+BorderSizeY);
      End
      Else
      Begin
        ptMaxPosition.Y:=DesktopRect.Top-BorderSizeY;
        ptMaxSize.X:=DesktopWidth+BorderSizeX*2;
        ptMaxSize.Y:=DesktopHeight+BorderSizeY*2;
      End;
    end;
    ptMinTrackSize.x:=MinWindowSizeX;
    ptMinTrackSize.y:=MinWindowSizeY;
  end;
  Message.Result:=0;
End;

{--------------------------------------------}

procedure UpdateParamsWithBorderStyle(var Params: TCreateParams;BorderStyle:TBorderStyle;Ctl3d:boolean);
begin
  With Params do
    if BorderStyle = bsSingle then
      if NewStyleControls and Ctl3D then
      begin
        Style := Style and not WS_BORDER;
        ExStyle := ExStyle or WS_EX_CLIENTEDGE;
      end
      else
        Style := Style or WS_BORDER;
end;

{--------------------------------------------}

function GetScrollPosEx(Wnd:THandle;fnBar:Integer):Integer;
Var
  ScrollInfo:TScrollInfo;
Begin
  FillChar(ScrollInfo,SizeOf(ScrollInfo),0);
  ScrollInfo.cbSize:=SizeOf(ScrollInfo);
  ScrollInfo.fMask:=SIF_TRACKPOS;
  GetScrollInfo(Wnd,fnBar,ScrollInfo);
  Result:=ScrollInfo.nTrackPos;
End;

{------------------------------------------------------------------}
{$ENDIF}
function IsEmailString(const s : string) : boolean;
var
  firstpos : integer;
  lastpos  : integer;
  pointpos : integer;
  hs       : string;
begin
  hs := UpperCase(s);
  result := Pos(sUrlMailTo, hs) <> 0 ;
  if not result then
  begin
    firstpos := Pos('@', hs);
    lastpos := BackPosEx('@', hs, length(hs));
    pointpos := BackPosEx('.', hs, length(hs));
    result :=  (firstpos <> 0) and (firstpos = lastpos) and (pointpos > firstpos) and
               (firstpos <> length(hs)) and (hs[firstpos + 1] in cOtherIdentChars);

  end;
end;

{------------------------------------------------------------------}

function IsWWWString(const s : string) : boolean;
var
  hs       : string;
begin
  hs := UpperCase(Trim(s));
  result :=  (Pos(sUrlWWW, hs) <> 0) or (Pos(sUrlHttp, hs) = 1) or (Pos(SUrlGopher, hs) = 1) or
             (Pos(SUrlFtp, hs) = 1);
end;

{------------------------------------------------------------------}

function IsStringHot(const s : string) : boolean;
begin
  result := IsWWWString(s) or IsEMailString(s);
  if not result and Assigned(OnHotString) then
    result := OnHotString(s);
end;

{------------------------------------------------------------------}

procedure _SetScrollPos(W : HWND; Code : Integer; Value : Integer);
begin
  if GetScrollPos(W, Code) <> Value then
    SetScrollPos(W, Code, Value, True);
end;

{-------------------------------------------------------------------------}

procedure _SetScrollSize(W : HWND; Code, MinPos, MaxPos, PageSize : Integer);
Var T:TScrollInfo;
begin
  With T do
  begin
    cbSize:=SizeOf(T);
    fMask:=SIF_PAGE or SIF_RANGE;
    nMin:=MinPos;
    nMax:=MaxPos;
    nPage:=PageSize;
    nPos:=0;
    nTrackPos:=0;
  end;
  SetScrollInfo(W,Code,T,True);
end;

{------------------------------------------------------------------}

{$IFDEF WIN}
function GetMaxFontWidth(Font:TFont):Integer;
begin
  Result:=GetFontMetrics(Font).tmMaxCharWidth;
end;

{-------------------------------------------------------------------------}

function GetAveFontWidth(Font : TFont): integer;
begin
  Result := GetFontMetrics(Font).tmAveCharWidth;
end;

{-------------------------------------------------------------------------}
const
  CheckString = 'Wg';  //don't resource
  CheckMinString : string = 'x'; //don't resource

function GetMaxFontHeight(Font:TFont):Integer;
var
  dc   : THandle;
  oldf : THandle;
  Size : TSize;
begin

  dc := GetDC(0);
  oldf := SelectObject(dc, Font.Handle);
  try
    Size.cX := 0;
    Size.cY := 0;
    Windows.GetTextExtentPoint32(DC, PChar(CheckString), Length(CheckString), Size);
    result := Size.cY;
  finally
    SelectObject(dc, oldf);
    ReleaseDC(0, dc);
  end;
end;

{-------------------------------------------------------------------------}

function GetMinFontHeight(Font:TFont):Integer;
var
  dc   : THandle;
  oldf : THandle;
  Size : TSize;
begin

  dc := GetDC(0);
  oldf := SelectObject(dc, Font.Handle);
  try
    Size.cX := 0;
    Size.cY := 0;
    Windows.GetTextExtentPoint32(DC, PChar(CheckMinString), Length(CheckMinString), Size);
    result := Size.cY;
  finally
    SelectObject(dc, oldf);
    ReleaseDC(0, dc);
  end;
end;

{-------------------------------------------------------------------------}

function GetFontMetrics(Font:TFont):TTextMetric;
var
  dc   : THandle;
  oldf : THandle;
begin
  dc := GetDC(0);
  oldf := SelectObject(dc, Font.Handle);
  try
    GetTextMetrics(dc, result);
  finally
    SelectObject(dc, oldf);
    ReleaseDC(0, dc);
  end;
end;

{-------------------------------------------------------------------------}

function IsFontMonoSpaced(Font : TFont) : boolean;
begin
  result := (GetFontMetrics(Font).tmPitchAndFamily and TMPF_FIXED_PITCH) = 0;
end;

{---------TDCCustomControl----------------------}

procedure TDCCustomControl.KeyPress(var Key: Char);
begin
  inherited;
  if (csDesigning in ComponentState) or (KeyState<>0) then
    exit;
  If InsertChar(Char(Key)) then
    Key:=#0;
end;

{-------------------------------------------------------------}

procedure TDCCustomControl.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  With Msg do
  begin
    Result := DLGC_WANTMESSAGE or
              DLGC_WANTALLKEYS or
              DLGC_WANTARROWS  or
              DLGC_WANTCHARS;

    if FWantTabs then Result := Result or DLGC_WANTTAB;
    if not FWantReturns then
      Result := Result and not DLGC_WANTALLKEYS;
  end;
end;

{-------------------------------------------------------------}

function TDCCustomControl.InsertChar(Ch : Char):Boolean;
begin
  result := false;
end;

{-------------------------------------------------------------}

procedure TDCCustomControl.ClearKeys;
begin
  FKeys.Clear;
end;

{-------------------------------------------------------------}

procedure TDCCustomControl.UpdateKeyMapping;
begin
  ClearKeys;
  If Assigned(FKeyBoardInit) then
    FKeyboardInit(Self)
  else
    InitDefaultKeyMapping;
end;

{-------------------------------------------------------------}

procedure TDCCustomControl.SetKeyMapping(const V:String);
begin
  if FKeyMapping<>V then
  begin
    FKeyMapping:=V;
    FKeyboardInit:=GetKeyboardInitProc(Self.ClassType,V);
    UpdateKeyMapping;
  end;
end;

{-------------------------------------------------------------}

constructor TDCCustomControl.Create(AOwner:TComponent);
begin
  inherited;
  WantReturns:=True;
  FKeys:=TKeyList.Create;
  KeyMapping := ResStr(SDefault);
end;

{-------------------------------------------------------------}

destructor TDCCustomControl.Destroy;
begin
  FKeys.Free;
  inherited;
end;

{--------------------------------------------}

procedure TDCCustomControl.CNKeyDown(var Message: TWMKeyDown);
begin
  If KeyState=0 then
    inherited
  else
  With Message do
  begin
    KeyDown(CharCode,KeysToShift);
    If CharCode=0 then
      Result:=1
    else
      inherited;
  end;
end;

{-------------------------------------------------------------}

procedure TDCCustomControl.CNSysKeyDown(var Message: TWMKeyDown);
begin
  With Message do
  begin
    KeyDown(CharCode,KeysToShift);
    If CharCode=0 then
      Result:=1
    else
      inherited;
  end;
end;

{-------------------------------------------------------------}

procedure TDCCustomControl.KeyDown(var Key: Word; Shift: TShiftState);
Var
  ResultKeyData:TKeyData;
begin
  inherited;

  If ((Key = VK_RETURN) and not FWantReturns) or ((Key = VK_TAB) and not FWantTabs ) then
  begin
   if ssCtrl in Shift then
     Shift := []
   else
     exit;
  end;

  If (Key=0) or (csDesigning in ComponentState) then
    exit;

{  If FKeyState=-2 then
    FKeyState:=0;}
  ResultKeyData:=FKeys.FindKeyData(Key,Shift,FKeyState);
  if ResultKeyData<>nil then
    With ResultKeyData do
      begin
        With TMethod(ActionCode) do
          If Code<>nil then
            CallMethod(Data,Code);
        Key:=0;
        FkeyState:=LeaveState;
{        If FKeyState=0 then
          FKeyState:=-2;}
        exit;
      end;
   FKeyState:=0;
end;
{----------------THandleObject-------------------------------------}
var
  ClipWndClass: TWndClass = (
    style: CS_DBLCLKS;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'ClipboardClass');//don't resource

{------------------------------------------------------------------}

constructor THandleObject.Create(WndProc: TWndMethod);
var
  TempClass       : TWndClass;
  ClassRegistered : Boolean;
begin
  inherited Create;
  ClipWndClass.hInstance := HInstance;
  ClassRegistered := GetClassInfo(HInstance, ClipWndClass.lpszClassName,TempClass);
  if not ClassRegistered then
    Windows.RegisterClass(ClipWndClass);
  FWnd  := CreateWindowEx(WS_EX_TOPMOST, ClipWndClass.lpszClassName,
                          '', WS_POPUP, 0, 0, 1, 1, 0, 0, HInstance, nil);
  SetWindowLong(FWnd, GWL_WNDPROC, Longint(MakeObjectInstance(WndProc)));
  SetWindowLong(FWnd, GWL_STYLE, WS_CHILD);
end;

{------------------------------------------------------------------}

destructor THandleObject.Destroy;
begin
  DeallocateHWnd(FWnd);
  inherited Destroy;
end;

{******************************************************************}

procedure TDCHandleObject.PostMsg(Msg, wParam, lParam : integer);
begin
  PostMessage(Handle, Msg, wParam, lParam);
end;

{------------------------------------------------------------------}

procedure TDCHandleObject.WndProc(var Msg: TMessage);
begin
  if fObject <> nil then
    fObject.Dispatch(Msg);
end;

{------------------------------------------------------------------}

constructor TDCHandleObject.Create(AObject : TObject);
begin
  fObject := AObject;
  inherited Create(WndProc);
end;

{------------------------------------------------------------------}

procedure TPropStream.BadPropInfo;
begin
  raise Exception.Create(SErrBadPropStream);
end;

{------------------------------------------------------------------}

procedure TPropStream.UpdatePropInfo;
Var
  FObject:TObject;
  TypeInfo:PTypeInfo;
begin
  If (FInstance=nil) or (FPropName='') then
    BadPropInfo;

  FPropInfo:=GetPropInfo(FInstance.ClassInfo,FPropName);
  TypeInfo:=GetPTypeInfo(FPropInfo);

  If (FPropInfo=nil) or (TypeInfo=nil) then
    BadPropInfo;

  If TypeInfo.Kind=tkClass then
  begin
    FObject:=TObject(GetOrdProp(FInstance,FPropInfo));
    If FObject is TStrings then
      FStrings:=TStrings(FObject)
    else
      BadPropInfo;
  end else
    if TypeInfo.Kind in StringTypes then
      FStrings:=nil
    else
      BadPropInfo;
end;

{------------------------------------------------------------------}

procedure TPropStream.SetPropValue(const S:String);
begin
  UpdatePropInfo;
  If FStrings<>nil then
    FStrings.Text:=S
  else
    SetStrProp(FInstance,FPropInfo,S);
  DesignerModified(FInstance);
end;

{------------------------------------------------------------------}

function TPropStream.GetPropValue:String;
begin
  UpdatePropInfo;
  If FStrings<>nil then
    Result:=FStrings.Text
  else
    Result:=GetStrProp(FInstance,FPropInfo);
end;

{------------------------------------------------------------------}

constructor TPropStream.Create(Instance:TPersistent;const PropName:String;Mode:Integer);
Var
  PropVal:String;
begin
  inherited Create;
  FInstance:=Instance;
  FPropName:=PropName;
  FMode:=Mode and 3;
  If (FMode=fmOpenRead) or (FMode=fmOpenReadWrite) then
  begin
    PropVal:=GetPropValue;
    WriteBuffer(PropVal[1],Length(PropVal));
    Seek(0,SoFromBeginning);
  end;
end;

{------------------------------------------------------------------}

destructor TPropStream.Destroy;
Var
  PropVal:String;
begin
  If FMode<>fmOpenRead then
  begin
    SetLength(PropVal,Size);
    Seek(0,soFromBeginning);
    ReadBuffer(PropVal[1],Size);
    SetPropValue(PropVal);
  end;
  inherited;
end;

{-------------------------------------------------------------------------}

procedure SetMenuItemParams(Comp:TComponent;VerbItem:TverbListItem);
begin
  With TMenuItem(Comp),VerbItem do
  begin
    If Visible<>(vsVisible in VerbStates) then
      Visible:=vsVisible in VerbStates;
    Enabled:=vsEnabled in VerbStates;
    Checked:=vsChecked in VerbStates;
    If ClearHandler then
      OnClick:=nil
    else
      OnClick:=VerbOnClick;
  end;
end;

{-------------------------------------------------------------------------}

procedure SetButtonParams(Comp:TComponent;VerbItem:TVerbListItem);
begin
  With TButton(Comp),VerbItem do
  begin
    Visible:=vsVisible in VerbStates;
    Enabled:=vsEnabled in VerbStates;
    If ClearHandler then
      OnClick:=nil
    else
      OnClick:=VerbOnClick;
  end;
end;

{-------------------------------------------------------------------------}

procedure SetSpeedButtonParams(Comp:TComponent;VerbItem:TVerbListItem);
begin
  With TSpeedButton(Comp),VerbItem do
  begin
    Visible:=vsVisible in VerbStates;
    Enabled:=vsEnabled in VerbStates;
    If ClearHandler then
      OnClick:=nil
    else
      OnClick:=VerbOnClick;
  end;
end;

{------------------------------------------------------------------}

procedure ChangeImageList(Image: TCustomImageList; Bitmap: TBitmap; trColor: TColor; index: integer);
var
  bmp: TBitmap;
  {$IFNDEF D3}
  oldbkcolor: longint;
  {$ENDIF}
begin
  Bmp := TBitmap.Create;
  try
    {$IFDEF D3}
    bmp.Assign(Bitmap);
    bmp.TransparentColor := trColor;
    ImageList_Replace(Image.Handle, Index, Bitmap.Handle, bmp.MaskHandle);
    {$ELSE}
    with Bitmap do
    begin
      Bmp.Monochrome := True;
      Bmp.Width := Width;
      Bmp.Height := Height;
      oldbkcolor := SetBkColor(Canvas.Handle, ColorToRgb(trcolor));
      Bmp.Canvas.Draw(0, 0, Bitmap);
      SetBkColor(Canvas.Handle, oldbkcolor);
      Image.Replace(Index, Bitmap, Bmp);
    end;
    {$ENDIF}
  finally
    bmp.Free;
  end;
end;

var
  RegisterAssignVerbProcsCalled : boolean = false;

procedure RegisterAssignVerbProcs;
begin
  if not RegisterAssignVerbProcsCalled then
    begin
      RegisterAssignVerbProcsCalled := true;
      RegisterAssignVerbProc(TMenuItem,SetMenuItemParams);
      RegisterAssignVerbProc(TSpeedButton,SetSpeedButtonParams);
      RegisterAssignVerbProc(TButton,SetButtonParams);
    end
end;

{---------TVerbDispatcher------------------------------------}

procedure TVerbDispatcher.CMPACKAGELOADED(Var Message:TMessage);
begin
  UpdateVerbObjects(-1);
end;

{-------------------------------------------------------------}

procedure TVerbDispatcher.UpdateVerbObjects(Group:Integer);
Var
  i:Integer;
begin
//  SendDebug(IntToStr(Group));
  for i:=0 to FVerbList.Count-1 do
    With TVerbListItem(FVerbList.Items[i]) do
      if (Group<0) or (FDesignGroup=Group) then
      begin
//        SendDebug(VerbName);
        UpdateVerbObject;
      end;
end;

{-------------------------------------------------------------}

procedure TVerbDispatcher.CMFREEEDITGROUP(Var Message:TMessage);
begin
  UpdateVerbObjects(Message.wParam);
end;

{-------------------------------------------------------------}

procedure TVerbDispatcher.Notification(AComponent:TComponent;Operation:TOperation);
var
  i:Integer;
begin
  inherited;
  If (Operation=opRemove) and (FVerbList<>nil) then
    With FVerbList do
      for i:=Count-1 downto 0 do
        With Items[i] do
          if VerbComp=AComponent then
            VerbComp:=nil;
end;

{-------------------------------------------------------------}

procedure TVerbDispatcher.CMPROPCHANGED(Var Message:TMessage);
begin
  UpdateControls;
end;

{-------------------------------------------------------------}

procedure TVerbDispatcher.CMIDECHANGED(Var Message:TMessage);
begin
  UpdateControls;
end;

{-------------------------------------------------------------}

procedure TVerbDispatcher.UpdateControls;
Var
  i:Integer;
begin
  If (IDEUpdateCount>0) or ([csDesigning,csLoading,csDestroying,csReading] * ComponentState<>[]) then
    exit;
  for i:=0 to FVerbList.Count-1 do
    TVerbListItem(FVerbList.Items[i]).UpdateControl;
end;

{-------------------------------------------------------------}

procedure TVerbDispatcher.SetVerbList(Value:TVerbList);
begin
  FVerbList.Assign(Value);
end;

{-------------------------------------------------------------}

constructor TVerbDispatcher.Create(AOwner:TComponent);
begin
  inherited;
  RegisterAssignVerbProcs;
  FVerbList := TVerbList.Create(self,TVerbListItem);
  RegisterNotifier(Self);
  InitIDENotifier;
end;

{-------------------------------------------------------------}

destructor TVerbDispatcher.Destroy;
begin
  UnRegisterNotifier(Self);
  FreeObject(FVerbList);//must be FreeObject not .Free
  inherited;
end;

{--------TVerbList--------------------------------------------}

function TVerbList.GetItem(Index:Integer):TVerbListItem;
begin
  Result:=TVerbListItem(inherited Items[Index]);
end;

{-------------------------------------------------------------}

procedure TVerbList.SetItem(Index:Integer;V:TVerbListItem);
begin
  inherited Items[Index]:=V;
end;

{---------TVerbListItem---------------------------------------}

procedure TVerbListItem.SetVerbName(const Value:String);
begin
  if FVerbName<>Value then
  begin
    FVerbName:=Trim(Value);
    UpdateVerbObject;
  end;
end;

{---------------------------------------------------------------}

procedure RegisterAssignVerbProc(CompClass:TComponentClass;AssignVerbProc:TAssignVerbProc);
begin
  RegisterClassExt(CompClass,[SAssignIdent,SAssignVerbProc],['',Integer(@AssignVerbProc)]);
end;

{-------------------------------------------------------------------------}

{$IFDEF D3}
function TVerbListItem.GetDisplayName: string;
begin
  If VerbComp<>nil then
    Result:=VerbComp.Name + ' - '
  else
    Result:='';
  Result:=Result+VerbName;
  If Result='' then
    Result:=inherited GetDisplayName;
end;
{$ENDIF}

{-------------------------------------------------------------------------}

function TVerbListItem.OwnerObject:TComponent;
begin
  Result:=TVerbList(Collection).Owner;
end;

{-------------------------------------------------------------------------}

procedure TVerbListItem.UpdateVerbObject;
Var
  Item,Item1:TObjectParamListItem;
begin
  If (csDesigning in OwnerObject.ComponentState) then
    exit;
  FVerbGetState:=nil;
  FVerbExecute:=nil;
  FAssignProc:=nil;
  If (VerbName='') or (VerbComp=nil) then
    exit;
  Item1:=GetItemInherited(VerbComp.ClassType,[SAssignIdent],[''],[]);
  Item:=GetVerbProcAddr(FVerbName,FVerbGetState,FVerbExecute);
  If (Item1<>nil) and (Item<>nil) then
  begin
    FDesignGroup:=Item.EditorGroup;
//    SendDebug(IntToStr(FDesignGroup)+' '+ FVerbName );
    FAssignProc:=TAssignVerbProc(Integer(Item1.Params[SAssignVerbProc]));
    UpdateControl;
  end;
end;

{-------------------------------------------------------------------------}

destructor TVerbListItem.Destroy;
begin
  FVerbStates:=[];
  FClearHandler:=True;
  If (VerbComp<>nil) and not (csDestroying in VerbComp.ComponentState) then
    UpdateControl;
  inherited;
end;

{-------------------------------------------------------------------------}

procedure TVerbListItem.UpdateControl;
Var
  FNewStates:TVerbStates;

  procedure InternalUpdate;
  begin
    If (FNewStates<>FVerbStates) then
    begin
      FVerbStates:=FNewStates;
      FAssignProc(VerbComp,Self);
    end;
  end;

begin
  If not Assigned(FAssignProc) then
    exit;
  FNewStates:=[vsVisible,vsEnabled];
  If Assigned(FVerbGetState) then
    FVerbGetState(FNewStates);
  InternalUpdate;
end;

{-------------------------------------------------------------------------}

procedure TVerbListItem.VerbOnClick(Sender:TObject);
begin
  If Assigned(FverbExecute) then
  begin
    IDEBeginUpdate;
    try
      FVerbExecute;
    finally
      IDEEndUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------}

procedure TVerbListItem.SetVerbComp(Value:TComponent);
begin
  If FVerbComp<>Value then
  begin
    FVerbComp:=Value;
    If Value<>nil then
      Value.FreeNotification(OwnerObject);
    UpdateVerbObject;
  end;
end;

{--------TPropFileSystem----------------------------------------------}

function TPropFileSystem.GetFileStream(const FileName: TFileName; Mode: Integer): TStream;
begin
  if fComponent = nil then
    Error('Component doesn''t exist'); // !!!!!!!
  result:=TPropStream.Create(fComponent, FPropName, Mode);
end;

{------------------------------------------------------------------}

function TPropFileSystem.GetFileSystemLevel:TFileSystemLevel;
begin
  Result:=flOnlyGetStream;
end;

{------------------------------------------------------------------}

procedure TPropFileSystem.SetComponent(val : TComponent);
begin
  if val <> fcomponent then
    begin
      {$IFDEF D5}
      if fComponent <> nil then
        fComponent.RemoveFreeNotification(self);
      {$ENDIF}
      fComponent := val;
      fComponent.FreeNotification(self);
    end;
end;

{------------------------------------------------------------------}

procedure TPropFileSystem.SetComponentPtr(const val : string);
begin
  Component := TComponent(StrToInt(val));
end;

{------------------------------------------------------------------}

function  TPropFileSystem.GetComponentPtr : string;
begin
  result := '$' + IntToHex(integer(fComponent), 8);
end;

{------------------------------------------------------------------}

function TPropFileSystem.FileExists(const FileName: TFileName): Boolean;
Var
  PropInfo:PPropInfo;
  TypeInfo:PTypeInfo;
begin
  result := (fComponent <> nil) and (fPropName <> '');

  if not result then
    exit;

  PropInfo := GetPropInfo(fComponent.ClassInfo, FPropName);
  TypeInfo := GetPTypeInfo(PropInfo);
  Result := TypeInfo <> nil;
  if not Result then
    exit;

  Result:=((TypeInfo.Kind = tkClass) and (TObject(GetOrdProp(fComponent, PropInfo)) is TStrings))
    or (TypeInfo.Kind in StringTypes);
end;

{------------------------------------------------------------------}

procedure TPropFileSystem.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FComponent) then
    begin
      Component:=nil;
      ReleaseFileSystem(Self);
    end;
end;

{-------------------------------------------------------------------------}

function DropFiles(const Dirs , Multiselect: boolean ; DelimiterChar : char;
  var Message: TWMDropFiles):string;
var
  AFileName : array[0..255] of Char;
  FName    : string;
  Tempstr  : string;
  i        : integer;
  Num      : integer;
begin
  Message.Result := 0;
  result := '';
  try
    Num := DragQueryFile(Message.Drop, $FFFFFFFF, nil, 0);
    if Num > 0 then
    begin
      for i := 0 to Num - 1 do
      begin
        DragQueryFile(Message.Drop, i, PChar(@AFileName), SizeOf(AFileName)-1 );
        FName := StrPAs(AFileName);
        if Dirs and  FileExists(FName) then
          Tempstr := ExtractFilePath(FName)
        else
          Tempstr := FName;
        if (result = '') or not Multiselect then
          result := Tempstr
        else
          result := result + DelimiterChar + Tempstr;
        if not Multiselect then
          Break;
      end;
    end;
  finally
    DragFinish(Message.Drop);
  end;
end;

{******************************************************************}

constructor TDCPropStore.Create(AOwner:TComponent);
begin
  inherited;
  FPropList := TStringList.Create;
  fTmpProps := TList.Create;
  StorePos := true;
  fIgnoreErrors := true;
  fPropNames := TStringList.Create;
  HookOnClose;
end;

{------------------------------------------------------------------}

destructor TDCPropStore.Destroy;
begin
  FPropList.Free;
  fTmpProps.Free;
  fPropNames.Free;
  inherited;
end;

{------------------------------------------------------------------}

procedure TDCPropStore.MyOnDestroy(Sender: TObject);
begin
  if LongRec(@fOldOnDestroy).Hi <> 0 then
    fOldOnDestroy(Sender);

  Save;
end;

{------------------------------------------------------------------}

procedure TDCPropStore.MyCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if LongRec(@fOldFormClose).Hi <> 0 then
    fOldFormClose(Sender, CanClose);

  if CanClose and TCustomForm(Owner).HandleAllocated then
    Save;
end;

{------------------------------------------------------------------}

type
  TMCustomForm = class(TCustomForm)
  end;

{------------------------------------------------------------------}

procedure TDCPropStore.HookOnClose;
var
  p : TCloseQueryEvent;
  pp : TNotifyEvent;
begin
  if csDesigning in ComponentState then
    exit;

  if Owner is TCustomForm then
    begin
      p := MyCloseQuery;
      with TMCustomForm(Owner) do
        if @OnCloseQuery <> @p then
          begin
            fOldFormClose := OnCloseQuery;
            OnCloseQuery := MyCloseQuery;
          end
    end
  else if Owner is TDataModule then
    begin
      pp := MyOnDestroy;
      with TDataModule(Owner) do
        if @OnDestroy <> @pp then
          begin
            fOldOnDestroy := OnDestroy;
            OnDestroy := MyOnDestroy;
          end;
    end;
end;

{------------------------------------------------------------------}

procedure TDCPropStore.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    begin
      HookOnClose;
      BeginGlobalLoading;
      try
        Load;
        NotifyGlobalLoading;
      finally
        EndGlobalLoading;
      end;
    end;
end;

{------------------------------------------------------------------}

procedure TDCPropStore.SetPropList(Value:TStrings);
begin
  FPropList.Assign(Value);
end;

{------------------------------------------------------------------}

procedure TDCPropStore.DummySetProc;
begin
end;

{------------------------------------------------------------------}

procedure TDCPropStore.ProcessProp1(Instance : TPersistent; PropInfo : PPropInfo; UserData : Integer);
var
  V : DWord;
  p : pointer;
begin
  ftmpProps.Add(PropInfo.SetProc);
  if fPropNames.IndexOf(PropInfo.Name) < 0 then
    begin
      p := Addr(TDCPropStore.DummySetProc);
      WriteProcessMemory(GetCurrentProcess, @(PropInfo.SetProc), @p, 4, V);
    end;
// PropInfo.SetProc := Addr(TDCPropStore.DummySetProc)

end;

{------------------------------------------------------------------}

procedure TDCPropStore.ProcessProp2(Instance : TPersistent; PropInfo : PPropInfo; UserData : Integer);
var
  P : Pointer;
  V : DWord;
begin
  with ftmpProps do
    begin
      P := First;
      WriteProcessMemory(GetCurrentProcess, @(PropInfo.SetProc), @P, 4, V);
    // PropInfo.SetProc := First;
      Delete(0);
    end;
end;

{------------------------------------------------------------------}

procedure TDCPropStore.ReadSelectedProps(Instance : TComponent; Reader : TReader; PropNames : TStrings);
begin
  fTmpProps.Clear;

  ForEachProp(Instance, ProcessProp1, false, 0);
  try
    Reader.ReadRootComponent(Instance);
  finally
    ForEachProp(Instance, ProcessProp2, false, 0);
  end;  
end;

{------------------------------------------------------------------}

procedure TDCPropStore.ProcessAllProps(Filer : TFiler; WriteMode : boolean);
var
  i : integer;
  p : integer;
  inst : TComponent;
  cinst : TComponent;
  size   : integer;
  fName  : string;
  cinstname : string;
  instname : string;
  buf : pointer;

  procedure getinstprop(const s : string);
  begin
    p := BackPosEx('.', s, length(s));
    if p = 0 then
      begin
        inst := Owner;
        fPropNames.Add(s);
        instname := inst.Name;
      end
    else
      begin
        fPropNames.Add(copy(s, p + 1, length(s) - p));
        instname := copy(s, 1, p - 1);
        inst := Owner.FindComponent(instname);
        if inst = nil then
          inst := GlobalFindObject(Owner.Name + '.' + instname);

        if inst = nil then
          inst := GlobalFindObject(instname);
      end;
  end;

var
  savedprops    : TStringList;
  savedname     : string;
  needsavedname : boolean;
  _text         : string;
  _ntext        : string;

const
  InvalidName : string = '0'; //don't resource

begin
  if Owner = nil then
    exit;

  i := 0;
  savedprops := TStringList.Create;
  needsavedname := true;
  try
    with fPropList do
      while i < Count do
        begin
          fPropNames.Clear;
          cinstname := '';
          cinst := nil;
          repeat
            getInstProp(Strings[i]);
            if (instname <> cinstname) and (cinstname <> '') then
              begin
                if fPropNames.Count = 1 then
                  inc(i);
                fPropNames.Delete(fPropNames.Count - 1);
                break;
              end
            else
              inc(i);
            cinst := inst;
            cinstname := instname;
          until (i = Count);

          if WriteMode then
            begin
              TWriter(Filer).WriteBoolean(true);
              if cinst <> nil then
                begin
                  TWriter(Filer).WriteString(cinstname);
                  TWriter(Filer).WriteString(fPropNames.Text);
                  _WritePropsToStream(TWriter(Filer), cinst, fPropNames)
                end
              else
               TWriter(Filer).WriteString(InvalidName);
            end
          else
            with TReader(Filer) do
              begin
                if not ReadBoolean then
                  break;
                  
                if needsavedname then
                  savedname := TReader(Filer).ReadString;

                needsavedname := (savedname = InvalidName) or (savedname = cinstname);

                if not needsavedname or (savedname = InvalidName) then
                  continue;

                savedprops.Text := TReader(Filer).ReadString;
                Read(size, sizeof(integer));
                IntersectStrings(savedprops, fPropNames);

                if (fPropNames.count = 0) or (cInst = nil) then
                  begin
                    GetMem(buf, size);
                    try
                      Read(buf^, size);
                    finally
                      FreeMem(buf, size);
                    end;
                  end
                else
                  begin
                    fName := cinst.Name;
                    if cinst is TControl then
                      _text := TMControl(cinst).Text;

                    cinst.Name := '';
                    try
                      ReadSelectedProps(cinst, TReader(Filer), fPropNames);
//                      ReadRootComponent(cinst);
                    finally
                      if (cinst is TControl) then
                        with TMControl(cinst) do
                          begin
                            _ntext := Text;

                            if (Name = Text) or (Name + #13#10 = Text) then
                              Text := _text;
                          end;

                      cinst.Name := fName;
                    end;
                  end;
              end;
        end;

      if WriteMode then
        TWriter(Filer).WriteBoolean(false);
  finally
    savedprops.Free;
  end;
end;

{------------------------------------------------------------------}

procedure TDCPropStore.SaveToStream(Stream : TStream);
var
  w : TWriter;
begin
  w := TMWriter.Create(Stream, 4096, nil);
  try
    w.IgnoreChildren := true;
    ProcessAllProps(w, true);
  finally
    w.Free;
  end;
end;

{------------------------------------------------------------------}

procedure TDCPropStore.ReaderError(Reader: TReader; const Message: string; var Handled: Boolean);
begin

  Handled := IgnoreErrors or (MessageBox(0, pchar(Message), PCHar(SErrReadProps),
                       MB_OKCANCEL + MB_ICONSTOP + MB_TASKMODAL) = idOk);

end;

{------------------------------------------------------------------}

procedure TDCPropStore.LoadFromStream(Stream : TStream);
var
  r : TReader;
begin
  r := TReader.Create(Stream, 4096);
  try
    r.OnError := ReaderError;
    ProcessAllProps(r, false);
  finally
    r.Free;
  end;
end;

{------------------------------------------------------------------}

procedure TDCPropStore.Load;
var
  Stream : TMemoryStream;
  size   : integer;
  processed : boolean;
begin
  if Assigned (OnLoadChanges) then
    begin
      processed := false;
      OnLoadChanges(self, processed);
      if processed then
        exit;
    end;

  size := GetRegBufSize(key);
  if size > 0 then
    begin
      Stream := TMemoryStream.Create;
      try
        Stream.SetSize(Size);
        ReadBufFromRegistry(key, Stream.Memory^, Size);
        LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
    end;

  if StorePos  and (Owner is TCustomForm) then
    ReadWinPosFromReg(TCustomForm(Owner), key{TCustomForm(Owner).name});
end;

{------------------------------------------------------------------}

procedure TDCPropStore.Save;
var
  Stream : TMemoryStream;
  processed : boolean;
begin
  if Assigned (OnSaveChanges) then
    begin
      processed := false;
      OnSaveChanges(self, processed);
      if processed then
        exit;
    end;

  Stream := TMemoryStream.Create;
  try
    SaveToStream(Stream);
    WriteBufToRegistry(key, Stream.Memory^, Stream.Size);
    if StorePos  and (Owner is TCustomForm) then
      WriteWinPosToReg(TCustomForm(Owner), key {+ TCustomForm(Owner).name});

  finally
    Stream.Free;
  end;
end;

{------------------------------------------------------------------}

function  TDCPropStore.GetKey : string;
begin
  if fKey = '' then
    result := Owner.Name + Name
  else
    result := fKey;
end;

{--------TDCTabControl---------------------------------------------------}


function TDCTabControl.IsContainedControl: Boolean;
var
  Control: TControl;
begin
  Control:= GetParentForm(Self).ActiveControl;
  while (Control <> nil) and (Control <> Self) do
    Control := Control.Parent;
  Result := Control <> nil;
end;

{------------------------------------------------------------------}

procedure TDCTabControl.CMDialogKey(var Message: TCMDialogKey);
var
  ShiftState: TShiftState;
begin
  with Message do
  begin
    ShiftState := KeyDataToShiftState(KeyData);
    if (CharCode = VK_TAB) and (ssCtrl in ShiftState) and IsContainedControl then
    begin
      ChangeTab(Self,not(ssShift in ShiftState));
      Change;
      result := 1;
    end
    else
      inherited;
  end;
end;

{------------------------------------------------------------------}

function  TCompFiler.EventNameByID (ID : integer) : string;
var
  index : integer;
begin
  index := FEventNames.IndexOfObject(TObject(ID));
  if index >= 0 then
    result := FEventNames[index]
  else
    result := '';
end;

{------------------------------------------------------------------}

procedure TCompFiler.CreateMethodTable(S:TStream; OldTable : PMethodTable);
Var
  i    : Integer;
  pdef : PMethodDef;
  oldsize : integer;
begin
  if OldTable <> nil then
    oldsize := OldTable^.Size
  else
    oldsize := 0;

  WriteWord(S, oldsize + fEventNames.Count);

  For i:=0 to FEventNames.Count-1 do
    begin
      WriteWord(S,Length(FEventNames[i]) + sizeof(word) + sizeof(integer) + 1);
      WriteInt(S,Integer(FEventNames.Objects[i]));
      WriteShortStr(S,FEventNames[i]);
    end;

  if OldSize > 0 then
    begin
      pdef := PMethodDef(pchar(OldTable) + 2);

      for i := 0 to OldSize - 1 do
        begin
          S.Write(pdef^, pdef^.size);
          pdef := PMethodDef(pchar(pdef) + pdef^.size);
        end;
    end;
end;

{------------------------------------------------------------------}

procedure TCompFiler.BeginClassNameTrick(OwnerControl:TComponent);
begin
  if OwnerControl = nil then
    exit;

  _OldClassNamePtr := ClassNamePtr(OwnerControl.ClassType);
  _ClassNameStr := 'T' + OwnerControl.Name;
  SetClassNamePtr(OwnerControl.ClassType, @_ClassNameStr);
end;

{------------------------------------------------------------------}

procedure TCompFiler.EndClassNameTrick(OwnerControl:TComponent);
begin
  if OwnerControl <> nil then
    SetClassNamePtr(OwnerControl.ClassType, _OldClassNamePtr);
end;

{------------------------------------------------------------------}

procedure TCompFiler.BeginTrick(OwnerControl:TComponent;SkipMethodsWrite:boolean);
begin
  BeginMethodTrick(OwnerControl,SkipMethodsWrite);
  BeginClassNameTrick(OwnerControl);
end;

{------------------------------------------------------------------}

procedure TCompFiler.EndTrick(OwnerControl:TComponent);
begin
  EndClassNameTrick(OwnerControl);
  EndMethodTrick(OwnerControl);
end;

{------------------------------------------------------------------}

procedure TCompFiler.BeginMethodTrick(OwnerControl:TComponent;SkipMethodsWrite:boolean);
begin
  if OwnerControl = nil then
   exit;

  if fEventNames.Count > 0 then
    begin
      _OldTable := MethodTable(OwnerControl.ClassType);
      _S := TMemoryStream.Create;
      CreateMethodTable(_S, _OldTable);
      if not SkipMethodsWrite then
        SetMethodTable(OwnerControl.ClassType,_S.Memory);
    end
  else
    _OldTable := nil;
end;

{------------------------------------------------------------------}

procedure TCompFiler.EndMethodTrick(OwnerControl:TComponent);
begin
  if OwnerControl = nil then
   exit;

  if _OldTable <> nil then
    begin
      SetMethodTable(OwnerControl.ClassType, _OldTable);
      FreeObject(_S);
    end;
end;

{------------------------------------------------------------------}

type
  TMForm = class(TCustomForm);

procedure CallCompOnCreate(Comp:TComponent);
begin
  try
    if Comp is TDataModule then
      begin
        with TDataModule(Comp) do
          if Assigned(OnCreate) then
            OnCreate(Comp);
      end
    else
      if Comp is TCustomForm then
        with TMForm(Comp) do
          if Assigned(OnCreate) then
            OnCreate(Comp);
  except
    Application.HandleException(Comp);
  end;
end;

{------------------------------------------------------------------}

function TCompFiler.CreateFromFile(const FileName : TFileName;ModuleClass : TComponentClass; SetDesigning:boolean):TComponent;
var
  FileStream : TFileStream;
begin
  FileStream := TFileStream.Create(FileName, DefaultOpenMode);
  try
    result := CreateFromStream(FileStream, ModuleClass, SetDesigning);
  finally
    FileStream.Free;
  end;
end;

{------------------------------------------------------------------}

function TCompFiler.GlobalFindCompWithoutDesigned(const Name: string): TComponent;

  function CompIsOK(comp : TComponent) : boolean;
  begin
    result := not (csDesigning in comp.ComponentState) and (CompareText(Name, comp.Name) = 0);
  end;

var
  i : integer;

begin
  for i := 0 to ScreenFormCount - 1 do
    begin
      Result := ScreenForms(i);
      if CompIsOK(result) then
        exit;
    end;

  for i := 0 to Screen.DataModuleCount - 1 do
    begin
      Result := Screen.DataModules[I];
      if CompIsOK(result) then
        exit;
    end;

  Result := nil;
end;

{------------------------------------------------------------------}

function TCompFiler.CreateFromStream(S : TStream; ModuleClass : TComponentClass; SetDesigning : boolean) : TComponent;
var
  Hooked : boolean;
begin
  if StreamContainsDataModule(S) then
    Result := CreateDataModuleWithClass(ModuleClass)
  else
    Result := CreateFormWithClass(ModuleClass);

  if Result is TCustomForm then
    TForm(Result).FormStyle := NewFormStyle;
    
  if SetDesigning then
    SetDesign(Result, true);

  try
    if fIgnoreDesignedForms then
      Hooked := SetFindGlobalCompProc(GlobalFindCompWithoutDesigned)
    else
      Hooked := false;
    try
      Result.Name:=LoadFromStream(S,Result);
    finally
      if Hooked then
        RemoveFindGlobalCompProc;
    end;
  except
    FreeObject(Result);
    raise;
  end;

  CompLoaded;
end;

{------------------------------------------------------------------}

function TCompFiler.AddEvent(Const EvName:String):Integer;
begin
  With FEventNames do
  begin
    Result:=IndexOf(EvName);
    If Result>=0 then
    begin
      Result:=integer(Objects[Result]);
      exit;
    end;
    AddObject(EvName, pointer(fEventID));
  end;
  result := fEventID;
  inc(fEventID);
end;

{------------------------------------------------------------------}

procedure TCompFiler.ReaderOnMethod(Reader: TReader; const MethodName: string;
    var Address: Pointer; var Error: Boolean);
begin
  if Error then
    begin
      Error:=False;
      Address:=Pointer(AddEvent(MethodName));
    end;  
end;

{------------------------------------------------------------------}

procedure TCompFiler.ReaderError(Reader: TReader; const Message: string; var Handled: Boolean);
begin
  if Assigned(fOnReaderError) then
    begin
      fOnReaderError(Reader, Message, Handled);
      exit;
    end;

  FFilerErrors:=True;
  Handled:=HandledAll;
  If not Handled  and  Assigned(ReaderErrorHandler) then
    ReaderErrorHandler(Message, Handled , HandledAll);
end;

{--------------------------------------------}

procedure TCompFiler.Assign(Source : TCompFiler);
begin
  if Source <> nil then
    begin
      fEventID := Source.fEventID;
      fEventNames.Assign(Source.fEventNames);
    end;
end;

{--------------------------------------------}

constructor TCompFiler.Create;
begin
  inherited;
  fEventID := 1;
  FEventNames:=TStringList.Create;
  FFixList:=TStringList.Create;
end;

{--------------------------------------------}

destructor TCompFiler.Destroy;
begin
  FEventNames.Free;
  FFixList.Free;
  inherited;
end;

{--------------------------------------------}

procedure TCompFiler.SaveToStream(FormStream:TStream;Instance : TComponent);
begin
  If Instance<>Nil Then
  Begin
    BeginTrick(Instance, false);
    try
      FormStream.WriteComponentRes('T'+Instance.Name, Instance)
    finally
      EndTrick(Instance);
    end;
  End; 
end;

{--------------------------------------------}

procedure TCompFiler.LoadFromFile(const FileName : TFileName; Instance : TComponent);
var
  FileStream : TFileStream;
begin
  FileStream := TFileStream.Create(FileName, DefaultOpenMode);
  try
    LoadFromStream(FileStream, Instance);
  finally
    FileStream.Free;
  end;
end;

{--------------------------------------------}

procedure TCompFiler.SaveToFile(const FileName : TFileName; Instance : TComponent);
var
  FileStream : TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(FileStream, Instance);
  finally
    FileStream.Free;
  end;
end;

{--------------------------------------------}

function TCompFiler.LoadFromStream(FormStream:TStream;Instance : TComponent):String;

var
  memstream : TMemoryStream;
begin
  if isTextStream(FormStream) then
    begin
      MemStream := TMemoryStream.Create;
      try
        ObjectTextToBinary(FormStream, MemStream);
        MemStream.Seek(0, 0);
        result := DoLoadFromStream(MemStream, Instance)
      finally
        MemStream.Free;
      end
    end
  else
    result := DoLoadFromStream(FormStream, Instance);
end;

{--------------------------------------------}

function TCompFiler.DoLoadFromStream(FormStream:TStream;Instance : TComponent):String;
var
  FPosition:Integer;
  I: Integer;
  Flags: TFilerFlags;
begin
  FEventID:=1;
  FEventNames.Clear;
  HandledAll:=False;
  FFilerErrors:=False;
  with TReader.Create(FormStream, 4096) do
  try
    SmartSkipResHeader(FormStream,False);
    FPosition:=Position;
//--- read form name here
    ReadSignature;
    ReadPrefix(Flags, I);
    ReadStr; { Ignore class name }
    Result :=ReadStr;
//---
    Position:=FPosition;

    OnError := ReaderError;
    OnFindMethod:=ReaderOnMethod;
    ReadRootComponent(Instance);
  finally
    Free;
  end;
  CompLoaded;
end;

{------------------------------------------------------------------}

procedure TCompFiler.CompLoaded;
begin
  if Assigned(OnAfterLoad) then
    OnAfterLoad(self);
end;

{******************************************************************}

procedure TDCSpeedButton.GlyphChanged(Sender : TObject);
begin
  if Assigned(fOldOnChange) then
    fOldOnChange(Sender);
  Glyph.FreeImage;
  Glyph.Dormant;
end;

{-------------------------------------------------------------------------}

constructor TDCSpeedButton.Create(AOwner : TComponent);
begin
  inherited;
  fOldOnChange := Glyph.OnChange;
  Glyph.OnChange := GlyphChanged;
end;

{$ENDIF WIN}
type
  TDComponent = class(TComponent)
  end;

procedure SetDesign(F:TComponent; Value:Boolean);
begin
  TDComponent(F).SetDesigning(Value);
end;

{------------------------------------------------------------------}

const
  StandardPropCount = 5;
  StandardProps : array[1 .. StandardPropCount] of string = ('Left','Top', 'Width', 'Height', 'OldCreateOrder'); //don't resource

function _StreamContainsDataModule(S : TStream) : boolean;
var
  savepos : integer;
  i       : Integer;
  flags   : TFilerFlags;
  propname : string;
  isstandard : boolean;
begin
  savepos := S.Position;
  try
    SmartSkipResHeader(S,False);
    with TReader.Create(S, 64) do
      try
        ReadSignature;
        ReadPrefix(flags, i);
        ReadStr; // Class Name
        ReadStr; // Comp Name
        while not EndOfList do
          begin
            propname := ReadStr;
            isstandard := false;
            if pos('On',propname) = 1 then //don't resource
              begin
                ReadIdent;
                continue;
              end;

            for i := 1 to StandardPropCount do
              if CompareText(propname, StandardProps[i]) = 0 then
                begin
                  isstandard := true;
                  break;
                end;

            if isstandard then
              if CompareText(propname, 'OldCreateOrder') = 0 then //don't resource
                ReadBoolean
              else
                ReadInteger
            else
              begin
                result := false;
                exit;
              end;
          end;
        result := EndOfList;
      finally
        Free;
      end;
  finally
    S.Position := savepos;
  end;
end;

{-------------------------------------------------------------------------}

function StreamContainsDataModule(S : TStream) : boolean;
var
  memstream : TMemoryStream;
  savepos : integer;
begin
  if isTextStream(S) then
    begin
      MemStream := TMemoryStream.Create;
      savepos := S.Position;
      try
        ObjectTextToBinary(S, MemStream);
        MemStream.Seek(0, 0);
        result := _StreamContainsDataModule(MemStream)
      finally
        S.Position := savepos;
        MemStream.Free;
      end
    end
  else
    result := _StreamContainsDataModule(S);
end;

{------------------------------------------------------------------}

function GetModulePath(Module:HModule):String;
begin
  SetLength(Result,1024);
  Setlength(Result,GetModuleFileName(Module,@Result[1],1023));
end;

{------------------------------------------------------------------}

procedure GetLoadedPackagesPaths(Strings:TStrings);
Var
  List:TList;
  i:Integer;
  Path:String;
begin
  List:=TList.Create;
  try
    ModulesToList(List);
    With Strings do
    begin
      BeginUpdate;
      Clear;
      for i:=0 to List.Count-1 do
      begin
        Path:=GetModulePath(Integer(List[i]));
        If FileIsPackage(Path) then
          Add(Path);
      end;
      EndUpdate;
    end;
  finally
    List.Free;
  end;
end;

{------------------------------------------------------------------}

{$IFDEF D3}
function ModulesToListFunc(HInstance: Longint; Data: Pointer): Boolean;
begin
  Result:=True;
  TList(Data).Add(Pointer(HInstance));
end;
{$ENDIF}

{------------------------------------------------------------------}

procedure ModulesToList(List:TList);
begin
  List.Clear;
  {$IFDEF D3}
  EnumModules(ModulesToListFunc,List);
  {$ELSE}
  List.Add(Pointer(HInstance));
  {$ENDIF}
end;

{------------------------------------------------------------------}

procedure ResModulesToList(List:TList);
begin
  List.Clear;
  {$IFDEF D3}
  EnumResourceModules(ModulesToListFunc,List);
  {$ELSE}
  List.Add(Pointer(HInstance));
  {$ENDIF}
end;

{------------------------------------------------------------------}

function CheckFileExt(const FileName,FileExt:String):boolean;
begin
  Result:=CompareText(RemoveCharSet(['.'],ExtractFileExt(FileName)),
    RemoveCharSet(['.'],FileExt))=0;
end;

{------------------------------------------------------------------}

function FileIsPackage(const FileName:String):boolean;
begin
  Result:=CheckFileExt(FileName,'BPL') or CheckFileExt(FileName,'DPL'); //don't resource
end;

{------------------------------------------------------------------}

procedure MovePages(Source, Dest : TPageControl);
begin
  while Source.PageCount > 0 do
    Source.Pages[0].PageControl := Dest;
end;

{------------------------------------------------------------------}

var
  _OptionFormClasses : TStringList;

function OptionFormClasses : TStringList;
begin
  if _OptionFormClasses = nil then
    _OptionFormClasses := CreateSortedStringList;

  result := _OptionFormClasses;
end;

{------------------------------------------------------------------}

var
  _OptionFormCaptions : TStringList;

function OptionFormCaptions : TStringList;
begin
  if _OptionFormCaptions = nil then
    _OptionFormCaptions := TStringList.Create;

  result := _OptionFormCaptions;
end;

{------------------------------------------------------------------}

{$IFDEF WIN}
function GetOptionsFormCaption(OptionsFormClass : TCustomFormClass) : string;
var
  i : integer;
begin
  with OptionFormCaptions do
    begin
      i := IndexOfObject(TObject(OptionsFormClass));
      result := '';
      if i >= 0 then
        result := OptionFormCaptions[i];
    end;
end;

{------------------------------------------------------------------}

procedure RegisterOptionsFormOrder(OptionsFormClass : TCustomFormClass; Order : integer; const ACaption : string);
var
  ostring : string;
begin
  Str(Order : 5, ostring);
  OptionFormClasses.AddObject(ostring, TObject(OptionsFormClass));
  OptionFormCaptions.AddObject(ACaption, TObject(OptionsFormClass));
end;

{------------------------------------------------------------------}

procedure UnregisterOptionsForm(OptionsFormClass : TCustomFormClass);
var
  i : integer;
begin
  if _OptionFormClasses <> nil then
    with _OptionFormClasses do
      begin
        i := IndexOfObject(TObject(OptionsFormClass));
        if i >= 0 then
          begin
            Delete(i);
            i := OptionFormCaptions.IndexOfObject(TObject(OptionsFormClass));
            if i >= 0 then
              OptionFormCaptions.Delete(i);
          end;
      end;
end;

{------------------------------------------------------------------}

procedure RegisterOptionsForm(OptionsFormClass : TCustomFormClass; const ACaption : string);
begin
  RegisterOptionsFormOrder(OptionsFormClass, -1, ACaption);
end;

{------------------------------------------------------------------}

procedure SetFlatPropToAll(Owner:TComponent;Value:boolean);
Var
  i:Integer;
begin
  With Owner do
    for i:=0 to ComponentCount-1 do
      If Components[i] is TSpeedButton then
        SetFlatProp([TSpeedButton(Components[i])],Value);
end;

{--------------------------------------------}

procedure SetFlatProp(const Ctrls:Array of TSpeedButton;V:Boolean);
{$IFDEF D3}
var
   i:integer;
begin
  for i:= Low(Ctrls) to High(Ctrls) do
    Ctrls[i].flat:=V;
end;
{$ELSE}
begin
end;
{$ENDIF}

{-------------------------------------------------------------------------}

procedure CreateBrushPatternEx(Bitmap: TBitmap; Color1, Color2: TColor);
var
  X, Y: Integer;
begin
  if Bitmap = nil then
    exit;
  with Bitmap, Canvas do
  begin
    Width := 8;
    Height := 8;
    Brush.Style := bsSolid;
    Brush.Color := Color1;
    FillRect(Rect(0, 0, Width, Height));
    for Y := 0 to 7 do
      for X := 0 to 7 do
        if (Y mod 2) = (X mod 2) then
          Pixels[X, Y] := Color2;
  end;
end;

{-----------------------------------------------------------}

procedure CreateBrushPattern(Bitmap: TBitmap);
begin
  CreateBrushPatternEx(Bitmap, clBtnFace, clBtnHighlight);
end;

{-----------------------------------------------------------}

procedure DrawImage(Canvas: TCanvas; Image: TPersistent; Color: TColor;
  const ARect: TRect; ImageIndex: integer);
var
  Bitmap: TBitmap;
begin
  if not ((Image is TImageList) or (Image is TBitmap)) then
    Exit;
  Bitmap := TBitmap.Create;
  try
    Bitmap.Width := ARect.Right - ARect.Left;
    Bitmap.Height := ARect.Bottom - ARect.Top;
    Bitmap.Canvas.Brush.Color := Color;
    Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
    if Image is TImageList then
      TImageList(Image).Draw(Bitmap.Canvas, 0, 0, ImageIndex)
    else if not TBitmap(Image).Empty then
      StretchBltTransparent(Bitmap.Canvas.Handle,
        0, 0, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
        TBitmap(Image).Canvas.Handle, 0, 0, TBitmap(Image).Width,
        TBitmap(Image).Height, TBitmap(Image).Canvas.Pixels[0, 0]);
    Canvas.Draw(ARect.Left, ARect.Top, Bitmap);
  finally
    Bitmap.Free;
  end;
end;

{---------------------------------------------------------}

procedure StretchBltTransparent(DestDC: THandle; DestLeft, DestTop, DestWidth, DestHeight: Integer;
  SourceDC: THandle; SourceLeft, SourceTop, SourceWidth, SourceHeight: Integer; TransColor: TColor);
var
  ScreenDC: THandle;
  hMaskBitmap: THandle;
  MaskDC: THandle;
  OldBkColor: TColorRef;
  OldTextColor: TColorRef;
  OldBmp:THandle;
begin
  ScreenDC := GetDC(0);
  MaskDC := CreateCompatibleDC(ScreenDC);
  ReleaseDC(0, ScreenDC);

  hMaskBitmap := CreateCompatibleBitmap(MaskDC, DestWidth, DestHeight);
  OldBmp:=SelectObject(MaskDC, hMaskBitmap);
  OldBkColor := SetBkColor(SourceDC, ColorToRgb(TransColor));
  BitBlt(MaskDC, 0, 0, DestWidth, DestHeight, SourceDC, SourceLeft, SourceTop, SRCCOPY);
  SetBkColor(SourceDC, OldBkColor);

  OldBkColor := SetBkColor(DestDC, Rgb(255, 255, 255));
  OldTextColor := SetTextColor(DestDC, 0);
  StretchBlt(DestDC, DestLeft, DestTop, DestWidth, DestHeight, SourceDC, SourceLeft, SourceTop,
    SourceWidth, SourceHeight, SRCINVERT);
  BitBlt(DestDC, DestLeft, DestTop, DestWidth, DestHeight, MaskDC, 0, 0, SRCAND);
  StretchBlt(DestDC, DestLeft, DestTop, DestWidth, DestHeight, SourceDC, SourceLeft, SourceTop,
    SourceWidth, SourceHeight, SRCINVERT);
  SelectObject(MaskDC, OldBmp);
  SetBkColor(DestDC, OldBkColor);
  SetTextColor(DestDC, OldTextColor);
  DeleteObject(hMaskBitmap);
  DeleteDC(MaskDC);
end;
{$ENDIF WIN}
{$IFDEF D4}

procedure SafeRegisterActions(const CategoryName: string; const AClasses: array of TBasicActionClass; Resource: TComponentClass);
begin
  if Assigned(RegisterActionsProc) then
    RegisterActions(CategoryName, AClasses, Resource);
end;
{$ENDIF}

Procedure Register;
Begin
{$IFDEF WIN}
  RegisterComponents(SPalDream,[TDCPropStore,TDCTabControl,TDCSpeedButton]);
{$ENDIF}
End;

initialization

finalization
  _OptionFormClasses.Free;
  _OptionFormCaptions.Free;
end.
