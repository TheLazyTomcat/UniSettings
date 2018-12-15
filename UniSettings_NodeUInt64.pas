{$IFNDEF Included}
unit UniSettings_NodeUInt64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeUInt64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = UInt64;
  TUNSNodeValueTypeBin = UInt64;
  TUNSNodeValueTypePtr = PUInt64;

  TUNSNodeUInt64 = class(TUNSNodeLeaf)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_Node.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions, UniSettings_Utils;

type
  TUNSNodeClassType = TUNSNodeUInt64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt64
      = BinaryStreaming.Stream_ReadUInt64;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: UInt64): TMemSize
      = BinaryStreaming.Ptr_WriteUInt64;

  UNS_BufferReadFunction:
    Function(Dest: Pointer): UInt64
      = BinaryStreaming.Ptr_ReadUInt64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtUInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,16)
else
  Result := UNSUInt64ToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := TUNSNodeValueType(UNSStrToUInt64(Str));
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
    Function UInt64ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt64; virtual;
    procedure UInt64ValueSet(const ValueName: String; NewValue: UInt64; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt64ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt64;
begin
ReadLock;
try
  with TUNSNodeUInt64(CheckedLeafNodeTypeAccess(ValueName,vtUInt64,'UInt64ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt64ValueSet(const ValueName: String; NewValue: UInt64; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeUInt64(CheckedLeafNodeTypeAccess(ValueName,vtUInt64,'UInt64ValueSet')) do
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
