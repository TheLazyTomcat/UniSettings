{$IFNDEF Included}
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

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function Int32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int32; virtual;
    procedure Int32ValueSet(const ValueName: String; NewValue: Int32; AccessDefVal: Boolean = False); virtual;
    Function IntegerValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int32; virtual;
    procedure IntegerValueSet(const ValueName: String; NewValue: Int32; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Int32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int32;
begin
ReadLock;
try
  with TUNSNodeInt32(CheckedLeafNodeTypeAccess(ValueName,vtBool,'Int32ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int32ValueSet(const ValueName: String; NewValue: Int32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeInt32(CheckedLeafNodeTypeAccess(ValueName,vtInt32,'Int32ValueSet')) do
    If AccessDefVal then
      Value := NewValue
    else
      DefaultValue := NewValue;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.IntegerValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int32;
begin
ReadLock;
try
  with TUNSNodeInt32(CheckedLeafNodeTypeAccess(ValueName,vtInteger,'IntegerValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.IntegerValueSet(const ValueName: String; NewValue: Int32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeInt32(CheckedLeafNodeTypeAccess(ValueName,vtInteger,'IntegerValueSet')) do
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
