{$IFNDEF Included}
unit UniSettings_NodeBool;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeBool = class(TUNSNodeLeaf)
  private
    fValue:         Boolean;
    fDefaultValue:  Boolean;
    procedure SetValue(NewValue: Boolean);
    procedure SetDefaultValue(NewValue: Boolean);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(Value: Boolean): String; reintroduce;
    Function ConvFromStr(const Str: String): Boolean; reintroduce;
  public
    constructor CreateCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
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
    property Value: Boolean read fValue write SetValue;
    property DefaultValue: Boolean read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
  UniSettings_Exceptions;   

procedure TUNSNodeBool.SetValue(NewValue: Boolean);
begin
If NewValue <> fValue then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetDefaultValue(NewValue: Boolean);
begin
If NewValue <> fDefaultValue then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeBool.GetValueType: TUNSValueType;
begin
Result := vtBool;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueSize: TMemSize;
begin
Result := SizeOf(ByteBool);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(ByteBool);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.ConvToStr(Value: Boolean): String;
begin
If ValueFormatSettings.NumericBools then
  Result := IntToStr(Ord(Value))
else
  Result := BoolToStr(Value,True);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.ConvFromStr(const Str: String): Boolean;
begin
Result := StrToBool(Str);
end;

//==============================================================================

constructor TUNSNodeBool.CreateCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateCopy(Source,Name,ParentNode);
fValue := TUNSNodeBool(Source).Value;
fDefaultValue := TUNSNodeBool(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.ExchangeActualAndDefault;
var
  Temp: Boolean;
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

Function TUNSNodeBool.ActualEqualsDefault: Boolean;
begin
Result := fValue = fDefaultValue;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := ConvToStr(fDefaultValue)
else
  Result := ConvToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(ConvFromStr(Str))
else
  SetValue(ConvFromStr(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteBool(Stream,fDefaultValue)
else
  Stream_WriteBool(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadBool(Stream))
else
  SetValue(Stream_ReadBool(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteBool(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteBool(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadBool(Buffer.Memory))
    else
      SetValue(Ptr_ReadBool(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function BooleanValueGet(const ValueName: String; AccessDefVal: Boolean = False): Boolean; virtual;
    procedure BooleanValueSet(const ValueName: String; NewValue: Boolean; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.BooleanValueGet(const ValueName: String; AccessDefVal: Boolean = False): Boolean;
begin
ReadLock;
try
  with TUNSNodeBool(CheckedLeafNodeTypeAccess(ValueName,vtBool,'BooleanValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BooleanValueSet(const ValueName: String; NewValue: Boolean; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  with TUNSNodeBool(CheckedLeafNodeTypeAccess(ValueName,vtBool,'BooleanValueSet')) do
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
