{$IFNDEF UNS_Included}
unit UniSettings_NodeFloat64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeFloat64}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Float64;
  TUNSNodeValueTypeBin = Float64;
  TUNSNodeValueTypePtr = PFloat64;

  TUNSNodeFloat64 = class(TUNSNodeLeaf)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_Node.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeFloat64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Float64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteFloat64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Float64
      = BinaryStreaming.Stream_ReadFloat64;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Float64): TMemSize
      = BinaryStreaming.Ptr_WriteFloat64;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): Float64
      = BinaryStreaming.Ptr_ReadFloat64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtFloat64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexFloats then
  Result := '$' + SingleToHex(Value)
else
  Result := FloatToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
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

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0.0;
fSavedValue := 0.0;
fDefaultValue := 0.0;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SaveTo(Ini: TIniFile; const Section,Key: String);
begin
Ini.WriteFloat(Section,Key,fValue);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveTo(Ini: TIniFileEx; const Section,Key: String);
begin
Ini.WriteFloat64(Section,Key,fValue);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveTo(Reg: TRegistry; const Value: String);
begin
Reg.WriteFloat(Value,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFile; const Section,Key: String);
begin
SetValue(Ini.ReadFloat(Section,Key,fValue));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFileEx; const Section,Key: String);
begin
SetValue(Ini.ReadFloat64(Section,Key,fValue));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Reg: TRegistry; const Value: String);
begin
SetValue(Reg.ReadFloat(Value));
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
    Function Float64ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64; virtual;
    procedure Float64ValueSetNoLock(const ValueName: String; NewValue: Float64; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Float64ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64; virtual;
    procedure Float64ValueSet(const ValueName: String; NewValue: Float64; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Float64ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtFloat64,'Float64ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoFloat64(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoFloat64(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoFloat64(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Float64ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeFloat64(TempNode).Value;
    vkSaved:    Result := TUNSNodeFloat64(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeFloat64(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Float64ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.Float64ValueSetNoLock(const ValueName: String; NewValue: Float64; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'Float64ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoFloat64(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoFloat64(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoFloat64(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Float64ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeFloat64(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeFloat64(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeFloat64(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Float64ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float64ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float64;
begin
ReadLock;
try
  Result := Float64ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float64ValueSet(const ValueName: String; NewValue: Float64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Float64ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
