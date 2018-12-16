{$IFNDEF Included}
unit UniSettings_NodeUInt32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeUInt32}

interface         

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = UInt32;
  TUNSNodeValueTypeBin = UInt32;
  TUNSNodeValueTypePtr = PuInt32;

  TUNSNodeUInt32 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeUInt32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt32
      = BinaryStreaming.Stream_ReadUInt32;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: UInt32): TMemSize
      = BinaryStreaming.Ptr_WriteUInt32;

  UNS_BufferReadFunction:
    Function(Dest: Pointer): UInt32
      = BinaryStreaming.Ptr_ReadUInt32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtUInt32;
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

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function UInt32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt32; virtual;
    procedure UInt32ValueSet(const ValueName: String; NewValue: UInt32; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt32;
begin
ReadLock;
try
  with TUNSNodeUInt32(CheckedLeafNodeTypeAccess(ValueName,vtUInt32,'UInt32ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt32ValueSet(const ValueName: String; NewValue: UInt32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeUInt32(CheckedLeafNodeTypeAccess(ValueName,vtUInt32,'UInt32ValueSet')) do
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
