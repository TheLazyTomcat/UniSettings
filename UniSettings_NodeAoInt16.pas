{$IFNDEF UNS_Included}
unit UniSettings_NodeAoInt16;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt16}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt16,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Int16;
  TUNSNodeValueItemTypeBin = Int16;
  TUNSNodeValueItemTypePtr = PInt16;

  TUNSNodeValueType    = TInt16CountedDynArray;
  TUNSNodeValueTypePtr = PInt16CountedDynArray;

  TUNSNodeAoInt16 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoInt16;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int16; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt16;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int16
      = BinaryStreaming.Stream_ReadInt16;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Int16; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteInt16;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Int16
      = BinaryStreaming.Ptr_ReadInt16;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt16;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtInt16;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,4)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
Result := TUNSNodeValueItemType(StrToInt(Str));
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
    Function Int16ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16; virtual;
    Function Int16ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16; virtual;
    Function Int16ValueIndexOfNoLock(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int16ValueAddNoLock(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int16ValueAppendNoLock(const ValueName: String; const Values: array of Int16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Int16ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Int16; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Int16ValueRemoveNoLock(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Int16ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16; virtual;
    Function Int16ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16; virtual;
    Function Int16ValueIndexOf(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int16ValueAdd(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int16ValueAppend(const ValueName: String; const Values: array of Int16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Int16ValueInsert(const ValueName: String; Index: Integer; const Value: Int16; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Int16ValueRemove(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Int16ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int16; virtual;
    procedure Int16ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Int16; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Int16ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int16; virtual;
    procedure Int16ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Int16; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Int16ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16;
begin
Result := TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16;
begin
Result := TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueIndexOfNoLock(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueAddNoLock(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueAppendNoLock(const ValueName: String; const Values: array of Int16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Int16; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueRemoveNoLock(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16;
begin
ReadLock;
try
  Result := Int16ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16;
begin
ReadLock;
try
  Result := Int16ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueIndexOf(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := Int16ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueAdd(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int16ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueAppend(const ValueName: String; const Values: array of Int16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int16ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueInsert(const ValueName: String; Index: Integer; const Value: Int16; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int16ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueRemove(const ValueName: String; const Value: Int16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int16ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int16;
begin
with TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int16ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Int16; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoInt16(CheckedLeafNodeTypeAccess(ValueName,vtAoInt16,'Int16ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int16ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int16;
begin
ReadLock;
try
  Result := Int16ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Int16; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int16ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
