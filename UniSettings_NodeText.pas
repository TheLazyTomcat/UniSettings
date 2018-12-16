{$IFNDEF Included}
unit UniSettings_NodeText;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeText}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = String;
  TUNSNodeValueTypeBin = String;
  TUNSNodeValueTypePtr = PString;

  TUNSNodeText = class(TUNSNodeLeaf)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_Node.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect,
  UniSettings_Exceptions;

type
  TUNSNodeClassType = TUNSNodeText;

var
  UNS_StreamWriteFunction:
    Function(Stream: TStream; const Value: String; Advance: Boolean = True): TMemSize
      = BinaryStreaming.Stream_WriteString;

  UNS_StreamReadFunction:
    Function(Stream: TStream; Advance: Boolean = True): String
      = BinaryStreaming.Stream_ReadString;

  UNS_BufferWriteFunction:
    Function(Dest: Pointer; const Value: String): TMemSize
      = BinaryStreaming.Ptr_WriteString;
      
  UNS_BufferReadFunction:
    Function(Dest: Pointer): String
      = BinaryStreaming.Ptr_ReadString;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtText;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
begin
Result := Value;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvFromStr(const Str: String): TUNSNodeValueType;
begin
Result := Str;
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := '';
fSavedValue := '';
fDefaultValue := '';
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
    Function TextValueGet(const ValueName: String; ThreadSafe: Boolean = True; AccessDefVal: Boolean = False): String; virtual;
    procedure TextValueSet(const ValueName: String; NewValue: String; ThreadSafe: Boolean = True; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.TextValueGet(const ValueName: String; ThreadSafe: Boolean = True; AccessDefVal: Boolean = False): String;
begin
ReadLock;
try
  with TUNSNodeText(CheckedLeafNodeTypeAccess(ValueName,vtText,'TextValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
  If ThreadSafe then
    UniqueString(Result);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TextValueSet(const ValueName: String; NewValue: String; ThreadSafe: Boolean = True; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  If ThreadSafe then
    UniqueString(NewValue);
  with TUNSNodeText(CheckedLeafNodeTypeAccess(ValueName,vtText,'TextValueSet')) do
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
