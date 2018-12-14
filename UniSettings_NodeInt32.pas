{$IFNDEF Included}
unit UniSettings_NodeInt32;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeInt32 = class(TUNSNodeLeaf)
  private
    fValue:         Int32;
    fSavedValue:    Int32;
    fDefaultValue:  Int32;
    procedure SetValue(NewValue: Int32);
    procedure SetDefaultValue(NewValue: Int32);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: Int32): String; reintroduce;
    Function ConvFromStr(const Str: String): Int32; reintroduce;
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
    property Value: Int32 read fValue write SetValue;
    property SavedValue: Int32 read fSavedValue;
    property DefaultValue: Int32 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeInt32.SetValue(NewValue: Int32);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.SetDefaultValue(NewValue: Int32);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeInt32.GetValueType: TUNSValueType;
begin
Result := vtInt32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.GetValueSize: TMemSize;
begin
Result := SizeOf(Int32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(Int32);
end;        

//------------------------------------------------------------------------------

Function TUNSNodeInt32.ConvToStr(Value: Int32): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,8)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.ConvFromStr(const Str: String): Int32;
begin
Result := Int32(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeInt32.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeInt32.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeInt32(Source).Value;
fSavedValue := TUNSNodeInt32(Source).SavedValue;
fDefaultValue := TUNSNodeInt32(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.ExchangeActualAndDefault;
var
  Temp: Int32;
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

Function TUNSNodeInt32.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.Save;
begin
fSavedValue := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteInt32(Stream,fDefaultValue)
else
  Stream_WriteInt32(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadInt32(Stream))
else
  SetValue(Stream_ReadInt32(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteInt32(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteInt32(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadInt32(Buffer.Memory))
    else
      SetValue(Ptr_ReadInt32(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end; 

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function Int32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int32; virtual;
    procedure Int32ValueSet(const ValueName: String; NewValue: Int32; AccessDefVal: Boolean = False); virtual;
    Function IntegerValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int32; virtual;
    procedure IntegerValueSet(const ValueName: String; NewValue: Int32; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Int32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int32;
begin
ReadLock;
try
  with TUNSNodeInt32(CheckedLeafNodeTypeAccess(ValueName,vtBool,'Int32ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int32ValueSet(const ValueName: String; NewValue: Int32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeInt32(CheckedLeafNodeTypeAccess(ValueName,vtInt32,'Int32ValueSet')) do
    If AccessDefVal then
      Value := NewValue
    else
      DefaultValue := NewValue;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.IntegerValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int32;
begin
ReadLock;
try
  with TUNSNodeInt32(CheckedLeafNodeTypeAccess(ValueName,vtInteger,'IntegerValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.IntegerValueSet(const ValueName: String; NewValue: Int32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeInt32(CheckedLeafNodeTypeAccess(ValueName,vtInteger,'IntegerValueSet')) do
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
