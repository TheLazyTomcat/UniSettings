unit UniSettings_NodeAoInt8;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt8}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt8,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Int8;
  TUNSNodeValueItemTypeBin = Int8;
  TUNSNodeValueItemTypePtr = PInt8;

  TUNSNodeValueType    = TInt8CountedDynArray;
  TUNSNodeValueTypePtr = PInt8CountedDynArray;

  TUNSNodeAoInt8 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoInt8;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int8; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt8;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int8
      = BinaryStreaming.Stream_ReadInt8;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Int8; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteInt8;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Int8
      = BinaryStreaming.Ptr_ReadInt8;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt8;
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
