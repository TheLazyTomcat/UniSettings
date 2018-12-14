{$IFNDEF Included}
unit UniSettings_NodeDate;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeDate = class(TUNSNodeLeaf)
  private
    fValue:         TDate;
    fSavedValue:    TDate;
    fDefaultValue:  TDate;
    procedure SetValue(NewValue: TDate);
    procedure SetDefaultValue(NewValue: TDate);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: TDate): String; reintroduce;
    Function ConvFromStr(const Str: String): TDate; reintroduce;
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
    property Value: TDate read fValue write SetValue;
    property SavedValue: TDate read fSavedValue;
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

class Function TUNSNodeDate.GetValueType: TUNSValueType;
begin
Result := vtDate;
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.GetValueSize: TMemSize;
begin
Result := SizeOf(TDate);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(TDate);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.ConvToStr(Value: TDate): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := DateToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.ConvFromStr(const Str: String): TDate;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToDate(Str,fConvSettings);
  end
else Result := StrToDate(Str,fConvSettings);
end;

//==============================================================================

constructor TUNSNodeDate.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := Now;
fSavedValue := fValue;
fDefaultValue := fValue;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeDate.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeDate(Source).Value;
fSavedValue := TUNSNodeDate(Source).SavedValue;
fDefaultValue := TUNSNodeDate(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

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

procedure TUNSNodeDate.Save;
begin
fSavedValue := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeDate.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat64(Stream,Int(fDefaultValue))
else
  Stream_WriteFloat64(Stream,Int(fValue));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Int(Stream_ReadFloat64(Stream)))
else
  SetValue(Int(Stream_ReadFloat64(Stream)));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat64(Buffer.Memory,Int(fDefaultValue))
    else
      Ptr_WriteFloat64(Buffer.Memory,Int(fValue));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeDate.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Int(Ptr_ReadFloat64(Buffer.Memory)))
    else
      SetValue(Int(Ptr_ReadFloat64(Buffer.Memory)));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function DateValueGet(const ValueName: String; AccessDefVal: Boolean = False): TDate; virtual;
    procedure DateValueSet(const ValueName: String; NewValue: TDate; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.DateValueGet(const ValueName: String; AccessDefVal: Boolean = False): TDate;
begin
ReadLock;
try
  with TUNSNodeDate(CheckedLeafNodeTypeAccess(ValueName,vtDate,'DateValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DateValueSet(const ValueName: String; NewValue: TDate; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeDate(CheckedLeafNodeTypeAccess(ValueName,vtDate,'DateValueSet')) do
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
