{$IFNDEF Included}
unit UniSettings_NodeText;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeText = class(TUNSNodeLeaf)
  private
    fValue:         String;
    fDefaultValue:  String;
    procedure SetValue(NewValue: String);
    procedure SetDefaultValue(NewValue: String);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
    Function ConvToStr(const Value): String; override;
    Function ConvFromStr(const Str: String): Pointer; override;
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
    property Value: String read fValue write SetValue;
    property DefaultValue: String read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect,
  UniSettings_Exceptions;

procedure TUNSNodeText.SetValue(NewValue: String);
begin
If not AnsiSameStr(NewValue,fValue) then
  begin
    fValue := NewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.SetDefaultValue(NewValue: String);
begin
If not AnsiSameStr(NewValue,fDefaultValue) then
  begin
    fDefaultValue := NewValue;
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeText.GetValueType: TUNSValueType;
begin
Result := vtText;
end;

//------------------------------------------------------------------------------

Function TUNSNodeText.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
If AccessDefVal <> 0 then
  Result := SizeOf(Int32) + Length(StrToUTF8(fDefaultValue)) * SizeOf(UTF8Char)
else
  Result := SizeOf(Int32) + Length(StrToUTF8(fValue)) * SizeOf(UTF8Char)
end;

//------------------------------------------------------------------------------

Function TUNSNodeText.ConvToStr(const Value): String;
begin
Result := '';
end;

//------------------------------------------------------------------------------

Function TUNSNodeText.ConvFromStr(const Str: String): Pointer;
begin
Result := nil;
end;

//==============================================================================

procedure TUNSNodeText.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    fValue := fDefaultValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    fDefaultValue := fValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.ExchangeActualAndDefault;
var
  Temp: String;
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

Function TUNSNodeText.ActualEqualsDefault: Boolean;
begin
Result := AnsiSameStr(fValue,fDefaultValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeText.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := PChar(fDefaultValue)
else
  Result := PChar(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeText.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := fDefaultValue
else
  Result := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Str)
else
  SetValue(Str);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteString(Stream,fDefaultValue)
else
  Stream_WriteString(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadString(Stream))
else
  SetValue(Stream_ReadString(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteString(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteString(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= SizeOf(Int32) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadString(Buffer.Memory))
    else
      SetValue(Ptr_ReadString(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function TextValueGet(const ValueName: String; ThreadSafe: Boolean = True; AccessDefVal: Boolean = False): String; virtual;
    procedure TextValueSet(const ValueName: String; NewValue: String; ThreadSafe: Boolean = True; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.TextValueGet(const ValueName: String; ThreadSafe: Boolean = True; AccessDefVal: Boolean = False): String;
begin
ReadLock;
try
  with TUNSNodeText(CheckedLeafNodeTypeAccess(ValueName,vtBool,'TextValueGet')) do
    If AccessDefVal then
      Result := Value
    else
      Result := DefaultValue;
  If ThreadSafe then
    UniqueString(Result);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.TextValueSet(const ValueName: String; NewValue: String; ThreadSafe: Boolean = True; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  If ThreadSafe then
    UniqueString(NewValue);
  with TUNSNodeText(CheckedLeafNodeTypeAccess(ValueName,vtBool,'TextValueSet')) do
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
