{$IFNDEF UNS_Included}
unit UniSettings_NodeAoUInt32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoUInt32}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayUInt32,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = UInt32;
  TUNSNodeValueItemTypeBin = UInt32;
  TUNSNodeValueItemTypePtr = PUInt32;

  TUNSNodeValueType    = TUInt32CountedDynArray;
  TUNSNodeValueTypePtr = PUInt32CountedDynArray;

  TUNSNodeAoUInt32 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoUInt32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt32
      = BinaryStreaming.Stream_ReadUInt32;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: UInt32; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteUInt32;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): UInt32
      = BinaryStreaming.Ptr_ReadUInt32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoUInt32;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtUInt32;
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
    Function UInt32ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32; virtual;
    Function UInt32ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32; virtual;
    Function UInt32ValueIndexOfNoLock(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt32ValueAddNoLock(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt32ValueAppendNoLock(const ValueName: String; const Values: array of UInt32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure UInt32ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: UInt32; ValueKind: TUNSValueKind = vkActual); virtual;
    Function UInt32ValueRemoveNoLock(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function UInt32ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32; virtual;
    Function UInt32ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32; virtual;
    Function UInt32ValueIndexOf(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt32ValueAdd(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt32ValueAppend(const ValueName: String; const Values: array of UInt32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure UInt32ValueInsert(const ValueName: String; Index: Integer; const Value: UInt32; ValueKind: TUNSValueKind = vkActual); virtual;
    Function UInt32ValueRemove(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function UInt32ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt32; virtual;
    procedure UInt32ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: UInt32; ValueKind: TUNSValueKind = vkActual); virtual;

    Function UInt32ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt32; virtual;
    procedure UInt32ValueItemSet(const ValueName: String; Index: Integer; const NewValue: UInt32; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.UInt32ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32;
begin
Result := TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32;
begin
Result := TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueIndexOfNoLock(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueAddNoLock(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueAppendNoLock(const ValueName: String; const Values: array of UInt32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt32ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: UInt32; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueRemoveNoLock(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32;
begin
ReadLock;
try
  Result := UInt32ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32;
begin
ReadLock;
try
  Result := UInt32ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueIndexOf(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := UInt32ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueAdd(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt32ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueAppend(const ValueName: String; const Values: array of UInt32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt32ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt32ValueInsert(const ValueName: String; Index: Integer; const Value: UInt32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt32ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueRemove(const ValueName: String; const Value: UInt32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt32ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt32;
begin
with TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt32ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt32ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: UInt32; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoUInt32(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt32,'UInt32ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt32ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt32;
begin
ReadLock;
try
  Result := UInt32ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt32ValueItemSet(const ValueName: String; Index: Integer; const NewValue: UInt32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt32ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
