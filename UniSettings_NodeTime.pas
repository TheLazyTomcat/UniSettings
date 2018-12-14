{$IFNDEF Included}
unit UniSettings_NodeTime;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeTime = class(TUNSNodeLeaf)
  private
    fValue:         TTime;
    fSavedValue:    TTime;
    fDefaultValue:  TTime;
    procedure SetValue(NewValue: TTime);
    procedure SetDefaultValue(NewValue: TTime);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: TTime): String; reintroduce;
    Function ConvFromStr(const Str: String): TTime; reintroduce;
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
    property Value: TTime read fValue write SetValue;
    property SavedValue: TTime read fSavedValue;
    property DefaultValue: TTime read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, FloatHex,
  UniSettings_Exceptions;

procedure TUNSNodeTime.SetValue(NewValue: TTime);
begin
If Frac(NewValue) <> Frac(fValue) then
  begin
    fValue := Frac(NewValue);
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.SetDefaultValue(NewValue: TTime);
begin
If Frac(NewValue) <> Frac(fDefaultValue) then
  begin
    fDefaultValue := Frac(NewValue);
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeTime.GetValueType: TUNSValueType;
begin
Result := vtTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeTime.GetValueSize: TMemSize;
begin
Result := SizeOf(TTime);
end;

//------------------------------------------------------------------------------

Function TUNSNodeTime.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(TTime);
end;


//------------------------------------------------------------------------------

Function TUNSNodeTime.ConvToStr(Value: TTime): String;
begin
If ValueFormatSettings.HexDateTime then
  Result := '$' + DoubleToHex(Value)
else
  Result := TimeToStr(Value,fConvSettings);
end;

//------------------------------------------------------------------------------

Function TUNSNodeTime.ConvFromStr(const Str: String): TTime;
begin
If Length(Str) > 1 then
  begin
    If Str[1] = '$' then
      Result := HexToDouble(Str)
    else
      Result := StrToTime(Str,fConvSettings);
  end
else Result := StrToTime(Str,fConvSettings);
end;

//==============================================================================

constructor TUNSNodeTime.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := Now;
fSavedValue := fValue;
fDefaultValue := fValue;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeTime.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeTime(Source).Value;
fSavedValue := TUNSNodeTime(Source).SavedValue;
fDefaultValue := TUNSNodeTime(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.ExchangeActualAndDefault;
var
  Temp: TTime;
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

Function TUNSNodeTime.ActualEqualsDefault: Boolean;
begin
Result := Frac(fValue) = Frac(fDefaultValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.Save;
begin
fSavedValue := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeTime.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeTime.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat64(Stream,Frac(fDefaultValue))
else
  Stream_WriteFloat64(Stream,Frac(fValue));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Frac(Stream_ReadFloat64(Stream)))
else
  SetValue(Frac(Stream_ReadFloat64(Stream)));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat64(Buffer.Memory,Frac(fDefaultValue))
    else
      Ptr_WriteFloat64(Buffer.Memory,Frac(fValue));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Frac(Ptr_ReadFloat64(Buffer.Memory)))
    else
      SetValue(Frac(Ptr_ReadFloat64(Buffer.Memory)));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function TimeValueGet(const ValueName: String; AccessDefVal: Boolean = False): TTime; virtual;
    procedure TimeValueSet(const ValueName: String; NewValue: TTime; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.TimeValueGet(const ValueName: String; AccessDefVal: Boolean = False): TTime;
begin
ReadLock;
try
  with TUNSNodeTime(CheckedLeafNodeTypeAccess(ValueName,vtTime,'TimeValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TimeValueSet(const ValueName: String; NewValue: TTime; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeTime(CheckedLeafNodeTypeAccess(ValueName,vtTime,'TimeValueSet')) do
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
