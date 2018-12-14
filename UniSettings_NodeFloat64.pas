{$IFNDEF Included}
unit UniSettings_NodeFloat64;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeFloat64 = class(TUNSNodeLeaf)
  private
    fValue:         Float64;
    fDefaultValue:  Float64;
    procedure SetValue(NewValue: Float64);
    procedure SetDefaultValue(NewValue: Float64);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: Float64): String; reintroduce;
    Function ConvFromStr(const Str: String): Float64; reintroduce;
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
    property Value: Float64 read fValue write SetValue;
    property DefaultValue: Float64 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

procedure TUNSNodeFloat64.SetValue(NewValue: Float64);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat64.SetDefaultValue(NewValue: Float64);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeFloat64.GetValueType: TUNSValueType;
begin
Result := vtFloat64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat64.GetValueSize: TMemSize;
begin
Result := SizeOf(Float64);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat64.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(Float64);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat64.ConvToStr(Value: Float64): String;
begin
If ValueFormatSettings.HexFloats then
  Result := '$' + DoubleToHex(Value)
else
  Result := FloatToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat64.ConvFromStr(const Str: String): Float64;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToSingle(Str)
    else
      Result := StrToFloat(Str,fConvSettings);
  end
else Result := StrToFloat(Str,fConvSettings);
end;

//==============================================================================

procedure TUNSNodeFloat64.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat64.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat64.ExchangeActualAndDefault;
var
  Temp: Float64;
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

Function TUNSNodeFloat64.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat64.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat64.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat64.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat64.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat64(Stream,fDefaultValue)
else
  Stream_WriteFloat64(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat64.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadFloat64(Stream))
else
  SetValue(Stream_ReadFloat64(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat64.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat64(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteFloat64(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat64.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadFloat64(Buffer.Memory))
    else
      SetValue(Ptr_ReadFloat64(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function Float64ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float64; virtual;
    procedure Float64ValueSet(const ValueName: String; NewValue: Float64; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Float64ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float64;
begin
ReadLock;
try
  with TUNSNodeFloat64(CheckedLeafNodeTypeAccess(ValueName,vtFloat64,'Float64ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float64ValueSet(const ValueName: String; NewValue: Float64; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeFloat64(CheckedLeafNodeTypeAccess(ValueName,vtFloat64,'Float64ValueSet')) do
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
