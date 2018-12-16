{$IFNDEF Included}
unit UniSettings_NodeFloat32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeFloat32}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Float32;
  TUNSNodeValueTypeBin = Float32;
  TUNSNodeValueTypePtr = PFloat32;

  TUNSNodeFloat32 = class(TUNSNodeLeaf)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_Node.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeFloat32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Float32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteFloat32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Float32
      = BinaryStreaming.Stream_ReadFloat32;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Float32): TMemSize
      = BinaryStreaming.Ptr_WriteFloat32;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): Float32
      = BinaryStreaming.Ptr_ReadFloat32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtFloat32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexFloats then
  Result := '$' + SingleToHex(Value)
else
  Result := FloatToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToSingle(Str)
    else
      Result := StrToFloat(Str,fConvSettings);
  end
else Result := StrToFloat(Str,fConvSettings);
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0.0;
fSavedValue := 0.0;
fDefaultValue := 0.0;
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
    Function Float32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float32; virtual;
    procedure Float32ValueSet(const ValueName: String; NewValue: Float32; AccessDefVal: Boolean = False); virtual;
    Function FloatValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float32; virtual;
    procedure FloatValueSet(const ValueName: String; NewValue: Float32; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Float32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float32;
begin
ReadLock;
try
  with TUNSNodeFloat32(CheckedLeafNodeTypeAccess(ValueName,vtFloat32,'Float32ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float32ValueSet(const ValueName: String; NewValue: Float32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeFloat32(CheckedLeafNodeTypeAccess(ValueName,vtFloat32,'Float32ValueSet')) do
    If AccessDefVal then
      Value := NewValue
    else
      DefaultValue := NewValue;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.FloatValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float32;
begin
ReadLock;
try
  with TUNSNodeFloat32(CheckedLeafNodeTypeAccess(ValueName,vtFloat,'FloatValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.FloatValueSet(const ValueName: String; NewValue: Float32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeFloat32(CheckedLeafNodeTypeAccess(ValueName,vtFloat,'FloatValueSet')) do
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
