{$IFNDEF UNS_Included}
unit UniSettings_NodeAoInt32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt32}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt32,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Int32;
  TUNSNodeValueItemTypeBin = Int32;
  TUNSNodeValueItemTypePtr = PInt32;

  TUNSNodeValueType    = TInt32CountedDynArray;
  TUNSNodeValueTypePtr = PInt32CountedDynArray;

  TUNSNodeAoInt32 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoInt32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int32
      = BinaryStreaming.Stream_ReadInt32;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Int32; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteInt32;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Int32
      = BinaryStreaming.Ptr_ReadInt32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt32;
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
  Result := '$' + IntToHex(Value,8)
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
    Function Int32ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32; virtual;
    Function Int32ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32; virtual;
    Function Int32ValueIndexOfNoLock(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int32ValueAddNoLock(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int32ValueAppendNoLock(const ValueName: String; const Values: array of Int32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Int32ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Int32; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Int32ValueRemoveNoLock(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Int32ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32; virtual;
    Function Int32ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32; virtual;
    Function Int32ValueIndexOf(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int32ValueAdd(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int32ValueAppend(const ValueName: String; const Values: array of Int32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Int32ValueInsert(const ValueName: String; Index: Integer; const Value: Int32; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Int32ValueRemove(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Int32ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int32; virtual;
    procedure Int32ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Int32; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Int32ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int32; virtual;
    procedure Int32ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Int32; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Int32ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32;
begin
Result := TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32;
begin
Result := TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueIndexOfNoLock(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueAddNoLock(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueAppendNoLock(const ValueName: String; const Values: array of Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int32ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Int32; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueRemoveNoLock(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32;
begin
ReadLock;
try
  Result := Int32ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32;
begin
ReadLock;
try
  Result := Int32ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueIndexOf(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := Int32ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueAdd(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int32ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueAppend(const ValueName: String; const Values: array of Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int32ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int32ValueInsert(const ValueName: String; Index: Integer; const Value: Int32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int32ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueRemove(const ValueName: String; const Value: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int32ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int32;
begin
with TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int32ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int32ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Int32; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoInt32(AccessLeafNodeType(ValueName,vtAoInt32,'Int32ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int32ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int32;
begin
ReadLock;
try
  Result := Int32ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int32ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Int32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int32ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
