unit UniSettings_NodeTime;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeTime = class(TUNSNodeLeaf)
  private
    fValue:         TTime;
    fDefaultValue:  TTime;
    procedure SetValue(NewValue: TTime);
    procedure SetDefaultValue(NewValue: TTime);
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
    property Value: TTime read fValue write SetValue;
    property DefaultValue: TTime read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming,
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

class Function TUNSNodeTime.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtTime;
end;

//------------------------------------------------------------------------------

Function TUNSNodeTime.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := SizeOf(TTime);
end;

//==============================================================================

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

Function TUNSNodeTime.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeTime.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
If AccessDefVal then
  Result := TimeToStr(fDefaultValue)
else
  Result := TimeToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(StrToTime(Str))
else
  SetValue(StrToTime(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteFloat64(Stream,Frac(fDefaultValue))
else
  Stream_WriteFloat64(Stream,Frac(fValue));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  SetDefaultValue(Frac(Stream_ReadFloat64(Stream)))
else
  SetValue(Frac(Stream_ReadFloat64(Stream)));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteFloat64(Buffer.Memory,Frac(fDefaultValue))
    else
      Ptr_WriteFloat64(Buffer.Memory,Frac(fValue));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeTime.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      SetDefaultValue(Frac(Ptr_ReadFloat64(Buffer.Memory)))
    else
      SetValue(Frac(Ptr_ReadFloat64(Buffer.Memory)));
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'SetValueFromBuffer');
end;

end.
