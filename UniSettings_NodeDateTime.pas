{$IFNDEF Included}
unit UniSettings_NodeDateTime;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeDateTime = class(TUNSNodeLeaf)
  private
    fValue:         TDateTime;
    fSavedValue:    TDateTime;
    fDefaultValue:  TDateTime;
    procedure SetValue(NewValue: TDateTime);
    procedure SetDefaultValue(NewValue: TDateTime);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: TDateTime): String; reintroduce;
    Function ConvFromStr(const Str: String): TDateTime; reintroduce;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    constructor CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    procedure Save; override;
    procedure Restore; override;
    Function Address(AccessDefVal: Boolean = False): Pointer; override;
    Function AsString(AccessDefVal: Boolean = False): String; override;
    procedure FromString(const Str: String; AccessDefVal: Boolean = False); override;
    procedure ToStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure FromStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    procedure FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    property Value: TDateTime read fValue write SetValue;
    property SavedValue: TDateTime read fSavedValue;
    property DefaultValue: TDateTime read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
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

class Function TUNSNodeDateTime.GetValueType: TUNSValueType;
begin
Result := vtDateTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.GetValueSize: TMemSize;
begin
Result := SizeOf(TDateTime);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(TDateTime);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.ConvToStr(Value: TDateTime): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateTimeToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.ConvFromStr(const Str: String): TDateTime;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToDateTime(Str,fConvSettings);
  end
else Result := StrToDateTime(Str,fConvSettings);
end;

//==============================================================================

constructor TUNSNodeDateTime.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := Now;
fSavedValue := fValue;
fDefaultValue := fValue;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeDateTime.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeDateTime(Source).Value;
fSavedValue := TUNSNodeDateTime(Source).SavedValue;
fDefaultValue := TUNSNodeDateTime(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

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

procedure TUNSNodeDateTime.Save;
begin
fSavedValue := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDateTime.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat64(Stream,fDefaultValue)
else
  Stream_WriteFloat64(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadFloat64(Stream))
else
  SetValue(Stream_ReadFloat64(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat64(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteFloat64(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDateTime.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadFloat64(Buffer.Memory))
    else
      SetValue(Ptr_ReadFloat64(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function DateTimeValueGet(const ValueName: String; AccessDefVal: Boolean = False): TDateTime; virtual;
    procedure DateTimeValueSet(const ValueName: String; NewValue: TDateTime; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.DateTimeValueGet(const ValueName: String; AccessDefVal: Boolean = False): TDateTime;
begin
ReadLock;
try
  with TUNSNodeDateTime(CheckedLeafNodeTypeAccess(ValueName,vtDateTime,'DateTimeValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateTimeValueSet(const ValueName: String; NewValue: TDateTime; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeDateTime(CheckedLeafNodeTypeAccess(ValueName,vtDateTime,'DateTimeValueSet')) do
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
