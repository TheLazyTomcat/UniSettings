{$IFDEF UNS_NodeInclude_Declaration}
  private
    fValue:         TUNSNodeValueType;
    fSavedValue:    TUNSNodeValueType;
    fDefaultValue:  TUNSNodeValueType;
    procedure SetValue(const NewValue: TUNSNodeValueType);
    procedure SetSavedValue(const NewValue: TUNSNodeValueType);
    procedure SetDefaultValue(const NewValue: TUNSNodeValueType);
  protected
    class Function SameValues(const A,B: TUNSNodeValueType): Boolean; reintroduce;
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(const Value: TUNSNodeValueType): String; reintroduce;
  {$IFDEF UNS_NodeBuffer}
    procedure ConvFromStr(const Str: String; var Value: TUNSNodeValueType); reintroduce;   
  {$ELSE}
    Function ConvFromStr(const Str: String): TUNSNodeValueType; reintroduce;
  {$ENDIF}
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    constructor CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
  {$IFDEF UNS_NodeBuffer}
    destructor Destroy; override;
  {$ENDIF}
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
    property Value: TUNSNodeValueType read fValue write SetValue;
    property SavedValue: TUNSNodeValueType read fSavedValue write SetSavedValue;
    property DefaultValue: TUNSNodeValueType read fDefaultValue write SetDefaultValue;
{$ENDIF UNS_NodeInclude_Declaration}

//==============================================================================

{$IFDEF UNS_NodeInclude_Implementation}

procedure TUNSNodeClassType.SetValue(const NewValue: TUNSNodeValueType);
begin
If not SameValues(NewValue,fValue) then
  begin
  {$IFDEF UNS_NodeBuffer}
    CopyBufferInto(NewValue,fValue);
  {$ELSE}
    fValue := NewValue;
  {$ENDIF}
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetSavedValue(const NewValue: TUNSNodeValueType);
begin
If not SameValues(NewValue,fSavedValue) then
  begin
  {$IFDEF UNS_NodeBuffer}
    CopyBufferInto(NewValue,fSavedValue);
  {$ELSE}
    fSavedValue := NewValue;
  {$ENDIF}
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetDefaultValue(const NewValue: TUNSNodeValueType);
begin
If not SameValues(NewValue,fDefaultValue) then
  begin
  {$IFDEF UNS_NodeBuffer}
    CopyBufferInto(NewValue,fDefaultValue);
  {$ELSE}
    fDefaultValue := NewValue;
  {$ENDIF}
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeClassType.SameValues(const A,B: TUNSNodeValueType): Boolean;
{$IFDEF UNS_NodeBuffer}
var
  i:      TMemSize;
  ABuff:  PByte;
  BBuff:  PByte;
{$ENDIF}
begin
{$IF Defined(UNS_NodeDate)}
Result := Int(A) = Int(B);
{$ELSEIF Defined(UNS_NodeTime)}
Result := Frac(A) = Frac(B);
{$ELSEIF Defined(UNS_NodeText)}
Result := AnsiSameStr(A,B);
{$ELSEIF Defined(UNS_NodeBuffer)}
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
begin
{$IF Defined(UNS_NodeText)}
Result := SizeOf(Int32) + Length(StrToUTF8(fValue)) * SizeOf(UTF8Char);
{$ELSEIF Defined(UNS_NodeBuffer)}
Result := SizeOf(UInt64) + fValue.Size;
{$ELSE}
Result := SizeOf(TUNSNodeValueTypeBin);
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetSavedValueSize: TMemSize;
begin
{$IF Defined(UNS_NodeText)}
Result := SizeOf(Int32) + Length(StrToUTF8(fSavedValue)) * SizeOf(UTF8Char);
{$ELSEIF Defined(UNS_NodeBuffer)}
Result := SizeOf(UInt64) + fSavedValue.Size;
{$ELSE}
Result := SizeOf(TUNSNodeValueTypeBin);
{$IFEND}
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetDefaultValueSize: TMemSize;
begin
{$IF Defined(UNS_NodeText)}
Result := SizeOf(Int32) + Length(StrToUTF8(fDefaultValue)) * SizeOf(UTF8Char);
{$ELSEIF Defined(UNS_NodeBuffer)}
Result := SizeOf(UInt64) + fDefaultValue.Size;
{$ELSE}
Result := SizeOf(TUNSNodeValueTypeBin);
{$IFEND}
end;

//==============================================================================

constructor TUNSNodeClassType.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
{$IFDEF UNS_NodeBuffer}
// buffers are initalized in constructor, which is called in inherited CreateAsCopy
CopyBufferInto(TUNSNodeBuffer(Source).Value,fValue);
CopyBufferInto(TUNSNodeBuffer(Source).SavedValue,fSavedValue);
CopyBufferInto(TUNSNodeBuffer(Source).DefaultValue,fDefaultValue);
{$ELSE}
fValue := TUNSNodeClassType(Source).Value;
fSavedValue := TUNSNodeClassType(Source).SavedValue;
fDefaultValue := TUNSNodeClassType(Source).DefaultValue;
{$IFDEF UNS_NodeText}
UniqueString(fValue);
UniqueString(fSavedValue);
UniqueString(fDefaultValue);
{$ENDIF}
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
      {$IFDEF UNS_NodeBuffer}
        CopyBufferInto(SrcPtr^,DestPtr^);
      {$ELSE}
        DestPtr^ := SrcPtr^;
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
{$IFDEF UNS_NodeBuffer}
  vkActual:   ConvFromStr(Str,fValue);
  vkSaved:    ConvFromStr(Str,fSavedValue);
  vkDefault:  ConvFromStr(Str,fDefaultValue);
{$ELSE}
  vkActual:   SetValue(ConvFromStr(Str));
  vkSaved:    SetSavedValue(ConvFromStr(Str));
  vkDefault:  SetDefaultValue(ConvFromStr(Str));
{$ENDIF}
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromString');
end;
{$IFDEF UNS_NodeBuffer}
DoChange;
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);

{$IFDEF UNS_NodeBuffer}
  procedure UNS_StreamWriteFunction(WriteStream: TStream; const Value: TUNSNodeValueType);
  begin
    // buffers are stored with explicit size (UInt64 value)
    Stream_WriteUInt64(WriteStream,UInt64(Value.Size));
    Stream_WriteBuffer(WriteStream,Value.Memory^,Value.Size);
  end;
{$ENDIF}

begin
case ValueKind of
  vkActual:   UNS_StreamWriteFunction(Stream,fValue);
  vkSaved:    UNS_StreamWriteFunction(Stream,fSavedValue);
  vkDefault:  UNS_StreamWriteFunction(Stream,fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);

{$IFDEF UNS_NodeBuffer}
  procedure UNS_StreamReadFunction(ReadStream: TStream; var Value: TUNSNodeValueType);
  begin
    ReallocBuffer(Value,TMemSize(Stream_ReadUInt64(ReadStream)));
    Stream_ReadBuffer(ReadStream,Value.Memory^,Value.Size);
  end;
{$ENDIF}

begin
case ValueKind of
{$IFDEF UNS_NodeBuffer}
  vkActual:   UNS_StreamReadFunction(Stream,fValue);
  vkSaved:    UNS_StreamReadFunction(Stream,fSavedValue);
  vkDefault:  UNS_StreamReadFunction(Stream,fDefaultValue);
{$ELSE}
  vkActual:   SetValue(UNS_StreamReadFunction(Stream));
  vkSaved:    SetSavedValue(UNS_StreamReadFunction(Stream));
  vkDefault:  SetDefaultValue(UNS_StreamReadFunction(Stream));
{$ENDIF}
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
{$IFDEF UNS_NodeBuffer}
DoChange;
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);

{$IFDEF UNS_NodeBuffer}
  procedure UNS_BufferWriteFunction(Memory: Pointer; const Value: TUNSNodeValueType);
  begin
    {
      the pointer is advanced in first write, but since the parameter is passed
      by value, not by reference, the original buffer record will stay unchanged
    }
    Ptr_WriteUInt64(Memory,UInt64(Value.Size),True);
    Ptr_WriteBuffer(Memory,Value.Memory^,Value.Size);
  end;
{$ENDIF}

begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   UNS_BufferWriteFunction(Buffer.Memory,fValue);
    vkSaved:    UNS_BufferWriteFunction(Buffer.Memory,fSavedValue);
    vkDefault:  UNS_BufferWriteFunction(Buffer.Memory,fDefaultValue);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);

{$IFDEF UNS_NodeBuffer}
  procedure UNS_BufferReadFunction(Memory: Pointer; var Value: TUNSNodeValueType);
  begin
    ReallocBuffer(Value,TMemSize(Ptr_ReadUInt64(Memory,True)));
    Ptr_ReadBuffer(Memory,Value.Memory^,Value.Size);
  end;
{$ENDIF}

begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  begin
    case ValueKind of
    {$IFDEF UNS_NodeBuffer}
      vkActual:   UNS_BufferReadFunction(Buffer.Memory,fValue);
      vkSaved:    UNS_BufferReadFunction(Buffer.Memory,fSavedValue);
      vkDefault:  UNS_BufferReadFunction(Buffer.Memory,fDefaultValue);
    {$ELSE}
      vkActual:   SetValue(UNS_BufferReadFunction(Buffer.Memory));
      vkSaved:    SetSavedValue(UNS_BufferReadFunction(Buffer.Memory));
      vkDefault:  SetDefaultValue(UNS_BufferReadFunction(Buffer.Memory));
    {$ENDIF}
    else
      raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromBuffer');
    end;
  {$IFDEF UNS_NodeBuffer}
    DoChange;
  {$ENDIF}
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'FromBuffer');
end;

{$ENDIF UNS_NodeInclude_Implementation}
