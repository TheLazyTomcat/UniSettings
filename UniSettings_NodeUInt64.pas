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

class Function TUNSNodeUInt64.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtUInt64;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(UInt64);
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

Function TUNSNodeUInt64.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt64.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := IntToStr(fDefaultValue)
else
  Result := IntToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(UInt64(StrToInt64(Str)))
else
  SetValue(UInt64(StrToInt64(Str)));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteUInt64(Stream,fDefaultValue)
else
  Stream_WriteUInt64(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadUInt64(Stream))
else
  SetValue(Stream_ReadUInt64(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteUInt64(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteUInt64(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt64.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadUInt64(Buffer.Memory))
    else
      SetValue(Ptr_ReadUInt64(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.
