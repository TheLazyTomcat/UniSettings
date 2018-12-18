{$IFNDEF UNS_Included}
unit UniSettings_NodeAoUInt64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoUInt64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayUInt64,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = UInt64;
  TUNSNodeValueItemTypeBin = UInt64;
  TUNSNodeValueItemTypePtr = PUInt64;

  TUNSNodeValueType    = TUInt64CountedDynArray;
  TUNSNodeValueTypePtr = PUInt64CountedDynArray;

  TUNSNodeAoUInt64 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoUInt64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt64
      = BinaryStreaming.Stream_ReadUInt64;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: UInt64; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteUInt64;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): UInt64
      = BinaryStreaming.Ptr_ReadUInt64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoUInt64;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtUInt64;
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
    Function UInt64ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64; virtual;
    Function UInt64ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64; virtual;
    Function UInt64ValueIndexOfNoLock(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt64ValueAddNoLock(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt64ValueAppendNoLock(const ValueName: String; const Values: array of UInt64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure UInt64ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: UInt64; ValueKind: TUNSValueKind = vkActual); virtual;
    Function UInt64ValueRemoveNoLock(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function UInt64ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64; virtual;
    Function UInt64ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64; virtual;
    Function UInt64ValueIndexOf(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt64ValueAdd(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt64ValueAppend(const ValueName: String; const Values: array of UInt64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure UInt64ValueInsert(const ValueName: String; Index: Integer; const Value: UInt64; ValueKind: TUNSValueKind = vkActual); virtual;
    Function UInt64ValueRemove(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function UInt64ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt64; virtual;
    procedure UInt64ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: UInt64; ValueKind: TUNSValueKind = vkActual); virtual;

    Function UInt64ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt64; virtual;
    procedure UInt64ValueItemSet(const ValueName: String; Index: Integer; const NewValue: UInt64; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.UInt64ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64;
begin
Result := TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64;
begin
Result := TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueIndexOfNoLock(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueAddNoLock(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueAppendNoLock(const ValueName: String; const Values: array of UInt64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt64ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: UInt64; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueRemoveNoLock(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64;
begin
ReadLock;
try
  Result := UInt64ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64;
begin
ReadLock;
try
  Result := UInt64ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueIndexOf(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := UInt64ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueAdd(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt64ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueAppend(const ValueName: String; const Values: array of UInt64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt64ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt64ValueInsert(const ValueName: String; Index: Integer; const Value: UInt64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt64ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueRemove(const ValueName: String; const Value: UInt64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt64ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt64;
begin
with TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt64ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt64ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: UInt64; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoUInt64(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt64,'UInt64ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt64ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt64;
begin
ReadLock;
try
  Result := UInt64ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt64ValueItemSet(const ValueName: String; Index: Integer; const NewValue: UInt64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt64ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
