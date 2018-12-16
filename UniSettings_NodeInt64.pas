{$IFNDEF Included}
unit UniSettings_NodeInt64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeInt64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Int64;
  TUNSNodeValueTypeBin = Int64;
  TUNSNodeValueTypePtr = PInt64;

  TUNSNodeInt64 = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeInt64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int64
      = BinaryStreaming.Stream_ReadInt64;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Int64): TMemSize
      = BinaryStreaming.Ptr_WriteInt64;

  UNS_BufferReadFunction:
    Function(Dest: Pointer): Int64
      = BinaryStreaming.Ptr_ReadInt64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,16)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := TUNSNodeValueType(StrToInt64(Str));
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
    Function Int64ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int64; virtual;
    procedure Int64ValueSet(const ValueName: String; NewValue: Int64; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Int64ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int64;
begin
ReadLock;
try
  with TUNSNodeInt64(CheckedLeafNodeTypeAccess(ValueName,vtInt64,'Int64ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int64ValueSet(const ValueName: String; NewValue: Int64; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeInt64(CheckedLeafNodeTypeAccess(ValueName,vtInt64,'Int64ValueSet')) do
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
