unit UniSettings_NodePrimitiveArray;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodePrimitiveArray = class(TUNSNodeLeaf)
  protected
    class Function GetNodeType: TUNSNodeType; override;
    class Function GetItemValueType: TUNSValueType; virtual;
    class Function SameItemValues(const A,B): Boolean; virtual; abstract;
    Function GetCount: Integer; virtual; abstract;
    Function GetSavedCount: Integer; virtual; abstract;
    Function GetDefaultCount: Integer; virtual; abstract;
    Function GetItemSize(Index: Integer): TMemSize; virtual; abstract;
    Function GetSavedItemSize(Index: Integer): TMemSize; virtual; abstract;
    Function GetDefaultItemSize(Index: Integer): TMemSize; virtual; abstract; 
    Function ConvItemToStr(const Value): String; virtual; abstract;
    Function ConvItemFromStr(const Str: String): Pointer; virtual; abstract;
  public
    destructor Destroy; override;
    Function ObtainCount(ValueKind: TUNSValueKind): Integer; virtual;
    Function ObtainItemSize(Index: Integer; ValueKind: TUNSValueKind): TMemSize; virtual;
    procedure ValueKindMove(Index: Integer; Src,Dest: TUNSValueKind); overload; virtual; abstract;
    procedure ValueKindExchange(Index: Integer; ValA,ValB: TUNSValueKind); overload; virtual; abstract;
    Function ValueKindCompare(Index: Integer; ValA,ValB: TUNSValueKind): Boolean; overload; virtual; abstract;
    procedure ActualFromDefault(Index: Integer); overload; virtual;
    procedure DefaultFromActual(Index: Integer); overload; virtual;
    procedure ExchangeActualAndDefault(Index: Integer); overload; virtual;
    Function ActualEqualsDefault(Index: Integer): Boolean; overload; virtual;
    procedure Save(Index: Integer); overload; virtual;
    procedure Restore(Index: Integer); overload; virtual;       
    Function Address(Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer; overload; virtual; abstract;
    Function AsString(Index: Integer; ValueKind: TUNSValueKind = vkActual): String; overload; virtual; abstract;
    procedure FromString(Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    procedure ToStream(Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    procedure FromStream(Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    Function AsStream(Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryStream; overload; virtual;
    procedure ToBuffer(Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    procedure FromBuffer(Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    Function AsBuffer(Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer; overload; virtual;
    Function LowIndex(ValueKind: TUNSValueKind = vkActual): Integer; virtual; abstract;
    Function HighIndex(ValueKind: TUNSValueKind = vkActual): Integer; virtual; abstract;
    Function CheckIndex(Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure First(ValueKind: TUNSValueKind = vkActual); virtual; abstract;
    procedure Last(ValueKind: TUNSValueKind = vkActual); virtual; abstract;
    Function IndexOf(const Item; ValueKind: TUNSValueKind = vkActual): Integer; virtual; abstract;
    Function Add(const Item; ValueKind: TUNSValueKind = vkActual): Integer; virtual; abstract;
    Function Append(const Items; ValueKind: TUNSValueKind = vkActual): Integer; virtual; abstract;
    procedure Insert(Index: Integer; const Item; ValueKind: TUNSValueKind = vkActual); virtual; abstract;
    procedure Exchange(Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual); virtual; abstract;
    procedure Move(SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual); virtual; abstract;
    Function Remove(const Item; ValueKind: TUNSValueKind = vkActual): Integer; virtual; abstract;
    procedure Delete(Index: Integer; ValueKind: TUNSValueKind = vkActual); virtual; abstract;
    procedure Clear(ValueKind: TUNSValueKind = vkActual); virtual; abstract;
    // PrepareEmptyItems is only for internal purposes, do not publish it through UniSettings methods
    procedure PrepareEmptyItems(Count: Integer; ValueKind: TUNSValueKind = vkActual); virtual; abstract;
    procedure SaveTo(Ini: TIniFile; const Section,Key: String); override;
    procedure SaveTo(Ini: TIniFileEx; const Section,Key: String); override;
    procedure SaveTo(Reg: TRegistry; const Value: String); override;
    procedure LoadFrom(Ini: TIniFile; const Section,Key: String); override;
    procedure LoadFrom(Ini: TIniFileEx; const Section,Key: String); override;
    procedure LoadFrom(Reg: TRegistry; const Value: String); override;
    procedure SaveItemTo(Ini: TIniFile; Index: Integer; const Section,Key: String); overload; virtual; abstract;
    procedure SaveItemTo(Ini: TIniFileEx; Index: Integer; const Section,Key: String); overload; virtual; abstract;
    procedure SaveItemTo(Reg: TRegistry; Index: Integer; const Value: String); overload; virtual; abstract;
    procedure LoadItemFrom(Ini: TIniFile; Index: Integer; const Section,Key: String); overload; virtual; abstract;
    procedure LoadItemFrom(Ini: TIniFileEx; Index: Integer; const Section,Key: String); overload; virtual; abstract;
    procedure LoadItemFrom(Reg: TRegistry; Index: Integer; const Value: String); overload; virtual; abstract;
    property ItemValueType: TUNSValueType read GetItemValueType;
    property Count: Integer read GetCount;
    property SavedCount: Integer read GetSavedCount;
    property DefaultCount: Integer read GetDefaultCount;
    property ItemSize[Index: Integer]: TMemSize read GetItemSize;
    property SavedItemSize[Index: Integer]: TMemSize read GetSavedItemSize;
    property DefaultValueItemSize[Index: Integer]: TMemSize read GetDefaultItemSize;
  end;

implementation

uses
  SysUtils,
  UniSettings_Exceptions;

class Function TUNSNodePrimitiveArray.GetNodeType: TUNSNodeType;
begin
Result := ntLeafArray;
end;

//------------------------------------------------------------------------------

class Function TUNSNodePrimitiveArray.GetItemValueType: TUNSValueType;
begin
Result := vtUndefined;
end;

//==============================================================================

Function TUNSNodePrimitiveArray.ObtainCount(ValueKind: TUNSValueKind): Integer;
begin
case ValueKind of
  vkActual:   Result := GetCount;
  vkSaved:    Result := GetSavedCount;
  vkDefault:  Result := GetDefaultCount;
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ObtainCount');
end;
end;

//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.ObtainItemSize(Index: Integer; ValueKind: TUNSValueKind): TMemSize;
begin
case ValueKind of
  vkActual:   Result := GetItemSize(Index);
  vkSaved:    Result := GetSavedItemSize(Index);
  vkDefault:  Result := GetDefaultItemSize(Index);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ObtainItemSize');
end;
end;

//==============================================================================

destructor TUNSNodePrimitiveArray.Destroy;
begin
Clear(vkActual);
Clear(vkSaved);
Clear(vkDefault);
inherited;
end;

//------------------------------------------------------------------------------

procedure TUNSNodePrimitiveArray.ActualFromDefault(Index: Integer);
begin
ValueKindMove(Index,vkDefault,vkActual);
end;
 
//------------------------------------------------------------------------------

procedure TUNSNodePrimitiveArray.DefaultFromActual(Index: Integer);
begin
ValueKindMove(Index,vkActual,vkDefault);
end;
 
//------------------------------------------------------------------------------

procedure TUNSNodePrimitiveArray.ExchangeActualAndDefault(Index: Integer);
begin
ValueKindExchange(Index,vkActual,vkDefault);
end;
 
//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.ActualEqualsDefault(Index: Integer): Boolean;
begin
Result := ValueKindCompare(Index,vkActual,vkDefault);
end;

//------------------------------------------------------------------------------

procedure TUNSNodePrimitiveArray.Save(Index: Integer);
begin
ValueKindMove(Index,vkActual,vkSaved);
end;

//------------------------------------------------------------------------------

procedure TUNSNodePrimitiveArray.Restore(Index: Integer);
begin
ValueKindMove(Index,vkSaved,vkActual);
end;

//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.AsStream(Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryStream;
begin
Result := TMemoryStream.Create;
ToStream(Index,Result,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.AsBuffer(Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
begin
GetBuffer(Result,ObtainItemSize(Index,ValueKind));
ToBuffer(Index,Result,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.CheckIndex(Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
Result := (Index >= LowIndex(ValueKind)) and (Index <= HighIndex(ValueKind));
end;

//------------------------------------------------------------------------------

procedure TUNSNodePrimitiveArray.SaveTo(Ini: TIniFile; const Section,Key: String);
var
  i:  Integer;
begin
Ini.WriteInteger(Section,Key,Count);
For i := LowIndex to HighIndex do
  SaveItemTo(Ini,i,Section,Format('%s[%d]',[Key,i]));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodePrimitiveArray.SaveTo(Ini: TIniFileEx; const Section,Key: String);
var
  i:  Integer;
begin
Ini.WriteInteger(Section,Key,Count);
For i := LowIndex to HighIndex do
  SaveItemTo(Ini,i,Section,Format('%s[%d]',[Key,i]));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodePrimitiveArray.SaveTo(Reg: TRegistry; const Value: String);
var
  i:  Integer;
begin
Reg.WriteInteger(Value,Count);
For i := LowIndex to HighIndex do
  SaveItemTo(Reg,i,Format('%s[%d]',[Value,i]));
end;

//------------------------------------------------------------------------------

procedure TUNSNodePrimitiveArray.LoadFrom(Ini: TIniFile; const Section,Key: String);
var
  i:  Integer;
begin
BeginChanging;
try
  PrepareEmptyItems(Ini.ReadInteger(Section,Key,0),vkActual);
  For i := LowIndex to HighIndex do
    LoadItemFrom(Ini,i,Section,Format('%s[%d]',[Key,i]));
finally
  EndChanging;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodePrimitiveArray.LoadFrom(Ini: TIniFileEx; const Section,Key: String);
var
  i:  Integer;
begin
BeginChanging;
try
  PrepareEmptyItems(Ini.ReadInteger(Section,Key,0),vkActual);
  For i := LowIndex to HighIndex do
    LoadItemFrom(Ini,i,Section,Format('%s[%d]',[Key,i]));
finally
  EndChanging;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodePrimitiveArray.LoadFrom(Reg: TRegistry; const Value: String);
var
  i:  Integer;
begin
BeginChanging;
try
  PrepareEmptyItems(Reg.ReadInteger(Value),vkActual);
  For i := LowIndex to HighIndex do
    LoadItemFrom(Reg,i,Format('%s[%d]',[Value,i]));
finally
  EndChanging;
end;
end;

end.
