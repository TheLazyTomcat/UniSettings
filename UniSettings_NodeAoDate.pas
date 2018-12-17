unit UniSettings_NodeAoDate;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoDate}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrays,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TDateCountedDynArray = record
    Arr:    array of TDate;
    Count:  Integer;
    Data:   PtrInt;
  end;
  PDateCountedDynArray = ^TDateCountedDynArray;

  TCDABaseType = TDate;
  TCDAArrayType = TDateCountedDynArray;

{$DEFINE CDA_Interface}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Interface}

//------------------------------------------------------------------------------

type
  TUNSNodeValueItemType    = TDate;
  TUNSNodeValueItemTypeBin = TDate;
  TUNSNodeValueItemTypePtr = PDate;

  TUNSNodeValueType    = TDateCountedDynArray;
  TUNSNodeValueTypePtr = PDateCountedDynArray;

  TUNSNodeAoDate = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex, ListSorters,
  UniSettings_Exceptions;

Function CDA_CompareFunc(A,B: TCDABaseType): Integer;
begin
If Int(A) > Int(B) then Result := -1
  else If Int(A) < Int(B) then Result := 1
    else Result := 0;
end;

//------------------------------------------------------------------------------

{$DEFINE CDA_Implementation}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Implementation}

//==============================================================================

type
  TUNSNodeClassType = TUNSNodeAoDate;

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
Result := vtAoDate;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
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

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

end.
