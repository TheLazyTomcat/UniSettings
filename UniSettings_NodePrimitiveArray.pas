unit UniSettings_NodePrimitiveArray;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodePrimitiveArray = class(TUNSNodeLeaf)
  protected
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
    class Function IsPrimitiveArray: Boolean; override;
    destructor Destroy; override;
    Function ObtainCount(ValueKind: TUNSValueKind): Integer; virtual;
    Function ObtainItemSize(Index: Integer; ValueKind: TUNSValueKind): TMemSize; virtual;
    procedure ValueKindMove(Index: Integer; Src,Dest: TUNSValueKind); overload; virtual; abstract;
    procedure ValueKindExchange(Index: Integer; ValA,ValB: TUNSValueKind); overload; virtual; abstract;
    Function ValueKindCompare(Index: Integer; ValA,ValB: TUNSValueKind): Boolean; overload; virtual; abstract;
    Function ActualFromDefault(Index: Integer): Boolean; overload; virtual;
    Function DefaultFromActual(Index: Integer): Boolean; overload; virtual;
    Function ExchangeActualAndDefault(Index: Integer): Boolean; overload; virtual;
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
    property Count: Integer read GetCount;
    property SavedCount: Integer read GetSavedCount;
    property DefaultCount: Integer read GetDefaultCount;
    property ItemSize[Index: Integer]: TMemSize read GetItemSize;
    property SavedItemSize[Index: Integer]: TMemSize read GetSavedItemSize;
    property DefaultValueItemSize[Index: Integer]: TMemSize read GetDefaultItemSize;
  end;

implementation

uses
  UniSettings_Exceptions;

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

class Function TUNSNodePrimitiveArray.IsPrimitiveArray: Boolean;
begin
Result := True;
end;

//------------------------------------------------------------------------------

destructor TUNSNodePrimitiveArray.Destroy;
begin
Clear(vkActual);
Clear(vkSaved);
Clear(vkDefault);
inherited;
end;

//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.ActualFromDefault(Index: Integer): Boolean;
begin
ValueKindMove(Index,vkDefault,vkActual);
end;
 
//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.DefaultFromActual(Index: Integer): Boolean;
begin
ValueKindMove(Index,vkActual,vkDefault);
end;
 
//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.ExchangeActualAndDefault(Index: Integer): Boolean;
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

end.
