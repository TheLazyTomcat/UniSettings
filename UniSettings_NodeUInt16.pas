{$IFNDEF Included}
unit UniSettings_NodeUInt16;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeUInt16 = class(TUNSNodeLeaf)
  private
    fValue:         UInt16;
    fSavedValue:    UInt16;
    fDefaultValue:  UInt16;
    procedure SetValue(NewValue: UInt16);
    procedure SetSavedValue(NewValue: UInt16);
    procedure SetDefaultValue(NewValue: UInt16);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: UInt16): String; reintroduce;
    Function ConvFromStr(const Str: String): UInt16; reintroduce;
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
    property Value: UInt16 read fValue write SetValue;
    property SavedValue: UInt16 read fSavedValue write SetSavedValue;
    property DefaultValue: UInt16 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeUInt16.SetValue(NewValue: UInt16);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.SetSavedValue(NewValue: UInt16);
begin
If NewValue <> fSavedValue then
  begin
    fSavedValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------


procedure TUNSNodeUInt16.SetDefaultValue(NewValue: UInt16);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeUInt16.GetValueType: TUNSValueType;
begin
Result := vtUInt16;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.GetValueSize: TMemSize;
begin
Result := SizeOf(UInt16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.GetSavedValueSize: TMemSize;
begin
Result := SizeOf(UInt16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(UInt16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.ConvToStr(Value: UInt16): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,4)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.ConvFromStr(const Str: String): UInt16;
begin
Result := UInt16(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeUInt16.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeUInt16.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeUInt16(Source).Value;
fSavedValue := TUNSNodeUInt16(Source).SavedValue;
fDefaultValue := TUNSNodeUInt16(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
If inherited NodeEquals(Node) then
  begin
    Result := True;
    If vkActual in CompareValueKinds then
      Result := Result and (fValue = TUNSNodeUInt16(Node).Value);
    If vkSaved in CompareValueKinds then
      Result := Result and (fSavedValue = TUNSNodeUInt16(Node).SavedValue);
    If vkDefault in CompareValueKinds then
      Result := Result and (fDefaultValue = TUNSNodeUInt16(Node).DefaultValue);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.ValueKindMove(Src,Dest: TUNSValueKind);
var
  SrcPtr, DestPtr:  PUInt16;
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

procedure TUNSNodeUInt16.ValueKindExchange(ValA,ValB: TUNSValueKind);
var
  ValAPtr, ValBPtr: PUInt16;
  Temp:             UInt16;
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

Function TUNSNodeUInt16.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := UInt16(Address(ValA)^) = UInt16(Address(ValB)^)
else
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.Save;
begin
SetSavedValue(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.Address(ValueKind: TUNSValueKind = vkActual): Pointer;
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

Function TUNSNodeUInt16.AsString(ValueKind: TUNSValueKind = vkActual): String;
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

procedure TUNSNodeUInt16.FromString(const Str: String; ValueKind: TUNSValueKind = vkActual);
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

procedure TUNSNodeUInt16.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   Stream_WriteUInt16(Stream,fValue);
  vkSaved:    Stream_WriteUInt16(Stream,fSavedValue);
  vkDefault:  Stream_WriteUInt16(Stream,fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   SetValue(Stream_ReadUInt16(Stream));
  vkSaved:    SetSavedValue(Stream_ReadUInt16(Stream));
  vkDefault:  SetDefaultValue(Stream_ReadUInt16(Stream))
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   Ptr_WriteUInt16(Buffer.Memory,fValue);
    vkSaved:    Ptr_WriteUInt16(Buffer.Memory,fSavedValue);
    vkDefault:  Ptr_WriteUInt16(Buffer.Memory,fDefaultValue);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   SetValue(Ptr_ReadUInt16(Buffer.Memory));
    vkSaved:    SetSavedValue(Ptr_ReadUInt16(Buffer.Memory));
    vkDefault:  SetDefaultValue(Ptr_ReadUInt16(Buffer.Memory));
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
    Function UInt16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt16; virtual;
    procedure UInt16ValueSet(const ValueName: String; NewValue: UInt16; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt16;
begin
ReadLock;
try
  with TUNSNodeUInt16(CheckedLeafNodeTypeAccess(ValueName,vtUInt16,'UInt16ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueSet(const ValueName: String; NewValue: UInt16; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeUInt16(CheckedLeafNodeTypeAccess(ValueName,vtUInt16,'UInt16ValueSet')) do
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
