{$IFNDEF UNS_Included}
unit UniSettings_NodeAoBool;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoBool}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, CountedDynArrayBool, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Boolean;
  TUNSNodeValueItemTypeBin = ByteBool;
  TUNSNodeValueItemTypePtr = PBoolean;

  TUNSNodeValueType    = TBooleanCountedDynArray;
  TUNSNodeValueTypePtr = PBooleanCountedDynArray;

  TUNSNodeAoBool = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoBool;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: ByteBool; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteBool;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): ByteBool
      = BinaryStreaming.Stream_ReadBool;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: ByteBool; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteBool;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): ByteBool
      = BinaryStreaming.Ptr_ReadBool;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoBool;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtBool;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.NumericBools then
  Result := IntToStr(Ord(Value))
else
  Result := BoolToStr(Value,True);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
Result := StrToBool(Str);
end;

//==============================================================================

procedure TUNSNodeClassType.SaveItemTo(Ini: TIniFile; Index: Integer; const Section,Key: String);
begin
Ini.WriteBool(Section,Key,GetItem(Index));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveItemTo(Ini: TIniFileEx; Index: Integer; const Section,Key: String);
begin
Ini.WriteBool(Section,Key,GetItem(Index));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveItemTo(Reg: TRegistry; Index: Integer; const Value: String);
begin
Reg.WriteBool(Value,GetItem(Index));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadItemFrom(Ini: TIniFile; Index: Integer; const Section,Key: String);
begin
SetItem(Index,Ini.ReadBool(Section,Key,GetItem(Index)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadItemFrom(Ini: TIniFileEx; Index: Integer; const Section,Key: String);
begin
SetItem(Index,Ini.ReadBool(Section,Key,GetItem(Index)));
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadItemFrom(Reg: TRegistry; Index: Integer; const Value: String);
begin
SetItem(Index,Reg.ReadBool(Value));
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
    Function BooleanValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    Function BooleanValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    Function BooleanValueIndexOfNoLock(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function BooleanValueAddNoLock(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function BooleanValueAppendNoLock(const ValueName: String; const Values: array of Boolean; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure BooleanValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Boolean; ValueKind: TUNSValueKind = vkActual); virtual;
    Function BooleanValueRemoveNoLock(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function BooleanValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    Function BooleanValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    Function BooleanValueIndexOf(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function BooleanValueAdd(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function BooleanValueAppend(const ValueName: String; const Values: array of Boolean; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure BooleanValueInsert(const ValueName: String; Index: Integer; const Value: Boolean; ValueKind: TUNSValueKind = vkActual); virtual;
    Function BooleanValueRemove(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function BooleanValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure BooleanValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Boolean; ValueKind: TUNSValueKind = vkActual); virtual;

    Function BooleanValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure BooleanValueItemSet(const ValueName: String; Index: Integer; const NewValue: Boolean; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.BooleanValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
Result := TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueFirstNoLock')).First(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
Result := TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueLastNoLock')).Last(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueIndexOfNoLock(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueAddNoLock(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueAppendNoLock(const ValueName: String; const Values: array of Boolean; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueInsertNoLock(const ValueName: String; Index: Integer; const Value: Boolean; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueRemoveNoLock(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
ReadLock;
try
  Result := BooleanValueFirstNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
ReadLock;
try
  Result := BooleanValueLastNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueIndexOf(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := BooleanValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueAdd(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := BooleanValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueAppend(const ValueName: String; const Values: array of Boolean; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := BooleanValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueInsert(const ValueName: String; Index: Integer; const Value: Boolean; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  BooleanValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueRemove(const ValueName: String; const Value: Boolean; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := BooleanValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
with TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   Result := Items[Index];
    vkSaved:    Result := SavedItems[Index];
    vkDefault:  Result := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'BooleanValueItemGetNoLock');
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: Boolean; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoBool(AccessLeafNodeType(ValueName,vtAoBool,'BooleanValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'BooleanValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
ReadLock;
try
  Result := BooleanValueItemGetNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueItemSet(const ValueName: String; Index: Integer; const NewValue: Boolean; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  BooleanValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
