{$IFNDEF Included}
unit UniSettings_NodeInt16;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeInt16}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = Int16;
  TUNSNodeValueTypeBin = Int16;
  TUNSNodeValueTypePtr = PInt16;

  TUNSNodeInt16 = class(TUNSNodeLeaf)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_Node.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;
  
implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeInt16;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; Value: Int16; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteInt16;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): Int16
      = BinaryStreaming.Stream_ReadInt16;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; Value: Int16): TMemSize
      = BinaryStreaming.Ptr_WriteInt16;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): Int16
      = BinaryStreaming.Ptr_ReadInt16;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtInt16;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(Value: TUNSNodeValueType): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,4)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := TUNSNodeValueType(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_Node.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function Int16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int16; virtual;
    procedure Int16ValueSet(const ValueName: String; NewValue: Int16; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Int16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int16;
begin
ReadLock;
try
  with TUNSNodeInt16(CheckedLeafNodeTypeAccess(ValueName,vtInt16,'Int16ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueSet(const ValueName: String; NewValue: Int16; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeInt16(CheckedLeafNodeTypeAccess(ValueName,vtInt16,'Int16ValueSet')) do
    If AccessDefVal then
      Value := NewValue
    else
      DefaultValue := NewValue;
finally
  WriteUnlock;
end;
end;

{$ENDIF}

{$ENDIF Included}
