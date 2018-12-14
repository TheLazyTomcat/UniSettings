{$IFNDEF Included}
unit UniSettings_NodeUInt16;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeUInt16 = class(TUNSNodeLeaf)
  private
    fValue:         UInt16;
    fSavedValue:    UInt16;
    fDefaultValue:  UInt16;
    procedure SetValue(NewValue: UInt16);
    procedure SetDefaultValue(NewValue: UInt16);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: UInt16): String; reintroduce;
    Function ConvFromStr(const Str: String): UInt16; reintroduce;
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
    property Value: UInt16 read fValue write SetValue;
    property SavedValue: UInt16 read fSavedValue;
    property DefaultValue: UInt16 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;

procedure TUNSNodeUInt16.SetValue(NewValue: UInt16);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.SetDefaultValue(NewValue: UInt16);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeUInt16.GetValueType: TUNSValueType;
begin
Result := vtUInt16;
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.GetValueSize: TMemSize;
begin
Result := SizeOf(UInt16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(UInt16);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.ConvToStr(Value: UInt16): String;
begin
If ValueFormatSettings.HexIntegers then
  Result := '$' + IntToHex(Value,4)
else
  Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.ConvFromStr(const Str: String): UInt16;
begin
Result := UInt16(StrToInt(Str));
end;

//==============================================================================

constructor TUNSNodeUInt16.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := 0;
fSavedValue := 0;
fDefaultValue := 0;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeUInt16.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeUInt16(Source).Value;
fSavedValue := TUNSNodeUInt16(Source).SavedValue;
fDefaultValue := TUNSNodeUInt16(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.ExchangeActualAndDefault;
var
  Temp: UInt16;
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

Function TUNSNodeUInt16.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.Save;
begin
fSavedValue := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeUInt16.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteUInt16(Stream,fDefaultValue)
else
  Stream_WriteUInt16(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadUInt16(Stream))
else
  SetValue(Stream_ReadUInt16(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteUInt16(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteUInt16(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeUInt16.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadUInt16(Buffer.Memory))
    else
      SetValue(Ptr_ReadUInt16(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function UInt16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt16; virtual;
    procedure UInt16ValueSet(const ValueName: String; NewValue: UInt16; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.UInt16ValueGet(const ValueName: String; AccessDefVal: Boolean = False): UInt16;
begin
ReadLock;
try
  with TUNSNodeUInt16(CheckedLeafNodeTypeAccess(ValueName,vtUInt16,'UInt16ValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.UInt16ValueSet(const ValueName: String; NewValue: UInt16; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeUInt16(CheckedLeafNodeTypeAccess(ValueName,vtUInt16,'UInt16ValueSet')) do
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
