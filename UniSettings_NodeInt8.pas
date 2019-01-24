{$IFNDEF UNS_Included}
unit UniSettings_NodeInt8;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeInt8}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Int8;
  TUNSNodeValueTypeBin = Int8;
  TUNSNodeValueTypePtr = PInt8;

  TUNSNodeInt8 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeInt8;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int8; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt8;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int8
      = BinaryStreaming.Stream_ReadInt8;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Int8): TMemSize
      = BinaryStreaming.Ptr_WriteInt8;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): Int8
      = BinaryStreaming.Ptr_ReadInt8;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtInt8;
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

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_Node.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE UNS_Included}

{$WARNINGS ON}

{$IFDEF UNS_Include_Declaration}
    Function Int8ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    procedure Int8ValueSetNoLock(const ValueName: String; NewValue: Int8; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Int8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    procedure Int8ValueSet(const ValueName: String; NewValue: Int8; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Int8ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtInt8,'Int8ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoInt8(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoInt8(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoInt8(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int8ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeInt8(TempNode).Value;
    vkSaved:    Result := TUNSNodeInt8(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeInt8(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int8ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.Int8ValueSetNoLock(const ValueName: String; NewValue: Int8; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'Int8ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoInt8(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoInt8(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoInt8(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int8ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeInt8(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeInt8(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeInt8(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int8ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8;
begin
ReadLock;
try
  Result := Int8ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int8ValueSet(const ValueName: String; NewValue: Int8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int8ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
