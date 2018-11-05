unit UniSettings_NodeDateTime;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeDateTime = class(TUNSNodeLeaf)
  private
    fValue:         TDateTime;
    fDefaultValue:  TDateTime;
    procedure SetValue(NewValue: TDateTime);
    procedure SetDefaultValue(NewValue: TDateTime);
  protected
    class Function GetNodeDataType: TUNSNodeDataType; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
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
    property Value: TDateTime read fValue write SetValue;
    property DefaultValue: TDateTime read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeDateTime.SetValue(NewValue: TDateTime);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.SetDefaultValue(NewValue: TDateTime);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeDateTime.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtDateTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(TDateTime);
end;

//==============================================================================

procedure TUNSNodeDateTime.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.ExchangeActualAndDefault;
var
  Temp: TDateTime;
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

Function TUNSNodeDateTime.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := DateTimeToStr(fDefaultValue)
else
  Result := DateTimeToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(StrToDateTime(Str))
else
  SetValue(StrToDateTime(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat64(Stream,fDefaultValue)
else
  Stream_WriteFloat64(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadFloat64(Stream))
else
  SetValue(Stream_ReadFloat64(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat64(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteFloat64(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadFloat64(Buffer.Memory))
    else
      SetValue(Ptr_ReadFloat64(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.
