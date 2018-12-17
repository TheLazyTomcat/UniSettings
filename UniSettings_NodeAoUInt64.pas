unit UniSettings_NodeAoUInt64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoUInt64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayUInt64,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = UInt64;
  TUNSNodeValueItemTypeBin = UInt64;
  TUNSNodeValueItemTypePtr = PUInt64;

  TUNSNodeValueType    = TUInt64CountedDynArray;
  TUNSNodeValueTypePtr = PUInt64CountedDynArray;

  TUNSNodeAoUInt64 = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeAoUInt64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt64
      = BinaryStreaming.Stream_ReadUInt64;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: UInt64; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteUInt64;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): UInt64
      = BinaryStreaming.Ptr_ReadUInt64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoUInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,16)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
Result := TUNSNodeValueItemType(StrToInt64(Str));
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

end.