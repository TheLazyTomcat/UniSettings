unit UniSettings_NodeUInt32;

{$INCLUDE '.\UniSettings_defs.inc'}

interface         

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeUInt32 = class(TUNSNodeLeaf)
  private
    fValue:         UInt32;
    fDefaultValue:  UInt32;
    procedure SetValue(NewValue: UInt32);
    procedure SetDefaultValue(NewValue: UInt32);
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
    property Value: UInt32 read fValue write SetValue;
    property DefaultValue: UInt32 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeUInt32.SetValue(NewValue: UInt32);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.SetDefaultValue(NewValue: UInt32);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeUInt32.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtUInt32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(UInt32);
end;

//==============================================================================

procedure TUNSNodeUInt32.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.ExchangeActualAndDefault;
var
  Temp: UInt32;
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

Function TUNSNodeUInt32.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := IntToStr(fDefaultValue)
else
  Result := IntToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(UInt32(StrToInt64(Str)))
else
  SetValue(UInt32(StrToInt64(Str)));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteUInt32(Stream,fDefaultValue)
else
  Stream_WriteUInt32(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadUInt32(Stream))
else
  SetValue(Stream_ReadUInt32(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteUInt32(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteUInt32(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadUInt32(Buffer.Memory))
    else
      SetValue(Ptr_ReadUInt32(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.
