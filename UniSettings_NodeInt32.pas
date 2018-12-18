{$IFNDEF UNS_Included}
unit UniSettings_NodeInt32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeInt32}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Int32;
  TUNSNodeValueTypeBin = Int32;
  TUNSNodeValueTypePtr = PInt32;

  TUNSNodeInt32 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeInt32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int32
      = BinaryStreaming.Stream_ReadInt32;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Int32): TMemSize
      = BinaryStreaming.Ptr_WriteInt32;

  UNS_BufferReadFunction:
    Function(Dest: Pointer): Int32
      = BinaryStreaming.Ptr_ReadInt32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtInt32;
end;

//------------------------------------------------------------------------------


Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,8)
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
    Function Int32ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32; virtual;
    procedure Int32ValueSetNoLock(const ValueName: String; NewValue: Int32; ValueKind: TUNSValueKind = vkActual); virtual;

    Function Int32ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32; virtual;
    procedure Int32ValueSet(const ValueName: String; NewValue: Int32; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.Int32ValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeTypeAccessIsArray(ValueName,vtInt32,'Int32ValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoInt32(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoInt32(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoInt32(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int32ValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeInt32(TempNode).Value;
    vkSaved:    Result := TUNSNodeInt32(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeInt32(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int32ValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.Int32ValueSetNoLock(const ValueName: String; NewValue: Int32; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeTypeAccessIsArray(ValueName,vtBool,'Int32ValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoInt32(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoInt32(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoInt32(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'Int32ValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeInt32(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeInt32(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeInt32(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Int32ValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Int32ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int32;
begin
ReadLock;
try
  Result := Int32ValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int32ValueSet(const ValueName: String; NewValue: Int32; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  Int32ValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
