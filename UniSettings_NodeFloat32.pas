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
    property Value: Float32 read fValue write SetValue;
    property DefaultValue: Float32 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
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

class Function TUNSNodeFloat32.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtFloat32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat32.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(Float32);
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

Function TUNSNodeFloat32.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeFloat32.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := FloatToStr(fDefaultValue)
else
  Result := FloatToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(StrToFloat(Str))
else
  SetValue(StrToFloat(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat32(Stream,fDefaultValue)
else
  Stream_WriteFloat32(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadFloat32(Stream))
else
  SetValue(Stream_ReadFloat32(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat32(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteFloat32(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeFloat32.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadFloat32(Buffer.Memory))
    else
      SetValue(Ptr_ReadFloat32(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.
