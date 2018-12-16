{$IFDEF UNS_NodeInclude_Declaration}
  private
    fValue:         TUNSNodeValueType;
    fSavedValue:    TUNSNodeValueType;
    fDefaultValue:  TUNSNodeValueType;
    procedure SetValue(NewValue: TUNSNodeValueType);
    procedure SetSavedValue(NewValue: TUNSNodeValueType);
    procedure SetDefaultValue(NewValue: TUNSNodeValueType);
    Function GetItem(Index: Integer): TUNSNodeValueItemType;
    Function GetSavedItem(Index: Integer): TUNSNodeValueItemType;
    Function GetDefaultItem(Index: Integer): TUNSNodeValueItemType;
    procedure SetItem(Index: Integer; NewValue: TUNSNodeValueItemType);
    procedure SetSavedItem(Index: Integer; NewValue: TUNSNodeValueItemType);
    procedure SetDefaultItem(Index: Integer; NewValue: TUNSNodeValueItemType);
  protected
    class Function GetValueType: TUNSValueType; override;
    class Function SameValues(const A,B: TUNSNodeValueType): Boolean; reintroduce;
    class Function SameItemValues(const A,B: TUNSNodeValueItemType): Boolean; reintroduce;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function GetCount: Integer; override;
    Function GetSavedCount: Integer; override;
    Function GetDefaultCount: Integer; override;
    Function GetItemSize(Index: Integer): TMemSize; override;
    Function GetSavedItemSize(Index: Integer): TMemSize; override;
    Function GetDefaultItemSize(Index: Integer): TMemSize; override;
    Function ConvToStr(const Value: TUNSNodeValueType): String; reintroduce;
    procedure ConvFromStr(const Str: String; var Value: TUNSNodeValueType); reintroduce; 
    Function ConvItemToStr(const Value: TUNSNodeValueItemType): String; reintroduce;
  {$IFDEF UNS_NodeAoBuffer}
    procedure ConvItemFromStr(const Str: String; out Item: TUNSNodeValueItemType); reintroduce;   
  {$ELSE}
    Function ConvItemFromStr(const Str: String): TUNSNodeValueItemType; reintroduce;
  {$ENDIF}  
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
    Function First(ValueKind: TUNSValueKind = vkActual): TUNSNodeValueItemType; reintroduce;
    Function Last(ValueKind: TUNSValueKind = vkActual): TUNSNodeValueItemType; reintroduce;
    Function IndexOf(const Item: TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual): Integer; reintroduce;
    Function Add(const Item: TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual): Integer; reintroduce;
    Function Append(const Items: array of TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual): Integer; reintroduce;
    procedure Insert(Index: Integer; const Item: TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual); reintroduce;
    procedure Exchange(Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual); override;
    procedure Move(SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual); override;
    Function Remove(const Item: TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual): Integer; reintroduce;
    procedure Delete(Index: Integer; ValueKind: TUNSValueKind = vkActual); override;
    procedure Clear(ValueKind: TUNSValueKind = vkActual); override;     
    property Value: TUNSNodeValueType read fValue write SetValue;
    property SavedValue: TUNSNodeValueType read fSavedValue write SetSavedValue;
    property DefaultValue: TUNSNodeValueType read fDefaultValue write SetDefaultValue;
    property Items[Index: Integer]: TUNSNodeValueItemType read GetItem write SetItem;
    property SavedItems[Index: Integer]: TUNSNodeValueItemType read GetSavedItem write SetSavedItem;
    property DefaultItems[Index: Integer]: TUNSNodeValueItemType read GetDefaultItem write SetDefaultItem;
{$ENDIF UNS_NodeInclude_Declaration}

//==============================================================================

{$IFDEF UNS_NodeInclude_Implementation}

procedure TUNSNodeClassType.SetValue(NewValue: TUNSNodeValueType);
begin
If not SameValues(NewValue,fValue) then
  begin
  {$IFDEF UNS_NodeAoBuffer}
    CopyArrayInto(NewValue,fValue);
  {$ELSE}
    fValue := CDA_Copy(NewValue);
  {$ENDIF}
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetSavedValue(NewValue: TUNSNodeValueType);
begin
If not SameValues(NewValue,fSavedValue) then
  begin
  {$IFDEF UNS_NodeAoBuffer}
    CopyArrayInto(NewValue,fSavedValue);
  {$ELSE}
    fSavedValue := CDA_Copy(NewValue);
  {$ENDIF}
    DoChange;
  end;
end;
 
//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetDefaultValue(NewValue: TUNSNodeValueType);
begin
If not SameValues(NewValue,fDefaultValue) then
  begin
  {$IFDEF UNS_NodeAoBuffer}
    CopyArrayInto(NewValue,fDefaultValue);
  {$ELSE}
    fDefaultValue := CDA_Copy(NewValue);
  {$ENDIF}
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetItem(Index: Integer): TUNSNodeValueItemType;
begin
If CDA_CheckIndex(fValue,Index) then
  Result := CDA_GetItem(fValue,Index)
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetItem');
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetSavedItem(Index: Integer): TUNSNodeValueItemType;
begin
If CDA_CheckIndex(fSavedValue,Index) then
  Result := CDA_GetItem(fSavedValue,Index)
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetSavedItem');
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetDefaultItem(Index: Integer): TUNSNodeValueItemType;
begin
If CDA_CheckIndex(fDefaultValue,Index) then
  Result := CDA_GetItem(fDefaultValue,Index)
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetDefaultItem');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetItem(Index: Integer; NewValue: TUNSNodeValueItemType);
begin
If CDA_CheckIndex(fValue,Index) then
  begin
    If not SameItemValues(CDA_GetItem(fValue,Index),NewValue) then
      begin
      {$IFDEF UNS_NodeAoBuffer}
        CopyBufferInto(NewValue,fValue.Arr[Index]);
      {$ELSE}
        CDA_SetItem(fValue,Index,NewValue);
      {$ENDIF}
        DoChange;
      end;
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'SetItem');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetSavedItem(Index: Integer; NewValue: TUNSNodeValueItemType);
begin
If CDA_CheckIndex(fSavedValue,Index) then
  begin
    If not SameItemValues(CDA_GetItem(fSavedValue,Index),NewValue) then
      begin
      {$IFDEF UNS_NodeAoBuffer}
        CopyBufferInto(NewValue,fSavedValue.Arr[Index]);
      {$ELSE}
        CDA_SetItem(fSavedValue,Index,NewValue);
      {$ENDIF}
        DoChange;
      end;
  end
else EUNSIndexOutOfBoundsException.Create(Index,Self,'SetSavedItem');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetDefaultItem(Index: Integer; NewValue: TUNSNodeValueItemType);
begin
If CDA_CheckIndex(fDefaultValue,Index) then
  begin
    If not SameItemValues(CDA_GetItem(fDefaultValue,Index),NewValue) then
      begin
      {$IFDEF UNS_NodeAoBuffer}
        CopyBufferInto(NewValue,fDefaultValue.Arr[Index]);
      {$ELSE}
        CDA_SetItem(fDefaultValue,Index,NewValue);
      {$ENDIF}
        DoChange;
      end;
  end
else EUNSIndexOutOfBoundsException.Create(Index,Self,'SetDefaultItem');
end;

//==============================================================================    

class Function TUNSNodeClassType.SameValues(const A,B: TUNSNodeValueType): Boolean;
begin
Result := CDA_Same(A,B);
end;

//------------------------------------------------------------------------------

class Function TUNSNodeClassType.SameItemValues(const A,B: TUNSNodeValueItemType): Boolean;
{$IFDEF UNS_NodeAoBuffer}
var
  i:      TMemSize;
  ABuff:  PByte;
  BBuff:  PByte;
{$ENDIF}
begin
{$IF Defined(UNS_NodeAoDate)}
Result := Int(A) = Int(B);
{$ELSEIF Defined(UNS_NodeAoTime)}
Result := Frac(A) = Frac(B);
{$ELSEIF Defined(UNS_NodeAoText)}
Result := AnsiSameStr(A,B);
{$ELSEIF Defined(UNS_NodeAoBuffer)}
If A.Size = B.Size then
  begin
    ABuff := A.Memory;
    BBuff := B.Memory;
    Result := True;
    If A.Size > 0 then
      begin
        For i := 0 to Pred(A.Size) do
          If ABuff^ = BBuff^ then
            begin
              Inc(ABuff);
              Inc(BBuff);
            end
          else
            begin
              Result := False;
              Break{For i};
            end;
      end;
  end
else Result := False;
{$ELSE}
Result := A = B;
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetValueSize: TMemSize;
{$IF Defined(UNS_NodeAoText) or Defined(UNS_NodeAoBuffer)}
var
  i:  Integer;
begin
Result := SizeOf(Int32);
For i := CDA_Low(fValue) to CDA_High(fValue) do
  Result := Result + GetItemSize(i);
{$ELSE}
begin
Result := SizeOf(Int32) + (TMemSize(CDA_Count(fValue)) * GetItemSize(-1));
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetSavedValueSize: TMemSize;
{$IF Defined(UNS_NodeAoText) or Defined(UNS_NodeAoBuffer)}
var
  i:  Integer;
begin
Result := SizeOf(Int32);
For i := CDA_Low(fSavedValue) to CDA_High(fSavedValue) do
  Result := Result + GetSavedItemSize(i);
{$ELSE}
begin
Result := SizeOf(Int32) + (TMemSize(CDA_Count(fSavedValue)) * GetSavedItemSize(-1));
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetDefaultValueSize: TMemSize;
{$IF Defined(UNS_NodeAoText) or Defined(UNS_NodeAoBuffer)}
var
  i:  Integer;
begin
Result := SizeOf(Int32);
For i := CDA_Low(fDefaultValue) to CDA_High(fDefaultValue) do
  Result := Result + GetDefaultItemSize(i);
{$ELSE}
begin
Result := SizeOf(Int32) + (TMemSize(CDA_Count(fDefaultValue)) * GetDefaultItemSize(-1));
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetCount: Integer;
begin
Result := CDA_Count(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetSavedCount: Integer;
begin
Result := CDA_Count(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetDefaultCount: Integer;
begin
Result := CDA_Count(fDefaultValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetItemSize(Index: Integer): TMemSize;
begin
{$IF Defined(UNS_NodeAoText) or Defined(UNS_NodeAoBuffer)}
If CDA_CheckIndex(fValue,Index) then
  {$IFDEF UNS_NodeAoBuffer}
  Result := SizeOf(UInt64) + CDA_GetItem(fValue,Index).Size
  {$ELSE}
  Result := SizeOf(Int32) + Length(StrToUTF8(CDA_GetItem(fValue,Index))) * SizeOf(UTF8Char)
  {$ENDIF}
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetItemSize');
{$ELSE}
Result := SizeOf(TUNSNodeValueItemTypeBin);
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetSavedItemSize(Index: Integer): TMemSize;
begin
{$IF Defined(UNS_NodeAoText) or Defined(UNS_NodeAoBuffer)}
If CDA_CheckIndex(fSavedValue,Index) then
  {$IFDEF UNS_NodeAoBuffer}
  Result := SizeOf(UInt64) + CDA_GetItem(fSavedValue,Index).Size
  {$ELSE}
  Result := SizeOf(Int32) + Length(StrToUTF8(CDA_GetItem(fSavedValue,Index))) * SizeOf(UTF8Char)
  {$ENDIF}
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetSavedItemSize');
{$ELSE}
Result := SizeOf(TUNSNodeValueItemTypeBin);
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetDefaultItemSize(Index: Integer): TMemSize;
begin
{$IF Defined(UNS_NodeAoText) or Defined(UNS_NodeAoBuffer)}
If CDA_CheckIndex(fDefaultValue,Index) then
  {$IFDEF UNS_NodeAoBuffer}
  Result := SizeOf(UInt64) + CDA_GetItem(fDefaultValue,Index).Size
  {$ELSE}
  Result := SizeOf(Int32) + Length(StrToUTF8(CDA_GetItem(fDefaultValue,Index))) * SizeOf(UTF8Char)
  {$ENDIF}
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetDefaultItemSize');
{$ELSE}
Result := SizeOf(TUNSNodeValueItemTypeBin);
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.ConvToStr(const Value: TUNSNodeValueType): String;
var
  i:  Integer;
begin
{
  This could use some optimization, right?... nope, this method is NOT supposed
  to be used to create monstrous lists!
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

procedure TUNSNodeClassType.ConvFromStr(const Str: String; var Value: TUNSNodeValueType);
var
  Position:   Integer;
  ItemStart:  Integer;
{$IFDEF UNS_NodeAoBuffer}
  i:          Integer;
  Temp:       TUNSNodeValueItemType;
begin
For i := CDA_Low(Value) to CDA_High(Value) do
  FreeBuffer(Value.Arr[i]);
{$ELSE}
begin
{$ENDIF}
CDA_Clear(Value);
ItemStart := 1;
For Position := 1 to Length(Str) do
  begin
    If Str[Position] = ' ' then
      begin
        If ItemStart <> Position then
        {$IFDEF UNS_NodeAoBuffer}
          ConvItemFromStr(Copy(Str,ItemStart,Position - ItemStart),Temp);
          CDA_Add(Value,Temp);
        {$ELSE}
          CDA_Add(Value,ConvItemFromStr(Copy(Str,ItemStart,Position - ItemStart)));
        {$ENDIF}
        ItemStart := Succ(Position);  
      end;
  end;
If ItemStart <= Length(Str) then
{$IFDEF UNS_NodeAoBuffer}
  ConvItemFromStr(Copy(Str,ItemStart,Length(Str)),Temp);
  CDA_Add(Value,Temp);
{$ELSE}
  CDA_Add(Value,ConvItemFromStr(Copy(Str,ItemStart,Length(Str))));
{$ENDIF}
end;

//==============================================================================

constructor TUNSNodeClassType.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
CDA_Init(fValue);
CDA_Init(fSavedValue);
CDA_Init(fDefaultValue);
end;

//------------------------------------------------------------------------------

constructor TUNSNodeClassType.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
{$IFDEF UNS_NodeAoBuffer}
CopyArrayInto(TUNSNodeClassType(Source).Value,fValue);
CopyArrayInto(TUNSNodeClassType(Source).SavedValue,fSavedValue);
CopyArrayInto(TUNSNodeClassType(Source).DefaultValue,fDefaultValue);
{$ELSE}
fValue := CDA_Copy(TUNSNodeClassType(Source).Value);
fSavedValue := CDA_Copy(TUNSNodeClassType(Source).SavedValue);
fDefaultValue := CDA_Copy(TUNSNodeClassType(Source).DefaultValue);
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
If inherited NodeEquals(Node) then
  begin
    Result := True;
    If vkActual in CompareValueKinds then
      Result := Result and SameValues(fValue,TUNSNodeClassType(Node).Value);
    If vkSaved in CompareValueKinds then
      Result := Result and SameValues(fSavedValue,TUNSNodeClassType(Node).SavedValue);
    If vkDefault in CompareValueKinds then
      Result := Result and SameValues(fDefaultValue,TUNSNodeClassType(Node).DefaultValue);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ValueKindMove(Src,Dest: TUNSValueKind);
var
  SrcPtr,DestPtr: TUNSNodeValueTypePtr;
begin
If Src <> Dest then
  begin
    SrcPtr := Address(Src);
    DestPtr := Address(Dest);
    If not SameValues(SrcPtr^,DestPtr^) then
      begin
      {$IFDEF UNS_NodeAoBuffer}
        CopyArrayInto(SrcPtr^,DestPtr^);
      {$ELSE}
        DestPtr^ := CDA_Copy(SrcPtr^);
      {$ENDIF}  
        DoChange;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ValueKindExchange(ValA,ValB: TUNSValueKind);
var
  ValAPtr,ValBPtr:  TUNSNodeValueTypePtr;
  Temp:             TUNSNodeValueType;
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

Function TUNSNodeClassType.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := SameValues(TUNSNodeValueType(Address(ValA)^),TUNSNodeValueType(Address(ValB)^))
else
  Result := True;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.Address(ValueKind: TUNSValueKind = vkActual): Pointer;
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

Function TUNSNodeClassType.AsString(ValueKind: TUNSValueKind = vkActual): String;
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

procedure TUNSNodeClassType.FromString(const Str: String; ValueKind: TUNSValueKind = vkActual);
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

procedure TUNSNodeClassType.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
var
  i:  Integer;
begin
// arrays are stored with explicit length (Int32 value)
Stream_WriteInt32(Stream,Int32(ObtainCount(ValueKind)));
// cycles are inside of cases, it is faster that way
case ValueKind of
  vkActual:   For i := CDA_Low(fValue) to CDA_High(fValue) do
                UNS_StreamWriteFunction(Stream,CDA_GetItem(fValue,i));
  vkSaved:    For i := CDA_Low(fSavedValue) to CDA_High(fSavedValue) do
                UNS_StreamWriteFunction(Stream,CDA_GetItem(fSavedValue,i));
  vkDefault:  For i := CDA_Low(fDefaultValue) to CDA_High(fDefaultValue) do
                UNS_StreamWriteFunction(Stream,CDA_GetItem(fDefaultValue,i));
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
var
  i:  Integer;
begin
case ValueKind of
  vkActual:   begin
              {$IFDEF UNS_NodeAoBuffer}
                For i := CDA_Low(fValue) to CDA_High(fValue) do
                  FreeBuffer(fValue.Arr[i]);
              {$ENDIF}
                CDA_Clear(fValue);
                For i := 0 to Pred(Stream_ReadInt32(Stream)) do
                  CDA_Add(fValue,UNS_StreamReadFunction(Stream));
              end;
  vkSaved:    begin
              {$IFDEF UNS_NodeAoBuffer}
                For i := CDA_Low(fSavedValue) to CDA_High(fSavedValue) do
                  FreeBuffer(fSavedValue.Arr[i]);
              {$ENDIF}
                CDA_Clear(fSavedValue);
                For i := 0 to Pred(Stream_ReadInt32(Stream)) do
                  CDA_Add(fSavedValue,UNS_StreamReadFunction(Stream));
              end;
  vkDefault:  begin
              {$IFDEF UNS_NodeAoBuffer}
                For i := CDA_Low(fDefaultValue) to CDA_High(fDefaultValue) do
                  FreeBuffer(fDefaultValue.Arr[i]);
              {$ENDIF}
                CDA_Clear(fDefaultValue);
                For i := 0 to Pred(Stream_ReadInt32(Stream)) do
                  CDA_Add(fDefaultValue,UNS_StreamReadFunction(Stream));
              end;
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  i:  Integer;
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  begin
    Ptr_WriteInt32(Buffer.Memory,Int32(ObtainCount(ValueKind)),True);
    case ValueKind of
      vkActual:   For i := CDA_Low(fValue) to CDA_High(fValue) do
                    UNS_BufferWriteFunction(Buffer.Memory,CDA_GetItem(fValue,i),True);
      vkSaved:    For i := CDA_Low(fSavedValue) to CDA_High(fSavedValue) do
                    UNS_BufferWriteFunction(Buffer.Memory,CDA_GetItem(fSavedValue,i),True);
      vkDefault:  For i := CDA_Low(fDefaultValue) to CDA_High(fDefaultValue) do
                    UNS_BufferWriteFunction(Buffer.Memory,CDA_GetItem(fDefaultValue,i),True);
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
    end;
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  i:  Integer;
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  begin
    case ValueKind of
      vkActual:   begin
                  {$IFDEF UNS_NodeAoBuffer}
                    For i := CDA_Low(fValue) to CDA_High(fValue) do
                      FreeBuffer(fValue.Arr[i]);
                  {$ENDIF}
                    CDA_Clear(fValue);
                    For i := 0 to Pred(Ptr_ReadInt32(Buffer.Memory,True)) do
                      CDA_Add(fValue,UNS_BufferReadFunction(Buffer.Memory,True));
                  end;
      vkSaved:    begin
                  {$IFDEF UNS_NodeAoBuffer}
                    For i := CDA_Low(fSavedValue) to CDA_High(fSavedValue) do
                      FreeBuffer(fSavedValue.Arr[i]);
                  {$ENDIF}
                    CDA_Clear(fSavedValue);
                    For i := 0 to Pred(Ptr_ReadInt32(Buffer.Memory,True)) do
                      CDA_Add(fSavedValue,UNS_BufferReadFunction(Buffer.Memory,True));
                  end;
      vkDefault:  begin
                  {$IFDEF UNS_NodeAoBuffer}
                    For i := CDA_Low(fDefaultValue) to CDA_High(fDefaultValue) do
                      FreeBuffer(fDefaultValue.Arr[i]);
                  {$ENDIF}
                    CDA_Clear(fDefaultValue);
                    For i := 0 to Pred(Ptr_ReadInt32(Buffer.Memory,True)) do
                      CDA_Add(fDefaultValue,UNS_BufferReadFunction(Buffer.Memory,True));
                  end;
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromBuffer');
    end;
    DoChange;
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'FromBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ValueKindMove(Index: Integer; Src,Dest: TUNSValueKind);
var
  SrcPtr,DestPtr: TUNSNodeValueItemTypePtr;
begin
If Src <> Dest then
  begin
    SrcPtr := Address(Index,Src);
    DestPtr := Address(Index,Dest);
    If not SameItemValues(SrcPtr^,DestPtr^) then
      begin
      {$IFDEF UNS_NodeAoBuffer}
        CopyBufferInto(SrcPtr^,DestPtr^);
      {$ELSE}
        DestPtr^ := SrcPtr^;
      {$ENDIF}
        DoChange;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ValueKindExchange(Index: Integer; ValA,ValB: TUNSValueKind);
var
  ValAPtr,ValBPtr:  TUNSNodeValueItemTypePtr;
  Temp:             TUNSNodeValueItemType;
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

Function TUNSNodeClassType.ValueKindCompare(Index: Integer; ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := SameItemValues(TUNSNodeValueItemType(Address(Index,ValA)^),
                           TUNSNodeValueItemType(Address(Index,ValB)^))
else
  Result := True;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.Address(Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer;
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

Function TUNSNodeClassType.AsString(Index: Integer; ValueKind: TUNSValueKind = vkActual): String;
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

procedure TUNSNodeClassType.FromString(Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  begin
    case ValueKind of
    {$IFDEF UNS_NodeAoBuffer}
      vkActual:   begin
                    FreeBuffer(fValue.Arr[Index]);
                    ConvItemFromStr(Str,fValue.Arr[Index]);
                  end;
      vkSaved:    begin
                    FreeBuffer(fSavedValue.Arr[Index]);
                    ConvItemFromStr(Str,fSavedValue.Arr[Index]);
                  end;
      vkDefault:  begin
                    FreeBuffer(fDefaultValue.Arr[Index]);
                    ConvItemFromStr(Str,fDefaultValue.Arr[Index]);
                  end;
    {$ELSE}
      vkActual:   SetItem(Index,ConvItemFromStr(Str));
      vkSaved:    SetSavedItem(Index,ConvItemFromStr(Str));
      vkDefault:  SetDefaultItem(Index,ConvItemFromStr(Str));
    {$ENDIF}
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromString');
    end;
  {$IFDEF UNS_NodeAoBuffer}
    DoChange;
  {$ENDIF}
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'FromString');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ToStream(Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   UNS_StreamWriteFunction(Stream,CDA_GetItem(fValue,Index));
    vkSaved:    UNS_StreamWriteFunction(Stream,CDA_GetItem(fSavedValue,Index));
    vkDefault:  UNS_StreamWriteFunction(Stream,CDA_GetItem(fDefaultValue,Index));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'ToStream');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.FromStream(Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  begin
    case ValueKind of
    {$IFDEF UNS_NodeAoBuffer}
      vkActual:   begin
                    FreeBuffer(fValue.Arr[Index]);
                    fValue.Arr[Index] := UNS_StreamReadFunction(Stream);
                  end;
      vkSaved:    begin
                    FreeBuffer(fSavedValue.Arr[Index]);
                    fSavedValue.Arr[Index] := UNS_StreamReadFunction(Stream);
                  end;
      vkDefault:  begin
                    FreeBuffer(fDefaultValue.Arr[Index]);
                    fDefaultValue.Arr[Index] := UNS_StreamReadFunction(Stream);
                  end;
    {$ELSE}
      vkActual:   SetItem(Index,UNS_StreamReadFunction(Stream));
      vkSaved:    SetSavedItem(Index,UNS_StreamReadFunction(Stream));
      vkDefault:  SetDefaultItem(Index,UNS_StreamReadFunction(Stream));
    {$ENDIF}
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
    end;
  {$IFDEF UNS_NodeAoBuffer}
    DoChange;
  {$ENDIF}    
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'FromStream');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ToBuffer(Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   UNS_BufferWriteFunction(Buffer.Memory,CDA_GetItem(fValue,Index),False);
    vkSaved:    UNS_BufferWriteFunction(Buffer.Memory,CDA_GetItem(fSavedValue,Index),False);
    vkDefault:  UNS_BufferWriteFunction(Buffer.Memory,CDA_GetItem(fDefaultValue,Index),False);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.FromBuffer(Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If CheckIndex(Index,ValueKind) then
  begin
    case ValueKind of
    {$IFDEF UNS_NodeAoBuffer}
      vkActual:   begin
                    FreeBuffer(fValue.Arr[Index]);
                    fValue.Arr[Index] := UNS_BufferReadFunction(Buffer.Memory,False);;
                  end;
      vkSaved:    begin
                    FreeBuffer(fSavedValue.Arr[Index]);
                    fSavedValue.Arr[Index] := UNS_BufferReadFunction(Buffer.Memory,False);;
                  end;
      vkDefault:  begin
                    FreeBuffer(fDefaultValue.Arr[Index]);
                    fDefaultValue.Arr[Index] := UNS_BufferReadFunction(Buffer.Memory,False);
                  end;
    {$ELSE}
      vkActual:   SetItem(Index,UNS_BufferReadFunction(Buffer.Memory,False));
      vkSaved:    SetSavedItem(Index,UNS_BufferReadFunction(Buffer.Memory,False));
      vkDefault:  SetDefaultItem(Index,UNS_BufferReadFunction(Buffer.Memory,False));
    {$ENDIF}
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromBuffer');
    end;
  {$IFDEF UNS_NodeAoBuffer}
    DoChange;
  {$ENDIF}
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'FromBuffer');
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.LowIndex(ValueKind: TUNSValueKind = vkActual): Integer;
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

Function TUNSNodeClassType.HighIndex(ValueKind: TUNSValueKind = vkActual): Integer;
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

Function TUNSNodeClassType.First(ValueKind: TUNSValueKind = vkActual): TUNSNodeValueItemType;
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

Function TUNSNodeClassType.Last(ValueKind: TUNSValueKind = vkActual): TUNSNodeValueItemType;
begin
If ObtainCount(ValueKind) > 0 then
  case ValueKind of
    vkActual:   Result := CDA_GetItem(fValue,CDA_High(fValue));
    vkSaved:    Result := CDA_GetItem(fSavedValue,CDA_High(fSavedValue));
    vkDefault:  Result := CDA_GetItem(fDefaultValue,CDA_High(fDefaultValue));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'First');
  end
else raise EUNSException.Create('Empty array.',Self,'Last');
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.IndexOf(const Item: TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual): Integer;
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

Function TUNSNodeClassType.Add(const Item: TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual): Integer;
var
  Temp: TUNSNodeValueItemType;
begin
{$IFDEF UNS_NodeAoBuffer}
CopyBuffer(Item,Temp);
{$ELSE}
Temp := Item;
{$ENDIF}
case ValueKind of
  vkActual:   Result := CDA_Add(fValue,Temp);
  vkSaved:    Result := CDA_Add(fSavedValue,Temp);
  vkDefault:  Result := CDA_Add(fDefaultValue,Temp);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Add');
end;
If Result >= 0 then
  DoChange;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.Append(const Items: array of TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual): Integer;

  procedure AppendTo(var Value: TUNSNodeValueType);
  var
    i:    Integer;
    Temp: TUNSNodeValueItemType;
  begin
    For i := Low(Items) to High(Items) do
      begin
      {$IFDEF UNS_NodeAoBuffer}
        CopyBuffer(Items[i],Temp);
      {$ELSE}
        Temp := Items[i];
      {$ENDIF}
        CDA_Add(Value,Temp);
      end;
  end;

begin
If Length(Items) > 0 then
  begin
    case ValueKind of
      vkActual:   AppendTo(fValue);
      vkSaved:    AppendTo(fSavedValue);
      vkDefault:  AppendTo(fDefaultValue);
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Append');
    end;
    Result := Length(Items);
    DoChange;
  end
else Result := 0;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.Insert(Index: Integer; const Item: TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual);
var
  Temp: TUNSNodeValueItemType;
begin
{$IFDEF UNS_NodeAoBuffer}
CopyBuffer(Item,Temp);
{$ELSE}
Temp := Item;
{$ENDIF}
case ValueKind of
  vkActual:   CDA_Insert(fValue,Index,Temp);
  vkSaved:    CDA_Insert(fSavedValue,Index,Temp);
  vkDefault:  CDA_Insert(fDefaultValue,Index,Temp);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Insert');
end;
DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.Exchange(Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual);
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

procedure TUNSNodeClassType.Move(SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual);
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

Function TUNSNodeClassType.Remove(const Item: TUNSNodeValueItemType; ValueKind: TUNSValueKind = vkActual): Integer;

  Function RemoveFrom(var Value: TUNSNodeValueType): Integer;
  {$IFDEF UNS_NodeAoBuffer}
  begin
    Result := CDA_IndexOf(Value,Item);
    If CDA_CheckIndex(Value,Result) then
      begin
        FreeBuffer(Value.Arr[Result]);
        CDA_Delete(Value,Result);
      end;
  {$ELSE}
  begin
    Result := CDA_Remove(Value,Item);
  {$ENDIF}
  end;

begin
case ValueKind of
  vkActual:   Result := RemoveFrom(fValue);
  vkSaved:    Result := RemoveFrom(fSavedValue);
  vkDefault:  Result := RemoveFrom(fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Remove');
end;
If Result >= 0 then
  DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.Delete(Index: Integer; ValueKind: TUNSValueKind = vkActual);

  procedure DeleteFrom(var Value: TUNSNodeValueType);
  begin
  {$IFDEF UNS_NodeAoBuffer}
    FreeBuffer(Value.Arr[Index]);
  {$ENDIF}
    CDA_Delete(Value,Index);
  end;

begin
If CheckIndex(Index,ValueKind) then
  case ValueKind of
    vkActual:   DeleteFrom(fValue);
    vkSaved:    DeleteFrom(fSavedValue);
    vkDefault:  DeleteFrom(fDefaultValue);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Delete');
  end
else EUNSIndexOutOfBoundsException.Create(Index,Self,'Delete');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.Clear(ValueKind: TUNSValueKind = vkActual);

  procedure ClearFrom(var Value: TUNSNodeValueType);
  {$IFDEF UNS_NodeAoBuffer}
  var
    i:  Integer;
  begin
    For i := CDA_Low(Value) to CDA_High(Value) do
      FreeBuffer(Value.Arr[i]);
  {$ELSE}
  begin
  {$ENDIF}
    CDA_Clear(Value);
  end;

begin
case ValueKind of
  vkActual:   ClearFrom(fValue);
  vkSaved:    ClearFrom(fSavedValue);
  vkDefault:  ClearFrom(fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'Clear');
end;
DoChange;
end;

{$ENDIF UNS_NodeInclude_Implementation}
