{$IFNDEF UNS_Included}
unit UniSettings_NodeAoDateTime;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoDateTime}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayDateTime,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = TDateTime;
  TUNSNodeValueItemTypeBin = TDateTime;
  TUNSNodeValueItemTypePtr = PDateTime;

  TUNSNodeValueType    = TDateTimeCountedDynArray;
  TUNSNodeValueTypePtr = PDateTimeCountedDynArray;

  TUNSNodeAoDateTime = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoDateTime;

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
Result := vtAoDateTime;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtDateTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateTimeToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToDateTime(Str,fConvSettings);
  end
else Result := StrToDateTime(Str,fConvSettings);
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
    Function DateTimeValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime; virtual;
    Function DateTimeValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime; virtual;
    Function DateTimeValueIndexOfNoLock(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function DateTimeValueAddNoLock(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function DateTimeValueAppendNoLock(const ValueName: String; const Values: array of TDateTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure DateTimeValueInsertNoLock(const ValueName: String; Index: Integer; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual); virtual;
    Function DateTimeValueRemoveNoLock(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function DateTimeValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime; virtual;
    Function DateTimeValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime; virtual;
    Function DateTimeValueIndexOf(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function DateTimeValueAdd(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function DateTimeValueAppend(const ValueName: String; const Values: array of TDateTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure DateTimeValueInsert(const ValueName: String; Index: Integer; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual); virtual;
    Function DateTimeValueRemove(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function DateTimeValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TDateTime; virtual;
    procedure DateTimeValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: TDateTime; ValueKind: TUNSValueKind = vkActual); virtual;

    Function DateTimeValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TDateTime; virtual;
    procedure DateTimeValueItemSet(const ValueName: String; Index: Integer; const NewValue: TDateTime; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.DateTimeValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime;
begin
Result := TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime;
begin
Result := TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueIndexOfNoLock(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueAddNoLock(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueAppendNoLock(const ValueName: String; const Values: array of TDateTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateTimeValueInsertNoLock(const ValueName: String; Index: Integer; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueRemoveNoLock(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime;
begin
ReadLock;
try
  Result := DateTimeValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime;
begin
ReadLock;
try
  Result := DateTimeValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueIndexOf(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := DateTimeValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueAdd(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := DateTimeValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueAppend(const ValueName: String; const Values: array of TDateTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := DateTimeValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateTimeValueInsert(const ValueName: String; Index: Integer; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  DateTimeValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueRemove(const ValueName: String; const Value: TDateTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := DateTimeValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TDateTime;
begin
with TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'DateTimeValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateTimeValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: TDateTime; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoDateTime(AccessLeafNodeType(ValueName,vtAoDateTime,'DateTimeValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'DateTimeValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TDateTime;
begin
ReadLock;
try
  Result := DateTimeValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateTimeValueItemSet(const ValueName: String; Index: Integer; const NewValue: TDateTime; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  DateTimeValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
