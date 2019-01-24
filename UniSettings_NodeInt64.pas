{$IFNDEF UNS_Included}
unit UniSettings_NodeInt64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeInt64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Int64;
  TUNSNodeValueTypeBin = Int64;
  TUNSNodeValueTypePtr = PInt64;

  TUNSNodeInt64 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeInt64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int64
      = BinaryStreaming.Stream_ReadInt64;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Int64): TMemSize
      = BinaryStreaming.Ptr_WriteInt64;

  UNS_BufferReadFunction:
    Function(Dest: Pointer): Int64
      = BinaryStreaming.Ptr_ReadInt64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,16)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := TUNSNodeValueType(StrToInt64(Str));
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

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_Node.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE UNS_Included}

{$WARNINGS ON}

{$IFDEF UNS_Include_Declaration}
    Function Int64ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64; virtual;
    procedure Int64ValueSetNoLock(const ValueName: String; NewValue: Int64; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Int64ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64; virtual;
    procedure Int64ValueSet(const ValueName: String; NewValue: Int64; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Int64ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtInt64,'Int64ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoInt64(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoInt64(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoInt64(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int64ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeInt64(TempNode).Value;
    vkSaved:    Result := TUNSNodeInt64(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeInt64(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int64ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.Int64ValueSetNoLock(const ValueName: String; NewValue: Int64; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'Int64ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoInt64(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoInt64(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoInt64(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int64ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeInt64(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeInt64(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeInt64(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int64ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int64ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int64;
begin
ReadLock;
try
  Result := Int64ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int64ValueSet(const ValueName: String; NewValue: Int64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int64ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
