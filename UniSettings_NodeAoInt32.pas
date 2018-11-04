unit UniSettings_NodeAoInt32;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodePrimitiveArray;

type
  TUNSNodeAoInt32 = class(TUNSNodePrimitiveArray)
  private
    fValue:         TUNSAoInt32;
    fDefaultValue:  TUNSAoInt32;
    Function GetValueItem(Index: Integer): Int32;
    procedure SetValueItem(Index: Integer; Value: Int32);
    Function GetDefaultValueItem(Index: Integer): Int32;
    procedure SetDefaultValueItem(Index: Integer; Value: Int32);
  protected
    class Function GetNodeDataType: TUNSNodeDataType; override;
    class Function GetValueItemSize: TMemSize; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
  public

    procedure ActualFromDefault; overload; override;
    procedure DefaultFromActual; overload; override;
    procedure ExchangeActualAndDefault; overload; override;
    Function ActualEqualsDefault: Boolean; overload; override;

    Function GetValueAddress(AccessDefVal: Boolean = False): Pointer; override;
    Function GetValueAsString(AccessDefVal: Boolean = False): String; override;
    procedure SetValueFromString(const Str: String; AccessDefVal: Boolean = False); override;
    procedure GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    Function GetValueAsStream(AccessDefVal: Boolean = False): TMemoryStream; override;
    procedure GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    procedure SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    Function GetValueAsBuffer(AccessDefVal: Boolean = False): TMemoryBuffer; override;
  (*
    Function ActualFromDefault(Index: Integer): Boolean; overload; override;
    Function DefaultFromActual(Index: Integer): Boolean; overload; override;
    Function ExchangeActualAndDefault(Index: Integer): Boolean; overload; override;
    Function ActualEqualsDefault(Index: Integer): Boolean; overload; override;
    Function GetValueItemAddress(Index: Integer; AccessDefVal: Boolean = False): Pointer; override;
    Function GetValueItemAsString(Index: Integer; AccessDefVal: Boolean = False): String; override;
    procedure SetValueItemFromString(Index: Integer; const Str: String; AccessDefVal: Boolean = False); override;
    procedure GetValueItemToStream(Index: Integer; Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure SetValueItemFromStream(Index: Integer; Stream: TStream; AccessDefVal: Boolean = False); override;
    Function GetValueItemAsStream(Index: Integer; AccessDefVal: Boolean = False): TMemoryStream; override;
    Function GetValueItemToBuffer(Index: Integer; Buffer: Pointer; Size: TMemSize; AccessDefVal: Boolean = False): TMemSize; override;
    procedure SetValueItemFromBuffer(Index: Integer; Buffer: Pointer; Size: TMemSize; AccessDefVal: Boolean = False); override;
    Function GetValueItemAsBuffer(Index: Integer; out Buffer: Pointer; AccessDefVal: Boolean = False): TMemSize; override;

    Function ValueLowIndex(AccessDefVal: Boolean = False): Integer; override;
    Function ValueHighIndex(AccessDefVal: Boolean = False): Integer; override;

    Function ValueIndexOf(Item: Int32; AccessDefVal: Boolean = False): Integer; reintroduce;
    Function ValueAdd(Item: Int32; AccessDefVal: Boolean = False): Integer; reintroduce;
    Function ValueAppend(Items: array of Int32; AccessDefVal: Boolean = False): Integer; reintroduce;
    Function ValueInsert(Index: Integer; Item: Int32; AccessDefVal: Boolean = False): Integer; reintroduce;
    procedure ValueExchange(Index1,Index2: Integer; AccessDefVal: Boolean = False); override;
    procedure ValueMove(SrcIndex,DstIndex: Integer; AccessDefVal: Boolean = False); override;
    Function ValueRemove(Item: Int32; AccessDefVal: Boolean = False): Integer; reintroduce;
    procedure ValueDelete(Index: Integer; AccessDefVal: Boolean = False); override;
    procedure ValueClear(AccessDefVal: Boolean = False); override;
  *)
    property ValueItems[Index: Integer]: Int32 read GetValueItem write SetValueItem; default;
    property DefaultValueItems[Index: Integer]: Int32 read GetDefaultValueItem write SetDefaultValueItem;
    property ValueCount: Integer read fValue.Count;
    property DefaultValueCount: Integer read fDefaultValue.Count;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming;

Function TUNSNodeAoInt32.GetValueItem(Index: Integer): Int32;
begin
If ValueCheckIndex(Index,False) then
  Result := fValue.Arr[Index]
else
  raise Exception.CreateFmt('TUNSNodeAoInt32.GetValueItem: Index(%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetValueItem(Index: Integer; Value: Int32);
begin
If ValueCheckIndex(Index,False) then
  begin
    If Value <> fValue.Arr[Index] then
      begin
        fValue.Arr[Index] := Value;
        DoChange;
      end;
  end
else raise Exception.CreateFmt('TUNSNodeAoInt32.SetValueItem: Index(%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetDefaultValueItem(Index: Integer): Int32;
begin
If ValueCheckIndex(Index,True) then
  Result := fDefaultValue.Arr[Index]
else
  raise Exception.CreateFmt('TUNSNodeAoInt32.GetDefaultValueItem: Index(%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetDefaultValueItem(Index: Integer; Value: Int32);
begin
If ValueCheckIndex(Index,True) then
  begin
    If Value <> fDefaultValue.Arr[Index] then
      begin
        fDefaultValue.Arr[Index] := Value;
        DoChange;
      end;
  end
else raise Exception.CreateFmt('TUNSNodeAoInt32.SetDefaultValueItem: Index(%d) out of bounds.',[Index]);
end;

//==============================================================================

class Function TUNSNodeAoInt32.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtAoInt32;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeAoInt32.GetValueItemSize: TMemSize;
begin
Result := SizeOf(Int32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
If AccessDefVal <> 0 then
  Result := ValueItemSize * TMemSize(DefaultValueCount)
else
  Result := ValueItemSize * TMemSize(ValueCount);
end;

//==============================================================================

procedure TUNSNodeAoInt32.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    SetLength(fValue.Arr,Length(fValue.Arr)); // ensures the array is unique
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    SetLength(fDefaultValue.Arr,Length(fDefaultValue.Arr)); 
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ExchangeActualAndDefault;
var
  Temp: TUNSAoInt32;
begin
If not ActualEqualsDefault then
  begin
    Temp := fValue;
    fValue := fDefaultValue;
    fDefaultValue := Temp;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.ActualEqualsDefault: Boolean;
var
  i:  Integer;
begin
If fValue.Count = fDefaultValue.Count then
  begin
    Result := True;
    For i := ValueLowIndex to ValueHighIndex do
      If fValue.Arr[i] <> fDefaultValue.Arr[i] then
        begin
          Result := False;
          Break{For i};
        end;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  begin
    If fDefaultValue.Count > 0 then
      Result := Addr(fDefaultValue.Arr[0])
    else
      Result := nil;
  end
else
  begin
    If fValue.Count > 0 then
      Result := Addr(fValue.Arr[0])
    else
      Result := nil;
  end
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetValueAsString(AccessDefVal: Boolean = False): String; 
begin
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  begin
    If DefaultValueCount > 0 then
      Stream_WriteBuffer(Stream,fDefaultValue.Arr[0],DefaultValueSize);
  end
else
  begin
    If ValueCount > 0 then
      Stream_WriteBuffer(Stream,fValue.Arr[0],ValueSize);
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  begin
    fDefaultValue.Count := Integer((Stream.Size - Stream.Position) div ValueItemSize);
    If fDefaultValue.Count > 0  then
      begin
        If Length(fDefaultValue.Arr) < fDefaultValue.Count then
          SetLength(fDefaultValue.Arr,fDefaultValue.Count);
        Stream_ReadBuffer(Stream,fDefaultValue.Arr[0],DefaultValueSize);
      end;
    DoChange;
  end
else
  begin
    fValue.Count := Integer((Stream.Size - Stream.Position) div ValueItemSize);
    If fValue.Count > 0 then
      begin
        If Length(fValue.Arr) < fValue.Count then
          SetLength(fValue.Arr,fValue.Count);
        Stream_ReadBuffer(Stream,fValue.Arr[0],ValueSize);
      end;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetValueAsStream(AccessDefVal: Boolean = False): TMemoryStream;
begin
Result := TMemoryStream.Create;
GetValueToStream(Result,AccessDefVal);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
(*
Result := 0;
If AccessDefVal then
  begin
    If Size >= DefaultValueSize then
      begin
        If fDefaultValue.Count > 0 then
          Result := Ptr_WriteBuffer(Buffer,fDefaultValue.Arr[0],DefaultValueSize);
      end
    else raise Exception.CreateFmt('TUNSNodeAoInt32.GetValueToBuffer: Provided buffer is too small (%d).',[Size]);
  end
else
  begin
    If Size >= ValueSize then
      begin
        If fValue.Count > 0 then
          Result := Ptr_WriteBuffer(Buffer,fValue.Arr[0],ValueSize);
      end
    else raise Exception.CreateFmt('TUNSNodeAoInt32.GetValueToBuffer: Provided buffer is too small (%d).',[Size]);
  end;
*)
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetValueAsBuffer(AccessDefVal: Boolean = False): TMemoryBuffer;
begin
(*
If AccessDefVal then
  Result := DefaultValueSize
else
  Result := ValueSize;
GetMem(Buffer,Result);
GetValueToBuffer(Buffer,Result,AccessDefVal);
*)
end;

//------------------------------------------------------------------------------


end.
