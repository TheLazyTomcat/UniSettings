{$IFNDEF UNS_Included}
unit UniSettings_NodeAoInt8;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt8}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt8,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Int8;
  TUNSNodeValueItemTypeBin = Int8;
  TUNSNodeValueItemTypePtr = PInt8;

  TUNSNodeValueType    = TInt8CountedDynArray;
  TUNSNodeValueTypePtr = PInt8CountedDynArray;

  TUNSNodeAoInt8 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoInt8;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int8; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt8;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int8
      = BinaryStreaming.Stream_ReadInt8;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Int8; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteInt8;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Int8
      = BinaryStreaming.Ptr_ReadInt8;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt8;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtInt8;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,2)
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
    Function Int8ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    Function Int8ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    Function Int8ValueIndexOfNoLock(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int8ValueAddNoLock(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int8ValueAppendNoLock(const ValueName: String; const Values: array of Int8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Int8ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Int8; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Int8ValueRemoveNoLock(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Int8ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    Function Int8ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    Function Int8ValueIndexOf(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int8ValueAdd(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Int8ValueAppend(const ValueName: String; const Values: array of Int8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Int8ValueInsert(const ValueName: String; Index: Integer; const Value: Int8; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Int8ValueRemove(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Int8ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    procedure Int8ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Int8; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Int8ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    procedure Int8ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Int8; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Int8ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8;
begin
Result := TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8;
begin
Result := TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueIndexOfNoLock(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueAddNoLock(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueAppendNoLock(const ValueName: String; const Values: array of Int8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int8ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Int8; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueRemoveNoLock(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8;
begin
ReadLock;
try
  Result := Int8ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8;
begin
ReadLock;
try
  Result := Int8ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueIndexOf(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := Int8ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueAdd(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int8ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueAppend(const ValueName: String; const Values: array of Int8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int8ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int8ValueInsert(const ValueName: String; Index: Integer; const Value: Int8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int8ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueRemove(const ValueName: String; const Value: Int8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Int8ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int8;
begin
with TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int8ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int8ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Int8; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoInt8(AccessLeafNodeType(ValueName,vtAoInt8,'Int8ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int8ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Int8;
begin
ReadLock;
try
  Result := Int8ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int8ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Int8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int8ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
