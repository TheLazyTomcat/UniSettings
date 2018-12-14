{$IFNDEF Included}
unit UniSettings_NodeBool;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeBool = class(TUNSNodeLeaf)
  private
    fValue:         Boolean;
    fSavedValue:    Boolean;
    fDefaultValue:  Boolean;
    procedure SetValue(NewValue: Boolean);
    procedure SetSavedValue(NewValue: Boolean);
    procedure SetDefaultValue(NewValue: Boolean);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: Boolean): String; reintroduce;
    Function ConvFromStr(const Str: String): Boolean; reintroduce;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    constructor CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
    Function NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean; override;
    procedure ValueKindMove(Src,Dest: TUNSValueKind); override;
    procedure ValueKindExchange(ValA,ValB: TUNSValueKind); override;
    Function ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean; override;   
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    procedure Save; override;
    procedure Restore; override;
    Function Address(ValueKind: TUNSValueKind = vkActual): Pointer; override;
    Function AsString(ValueKind: TUNSValueKind = vkActual): String; override;
    procedure FromString(const Str: String; ValueKind: TUNSValueKind = vkActual); override;
    procedure ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual); override;
    procedure FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual); override;
    procedure ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); override;
    procedure FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); override;
    property Value: Boolean read fValue write SetValue;
    property SavedValue: Boolean read fSavedValue write SetSavedValue;
    property DefaultValue: Boolean read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeBool.SetValue(NewValue: Boolean);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetSavedValue(NewValue: Boolean);
begin
If NewValue <> fSavedValue then
  begin
    fSavedValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetDefaultValue(NewValue: Boolean);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeBool.GetValueType: TUNSValueType;
begin
Result := vtBool;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueSize: TMemSize;
begin
Result := SizeOf(ByteBool);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetSavedValueSize: TMemSize;
begin
Result := SizeOf(ByteBool);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(ByteBool);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.ConvToStr(Value: Boolean): String;
begin
If ValueFormatSettings.NumericBools then
  Result := IntToStr(Ord(Value))
else
  Result := BoolToStr(Value,True);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.ConvFromStr(const Str: String): Boolean;
begin
Result := StrToBool(Str);
end;

//==============================================================================

constructor TUNSNodeBool.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := False;
fSavedValue := False;
fDefaultValue := False;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeBool.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeBool(Source).Value;
fSavedValue := TUNSNodeBool(Source).SavedValue;
fDefaultValue := TUNSNodeBool(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
If inherited NodeEquals(Node) then
  begin
    Result := True;
    If vkActual in CompareValueKinds then
      Result := Result and (fValue = TUNSNodeBool(Node).Value);
    If vkSaved in CompareValueKinds then
      Result := Result and (fSavedValue = TUNSNodeBool(Node).SavedValue);
    If vkDefault in CompareValueKinds then
      Result := Result and (fDefaultValue = TUNSNodeBool(Node).DefaultValue);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.ValueKindMove(Src,Dest: TUNSValueKind);
var
  SrcPtr, DestPtr:  PBoolean;
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

procedure TUNSNodeBool.ValueKindExchange(ValA,ValB: TUNSValueKind);
var
  ValAPtr, ValBPtr: PBoolean;
  Temp:             Boolean;
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

Function TUNSNodeBool.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
If ValA <> ValB then
  Result := Boolean(Address(ValA)^) = Boolean(Address(ValB)^)
else
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.ActualFromDefault;
begin
ValueKindMove(vkDefault,vkActual);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.DefaultFromActual;
begin
ValueKindMove(vkActual,vkDefault);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.ExchangeActualAndDefault;
begin
ValueKindExchange(vkActual,vkDefault);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.ActualEqualsDefault: Boolean;
begin
Result := ValueKindCompare(vkActual,vkDefault);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.Save;
begin
SetSavedValue(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.Address(ValueKind: TUNSValueKind = vkActual): Pointer;
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

Function TUNSNodeBool.AsString(ValueKind: TUNSValueKind = vkActual): String;
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

procedure TUNSNodeBool.FromString(const Str: String; ValueKind: TUNSValueKind = vkActual);
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

procedure TUNSNodeBool.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   Stream_WriteBool(Stream,fValue);
  vkSaved:    Stream_WriteBool(Stream,fSavedValue);
  vkDefault:  Stream_WriteBool(Stream,fDefaultValue);
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
case ValueKind of
  vkActual:   SetValue(Stream_ReadBool(Stream));
  vkSaved:    SetSavedValue(Stream_ReadBool(Stream));
  vkDefault:  SetDefaultValue(Stream_ReadBool(Stream))
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'FromStream');
end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   Ptr_WriteBool(Buffer.Memory,fValue);
    vkSaved:    Ptr_WriteBool(Buffer.Memory,fSavedValue);
    vkDefault:  Ptr_WriteBool(Buffer.Memory,fDefaultValue);
  else
    raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ToBuffer');
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'ToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
If Buffer.Size >= ObtainValueSize(ValueKind) then
  case ValueKind of
    vkActual:   SetValue(Ptr_ReadBool(Buffer.Memory));
    vkSaved:    SetSavedValue(Ptr_ReadBool(Buffer.Memory));
    vkDefault:  SetDefaultValue(Ptr_ReadBool(Buffer.Memory));
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
    Function BooleanValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure BooleanValueSet(const ValueName: String; NewValue: Boolean; ValueKind: TUNSValueKind = vkActual); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.BooleanValueGet(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
ReadLock;
try
  with TUNSNodeBool(CheckedLeafNodeTypeAccess(ValueName,vtBool,'BooleanValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueSet(const ValueName: String; NewValue: Boolean; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  with TUNSNodeBool(CheckedLeafNodeTypeAccess(ValueName,vtBool,'BooleanValueSet')) do
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
