{$IFNDEF Included}
unit UniSettings_NodeInt16;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeInt16 = class(TUNSNodeLeaf)
  private
    fValue:         Int16;
    fSavedValue:    Int16;
    fDefaultValue:  Int16;
    procedure SetValue(NewValue: Int16);
    procedure SetDefaultValue(NewValue: Int16);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: Int16): String; reintroduce;
    Function ConvFromStr(const Str: String): Int16; reintroduce;
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
    property Value: Int16 read fValue write SetValue;
    property SavedValue: Int16 read fSavedValue;
    property DefaultValue: Int16 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeInt16.SetValue(NewValue: Int16);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.SetDefaultValue(NewValue: Int16);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeInt16.GetValueType: TUNSValueType;
begin
Result := vtInt16;
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.GetValueSize: TMemSize;
begin
Result := SizeOf(Int16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(Int16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.ConvToStr(Value: Int16): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,4)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.ConvFromStr(const Str: String): Int16;
begin
Result := Int16(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeInt16.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeInt16.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeInt16(Source).Value;
fSavedValue := TUNSNodeInt16(Source).SavedValue;
fDefaultValue := TUNSNodeInt16(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.ExchangeActualAndDefault;
var
  Temp: Int16;
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

Function TUNSNodeInt16.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.Save;
begin
fSavedValue := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt16.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteInt16(Stream,fDefaultValue)
else
  Stream_WriteInt16(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadInt16(Stream))
else
  SetValue(Stream_ReadInt16(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteInt16(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteInt16(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt16.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadInt16(Buffer.Memory))
    else
      SetValue(Ptr_ReadInt16(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function Int16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int16; virtual;
    procedure Int16ValueSet(const ValueName: String; NewValue: Int16; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.Int16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): Int16;
begin
ReadLock;
try
  with TUNSNodeInt16(CheckedLeafNodeTypeAccess(ValueName,vtInt16,'Int16ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Int16ValueSet(const ValueName: String; NewValue: Int16; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeInt16(CheckedLeafNodeTypeAccess(ValueName,vtInt16,'Int16ValueSet')) do
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
