unit UniSettings_NodeAoInt32;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeAoInt32}


interface

uses
  Classes,
  AuxTypes, MemoryBuffer, CountedDynArrayInt32,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray;

type
  TUNSNodeAoInt32 = class(TUNSNodePrimitiveArray)
  private
    fValue:         TInt32CountedDynArray;
    fSavedValue:    TInt32CountedDynArray;
    fDefaultValue:  TInt32CountedDynArray;
    procedure SetValue(NewValue: TInt32CountedDynArray);
    procedure SetSavedValue(NewValue: TInt32CountedDynArray);
    procedure SetDefaultValue(NewValue: TInt32CountedDynArray);
    Function GetItem(Index: Integer): Int32;
    Function GetSavedItem(Index: Integer): Int32;
    Function GetDefaultItem(Index: Integer): Int32;
    procedure SetItem(Index: Integer; NewValue: Int32);
    procedure SetSavedItem(Index: Integer; NewValue: Int32);
    procedure SetDefaultItem(Index: Integer; NewValue: Int32);
  protected
    class Function GetValueType: TUNSValueType; override;
    class Function SameValues(const A,B: TInt32CountedDynArray): Boolean; reintroduce;
    class Function SameItemValues(const A,B: Int32): Boolean; reintroduce;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function GetCount: Integer; override;
    Function GetSavedCount: Integer; override;
    Function GetDefaultCount: Integer; override;
    Function GetItemSize(Index: Integer): TMemSize; override;
    Function GetSavedItemSize(Index: Integer): TMemSize; override;
    Function GetDefaultItemSize(Index: Integer): TMemSize; override;
    Function ConvToStr(const Value: TInt32CountedDynArray): String; reintroduce;
    procedure ConvFromStr(const Str: String; var Value: TInt32CountedDynArray); reintroduce; 
    Function ConvItemToStr(const Value: Int32): String; reintroduce;
    Function ConvItemFromStr(const Str: String): Int32; reintroduce;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    constructor CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase); 
    Function NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean; override;
    procedure ValueKindMove(Src,Dest: TUNSValueKind); override;
    procedure ValueKindExchange(ValA,ValB: TUNSValueKind); override;
    Function ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean; override;
    Function Address(ValueKind: TUNSValueKind = vkActual): Pointer; override;
    Function AsString(ValueKind: TUNSValueKind = vkActual): String; override;
    procedure FromString(const Str: String; ValueKind: TUNSValueKind = vkActual); override;
    procedure ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual); override;
    procedure FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual); override;
    procedure ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); override;
    procedure FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); override;
    procedure ValueKindMove(Index: Integer; Src,Dest: TUNSValueKind); override;
    procedure ValueKindExchange(Index: Integer; ValA,ValB: TUNSValueKind); override;
    Function ValueKindCompare(Index: Integer; ValA,ValB: TUNSValueKind): Boolean; override;
    Function Address(Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer; override;
    Function AsString(Index: Integer; ValueKind: TUNSValueKind = vkActual): String; override;
    procedure FromString(Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual); override;
    procedure ToStream(Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual); override;
    procedure FromStream(Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual); override;
    procedure ToBuffer(Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); override;
    procedure FromBuffer(Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); override;
    Function LowIndex(ValueKind: TUNSValueKind = vkActual): Integer; override;
    Function HighIndex(ValueKind: TUNSValueKind = vkActual): Integer; override;
    Function First(ValueKind: TUNSValueKind = vkActual): Int32; reintroduce;
    Function Last(ValueKind: TUNSValueKind = vkActual): Int32; reintroduce;
    Function IndexOf(const Item: Int32; ValueKind: TUNSValueKind = vkActual): Integer; reintroduce;
    Function Add(const Item: Int32; ValueKind: TUNSValueKind = vkActual): Integer; reintroduce;
    Function Append(const Items: array of Int32; ValueKind: TUNSValueKind = vkActual): Integer; reintroduce;
    procedure Insert(Index: Integer; const Item: Int32; ValueKind: TUNSValueKind = vkActual); reintroduce;
    procedure Exchange(Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual); override;
    procedure Move(SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual); override;
    Function Remove(const Item: Int32; ValueKind: TUNSValueKind = vkActual): Integer; reintroduce;
    procedure Delete(Index: Integer; ValueKind: TUNSValueKind = vkActual); override;
    procedure Clear(ValueKind: TUNSValueKind = vkActual); override;     
    property Value: TInt32CountedDynArray read fValue write SetValue;
    property SavedValue: TInt32CountedDynArray read fSavedValue write SetSavedValue;
    property DefaultValue: TInt32CountedDynArray read fDefaultValue write SetDefaultValue;
    property Items[Index: Integer]: Int32 read GetItem write SetItem;
    property SavedItems[Index: Integer]: Int32 read GetSavedItem write SetSavedItem;
    property DefaultItems[Index: Integer]: Int32 read GetDefaultItem write SetDefaultItem;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeAoInt32.SetValue(NewValue: TInt32CountedDynArray);
begin
If not SameValues(NewValue,fValue) then
  begin
    fValue := CDA_Copy(NewValue);
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetSavedValue(NewValue: TInt32CountedDynArray);
begin
If not SameValues(NewValue,fSavedValue) then
  begin
    fSavedValue := CDA_Copy(NewValue);
    DoChange;
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetDefaultValue(NewValue: TInt32CountedDynArray);
begin
If not SameValues(NewValue,fDefaultValue) then
  begin
    fDefaultValue := CDA_Copy(NewValue);
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetItem(Index: Integer): Int32;
begin
If CDA_CheckIndex(fValue,Index) then
  Result := CDA_GetItem(fValue,Index)
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetItem');
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetSavedItem(Index: Integer): Int32;
begin
If CDA_CheckIndex(fSavedValue,Index) then
  Result := CDA_GetItem(fSavedValue,Index)
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetSavedItem');
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetDefaultItem(Index: Integer): Int32;
begin
If CDA_CheckIndex(fDefaultValue,Index) then
  Result := CDA_GetItem(fDefaultValue,Index)
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetDefaultItem');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetItem(Index: Integer; NewValue: Int32);
begin
If CDA_CheckIndex(fValue,Index) then
  begin
    If not SameItemValues(CDA_GetItem(fValue,Index),NewValue) then
      begin
        CDA_SetItem(fValue,Index,NewValue);
        DoChange;
      end;
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'SetItem');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetSavedItem(Index: Integer; NewValue: Int32);
begin
If CDA_CheckIndex(fSavedValue,Index) then
  begin
    If not SameItemValues(CDA_GetItem(fSavedValue,Index),NewValue) then
      begin
        CDA_SetItem(fSavedValue,Index,NewValue);
        DoChange;
      end;
  end
else EUNSIndexOutOfBoundsException.Create(Index,Self,'SetSavedItem');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.SetDefaultItem(Index: Integer; NewValue: Int32);
begin
If CDA_CheckIndex(fDefaultValue,Index) then
  begin
    If not SameItemValues(CDA_GetItem(fDefaultValue,Index),NewValue) then
      begin
        CDA_SetItem(fDefaultValue,Index,NewValue);
        DoChange;
      end;
  end
else EUNSIndexOutOfBoundsException.Create(Index,Self,'SetDefaultItem');
end;

//==============================================================================

class Function TUNSNodeAoInt32.GetValueType: TUNSValueType;
begin
Result := vtAoInt32;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeAoInt32.SameValues(const A,B: TInt32CountedDynArray): Boolean;
begin
Result := CDA_Same(A,B);
end;

//------------------------------------------------------------------------------

class Function TUNSNodeAoInt32.SameItemValues(const A,B: Int32): Boolean;
begin
Result := A = B;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetValueSize: TMemSize;
begin
Result := SizeOf(Int32) + (TMemSize(CDA_Count(fValue)) * GetItemSize(-1));
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetSavedValueSize: TMemSize;
begin
Result := SizeOf(Int32) + (TMemSize(CDA_Count(fSavedValue)) * GetSavedItemSize(-1));
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(Int32) + (TMemSize(CDA_Count(fDefaultValue)) * GetDefaultItemSize(-1));
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetCount: Integer;
begin
Result := CDA_Count(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetSavedCount: Integer;
begin
Result := CDA_Count(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetDefaultCount: Integer;
begin
Result := CDA_Count(fDefaultValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetItemSize(Index: Integer): TMemSize;
begin
Result := SizeOf(Int32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetSavedItemSize(Index: Integer): TMemSize;
begin
Result := SizeOf(Int32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.GetDefaultItemSize(Index: Integer): TMemSize;
begin
Result := SizeOf(Int32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.ConvToStr(const Value: TInt32CountedDynArray): String;
var
  i:  Integer;
begin
{
  This could use some optimization, right?... nope, this method is NOT supposed
  to be used to create monstrous lists, end of story!
}
If CDA_Count(Value) > 0 then
  begin
    For i := CDA_Low(Value) to CDA_High(Value) do
      If i < CDA_High(Value) then
        Result := Result + ConvItemToStr(CDA_GetItem(Value,i)) + ' '
      else
        Result := Result + ConvItemToStr(CDA_GetItem(Value,i));
  end
else Result := '';
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ConvFromStr(const Str: String; var Value: TInt32CountedDynArray);
var
  Position:   Integer;
  ItemStart:  Integer;
begin
CDA_Clear(Value);
ItemStart := 1;
For Position := 1 to Length(Str) do
  begin
    If Str[Position] = ' ' then
      begin
        If ItemStart <> Position then
          CDA_Add(Value,ConvItemFromStr(Copy(Str,ItemStart,Position - ItemStart)));
        ItemStart := Succ(Position);  
      end;
  end;
If ItemStart <= Length(Str) then
  CDA_Add(Value,ConvItemFromStr(Copy(Str,ItemStart,Length(Str))));
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.ConvItemToStr(const Value: Int32): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,8)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.ConvItemFromStr(const Str: String): Int32;
begin
Result := Int32(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeAoInt32.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
CDA_Init(fValue);
CDA_Init(fSavedValue);
CDA_Init(fDefaultValue);
end;

//------------------------------------------------------------------------------

constructor TUNSNodeAoInt32.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := CDA_Copy(TUNSNodeAoInt32(Source).Value);
fSavedValue := CDA_Copy(TUNSNodeAoInt32(Source).SavedValue);
fDefaultValue := CDA_Copy(TUNSNodeAoInt32(Source).DefaultValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
If inherited NodeEquals(Node) then
  begin
    Result := True;
    If vkActual in CompareValueKinds then
      Result := Result and SameValues(fValue,TUNSNodeAoInt32(Node).Value);
    If vkSaved in CompareValueKinds then
      Result := Result and SameValues(fSavedValue,TUNSNodeAoInt32(Node).SavedValue);
    If vkDefault in CompareValueKinds then
      Result := Result and SameValues(fDefaultValue,TUNSNodeAoInt32(Node).DefaultValue);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ValueKindMove(Src,Dest: TUNSValueKind);
var
  SrcPtr,DestPtr: PInt32CountedDynArray;
begin
If Src <> Dest then
  begin
    SrcPtr := Address(Src);
    DestPtr := Address(Dest);
    If not SameValues(SrcPtr^,DestPtr^) then
      begin
        DestPtr^ := CDA_Copy(SrcPtr^);
        DoChange;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ValueKindExchange(ValA,ValB: TUNSValueKind);
var
  ValAPtr,ValBPtr:  PInt32CountedDynArray;
  Temp:             TInt32CountedDynArray;
begin
If ValA <> ValB then
  begin
    ValAPtr := Address(ValA);
    ValBPtr := Address(ValB);
    If not SameValues(ValAPtr^,ValBPtr^) then
      begin
        // no need for array managing, just swap the records
        Temp := ValAPtr^;
        ValAPtr^ := ValBPtr^;
        ValBPtr^ := Temp;
        DoChange;
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := SameValues(TInt32CountedDynArray(Address(ValA)^),TInt32CountedDynArray(Address(ValB)^))
else
  Result := True;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.Address(ValueKind: TUNSValueKind = vkActual): Pointer;
begin
case ValueKind of
  vkActual:   Result := Addr(fValue);
  vkSaved:    Result := Addr(fSavedValue);
  vkDefault:  Result := Addr(fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Address');
end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.AsString(ValueKind: TUNSValueKind = vkActual): String;
begin
case ValueKind of
  vkActual:   Result := ConvToStr(fValue);
  vkSaved:    Result := ConvToStr(fSavedValue);
  vkDefault:  Result := ConvToStr(fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'AsString');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.FromString(const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   ConvFromStr(Str,fValue);
  vkSaved:    ConvFromStr(Str,fSavedValue);
  vkDefault:  ConvFromStr(Str,fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromString');
end;
DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
var
  i:  Integer;
begin
// arrays are stored with explicit length (Int32 value)
Stream_WriteInt32(Stream,Int32(ObtainCount(ValueKind)));
// cycles are inside of cases, it is faster that way
case ValueKind of
  vkActual:   For i := CDA_Low(fValue) to CDA_High(fValue) do
                Stream_WriteInt32(Stream,CDA_GetItem(fValue,i));
  vkSaved:    For i := CDA_Low(fValue) to CDA_High(fSavedValue) do
                Stream_WriteInt32(Stream,CDA_GetItem(fSavedValue,i));
  vkDefault:  For i := CDA_Low(fValue) to CDA_High(fDefaultValue) do
                Stream_WriteInt32(Stream,CDA_GetItem(fDefaultValue,i));
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
var
  i:  Integer;
begin
case ValueKind of
  vkActual:   begin
                CDA_Clear(fValue);
                For i := 0 to Pred(Stream_ReadInt32(Stream)) do
                  CDA_Add(fValue,Stream_ReadInt32(Stream));
              end;
  vkSaved:    begin
                CDA_Clear(fSavedValue);
                For i := 0 to Pred(Stream_ReadInt32(Stream)) do
                  CDA_Add(fSavedValue,Stream_ReadInt32(Stream));
              end;
  vkDefault:  begin
                CDA_Clear(fDefaultValue);
                For i := 0 to Pred(Stream_ReadInt32(Stream)) do
                  CDA_Add(fDefaultValue,Stream_ReadInt32(Stream));
              end;
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  i:  Integer;
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  begin
    Ptr_WriteInt32(Buffer.Memory,Int32(ObtainCount(ValueKind)),True);
    case ValueKind of
      vkActual:   For i := CDA_Low(fValue) to CDA_High(fValue) do
                    Ptr_WriteInt32(Buffer.Memory,CDA_GetItem(fValue,i),True);
      vkSaved:    For i := CDA_Low(fSavedValue) to CDA_High(fSavedValue) do
                    Ptr_WriteInt32(Buffer.Memory,CDA_GetItem(fSavedValue,i),True);
      vkDefault:  For i := CDA_Low(fDefaultValue) to CDA_High(fDefaultValue) do
                    Ptr_WriteInt32(Buffer.Memory,CDA_GetItem(fDefaultValue,i),True);
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
    end;
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  i:  Integer;
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  begin
    case ValueKind of
      vkActual:   begin
                    CDA_Clear(fValue);
                    For i := 0 to Pred(Ptr_ReadInt32(Buffer.Memory,True)) do
                      CDA_Add(fValue,Ptr_ReadInt32(Buffer.Memory,True));
                  end;
      vkSaved:    begin
                    CDA_Clear(fSavedValue);
                    For i := 0 to Pred(Ptr_ReadInt32(Buffer.Memory,True)) do
                      CDA_Add(fSavedValue,Ptr_ReadInt32(Buffer.Memory,True));
                  end;
      vkDefault:  begin
                    CDA_Clear(fDefaultValue);
                    For i := 0 to Pred(Ptr_ReadInt32(Buffer.Memory,True)) do
                      CDA_Add(fDefaultValue,Ptr_ReadInt32(Buffer.Memory,True));
                  end;
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromBuffer');
    end;
    DoChange;
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'FromBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ValueKindMove(Index: Integer; Src,Dest: TUNSValueKind);
var
  SrcPtr,DestPtr: PInt32;
begin
If Src <> Dest then
  begin
    SrcPtr := Address(Index,Src);
    DestPtr := Address(Index,Dest);
    If not SameItemValues(SrcPtr^,DestPtr^) then
      begin
        DestPtr^ := SrcPtr^;
        DoChange;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ValueKindExchange(Index: Integer; ValA,ValB: TUNSValueKind);
var
  ValAPtr,ValBPtr:  PInt32;
  Temp:             Int32;
begin
If ValA <> ValB then
  begin
    ValAPtr := Address(Index,ValA);
    ValBPtr := Address(Index,ValB);
    If not SameItemValues(ValAPtr^,ValBPtr^) then
      begin
        Temp := ValAPtr^;
        ValAPtr^ := ValBPtr^;
        ValBPtr^ := Temp;
        DoChange;
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.ValueKindCompare(Index: Integer; ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := SameItemValues(Int32(Address(Index,ValA)^),Int32(Address(Index,ValB)^))
else
  Result := True;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.Address(Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer;
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   Result := Addr(fValue.Arr[Index]);
    vkSaved:    Result := Addr(fSavedValue.Arr[Index]);
    vkDefault:  Result := Addr(fDefaultValue.Arr[Index]);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Address');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'Address');
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.AsString(Index: Integer; ValueKind: TUNSValueKind = vkActual): String;
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   Result := ConvItemToStr(CDA_GetItem(fValue,Index));
    vkSaved:    Result := ConvItemToStr(CDA_GetItem(fSavedValue,Index));
    vkDefault:  Result := ConvItemToStr(CDA_GetItem(fDefaultValue,Index));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'AsString');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'AsString');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.FromString(Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   SetItem(Index,ConvItemFromStr(Str));
    vkSaved:    SetSavedItem(Index,ConvItemFromStr(Str));
    vkDefault:  SetDefaultItem(Index,ConvItemFromStr(Str));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromString');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'FromString');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ToStream(Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   Stream_WriteInt32(Stream,CDA_GetItem(fValue,Index));
    vkSaved:    Stream_WriteInt32(Stream,CDA_GetItem(fSavedValue,Index));
    vkDefault:  Stream_WriteInt32(Stream,CDA_GetItem(fDefaultValue,Index));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'ToStream');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.FromStream(Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   SetItem(Index,Stream_ReadInt32(Stream));
    vkSaved:    SetSavedItem(Index,Stream_ReadInt32(Stream));
    vkDefault:  SetDefaultItem(Index,Stream_ReadInt32(Stream));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'FromStream');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.ToBuffer(Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   Ptr_WriteInt32(Buffer.Memory,CDA_GetItem(fValue,Index));
    vkSaved:    Ptr_WriteInt32(Buffer.Memory,CDA_GetItem(fSavedValue,Index));
    vkDefault:  Ptr_WriteInt32(Buffer.Memory,CDA_GetItem(fDefaultValue,Index));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.FromBuffer(Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   SetItem(Index,Ptr_ReadInt32(Buffer.Memory));
    vkSaved:    SetSavedItem(Index,Ptr_ReadInt32(Buffer.Memory));
    vkDefault:  SetDefaultItem(Index,Ptr_ReadInt32(Buffer.Memory));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromBuffer');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'FromBuffer');
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.LowIndex(ValueKind: TUNSValueKind = vkActual): Integer;
begin
case ValueKind of
  vkActual:   Result := CDA_Low(fValue);
  vkSaved:    Result := CDA_Low(fSavedValue);
  vkDefault:  Result := CDA_Low(fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'LowIndex');
end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.HighIndex(ValueKind: TUNSValueKind = vkActual): Integer;
begin
case ValueKind of
  vkActual:   Result := CDA_High(fValue);
  vkSaved:    Result := CDA_High(fSavedValue);
  vkDefault:  Result := CDA_High(fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'HighIndex');
end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.First(ValueKind: TUNSValueKind = vkActual): Int32;
begin
If ObtainCount(ValueKind) > 0 then
  case ValueKind of
    vkActual:   Result := CDA_GetItem(fValue,CDA_Low(fValue));
    vkSaved:    Result := CDA_GetItem(fSavedValue,CDA_Low(fSavedValue));
    vkDefault:  Result := CDA_GetItem(fDefaultValue,CDA_Low(fDefaultValue));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'First');
  end
else raise EUNSException.Create('Empty array.',Self,'First');
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.Last(ValueKind: TUNSValueKind = vkActual): Int32;
begin
If ObtainCount(ValueKind) > 0 then
  case ValueKind of
    vkActual:   Result := CDA_GetItem(fValue,CDA_High(fValue));
    vkSaved:    Result := CDA_GetItem(fSavedValue,CDA_High(fSavedValue));
    vkDefault:  Result := CDA_GetItem(fDefaultValue,CDA_High(fDefaultValue));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'First');
  end
else raise EUNSException.Create('Empty array.',Self,'First');
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.IndexOf(const Item: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
case ValueKind of
  vkActual:   Result := CDA_IndexOf(fValue,Item);
  vkSaved:    Result := CDA_IndexOf(fSavedValue,Item);
  vkDefault:  Result := CDA_IndexOf(fDefaultValue,Item);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'IndexOf');
end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.Add(const Item: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
case ValueKind of
  vkActual:   Result := CDA_Add(fValue,Item);
  vkSaved:    Result := CDA_Add(fSavedValue,Item);
  vkDefault:  Result := CDA_Add(fDefaultValue,Item);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Add');
end;
If Result >= 0 then
  DoChange;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.Append(const Items: array of Int32; ValueKind: TUNSValueKind = vkActual): Integer;
var
  i:  Integer;
begin
If Length(Items) > 0 then
  begin
    case ValueKind of
      vkActual:   For i := Low(Items) to High(Items) do
                    CDA_Add(fValue,Items[i]);
      vkSaved:    For i := Low(Items) to High(Items) do
                    CDA_Add(fSavedValue,Items[i]);
      vkDefault:  For i := Low(Items) to High(Items) do
                    CDA_Add(fDefaultValue,Items[i]);
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Append');
    end;
    Result := Length(Items);
    DoChange;
  end
else Result := 0;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.Insert(Index: Integer; const Item: Int32; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   CDA_Insert(fValue,Index,Item);
  vkSaved:    CDA_Insert(fSavedValue,Index,Item);
  vkDefault:  CDA_Insert(fDefaultValue,Index,Item);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Insert');
end;
DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.Exchange(Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual);
begin
If Index1 <> Index2 then
  begin
    If not CheckIndex(Index1,ValueKind) then
      raise EUNSIndexOutOfBoundsException.Create(Index1,Self,'Exchange');
    If not CheckIndex(Index2,ValueKind) then
      raise EUNSIndexOutOfBoundsException.Create(Index2,Self,'Exchange');
    case ValueKind of
      vkActual:   CDA_Exchange(fValue,Index1,Index2);
      vkSaved:    CDA_Exchange(fSavedValue,Index1,Index2);
      vkDefault:  CDA_Exchange(fDefaultValue,Index1,Index2);
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Exchange');
    end;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.Move(SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual);
begin
If SrcIndex <> DstIndex then
  begin
    If not CheckIndex(SrcIndex,ValueKind) then
      raise EUNSIndexOutOfBoundsException.Create(SrcIndex,Self,'Exchange');
    If not CheckIndex(DstIndex,ValueKind) then
      raise EUNSIndexOutOfBoundsException.Create(DstIndex,Self,'Exchange');
    case ValueKind of
      vkActual:   CDA_Move(fValue,SrcIndex,DstIndex);
      vkSaved:    CDA_Move(fSavedValue,SrcIndex,DstIndex);
      vkDefault:  CDA_Move(fDefaultValue,SrcIndex,DstIndex);
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Move');
    end;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeAoInt32.Remove(const Item: Int32; ValueKind: TUNSValueKind = vkActual): Integer;
begin
case ValueKind of
  vkActual:   CDA_Remove(fValue,Item);
  vkSaved:    CDA_Remove(fSavedValue,Item);
  vkDefault:  CDA_Remove(fDefaultValue,Item);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Remove');
end;
If Result >= 0 then
  DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.Delete(Index: Integer; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   CDA_Delete(fValue,Index);
    vkSaved:    CDA_Delete(fSavedValue,Index);
    vkDefault:  CDA_Delete(fDefaultValue,Index);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Delete');
  end
else EUNSIndexOutOfBoundsException.Create(Index,Self,'Delete');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeAoInt32.Clear(ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   CDA_Clear(fValue);
  vkSaved:    CDA_Clear(fSavedValue);
  vkDefault:  CDA_Clear(fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Clear');
end;
DoChange;
end;

end.
