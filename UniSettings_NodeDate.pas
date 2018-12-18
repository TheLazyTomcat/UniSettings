{$IFNDEF UNS_Included}
unit UniSettings_NodeDate;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeDate}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = TDate;
  TUNSNodeValueTypeBin = TDate;
  TUNSNodeValueTypePtr = PDate;

  TUNSNodeDate = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeDate;

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
Result := vtDate;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
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
    Function DateValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate; virtual;
    procedure DateValueSetNoLock(const ValueName: String; NewValue: TDate; ValueKind: TUNSValueKind = vkActual); virtual;

    Function DateValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate; virtual;
    procedure DateValueSet(const ValueName: String; NewValue: TDate; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.DateValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeTypeAccessIsArray(ValueName,vtDate,'DateValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoDate(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoDate(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoDate(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'DateValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeDate(TempNode).Value;
    vkSaved:    Result := TUNSNodeDate(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeDate(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'DateValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.DateValueSetNoLock(const ValueName: String; NewValue: TDate; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeTypeAccessIsArray(ValueName,vtBool,'DateValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoDate(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoDate(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoDate(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'DateValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeDate(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeDate(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeDate(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'DateValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.DateValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TDate;
begin
ReadLock;
try
  Result := DateValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateValueSet(const ValueName: String; NewValue: TDate; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  DateValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
