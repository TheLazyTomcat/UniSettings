{$IFNDEF Included}
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

Function TUNSNodeClassType.ConvToStr(Value: TUNSNodeValueType): String;
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

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function BooleanValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure BooleanValueSet(const ValueName: String; NewValue: Boolean; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.BooleanValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
ReadLock;
try
  with TUNSNodeBool(CheckedLeafNodeTypeAccess(ValueName,vtBool,'BooleanValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueSet(const ValueName: String; NewValue: Boolean; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  with TUNSNodeBool(CheckedLeafNodeTypeAccess(ValueName,vtBool,'BooleanValueSet')) do
    If AccessDefVal then
      Value := NewValue
    else
      DefaultValue := NewValue;
finally
  WriteUnlock;
end;
end;

{$ENDIF}

{$ENDIF Included}
