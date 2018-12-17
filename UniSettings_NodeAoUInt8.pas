unit UniSettings_NodeAoUInt8;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoUInt8}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayUInt8,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = UInt8;
  TUNSNodeValueItemTypeBin = UInt8;
  TUNSNodeValueItemTypePtr = PUInt8;

  TUNSNodeValueType    = TUInt8CountedDynArray;
  TUNSNodeValueTypePtr = PUInt8CountedDynArray;

  TUNSNodeAoUInt8 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoUInt8;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt8; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt8;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt8
      = BinaryStreaming.Stream_ReadUInt8;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: UInt8; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteUInt8;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): UInt8
      = BinaryStreaming.Ptr_ReadUInt8;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoUInt8;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtUInt8;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,2)
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
