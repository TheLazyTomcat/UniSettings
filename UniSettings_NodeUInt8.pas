{$IFNDEF Included}
unit UniSettings_NodeUInt8;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeUInt8}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = UInt8;
  TUNSNodeValueTypeBin = UInt8;
  TUNSNodeValueTypePtr = PUInt8;

  TUNSNodeUInt8 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeUInt8;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt8; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt8;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt8
      = BinaryStreaming.Stream_ReadUInt8;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: UInt8): TMemSize
      = BinaryStreaming.Ptr_WriteUInt8;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): UInt8
      = BinaryStreaming.Ptr_ReadUInt8;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtUInt8;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(Value: TUNSNodeValueType): String;
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
    Function UInt8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    procedure UInt8ValueSet(const ValueName: String; NewValue: UInt8; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
ReadLock;
try
  with TUNSNodeUInt8(CheckedLeafNodeTypeAccess(ValueName,vtUInt8,'UInt8ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueSet(const ValueName: String; NewValue: UInt8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  with TUNSNodeUInt8(CheckedLeafNodeTypeAccess(ValueName,vtUInt8,'UInt8ValueSet')) do
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
