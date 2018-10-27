unit UniSettings_NodeBool;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
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
  public
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    Function GetValueAddress(DefaultValue: Boolean = False): Pointer; override;
    Function GetValueAsString(DefaultValue: Boolean = False): String; override;
    procedure SetValueFromString(const Str: String; DefaultValue: Boolean = False); override;
    procedure GetValueToStream(Stream: TStream; DefaultValue: Boolean = False); override;
    procedure SetValueFromStream(Stream: TStream; DefaultValue: Boolean = False); override;
    Function GetValueAsStream(DefaultValue: Boolean = False): TMemoryStream; override;
    Function GetValueToBuffer(const Buffer; Size: TMemSize; DefaultValue: Boolean = False): TMemSize; override;
    procedure SetValueFromBuffer(const Buffer: Pointer; const Size: TMemSize; DefaultValue: Boolean = False); override;
    Function GetValueAsBuffer(out Buffer: Pointer; DefaultValue: Boolean = False): TMemSize; override;
    property Value: Boolean read fValue write SetValue;
    property DefaultValue: Boolean read fDefaultValue write SetDefaultValue; 
  end;

implementation

uses
  SysUtils,
  BinaryStreaming;

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

Function TUNSNodeBool.GetValueAddress(DefaultValue: Boolean = False): Pointer;
begin
If DefaultValue then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueAsString(DefaultValue: Boolean = False): String;
begin
If DefaultValue then
  Result := BoolToStr(fDefaultValue,True)
else
  Result := BoolToStr(fValue,True);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetValueFromString(const Str: String; DefaultValue: Boolean = False);
begin
If DefaultValue then
  SetDefaultValue(StrToBool(Str))
else
  SetValue(StrToBool(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.GetValueToStream(Stream: TStream; DefaultValue: Boolean = False);
begin
If DefaultValue then
  Stream_WriteBoolean(Stream,fDefaultValue)
else
  Stream_WriteBoolean(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetValueFromStream(Stream: TStream; DefaultValue: Boolean = False);
begin
If DefaultValue then
  SetDefaultValue(Stream_ReadBool(Stream))
else
  SetValue(Stream_ReadBool(Stream));
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueAsStream(DefaultValue: Boolean = False): TMemoryStream;
begin
Result := TMemoryStream.Create;
GetValueToStream(Result,DefaultValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueToBuffer(const Buffer; Size: TMemSize; DefaultValue: Boolean = False): TMemSize;
begin
If Size >= SizeOf(ByteBool) then
  begin
    If DefaultValue then
      Result := Ptr_WriteBoolean(@Buffer,fDefaultValue)
    else
      Result := Ptr_WriteBoolean(@Buffer,fValue);
  end
else raise Exception.CreateFmt('TUNSNodeBool.GetValueToBuffer: Provided buffer is too small (%d).',[Size]);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBool.SetValueFromBuffer(const Buffer: Pointer; const Size: TMemSize; DefaultValue: Boolean = False);
begin
If Size >= SizeOf(ByteBool) then
  begin
    If DefaultValue then
      SetDefaultValue(Ptr_ReadBool(@Buffer))
    else
      SetValue(Ptr_ReadBool(@Buffer));
  end
else raise Exception.CreateFmt('TUNSNodeBool.SetValueFromBuffer: Provided buffer is too small (%d).',[Size]);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBool.GetValueAsBuffer(out Buffer: Pointer; DefaultValue: Boolean = False): TMemSize;
begin
Result := SizeOf(ByteBool);
GetMem(Buffer,Result);
GetValueToBuffer(Buffer,Result,DefaultValue);
end;

end.
