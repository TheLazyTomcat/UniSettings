{$IFNDEF UNS_Included}
unit UniSettings_NodeBuffer;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeBuffer}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, IniFileEx,
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

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
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
      TempPtr^ := Byte(StrToInt('$' + Copy(Str,Integer(i * 2) + StrOff,2)));
      Inc(TempPtr);
    end;
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

destructor TUNSNodeClassType.Destroy;
begin
FreeBuffer(fDefaultValue);
FreeBuffer(fSavedValue);
FreeBuffer(fValue);
inherited;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SaveTo(Ini: TIniFile; const Section,Key: String);
begin
Ini.WriteString(Section,Key,AsString(vkActual));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveTo(Ini: TIniFileEx; const Section,Key: String);
begin
Ini.WriteBinaryMemory(Section,Key,fValue.Memory,fValue.Size,True);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveTo(Reg: TRegistry; const Value: String);
begin
Reg.WriteBinaryData(Value,fValue.Memory^,fValue.Size);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFile; const Section,Key: String);
begin
FromString(Ini.ReadString(Section,Key,AsString(vkActual)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Ini: TIniFileEx; const Section,Key: String);
var
  Buffer: TMemoryBuffer;
begin
InitBuffer(Buffer);
// following will also allocate the buffer memory
Buffer.Size := Ini.ReadBinaryMemory(Section,Key,Buffer.Memory,False);
try
  SetValue(Buffer);
finally
  FreeBuffer(Buffer);
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadFrom(Reg: TRegistry; const Value: String);
var
  Buffer: TMemoryBuffer;
begin
GetBuffer(Buffer,Reg.GetDataSize(Value));
try
  Reg.ReadBinaryData(Value,Buffer.Memory^,Buffer.Size);
  SetValue(Buffer);
finally
  FreeBuffer(Buffer);
end;
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_Node.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE UNS_Included}

{$WARNINGS ON}

{$IFDEF UNS_Include_Declaration}
    Function BufferValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer; virtual;
    procedure BufferValueSetNoLock(const ValueName: String; const NewValue: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;

    Function BufferValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer; virtual;
    procedure BufferValueSet(const ValueName: String; const NewValue: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.BufferValueGetNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
  TempBuffer:     TMemoryBuffer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBuffer,'BufferValueGetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TempBuffer := TUNSNodeAoBuffer(TempNode).Items[TempIndex];
    vkSaved:    TempBuffer := TUNSNodeAoBuffer(TempNode).SavedItems[TempIndex];
    vkDefault:  TempBuffer := TUNSNodeAoBuffer(TempNode).DefaultItems[TempIndex];
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'BufferValueGetNoLock');
  end
else
  case ValueKind of
    vkActual:   TempBuffer := TUNSNodeBuffer(TempNode).Value;
    vkSaved:    TempBuffer := TUNSNodeBuffer(TempNode).SavedValue;
    vkDefault:  TempBuffer := TUNSNodeBuffer(TempNode).DefaultValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'BufferValueGetNoLock');
  end;
If CreateCopy then
  CopyBuffer(TempBuffer,Result)
else
  Result := TempBuffer;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.BufferValueSetNoLock(const ValueName: String; const NewValue: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeTypeIsArray(ValueName,vtBuffer,'BufferValueSetNoLock',TempNode,TempValueKind,TempIndex) then
  case TempValueKind of
    vkActual:   TUNSNodeAoBuffer(TempNode).Items[TempIndex] := NewValue;
    vkSaved:    TUNSNodeAoBuffer(TempNode).SavedItems[TempIndex] := NewValue;
    vkDefault:  TUNSNodeAoBuffer(TempNode).DefaultItems[TempIndex] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(TempValueKind,Self,'BufferValueSetNoLock');
  end
else
  case ValueKind of
    vkActual:   TUNSNodeBuffer(TempNode).Value := NewValue;
    vkSaved:    TUNSNodeBuffer(TempNode).SavedValue := NewValue;
    vkDefault:  TUNSNodeBuffer(TempNode).DefaultValue := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'BufferValueSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer;
begin
ReadLock;
try
  Result := BufferValueGetNoLock(ValueName,ValueKind,CreateCopy);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BufferValueSet(const ValueName: String; const NewValue: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  BufferValueSetNoLock(ValueName,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
