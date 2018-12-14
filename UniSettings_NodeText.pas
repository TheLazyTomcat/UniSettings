{$IFNDEF Included}
unit UniSettings_NodeText;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeText = class(TUNSNodeLeaf)
  private
    fValue:         String;
    fSavedValue:    String;
    fDefaultValue:  String;
    procedure SetValue(NewValue: String);
    procedure SetDefaultValue(NewValue: String);
  protected
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(const Value): String; override;
    Function ConvFromStr(const Str: String): Pointer; override;
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
    property Value: String read fValue write SetValue;
    property SavedValue: String read fSavedValue;
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

Function TUNSNodeText.GetValueSize: TMemSize;
begin
Result := SizeOf(Int32) + Length(StrToUTF8(fValue)) * SizeOf(UTF8Char);
end;

//------------------------------------------------------------------------------

Function TUNSNodeText.GetDefaultValueSize: TMemSize;
begin
Result := SizeOf(Int32) + Length(StrToUTF8(fDefaultValue)) * SizeOf(UTF8Char);
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

constructor TUNSNodeText.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fValue := '';
fSavedValue := '';
fDefaultValue := '';
end;

//------------------------------------------------------------------------------

constructor TUNSNodeText.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
fValue := TUNSNodeText(Source).Value;
fSavedValue := TUNSNodeText(Source).SavedValue;
fDefaultValue := TUNSNodeText(Source).DefaultValue;
end;

//------------------------------------------------------------------------------

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

procedure TUNSNodeText.Save;
begin
fSavedValue := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeText.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := PChar(fDefaultValue)
else
  Result := PChar(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeText.AsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := fDefaultValue
else
  Result := fValue;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Str)
else
  SetValue(Str);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteString(Stream,fDefaultValue)
else
  Stream_WriteString(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadString(Stream))
else
  SetValue(Stream_ReadString(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteString(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteString(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeText.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
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
  with TUNSNodeText(CheckedLeafNodeTypeAccess(ValueName,vtText,'TextValueGet')) do
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
  with TUNSNodeText(CheckedLeafNodeTypeAccess(ValueName,vtText,'TextValueSet')) do
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
