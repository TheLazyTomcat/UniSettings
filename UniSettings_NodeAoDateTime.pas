unit UniSettings_NodeAoDateTime;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoDateTime}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayDateTime,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = TDateTime;
  TUNSNodeValueItemTypeBin = TDateTime;
  TUNSNodeValueItemTypePtr = PDateTime;

  TUNSNodeValueType    = TDateTimeCountedDynArray;
  TUNSNodeValueTypePtr = PDateTimeCountedDynArray;

  TUNSNodeAoDateTime = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeAoDateTime;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Float64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteFloat64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Float64
      = BinaryStreaming.Stream_ReadFloat64;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Float64; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteFloat64;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Float64
      = BinaryStreaming.Ptr_ReadFloat64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoDateTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateTimeToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToDateTime(Str,fConvSettings);
  end
else Result := StrToDateTime(Str,fConvSettings);
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

end.
