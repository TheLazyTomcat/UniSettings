{$IFNDEF Included}
unit UniSettings_NodeUInt64;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeUInt64 = class(TUNSNodeLeaf)
  private
    fValue:         UInt64;
    fDefaultValue:  UInt64;
    procedure SetValue(NewValue: UInt64);
    procedure SetDefaultValue(NewValue: UInt64);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: UInt64): String; reintroduce;
    Function ConvFromStr(const Str: String): UInt64; reintroduce;
  public
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    Function Address(AccessDefVal: Boolean = False): Pointer; override;
    Function AsString(AccessDefVal: Boolean = False): String; override;
    procedure FromString(const Str: String; AccessDefVal: Boolean = False); override;
    procedure ToStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure FromStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    procedure FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    property Value: UInt64 read fValue write SetValue;
    property DefaultValue: UInt64 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeUInt64.SetValue(NewValue: UInt64);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.SetDefaultValue(NewValue: UInt64);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeUInt64.GetValueType: TUNSValueType;
begin
Result := vtUInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.GetValueSize: TMemSize;
begin
Result := SizeOf(UInt64);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(UInt64);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.ConvToStr(Value: UInt64): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,16)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.ConvFromStr(const Str: String): UInt64;
begin
Result := UInt64(StrToInt64(Str));
end;

//==============================================================================

procedure TUNSNodeUInt64.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.ExchangeActualAndDefault;
var
  Temp: UInt64;
begin
If not ActualEqualsDefault then
  begin
    Temp := fDefaultValue;
    fDefaultValue := fValue;
    fValue := Temp;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteUInt64(Stream,fDefaultValue)
else
  Stream_WriteUInt64(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadUInt64(Stream))
else
  SetValue(Stream_ReadUInt64(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteUInt64(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteUInt64(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadUInt64(Buffer.Memory))
    else
      SetValue(Ptr_ReadUInt64(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function UInt64ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt64; virtual;
    procedure UInt64ValueSet(const ValueName: String; NewValue: UInt64; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt64ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt64;
begin
ReadLock;
try
  with TUNSNodeUInt64(CheckedLeafNodeTypeAccess(ValueName,vtUInt64,'UInt64ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt64ValueSet(const ValueName: String; NewValue: UInt64; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeUInt64(CheckedLeafNodeTypeAccess(ValueName,vtUInt64,'UInt64ValueSet')) do
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
