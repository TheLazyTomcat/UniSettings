unit UniSettings_NodeAoBool;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoBool}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayBool,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Boolean;
  TUNSNodeValueItemTypeBin = ByteBool;
  TUNSNodeValueItemTypePtr = PBoolean;

  TUNSNodeValueType        = TBooleanCountedDynArray;
  TUNSNodeValueTypePtr     = PBooleanCountedDynArray;

  TUNSNodeAoBool = class(TUNSNodePrimitiveArray)
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
  TUNSNodeClassType = TUNSNodeAoBool;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: ByteBool; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteBool;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): ByteBool
      = BinaryStreaming.Stream_ReadBool;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: ByteBool; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteBool;
      
  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): ByteBool
      = BinaryStreaming.Ptr_ReadBool;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoInt32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.NumericBools then
  Result := IntToStr(Ord(Value))
else
  Result := BoolToStr(Value,True);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
Result := StrToBool(Str);
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}  

end.
