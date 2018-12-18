{$IFNDEF UNS_Included}
unit UniSettings_NodeUInt64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeUInt64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = UInt64;
  TUNSNodeValueTypeBin = UInt64;
  TUNSNodeValueTypePtr = PUInt64;

  TUNSNodeUInt64 = class(TUNSNodeLeaf)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_Node.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions, UniSettings_Utils;

type
  TUNSNodeClassType = TUNSNodeUInt64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt64
      = BinaryStreaming.Stream_ReadUInt64;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: UInt64): TMemSize
      = BinaryStreaming.Ptr_WriteUInt64;

  UNS_BufferReadFunction:
    Function(Dest: Pointer): UInt64
      = BinaryStreaming.Ptr_ReadUInt64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtUInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,16)
else
  Result := UNSUInt64ToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := TUNSNodeValueType(UNSStrToUInt64(Str));
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
    Function UInt64ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64; virtual;
    procedure UInt64ValueSetNoLock(const ValueName: String; NewValue: UInt64; ValueKind: TUNSValueKind = vkActual); virtual;

    Function UInt64ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64; virtual;
    procedure UInt64ValueSet(const ValueName: String; NewValue: UInt64; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.UInt64ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeTypeAccessIsArray(ValueName,vtUInt64,'UInt64ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoUInt64(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoUInt64(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoUInt64(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt64ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeUInt64(TempNode).Value;
    vkSaved:    Result := TUNSNodeUInt64(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeUInt64(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt64ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.UInt64ValueSetNoLock(const ValueName: String; NewValue: UInt64; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeTypeAccessIsArray(ValueName,vtBool,'UInt64ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoUInt64(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoUInt64(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoUInt64(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt64ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeUInt64(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeUInt64(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeUInt64(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt64ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt64ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt64;
begin
ReadLock;
try
  Result := UInt64ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt64ValueSet(const ValueName: String; NewValue: UInt64; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt64ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
