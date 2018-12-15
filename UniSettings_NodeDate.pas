{$IFNDEF Included}
unit UniSettings_NodeDate;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeDate}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = TDate;
  TUNSNodeValueTypeBin = TDate;
  TUNSNodeValueTypePtr = PDate;

  TUNSNodeDate = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeDate;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Float64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteFloat64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Float64
      = BinaryStreaming.Stream_ReadFloat64;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Float64): TMemSize
      = BinaryStreaming.Ptr_WriteFloat64;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): Float64
      = BinaryStreaming.Ptr_ReadFloat64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtDate;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToDate(Str,fConvSettings);
  end
else Result := StrToDate(Str,fConvSettings);
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := Now;
fSavedValue := fValue;
fDefaultValue := fValue;
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
    Function DateValueGet(const ValueName: String; AccessDefVal: Boolean = False): TDate; virtual;
    procedure DateValueSet(const ValueName: String; NewValue: TDate; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.DateValueGet(const ValueName: String; AccessDefVal: Boolean = False): TDate;
begin
ReadLock;
try
  with TUNSNodeDate(CheckedLeafNodeTypeAccess(ValueName,vtDate,'DateValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateValueSet(const ValueName: String; NewValue: TDate; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeDate(CheckedLeafNodeTypeAccess(ValueName,vtDate,'DateValueSet')) do
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
