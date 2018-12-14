{$IFNDEF Included}
unit UniSettings_NodeUInt8;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeUInt8 = class(TUNSNodeLeaf)
  private
    fValue:         UInt8;
    fDefaultValue:  UInt8;
    procedure SetValue(NewValue: UInt8);
    procedure SetDefaultValue(NewValue: UInt8);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: UInt8): String; reintroduce;
    Function ConvFromStr(const Str: String): UInt8; reintroduce;
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
    property Value: UInt8 read fValue write SetValue;
    property DefaultValue: UInt8 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeUInt8.SetValue(NewValue: UInt8);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.SetDefaultValue(NewValue: UInt8);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeUInt8.GetValueType: TUNSValueType;
begin
Result := vtUInt8;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.GetValueSize: TMemSize;
begin
Result := SizeOf(UInt8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(UInt8);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.ConvToStr(Value: UInt8): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,2)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.ConvFromStr(const Str: String): UInt8;
begin
Result := UInt8(StrToInt(Str));
end;

//==============================================================================

procedure TUNSNodeUInt8.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.ExchangeActualAndDefault;
var
  Temp: UInt8;
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

Function TUNSNodeUInt8.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt8.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteUInt8(Stream,fDefaultValue)
else
  Stream_WriteUInt8(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadUInt8(Stream))
else
  SetValue(Stream_ReadUInt8(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteUInt8(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteUInt8(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt8.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadUInt8(Buffer.Memory))
    else
      SetValue(Ptr_ReadUInt8(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function UInt8ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt8; virtual;
    procedure UInt8ValueSet(const ValueName: String; NewValue: UInt8; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt8ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt8;
begin
ReadLock;
try
  with TUNSNodeUInt8(CheckedLeafNodeTypeAccess(ValueName,vtUInt8,'UInt8ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt8ValueSet(const ValueName: String; NewValue: UInt8; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeUInt8(CheckedLeafNodeTypeAccess(ValueName,vtUInt8,'UInt8ValueSet')) do
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
