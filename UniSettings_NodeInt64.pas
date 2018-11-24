unit UniSettings_NodeInt64;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeInt64 = class(TUNSNodeLeaf)
  private
    fValue:         Int64;
    fDefaultValue:  Int64;
    procedure SetValue(NewValue: Int64);
    procedure SetDefaultValue(NewValue: Int64);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
    Function ConvToStr(Value: Int64): String; reintroduce;
    Function ConvFromStr(const Str: String): Int64; reintroduce;
  public
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    Function GetValueAddress(AccessDefVal: Boolean = False): Pointer; override;
    Function GetValueAsString(AccessDefVal: Boolean = False): String; override;
    procedure SetValueFromString(const Str: String; AccessDefVal: Boolean = False); override;
    procedure GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    procedure SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    property Value: Int64 read fValue write SetValue;
    property DefaultValue: Int64 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeInt64.SetValue(NewValue: Int64);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt64.SetDefaultValue(NewValue: Int64);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeInt64.GetValueType: TUNSValueType;
begin
Result := vtInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt64.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(Int64);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt64.ConvToStr(Value: Int64): String;
begin
If FormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,16)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt64.ConvFromStr(const Str: String): Int64;
begin
Result := Int64(StrToInt64(Str));
end;

//==============================================================================

procedure TUNSNodeInt64.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt64.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt64.ExchangeActualAndDefault;
var
  Temp: Int64;
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

Function TUNSNodeInt64.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt64.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt64.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt64.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt64.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteInt64(Stream,fDefaultValue)
else
  Stream_WriteInt64(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt64.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadInt64(Stream))
else
  SetValue(Stream_ReadInt64(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt64.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteInt64(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteInt64(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt64.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadInt64(Buffer.Memory))
    else
      SetValue(Ptr_ReadInt64(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.
