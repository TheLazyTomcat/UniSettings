{$IFNDEF UNS_Included}
unit UniSettings_NodeDateTime;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeDateTime}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = TDateTime;
  TUNSNodeValueTypeBin = TDateTime;
  TUNSNodeValueTypePtr = PDateTime;

  TUNSNodeDateTime = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeDateTime;

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
Result := vtDateTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateTimeToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
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

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := Now;
fSavedValue := fValue;
fDefaultValue := fValue;
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
    Function DateTimeValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime; virtual;
    procedure DateTimeValueSetNoLock(const ValueName: String; NewValue: TDateTime; ValueKind: TUNSValueKind = vkActual); virtual;

    Function DateTimeValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime; virtual;
    procedure DateTimeValueSet(const ValueName: String; NewValue: TDateTime; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.DateTimeValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtDateTime,'DateTimeValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoDateTime(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoDateTime(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoDateTime(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'DateTimeValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeDateTime(TempNode).Value;
    vkSaved:    Result := TUNSNodeDateTime(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeDateTime(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'DateTimeValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.DateTimeValueSetNoLock(const ValueName: String; NewValue: TDateTime; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'DateTimeValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoDateTime(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoDateTime(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoDateTime(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'DateTimeValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeDateTime(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeDateTime(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeDateTime(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'DateTimeValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateTimeValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDateTime;
begin
ReadLock;
try
  Result := DateTimeValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateTimeValueSet(const ValueName: String; NewValue: TDateTime; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  DateTimeValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
