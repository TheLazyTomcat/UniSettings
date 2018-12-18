{$IFNDEF UNS_Included}
unit UniSettings_NodeText;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeText}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = String;
  TUNSNodeValueTypeBin = String;
  TUNSNodeValueTypePtr = PString;

  TUNSNodeText = class(TUNSNodeLeaf)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_Node.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeText;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; const Value: String; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteString;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): String
      = BinaryStreaming.Stream_ReadString;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; const Value: String): TMemSize
      = BinaryStreaming.Ptr_WriteString;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): String
      = BinaryStreaming.Ptr_ReadString;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtText;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
Result := Value;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := Str;
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := '';
fSavedValue := '';
fDefaultValue := '';
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
    Function TextValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String; virtual;
    procedure TextValueSetNoLock(const ValueName: String; const NewValue: String; ValueKind: TUNSValueKind = vkActual); virtual;

    Function TextValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String; virtual;
    procedure TextValueSet(const ValueName: String; const NewValue: String; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.TextValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeTypeAccessIsArray(ValueName,vtText,'TextValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   Result := TUNSNodeAoText(TempNode).Items[TempIndex];
    vkSaved:    Result := TUNSNodeAoText(TempNode).SavedItems[TempIndex];
    vkDefault:  Result := TUNSNodeAoText(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'TextValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   Result := TUNSNodeText(TempNode).Value;
    vkSaved:    Result := TUNSNodeText(TempNode).SavedValue;
    vkDefault:  Result := TUNSNodeText(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'TextValueGetNoLock');
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.TextValueSetNoLock(const ValueName: String; const NewValue: String; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeTypeAccessIsArray(ValueName,vtText,'TextValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoText(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoText(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoText(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'TextValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeText(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeText(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeText(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'TextValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.TextValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
begin
ReadLock;
try
  Result := TextValueGetNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TextValueSet(const ValueName: String; const NewValue: String; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  TextValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
