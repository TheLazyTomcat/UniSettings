unit UniSettings_NodeDate;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeDate = class(TUNSNodeLeaf)
  private
    fValue:         TDate;
    fDefaultValue:  TDate;
    procedure SetValue(NewValue: TDate);
    procedure SetDefaultValue(NewValue: TDate);
  protected
    class Function GetNodeDataType: TUNSNodeDataType; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
    Function ConvToStr(Value: TDate): String; reintroduce;
    Function ConvFromStr(const Str: String): TDate; reintroduce;
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
    property Value: TDate read fValue write SetValue;
    property DefaultValue: TDate read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

procedure TUNSNodeDate.SetValue(NewValue: TDate);
begin
If Int(NewValue) <> Int(fValue) then
  begin
    fValue := Int(NewValue);
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.SetDefaultValue(NewValue: TDate);
begin
If Int(NewValue) <> Int(fDefaultValue) then
  begin
    fDefaultValue := Int(NewValue);
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeDate.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtDate;
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(TDate);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.ConvToStr(Value: TDate): String;
begin
If not FormatSettings.HexDateTime then
  Result := DateToStr(Value,fSysFormatSettings)
else
  Result := '$' + DoubleToHex(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.ConvFromStr(const Str: String): TDate;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToDate(Str,fSysFormatSettings);
  end
else Result := StrToDate(Str,fSysFormatSettings);
end;

//==============================================================================

procedure TUNSNodeDate.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.ExchangeActualAndDefault;
var
  Temp: TDate;
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

Function TUNSNodeDate.ActualEqualsDefault: Boolean;
begin
Result := Int(fValue) = Int(fDefaultValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat64(Stream,Int(fDefaultValue))
else
  Stream_WriteFloat64(Stream,Int(fValue));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Int(Stream_ReadFloat64(Stream)))
else
  SetValue(Int(Stream_ReadFloat64(Stream)));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat64(Buffer.Memory,Int(fDefaultValue))
    else
      Ptr_WriteFloat64(Buffer.Memory,Int(fValue));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Int(Ptr_ReadFloat64(Buffer.Memory)))
    else
      SetValue(Int(Ptr_ReadFloat64(Buffer.Memory)));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.

