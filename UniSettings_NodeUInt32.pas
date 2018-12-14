{$IFNDEF Included}
unit UniSettings_NodeUInt32;

{$INCLUDE '.\UniSettings_defs.inc'}

interface         

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeUInt32 = class(TUNSNodeLeaf)
  private
    fValue:         UInt32;
    fSavedValue:    UInt32;
    fDefaultValue:  UInt32;
    procedure SetValue(NewValue: UInt32);
    procedure SetDefaultValue(NewValue: UInt32);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: UInt32): String; reintroduce;
    Function ConvFromStr(const Str: String): UInt32; reintroduce;
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
    property Value: UInt32 read fValue write SetValue;
    property SavedValue: UInt32 read fSavedValue;
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

class Function TUNSNodeUInt32.GetValueType: TUNSValueType;
begin
Result := vtUInt32;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.GetValueSize: TMemSize;
begin
Result := SizeOf(UInt32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(UInt32);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.ConvToStr(Value: UInt32): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,8)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.ConvFromStr(const Str: String): UInt32;
begin
Result := UInt32(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeUInt32.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeUInt32.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeUInt32(Source).Value;
fSavedValue := TUNSNodeUInt32(Source).SavedValue;
fDefaultValue := TUNSNodeUInt32(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

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

procedure TUNSNodeUInt32.Save;
begin
fSavedValue := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt32.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteUInt32(Stream,fDefaultValue)
else
  Stream_WriteUInt32(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadUInt32(Stream))
else
  SetValue(Stream_ReadUInt32(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteUInt32(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteUInt32(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt32.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadUInt32(Buffer.Memory))
    else
      SetValue(Ptr_ReadUInt32(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function UInt32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt32; virtual;
    procedure UInt32ValueSet(const ValueName: String; NewValue: UInt32; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt32ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt32;
begin
ReadLock;
try
  with TUNSNodeUInt32(CheckedLeafNodeTypeAccess(ValueName,vtUInt32,'UInt32ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt32ValueSet(const ValueName: String; NewValue: UInt32; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeUInt32(CheckedLeafNodeTypeAccess(ValueName,vtUInt32,'UInt32ValueSet')) do
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
