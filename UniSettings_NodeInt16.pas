{$IFNDEF UNS_Included}
unit UniSettings_NodeInt16;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeInt16}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Int16;
  TUNSNodeValueTypeBin = Int16;
  TUNSNodeValueTypePtr = PInt16;

  TUNSNodeInt16 = class(TUNSNodeLeaf)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_Node.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;
  
implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeInt16;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int16; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt16;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int16
      = BinaryStreaming.Stream_ReadInt16;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Int16): TMemSize
      = BinaryStreaming.Ptr_WriteInt16;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): Int16
      = BinaryStreaming.Ptr_ReadInt16;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtInt16;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,4)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := TUNSNodeValueType(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SaveTo(Ini: TIniFile; const Section,Key: String);
begin
Ini.WriteInteger(Section,Key,fValue);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveTo(Ini: TIniFileEx; const Section,Key: String);
begin
Ini.WriteInt16(Section,Key,fValue);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveTo(Reg: TRegistry; const Value: String);
begin
Reg.WriteInteger(Value,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFile; const Section,Key: String);
begin
SetValue(Int16(Ini.ReadInteger(Section,Key,fValue)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFileEx; const Section,Key: String);
begin
SetValue(Ini.ReadInt16(Section,Key,fValue));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Reg: TRegistry; const Value: String);
begin
SetValue(Int16(Reg.ReadInteger(Value)));
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_Node.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE UNS_Included}

{$WARNINGS ON}

{$IFDEF UNS_Include_Declaration}
    Function Int16ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16; virtual;
    procedure Int16ValueSetNoLock(const ValueName: String; NewValue: Int16; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Int16ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16; virtual;
    procedure Int16ValueSet(const ValueName: String; NewValue: Int16; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Int16ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtInt16,'Int16ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoInt16(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoInt16(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoInt16(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int16ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeInt16(TempNode).Value;
    vkSaved:    Result := TUNSNodeInt16(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeInt16(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int16ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueSetNoLock(const ValueName: String; NewValue: Int16; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'Int16ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoInt16(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoInt16(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoInt16(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int16ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeInt16(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeInt16(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeInt16(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int16ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int16ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int16;
begin
ReadLock;
try
  Result := Int16ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueSet(const ValueName: String; NewValue: Int16; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int16ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
