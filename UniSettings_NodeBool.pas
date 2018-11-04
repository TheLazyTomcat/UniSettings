unit UniSettings_NodeBool;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeBool = class(TUNSNodeLeaf)
  private
    fValue:         Boolean;
    fDefaultValue:  Boolean;
    procedure SetValue(NewValue: Boolean);
    procedure SetDefaultValue(NewValue: Boolean); 
  protected
    class Function GetNodeDataType: TUNSNodeDataType; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
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

class Function TUNSNodeBool.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtBool;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(ByteBool);
end;

//==============================================================================

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
Result := fValue = fDefaultValue
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := BoolToStr(fDefaultValue,True)
else
  Result := BoolToStr(fValue,True);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(StrToBool(Str))
else
  SetValue(StrToBool(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteBool(Stream,fDefaultValue)
else
  Stream_WriteBool(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Stream_ReadBool(Stream))
else
  SetValue(Stream_ReadBool(Stream));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteBool(Buffer.Memory,fDefaultValue)
    else
      Ptr_WriteBool(Buffer.Memory,fValue);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Ptr_ReadBool(Buffer.Memory))
    else
      SetValue(Ptr_ReadBool(Buffer.Memory));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;


end.
