{$IFNDEF UNS_Included}
unit UniSettings_NodeAoDate;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoDate}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, CountedDynArrays, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TDateCountedDynArray = record
    Arr:    array of TDate;
    SigA:   UInt32;
    Count:  Integer;
    Data:   PtrInt;
    SigB:   UInt32;
  end;
  PDateCountedDynArray = ^TDateCountedDynArray;

  TCDABaseType = TDate;
  PCDABaseType = PDate;

  TCDAArrayType = TDateCountedDynArray;
  PCDAArrayType = PDateCountedDynArray;

{$DEFINE CDA_Interface}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Interface}

//------------------------------------------------------------------------------

type
  TUNSNodeValueItemType    = TDate;
  TUNSNodeValueItemTypeBin = TDate;
  TUNSNodeValueItemTypePtr = PDate;

  TUNSNodeValueType    = TDateCountedDynArray;
  TUNSNodeValueTypePtr = PDateCountedDynArray;

  TUNSNodeAoDate = class(TUNSNodePrimitiveArray)
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
If Int(A) > Int(B) then Result := -1
  else If Int(A) < Int(B) then Result := 1
    else Result := 0;
end;

//------------------------------------------------------------------------------

{$DEFINE CDA_Implementation}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Implementation}

//==============================================================================

type
  TUNSNodeClassType = TUNSNodeAoDate;

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
Result := vtAoDate;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtDate;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToDate(Str,fConvSettings);
  end
else Result := StrToDate(Str,fConvSettings);
end;

//==============================================================================

procedure TUNSNodeClassType.SaveItemTo(Ini: TIniFile; Index: Integer; const Section,Key: String);
begin
Ini.WriteDate(Section,Key,GetItem(Index));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveItemTo(Ini: TIniFileEx; Index: Integer; const Section,Key: String);
begin
Ini.WriteDate(Section,Key,GetItem(Index));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveItemTo(Reg: TRegistry; Index: Integer; const Value: String);
begin
Reg.WriteDate(Value,GetItem(Index));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadItemFrom(Ini: TIniFile; Index: Integer; const Section,Key: String);
begin
SetItem(Index,Ini.ReadDate(Section,Key,GetItem(Index)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadItemFrom(Ini: TIniFileEx; Index: Integer; const Section,Key: String);
begin
SetItem(Index,Ini.ReadDate(Section,Key,GetItem(Index)));
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadItemFrom(Reg: TRegistry; Index: Integer; const Value: String);
begin
SetItem(Index,Reg.ReadDate(Value));
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
    Function DateValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate; virtual;
    Function DateValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate; virtual;
    Function DateValueIndexOfNoLock(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function DateValueAddNoLock(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function DateValueAppendNoLock(const ValueName: String; const Values: array of TDate; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure DateValueInsertNoLock(const ValueName: String; Index: Integer; const Value: TDate; ValueKind: TUNSValueKind = vkActual); virtual;
    Function DateValueRemoveNoLock(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function DateValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate; virtual;
    Function DateValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate; virtual;
    Function DateValueIndexOf(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function DateValueAdd(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function DateValueAppend(const ValueName: String; const Values: array of TDate; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure DateValueInsert(const ValueName: String; Index: Integer; const Value: TDate; ValueKind: TUNSValueKind = vkActual); virtual;
    Function DateValueRemove(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function DateValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TDate; virtual;
    procedure DateValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: TDate; ValueKind: TUNSValueKind = vkActual); virtual;

    Function DateValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TDate; virtual;
    procedure DateValueItemSet(const ValueName: String; Index: Integer; const NewValue: TDate; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.DateValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate;
begin
Result := TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate;
begin
Result := TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueIndexOfNoLock(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueAddNoLock(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueAppendNoLock(const ValueName: String; const Values: array of TDate; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateValueInsertNoLock(const ValueName: String; Index: Integer; const Value: TDate; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.DateValueRemoveNoLock(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate;
begin
ReadLock;
try
  Result := DateValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate;
begin
ReadLock;
try
  Result := DateValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueIndexOf(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := DateValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueAdd(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := DateValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueAppend(const ValueName: String; const Values: array of TDate; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := DateValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateValueInsert(const ValueName: String; Index: Integer; const Value: TDate; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  DateValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueRemove(const ValueName: String; const Value: TDate; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := DateValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TDate;
begin
with TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'DateValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: TDate; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoDate(AccessLeafNodeType(ValueName,vtAoDate,'DateValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'DateValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TDate;
begin
ReadLock;
try
  Result := DateValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateValueItemSet(const ValueName: String; Index: Integer; const NewValue: TDate; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  DateValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
