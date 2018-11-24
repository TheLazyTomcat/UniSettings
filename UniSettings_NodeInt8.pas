unit UniSettings_NodeInt8;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeInt8 = class(TUNSNodeLeaf)
  private
    fValue:         Int8;
    fDefaultValue:  Int8;
    procedure SetValue(NewValue: Int8);
    procedure SetDefaultValue(NewValue: Int8);
  protected
    class Function GetNodeDataType: TUNSNodeDataType; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
    Function ConvToStr(Value: Int8): String; reintroduce;
    Function ConvFromStr(const Str: String): Int8; reintroduce;
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
    property Value: Int8 read fValue write SetValue;
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

procedure TUNSNodeInt8.SetDefaultValue(NewValue: Int8);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeInt8.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtInt8;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(Int8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.ConvToStr(Value: Int8): String;
begin
If FormatSettings.HexIntegers then
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

procedure TUNSNodeInt8.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.ExchangeActualAndDefault;
var
  Temp: Int8;
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

Function TUNSNodeInt8.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt8.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteInt8(Stream,fDefaultValue)
else
  Stream_WriteInt8(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadInt8(Stream))
else
  SetValue(Stream_ReadInt8(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteInt8(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteInt8(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt8.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadInt8(Buffer.Memory))
    else
      SetValue(Ptr_ReadInt8(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.