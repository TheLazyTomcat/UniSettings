{$IFNDEF UNS_Included}
unit UniSettings_NodeAoUInt16;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoUInt16}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, CountedDynArrayUInt16, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = UInt16;
  TUNSNodeValueItemTypeBin = UInt16;
  TUNSNodeValueItemTypePtr = PUInt16;

  TUNSNodeValueType    = TUInt16CountedDynArray;
  TUNSNodeValueTypePtr = PUInt16CountedDynArray;

  TUNSNodeAoUInt16 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoUInt16;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt16; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt16;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt16
      = BinaryStreaming.Stream_ReadUInt16;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: UInt16; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteUInt16;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): UInt16
      = BinaryStreaming.Ptr_ReadUInt16;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoUInt16;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtUInt16;
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

//==============================================================================

procedure TUNSNodeClassType.SaveItemTo(Ini: TIniFile; Index: Integer; const Section,Key: String);
begin
Ini.WriteInteger(Section,Key,GetItem(Index));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveItemTo(Ini: TIniFileEx; Index: Integer; const Section,Key: String);
begin
Ini.WriteUInt16(Section,Key,GetItem(Index));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveItemTo(Reg: TRegistry; Index: Integer; const Value: String);
begin
Reg.WriteInteger(Value,GetItem(Index));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadItemFrom(Ini: TIniFile; Index: Integer; const Section,Key: String);
begin
SetItem(Index,UInt16(Ini.ReadInteger(Section,Key,GetItem(Index))));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadItemFrom(Ini: TIniFileEx; Index: Integer; const Section,Key: String);
begin
SetItem(Index,Ini.ReadUInt16(Section,Key,GetItem(Index)));
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadItemFrom(Reg: TRegistry; Index: Integer; const Value: String);
begin
SetItem(Index,UInt16(Reg.ReadInteger(Value)));
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
    Function UInt16ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16; virtual;
    Function UInt16ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16; virtual;
    Function UInt16ValueIndexOfNoLock(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt16ValueAddNoLock(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt16ValueAppendNoLock(const ValueName: String; const Values: array of UInt16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure UInt16ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: UInt16; ValueKind: TUNSValueKind = vkActual); virtual;
    Function UInt16ValueRemoveNoLock(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function UInt16ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16; virtual;
    Function UInt16ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16; virtual;
    Function UInt16ValueIndexOf(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt16ValueAdd(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function UInt16ValueAppend(const ValueName: String; const Values: array of UInt16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure UInt16ValueInsert(const ValueName: String; Index: Integer; const Value: UInt16; ValueKind: TUNSValueKind = vkActual); virtual;
    Function UInt16ValueRemove(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function UInt16ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt16; virtual;
    procedure UInt16ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: UInt16; ValueKind: TUNSValueKind = vkActual); virtual;

    Function UInt16ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt16; virtual;
    procedure UInt16ValueItemSet(const ValueName: String; Index: Integer; const NewValue: UInt16; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.UInt16ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16;
begin
Result := TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16;
begin
Result := TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueIndexOfNoLock(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueAddNoLock(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueAppendNoLock(const ValueName: String; const Values: array of UInt16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: UInt16; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueRemoveNoLock(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16;
begin
ReadLock;
try
  Result := UInt16ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16;
begin
ReadLock;
try
  Result := UInt16ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueIndexOf(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := UInt16ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueAdd(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt16ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueAppend(const ValueName: String; const Values: array of UInt16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt16ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueInsert(const ValueName: String; Index: Integer; const Value: UInt16; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt16ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueRemove(const ValueName: String; const Value: UInt16; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := UInt16ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt16;
begin
with TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt16ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: UInt16; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoUInt16(AccessLeafNodeType(ValueName,vtAoUInt16,'UInt16ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt16ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): UInt16;
begin
ReadLock;
try
  Result := UInt16ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueItemSet(const ValueName: String; Index: Integer; const NewValue: UInt16; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt16ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
