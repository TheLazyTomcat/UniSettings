{$IFNDEF Included}
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

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function UInt16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt16; virtual;
    procedure UInt16ValueSet(const ValueName: String; NewValue: UInt16; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt16;
begin
ReadLock;
try
  with TUNSNodeUInt16(CheckedLeafNodeTypeAccess(ValueName,vtUInt16,'UInt16ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueSet(const ValueName: String; NewValue: UInt16; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeUInt16(CheckedLeafNodeTypeAccess(ValueName,vtUInt16,'UInt16ValueSet')) do
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
