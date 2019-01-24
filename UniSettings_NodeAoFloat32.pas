{$IFNDEF UNS_Included}
unit UniSettings_NodeAoFloat32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoFloat32}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayFloat32,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Float32;
  TUNSNodeValueItemTypeBin = Float32;
  TUNSNodeValueItemTypePtr = PFloat32;

  TUNSNodeValueType    = TFloat32CountedDynArray;
  TUNSNodeValueTypePtr = PFloat32CountedDynArray;

  TUNSNodeAoFloat32 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoFloat32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Float32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteFloat32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Float32
      = BinaryStreaming.Stream_ReadFloat32;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Float32; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteFloat32;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Float32
      = BinaryStreaming.Ptr_ReadFloat32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoFloat32;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtFloat32;
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
    Function Float32ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32; virtual;
    Function Float32ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32; virtual;
    Function Float32ValueIndexOfNoLock(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Float32ValueAddNoLock(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Float32ValueAppendNoLock(const ValueName: String; const Values: array of Float32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Float32ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Float32; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Float32ValueRemoveNoLock(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Float32ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32; virtual;
    Function Float32ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32; virtual;
    Function Float32ValueIndexOf(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Float32ValueAdd(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function Float32ValueAppend(const ValueName: String; const Values: array of Float32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure Float32ValueInsert(const ValueName: String; Index: Integer; const Value: Float32; ValueKind: TUNSValueKind = vkActual); virtual;
    Function Float32ValueRemove(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function Float32ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Float32; virtual;
    procedure Float32ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Float32; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Float32ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Float32; virtual;
    procedure Float32ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Float32; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Float32ValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32;
begin
Result := TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32;
begin
Result := TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueIndexOfNoLock(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueAddNoLock(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueAppendNoLock(const ValueName: String; const Values: array of Float32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float32ValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Float32; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueRemoveNoLock(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32;
begin
ReadLock;
try
  Result := Float32ValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32;
begin
ReadLock;
try
  Result := Float32ValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueIndexOf(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := Float32ValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueAdd(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Float32ValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueAppend(const ValueName: String; const Values: array of Float32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Float32ValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float32ValueInsert(const ValueName: String; Index: Integer; const Value: Float32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Float32ValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueRemove(const ValueName: String; const Value: Float32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := Float32ValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Float32;
begin
with TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Float32ValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float32ValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Float32; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoFloat32(AccessLeafNodeType(ValueName,vtAoFloat32,'Float32ValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Float32ValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Float32;
begin
ReadLock;
try
  Result := Float32ValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float32ValueItemSet(const ValueName: String; Index: Integer; const NewValue: Float32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Float32ValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
