unit UniSettings_NodeAoInt64;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt64}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt64,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Int64;
  TUNSNodeValueItemTypeBin = Int64;
  TUNSNodeValueItemTypePtr = PInt64;

  TUNSNodeValueType    = TInt64CountedDynArray;
  TUNSNodeValueTypePtr = PInt64CountedDynArray;

  TUNSNodeAoInt64 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoInt64;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int64; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt64;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int64
      = BinaryStreaming.Stream_ReadInt64;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Int64; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteInt64;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Int64
      = BinaryStreaming.Ptr_ReadInt64;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt64;
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
