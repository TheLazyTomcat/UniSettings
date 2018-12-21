{$IFNDEF UNS_Included}
unit UniSettings_NodeAoText;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoText}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayString,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = String;
  TUNSNodeValueItemTypeBin = String;
  TUNSNodeValueItemTypePtr = PString;

  TUNSNodeValueType    = TStringCountedDynArray;
  TUNSNodeValueTypePtr = PStringCountedDynArray;

  TUNSNodeAoText = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect,
  UniSettings_Exceptions, UniSettings_ScriptUtils;

type
  TUNSNodeClassType = TUNSNodeAoText;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; const Value: String; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteString;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): String
      = BinaryStreaming.Stream_ReadString;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; const Value: String; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteString;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): String
      = BinaryStreaming.Ptr_ReadString;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoText;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtText;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
Result := UNSEncodeString(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
Result := UNSDecodeString(Str);
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
    Function TextValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String; virtual;
    Function TextValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String; virtual;
    Function TextValueIndexOfNoLock(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function TextValueAddNoLock(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function TextValueAppendNoLock(const ValueName: String; const Values: array of String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure TextValueInsertNoLock(const ValueName: String; Index: Integer; const Value: String; ValueKind: TUNSValueKind = vkActual); virtual;
    Function TextValueRemoveNoLock(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function TextValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String; virtual;
    Function TextValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String; virtual;
    Function TextValueIndexOf(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function TextValueAdd(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function TextValueAppend(const ValueName: String; const Values: array of String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure TextValueInsert(const ValueName: String; Index: Integer; const Value: String; ValueKind: TUNSValueKind = vkActual); virtual;
    Function TextValueRemove(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function TextValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String; virtual;
    procedure TextValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: String; ValueKind: TUNSValueKind = vkActual); virtual;

    Function TextValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String; virtual;
    procedure TextValueItemSet(const ValueName: String; Index: Integer; const NewValue: String; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.TextValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
begin
Result := TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
begin
Result := TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueIndexOfNoLock(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueAddNoLock(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueAppendNoLock(const ValueName: String; const Values: array of String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TextValueInsertNoLock(const ValueName: String; Index: Integer; const Value: String; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.TextValueRemoveNoLock(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
begin
ReadLock;
try
  Result := TextValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
begin
ReadLock;
try
  Result := TextValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueIndexOf(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := TextValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueAdd(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := TextValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueAppend(const ValueName: String; const Values: array of String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := TextValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TextValueInsert(const ValueName: String; Index: Integer; const Value: String; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  TextValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueRemove(const ValueName: String; const Value: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := TextValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String;
begin
with TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'TextValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TextValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: String; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoText(CheckedLeafNodeTypeAccess(ValueName,vtAoText,'TextValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'TextValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String;
begin
ReadLock;
try
  Result := TextValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TextValueItemSet(const ValueName: String; Index: Integer; const NewValue: String; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  TextValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
