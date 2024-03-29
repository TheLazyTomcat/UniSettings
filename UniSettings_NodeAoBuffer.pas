{$IFNDEF UNS_Included}
unit UniSettings_NodeAoBuffer;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoBuffer}

interface

uses
  Classes, IniFiles, Registry,
  AuxTypes, MemoryBuffer, CountedDynArrays, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TBufferCountedDynArray = record
    Arr:    array of TMemoryBuffer;
    SigA:   UInt32;
    Count:  Integer;
    Data:   PtrInt;
    SigB:   UInt32;
  end;
  PBufferCountedDynArray = ^TBufferCountedDynArray;

  TCDABaseType = TMemoryBuffer;
  PCDABaseType = PMemoryBuffer;

  TCDAArrayType = TBufferCountedDynArray;
  PCDAArrayType = PBufferCountedDynArray;

{$DEFINE CDA_Interface}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Interface}

//------------------------------------------------------------------------------

type
  TUNSNodeValueItemType    = TMemoryBuffer;
  TUNSNodeValueItemTypeBin = TMemoryBuffer;
  TUNSNodeValueItemTypePtr = PMemoryBuffer;

  TUNSNodeValueType    = TBufferCountedDynArray;
  TUNSNodeValueTypePtr = PBufferCountedDynArray;

  TUNSNodeAoBuffer = class(TUNSNodePrimitiveArray)
  {$DEFINE UNS_NodeInclude_Declaration}
    {$INCLUDE '.\UniSettings_NodeArray.inc'}
  {$UNDEF UNS_NodeInclude_Declaration}
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex, ListSorters,
  UniSettings_Exceptions;

Function CDA_CompareFunc(A,B: TCDABaseType): Integer;
var
  i:          TMemSize;
  APtr,BPtr:  PByte;
begin
If A.Size = B.Size then
  begin
    If A.Size > 0 then
      begin
        APtr := A.Memory;
        BPtr := B.Memory;
        Result := 0;
        For i := 0 to Pred(A.Size) do
          begin
            If APtr^ <> BPtr^ then
              begin
                Result := Integer(BPtr^ - APtr^);
                Break{For i};
              end;
            Inc(APtr);
            Inc(BPtr);
          end;
      end
    else Result := 0;
  end
else
  begin
    If A.Size > B.Size then Result := -1
      else If A.Size < B.Size then Result := 1
        else Result := 0;
  end;
end;

//------------------------------------------------------------------------------

{$DEFINE CDA_Implementation}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Implementation}

//==============================================================================

type
  TUNSNodeClassType = TUNSNodeAoBuffer;

procedure UNS_StreamWriteFunction(Stream: TStream; const Buffer: TMemoryBuffer);
begin
Stream_WriteUInt64(Stream,UInt64(Buffer.Size));
Stream_WriteBuffer(Stream,Buffer.Memory^,Buffer.Size);
end;

//------------------------------------------------------------------------------

Function UNS_StreamReadFunction(Stream: TStream): TMemoryBuffer;
begin
GetBuffer(Result,TMemSize(Stream_ReadUInt64(Stream)));
Stream_ReadBuffer(Stream,Result.Memory^,Result.Size);
end;

//------------------------------------------------------------------------------

procedure UNS_BufferWriteFunction(var Memory: Pointer; const Buffer: TMemoryBuffer; Advance: Boolean);
begin
Ptr_WriteUInt64(Memory,UInt64(Buffer.Size),Advance);
Ptr_WriteBuffer(Memory,Buffer.Memory^,Buffer.Size,Advance);
end;

//------------------------------------------------------------------------------

Function UNS_BufferReadFunction(var Memory: Pointer; Advance: Boolean): TMemoryBuffer;
begin
GetBuffer(Result,TMemSize(Ptr_ReadUInt64(Memory,Advance)));
Ptr_ReadBuffer(Memory,Result.Memory^,Result.Size,Advance);
end;

//==============================================================================

procedure CopyArrayInto(const Src: TUNSNodeValueType; var Dest: TUNSNodeValueType);
var
  i:    Integer;
  Temp: TUNSNodeValueItemType;
begin
For i := CDA_Low(Dest) to CDA_High(Dest) do
  FreeBuffer(CDA_GetItemPtr(Dest,i)^);
CDA_Clear(Dest);
For i := CDA_Low(Src) to CDA_High(Src) do
  begin
    CopyBuffer(CDA_GetItem(Src,i),Temp);
    CDA_Add(Dest,Temp);
  end;
end;

//==============================================================================

class Function TUNSNodeClassType.GetValueType: TUNSValueType;
begin
Result := vtAoBuffer;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.GetItemValueType: TUNSValueType;
begin
Result := vtBuffer;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvItemToStr(const Value: TUNSNodeValueItemType): String;
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

procedure TUNSNodeClassType.ConvItemFromStr(const Str: String; out Item: TUNSNodeValueItemType);
var
  TempSize: TMemSize;
  TempPtr:  PByte;
  i:        TMemSize;
  StrOff:   Integer;
begin
If Str[1] = '$' then StrOff := 2
  else StrOff := 1;
TempSize := TMemSize(Length(Str) div 2);
GetBuffer(Item,TempSize);
TempPtr := Item.Memory;
If TempSize > 0 then
  For i := 0 to Pred(TempSize) do
    begin
      TempPtr^ := Byte(StrToInt('$' + Copy(Str,Integer(i * 2) + StrOff,2)));
      Inc(TempPtr);
    end;
end;

//==============================================================================

procedure TUNSNodeClassType.SaveItemTo(Ini: TIniFile; Index: Integer; const Section,Key: String);
begin
Ini.WriteString(Section,Key,AsString(Index,vkActual));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveItemTo(Ini: TIniFileEx; Index: Integer; const Section,Key: String);
var
  Buffer: TMemoryBuffer;
begin
Buffer := GetItem(Index);
Ini.WriteBinaryMemory(Section,Key,Buffer.Memory,Buffer.Size,True);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.SaveItemTo(Reg: TRegistry; Index: Integer; const Value: String);
var
  Buffer: TMemoryBuffer;
begin
Buffer := GetItem(Index);
Reg.WriteBinaryData(Value,Buffer.Memory^,Buffer.Size);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.LoadItemFrom(Ini: TIniFile; Index: Integer; const Section,Key: String);
begin
FromString(Index,Ini.ReadString(Section,Key,AsString(Index,vkActual)),vkActual);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadItemFrom(Ini: TIniFileEx; Index: Integer; const Section,Key: String);
var
  Buffer: TMemoryBuffer;
begin
InitBuffer(Buffer);
// following will also allocate the buffer memory
Buffer.Size := Ini.ReadBinaryMemory(Section,Key,Buffer.Memory,False);
try
  SetItem(Index,Buffer);
finally
  FreeBuffer(Buffer);
end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSNodeClassType.LoadItemFrom(Reg: TRegistry; Index: Integer; const Value: String);
var
  Buffer: TMemoryBuffer;
begin
GetBuffer(Buffer,Reg.GetDataSize(Value));
try
  Reg.ReadBinaryData(Value,Buffer.Memory^,Buffer.Size);
  SetItem(Index,Buffer);
finally
  FreeBuffer(Buffer);
end;
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_NodeInclude_Implementation}
  {$INCLUDE '.\UniSettings_NodeArray.inc'}
{$UNDEF UNS_NodeInclude_Implementation}

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE UNS_Included}

{$WARNINGS ON}

{$IFDEF UNS_Include_Declaration}
    Function BufferValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer; virtual;
    Function BufferValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer; virtual;
    Function BufferValueIndexOfNoLock(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function BufferValueAddNoLock(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function BufferValueAppendNoLock(const ValueName: String; const Values: array of TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure BufferValueInsertNoLock(const ValueName: String; Index: Integer; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    Function BufferValueRemoveNoLock(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function BufferValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer; virtual;
    Function BufferValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer; virtual;
    Function BufferValueIndexOf(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function BufferValueAdd(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function BufferValueAppend(const ValueName: String; const Values: array of TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    procedure BufferValueInsert(const ValueName: String; Index: Integer; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    Function BufferValueRemove(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer; virtual;

    Function BufferValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer; virtual;
    procedure BufferValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;

    Function BufferValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer; virtual;
    procedure BufferValueItemSet(const ValueName: String; Index: Integer; const NewValue: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF UNS_Include_Declaration}

//==============================================================================

{$IFDEF UNS_Include_Implementation}

Function TUniSettings.BufferValueFirstNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer;
var
  TempBuffer: TMemoryBuffer;
begin
TempBuffer := TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueFirstNoLock')).First(ValueKind);
If CreateCopy then
  CopyBuffer(TempBuffer,Result)
else
  Result := TempBuffer;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueLastNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer;
var
  TempBuffer: TMemoryBuffer;
begin
TempBuffer := TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueLastNoLock')).Last(ValueKind);
If CreateCopy then
  CopyBuffer(TempBuffer,Result)
else
  Result := TempBuffer;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueIndexOfNoLock(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueIndexOfNoLock')).IndexOf(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueAddNoLock(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueAddNoLock')).Add(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueAppendNoLock(const ValueName: String; const Values: array of TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueAppendNoLock')).Append(Values,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BufferValueInsertNoLock(const ValueName: String; Index: Integer; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueInsertNoLock')).Insert(Index,Value,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.BufferValueRemoveNoLock(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueRemoveNoLock')).Remove(Value,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueFirst(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer;
begin
ReadLock;
try
  Result := BufferValueFirstNoLock(ValueName,ValueKind,CreateCopy);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueLast(const ValueName: String; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer;
begin
ReadLock;
try
  Result := BufferValueLastNoLock(ValueName,ValueKind,CreateCopy);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueIndexOf(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := BufferValueIndexOfNoLock(ValueName,Value,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueAdd(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := BufferValueAddNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueAppend(const ValueName: String; const Values: array of TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := BufferValueAppendNoLock(ValueName,Values,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BufferValueInsert(const ValueName: String; Index: Integer; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  BufferValueInsertNoLock(ValueName,Index,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueRemove(const ValueName: String; const Value: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual): Integer;
begin
WriteLock;
try
  Result := BufferValueRemoveNoLock(ValueName,Value,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueItemGetNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer;
var
  TempBuffer: TMemoryBuffer;
begin
with TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueItemGetNoLock')) do
  case ValueKind of
    vkActual:   TempBuffer := Items[Index];
    vkSaved:    TempBuffer := SavedItems[Index];
    vkDefault:  TempBuffer := DefaultItems[Index];
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'BufferValueItemGetNoLock');
  end;
If CreateCopy then
  CopyBuffer(TempBuffer,Result)
else
  Result := TempBuffer;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BufferValueItemSetNoLock(const ValueName: String; Index: Integer; const NewValue: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
with TUNSNodeAoBuffer(AccessLeafNodeType(ValueName,vtAoBuffer,'BufferValueItemSetNoLock')) do
  case ValueKind of
    vkActual:   Items[Index] := NewValue;
    vkSaved:    SavedItems[Index] := NewValue;
    vkDefault:  DefaultItems[Index] := NewValue;
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'BufferValueItemSetNoLock');
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.BufferValueItemGet(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual; CreateCopy: Boolean = True): TMemoryBuffer;
begin
ReadLock;
try
  Result := BufferValueItemGetNoLock(ValueName,Index,ValueKind,CreateCopy);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BufferValueItemSet(const ValueName: String; Index: Integer; const NewValue: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  BufferValueItemSetNoLock(ValueName,Index,NewValue,ValueKind);
finally
  WriteUnlock;
end;
end;

{$ENDIF UNS_Include_Implementation}

{$ENDIF UNS_Included}
