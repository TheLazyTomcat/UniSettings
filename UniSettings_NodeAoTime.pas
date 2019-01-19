{$IFNDEF UNS_Included}
unit UniSettings_NodeAoTime;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoTime}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrays,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TTimeCountedDynArray = record
    Arr:    array of TTime;
    SigA:   UInt32;
    Count:  Integer;
    Data:   PtrInt;
    SigB:   UInt32;
  end;
  PTimeCountedDynArray = ^TTimeCountedDynArray;

  TCDABaseType = TTime;
  PCDABaseType = PTime;

  TCDAArrayType = TTimeCountedDynArray;
  PCDAArrayType = PTimeCountedDynArray;

{$DEFINE CDA_Interface}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Interface}

//------------------------------------------------------------------------------

type
  TUNSNodeValueItemType    = TTime;
  TUNSNodeValueItemTypeBin = TTime;
  TUNSNodeValueItemTypePtr = PTime;

  TUNSNodeValueType    = TTimeCountedDynArray;
  TUNSNodeValueTypePtr = PTimeCountedDynArray;

  TUNSNodeAoTime = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex, ListSorters,
  UniSettings_Exceptions;

Function CDA_CompareFunc(A,B: TCDABaseType): Integer;
begin
If Frac(A) > Frac(B) then Result := -1
  else If Frac(A) < Frac(B) then Result := 1
    else Result := 0;
end;

//------------------------------------------------------------------------------

{$DEFINE CDA_Implementation}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Implementation}

//==============================================================================

type
  TUNSNodeClassType = TUNSNodeAoTime;

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
Result := vtAoTime;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := TimeToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToTime(Str,fConvSettings);
  end
else Result := StrToTime(Str,fConvSettings);
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
    Function TimeValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime; virtual;
    Function TimeValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime; virtual;
    Function TimeValueIndexOfNoLock(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function TimeValueAddNoLock(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function TimeValueAppendNoLock(const ValueName: String; const Values: array of TTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure TimeValueInsertNoLock(const ValueName: String; Index: Integer; const Value: TTime; ValueKind: TUNSValueKind = vkActual); virtual;
    Function TimeValueRemoveNoLock(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function TimeValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime; virtual;
    Function TimeValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime; virtual;
    Function TimeValueIndexOf(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function TimeValueAdd(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function TimeValueAppend(const ValueName: String; const Values: array of TTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure TimeValueInsert(const ValueName: String; Index: Integer; const Value: TTime; ValueKind: TUNSValueKind = vkActual); virtual;
    Function TimeValueRemove(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function TimeValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TTime; virtual;
    procedure TimeValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: TTime; ValueKind: TUNSValueKind = vkActual); virtual;

    Function TimeValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TTime; virtual;
    procedure TimeValueItemSet(const ValueName: String; Index: Integer; const NewValue: TTime; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.TimeValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime;
begin
Result := TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime;
begin
Result := TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueIndexOfNoLock(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueAddNoLock(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueAppendNoLock(const ValueName: String; const Values: array of TTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TimeValueInsertNoLock(const ValueName: String; Index: Integer; const Value: TTime; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.TimeValueRemoveNoLock(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime;
begin
ReadLock;
try
  Result := TimeValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime;
begin
ReadLock;
try
  Result := TimeValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueIndexOf(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := TimeValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueAdd(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := TimeValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueAppend(const ValueName: String; const Values: array of TTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := TimeValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TimeValueInsert(const ValueName: String; Index: Integer; const Value: TTime; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  TimeValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueRemove(const ValueName: String; const Value: TTime; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := TimeValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TTime;
begin
with TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'TimeValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TimeValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: TTime; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoTime(CheckedLeafNodeTypeAccess(ValueName,vtAoTime,'TimeValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'TimeValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TTime;
begin
ReadLock;
try
  Result := TimeValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TimeValueItemSet(const ValueName: String; Index: Integer; const NewValue: TTime; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  TimeValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
