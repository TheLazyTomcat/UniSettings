unit UniSettings_NodeAoUInt32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoUInt32}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayUInt32,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = UInt32;
  TUNSNodeValueItemTypeBin = UInt32;
  TUNSNodeValueItemTypePtr = PUInt32;

  TUNSNodeValueType    = TUInt32CountedDynArray;
  TUNSNodeValueTypePtr = PUInt32CountedDynArray;

  TUNSNodeAoUInt32 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoUInt32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt32
      = BinaryStreaming.Stream_ReadUInt32;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: UInt32; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteUInt32;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): UInt32
      = BinaryStreaming.Ptr_ReadUInt32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoUInt32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,8)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
Result := TUNSNodeValueItemType(StrToInt(Str));
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

end.
