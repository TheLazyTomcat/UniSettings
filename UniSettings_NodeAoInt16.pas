unit UniSettings_NodeAoInt16;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt16}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt16,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Int16;
  TUNSNodeValueItemTypeBin = Int16;
  TUNSNodeValueItemTypePtr = PInt16;

  TUNSNodeValueType    = TInt16CountedDynArray;
  TUNSNodeValueTypePtr = PInt16CountedDynArray;

  TUNSNodeAoInt16 = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoInt16;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int16; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt16;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int16
      = BinaryStreaming.Stream_ReadInt16;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Int16; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteInt16;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Int16
      = BinaryStreaming.Ptr_ReadInt16;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt16;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtInt16;
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
