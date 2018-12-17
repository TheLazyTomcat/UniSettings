unit UniSettings_NodeAoInt32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt32}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt32,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Int32;
  TUNSNodeValueItemTypeBin = Int32;
  TUNSNodeValueItemTypePtr = PInt32;

  TUNSNodeValueType    = TInt32CountedDynArray;
  TUNSNodeValueTypePtr = PInt32CountedDynArray;

  TUNSNodeAoInt32 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoInt32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int32
      = BinaryStreaming.Stream_ReadInt32;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Int32; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteInt32;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Int32
      = BinaryStreaming.Ptr_ReadInt32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt32;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtInt64;
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
