{$IFNDEF UNS_Included}
unit UniSettings_NodeAoFloat64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoFloat64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayFloat64,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Float64;
  TUNSNodeValueItemTypeBin = Float64;
  TUNSNodeValueItemTypePtr = PFloat64;

  TUNSNodeValueType    = TFloat64CountedDynArray;
  TUNSNodeValueTypePtr = PFloat64CountedDynArray;

  TUNSNodeAoFloat64 = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeAoFloat64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Float64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteFloat64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Float64
      = BinaryStreaming.Stream_ReadFloat64;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Float64; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteFloat64;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Float64
      = BinaryStreaming.Ptr_ReadFloat64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoFloat64;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtFloat64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexFloats then
  Result := '$' + SingleToHex(Value)
else
  Result := FloatToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToSingle(Str)
    else
      Result := StrToFloat(Str,fConvSettings);
  end
else Result := StrToFloat(Str,fConvSettings);
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
    Function Float64ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64; virtual;
    Function Float64ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64; virtual;
    Function Float64ValueIndexOfNoLock(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Float64ValueAddNoLock(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Float64ValueAppendNoLock(const ValueName: String; const Values: array of Float64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Float64ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Float64; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Float64ValueRemoveNoLock(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Float64ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64; virtual;
    Function Float64ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64; virtual;
    Function Float64ValueIndexOf(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Float64ValueAdd(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Float64ValueAppend(const ValueName: String; const Values: array of Float64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Float64ValueInsert(const ValueName: String; Index: Integer; const Value: Float64; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Float64ValueRemove(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Float64ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Float64; virtual;
    procedure Float64ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Float64; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Float64ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Float64; virtual;
    procedure Float64ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Float64; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Float64ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64;
begin
Result := TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64;
begin
Result := TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueIndexOfNoLock(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueAddNoLock(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueAppendNoLock(const ValueName: String; const Values: array of Float64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float64ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Float64; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueRemoveNoLock(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64;
begin
ReadLock;
try
  Result := Float64ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64;
begin
ReadLock;
try
  Result := Float64ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueIndexOf(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := Float64ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueAdd(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Float64ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueAppend(const ValueName: String; const Values: array of Float64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Float64ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float64ValueInsert(const ValueName: String; Index: Integer; const Value: Float64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Float64ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueRemove(const ValueName: String; const Value: Float64; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Float64ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Float64;
begin
with TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Float64ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float64ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Float64; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoFloat64(CheckedLeafNodeTypeAccess(ValueName,vtAoFloat64,'Float64ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Float64ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Float64;
begin
ReadLock;
try
  Result := Float64ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float64ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Float64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Float64ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}

