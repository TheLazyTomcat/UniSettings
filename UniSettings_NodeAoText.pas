unit UniSettings_NodeAoText;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoText}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayString,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = String;
  TUNSNodeValueItemTypeBin = String;
  TUNSNodeValueItemTypePtr = PString;

  TUNSNodeValueType    = TStringCountedDynArray;
  TUNSNodeValueTypePtr = PStringCountedDynArray;

  TUNSNodeAoText = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeAoText;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; const Value: String; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteString;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): String
      = BinaryStreaming.Stream_ReadString;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; const Value: String; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteString;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): String
      = BinaryStreaming.Ptr_ReadString;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoText;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtText;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
Result := Value;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
Result := Str;
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

end.
