{$IFNDEF UNS_Included}
unit UniSettings_NodeUInt8;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeUInt8}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = UInt8;
  TUNSNodeValueTypeBin = UInt8;
  TUNSNodeValueTypePtr = PUInt8;

  TUNSNodeUInt8 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeUInt8;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt8; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt8;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt8
      = BinaryStreaming.Stream_ReadUInt8;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: UInt8): TMemSize
      = BinaryStreaming.Ptr_WriteUInt8;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): UInt8
      = BinaryStreaming.Ptr_ReadUInt8;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtUInt8;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,2)
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
Ini.WriteUInt8(Section,Key,fValue);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveTo(Reg: TRegistry; const Value: String);
begin
Reg.WriteInteger(Value,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFile; const Section,Key: String);
begin
SetValue(UInt8(Ini.ReadInteger(Section,Key,fValue)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFileEx; const Section,Key: String);
begin
SetValue(Ini.ReadInt8(Section,Key,fValue));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Reg: TRegistry; const Value: String);
begin
SetValue(UInt8(Reg.ReadInteger(Value)));
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
    Function UInt8ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    procedure UInt8ValueSetNoLock(const ValueName: String; NewValue: UInt8; ValueKind: TUNSValueKind = vkActual); virtual;

    Function UInt8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    procedure UInt8ValueSet(const ValueName: String; NewValue: UInt8; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.UInt8ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtUInt8,'UInt8ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoUInt8(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoUInt8(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoUInt8(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt8ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeUInt8(TempNode).Value;
    vkSaved:    Result := TUNSNodeUInt8(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeUInt8(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt8ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueSetNoLock(const ValueName: String; NewValue: UInt8; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'UInt8ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoUInt8(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoUInt8(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoUInt8(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt8ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeUInt8(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeUInt8(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeUInt8(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt8ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
ReadLock;
try
  Result := UInt8ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueSet(const ValueName: String; NewValue: UInt8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt8ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
