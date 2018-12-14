{$IFNDEF Included}
unit UniSettings_NodeUInt8;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeUInt8 = class(TUNSNodeLeaf)
  private
    fValue:         UInt8;
    fSavedValue:    UInt8;
    fDefaultValue:  UInt8;
    procedure SetValue(NewValue: UInt8);
    procedure SetSavedValue(NewValue: UInt8);
    procedure SetDefaultValue(NewValue: UInt8);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: UInt8): String; reintroduce;
    Function ConvFromStr(const Str: String): UInt8; reintroduce;
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
    property Value: UInt8 read fValue write SetValue;
    property SavedValue: UInt8 read fSavedValue write SetSavedValue;
    property DefaultValue: UInt8 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeUInt8.SetValue(NewValue: UInt8);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.SetSavedValue(NewValue: UInt8);
begin
If NewValue <> fSavedValue then
  begin
    fSavedValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.SetDefaultValue(NewValue: UInt8);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeUInt8.GetValueType: TUNSValueType;
begin
Result := vtUInt8;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.GetValueSize: TMemSize;
begin
Result := SizeOf(UInt8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.GetSavedValueSize: TMemSize;
begin
Result := SizeOf(UInt8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(UInt8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.ConvToStr(Value: UInt8): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,2)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.ConvFromStr(const Str: String): UInt8;
begin
Result := UInt8(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeUInt8.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeUInt8.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeUInt8(Source).Value;
fSavedValue := TUNSNodeUInt8(Source).SavedValue;
fDefaultValue := TUNSNodeUInt8(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
If inherited NodeEquals(Node) then
  begin
    Result := True;
    If vkActual in CompareValueKinds then
      Result := Result and (fValue = TUNSNodeUInt8(Node).Value);
    If vkSaved in CompareValueKinds then
      Result := Result and (fSavedValue = TUNSNodeUInt8(Node).SavedValue);
    If vkDefault in CompareValueKinds then
      Result := Result and (fDefaultValue = TUNSNodeUInt8(Node).DefaultValue);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.ValueKindMove(Src,Dest: TUNSValueKind);
var
  SrcPtr, DestPtr:  PUInt8;
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

procedure TUNSNodeUInt8.ValueKindExchange(ValA,ValB: TUNSValueKind);
var
  ValAPtr, ValBPtr: PUInt8;
  Temp:             UInt8;
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

Function TUNSNodeUInt8.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := UInt8(Address(ValA)^) = UInt8(Address(ValB)^)
else
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.Save;
begin
SetSavedValue(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.Address(ValueKind: TUNSValueKind = vkActual): Pointer;
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

Function TUNSNodeUInt8.AsString(ValueKind: TUNSValueKind = vkActual): String;
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

procedure TUNSNodeUInt8.FromString(const Str: String; ValueKind: TUNSValueKind = vkActual);
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

procedure TUNSNodeUInt8.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   Stream_WriteUInt8(Stream,fValue);
  vkSaved:    Stream_WriteUInt8(Stream,fSavedValue);
  vkDefault:  Stream_WriteUInt8(Stream,fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   SetValue(Stream_ReadUInt8(Stream));
  vkSaved:    SetSavedValue(Stream_ReadUInt8(Stream));
  vkDefault:  SetDefaultValue(Stream_ReadUInt8(Stream))
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   Ptr_WriteUInt8(Buffer.Memory,fValue);
    vkSaved:    Ptr_WriteUInt8(Buffer.Memory,fSavedValue);
    vkDefault:  Ptr_WriteUInt8(Buffer.Memory,fDefaultValue);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   SetValue(Ptr_ReadUInt8(Buffer.Memory));
    vkSaved:    SetSavedValue(Ptr_ReadUInt8(Buffer.Memory));
    vkDefault:  SetDefaultValue(Ptr_ReadUInt8(Buffer.Memory));
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
    Function UInt8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8; virtual;
    procedure UInt8ValueSet(const ValueName: String; NewValue: UInt8; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt8ValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): UInt8;
begin
ReadLock;
try
  with TUNSNodeUInt8(CheckedLeafNodeTypeAccess(ValueName,vtUInt8,'UInt8ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueSet(const ValueName: String; NewValue: UInt8; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  with TUNSNodeUInt8(CheckedLeafNodeTypeAccess(ValueName,vtUInt8,'UInt8ValueSet')) do
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
