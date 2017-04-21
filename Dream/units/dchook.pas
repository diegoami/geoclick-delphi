{*******************************************************}
{                                                       }
{            TObject free notification                  }
{                                                       }
{  Copyright (c) 1997-2000 Dream Company                }
{  http://www.dream-com.com                             }
{  e-mail: contact@dream-com.com                        }
{                                                       }
{*******************************************************}
unit dchook;

interface
{$I dc.inc}
{$D-,L-,Y-}

uses
  {$IFDEF WIN32}
  messages, windows,
  {$ENDIF}

  classes, sysutils, dcconsts,
  dcClasses;

type
  TFreeNotifyProc = procedure(Instance : TObject) of object;

procedure dcAddFreeNotification(Instance : TObject; Proc : TFreeNotifyProc);
procedure dcRemoveFreeNotification(Instance : TObject; Proc : TFreeNotifyProc);

type
  THookInfo = packed record
    ProcAddr : Pointer;
    OldSrc   : array[0..4] of byte;
  end;

procedure RestoreHook(const HookInfo : THookInfo);
function  SetupHook(Proc, NewProc : Pointer) : THookInfo;

{$IFDEF WIN}
Type
  TCustomActiveNotifier = class(TComponent)
  private
    fOnActiveChanged : TNotifyEvent;
  protected
    procedure HookProc(const Msg : TCWPRetStruct);virtual;
  public
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;

    property OnActiveChanged : TNotifyEvent read fOnActiveChanged write fOnActiveChanged;
  end;
{$ENDIF}

implementation


Procedure RestoreHook(const HookInfo:THookInfo);
Begin
  If HookInfo.ProcAddr<>Nil Then
    WriteMemory(HookInfo.ProcAddr, @HookInfo.OldSrc[0], SizeOf(HookInfo.OldSrc));
End;

{---------------------------------------------------------}

Function CalcJmpOffset(Src,Dest:Pointer):Longint;
Begin
  Result:=Longint(Dest)-(Longint(Src)+5);
End;

{---------------------------------------------------------}

Function SetupHook(Proc,NewProc:Pointer):THookInfo;
Var
  NewSrc:Array[0..4] Of Byte;
Begin
  Integer((@Result.OldSrc[0])^):=Integer(Proc^);
  Result.OldSrc[4]:=Ord(PChar(Proc)[4]);
  NewSrc[0]:=$E9;
  Integer((@NewSrc[1])^):=CalcJmpOffset(Proc,NewProc);
  if WriteMemory(Proc,@NewSrc[0],SizeOf(NewSrc)) then
    Result.ProcAddr:=Proc
  Else
    Result.ProcAddr:=Nil;
End;

{---------------------------------------------------------}

{$IFDEF WIN}
var
  WHook : HHook=0;
  Fhooks : TList;

function Hooks:TList;
begin
  if fHooks = nil then
    fHooks := TList.Create;
  result := fHooks;
end;

{------------------------------------------------------------------}



function CallWndProcHook(nCode : integer; wParam : Longint; var Msg : TCWPRetStruct) : longint; stdcall;
var
  i  : integer;
begin
  result := 0;
//  Result := CallNextHookEx(WHook, nCode, wParam, Longint(@Msg));
  if (nCode = HC_ACTION) and (Msg.Message = WM_SETFOCUS) then
    for i := 0 to hooks.Count - 1 do
      with TCustomActiveNotifier(hooks[i]) do
        HookProc(Msg);
end;

{------------------------------------------------------------------}

procedure AddHook(o : TCustomActiveNotifier);
begin
  if hooks.Count = 0 then
    WHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @CallWndProcHook, 0, GetCurrentThreadId);
  hooks.Add(o);
end;

{------------------------------------------------------------------}

procedure RemoveHook(o : TCustomActiveNotifier);
begin
  hooks.Remove(o);
  if hooks.Count = 0 then
    UnHookWindowsHookEx(WHook);
end;

{------------------------------------------------------------------}

procedure FreeHook;
begin
  if WHook <> 0 then
    UnHookWindowsHookEx(WHook);

  FHooks.Free;
  fHooks := nil;
end;

{------------------------------------------------------------------}

constructor TCustomActiveNotifier.Create(AOwner : TComponent);
begin
  inherited;
  AddHook(self);
end;

{-----------------------------------------------------------}

destructor  TCustomActiveNotifier.Destroy;
begin
  RemoveHook(self);
  inherited;
end;

{-----------------------------------------------------------}

procedure TCustomActiveNotifier.HookProc(const Msg : TCWPRetStruct);
begin
  if Assigned(OnActiveChanged) then
    OnActiveChanged(self);
end;

{$ENDIF}

{******************************************************************}

type
  TFreeNotifier = class
  public
    Proc : TFreeNotifyProc;
  end;

  TFreeNotifierInfo = class
  public
    Instance  : TObject;
    Notifiers : TList;
    OldDestroy : pointer;
    fDestroying : boolean;

    constructor Create(AInstance : TObject);
    destructor Destroy; override;
  end;

  TFreeNotifiersList = class(TCustomSortedList)
  protected
    function  CompareWithKey(Item, Key : pointer) : Integer; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;
  end;

var
  FreeNotifiers  : TFreeNotifiersList;

{******************************************************************}

function  TFreeNotifiersList.Compare(Item1, Item2: Pointer) : integer;
begin
  result := integer(TFreeNotifierInfo(Item1).Instance) - integer(TFreeNotifierInfo(Item2).Instance);
end;

{------------------------------------------------------------------}

function TFreeNotifiersList.CompareWithKey(Item, Key : pointer) : Integer;
begin
  result := integer(TFreeNotifierInfo(Item).Instance) - integer(Key);
end;

{******************************************************************}

function GetFreeNotifierInfo(Instance : TObject) : TFreeNotifierInfo;
var
  i : integer;
begin
  result := pointer(FreeNotifiers);
  if result = nil then
    exit;
  result := pointer(TFreeNotifiersList(result).Count);
  if integer(result) = 0 then
    exit;
  i := FreeNotifiers.IndexOfKey(Instance);
  result := nil;
  if i >= 0 then
    result := TFreeNotifierInfo(FreeNotifiers[i]);
end;

{------------------------------------------------------------------}

constructor TFreeNotifierInfo.Create(AInstance : TObject);
begin
  inherited Create;
  Notifiers := TList.Create;
  Instance := AInstance;
end;

{------------------------------------------------------------------}

destructor TFreeNotifierInfo.Destroy;
var
  i : integer;
begin
  fDestroying := true;

  if Notifiers <> nil then
    with Notifiers do
      begin
        for i := 0 to Count - 1 do
          TObject(List[i]).Free;

        Free;
      end;

  inherited;
end;

{******************************************************************}

procedure dcAddFreeNotification(Instance : TObject; Proc : TFreeNotifyProc);
var
  info : TFreeNotifierInfo;
  fnotifier : TFreeNotifier;
begin
  if Instance = nil then
    exit;

  info := GetFreeNotifierInfo(Instance);
  if info = nil then
    begin
      info := TFreeNotifierInfo.Create(Instance);
      FreeNotifiers.Add(info);
    end;

  fnotifier := TFreeNotifier.Create;
  fnotifier.Proc := Proc;
  info.Notifiers.Add(fnotifier);
end;

{------------------------------------------------------------------}

Function isMethodsEqual(Var A,B):Boolean;
begin
  Result:=(TMethod(A).Data=TMethod(b).Data) and (TMethod(A).Code=TMethod(B).Code);
end;

{------------------------------------------------------------------}

procedure dcRemoveFreeNotification(Instance : TObject; Proc : TFreeNotifyProc);
var
  info : TFreeNotifierInfo;
  i    : integer;
begin
  info := GetFreeNotifierInfo(Instance);
  if info <> nil then
    with info do
      if not fDestroying then
        begin
          with Notifiers do
            for i := Count - 1 downto 0 do
              if (List[i] <> nil) and
                IsMethodsEqual(TFreeNotifier(List[i]).Proc, Proc) then
                  begin
                    TFreeNotifier(List[i]).Free;
                    Delete(i);
                  end;

          if Notifiers.Count = 0 then
            begin
  //            UnHookDestroy(Instance, OldDestroy);

              FreeNotifiers.Remove(info);
              Free;
            end;
    end;
end;

{******************************************************************}

var
  MManager : TMemoryManager;

function MFreeMem(P: Pointer): Integer;
var
  info : TFreeNotifierInfo;
  i    : integer;
  n    : TFreeNotifier;
begin
  result := MManager.FreeMem(P);
  
  info := GetFreeNotifierInfo(P);
  if info <> nil then
    with info do
      begin
        i := 0;

        FreeNotifiers.Remove(info);

//        Notifiers.Add(nil);

        while i < Notifiers.Count do
          begin
            n := Notifiers[i];
            if n <> nil then
              TFreeNotifier(Notifiers[i]).Proc(Instance);
            if n = Notifiers[i] then
              inc(i);
          end;

(*
        for i := 0 to Notifiers.Count - 2 do
          if Notifiers[i] <> nil then
            TFreeNotifier(Notifiers[i]).Proc(Instance);
*)
        Free;
      end;
end;

{------------------------------------------------------------------}

function MGetMem(Size: Integer): Pointer;
begin
  result := MManager.GetMem(Size);
end;

{------------------------------------------------------------------}

function MReallocMem (P: Pointer; Size: Integer): Pointer;
begin
  result := MManager.ReallocMem(P, Size);
end;

{------------------------------------------------------------------}

function getnotnil(p1, p2 : pointer) : pointer;
begin
  if p1 <> nil then
    result := p1
  else
    result := p2;
end;

{------------------------------------------------------------------}

procedure FreeNotifiersList;
var
  item : TObject;
begin
  with FreeNotifiers do
    begin
      while Count > 0 do
        begin
          item := Items[0];
          Delete(0);
          item.Free;
        end;
      Free;
    end;
  FreeNotifiers := nil;  
end;

const
  NewManager : TMemoryManager =
    ( GetMem : MGetMem;
      FreeMem : MFreeMem;
      ReallocMem : MReallocMem);
var
  OldMManager : TMemoryManager;

initialization
  FreeNotifiers := TFreeNotifiersList.Create;


  GetMemoryManager(OldMManager);
  SetMemoryManager(NewManager);

  with MManager do
    begin
      GetMem := getnotnil(@OldMManager.GetMem, @SysGetMem);
      FreeMem := getnotnil(@OldMManager.FreeMem, @SysFreeMem);
      ReallocMem := getnotnil(@OldMManager.ReallocMem, @SysReallocMem);
    end;



finalization
  {$IFDEF WIN}
  FreeHook;
  {$ENDIF}
  SetMemoryManager(OldMManager);
  FreeNotifiersList;

end.
