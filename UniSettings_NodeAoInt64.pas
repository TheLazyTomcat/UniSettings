{$IFNDEF UNS_Included}
unit UniSettings_NodeAoInt64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt64,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Int64;
  TUNSNodeValueItemTypeBin = Int64;
  TUNSNodeValueItemTypePtr = PInt64;

  TUNSNodeValueType    = TInt64CountedDynArray;
  TUNSNodeValueTypePtr = PInt64CountedDynArray;

  TUNSNodeAoInt64 = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeAoInt64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int64
      = BinaryStreaming.Stream_ReadInt64;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Int64; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteInt64;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Int64
      = BinaryStreaming.Ptr_ReadInt64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt64;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,16)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
Result := TUNSNodeValueItemType(StrToInt64(Str));
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE UNS_Included}

{$WARNINGS ON}

{$IFDEF UNS_Include_Declaration}
    Function Int64ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64; virtual;
    Function Int64ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64; virtual;
    Function Int64ValueIndexOfNoLock(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int64ValueAddNoLock(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int64ValueAppendNoLock(const ValueName: String; const Values: array of Int64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Int64ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Int64; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Int64ValueRemoveNoLock(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Int64ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64; virtual;
    Function Int64ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64; virtual;
    Function Int64ValueIndexOf(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int64ValueAdd(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int64ValueAppend(const ValueName: String; const Values: array of Int64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Int64ValueInsert(const ValueName: String; Index: Integer; const Value: Int64; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Int64ValueRemove(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Int64ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int64; virtual;
    procedure Int64ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Int64; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Int64ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int64; virtual;
    procedure Int64ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Int64; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Int64ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64;
begin
Result := TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64;
begin
Result := TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueIndexOfNoLock(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueAddNoLock(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueAppendNoLock(const ValueName: String; const Values: array of Int64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int64ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Int64; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueRemoveNoLock(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64;
begin
ReadLock;
try
  Result := Int64ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64;
begin
ReadLock;
try
  Result := Int64ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueIndexOf(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := Int64ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueAdd(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int64ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueAppend(const ValueName: String; const Values: array of Int64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int64ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int64ValueInsert(const ValueName: String; Index: Integer; const Value: Int64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int64ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueRemove(const ValueName: String; const Value: Int64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int64ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int64;
begin
with TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int64ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int64ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Int64; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoInt64,'Int64ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int64ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int64;
begin
ReadLock;
try
  Result := Int64ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int64ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Int64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int64ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
