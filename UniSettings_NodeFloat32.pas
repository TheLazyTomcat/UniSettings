{$IFNDEF Included}
unit UniSettings_NodeFloat32;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeFloat32 = class(TUNSNodeLeaf)
  private
    fValue:         Float32;
    fDefaultValue:  Float32;
    procedure SetValue(NewValue: Float32);
    procedure SetDefaultValue(NewValue: Float32);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: Float32): String; reintroduce;
    Function ConvFromStr(const Str: String): Float32; reintroduce;
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
    property Value: Float32 read fValue write SetValue;
    property DefaultValue: Float32 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

procedure TUNSNodeFloat32.SetValue(NewValue: Float32);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.SetDefaultValue(NewValue: Float32);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeFloat32.GetValueType: TUNSValueType;
begin
Result := vtFloat32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat32.GetValueSize: TMemSize;
begin
Result := SizeOf(Float32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat32.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(Float32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat32.ConvToStr(Value: Float32): String;
begin
If ValueFormatSettings.HexFloats then
  Result := '$' + SingleToHex(Value)
else
  Result := FloatToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat32.ConvFromStr(const Str: String): Float32;
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

procedure TUNSNodeFloat32.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.ExchangeActualAndDefault;
var
  Temp: Float32;
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

Function TUNSNodeFloat32.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat32.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat32.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat32(Stream,fDefaultValue)
else
  Stream_WriteFloat32(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadFloat32(Stream))
else
  SetValue(Stream_ReadFloat32(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat32(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteFloat32(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadFloat32(Buffer.Memory))
    else
      SetValue(Ptr_ReadFloat32(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function Float32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float32; virtual;
    procedure Float32ValueSet(const ValueName: String; NewValue: Float32; AccessDefVal: Boolean = False); virtual;
    Function FloatValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float32; virtual;
    procedure FloatValueSet(const ValueName: String; NewValue: Float32; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Float32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float32;
begin
ReadLock;
try
  with TUNSNodeFloat32(CheckedLeafNodeTypeAccess(ValueName,vtFloat32,'Float32ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Float32ValueSet(const ValueName: String; NewValue: Float32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeFloat32(CheckedLeafNodeTypeAccess(ValueName,vtFloat32,'Float32ValueSet')) do
    If AccessDefVal then
      Value := NewValue
    else
      DefaultValue := NewValue;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.FloatValueGet(const ValueName: String; AccessDefVal: Boolean = False): Float32;
begin
ReadLock;
try
  with TUNSNodeFloat32(CheckedLeafNodeTypeAccess(ValueName,vtFloat,'FloatValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.FloatValueSet(const ValueName: String; NewValue: Float32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeFloat32(CheckedLeafNodeTypeAccess(ValueName,vtFloat,'FloatValueSet')) do
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
