{$IFNDEF UNS_Included}
unit UniSettings_NodeUInt32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeUInt32}

interface         

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = UInt32;
  TUNSNodeValueTypeBin = UInt32;
  TUNSNodeValueTypePtr = PuInt32;

  TUNSNodeUInt32 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeUInt32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt32
      = BinaryStreaming.Stream_ReadUInt32;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: UInt32): TMemSize
      = BinaryStreaming.Ptr_WriteUInt32;

  UNS_BufferReadFunction:
    Function(Dest: Pointer): UInt32
      = BinaryStreaming.Ptr_ReadUInt32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtUInt32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,8)
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
Ini.WriteUInt32(Section,Key,fValue);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveTo(Reg: TRegistry; const Value: String);
begin
Reg.WriteInteger(Value,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFile; const Section,Key: String);
begin
SetValue(UInt32(Ini.ReadInteger(Section,Key,fValue)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFileEx; const Section,Key: String);
begin
SetValue(Ini.ReadUInt32(Section,Key,fValue));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Reg: TRegistry; const Value: String);
begin
SetValue(UInt32(Reg.ReadInteger(Value)));
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
    Function UInt32ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32; virtual;
    procedure UInt32ValueSetNoLock(const ValueName: String; NewValue: UInt32; ValueKind: TUNSValueKind = vkActual); virtual;

    Function UInt32ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32; virtual;
    procedure UInt32ValueSet(const ValueName: String; NewValue: UInt32; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.UInt32ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtUInt32,'UInt32ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoUInt32(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoUInt32(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoUInt32(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt32ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeUInt32(TempNode).Value;
    vkSaved:    Result := TUNSNodeUInt32(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeUInt32(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt32ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.UInt32ValueSetNoLock(const ValueName: String; NewValue: UInt32; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'UInt32ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoUInt32(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoUInt32(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoUInt32(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt32ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeUInt32(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeUInt32(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeUInt32(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt32ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt32ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt32;
begin
ReadLock;
try
  Result := UInt32ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt32ValueSet(const ValueName: String; NewValue: UInt32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt32ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
