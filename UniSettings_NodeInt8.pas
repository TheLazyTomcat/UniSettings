{$IFNDEF Included}
unit UniSettings_NodeInt8;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeInt8 = class(TUNSNodeLeaf)
  private
    fValue:         Int8;
    fSavedValue:    Int8;
    fDefaultValue:  Int8;
    procedure SetValue(NewValue: Int8);
    procedure SetSavedValue(NewValue: Int8);
    procedure SetDefaultValue(NewValue: Int8);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: Int8): String; reintroduce;
    Function ConvFromStr(const Str: String): Int8; reintroduce;
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
    property Value: Int8 read fValue write SetValue;
    property SavedValue: Int8 read fSavedValue write SetSavedValue;
    property DefaultValue: Int8 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeInt8.SetValue(NewValue: Int8);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.SetSavedValue(NewValue: Int8);
begin
If NewValue <> fSavedValue then
  begin
    fSavedValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.SetDefaultValue(NewValue: Int8);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeInt8.GetValueType: TUNSValueType;
begin
Result := vtInt8;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.GetValueSize: TMemSize;
begin
Result := SizeOf(Int8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.GetSavedValueSize: TMemSize;
begin
Result := SizeOf(Int8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(Int8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.ConvToStr(Value: Int8): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,2)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.ConvFromStr(const Str: String): Int8;
begin
Result := Int8(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeInt8.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeInt8.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeInt8(Source).Value;
fSavedValue := TUNSNodeInt8(Source).SavedValue;
fDefaultValue := TUNSNodeInt8(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
If inherited NodeEquals(Node) then
  begin
    Result := True;
    If vkActual in CompareValueKinds then
      Result := Result and (fValue = TUNSNodeInt8(Node).Value);
    If vkSaved in CompareValueKinds then
      Result := Result and (fSavedValue = TUNSNodeInt8(Node).SavedValue);
    If vkDefault in CompareValueKinds then
      Result := Result and (fDefaultValue = TUNSNodeInt8(Node).DefaultValue);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.ValueKindMove(Src,Dest: TUNSValueKind);
var
  SrcPtr, DestPtr:  PInt8;
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

procedure TUNSNodeInt8.ValueKindExchange(ValA,ValB: TUNSValueKind);
var
  ValAPtr, ValBPtr: PInt8;
  Temp:             Int8;
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

Function TUNSNodeInt8.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := Int8(Address(ValA)^) = Int8(Address(ValB)^)
else
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.Save;
begin
SetSavedValue(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.Address(ValueKind: TUNSValueKind = vkActual): Pointer;
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

Function TUNSNodeInt8.AsString(ValueKind: TUNSValueKind = vkActual): String;
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

procedure TUNSNodeInt8.FromString(const Str: String; ValueKind: TUNSValueKind = vkActual);
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

procedure TUNSNodeInt8.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   Stream_WriteInt8(Stream,fValue);
  vkSaved:    Stream_WriteInt8(Stream,fSavedValue);
  vkDefault:  Stream_WriteInt8(Stream,fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   SetValue(Stream_ReadInt8(Stream));
  vkSaved:    SetSavedValue(Stream_ReadInt8(Stream));
  vkDefault:  SetDefaultValue(Stream_ReadInt8(Stream))
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   Ptr_WriteInt8(Buffer.Memory,fValue);
    vkSaved:    Ptr_WriteInt8(Buffer.Memory,fSavedValue);
    vkDefault:  Ptr_WriteInt8(Buffer.Memory,fDefaultValue);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   SetValue(Ptr_ReadInt8(Buffer.Memory));
    vkSaved:    SetSavedValue(Ptr_ReadInt8(Buffer.Memory));
    vkDefault:  SetDefaultValue(Ptr_ReadInt8(Buffer.Memory));
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromBuffer');
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'FromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function Int8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8; virtual;
    procedure Int8ValueSet(const ValueName: String; NewValue: Int8; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Int8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Int8;
begin
ReadLock;
try
  with TUNSNodeInt8(CheckedLeafNodeTypeAccess(ValueName,vtInt8,'Int8ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int8ValueSet(const ValueName: String; NewValue: Int8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  with TUNSNodeInt8(CheckedLeafNodeTypeAccess(ValueName,vtInt8,'Int8ValueSet')) do
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
