unit UniSettings_NodeInt16;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeInt16 = class(TUNSNodeLeaf)
  private
    fValue:         Int16;
    fDefaultValue:  Int16;
    procedure SetValue(NewValue: Int16);
    procedure SetDefaultValue(NewValue: Int16);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
    Function ConvToStr(Value: Int16): String; reintroduce;
    Function ConvFromStr(const Str: String): Int16; reintroduce;
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
    property Value: Int16 read fValue write SetValue;
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

Function TUNSNodeInt16.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(Int16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.ConvToStr(Value: Int16): String;
begin
If FormatSettings.HexIntegers then
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

procedure TUNSNodeInt16.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.ExchangeActualAndDefault;
var
  Temp: Int16;
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

Function TUNSNodeInt16.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteInt16(Stream,fDefaultValue)
else
  Stream_WriteInt16(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadInt16(Stream))
else
  SetValue(Stream_ReadInt16(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteInt16(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteInt16(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadInt16(Buffer.Memory))
    else
      SetValue(Ptr_ReadInt16(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.
