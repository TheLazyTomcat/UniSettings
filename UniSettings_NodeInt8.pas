{$IFNDEF Included}
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

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function Int8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    procedure Int8ValueSet(const ValueName: String; NewValue: Int8; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Int8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8;
begin
ReadLock;
try
  with TUNSNodeInt8(CheckedLeafNodeTypeAccess(ValueName,vtInt8,'Int8ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int8ValueSet(const ValueName: String; NewValue: Int8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  with TUNSNodeInt8(CheckedLeafNodeTypeAccess(ValueName,vtInt8,'Int8ValueSet')) do
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
