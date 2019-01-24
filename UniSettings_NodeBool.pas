{$IFNDEF UNS_Included}
unit UniSettings_NodeBool;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeBool}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Boolean;
  TUNSNodeValueTypeBin = ByteBool;
  TUNSNodeValueTypePtr = PBoolean;

  TUNSNodeBool = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeBool;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: ByteBool; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteBool;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): ByteBool
      = BinaryStreaming.Stream_ReadBool;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: ByteBool): TMemSize
      = BinaryStreaming.Ptr_WriteBool;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): ByteBool
      = BinaryStreaming.Ptr_ReadBool;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtBool;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.NumericBools then
  Result := IntToStr(Ord(Value))
else
  Result := BoolToStr(Value,True);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := StrToBool(Str);
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := False;
fSavedValue := False;
fDefaultValue := False;
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
    Function BooleanValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure BooleanValueSetNoLock(const ValueName: String; NewValue: Boolean; ValueKind: TUNSValueKind = vkActual); virtual;

    Function BooleanValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure BooleanValueSet(const ValueName: String; NewValue: Boolean; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.BooleanValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'BooleanValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoBool(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoBool(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoBool(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'BooleanValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeBool(TempNode).Value;
    vkSaved:    Result := TUNSNodeBool(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeBool(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'BooleanValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueSetNoLock(const ValueName: String; NewValue: Boolean; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBool,'BooleanValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoBool(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoBool(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoBool(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'BooleanValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeBool(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeBool(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeBool(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'BooleanValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BooleanValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
ReadLock;
try
  Result := BooleanValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueSet(const ValueName: String; NewValue: Boolean; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  BooleanValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
