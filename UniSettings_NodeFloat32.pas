{$IFNDEF UNS_Included}
unit UniSettings_NodeFloat32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeFloat32}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Float32;
  TUNSNodeValueTypeBin = Float32;
  TUNSNodeValueTypePtr = PFloat32;

  TUNSNodeFloat32 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeFloat32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Float32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteFloat32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Float32
      = BinaryStreaming.Stream_ReadFloat32;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Float32): TMemSize
      = BinaryStreaming.Ptr_WriteFloat32;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): Float32
      = BinaryStreaming.Ptr_ReadFloat32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtFloat32;
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
Ini.WriteFloat32(Section,Key,fValue);
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
SetValue(Ini.ReadFloat32(Section,Key,fValue));
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
    Function Float32ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32; virtual;
    procedure Float32ValueSetNoLock(const ValueName: String; NewValue: Float32; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Float32ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32; virtual;
    procedure Float32ValueSet(const ValueName: String; NewValue: Float32; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Float32ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtFloat32,'Float32ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoFloat32(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoFloat32(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoFloat32(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Float32ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeFloat32(TempNode).Value;
    vkSaved:    Result := TUNSNodeFloat32(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeFloat32(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Float32ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.Float32ValueSetNoLock(const ValueName: String; NewValue: Float32; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'Float32ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoFloat32(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoFloat32(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoFloat32(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Float32ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeFloat32(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeFloat32(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeFloat32(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Float32ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Float32ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Float32;
begin
ReadLock;
try
  Result := Float32ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float32ValueSet(const ValueName: String; NewValue: Float32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Float32ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
