{$IFNDEF Included}
unit UniSettings_NodeBuffer;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeBuffer}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeValueType    = TMemoryBuffer;
  TUNSNodeValueTypeBin = TMemoryBuffer;
  TUNSNodeValueTypePtr = PMemoryBuffer;

  TUNSNodeBuffer = class(TUNSNodeLeaf)
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
  TUNSNodeClassType = TUNSNodeBuffer;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtBuffer;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(Value: TUNSNodeValueType): String;
var
  i:        TMemSize;
  TempStr:  String;
begin
If Value.Size > 0 then
  begin
    SetLength(Result,Value.Size * 2);
    For i := 0 to Pred(Value.Size) do
      begin
        TempStr := IntToHex(PByte(PtrUInt(Value.Memory) + PtrUInt(i))^,2);
        Result[(i * 2) + 1] := TempStr[1];
        Result[(i * 2) + 2] := TempStr[2];
      end;
  end
else Result := '';
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ConvFromStr(const Str: String; var Value: TUNSNodeValueType);
var
  TempSize: TMemSize;
  TempPtr:  PByte;
  i:        TMemSize;
  StrOff:   Integer;
begin
If Str[1] = '$' then StrOff := 2
  else StrOff := 1;
TempSize := TMemSize(Length(Str) div 2);
ReallocBuffer(Value,TempSize);
TempPtr := Value.Memory;
If TempSize > 0 then
  For i := 0 to Pred(TempSize) do
    begin
      TempPtr^ := Byte(StrToInt('$' + Copy(Str,(i * 2) + StrOff,2)));
      Inc(TempPtr);
    end;
DoChange;
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
InitBuffer(fValue);
InitBuffer(fSavedValue);
InitBuffer(fDefaultValue);
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
    Function BufferValueGet(const ValueName: String; CreateCopy: Boolean = True; AccessDefVal: Boolean = False): TUNSNodeValueType; virtual;
    procedure BufferValueSet(const ValueName: String; NewValue: TUNSNodeValueType; CreateCopy: Boolean = True; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.BufferValueGet(const ValueName: String; CreateCopy: Boolean = True; AccessDefVal: Boolean = False): TUNSNodeValueType;
var
  Temp: TUNSNodeValueType;
begin
ReadLock;
try
  with TUNSNodeBuffer(CheckedLeafNodeTypeAccess(ValueName,vtBuffer,'BufferValueGet')) do
    If AccessDefVal then
      Temp := Value
    else
      Temp := DefaultValue;
  If CreateCopy then
    CopyBuffer(Temp,Result)
  else
    Result := Temp;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BufferValueSet(const ValueName: String; NewValue: TUNSNodeValueType; CreateCopy: Boolean = True; AccessDefVal: Boolean = False);
var
  Temp: TUNSNodeValueType;
begin
WriteLock;
try
  If CreateCopy then
    CopyBuffer(NewValue,Temp)
  else
    Temp := NewValue;
  with TUNSNodeBuffer(CheckedLeafNodeTypeAccess(ValueName,vtBuffer,'BufferValueSet')) do
    If AccessDefVal then
      Value := Temp
    else
      DefaultValue := Temp;
finally
  WriteUnlock;
end;
end;

{$ENDIF}

{$ENDIF Included}
