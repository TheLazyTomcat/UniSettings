unit UniSettings_NodeAoFloat32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoFloat32}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayFloat32,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeValueItemType    = Float32;
  TUNSNodeValueItemTypeBin = Float32;
  TUNSNodeValueItemTypePtr = PFloat32;

  TUNSNodeValueType    = TFloat32CountedDynArray;
  TUNSNodeValueTypePtr = PFloat32CountedDynArray;

  TUNSNodeAoFloat32 = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeAoFloat32;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Float32; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteFloat32;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Float32
      = BinaryStreaming.Stream_ReadFloat32;

  UNS_BufferWriteFunction:
    Function(var Dest: Pointer; Value: Float32; Advance: Boolean): TMemSize
      = BinaryStreaming.Ptr_WriteFloat32;

  UNS_BufferReadFunction:
    Function(var Dest: Pointer; Advance: Boolean): Float32
      = BinaryStreaming.Ptr_ReadFloat32;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoFloat32;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtFloat32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
begin
If ValueFormatSettings.HexFloats then
  Result := '$' + SingleToHex(Value)
else
  Result := FloatToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemFromStr(const Str: String): TUNSNodeValueItemType;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToSingle(Str)
    else
      Result := StrToFloat(Str,fConvSettings);
  end
else Result := StrToFloat(Str,fConvSettings);
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

end.
