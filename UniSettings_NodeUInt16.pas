{$IFNDEF UNS_Included}
unit UniSettings_NodeUInt16;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeUInt16}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = UInt16;
  TUNSNodeValueTypeBin = UInt16;
  TUNSNodeValueTypePtr = PUInt16;

  TUNSNodeUInt16 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeUInt16;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt16; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt16;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt16
      = BinaryStreaming.Stream_ReadUInt16;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: UInt16): TMemSize
      = BinaryStreaming.Ptr_WriteUInt16;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): UInt16
      = BinaryStreaming.Ptr_ReadUInt16;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtUInt16;
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

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_Node.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE UNS_Included}

{$WARNINGS ON}

{$IFDEF UNS_Include_Declaration}
    Function UInt16ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16; virtual;
    procedure UInt16ValueSetNoLock(const ValueName: String; NewValue: UInt16; ValueKind: TUNSValueKind = vkActual); virtual;

    Function UInt16ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16; virtual;
    procedure UInt16ValueSet(const ValueName: String; NewValue: UInt16; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.UInt16ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtUInt16,'UInt16ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoUInt16(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoUInt16(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoUInt16(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt16ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeUInt16(TempNode).Value;
    vkSaved:    Result := TUNSNodeUInt16(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeUInt16(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt16ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueSetNoLock(const ValueName: String; NewValue: UInt16; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'UInt16ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoUInt16(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoUInt16(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoUInt16(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'UInt16ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeUInt16(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeUInt16(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeUInt16(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'UInt16ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.UInt16ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt16;
begin
ReadLock;
try
  Result := UInt16ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueSet(const ValueName: String; NewValue: UInt16; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  UInt16ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF}

{$ENDIF UNS_Included}
