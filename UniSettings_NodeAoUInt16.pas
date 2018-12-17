unit UniSettings_NodeAoUInt16;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoUInt16}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayUInt16,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = UInt16;
  TUNSNodeValueItemTypeBin = UInt16;
  TUNSNodeValueItemTypePtr = PUInt16;

  TUNSNodeValueType    = TUInt16CountedDynArray;
  TUNSNodeValueTypePtr = PUInt16CountedDynArray;

  TUNSNodeAoUInt16 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoUInt16;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: UInt16; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteUInt16;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): UInt16
      = BinaryStreaming.Stream_ReadUInt16;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: UInt16; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteUInt16;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): UInt16
      = BinaryStreaming.Ptr_ReadUInt16;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoUInt16;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtUInt16;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,4)
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
