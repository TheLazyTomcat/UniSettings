{$IFNDEF UNS_Included}
unit UniSettings_NodeTime;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeTime}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = TTime;
  TUNSNodeValueTypeBin = TTime;
  TUNSNodeValueTypePtr = PTime;

  TUNSNodeTime = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeTime;

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
Result := vtTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := TimeToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
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
    Function TimeValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime; virtual;
    procedure TimeValueSetNoLock(const ValueName: String; NewValue: TTime; ValueKind: TUNSValueKind = vkActual); virtual;

    Function TimeValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime; virtual;
    procedure TimeValueSet(const ValueName: String; NewValue: TTime; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.TimeValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtTime,'TimeValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoTime(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoTime(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoTime(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'TimeValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeTime(TempNode).Value;
    vkSaved:    Result := TUNSNodeTime(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeTime(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'TimeValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.TimeValueSetNoLock(const ValueName: String; NewValue: TTime; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'TimeValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoTime(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoTime(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoTime(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'TimeValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeTime(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeTime(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeTime(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'TimeValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TimeValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TTime;
begin
ReadLock;
try
  Result := TimeValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TimeValueSet(const ValueName: String; NewValue: TTime; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  TimeValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
