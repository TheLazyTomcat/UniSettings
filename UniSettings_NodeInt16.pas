{$IFNDEF Included}
unit UniSettings_NodeInt16;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeInt16 = class(TUNSNodeLeaf)
  private
    fValue:         Int16;
    fSavedValue:    Int16;
    fDefaultValue:  Int16;
    procedure SetValue(NewValue: Int16);
    procedure SetSavedValue(NewValue: Int16);
    procedure SetDefaultValue(NewValue: Int16);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: Int16): String; reintroduce;
    Function ConvFromStr(const Str: String): Int16; reintroduce;
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
    property Value: Int16 read fValue write SetValue;
    property SavedValue: Int16 read fSavedValue write SetSavedValue;
    property DefaultValue: Int16 read fDefaultValue write SetDefaultValue;
  end;
  
implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeInt16.SetValue(NewValue: Int16);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.SetSavedValue(NewValue: Int16);
begin
If NewValue <> fSavedValue then
  begin
    fSavedValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.SetDefaultValue(NewValue: Int16);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeInt16.GetValueType: TUNSValueType;
begin
Result := vtInt16;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.GetValueSize: TMemSize;
begin
Result := SizeOf(Int16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.GetSavedValueSize: TMemSize;
begin
Result := SizeOf(Int16);
end;


//------------------------------------------------------------------------------

Function TUNSNodeInt16.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(Int16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.ConvToStr(Value: Int16): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,4)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.ConvFromStr(const Str: String): Int16;
begin
Result := Int16(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeInt16.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeInt16.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeInt16(Source).Value;
fSavedValue := TUNSNodeInt16(Source).SavedValue;
fDefaultValue := TUNSNodeInt16(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
If inherited NodeEquals(Node) then
  begin
    Result := True;
    If vkActual in CompareValueKinds then
      Result := Result and (fValue = TUNSNodeInt16(Node).Value);
    If vkSaved in CompareValueKinds then
      Result := Result and (fSavedValue = TUNSNodeInt16(Node).SavedValue);
    If vkDefault in CompareValueKinds then
      Result := Result and (fDefaultValue = TUNSNodeInt16(Node).DefaultValue);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.ValueKindMove(Src,Dest: TUNSValueKind);
var
  SrcPtr, DestPtr:  PInt16;
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

procedure TUNSNodeInt16.ValueKindExchange(ValA,ValB: TUNSValueKind);
var
  ValAPtr, ValBPtr: PInt16;
  Temp:             Int16;
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

Function TUNSNodeInt16.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := Int16(Address(ValA)^) = Int16(Address(ValB)^)
else
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.Save;
begin
SetSavedValue(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.Address(ValueKind: TUNSValueKind = vkActual): Pointer;
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

Function TUNSNodeInt16.AsString(ValueKind: TUNSValueKind = vkActual): String;
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

procedure TUNSNodeInt16.FromString(const Str: String; ValueKind: TUNSValueKind = vkActual);
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

procedure TUNSNodeInt16.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   Stream_WriteInt16(Stream,fValue);
  vkSaved:    Stream_WriteInt16(Stream,fSavedValue);
  vkDefault:  Stream_WriteInt16(Stream,fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   SetValue(Stream_ReadInt16(Stream));
  vkSaved:    SetSavedValue(Stream_ReadInt16(Stream));
  vkDefault:  SetDefaultValue(Stream_ReadInt16(Stream))
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   Ptr_WriteInt16(Buffer.Memory,fValue);
    vkSaved:    Ptr_WriteInt16(Buffer.Memory,fSavedValue);
    vkDefault:  Ptr_WriteInt16(Buffer.Memory,fDefaultValue);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   SetValue(Ptr_ReadInt16(Buffer.Memory));
    vkSaved:    SetSavedValue(Ptr_ReadInt16(Buffer.Memory));
    vkDefault:  SetDefaultValue(Ptr_ReadInt16(Buffer.Memory));
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
    Function Int16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int16; virtual;
    procedure Int16ValueSet(const ValueName: String; NewValue: Int16; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Int16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int16;
begin
ReadLock;
try
  with TUNSNodeInt16(CheckedLeafNodeTypeAccess(ValueName,vtInt16,'Int16ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueSet(const ValueName: String; NewValue: Int16; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeInt16(CheckedLeafNodeTypeAccess(ValueName,vtInt16,'Int16ValueSet')) do
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
