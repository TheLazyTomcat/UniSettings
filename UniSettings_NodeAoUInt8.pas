{$IFNDEF UNS_Included}
unit UniSettings_NodeAoUInt8;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoUInt8}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayUInt8,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = UInt8;
  TUNSNodeValueItemTypeBin = UInt8;
  TUNSNodeValueItemTypePtr = PUInt8;

  TUNSNodeValueType    = TUInt8CountedDynArray;
  TUNSNodeValueTypePtr = PUInt8CountedDynArray;

  TUNSNodeAoUInt8 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoUInt8;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt8; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt8;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt8
      = BinaryStreaming.Stream_ReadUInt8;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: UInt8; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteUInt8;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): UInt8
      = BinaryStreaming.Ptr_ReadUInt8;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoUInt8;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtUInt8;
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
    Function UInt8ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    Function UInt8ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    Function UInt8ValueIndexOfNoLock(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt8ValueAddNoLock(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt8ValueAppendNoLock(const ValueName: String; const Values: array of UInt8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure UInt8ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: UInt8; ValueKind: TUNSValueKind = vkActual); virtual;
    Function UInt8ValueRemoveNoLock(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function UInt8ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    Function UInt8ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    Function UInt8ValueIndexOf(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt8ValueAdd(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt8ValueAppend(const ValueName: String; const Values: array of UInt8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure UInt8ValueInsert(const ValueName: String; Index: Integer; const Value: UInt8; ValueKind: TUNSValueKind = vkActual); virtual;
    Function UInt8ValueRemove(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function UInt8ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    procedure UInt8ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: UInt8; ValueKind: TUNSValueKind = vkActual); virtual;

    Function UInt8ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    procedure UInt8ValueItemSet(const ValueName: String; Index: Integer; const NewValue: UInt8; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.UInt8ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
Result := TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
Result := TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueIndexOfNoLock(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueAddNoLock(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueAppendNoLock(const ValueName: String; const Values: array of UInt8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: UInt8; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueRemoveNoLock(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
ReadLock;
try
  Result := UInt8ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
ReadLock;
try
  Result := UInt8ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueIndexOf(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := UInt8ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueAdd(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt8ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueAppend(const ValueName: String; const Values: array of UInt8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt8ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueInsert(const ValueName: String; Index: Integer; const Value: UInt8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt8ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueRemove(const ValueName: String; const Value: UInt8; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt8ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
with TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt8ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: UInt8; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoUInt8(CheckedLeafNodeTypeAccess(ValueName,vtAoUInt8,'UInt8ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt8ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
ReadLock;
try
  Result := UInt8ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueItemSet(const ValueName: String; Index: Integer; const NewValue: UInt8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt8ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
