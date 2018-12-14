{$IFDEF UNS_NodeInclude_Declaration}
  private
    fValue:         TUNSNodeValueType;
    fSavedValue:    TUNSNodeValueType;
    fDefaultValue:  TUNSNodeValueType;
    procedure SetValue(NewValue: TUNSNodeValueType);
    procedure SetSavedValue(NewValue: TUNSNodeValueType);
    procedure SetDefaultValue(NewValue: TUNSNodeValueType);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: TUNSNodeValueType): String; reintroduce;
    Function ConvFromStr(const Str: String): TUNSNodeValueType; reintroduce;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    constructor CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
    Function NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean; override;
    procedure ValueKindMove(Src,Dest: TUNSValueKind); override;
    procedure ValueKindExchange(ValA,ValB: TUNSValueKind); override;
    Function ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean; override;   
    procedure Save; override;
    procedure Restore; override;
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

procedure TUNSNodeClassType.SetValue(NewValue: TUNSNodeValueType);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetSavedValue(NewValue: TUNSNodeValueType);
begin
If NewValue <> fSavedValue then
  begin
    fSavedValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.SetDefaultValue(NewValue: TUNSNodeValueType);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

Function TUNSNodeClassType.GetValueSize: TMemSize;
begin
Result := SizeOf(TUNSNodeValueTypeBin);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetSavedValueSize: TMemSize;
begin
Result := SizeOf(TUNSNodeValueTypeBin);
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(TUNSNodeValueTypeBin);
end;

//==============================================================================

constructor TUNSNodeClassType.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeClassType(Source).Value;
fSavedValue := TUNSNodeClassType(Source).SavedValue;
fDefaultValue := TUNSNodeClassType(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeClassType.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
If inherited NodeEquals(Node) then
  begin
    Result := True;
    If vkActual in CompareValueKinds then
      Result := Result and (fValue = TUNSNodeClassType(Node).Value);
    If vkSaved in CompareValueKinds then
      Result := Result and (fSavedValue = TUNSNodeClassType(Node).SavedValue);
    If vkDefault in CompareValueKinds then
      Result := Result and (fDefaultValue = TUNSNodeClassType(Node).DefaultValue);
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
    If SrcPtr^ <> DestPtr^ then
      begin
        DestPtr^ := SrcPtr^;
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
    If ValAPtr^ <> ValBPtr^ then
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
  Result := TUNSNodeValueType(Address(ValA)^) = TUNSNodeValueType(Address(ValB)^)
else
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.Save;
begin
SetSavedValue(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.Restore;
begin
SetValue(fSavedValue);
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
  vkActual:   SetValue(ConvFromStr(Str));
  vkSaved:    SetSavedValue(ConvFromStr(Str));
  vkDefault:  SetDefaultValue(ConvFromStr(Str));
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromString');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
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
begin
case ValueKind of
  vkActual:   SetValue(UNS_StreamReadFunction(Stream));
  vkSaved:    SetSavedValue(UNS_StreamReadFunction(Stream));
  vkDefault:  SetDefaultValue(UNS_StreamReadFunction(Stream))
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeClassType.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
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
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   SetValue(UNS_BufferReadFunction(Buffer.Memory));
    vkSaved:    SetSavedValue(UNS_BufferReadFunction(Buffer.Memory));
    vkDefault:  SetDefaultValue(UNS_BufferReadFunction(Buffer.Memory));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromBuffer');
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'FromBuffer');
end;

{$ENDIF UNS_NodeInclude_Implementation}
