{**************************************************}
{                                                  }
{              Common functions                    }
{                                                  }
{  Copyright (c) 1997-2000 Dream Company           }
{  http://www.dream-com.com                        }
{  e-mail: contact@dream-com.com                   }
{                                                  }
{**************************************************}
{ Search for:

  globproc  for section of global procedures and methods declaration
  globvar   for global variables declaration
  typedec   for types declaration
  consts    for consts declaration
  msgconst  for message constants
}

unit DCGen;
{$I dc.inc}

interface
uses
  dcsystem, dccommon, consts, Registry, SysUtils, Windows, Controls, Messages, Forms, Classes, StdCtrls,
  extctrls,
  dsgnintf,
  TypInfo, shellapi, comctrls, dialogs, graphics, clipbrd, menus,
  dcvcllib, dclib, dcapi, rerrdlg, dcVarPropEd,
  {$IFNDEF SHELLOBJ}
  filectrl,
  {$ENDIF}
  {$IFDEF D4}actnlist, imglist, {$ENDIF}
  {olectrls,} commctrl, buttons, dcconsts, {$IFDEF DEBUG}dcdebug, {$ENDIF}
  {$IFDEF D3}
  activex, oleconst;
{$ELSE}
  ole2, oleauto, olectl;
{$ENDIF}

// consts
// --------------------------- constant declarations ------------------------
{$IFNDEF CPB3}
const
  WHEEL_DELTA = 120;
  {$ENDIF}

  {$IFNDEF D3}
const
  SPI_GETWHEELSCROLLLINES = 104;
  SPI_SETWHEELSCROLLLINES = 105;

  WM_MOUSEWHEEL = $020A;
  {$ENDIF}

const
  TSOBJECTCHANGED = 1;
  TSREFRESH = 2;
  TSDELETE = 3;
  TSSELCHANGED = 4;
  TSSELEXPANDED = 6;
  TSINSERT = 7;
  TSMOVETO = 9;

  acCanHaveChild = 0;
  acCanClear = 1;
  acCanDelete = 2;
  acCanAdd = 3;
  acCanAddChild = 4;
  acShowModal = 5;
  acMultiSelect = 6;
  acShowLines = 7;
  acShowToolBar = 8;
  acCanDrag = 9;
  acCanEdit = 10;
  acShowPopup = 11;
  acShowSourceinPopup = 12;
  acSelectInspector = 13;
  acRefreshDelete = 14;
  acShowTreeview = 15;
  acShowListView = 16;

  acUser = 100;

  SVerbCfgPackagesActivex = 'View.PackagesActiveX'; //don't resource
  SVerbCfgPackages = 'View.PackagesConfig'; //don't resource

  // typedec
  // --------------------------- types declarations ------------------------
type
  TAppExceptionObject = class
    procedure ExceptionEvent(Sender: TObject; E: Exception); virtual;
    constructor Create;
  end;

  { Font size property editor. Adds drop down list with list of different
    font sizes to standart font size property editor
    We register this property editor in Delphi also.}
  TFontSizePropEdit = class(TIntegerProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  {$IFDEF D4}
  TDCIDEAction = class(TCustomAction)
  private
    FVerbGetState: TGetVerbStateProc;
    FVerbExecute: TExecuteVerbProc;
    FDesignGroup: Integer;
    FVerbName: string;
    procedure SetVerbName(const V: string);
    procedure UpdateVerbObject;
  protected
  public
    function Execute: boolean; override;
    function Update: boolean; override;
  published

    property Caption;
    property Checked;
    property Enabled;
    property HelpContext;
    property Hint;
    property ImageIndex;
    property ShortCut;
    property Visible;

    property VerbName: string read FVerbName write SetVerbName;
  end;

  {$ENDIF}

  TPropChangeProc = procedure(Objects: TList) of object;

type
  TTreeSource = class;

  PNodeRec = ^TNodeRec;
  TNodeRec = record
    ObjId: integer;
    RootId: integer;
    DestId: integer;
    Caption: string;
    ImageIndex: integer;
    SelectedIndex: Integer;
    StateIndex: integer;
    OverlayIndex: integer;
    Data: Pointer;
    TreeSource: TTreeSource;
    InsertType: TNodeAttachMode;
    FontColor: TColor;
    FontStyle: TFontStyles;
  end;

  TIteratorProc = procedure(const NodeRec: TNodeRec) of object;

  TActionCode = integer;

  TTreeSource = class(TComponent)
  protected
    procedure SetSelectedObject(value: integer); virtual; abstract;
    procedure SetTreeLink(Value: TPersistent); virtual; abstract;
    procedure ObjectInserted(ObjId: integer); virtual; abstract;
    function GetLargeImages: TCustomImageList; virtual; abstract;
    function GetSmallImages: TCustomImageList; virtual; abstract;
    function GetStateImages: TCustomImageList; virtual; abstract;
    procedure SetLargeImages(Value: TCustomImageList); virtual; abstract;
    procedure SetSmallImages(Value: TCustomImageList); virtual; abstract;
    procedure SetStateImages(Value: TCustomImageList); virtual; abstract;
    function GetSelectedObject: integer; virtual; abstract;
    function GetTreeLink: TPersistent; virtual; abstract;
  public
    procedure GetItems(ObjID: Integer; Iterator: TIteratorProc); virtual; abstract;
    procedure SetCaption(ObjID: Integer; const Caption: string); virtual; abstract;
    procedure Add(ObjID: Integer; const Caption: string; InsertType: TNodeAttachMode); virtual; abstract;
    procedure Clear; virtual; abstract;
    procedure Delete(ObjID: Integer); virtual; abstract;
    function CanMove(ObjId, DestId: Integer; InsertType: TNodeAttachMode): boolean; virtual; abstract;
    procedure MoveTo(ObjId, DestId: Integer; InsertType: TNodeAttachMode); virtual; abstract;
    procedure BeginUpdate; virtual; abstract;
    procedure EndUpdate; virtual; abstract;
    function GetInspectorControl(ObjID: Integer): TPersistent; virtual; abstract;
    function ActionAllowed(ObjId: Integer; Action: TActionCode): Boolean; virtual; abstract;
    function GetDisplayName(ObjID: integer): string; virtual; abstract;
    function GetAttrCount: Integer; virtual; abstract;
    function GetAttrName(Index: Integer): string; virtual; abstract;
    function GetAttrValue(ObjId, Index: Integer): string; virtual; abstract;

    function GetStatusLine(ObjId: Integer): string; virtual; abstract;
    function ValidSource: boolean; virtual; abstract;
    procedure Edit(ObjId: integer); virtual; abstract;
    function GetSortType: TSortType; virtual; abstract;
    function HasChild(objId: integer): boolean; virtual; abstract;
    function GetParentId(ObjId: integer): integer; virtual; abstract;
  end;

  TTreeSourceClass = class of TTreeSource;

  {$IFDEF D4}
  TFormDesigner = IFormDesigner;
  {$ENDIF}

  TDirectoryProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  TMonoSpaceFontNamesProperty = class(TFontNameProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  TMonoFontProperty = class(TFontProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  {------------------------------------------------------------------}

  TDispatchCompEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TNotifierListEx = class(TNotifierList (*{$IFDEF D3},IDCNotifierListEx {$ENDIF}*))
  private
    (*    {$IFDEF D3}
        procedure IDCNotifierListEx.PostNotify=PostMessage;
        procedure IDCNotifierListEx.Notify=NotifyEvents;
        procedure IDCNotifierListEx.RegisterNotifier=AddMethod;
        procedure IDCNotifierListEx.UnRegisterNotifier=DeleteMethod;
        {$ENDIF}  *)
  public
    procedure PostMessage(Msg: Integer; wParam, lParam: Integer);
  end;

  TWrapperInfo = class
    data: TDataModule;
    form: TCustomForm;
  end;

  TTypeToString = function(Designer: TFormDesigner; TypeCode: integer): string;

  {$IFDEF D4}
  IDCFDesigner = interface(IFormDesigner)
    ['{37CFFCE1-1BB2-11D2-B4E3-0000E8DC209E}']
    function GetOwnerControl: TComponent;
    procedure SetOwnerControl(C: TComponent);

    function GetLimitControl: TWinControl;
    procedure SetLimitControl(val: TWinControl);
    function CanBeSelected(Instance: TPersistent): boolean;

    function AllowEdit(Instance: TComponent; const PropName: string): boolean;
    function AllowEditList(Comps: TList; const PropName: string): boolean;

    function AllowPropShow(Instance: TComponent; const PropName: string): boolean;
    function AllowPropShowList(Comps: TList; const PropName: string): boolean;

    function IsSelected(Instance : TPersistent) : boolean;

    property LimitControl: TWinControl read GetLimitControl write SetLimitControl;
    property OwnerControl: TComponent read GetOwnerControl write SetOwnerControl;
  end;
  {$ENDIF}

  {$IFDEF D3}
  IDCInstantFormInit = interface
    ['{D9050E41-FE04-11D2-B668-0000E8DC5099}']
    procedure Init;
  end;
  {$ENDIF}

  TFDesigner = class({$IFDEF D4}TInterfacedObject, IDCFDesigner, {$ENDIF}TFormDesigner)
  private
    fOwnerControl: TComponent;
    fLimitWinControl: TWinControl;
    {$IFDEF D4}
    fform: TCustomForm;
    {$ENDIF}
    fSelection: TList;
    function GetSelection: TList;
    procedure ValidateSelection;
  protected
    procedure SelectionChanged;
    function GetOwnerControl: TComponent; virtual;
    procedure SetOwnerControl(C: TComponent);
    function GetLimitControl: TWinControl;
    procedure SetLimitControl(val: TWinControl);

  public
    constructor Create;
    destructor Destroy; override;
    function CanBeSelected(Instance: TPersistent): boolean; virtual;
    function AllowEdit(Instance: TComponent; const PropName: string): boolean; virtual;
    function AllowEditList(Comps: TList; const PropName: string): boolean;

    function AllowPropShow(Instance: TComponent; const PropName: string): boolean; virtual;
    function AllowPropShowList(Comps: TList; const PropName: string): boolean;

    function IsDesignMsg(Sender: TControl; var Message: TMessage): Boolean;
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure Modified;
    {$IFNDEF D4}override;
    {$ENDIF}
    {$IFNDEF D4}
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    {$ELSE}
    procedure Notification(AnObject: TPersistent; Operation: TOperation);
    {$ENDIF}
    procedure PaintGrid;
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure ValidateRename(AComponent: TComponent; const CurName, NewName: string);
    {$IFNDEF D4}override;
    {$ENDIF}
    function CreateMethod(const Name: string; TypeData: PTypeData): TMethod;
    {$IFNDEF D4}override;
    {$ENDIF}
    function GetMethodName(const Method: TMethod): string;
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure GetMethods(TypeData: PTypeData; Proc: TGetStrProc);
    {$IFNDEF D4}override;
    {$ENDIF}
    function GetPrivateDirectory: string;
    {$IFNDEF D4}override;
    {$ENDIF}
    {$IFNDEF D4}
    procedure GetSelections(List: TComponentList); override;
    procedure SetSelections(List: TComponentList); override;
    {$ELSE}
    procedure GetSelections(const List: IDesignerSelections);
    procedure SetSelections(const List: IDesignerSelections);
    {$ENDIF}
    function MethodExists(const Name: string): Boolean;
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure RenameMethod(const CurName, NewName: string);
    {$IFNDEF D4}override;
    {$ENDIF}
    {$IFDEF D3}
    procedure SelectComponent(Instance: TPersistent);
    {$IFNDEF D4}override;
    {$ENDIF}
    {$ELSE}
    procedure SelectComponent(Component: TComponent); override;
    {$ENDIF}
    procedure ShowMethod(const Name: string);
    {$IFNDEF D4}override;
    {$ENDIF}
    function UniqueName(const BaseName: string): string;
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure GetComponentNames(TypeData: PTypeData; Proc: TGetStrProc);
    {$IFNDEF D4}override;
    {$ENDIF}
    function GetComponent(const Name: string): TComponent;
    {$IFNDEF D4}override;
    {$ENDIF}
    function GetComponentName(Component: TComponent): string;
    {$IFNDEF D4}override;
    {$ENDIF}
    function MethodFromAncestor(const Method: TMethod): Boolean;
    {$IFNDEF D4}override;
    {$ENDIF}
    function CreateComponent(ComponentClass: TComponentClass; Parent: TComponent;
      Left, Top, Width, Height: Integer): TComponent;
    {$IFDEF D4}virtual;
    {$ELSE}override;
    {$ENDIF}
    function IsComponentLinkable(Component: TComponent): Boolean;
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure MakeComponentLinkable(Component: TComponent);
    {$IFNDEF D4}override;
    {$ENDIF}
    function GetRoot: TComponent;
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure Revert(Instance: TPersistent; PropInfo: PPropInfo);
    {$IFNDEF D4}override;
    {$ENDIF}
    {$IFDEF D3}
    function GetObject(const Name: string): TPersistent;
    {$IFNDEF D4}override;
    {$ENDIF}
    function GetObjectName(Instance: TPersistent): string;
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure GetObjectNames(TypeData: PTypeData; Proc: TGetStrProc);
    {$IFNDEF D4}override;
    {$ENDIF}
    function GetIsDormant: Boolean;
    {$IFNDEF D4}override;
    {$ENDIF}
    function HasInterface: Boolean;
    {$IFNDEF D4}override;
    {$ENDIF}
    function HasInterfaceMember(const Name: string): Boolean;
    {$IFNDEF D4}override;
    {$ENDIF}
    {$IFNDEF CPB3}
    procedure AddInterfaceMember(const MemberText: string); override;
    {$ELSE}
    procedure AddToInterface(InvKind: Integer; const Name: string; VT: Word;
      const TypeInfo: string);
    {$IFNDEF D4}override;
    {$ENDIF}
    procedure GetProjectModules(Proc: TGetModuleProc);
    {$IFNDEF D4}override;
    {$ENDIF}
    {$ENDIF}
    {$ENDIF}
    {$IFDEF D4}
    function GetCustomForm: TCustomForm;
    procedure SetCustomForm(Value: TCustomForm);
    function GetIsControl: Boolean;
    procedure SetIsControl(Value: Boolean);

    function GetAncestorDesigner: IFormDesigner;
    function IsSourceReadOnly: Boolean;

    property Form: TCustomForm read GetCustomForm write SetCustomForm;
    {$ENDIF}

    {$IFDEF D5}
    function GetContainerWindow: TWinControl;
    procedure SetContainerWindow(const NewContainer: TWinControl);
    function GetScrollRanges(const ScrollPosition: TPoint): TPoint;
    procedure Edit(const Component: IComponent);
    function BuildLocalMenu(Base: TPopupMenu; Filter: TLocalMenuFilters): TPopupMenu;
    procedure ChainCall(const MethodName, InstanceName, InstanceMethod: string;
      TypeData: PTypeData);

    function CanPaste: Boolean;
    procedure CopySelection; virtual;
    procedure CutSelection; virtual;
    procedure PasteSelection; virtual;
    procedure DeleteSelection; virtual;
    procedure ClearSelection; virtual;

    procedure NoSelection;
    procedure ModuleFileNames(var ImplFileName, IntfFileName, FormFileName: string);
    function GetRootClassName: string;
    {$ENDIF}

    function IsSelected(Instance : TPersistent) : boolean;

    property LimitControl: TWinControl read GetLimitControl write SetLimitControl;
    property OwnerControl: TComponent read GetOwnerControl write SetOwnerControl;
    property Selection: TList read GetSelection;
  end;

  {$IFNDEF D4}
  IDCFDesigner = TFDesigner;
  {$ENDIF}
  TActionEditor = class(TDefaultEditor)
  public
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerbCount: Integer; override;
  end;

  TDesignerList = class(TList)
  private
    function GetDesigner(index: integer): TFDesigner;
  public
    property Designers[index: Integer]: TFDesigner read GetDesigner; default;
  end;

  TActionCallType = (ctPropName, ctActionProc);

  TActionListItem = class(TPackagedCollectionItem)
  private
    { Text name of action (e.g. 'Show Object Inspector') }
    FActionName: string;

    { The class of objects specified in RegisterVisualProperty or
      RegisterComponentAction}
    FObjClass: TClass;

    { Procedure that is called when user select correspondent menu item.
      Used when CallType = ctActionProc
    }
    FActionProc: TActionProc;

    { The name of property for calling the property editor.
      Used when CallType = ctPropName
    }
    FPropName: string;

    {
     if CallType is ctPropName then for Property Editor will be created and
     used for editing otherwise ActionProc will be called
    }
    FCallType: TActionCallType;
  public
    property ActionName: string read FActionName write FActionName;
    property ObjClass: TClass read FObjClass write FObjClass;
    property ActionProc: TActionProc read FActionProc write FActionProc;
    property PropName: string read FPropName write FPropName;
    property CallType: TActionCallType read FCallType write FCallType;
  end;

  TActionsList = class(TPackagedCollection)
  public
    {Returns ActionListItem for given component. AIndex should be from 0 to
     GetVerbCount(AComp) - 1}
    function GetActionItem(AComp: TPersistent; AIndex: Integer): TCollectionItem;

    {
     GetVerb returns the string that corresponds to the specified position of the
     component’s context menu.
    }
    function GetVerb(AComp: TPersistent; AIndex: Integer): string;

    {
    ExecuteVerb performs the action of a specified verb.
    }
    procedure ExecuteVerb(AComp: TPersistent; AIndex: Integer);

    {
     Returns the number of actions registered for given component.
     @param AComp Component
    }
    function GetVerbCount(AComp: TPersistent): Integer;

    { Same as dcgen.RegisterComponentAction
      @see RegisterComponentAction}
    procedure RegisterComponentAction(const AActionName: string; AObjClass: TPersistentClass;
      AActionProc: TActionProc);

    { Same as dcgen.RegisterVisualProperty
      @see RegisterVisualProperty}
    procedure RegisterVisualProperty(const AActionName: string; AObjClass: TPersistentClass;
      const APropName: string);
  end;

  {------------------------------------------------------------------}

  TAxControlInfo = class(TCollectionItem)
  public
    guid: TGUID;
    name: string;
    picturefile: string;
    pictureindex: integer;
    inprocserver: string;
    hint: string;
    typelib: TGUID;
  end;

  TDCApplication = class
  private
    FActionList: TActionsList;
    FGUIDS: TStrings;

    procedure SaveActiveXConfig;
    function GetActionList: TActionsList;
    function GetGUIDS: TStrings;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function ActiveXRegistered(GUID: TGUID): boolean;
    procedure RegisterActiveX(AxInfo: TAxControlInfo);
    procedure UnRegisterActiveX(AxInfo: TAxControlInfo);

    { Collection of registered with RegisterVisualProperty Visual properties.}
    property ActionList: TActionsList read GetActionList;
    property GUIDS: TStrings read GetGUIDS;
  end;

  TAxControlCollection = class(TCollection)
  public
    constructor Create;
    procedure LoadRegisteredControls;
    function ItemByGUID(AGUID: TGUID): TAxControlInfo;
    procedure GetActiveXNames(S: TStrings);
  end;

  //=========================================================================
  // globproc
  // ------------------------ global procedures and functions ------------------

  //Graphics_procedures
  //registration_routines
  //forms_handling
  //designer_procedures
  //data_modules_support
  //tabs_support
  //image_list_handling
  //URL_procedures
  //Menu_handling
  //TStream_handling
  //notification_procs
  //DCEdit_registration

function CopyFileList(FileList: TStrings): boolean;
function DeleteFolder(const Folder: string): boolean;
function DirectoryExists(const Name: string): Boolean;

function GetPropertyEditor(Instance: TPersistent; const PropName: string;
  var ParentEditor: TPropertyEditor): TPropertyEditor;

procedure BeginControlUpdate(AControl: TWinControl);
procedure FinishControlUpdate(AControl: TWinControl);

function CompareVariants(V1, V2: POleVariant): integer;
procedure ShowMessageEx(const M: Variant);
procedure RegisterPropChangesNotifier(Instance: TPersistent; PropChangeProc: TPropChangeProc);
procedure UnRegisterPropChangesNotifier(Instance: TPersistent; PropChangeProc: TPropChangeProc);

function GetStringSize(const S: string; font: HFONT;
  var ascent, descent, overhang: integer): TSize;

function GetSymbolSize(c: char; font: HFONT; var ascent, descent, overhang: integer): TSize;
function GetSymbolWidth(c: char; font: HFONT): integer;
function GetSymbolHeight(c: char; font: HFONT): integer;

function GetWheelScrollLines: integer;

{$IFDEF SHELLOBJ}
function QueryComputer(const ATitle: string; var Computer: string): boolean;
{$ENDIF}

function GetVCLControlFromHWND(handle: THandle): TWinControl;

procedure CorrectMemoText(Memo: TMemo);

function FindResourceInstance(const ResName: string; ResType: PChar): THandle;

function GetTreeNotifiers: TNotifierListEx;

procedure MoveListItem(SourceItem, DestItem: TListItem; InsertType: TNodeAttachMode);

procedure FreePropEditors;

procedure ShowObjectInspector;
procedure HideObjectInspector;
procedure ShowComponentPalette;
procedure HideComponentPalette;
procedure ShowAlignPalette;
procedure HideAlignPalette;
function GetEventDispatchTypeInfo(const OLEObject: IUnknown): ITypeInfo;
function DelphiTypeToString(Designer: TFormDesigner; TypeCode: integer): string;
procedure UpdateLabelsEnabled(F: TCustomForm);
procedure LoadBitmapFromResource(Bitmap: TBitmap; const ResName: string);
procedure LoadUnknownGlyph(Bitmap: TBitmap);
procedure LoadBitmapForClass(Bitmap: TBitmap; AClass: TClass);
function FindObjectBitmapResEx(var H: THandle; C: TClass; const ResNamePrefix: string): string;
function FindObjectBitmapRes(var H: THandle; C: TClass; const ResNamePrefix: string): string;
procedure CallPropertyEditor(C: TPersistent; const APropname: string);

// ----------------------- Graphics_procedures -------------------------

function GetRGBColor(Value: TColor): DWORD;

// ----------------------- registration_routines ----------------------

procedure RegisterTreeSource(ObjClass: TClass; SourceClass: TTreeSourceClass; const EditMethod: string);
procedure RegisterDefaultTreeSource(ObjClass: TClass; SourceClass: TTreeSourceClass; const EditMethod: string);

function GetRegisteredTreeSource(ObjClass: TClass;
  const EditMethod: string): TTreeSourceClass;

procedure RegisterVisualProperty(const AActionName: string; AObjClass: TPersistentClass;
  const APropName: string);
procedure RegisterComponentAction(const ActionName: string; ObjClass: TPersistentClass;
  ActionProc: TActionProc);
function GetClassRegisterPackage(C: TClass): THandle;

// ----------------------- forms_handling ----------------------

procedure CorrectFormFiles(Path: string; SubFolders: boolean);
procedure GetUsedModules(Instance: TComponent; UsedModules: TList);
procedure ShowFormEx(Form: TCustomForm; ShowMode: Integer);
procedure UpdateDisabledControls(AOwner: TComponent);

// ----------------------- designer_procedures  ---------------------

{$IFDEF D5}
type
  TComponentList = TDesignerSelectionList;
  {$ENDIF}

procedure CompListToList(clist: TComponentList; list: TList);
{$IFDEF D4}
procedure IDesignerSelectionsToList(const IList: IDesignerSelections; list: TList);
{$ENDIF}
procedure ListToCompList(list: TList; clist: TComponentList);
procedure DesignerModified(c: TPersistent);
function GetDesigner(c: TPersistent): TFormDesigner;
function DesignerList: TDesignerList;
function IsFDesigner(const D: TFormDesigner): boolean;

procedure ClearComponent(AComponent: TComponent);
function DesignerCanPaste: boolean;

// ----------------------- data_modules_support ---------------------

function CreateDataModule: TDataModule;
function DataModuleWrappers: TList;
function DataModuleByWrapper(AForm: TCustomForm): TDataModule;
function GetDataModuleWrapper(DataModule: TDataModule): TCustomForm;

// ----------------------- tabs_support ---------------------

function CreateNewTabSheet(PageControl: TPageControl): TTabSheet;
procedure SetAllTabsVisible(PageControl: TPageControl; AVisible: Boolean);
procedure SetTabsVisible(PageControl: TPageControl;
  const TabNames: array of string; AVisible: Boolean);
procedure CorrectActiveTab(PageControl: TPageControl);
procedure DeleteTab(TabControl: TTabControl; const TabCaption: string);

// ----------------------- image_list_handling ---------------------

procedure ImageListSaveToFile(ImageList: TCustomImageList; const FileName: string);
function AddBitmapFromResource(ImageList: TCustomImageList; const ResName: string;
  Instance: THandle): Integer;
function AddIconFromAnyResource(ImageList: TCustomImageList; const ResName: string): boolean;
function AddIconFromResource(ImageList: TCustomImageList; const ResName: string;
  Instance: THandle): boolean;

// ------------------------ Menu_handling ---------------------

function IsChildMenu(Item: TMenuItem; Menu: Tmenu): boolean;
function GetControlPopupMenu(c: TControl): TPopupMenu;
procedure CopyPopupMenu(SourceMenu, TargetMenu: TPopupMenu);
procedure MakeComponentPopup(PopupMenu, fmenu: TPopupMenu; fcedit: TComponentEditor);

// ------------------------ TStream_handling ---------------------

function ToolsFormStyle: TFormStyle;

//--------------------- Forms manipulation -------------------------
procedure SetMainForm(AForm: TForm);
//=========================================================================
// consts2
// ------------------------ constants declaration ------------------

//=========================================================================
// globvar
// ------------------------ global variables declaration ------------------

var
  ToolFormsOnTop: boolean = false; // if true then all design time tools form
  // (like Align palette) will be always on top

  HideEventsInInspector: boolean = false;

  App: TDCApplication;
  TypeToString: TTypeToString = DelphiTypeToString;

  //  DesignerPopupMenu:TPopupMenu; // this will be removed!!

  {----------------------------------------------------------}
type
  TFileOperationType = (foCopy, foDelete, foMove, foRename);
  TFileOperationFlag =
    (ffAllowUndo, ffFilesOnly, ffNoConfirmation, ffNoConfirmMkDir, ffNoErrorUI,
    ffRenameCollision, ffSilent, ffSimpleProgress);

  TFileOperationFlags = set of TFileOperationFlag;

  TFileProcessEvent = procedure(Sender: TObject; const S: string; var Handled: boolean) of object;

  TDCFileOperation = class(TComponent)
  private
    FSourceFiles: TStrings;
    FDestFolder: string;
    FProgressTitle: string;
    FOperation: TFileOperationType;
    FOptions: TFileOperationFlags;
    FOnError: TFileProcessEvent;
    FVersion: TDCVersion;
    procedure SetSourceFiles(Value: TStrings);
    function ExecuteOperation(OpType: TFileOperationType): boolean;
    function GetSystemError(AError: integer): string;
  protected
    function Error(const S: string): boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: boolean;
    function Copy: boolean;
    function Delete: boolean;
    function Move: boolean;
    function Rename: boolean;
  published
    property SourceFiles: TStrings read FSourceFiles write SetSourceFiles;
    property DestFolder: string read FDestFolder write FDestFolder;
    property ProgressTitle: string read FProgressTitle write FProgressTitle;
    property Operation: TFileOperationType read FOperation write FOperation;
    property Options: TFileOperationFlags read FOptions write FOptions;
    property OnError: TFileProcessEvent read FOnError write FOnError;
    property Version: TDCVersion read FVersion write FVersion stored false;
  end;

function IsFormModal(AForm: TForm): Boolean;

const
  rtBitmap =
    {$IFDEF D4}
  imglist.rtBitmap;
  {$ELSE}
  controls.rtBitmap;
  {$ENDIF}

implementation
uses
  dcGenReg;

{------------------------------------------------------------------}

procedure ClearComponent(AComponent: TComponent);
begin
  if AComponent = nil then
    exit;

  AComponent.DestroyComponents;
  if AComponent is TWinControl then
    with TWinControl(AComponent) do
      while ControlCount > 0 do
        Controls[0].Free;
end;

{------------------------------------------------------------------}

type
  TGetProp = class
    searchproperty: string;
    pedit: TPropertyEditor;
    seteditor: TPropertyEditor;

    procedure GetPropEdit(Prop: TPropertyEditor);
  end;

procedure TGetProp.GetPropEdit(Prop: TPropertyEditor);
var
  sname: string;
  ppos: integer;
begin
  if pedit <> nil then
  begin
    prop.Free;
    exit;
  end;

  ppos := pos('.', searchproperty);
  if ppos = 0 then
    sname := searchproperty
  else
    sname := copy(searchproperty, 1, ppos - 1);

  if CompareText(Prop.GetName, sname) = 0 then
  begin
    if ppos = 0 then
    begin
      pedit := prop;
      exit;
    end
    else
    begin
      Delete(searchproperty, 1, ppos);
      try
        Prop.GetProperties(GetPropEdit);
      finally
        if Prop is TSetProperty then
          SetEditor := Prop
        else
          Prop.Free;
      end;
    end
  end
  else
    prop.Free;
end;

{******************************************************************}

function GetPropertyEditor(Instance: TPersistent; const PropName: string;
  var ParentEditor: TPropertyEditor): TPropertyEditor;
var
  clist: TComponentList;
  iDesigner: TFormDesigner;
  newdesigner: boolean;
begin
  ParentEditor := nil;
  clist := TComponentList.Create;
  {$IFNDEF D4}
  newdesigner := false;
  idesigner := nil;
  {$ENDIF}

  with TGetProp.Create do
  try
    iDesigner := GetDesigner(Instance);
    newdesigner := iDesigner = nil;

    if newdesigner then
    begin
      iDesigner := TFDesigner.Create;
      (iDesigner as IDCFDesigner).OwnerControl := GetTopOwner(Instance);
    end;

    searchproperty := PropName;
    clist.Add(TComponent(Instance));
    GetComponentProperties(clist, tkAny, iDesigner, GetPropEdit);

    result := pedit;
    ParentEditor := seteditor;
  finally
    {$IFNDEF D4}
    if newdesigner then
      iDesigner.Free;
    {$ENDIF}

    Free;
    clist.Free;
  end;
end;

{------------------------------------------------------------------}

procedure BeginControlUpdate(AControl: TWinControl);
begin
  if AControl.HandleAllocated then
    SendMessage(AControl.Handle, WM_SETREDRAW, 0, 0);
end;

{------------------------------------------------------------------}

procedure FinishControlUpdate(AControl: TWinControl);
begin
  if AControl.HandleAllocated then
  begin
    SendMessage(AControl.Handle, WM_SETREDRAW, 1, 0);
    AControl.Invalidate;
  end;
end;

{------------------------------------------------------------------}

const
  VariantSize = 16;

function CompareVariants(V1, V2: POleVariant): integer;
asm
      push  esi
      push  edi
      mov   esi, v1
      mov   edi, v2
      xor   eax, eax
      mov   ecx, VariantSize
      jcxz  @@quit
      cld
      rep   cmpsb
      mov   ecx, eax
      mov   al, [esi - 1]
      mov   cl, [edi - 1]
      sub   eax, ecx
@@quit:
      pop   edi
      pop   esi
end;

{----------------------------------------------------------}

{$R 'dcgen.res'}

function DelphiTypeToString(Designer: TFormDesigner; TypeCode: integer): string;
begin
  result := ConvertDelphiTypeToString(TypeCode);
end;

{----------------------------------------------------------}

procedure ShowFormEx(Form: TCustomForm; ShowMode: Integer);
var
  OldVisible: boolean;
begin
  if form = nil then
    exit;

  with Form do
  begin
    OldVisible := Visible;
    Show;
    ShowWindow(Handle, ShowMode);
    if csDesigning in ComponentState then
      Visible := OldVisible;
  end;
end;

{-------------------------------------------------------------------------}

var
  fADesignerList: TDesignerList;

  {-------------------------------------------------------------------------}

function DesignerList: TDesignerList;
begin
  if fADesignerList = nil then
    fADesignerList := TDesignerList.Create;

  Result := fADesignerList;
end;

{-------------------------------------------------------------------------}

function TDesignerList.GetDesigner(index: integer): TFDesigner;
begin
  result := TFDesigner(Items[index]);
end;

{-------------------------------------------------------------------------}

type
  TMPersistent = class(TPersistent)
  end;

  {$IFDEF D3}
type
  IEnumGUID = interface;
  IEnumCATEGORYINFO = interface;
  ICatRegister = interface;
  ICatInformation = interface;

  PCATEGORYINFO = ^TCATEGORYINFO;
  TCATEGORYINFO = record
    catid: TGUID;
    lcid: UINT;
    szDescription: array[0..127] of WideChar;
  end;

  IEnumGUID = interface(IUnknown)
    ['{0002E000-0000-0000-C000-000000000046}'] //don't resource
    function Next(celt: UINT; out rgelt: TGUID; out pceltFetched: UINT): HResult; stdcall;
    function Skip(celt: UINT): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumGUID): HResult; stdcall;
  end;

  IEnumCATEGORYINFO = interface(IUnknown)
    ['{0002E011-0000-0000-C000-000000000046}'] //don't resource
    function Next(celt: UINT; out rgelt: TCATEGORYINFO; out pceltFetched: UINT): HResult; stdcall;
    function Skip(celt: UINT): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumCATEGORYINFO): HResult; stdcall;
  end;

  ICatRegister = interface(IUnknown)
    ['{0002E012-0000-0000-C000-000000000046}'] //don't resource
    function RegisterCategories(cCategories: UINT; rgCategoryInfo: PCATEGORYINFO): HResult; stdcall;
    function UnRegisterCategories(cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
    function RegisterClassImplCategories(const rclsid: TGUID; cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
    function UnRegisterClassImplCategories(const rclsid: TGUID; cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
    function RegisterClassReqCategories(const rclsid: TGUID; cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
    function UnRegisterClassReqCategories(const rclsid: TGUID; cCategories: UINT; rgcatid: Pointer): HResult; stdcall;
  end;

  ICatInformation = interface(IUnknown)
    ['{0002E013-0000-0000-C000-000000000046}'] //don't resource
    function EnumCategories(lcid: UINT; out ppenumCategoryInfo: IEnumCATEGORYINFO): HResult; stdcall;
    function GetCategoryDesc(const rcatid: TGUID; lcid: UINT; out pszDesc: PWideChar): HResult; stdcall;
    function EnumClassesOfCategories(cImplemented: UINT; rgcatidImpl: Pointer; cRequired: UINT; rgcatidReq: Pointer; out ppenumClsid: IEnumGUID): HResult; stdcall;
    function IsClassOfCategories(const rclsid: TGUID; cImplemented: UINT; rgcatidImpl: Pointer; cRequired: UINT; rgcatidReq: Pointer): HResult; stdcall;
    function EnumImplCategoriesOfClass(var rclsid: TGUID; out ppenumCatid: IEnumGUID): HResult; stdcall;
    function EnumReqCategoriesOfClass(var rclsid: TGUID; out ppenumCatid: IEnumGUID): HResult; stdcall;
  end;

const
  CLSID_StdComponentCategoryMgr: TGUID = '{0002E005-0000-0000-C000-000000000046}'; //don't resource
  {$ENDIF}

  {----------------------------------------------------------}
  {$IFDEF D4}

procedure IDesignerSelectionsToList(const IList: IDesignerSelections; list: TList);
var
  i: integer;
begin
  list.Clear;
  list.Capacity := IList.Count;
  for i := 0 to IList.Count - 1 do
    list.Add(ExtractPersistent(Ilist[i]));
end;

{$ENDIF}

procedure CompListToList(clist: TComponentList; list: TList);
var
  i: integer;
begin
  list.Clear;
  list.Capacity := clist.Count;
  for i := 0 to clist.Count - 1 do
    list.Add(clist[i]);
end;

{----------------------------------------------------------}

procedure ListToCompList(list: TList; clist: TComponentList);
var
  i: integer;
begin
  for i := 0 to list.Count - 1 do
    clist.Add(list[i]);
end;

{**********************************************************}

function _BuildCompName(Comp: TPersistent; const AName: string): string;
var
  TempName: string;
begin
  Result := '';
  if Comp = nil then
    exit;

  if AName <> '' then
    TempName := AName
  else
  begin
    TempName := GetCompName(Comp);
    if TempName = '' then
      exit;
  end;

  if (Comp is TForm) and (TForm(Comp).Designer <> nil) then
    Result := TempName + ': T' + TempName //don't resource
  else
    {$IFDEF D3}if Comp is TCustomDCOleControl then
      Result := TempName + ': ' + TCustomDCOleControl(Comp).OleName
    else
      {$ENDIF}
      Result := TempName + ': ' + Comp.ClassName;
end;

{***************************************************************}

type
  TMForm = class(TCustomForm);

  {------------------------------------------------------------------}

function GetClassRegisterPackage(C: TClass): THandle;
begin
  {$IFDEF D3}
  Result := FindClassHInstance(C);
  {$ELSE}
  Result := HInstance;
  {$ENDIF}
end;

{------------------------------------------------------------------}

function FindResourceInstance(const ResName: string; ResType: PChar): THandle;
var
  PackList: TList;
  i: Integer;
begin
  PackList := TList.Create;
  ResModulesToList(PackList);
  try
    for i := 0 to PackList.Count - 1 do
    begin
      Result := Integer(PackList[i]);
      if (Result > 0) and (FindResource(Result, PChar(ResName), ResType) <> 0) then
        exit;
    end;
    Result := 0;
  finally
    PackList.Free;
  end;
end;

{------------------------------------------------------------------}

function FindObjectBitmapRes(var H: THandle; C: TClass; const ResNamePrefix: string): string;
var
  PackList: TList;
  i: Integer;
begin
  H := 0;
  if C = nil then
    exit;
  PackList := TList.Create;
  ResModulesToList(PackList);
  try
    repeat
      Result := ResNamePrefix + C.ClassName;
      for i := 0 to PackList.Count - 1 do
      begin
        H := Integer(PackList[i]);
        if (H > 0) and (FindResource(H, PChar(Result), RT_BITMAP) <> 0) then
          exit;
      end;
      C := C.ClassParent;
    until C = TPersistent;
    H := 0;
  finally
    PackList.Free;
  end;
end;

{------------------------------------------------------------------}

function FindObjectBitmapResEx(var H: THandle; C: TClass; const ResNamePrefix: string): string;
begin
  result := FindObjectBitmapRes(H, C, ResNamePrefix);
  if H = 0 then
    result := FindObjectBitmapRes(H, C, '_' + ResNamePrefix);
end;

{------------------------------------------------------------------}

type
  TMControl = class(TControl)
  end;

  {------------------------------------------------------------------}

function GetControlPopupMenu(c: TControl): TPopupMenu;
begin
  result := nil;
  while c <> nil do
  begin
    result := TMControl(c).GetPopupMenu;
    if Assigned(result) then
      exit;
    c := c.Parent;
  end;
end;

{-------------------------------------------------------------------------}

type
  TObjectWrapper = class
  private
    FPropedit: TPropertyEditor;
  public
    PropName: string;
    Instance: TPersistent;
    procedure Execute;
    procedure GetPropEdit(Prop: TPropertyEditor);
  end;

  {------------------------------------------------------------------}

procedure TObjectWrapper.GetPropEdit(Prop: TPropertyEditor);
begin
  if CompareText(Prop.GetName, PropName) = 0 then
    fPropEdit := Prop
  else
    Prop.Free;
end;

{------------------------------------------------------------------}

procedure TObjectWrapper.Execute;
var
  clist: TComponentList;
  Designer: TFormDesigner;
  fDesigner: TFDesigner;
begin
  clist := TComponentList.Create;
  {$IFNDEF D4}
  fDesigner := nil;
  {$ENDIF}
  try
    clist.Add(TComponent(Instance));
    Designer := GetDesigner(Instance);
    if Designer = nil then
    begin
      fDesigner := TFDesigner.Create;
      fDesigner.Form := GetPForm(Instance);
      fDesigner.OwnerControl := GetTopOwner(Instance);
      Designer := FDesigner;
    end;
    GetComponentProperties(clist, tkAny, Designer, GetPropEdit);
    if fPropEdit <> nil then
      fPropEdit.Edit;
  finally
    clist.Free;
    FreeObject(fPropEdit);
    {$IFNDEF D4}
    FreeObject(FDesigner);
    {$ENDIF}
  end;
end;

{------------------------------------------------------------------}

procedure CallPropertyEditor(C: TPersistent; const APropname: string);
begin
  if c <> nil then
    with TObjectWrapper.Create do
    try
      Instance := C;
      Propname := APropName;
      Execute;
    finally
      Free;
    end;
end;

{------------------------------------------------------------------}

function CreateNewTabSheet(PageControl: TPageControl): TTabSheet;
var
  Page: TTabSheet;
begin
  Page := TTabSheet.Create(PageControl.Owner);
  try
    Page.PageControl := PageControl;
    Result := Page;
  except
    Page.Free;
    raise;
  end;
end;

{------------------------------------------------------------------}

{Function CloneChar(C:Char;Len:Integer):String;
begin
  Result:='';
  If Len<=0 then
    exit;
  SetLength(Result,Len);
  FillChar(Result[1],Len,Byte(C))
end;}

{--------------------------------------------}

procedure RegisterVisualProperty(const AActionName: string; AObjClass: TPersistentClass;
  const APropName: string);
begin
  App.ActionList.RegisterVisualProperty(AActionName, AObjClass, APropName);
end;

{------------------------------------------------------------------}

type
  TMReader = class(TReader)
  private
    procedure ReaderSetName(Reader: TReader; Component: TComponent;
      var Name: string);
  end;

  {------------------------------------------------------------------}

procedure TMReader.ReaderSetName(Reader: TReader; Component: TComponent;
  var Name: string);
begin
  Name := '';
end;

{------------------------------------------------------------------}

procedure CopyPopupMenu(SourceMenu, TargetMenu: TPopupMenu);
var
  s: TMemoryStream;
  i: Integer;
  Item:TMenuItem;
begin
  while TargetMenu.Items.Count > 0 do
    TargetMenu.Items[0].Free;

  s := TMemoryStream.Create;
  try
    if Assigned(SourceMenu) then
    begin
      with TWriter.Create(s, 4096) do
      try
        Root := SourceMenu.Owner;
        WriteSignature;
        WriteComponent(SourceMenu);
      finally
        Free;
      end;

      s.Seek(0, 0);

      with TMReader.Create(S, 4096) do
      try
        OnSetName := ReaderSetName;
        Owner := SourceMenu.Owner;
        Root := SourceMenu.Owner;
        BeginReferences;
        ReadSignature;
        ReadComponent(TargetMenu);
      finally
        FixupReferences;
        EndReferences;
        Free;
      end;
      {$IFDEF D4}
      TargetMenu.Images:=SourceMenu.Images;
      {$ENDIF}
      with SourceMenu do
        for i := 0 to Items.Count - 1 do
        Begin
          Item:=Items[i];
          With  TargetMenu.Items[i] Do
          Begin
            OnClick := Item.OnClick;
            {$IFDEF D4}
            Action := Item.Action;
            {$ENDIF}
          End;  
        End;
    end;
  finally
    s.Free;
  end;
end;

{------------------------------------------------------------------}

type
  TMClass = class(TComponent)
  private
    fc: TColor;
    fRegistered: boolean;
    procedure GetPropEdit(prop: TPropertyEditor);
  published
    property c: TColor read fC write fC;
  end;

  {------------------------------------------------------------------}

procedure TMClass.GetPropEdit(prop: TPropertyEditor);
begin
  if prop.GetName = 'c' then
    fRegistered := prop is TColorProperty;

  prop.Free;
end;

{------------------------------------------------------------------}

function IsColorPropertyRegistered: boolean;
var
  mc: TMClass;
  clist: TComponentList;
  designer: TFormDesigner;
begin
  {$IFDEF CPB1}
  result := IsLibrary;
  if result then
    exit;
  {$ENDIF}
  clist := TComponentList.Create;
  Designer := TFDesigner.Create;
  mc := TMClass.Create(nil);
  try
    clist.Add(mc);
    GetComponentProperties(clist, tkAny, Designer, mc.GetPropEdit);
    result := mc.fRegistered;
  finally
    mc.Free;
    {$IFNDEF D4}
    Designer.Free;
    {$ENDIF}
    clist.Free;
  end;
end;

{******************************************************************}
(*
function TVariantProperty.GetValue: string;
begin
  result := GetVarValue;
end;

{------------------------------------------------------------------}

procedure TVariantProperty.SetValue(const Val: string);
begin
  SetVarValue(val);
end;

{******************************************************************}
*)
procedure RegisterStandardPropEdit;
begin
  if IsColorPropertyRegistered then
    exit;

  RegisterPropertyEditor(TypeInfo(tobject), nil, '', TClassProperty);
  RegisterPropertyEditor(TypeInfo(tcomponent), nil, '', TComponentProperty);
  RegisterPropertyEditor(TypeInfo(Longint), nil, '', TIntegerProperty);
  {$IFDEF D4}
  RegisterPropertyEditor(TypeInfo(Int64), nil, '', TIntegerProperty);
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(Char), nil, '', TCharProperty);
  RegisterPropertyEditor(TypeInfo(string), nil, '', TStringProperty);
  RegisterPropertyEditor(TypeInfo(TColor), nil, '', TColorProperty);
  RegisterPropertyEditor(TypeInfo(TFont), nil, '', TFontProperty);
  RegisterPropertyEditor(TypeInfo(TCursor), nil, '', TCursorProperty);

  // this property editor is overriden by TCaptionPropertyEditor
  // with multiline input feature in StrlstEd.pas
  RegisterPropertyEditor(TypeInfo(TCaption), nil, '', TCaptionProperty);

  RegisterPropertyEditor(TypeInfo(TFontName), nil, '', TFontNameProperty);
  RegisterPropertyEditor(TypeInfo(TModalResult), nil, '', TModalResultProperty);
  RegisterPropertyEditor(TypeInfo(TShortCut), nil, '', TShortCutProperty);
  RegisterPropertyEditor(TypeInfo(TComponentName), nil, '', TComponentNameProperty);
  RegisterPropertyEditor(TypeInfo(TTabOrder), nil, '', TTabOrderProperty);
  {$IFDEF D3}
  RegisterPropertyEditor(TypeInfo(TDateTime), nil, '', TDateTimeProperty);
  RegisterPropertyEditor(TypeInfo(TFontCharset), nil, '', TFontCharsetProperty);
  RegisterPropertyEditor(TypeInfo(TImeName), nil, '', TImeNameProperty);
  RegisterPropertyEditor(TypeInfo(TDate), nil, '', TDateProperty);
  RegisterPropertyEditor(TypeInfo(TTime), nil, '', TTimeProperty);

  RegisterPropertyEditor(TypeInfo(WordBool), nil, '', TBoolProperty);
  RegisterPropertyEditor(TypeInfo(LongBool), nil, '', TBoolProperty);
  //RegisterPropertyEditor(TypeInfo(Variant), TPersistent, '', TVariantProperty);
  dcVarPropEd.Register;
  {$ENDIF}

  RegisterPropertyEditor(TypeInfo(Integer), TFont, 'Size', TFontSizePropEdit); //don't resource
end;

{--------------------------------------------}

function TActionEditor.GetVerb(Index: Integer): string;
begin
  Result := App.ActionList.GetVerb(Component, Index)
end;

{--------------------------------------------}

procedure TActionEditor.ExecuteVerb(Index: Integer);
begin
  App.ActionList.ExecuteVerb(Component, Index);
end;

{--------------------------------------------}

function TActionEditor.GetVerbCount: Integer;
begin
  Result := App.ActionList.GetVerbCount(Component)
end;

{------------------------------------------------------------------}

type
  TFakeClickClass = class
  public
    CompEdit: TComponentEditor;
    procedure Click(Sender: TObject);
  end;

  {------------------------------------------------------------------}

var
  _FakeClickClass: TFakeClickClass = nil;

function FakeClickClass: TFakeClickClass;
begin
  if _FakeClickClass = nil then
    _FakeClickClass := TFakeClickClass.Create;

  result := _FakeClickClass;
end;

{------------------------------------------------------------------}

procedure TFakeClickClass.Click(Sender: TObject);
var
  i: integer;
begin
  i := TMenuItem(Sender).tag;
  if (i >= 2000) then
    App.ActionList.ExecuteVerb(CompEdit.Component, i - 2000)
  else if i >= 1000 then
    CompEdit.ExecuteVerb(i - 1000)
end;

{------------------------------------------------------------------}

procedure MakeComponentPopup(PopupMenu, fmenu: TPopupMenu; fcedit: TComponentEditor);
var
  item: TMenuItem;
  ActionEdit: TActionEditor;
  A: Integer;

  function AddActions(CompEdit: TComponentEditor; FakeID: Integer): Integer;
  var
    i: integer;
  begin
    with CompEdit do
    begin
      Result := GetVerbCount;
      if Result > 0 then
      begin
        for i := 0 to Result - 1 do
        begin
          item := TMenuItem.Create(FMenu);
          item.tag := FakeID + i;
          item.Caption := GetVerb(i);
          item.OnClick := FakeClickClass.Click;
          fmenu.Items.Insert(i, item);
        end;
      end;
    end;
  end;

begin
  FakeClickClass.CompEdit := FCEdit;
  CopyPopupMenu(PopupMenu, fMenu);
  FMenu.OnPopup := nil;

  if fcEdit <> nil then
  begin
    ActionEdit := TActionEditor.Create(fcEdit.Component, fcEdit.Designer);
    try
      A := AddActions(fcEdit, 1000) + AddActions(ActionEdit, 2000);
      if A > 0 then
      begin
        item := TMenuItem.Create(fmenu);
        item.Caption := '-';
        fmenu.Items.Insert(A, item);
      end;
    finally
      ActionEdit.Free;
    end;
  end;

  RemoveExtraMenuSeparators(fMenu.Items);
end;

{--------------------------------------------}

procedure RegisterComponentAction(const ActionName: string; ObjClass: TPersistentClass;
  ActionProc: TActionProc);
begin
  App.ActionList.RegisterComponentAction(ActionName, ObjClass, ActionProc);
end;

{******************************************************************}

function DesignerCanPaste: boolean;
begin
  result := IsClipboardFormatAvailable(CF_TEXT);
end;

{------------------------------------------------------------------}

constructor TFDesigner.Create;
begin
  inherited;
  DesignerList.Add(self);
  fSelection := TList.Create;
end;

{------------------------------------------------------------------}

destructor TFDesigner.Destroy;
begin
  DesignerList.Remove(self);
  fSelection.Free;
  inherited;
end;

{------------------------------------------------------------------}

function TFDesigner.AllowPropShow(Instance: TComponent; const PropName: string): boolean;
begin
  result := true;
end;

{------------------------------------------------------------------}

function TFDesigner.AllowPropShowList(Comps: TList; const PropName: string): boolean;
var
  i: integer;
begin
  for i := 0 to Comps.Count - 1 do
    if not AllowPropShow(TComponent(Comps[i]), PropName) then
    begin
      result := false;
      exit;
    end;

  result := true;
end;

{------------------------------------------------------------------}

function TFDesigner.AllowEditList(Comps: TList; const PropName: string): boolean;
var
  i: integer;
begin
  for i := 0 to Comps.Count - 1 do
    if not AllowEdit(TComponent(Comps[i]), PropName) then
    begin
      result := false;
      exit;
    end;

  result := true;
end;

{------------------------------------------------------------------}

function TFDesigner.AllowEdit(Instance: TComponent; const PropName: string): boolean;
begin
  result := true;
end;

{------------------------------------------------------------------}

function TFDesigner.CanBeSelected(Instance: TPersistent): boolean;
begin
  result := true;
end;

{------------------------------------------------------------------}

function TFDesigner.GetLimitControl: TWinControl;
begin
  result := fLimitWinControl;
end;

{------------------------------------------------------------------}

procedure TFDesigner.SetLimitControl(val: TWinControl);
begin
  if (val <> nil) and not (csAcceptsControls in TWinControl(val).ControlStyle) then
    raise EPropertyError.{$IFDEF D3}Create{$ELSE}CreateRes{$ENDIF}(SInvalidPropertyValue);

  fLimitWinControl := val;
end;

{------------------------------------------------------------------}

function TFDesigner.GetSelection: TList;
begin
  result := fSelection;
end;

{------------------------------------------------------------------}

function TFDesigner.IsDesignMsg(Sender: TControl; var Message: TMessage): Boolean;
begin
  result := false;
end;

{------------------------------------------------------------------}

procedure TFDesigner.Modified;
var
  b: boolean;
begin
  with fSelection do
  begin
    B := (count = 0);
    if b then
      Add(OwnerControl);

    BroadCastToNotifiers(self, CM_PROPCHANGED, integer(fSelection), 0);

    if B then
      FSelection.Clear;
  end;
end;

{------------------------------------------------------------------}
{$IFNDEF D4}

procedure TFDesigner.Notification(AComponent: TComponent; Operation: TOperation);
{$ELSE}

procedure TFDesigner.Notification(AnObject: TPersistent; Operation: TOperation);
{$ENDIF}
begin
  if (Operation = opInsert) and
    (GetTopOwner({$IFNDEF D4}AComponent{$ELSE}AnObject{$ENDIF}) = OwnerControl) then
    BroadCastToNotifiers(self, CM_OBJINSERT, integer({$IFNDEF D4}AComponent{$ELSE}AnObject{$ENDIF}), 0);
end;

{------------------------------------------------------------------}

procedure TFDesigner.PaintGrid;
begin
end;

{------------------------------------------------------------------}

procedure TFDesigner.ValidateRename(AComponent: TComponent; const CurName, NewName: string);
begin
  if AComponent = nil then
    AComponent := GetOwnerControl;
  BroadCastToNotifiers(self, CM_NAMECHANGED, Integer(AComponent), Integer(PChar(NewName)));
end;

{------------------------------------------------------------------}

function TFDesigner.CreateMethod(const Name: string; TypeData: PTypeData): TMethod;
begin
  Result.Code := nil;
  Result.Data := nil;
end;

{------------------------------------------------------------------}

function TFDesigner.GetMethodName(const Method: TMethod): string;
begin
  if (Method.Data <> nil) and (Method.Code <> nil) then
    result := TObject(Method.Data).MethodName(Method.Code)
  else
    result := '';
end;

{------------------------------------------------------------------}

procedure TFDesigner.GetMethods(TypeData: PTypeData; Proc: TGetStrProc);
begin
end;

{------------------------------------------------------------------}

function TFDesigner.GetPrivateDirectory: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

{------------------------------------------------------------------}
{$IFNDEF D4}

procedure TFDesigner.GetSelections(List: TComponentList);
begin
  ListToCompList(Selection, List);
end;

{------------------------------------------------------------------}

procedure TFDesigner.SetSelections(List: TComponentList);
begin
  Selection.Clear;
  CompListToList(List, Selection);
  SelectionChanged;
end;

{------------------------------------------------------------------}
{$ELSE}

procedure TFDesigner.GetSelections(const List: IDesignerSelections);
var
  i: integer;
begin
  for i := 0 to Selection.Count - 1 do
    List.Add(MakeIPersistent(TPersistent(Selection[i])));
end;

{------------------------------------------------------------------}

procedure TFDesigner.SetSelections(const List: IDesignerSelections);
var
  i: integer;
begin
  Selection.Clear;
  for i := 0 to List.Count - 1 do
    Selection.Add(ExtractPersistent(IPersistent(List[i])));
  SelectionChanged;
end;
{$ENDIF}

{------------------------------------------------------------------}

function TFDesigner.MethodExists(const Name: string): Boolean;
begin
  Result := GetOwnerControl.MethodAddress(Name) <> nil;
end;

{------------------------------------------------------------------}

procedure TFDesigner.RenameMethod(const CurName, NewName: string);
begin
end;

{------------------------------------------------------------------}

procedure TFDesigner.ValidateSelection;
var
  dmodule: TDataModule;
  i: integer;
begin
  with Selection do
  begin
    Remove(nil);

    if (Count = 0) and (LimitControl = nil) then
      Add(GetOwnerControl);

    for i := 0 to Count - 1 do
    begin
      dmodule := DataModuleByWrapper(TCustomForm(Items[i]));
      if dmodule <> nil then
        Items[i] := dmodule;
    end;
  end;
end;

{$IFDEF D3}

procedure TFDesigner.SelectComponent(Instance: TPersistent);
begin
  Selection.Clear;
  Selection.Add(Instance);
  {$ELSE}

procedure TFDesigner.SelectComponent(Component: TComponent);
begin
  Selection.Clear;
  Selection.Add(Component);
  {$ENDIF}
  SelectionChanged;
end;

{------------------------------------------------------------------}

procedure TFDesigner.SelectionChanged;
begin
  ValidateSelection;
  BroadCastToNotifiers(self, CM_SELECTIONCHANGED, integer(Selection), integer(self{$IFDEF D4} as TFormDesigner{$ENDIF}));
end;

{------------------------------------------------------------------}

procedure TFDesigner.ShowMethod(const Name: string);
begin
end;

{------------------------------------------------------------------}

function TFDesigner.UniqueName(const BaseName: string): string;
begin
  result := dcsystem.UniqueName(GetOwnerControl, BaseName);
end;

{------------------------------------------------------------------}

procedure TFDesigner.SetOwnerControl(C: TComponent);
begin
  fOwnerControl := c;
end;

{------------------------------------------------------------------}

function TFDesigner.GetOwnerControl: TComponent;
begin
  if fOwnerControl <> nil then
    result := fOwnerControl
  else
    result := form;
end;

{------------------------------------------------------------------}

procedure TFDesigner.GetComponentNames(TypeData: PTypeData; Proc: TGetStrProc);
begin
  CompNamesToProc(GetOwnerControl, GetOwnerControl, TypeData, Proc);
end;

{------------------------------------------------------------------}

function TFDesigner.GetComponent(const Name: string): TComponent;
var
  Owner: TComponent;
begin
  if (Pos('.', Name) <> 0) then
    Result := GlobalFindObject(Name)
  else
  begin
    Owner := GetOwnerControl;
    if Assigned(Owner) then
      if CompareText(Owner.Name, Name) = 0 then
        result := Owner
      else
        result := Owner.FindComponent(Name)
    else
      result := nil;
  end;
end;

{------------------------------------------------------------------}

function TFDesigner.GetComponentName(Component: TComponent): string;
var
  Owner: TComponent;
begin
  Owner := GetOwnerControl;
  if (Component <> nil) and (Component.Name <> '') then
  begin
    if (Component.Owner = Owner) or (Component = Owner) then
      result := Component.Name
    else
      result := Component.Owner.Name + '.' + Component.Name;
  end
  else
    result := '';
end;

{------------------------------------------------------------------}

function TFDesigner.MethodFromAncestor(const Method: TMethod): Boolean;
begin
  Result := False;
end;

{------------------------------------------------------------------}

function TFDesigner.CreateComponent(ComponentClass: TComponentClass; Parent: TComponent;
  Left, Top, Width, Height: Integer): TComponent;
begin
  Result := nil;
end;

{------------------------------------------------------------------}

function TFDesigner.IsComponentLinkable(Component: TComponent): Boolean;
begin
  result := False;
end;

{------------------------------------------------------------------}

procedure TFDesigner.MakeComponentLinkable(Component: TComponent);
begin
end;

{------------------------------------------------------------------}

function TFDesigner.GetRoot: TComponent;
begin
  Result := GetOwnerControl;
end;

{------------------------------------------------------------------}

procedure TFDesigner.Revert(Instance: TPersistent; PropInfo: PPropInfo);
begin
end;

{------------------------------------------------------------------}

{$IFDEF D3}

function TFDesigner.GetObject(const Name: string): TPersistent;
begin
  Result := nil;
end;

{------------------------------------------------------------------}

function TFDesigner.GetObjectName(Instance: TPersistent): string;
begin
  if Instance is TComponent then
    result := TComponent(Instance).Name
  else
    result := Instance.GetNamePath;
end;

{------------------------------------------------------------------}

procedure TFDesigner.GetObjectNames(TypeData: PTypeData; Proc: TGetStrProc);
begin
end;

{------------------------------------------------------------------}

function TFDesigner.GetIsDormant: Boolean;
begin
  Result := False;
end;

{------------------------------------------------------------------}

function TFDesigner.HasInterface: Boolean;
begin
  Result := False;
end;

{------------------------------------------------------------------}

function TFDesigner.HasInterfaceMember(const Name: string): Boolean;
begin
  Result := False;
end;

{------------------------------------------------------------------}

{$IFNDEF CPB3}

procedure TFDesigner.AddInterfaceMember(const MemberText: string);
begin

end;

{$ELSE}
{------------------------------------------------------------------}

procedure TFDesigner.AddToInterface(InvKind: Integer; const Name: string; VT: Word;
  const TypeInfo: string);
begin

end;

{------------------------------------------------------------------}

procedure TFDesigner.GetProjectModules(Proc: TGetModuleProc);
begin

end;

{$ENDIF}

{$ENDIF}

{$IFDEF D4}

function TFDesigner.GetCustomForm: TCustomForm;
begin
  result := fForm;
end;

{------------------------------------------------------------------}

procedure TFDesigner.SetCustomForm(Value: TCustomForm);
begin
  fform := Value;
end;

{------------------------------------------------------------------}

function TFDesigner.GetIsControl: Boolean;
begin
  result := false;
end;

{------------------------------------------------------------------}

procedure TFDesigner.SetIsControl(Value: Boolean);
begin

end;

{------------------------------------------------------------------}

function TFDesigner.GetAncestorDesigner: IFormDesigner;
begin
  result := nil;
end;

{------------------------------------------------------------------}

function TFDesigner.IsSourceReadOnly: Boolean;
begin
  result := false;
end;

{$ENDIF} //D4

{------------------------------------------------------------------}
{$IFDEF D5}

function TFDesigner.GetContainerWindow: TWinControl;
begin
  result := Form;
end;

{------------------------------------------------------------------}

procedure TFDesigner.SetContainerWindow(const NewContainer: TWinControl);
begin

end;

{------------------------------------------------------------------}

function TFDesigner.GetScrollRanges(const ScrollPosition: TPoint): TPoint;
begin
  result := ScrollPosition;
end;

{------------------------------------------------------------------}

procedure TFDesigner.Edit(const Component: IComponent);
begin
  if Component = nil then
    Form.Show;
end;

{------------------------------------------------------------------}

function TFDesigner.BuildLocalMenu(Base: TPopupMenu; Filter: TLocalMenuFilters): TPopupMenu;
begin
  result := Base;
end;

{------------------------------------------------------------------}

procedure TFDesigner.ChainCall(const MethodName, InstanceName, InstanceMethod: string;
  TypeData: PTypeData);
begin

end;

{------------------------------------------------------------------}

procedure TFDesigner.CopySelection;
begin

end;

{------------------------------------------------------------------}

procedure TFDesigner.CutSelection;
begin

end;

{------------------------------------------------------------------}

function TFDesigner.CanPaste: Boolean;
begin
  result := DesignerCanPaste;
end;

{------------------------------------------------------------------}

procedure TFDesigner.PasteSelection;
begin

end;

{------------------------------------------------------------------}

procedure TFDesigner.DeleteSelection;
begin

end;

{------------------------------------------------------------------}

procedure TFDesigner.ClearSelection;
begin

end;

{------------------------------------------------------------------}

procedure TFDesigner.NoSelection;
begin

end;

{------------------------------------------------------------------}

procedure TFDesigner.ModuleFileNames(var ImplFileName, IntfFileName, FormFileName: string);
begin

end;

{------------------------------------------------------------------}

function TFDesigner.GetRootClassName: string;
begin
  result := OwnerControl.ClassName;
end;

{$ENDIF}

{------------------------------------------------------------------}

function TFDesigner.IsSelected(Instance : TPersistent) : boolean;
begin
  result := Selection.IndexOf(Instance) >= 0;
end;

{------------------------------------------------------------------}

function TFontSizePropEdit.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paValueList];
end;

{------------------------------------------------------------------}

const
  FontSizeCount = 16;

  FontSizes: array[1..FontSizeCount] of byte =
    (8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72);

procedure TFontSizePropEdit.GetValues(Proc: TGetStrProc);
var
  i: Integer;
begin
  for i := 1 to FontSizeCount do
    Proc(IntToStr(FontSizes[i]));
end;

{------------------------------------------------------------------}

constructor TAxControlCollection.Create;
begin
  inherited Create(TAxControlInfo);
  LoadRegisteredControls;
end;

{------------------------------------------------------------------}

procedure TAxControlCollection.GetActiveXNames(S: TStrings);
var
  i: Integer;
  TempStr: string;
  TempList: TList;

  function NoSuchGuID(const guid: TGUID): boolean;
  var
    i: Integer;
  begin
    with TempList do
      for I := 0 to Count - 1 do
        if IsEqualGUID(GUID, TAxControlInfo(Items[i]).TypeLib) then
        begin
          Result := False;
          exit;
        end;
    Result := True;
  end;

begin
  with S do
  begin
    BeginUpdate;
    Clear;
    try
      TempList := TList.Create;
      for i := 0 to Self.Count - 1 do
        with TAxControlInfo(Self.Items[i]) do
          if NoSuchGuID(TypeLib) then
          begin
            TempStr := GetTypeLibName(TypeLib);
            if TempStr = '' then
              TempStr := InprocServer;
            AddObject(TempStr, Self.Items[i]);
            TempList.Add(Self.Items[i]);
          end;
    finally
      TempList.Free;
      EndUpdate;
    end;
  end;
end;

{
        if IsEqualGuID(GUID_NULL,TypeLib)  then
        begin
          // load controls with no type library
          TempStr:=Name;
          If TempStr='' then
            TempStr:=InprocServer;
          AddObject(TempStr,Self.Items[i])
        end
        else
         // load controls with type library
}

{------------------------------------------------------------------}

function TAxControlCollection.ItemByGUID(AGUID: TGUID): TAxControlInfo;
var
  i: Integer;
begin
  for I := 0 to Count - 1 do
    with TAxControlInfo(Items[i]) do
      if IsEqualGUID(AGUID, TypeLib) or IsEqualGUID(AGUID, GUID) then
      begin
        Result := TAxControlInfo(Items[i]);
        exit;
      end;
  Result := nil;
end;

{------------------------------------------------------------------}

procedure TAxControlCollection.LoadRegisteredControls;
var
  icat: ICatInformation;
  ienum: IEnumCATEGORYINFO;
  enuminfo: TCATEGORYINFO;
  res: DWORD;
  ccatid: TGUID;
  enumclsid: IEnumGUID;
  cguid: TGUID;
  reg: TRegistry;
  cname: string;
  pname: string;
  commapos: integer;
  ss: string;
  pwhint: PWideChar;
begin
  Clear;
  if CoCreateInstance(CLSID_StdComponentCategoryMgr, nil, CLSCTX_INPROC_SERVER, {$IFDEF D3}ICatInformation{$ELSE}IID_ICatInformation{$ENDIF}, icat) <> S_OK then
    exit;

  reg := TRegistry.Create;
  try
    icat.EnumCategories(0, ienum);
    while ienum.Next(1, enuminfo, res) = 0 do
      if (CompareText(WideCharToString(enuminfo.szDescription), 'Control') = 0) or //don't resource
      (CompareText(WideCharToString(enuminfo.szDescription), 'Controls') = 0) then //don't resource
      begin
        ccatid := enuminfo.catid;
        break;
      end;

    if icat.EnumClassesOfCategories(1, @ccatid, 0, nil, enumclsid) = S_OK then
      with reg do
      begin
        RootKey := HKEY_CLASSES_ROOT;
        while enumclsid.Next(1, cguid, res) = 0 do
        begin
          cname := 'CLSID\' + GUIDToString(cguid); //don't resource
          OpenKey(cname, false);
          cname := cname + '\';
          with TAxControlInfo(Add) do
          begin
            guid := cguid;
            name := ReadString('');
            CloseKey;
            if OpenKey(cname + 'ToolboxBitmap32', false) then //don't resource
            begin
              pname := ReadString('');
              CloseKey;
            end;

            if OpenKey(cname + 'InprocServer32', false) then //don't resource
            begin
              inprocserver := ReadString('');
              CloseKey;
            end;

            if keyexists(cname + 'TypeLib') then //don't resource
            begin
              OpenKey(cname + 'TypeLib', false); //don't resource
              ss := ReadString('');
              if ss <> '' then
                typelib := StringToGUID(ss);
              CloseKey;
            end;

            ProgIDFromCLSID(cguid, pwhint);
            if pwhint <> nil then
              hint := ExtractControlName(WideCharToString(pwhint))
            else
              hint := '';

            commapos := pos(',', pname);
            if commapos > 0 then
            begin
              picturefile := copy(pname, 1, commapos - 1);
              pictureindex := StrToIntDef(copy(pname, commapos + 1, length(pname) - commapos), 0);
            end
            else
              picturefile := pname;
          end;
        end;
      end;
  finally
    reg.Free;
  end;
end;

function TActionsList.GetActionItem(AComp: TPersistent; AIndex: Integer): TCollectionItem;
var
  k, i: Integer;
begin
  k := 0;
  Result := nil;
  for i := 0 to Count - 1 do
    with TActionListItem(Items[i]) do
    begin
      if ((AComp is ObjClass) or (ObjClass = nil)) {and
      ((CompareText(ObjName,AComp.Name)=0) or (ObjName=''))}then
      begin
        if k = AIndex then
        begin
          Result := Items[i];
          exit;
        end;
        inc(k);
      end;
    end;
end;

{-------------------------------------------------------------------------}

function TActionsList.GetVerb(AComp: TPersistent; AIndex: Integer): string;
var
  T: TActionListItem;
begin
  T := TActionListItem(GetActionItem(AComp, AIndex));
  if T = nil then
    Result := ''
  else
    Result := T.ActionName;
end;

{-------------------------------------------------------------------------}

procedure TActionsList.ExecuteVerb(AComp: TPersistent; AIndex: Integer);
var
  T: TActionListItem;
begin
  T := TActionListItem(GetActionItem(AComp, AIndex));
  if t <> nil then
    with T do
      if CallType = ctPropName then
        CallPropertyEdit(AComp, PropName)
      else if Assigned(ActionProc) then
        ActionProc(AComp);
end;

{-------------------------------------------------------------------------}

function TActionsList.GetVerbCount(AComp: TPersistent): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    with TActionListItem(Items[i]) do
    begin
      if ((AComp is ObjClass) or (ObjClass = nil)) { and
      ((CompareText(ObjName,AComp.Name)=0) or (ObjName=''))}then
        inc(Result);
    end;
end;

{-------------------------------------------------------------------------}

procedure TActionsList.RegisterVisualProperty(const AActionName: string;
  AObjClass: TPersistentClass; const APropName: string);
begin
  with TActionListItem(Add) do
  begin
    ActionName := AActionName;
    //    ObjName:=AObjName;
    ObjClass := AObjClass;
    CallType := ctPropName;
    PropName := APropName;
  end;
end;

{-------------------------------------------------------------------------}

procedure TActionsList.RegisterComponentAction(const AActionName: string; AObjClass: TPersistentClass;
  AActionProc: TActionProc);
begin
  with TActionListItem(Add) do
  begin
    ActionName := AActionName;
    //    ObjName:=AObjName;
    ObjClass := AObjClass;
    ActionProc := AActionProc;
    CallType := ctActionProc;
  end;
end;

{------------------------------------------------------------------}

procedure ImageListSaveToFile(ImageList: TCustomImageList; const FileName: string);
begin
  with TBitmap.Create do
  try
    Handle := ImageList.GetImageBitmap;
    SaveToFile(FileName);
  finally
    Free;
  end;
end;

{------------------------------------------------------------------}

{-----------------------------------------------------------}
var
  fDataModuleWrappers: TList = nil;

  {------------------------------------------------------------------}

function DataModuleWrappers: TList;
begin
  if fDataModuleWrappers = nil then
    fDataModuleWrappers := TList.Create;

  result := fDataModuleWrappers;
end;

{------------------------------------------------------------------}

function GetDesigner(c: TPersistent): TFormDesigner;
var
  pform: TCustomForm;
begin
  pform := GetPForm(c);
  if pform = nil then
  begin
    while (c <> nil) and not (c is TDataModule) do
      c := GetOwner(c);

    if c <> nil then
      pform := GetDataModuleWrapper(TDataModule(c));
  end;

  if pform <> nil then
    result := pform.Designer as TFormDesigner
  else
    result := nil;
end;

{------------------------------------------------------------------}

function IsFDesigner(const D: TFormDesigner): boolean;
{$IFDEF D4}
var
  tmp: IDesigner;
begin
  result := (D <> nil) and (D.QueryInterface(IDCFDesigner, tmp) = S_OK);
  {$ELSE}
begin
  result := D is TFDesigner;
  {$ENDIF}
end;

{------------------------------------------------------------------}

procedure DesignerModified(c: TPersistent);
var
  Designer: TFormDesigner;
begin
  Designer := GetDesigner(c);
  if Designer <> nil then
    Designer.Modified;
end;

{---------------------------------------}

procedure SetAllTabsVisible(PageControl: TPageControl; AVisible: Boolean);
var
  i: Integer;
begin
  with PageControl do
    for I := 0 to PageCount - 1 do
      Pages[i].TabVisible := AVisible;
end;

{---------------------------------------}

procedure CorrectActiveTab(PageControl: TPageControl);
var
  i: Integer;
begin
  with PageControl do
    for i := 0 to PageCount - 1 do
      if Pages[i].TabVisible then
      begin
        ActivePage := Pages[i];
        break;
      end;
end;

{---------------------------------------}

procedure SetTabsVisible(PageControl: TPageControl;
  const TabNames: array of string; AVisible: Boolean);
var
  i: Integer;
  TabSheet: TObject;
begin
  for i := Low(TabNames) to High(TabNames) do
  begin
    TabSheet := PageControl.Owner.FindComponent(TabNames[i]);
    if (TabSheet is TTabSheet) and (TTabSheet(TabSheet).PageControl = PageControl) then
      TTabSheet(TabSheet).TabVisible := AVisible;
  end;

  CorrectActiveTab(PageControl);
end;

{---------------------------------------}

procedure UpdateLabelsEnabled(F: TCustomForm);
var
  i: Integer;
begin
  with F do
    for i := 0 to ComponentCount - 1 do
      if (Components[i] is TLabel) then
        with TLabel(Components[i]) do
          if FocusControl <> nil then
            Enabled := FocusControl.Enabled;
end;

{------------------------------------------------------------------}

function IsChildMenu(Item: TMenuItem; Menu: Tmenu): boolean;
begin
  if Assigned(Menu) and Assigned(Item) then
  begin
    while Assigned(Item.Parent) do
      Item := Item.Parent;
    result := Assigned(Menu) and (Menu.Items = Item);
  end
  else
    result := false;
end;

{------------------------------------------------------------------}

type
  TFakeComponent = class(TComponent)
  end;

  TFakeComponentEditor = class(TDefaultEditor)
  end;

  TFakePropertyEditor = class(TPropertyEditor)
  end;

  {------------------------------------------------------------------}

const
  SKnownActiveXs = 'KnownActiveXs'; // don't resource

constructor TDCApplication.Create;
begin
  App := Self;
  inherited;

  //  RegisterNotifier(Self);
  RegisterStandardPropEdit;
end;

{------------------------------------------------------------------}

function TDCApplication.GetGUIDS: TStrings;
begin
  if fGUIDS = nil then
  begin
    FGUIDS := CreateSortedStringList;
    ReadStringsFromRegistry(SKnownActiveXs, FGUIDS); // maybe not read it in initialization
  end;

  result := fGUIDS;
end;

{------------------------------------------------------------------}

function TDCApplication.GetActionList: TActionsList;
begin
  if fActionList = nil then
    fActionList := TActionsList.Create(TActionListItem);

  result := fActionList;
end;

{------------------------------------------------------------------}

function TDCApplication.ActiveXRegistered(GUID: TGUID): boolean;
var
  i: Integer;
begin
  Result := TStringList(GUIDS).Find(GUIDTOString(GUID), i);
end;

{------------------------------------------------------------------}

procedure TDCApplication.RegisterActiveX(AxInfo: TAxControlInfo);
begin
  FGUIDS.Add(GUIDTOString(AxInfo.TypeLib));
  BroadCastToNotifiers(Self, CM_REGISTERACTIVEX, Integer(AxInfo), 0);
  SaveActiveXConfig;
end;

{------------------------------------------------------------------}

procedure TDCApplication.SaveActiveXConfig;
begin
  WriteStringsToRegistry(SKnownActiveXs, FGUIDS);
end;

{------------------------------------------------------------------}

procedure TDCApplication.UnRegisterActiveX(AxInfo: TAxControlInfo);
var
  i: Integer;
begin
  if TStringList(FGUIDS).Find(GUIDTOString(AxInfo.TypeLib), i) then
  begin
    FGUIDS.Delete(i);
    BroadCastToNotifiers(Self, CM_UNREGISTERACTIVEX, Integer(AxInfo), 0);
    SaveActiveXConfig;
  end;
end;

{------------------------------------------------------------------}

destructor TDCApplication.Destroy;
begin
  //  UnRegisterNotifier(self);
  FActionList.Free;
  _FakeClickClass.Free;
  FGUIDS.Free;
  inherited;
end;

{------------------------------------------------------------------}

function AddIconFromAnyResource(ImageList: TCustomImageList; const ResName: string): boolean;
var
  H: THandle;
begin
  H := FindResourceInstance(ResName, RT_GROUP_ICON);

  if H = 0 then
    H := FindResourceInstance(ResName, RT_ICON);

  if H = 0 then
    Result := False
  else
    Result := AddIconFromResource(ImageList, ResName, H);
end;

{------------------------------------------------------------------}

function AddIconFromResource(ImageList: TCustomImageList; const ResName: string;
  Instance: THandle): boolean;
var
  Handle: THandle;
begin
  Result := False;

  Handle := LoadIcon(Instance, PChar(ResName));
  if Handle <> 0 then
  begin
    ImageList_AddIcon(ImageList.Handle, Handle);
    Result := True;
  end;
  DestroyIcon(Handle);
end;

{------------------------------------------------------------------}

function AddBitmapFromResource(ImageList: TCustomImageList; const ResName: string;
  Instance: THandle): Integer;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.LoadFromResourceName(Instance, ResName);
    Result := ImageList.AddMasked(Bitmap, BitMap.TransparentColor);
  finally
    Bitmap.Free;
  end;
end;

{------------------------------------------------------------------}

function CreateDataModule: TDataModule;
begin
  {$IFDEF VER93}
  Result := TDataModule.CreateNew(nil, 0);
  {$ELSE}
  Result := TDataModule.CreateNew(nil);
  {$ENDIF}
end;

{------------------------------------------------------------------}

const
  EventImplFlags = IMPLTYPEFLAG_FDEFAULT or IMPLTYPEFLAG_FSOURCE;

function GetEventDispatchTypeInfo(const OLEObject: IUnknown): ITypeInfo;
var
  iclassinfo: IProvideClassInfo;
  eti: ITypeInfo;
  i: integer;
  implflags: integer;
  reftype: HRefType;
begin
  OleObject.QueryInterface({$IFNDEF D3}IID_IProvideClassInfo{$ELSE}IProvideClassInfo{$ENDIF}, iclassinfo);
  iclassinfo.GetClassInfo(eti);

  if eti = nil then
  begin
    result := nil;
    exit;
  end;

  i := 0;
  while (eti.GetImplTypeFlags(i, implflags) = S_OK) and (implflags and EventImplFlags <> EventImplFlags) do
    inc(i);

  eti.GetRefTypeOfImplType(i, reftype);
  eti.GetRefTypeInfo(reftype, result);
end;

{******************************************************************}

function DataModuleByWrapper(AForm: TCustomForm): TDataModule;
var
  i: integer;
begin
  with DataModuleWrappers do
    for i := 0 to Count - 1 do
      with TWrapperInfo(Items[i]) do
        if form = AForm then
        begin
          result := data;
          exit;
        end;

  result := nil;
end;

{------------------------------------------------------------------}

function GetDataModuleWrapper(DataModule: TDataModule): TCustomForm;
var
  i: integer;
begin
  with DataModuleWrappers do
    for i := 0 to Count - 1 do
      with TWrapperInfo(Items[i]) do
        if data = DataModule then
        begin
          result := form;
          exit;
        end;

  result := nil;
end;

{-----------------------------------------------------------}

function GetRGBColor(Value: TColor): DWORD;
begin
  Result := ColorToRGB(Value);
  case Result of
    clNone: Result := CLR_NONE;
    clDefault: Result := CLR_DEFAULT;
  end;
end;

{-------------------------------------------------------------------}

procedure TNotifierListEx.PostMessage(Msg: Integer; wParam, lParam: Integer);
var
  i: integer;
begin
  with Notifiers do
  begin
    i := Count - 1;
    while i >= 0 do
    begin
      Windows.PostMessage(TWinControl(TMethod(TNotifierListItem(Items[i]).Method).Data).Handle, Msg,
        wParam, lParam);
      i := Min(Count, i);
      dec(i);
    end;
  end;
end;

{-------------------------------------------------------------------------}

var
  ShowInspectorCount: integer = 0;
  ShowPaletteCount: integer = 0;
  ShowAlignPaletteCount: integer = 0;

procedure ShowObjectInspector;
var
  f: TCustomForm;
begin
  f := Screen.ActiveForm;
  ShowInspectorEx(False);
  inc(ShowInspectorCount);
  ShowFormEx(F, SW_SHOW);
end;

{-------------------------------------------------------------------------}

procedure HideObjectInspector;
begin
  dec(ShowInspectorCount);
  if ShowInspectorCount = 0 then
    HideInspector;
end;

{-------------------------------------------------------------------------}

procedure ShowComponentPalette;
var
  f: TCustomForm;
begin
  f := Screen.ActiveForm;
  BroadCastToNotifiers(nil, CM_SHOWPALETTE, 1, 0);
  inc(ShowPaletteCount);
  ShowFormEx(F, SW_SHOW);
end;

{-------------------------------------------------------------------------}

procedure HideComponentPalette;
begin
  dec(ShowPaletteCount);
  if ShowPaletteCount = 0 then
    SimpleBroadCast(CM_HIDEPALETTE);
end;

{-------------------------------------------------------------------------}

procedure ShowAlignPalette;
var
  f: TCustomForm;
begin
  f := Screen.ActiveForm;
  BroadCastToNotifiers(nil, CM_SHOWALIGNPALETTE, 1, 0);
  inc(ShowAlignPaletteCount);
  ShowFormEx(F, SW_SHOW);
end;

{-------------------------------------------------------------------------}

procedure HideAlignPalette;
begin
  dec(ShowAlignPaletteCount);
  if ShowAlignPaletteCount = 0 then
    SimpleBroadCast(CM_HIDEALIGNPALETTE);
end;

{------------------------------------------------------------------}

procedure FreePropEditors;
{$IFDEF D3}
var
  i: Integer;
begin
  for I := -1 to CurrentGroup do
    FreeEditorGroup(i);
end;
{$ELSE}
begin
end;
{$ENDIF}

{-------------------------------------------------------------------------}

{******************************************************************}

procedure TDispatchCompEditor.ExecuteVerb(Index: Integer);
begin
  CallPropertyEdit(Component, 'VerbList'); //don't resource
end;

{-------------------------------------------------------------------------}

function TDispatchCompEditor.GetVerb(Index: Integer): string;
begin
  Result := SVerbAssignVerbs;
end;

{-------------------------------------------------------------------------}

function TDispatchCompEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{------------------------------------------------------------------}

procedure TMonoSpaceFontNamesProperty.SetValue(const Value: string);
var
  f: TFont;
begin
  f := TFont.Create;
  try
    F.Name := Value;
    if IsFontMonoSpaced(f) then
      inherited SetValue(Value)
    else
      dcLib.Error(SErrNonMonoSpacedFont);
  finally
    f.Free;
  end;
end;

{------------------------------------------------------------------}

procedure TMonoSpaceFontNamesProperty.GetValues(Proc: TGetStrProc);
var
  i: integer;
  f: TFont;
begin
  f := TFont.Create;
  try
    with Screen.Fonts do
      for i := 0 to Count - 1 do
      begin
        f.Name := Strings[i];
        if IsFontMonoSpaced(f) then
          Proc(f.Name);
      end;
  finally
    f.Free;
  end;
end;

{-------------TDirectoryProperty---------------------------------------}

function TDirectoryProperty.GetAttributes: TPropertyAttributes;
begin
  result := inherited GetAttributes + [paDialog];
end;

{------------------------------------------------------------------}

procedure TDirectoryProperty.Edit;
var
  s: string;
begin
  s := Value;
  if QueryDirectory(SSelectDirectory, s) then
    Value := s;
end;

{------------------------------------------------------------------}

type
  TMlistView = class(TCustomListView);

procedure MoveListItem(SourceItem, DestItem: TListItem; InsertType: TNodeAttachMode);
var
  OldIndex: integer;
  Index: integer;

  {--------------------------------------------------}

  function CreateItem(Index: Integer; ListItem: TListItem): TLVItem;
  begin
    with Result do
    begin
      mask := LVIF_PARAM or LVIF_IMAGE;
      iItem := Index;
      iSubItem := 0;
      iImage := I_IMAGECALLBACK;
      lParam := Longint(ListItem);
    end;
  end;

  {--------------------------------------------------}

  procedure AssignListItem(S, D: TListItem);
  begin
    with S do
    begin
      D.Caption := Caption;
      D.Data := Data;
      D.ImageIndex := ImageIndex;
      D.OverlayIndex := OverlayIndex;
      D.StateIndex := StateIndex;
      D.SubItems.Text := SubItems.Text;
      {$IFDEF D4}
      D.Indent := Indent;
      if D.Checked <> Checked then
        D.Checked := Checked;
      {$ENDIF}
    end
  end;

  {--------------------------------------------------}

begin
  with TMlistView(SourceItem.ListView) do
  begin
    OldIndex := SourceItem.Index;
    if InsertType = naInsert then
      Index := DestItem.Index
    else
      Index := Items.Count;
    ListView_SetItem(Handle, CreateItem(OldIndex, nil));
    ListView_InsertItem(Handle, CreateItem(Index, nil));
    if OldIndex > Index then
      Inc(OldIndex)
    else
      Dec(Index);
    ListView_DeleteItem(Handle, OldIndex);
    ListView_SetItem(Handle, CreateItem(Index, SourceItem));
    AssignListItem(SourceItem, SourceItem);
  end;
end;

{-------------------------------------------------------------------------}
{$IFDEF D3}

var
  OldCustomModulesProc: TFreeCustomModulesProc;

procedure MyCustomModulesProc(Group: Integer);
var
  i: Integer;
begin
  with ObjectParamList do
  begin
    for i := Count - 1 downto 0 do
      with TObjectParamListItem(Items[i]) do
        if EditorGroup = Group then
        begin
          Items[i].Free;
        end;
  end;
  BroadCastToNotifiers(nil, CM_FREEEDITGROUP, Group, 0);
  //  ShowMessage('HH');
  if Assigned(OldCustomModulesProc) then
    OldCustomModulesProc(Group);
  //  ShowMessage('HH1');
end;

{$ENDIF}

{------------------------------------------------------------------}

var
  FTreeNotifiers: TNotifierListEx;

function GetTreeNotifiers: TNotifierListEx;
begin
  if FTreeNotifiers = nil then
    FTreeNotifiers := TNotifierListEx.Create;
  result := FTreeNotifiers;
end;

{------------------------------------------------------------------}

procedure RegisterTreeSource(ObjClass: TClass; SourceClass: TTreeSourceClass; const EditMethod: string);
begin
  RegisterClassExt(ObjClass, [SvarSourceClass, SvarSourceEditMethod, SvarSourceIdent], [integer(SourceClass), EditMethod, 12]);
end;

{------------------------------------------------------------------}

procedure RegisterDefaultTreeSource(ObjClass: TClass; SourceClass: TTreeSourceClass; const EditMethod: string);
begin
  if EditMethod <> '' then
    RegisterTreeSource(ObjClass, SourceClass, EditMethod);
  RegisterTreeSource(ObjClass, SourceClass, '');
end;

{------------------------------------------------------------------}

function GetRegisteredTreeSource(ObjClass: TClass; const EditMethod: string): TTreeSourceClass;
var
  Item: TObjectParamListItem;
begin
  Item := GetItemInherited(ObjClass, [SvarSourceEditMethod, SvarSourceIdent], [EditMethod, 12], [cpIgnoreCase]);
  {if Item = nil then
    Item :=GetItemInherited (ObjClass,[SvarSourceIdent],[12],[cpIgnoreCase]);}
  if Item = nil then
    result := nil
  else
    result := TTreeSourceClass(integer(Item.Params[SvarSourceClass]));
end;

{-------------------------------------------------------------------------}

procedure LoadUnknownGlyph(Bitmap: TBitmap);
const
  SPalUnknownGlyph = 'PAL_UNKNOWNGLYPH'; //don't resource
begin
  LoadBitmapFromResource(Bitmap, SPalUnknownGlyph);
end;

{------------------------------------------------------------------}

procedure LoadBitmapForClass(Bitmap: TBitmap; AClass: TClass);
var
  ResHandle: THandle;
  ResName: string;

begin
  ResName := FindObjectBitmapResEx(ResHandle, AClass, '');

  if ResHandle <> 0 then
    Bitmap.LoadFromResourceName(ResHandle, ResName)
  else
    LoadUnknownGlyph(Bitmap);
end;

{------------------------------------------------------------------}

procedure LoadBitmapFromResource(Bitmap: TBitmap; const ResName: string);
var
  ResHandle: THandle;
begin
  ResHandle := FindResourceInstance(ResName, RT_BITMAP);
  if ResHandle <> 0 then
    Bitmap.LoadFromResourceName(ResHandle, ResName);
end;

{------------------------------------------------------------------}

procedure TMonoFontProperty.Edit;
begin
end;

{------------------------------------------------------------------}

function TMonoFontProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes - [paDialog];
end;

{******************************************************************}

{$IFDEF SHELLOBJ}
type
  TComputerNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  {------------------------------------------------------------------}

procedure TComputerNameProperty.Edit;
var
  cname: string;
begin
  if QueryComputer('', cname) then
    Value := cname;
end;

{------------------------------------------------------------------}

function TComputerNameProperty.GetAttributes: TPropertyAttributes;
begin
  result := inherited GetAttributes + [paDialog];
end;

{$ENDIF}
{******************************************************************}

procedure _Register;
begin
end;

{------------------------------------------------------------------}

procedure DeleteTab(TabControl: TTabControl; const TabCaption: string);
var
  i: Integer;
begin
  with TabControl, Tabs do
  begin
    i := IndexOf(TabCaption);
    if i >= 0 then
    begin
      Delete(i);
      TabIndex := Min(i, Count - 1);
    end;
  end;
end;

{-------------------------------------------------------------------------}

procedure CorrectMemoText(Memo: TMemo);
var
  TempStr: string;
  DelimPos: Integer;
begin
  TempStr := RemoveCharSet([#13, #10], Memo.Text);
  repeat
    DelimPos := Pos('_', TempStr);
    if DelimPos > 0 then
    begin
      Delete(TempStr, DelimPos, 1);
      Insert(#13#10, TempStr, DelimPos);
    end;
  until DelimPos <= 0;
  Memo.Text := TempStr;
end;

{-------------------------------------------------------------------------}

function GetVCLControlFromHWND(handle: THandle): TWinControl;
begin
  result := nil;

  while handle <> 0 do
  begin
    result := FindControl(Handle);
    if result <> nil then
      exit;
    handle := windows.GetParent(handle);
  end;
end;

{------------------------------------------------------------------}

{$IFDEF SHELLOBJ}

function QueryComputer(const ATitle: string; var Computer: string): boolean;
begin
  result := QueryComp(ATitle, Computer, Application.Handle);
end;
{$ENDIF}

{------------------------------------------------------------------}

function GetStringSize(const S: string; font: HFONT;
  var ascent, descent, overhang: integer): TSize;
var
  dc: THandle;
  SaveFont: THandle;
  tm: TTextMetric;
begin
  dc := GetDC(0);
  SaveFont := SelectObject(DC, font);
  GetTextExtentPoint32(dc, @S[1], length(s), result);
  GetTextMetrics(DC, tm);
  ascent := tm.tmAscent;
  descent := tm.tmDescent;
  overhang := tm.tmOverhang;
  inc(result.cx, Overhang);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
end;

{------------------------------------------------------------------}

function GetSymbolSize(c: Char; font: HFONT;
  var ascent, descent, overhang: integer): TSize;
begin
  Result := GetStringSize(C, font, ascent, descent, overhang);
end;

{------------------------------------------------------------------}

function GetSymbolWidth(c: char; font: HFONT): integer;
var
  z: integer;
begin
  result := GetSymbolSize(c, font, z, z, z).cx;
end;

{------------------------------------------------------------------}

function GetSymbolHeight(c: char; font: HFONT): integer;
var
  z: integer;
  ascent: integer;
  descent: integer;
begin
  GetSymbolSize(c, font, ascent, descent, z);
  result := ascent + descent;
end;

{------------------------------------------------------------------}

procedure ShowMessageEx(const M: Variant);
begin
  ShowMessage(M);
end;

{------------------------------------------------------------------}

function GetWheelScrollLines: integer;
begin
  SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @result, 0);
end;

{------------------------------------------------------------------}

type
  TPCNotifierInfo = class
  public
    Instance: TObject;
    NotifyProc: TPropChangeProc;
  end;

  TPCNotifiers = class(TSortedList)
  protected
    function CompareWithKey(Item, Key: pointer): Integer; override;
  end;

var
  PCNotifiers: TPCNotifiers;

type
  TPCMessageAnswer = class(TMessageAnswer)
  public
    procedure CMPROPCHANGED(var Message: TMessage); message CM_PROPCHANGED;
  end;

procedure TPCMessageAnswer.CMPROPCHANGED(var Message: TMessage);
var
  l: TSortedList;

  procedure _add(Instance: TPersistent);
  var
    i: integer;
  begin
    i := PCNotifiers.IndexOfKey(Instance);
    if i < 0 then
      exit;

    l.Add(pointer(i));
  end;

var
  i: integer;
begin
  l := TSortedList.Create;
  try
    l.Duplicates := dupIgnore;
    with TList(Message.wParam) do
      for i := 0 to Count - 1 do
        _add(TPersistent(Items[i]));

    for i := 0 to l.Count - 1 do
      TPCNotifierInfo(PCNotifiers[integer(l[i])]).NotifyProc(TList(Message.wParam));
  finally
    l.Free;
  end;
end;

{------------------------------------------------------------------}

function TPCNotifiers.CompareWithKey(Item, Key: pointer): integer;
begin
  result := inherited Compare(TPCNotifierInfo(Item).Instance, Key);
end;

{******************************************************************}

procedure RegisterPropChangesNotifier(Instance: TPersistent; PropChangeProc: TPropChangeProc);
var
  info: TPCNotifierInfo;
begin
  info := TPCNotifierInfo.Create;
  info.Instance := Instance;
  info.NotifyProc := PropChangeProc;
  PCNotifiers.Add(info);
end;

{------------------------------------------------------------------}

procedure UnRegisterPropChangesNotifier(Instance: TPersistent; PropChangeProc: TPropChangeProc);
var
  i: integer;
begin
  i := PCNotifiers.IndexOfKey(Instance);
  if i >= 0 then
    PCNotifiers.Delete(i);
end;

{------------------------------------------------------------------}

procedure _InstantRegister;
begin
  RegisterPropertyEditor(TypeInfo(string), TComponent, 'FileName', TFileNameEdit); //don't resource
  {$IFDEF D3}
  RegisterPropertyEditor(TypeInfo(string), TComponent, 'ComputerName', TComputerNameProperty); //don't resource
  {$ENDIF}
end;

{------------------------------------------------------------------}

procedure RunRegister;
begin
  RegisterForDelphi(_Register);
  RegisterForInstant(_InstantRegister);
end;

{$IFDEF D4}

{------------------------------------------------------------------}

procedure TDCIDEAction.UpdateVerbObject;
var
  Item: TObjectParamListItem;
begin
  if (csDesigning in ComponentState) then
    exit;
  FVerbGetState := nil;
  FVerbExecute := nil;
  if (VerbName = '') then
    exit;
  Item := GetVerbProcAddr(FVerbName, FVerbGetState, FVerbExecute);
  if (Item <> nil) then
  begin
    FDesignGroup := Item.EditorGroup;
    Update;
  end;
end;

{------------------------------------------------------------------}

procedure TDCIDEAction.SetVerbName(const V: string);
begin
  if FVerbName <> V then
  begin
    FVerbName := Trim(V);
    UpdateVerbObject;
  end;
end;

{------------------------------------------------------------------}

function TDCIDEAction.Execute: boolean;
begin
  Result := False;
  if Assigned(FverbExecute) then
  begin
    IDEBeginUpdate;
    try
      FVerbExecute;
      Result := True;
    finally
      IDEEndUpdate;
    end;
  end;
end;

{------------------------------------------------------------------}

function TDCIDEAction.Update: boolean;
var
  FNewStates: TVerbStates;
begin
  FNewStates := [vsVisible, vsEnabled];
  if Assigned(FVerbGetState) then
    FVerbGetState(FNewStates);
  Visible := vsVisible in FNewStates;
  Enabled := vsEnabled in FNewStates;
  Checked := vsChecked in FNewStates;
  Result := True;
end;

{$ENDIF}

{------------------------------------------------------------------}

var
  _MessageAnswer: TPCMessageAnswer;

  {------------------------------------------------------------------}

constructor TAppExceptionObject.Create;
begin
  inherited;
  Application.OnException := ExceptionEvent;
end;

{------------------------------------------------------------------}

procedure TAppExceptionObject.ExceptionEvent(Sender: TObject; E: Exception);
begin
  Application.ShowException(E);
end;

{------------------------------------------------------------------}

type
  TMWinControl = class(TWinControl);

procedure UpdateDisabledControls(AOwner: TComponent);
var
  i: integer;
begin
  with AOwner do
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TWinControl then
        with TMWinControl(Components[i]) do
          if (Parent <> nil) and not (Enabled and Visible) then
          begin
            HandleNeeded;
            RecreateWnd;
          end;
end;

{------------------------------------------------------------------}

{-----------TDCFileOperation-----------------------------------------}

constructor TDCFileOperation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [ffAllowUndo, ffFilesOnly, ffRenameCollision];
  FSourceFiles := TStringList.Create;
end;

{------------------------------------------------------------------}

destructor TDCFileOperation.Destroy;
begin
  FSourceFiles.Free;
  inherited Destroy;
end;

{------------------------------------------------------------------}

function TDCFileOperation.Execute: boolean;
begin
  result := ExecuteOperation(FOperation);
end;

{------------------------------------------------------------------}

function TDCFileOperation.Copy: boolean;
begin
  result := ExecuteOperation(foCopy);
end;

{------------------------------------------------------------------}

function TDCFileOperation.Delete: boolean;
begin
  result := ExecuteOperation(foDelete);
end;

{------------------------------------------------------------------}

function TDCFileOperation.Move: boolean;
begin
  result := ExecuteOperation(foMove);
end;

{------------------------------------------------------------------}

function TDCFileOperation.Rename: boolean;
begin
  result := ExecuteOperation(foRename);
end;

{------------------------------------------------------------------}

procedure TDCFileOperation.SetSourceFiles(Value: TStrings);
begin
  FSourceFiles.Assign(Value);
end;

{------------------------------------------------------------------}

function TDCFileOperation.GetSystemError(AError: integer): string;
var
  Buff: array[0..1023] of Char;
begin
  if AError <> 0 then
  begin
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, AError, 0, Buff, SizeOf(Buff), nil);
    result := Buff;
  end
  else
    result := '';
end;

{------------------------------------------------------------------}

{$IFNDEF D3}
const
  FOF_NOERRORUI = $0400;
  {$ENDIF}

function TDCFileOperation.ExecuteOperation(OpType: TFileOperationType): boolean;
var
  SHFileOpStruct: TSHFileOpStruct;
  F: TCustomForm;
  FMultipleFiles: boolean;
  Sourcestr: string;
  Deststr: string;
  ErrStr: string;
  i: integer;
  p: integer;
  ARes: integer;

  {-------------------------------------------------------}

  procedure FillCharStr(pch: pchar; const S: string);
  var
    Temp: Pchar;
    Sl: TStrings;
    Index: integer;
    i: integer;
  begin
    Sl := TStringList.Create;
    try
      Sl.CommaText := S;
      Index := 0;
      for i := 0 to sl.Count - 1 do
        if Sl[i] <> '' then
        begin
          Temp := Pchar(Sl[i]);
          System.Move(Temp^, pch[Index], Length(Temp));
          Inc(Index, Length(Temp) + 1);
        end;
    finally
      sl.Free;
    end;
  end;

  {-------------------------------------------------------}

begin
  with SHFileOpStruct do
  begin
    if Owner is TWinControl then
      Wnd := TWinControl(Owner).Handle
    else
    begin
      F := GetPForm(Owner);
      if F <> nil then
        Wnd := F.Handle
      else
        Wnd := Application.Handle;
    end;
    case OpType of
      foCopy: wFunc := FO_COPY;
      foDelete: wFunc := FO_DELETE;
      foMove: wFunc := FO_MOVE;
      foRename: wFunc := FO_RENAME;
    end;
    FMultipleFiles := Pos('=', FSourceFiles.Text) <> 0;
    fFlags := 0;
    if ffAllowUndo in FOptions then
      fFlags := fFlags or FOF_ALLOWUNDO;
    if ffFilesOnly in FOptions then
      fFlags := fFlags or FOF_FILESONLY;
    if ffNoConfirmation in FOptions then
      fFlags := fFlags or FOF_NOCONFIRMATION;
    if ffNoConfirmMkDir in FOptions then
      fFlags := fFlags or FOF_NOCONFIRMMKDIR;
    if ffNoErrorUI in FOptions then
      fFlags := fFlags or FOF_NOERRORUI;
    if ffRenameCollision in FOptions then
      fFlags := fFlags or FOF_RENAMEONCOLLISION;
    if ffSilent in FOptions then
      fFlags := fFlags or FOF_SILENT;
    if ffSimpleProgress in FOptions then
      fFlags := fFlags or FOF_SIMPLEPROGRESS;
    if FMultipleFiles then
      fFlags := fFlags or FOF_MULTIDESTFILES;
    fAnyOperationsAborted := false;
    hNameMappings := nil;
    lpszProgressTitle := PChar(ProgressTitle);
    Sourcestr := '';
    DestStr := '';
    with FSourceFiles do
      for i := 0 to FSourceFiles.Count - 1 do
      begin
        if FMultipleFiles then
        begin
          p := pos('=', Strings[i]);
          if p <> 0 then
          begin
            Sourcestr := SourceStr + System.copy(Strings[i], 1, p - 1) + ',';
            if FDestFolder <> '' then
              DestStr := DestStr + AddSlash(FDestFolder);
            DestStr := DestStr + System.copy(Strings[i], p + 1, length(Strings[i]) - p) + ',';
          end;
        end
        else
          Sourcestr := SourceStr + Strings[i] + ',';
      end;
    i := Length(FSourceFiles.Text) + FSourceFiles.Count + 1;
    GetMem(pFrom, i);
    FillChar(pFrom^, i, #0);
    if FMultipleFiles then
      i := Length(Deststr) + FSourceFiles.Count + 1
    else
      i := Length(FDestFolder) + 2;
    GetMem(pTo, i);
    FillChar(pTo^, i, #0);
    try
      FillCharStr(pFrom, Sourcestr);
      if FMultipleFiles then
        FillCharStr(pTo, Deststr)
      else
        StrCopy(pTo, Pchar(FDestFolder));

      ErrStr := '';
      ARes := SHFileOperation(SHFileOpStruct);
      if (ARes <> 0) and (ARes <> ERROR_NO_MORE_FILES) then
      begin
        ErrStr := GetSystemError(ARes);
        Error(ErrStr);
      end;
    finally
      FreeMem(pFrom);
      FreeMem(pTo);
    end;
  end;
  result := ARes = 0;
end;

{------------------------------------------------------------------}

function TDCFileOperation.Error(const S: string): boolean;
begin
  result := false;
  if Assigned(FOnError) then
    FOnError(Self, S, result);
end;

{--------------------------------------------}

type
  TUsedModulesData = class
  private
    FInstance: TComponent;
    procedure PropCallBack(Instance: TPersistent; PropInfo: PPropInfo;
      UserData: Integer);
  public
    procedure GetUsedModules(Instance: TComponent; UsedModules: TList);
  end;

  {--------------------------------------------}

procedure TUsedModulesData.PropCallBack(Instance: TPersistent; PropInfo: PPropInfo;
  UserData: Integer);
var
  Value: TObject;
  ValueOwner: TComponent;
begin
  Value := TObject(GetOrdProp(Instance, PropInfo));
  if Value is TPersistent then
  begin
    ValueOwner := GetTopOwner(TPersistent(Value));
    if (Value <> FInstance) and (ValueOwner <> nil) then
      TList(UserData).Add(ValueOwner);
  end;
end;

{--------------------------------------------}

procedure TUsedModulesData.GetUsedModules(Instance: TComponent; UsedModules: TList);

  procedure ProcessComp(AComp: TComponent);
  begin
    if not (csDestroying in AComp.ComponentState) then
      IterateProps(AComp, [tkClass], PropCallBack, False, Integer(UsedModules));
  end;

var
  i: Integer;
begin
  FInstance := Instance;
  ProcessComp(Instance);
  with Instance do
    for i := ComponentCount - 1 downto 0 do
      ProcessComp(Components[i]);
end;

{--------------------------------------------}

procedure GetUsedModules(Instance: TComponent; UsedModules: TList);
var
  U: TUsedModulesData;
begin
  U := TUsedModulesData.Create;
  try
    UsedModules.Clear;
    U.GetUsedModules(Instance, UsedModules);
  finally
    U.Free;
  end;
end;

{------------------------------------------------------------------}

function CopyFileList(FileList: TStrings): boolean;
begin
  with TDCFileOperation.Create(nil) do
  try
    Operation := foCopy;
    SourceFiles := FileList;
    result := Execute;
  finally
    Free;
  end;
end;

{------------------------------------------------------------------}

function DirectoryExists(const Name: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(Name));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

{------------------------------------------------------------------}

function DeleteFolder(const Folder: string): boolean;
var
  AFolder: string;
begin

  if (Folder = '') or (not DirectoryExists(Folder)) then
  begin
    result := true;
    exit;
  end;

  AFolder := Folder;

  if Folder[Length(AFolder)] = '\' then
    Delete(AFolder, Length(AFolder), 1);

  with TDCFileOperation.Create(nil) do
  try
    Operation := foDelete;
    SourceFiles.Text := AFolder;
    FOptions := FOptions + [ffNoConfirmation] - [ffFilesOnly, ffAllowUndo];
    result := Execute;
  finally
    Free;
  end;
end;

{******************************************************************}

{$IFDEF LOGFILE}
type
  TLogAppException = class(TAppExceptionObject)
    procedure ExceptionEvent(Sender: TObject; E: Exception); override;
  end;

procedure TLogAppException.ExceptionEvent(Sender: TObject; E: Exception);
begin
  WriteToLog('Exception: ' + E.Message); //don't resource
  inherited;
end;

var
  LogAppEx: TLogAppException = nil;

procedure EnableLogExceptions;
begin
  if LogAppEx = nil then
    LogAppEx := TLogAppException.Create;
end;
{$ENDIF}

{------------------------------------------------------------------}

type
  TCompListItem = class(TCollectionItem)
  public
    Comp: TComponent;
    ErrorRead: boolean;
    FileName: string;
    CompFiler: TCompFiler;
    destructor Destroy; override;
  end;

  TD3D2Strings = class(TStringList)
  private
    FCompList: TCollection;
  public
    procedure D3FormToD2Form(const AFileName: string);
    procedure ProcessLoadedForms(const NewDir: string);
    procedure RError(Reader: TReader; const Message: string; var Handled: Boolean);
    constructor Create;
    destructor Destroy; override;
  end;

  {---------------------------------------------------------------}

constructor TD3D2Strings.Create;
begin
  inherited;
  FCompList := TCollection.Create(TCompListItem);
end;

{---------------------------------------------------------------}

destructor TCompListItem.Destroy;
begin
  Comp.Free;
  CompFiler.Free;
  inherited;
end;

{---------------------------------------------------------------}

procedure TD3D2Strings.ProcessLoadedForms(const NewDir: string);
var
  i: Integer;
begin
  with FCompList do
  begin
    try
      for I := Count - 1 downto 0 do
        with TCompListItem(Items[i]) do
          if CompareText(NewDir, ExtractFilePath(FileName)) <> 0 then
            if ErrorRead then
            begin
              RenameToBak(FileName);
              CompFiler.SaveToFile(FileName, comp);
              WriteToLog(Format('Form %s converted', [FileName])); //don't resource
            end;
    finally
      for I := Count - 1 downto 0 do
        with TCompListItem(Items[i]) do
          if CompareText(NewDir, ExtractFilePath(FileName)) <> 0 then
            Free;
    end;
  end;
end;

{---------------------------------------------------------------}

destructor TD3D2Strings.Destroy;
begin
  ProcessLoadedForms('___');
  FCompList.Free;
  inherited;
end;

{---------------------------------------------------------------}

procedure TD3D2Strings.D3FormToD2Form(const AFileName: string);
begin
  ProcessLoadedForms(ExtractFilePath(AFileName));
  with TCompListItem(FCompList.Add) do
  begin
    CompFiler := TCompFiler.Create;
    CompFiler.OnReaderError := RError;
    FileName := AFileName;
    comp := CompFiler.CreateFromFile(FileName, TForm, True);
    GlobalFixupReferences;
  end;
end;

{---------------------------------------------------------------}

procedure TD3D2Strings.RError(Reader: TReader; const Message: string; var Handled: Boolean);
begin
  WriteToLog('  ' + Message);
  Handled := true;
  with FCompList do
    TCompListItem(Items[Count - 1]).ErrorRead := True;
end;

{---------------------------------------------------------------}

procedure CorrectFormFiles(Path: string; SubFolders: boolean);

procedure _Iterat(const Path: string);
  var
    SearchRec: TSearchRec;
    R: Integer;
    MyPath, MyFile: string;
    AContinue: boolean;
    FirstR: Integer;
    Files: TD3D2Strings;
    i: Integer;
    FileName: string;
  begin
    MyPath := AddSlash(ExtractFilePath(Path));
    MyFile := ExtractFileName(Path);

    Files := TD3D2Strings.Create;

    //----- search and process files -------------

    FirstR := FindFirst(Path, faAnyFile, SearchRec);
    R := FirstR;
    try
      AContinue := True;
      while (R = 0) and AContinue do
      begin
        if faAnyFile <> faDirectory then
          Files.Add(MyPath + SearchRec.Name);
        R := FindNext(SearchRec);
      end;
    finally
      if FirstR = 0 then
        SysUtils.FindClose(SearchRec);
    end;

    with Files do
    try
      for I := 0 to Count - 1 do
      begin
        FileName := Strings[I];
        FileName := ExpandFileName(FileName);
        ChDir(ExtractFilePath(FileName));
        D3FormToD2Form(ExtractFileName(FileName));
        WriteToLog(FileName);
      end;
    finally
      Free;
    end;

    //----------------- iterate subfolders if needed ----------
    if SubFolders then
    begin
      FirstR := FindFirst(MyPath + '*.*', faDirectory, SearchRec);
      R := FirstR;
      try
        while R = 0 do
        begin
          if (SearchRec.Name[1] <> '.') and (SearchRec.Attr and faDirectory <> 0) then
            _Iterat(MyPath + SearchRec.Name + '\' + MyFile);
          R := FindNext(SearchRec);
        end;
      finally
        if FirstR = 0 then
          SysUtils.FindClose(SearchRec);
      end;
    end;
  end;

begin
  if CompareText(ExtractFileExt(Path), '.DFM') <> 0 then //don't resource
    Path := AddSlash(Path) + '*.dfm'; //don't resource
  _Iterat(Path);
end;

{******************************************************************}

function ToolsFormStyle: TFormStyle;
const
  styles: array[boolean] of TFormStyle = (fsNormal, fsStayOnTop);
begin
  result := styles[ToolFormsOnTop];
end;

{------------------------------------------------------------------}

type
  _TApplication = class(TComponent)
  private
    FHandle: HWnd;
    {$IFDEF D4}
    FBiDiMode: TBiDiMode;
    {$ENDIF}
    FObjectInstance: Pointer;
    FMainForm: TForm;
  end;

procedure SetMainFOrm(AForm: TForm);
begin
  if AForm = nil then
    Exit;
  AForm.HandleNeeded;
  _TApplication(Application).FMainForm := AForm;
  Exit;
  _TApplication(nil).FHandle := 0;
  {$IFDEF D4}
  _TApplication(nil).FBiDiMode := bdLeftToRight;
  {$ENDIF}
  _TApplication(nil).FObjectInstance := nil;
  _TApplication(nil).FMainForm := nil;
end;

{------------------------------------------------------------------}

{$IFNDEF D4}
type
  TPublicCustomForm = class(TScrollingWinControl)
  private
    FActiveControl: TWinControl;
    FFocusedControl: TWinControl;
    FBorderIcons: TBorderIcons;
    FBorderStyle: TFormBorderStyle;
    FWindowState: TWindowState;
    FShowAction: TShowAction;
    FKeyPreview: Boolean;
    FActive: Boolean;
    FFormStyle: TFormStyle;
    FPosition: TPosition;
    FTileMode: TTileMode;
    FFormState: TFormState;
  end;
  {$ENDIF}

function IsFormModal(AForm: TForm): Boolean;
begin
  {$IFDEF D4}
  Result := fsModal in AForm.FormState;
  {$ELSE}
  Result := fsModal in TPublicCustomForm(AForm).FFormState;
  Exit;
  with TPublicCustomForm(nil) do
  begin
    FActiveControl := nil;
    FFocusedControl := nil;
    FBorderIcons := [];
    FBorderStyle := TBorderStyle(0);
    FWindowState := TWindowState(0);
    FShowAction := TShowAction(0);
    FKeyPreview := False;
    FActive := False;
    FFormStyle := TFormStyle(0);
    FPosition := TPosition(0);
    FTileMode := TTileMode(0);
  end;
  {$ENDIF}
end;

initialization
  {$IFDEF D3}
  if CurrentGroup < 0 then
    NewEditorGroup;

  OldCustomModulesProc := FreeCustomModulesProc;
  FreeCustomModulesProc := MyCustomModulesProc;
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(string), TFakeComponent, 'NN', TFakePropertyEditor); //don't resource
  RegisterComponentEditor(TFakeComponent, TFakeComponentEditor);
  UnderDelphiIDE := IsColorPropertyRegistered;
  TDCApplication.Create;

  SafeRegisterClass(TPropFileSystem);
  RunRegister;

  PCNotifiers := TPCNotifiers.Create;
  _MessageAnswer := TPCMessageAnswer.Create;

  BuildCompNameFunc := _BuildCompName;

  GetDesignerProc := TGetDesignerProc(Addr(GetDesigner));
  CallPropEditProc := CallPropertyEditor;

  {$IFDEF LOGFILE}
  EnableLogExceptions;
  {$ENDIF}

finalization
  {$IFDEF D3}
  if @FreeCustomModulesProc = @MyCustomModulesProc then
    FreeCustomModulesProc := OldCustomModulesProc;
  {$ENDIF}

  FreeObject(App);
  FreeObject(fADesignerList);
  FreeObject(FDataModuleWrappers);
  FreeObject(FTreeNotifiers);
  _MessageAnswer.Free;
  FreeSortedList(PCNotifiers);
end.

