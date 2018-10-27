unit UniSettings_NodeInt32;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeInt32 = class(TUNSNodeLeaf)
  private
    fValue:         Int32;
    fDefaultValue:  Int32;
    procedure SetValue(NewValue: Int32);
    procedure SetDefaultValue(NewValue: Int32);
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
    property Value: Int32 read fValue write SetValue;
    property DefaultValue: Int32 read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming;

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

class Function TUNSNodeInt32.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtInt32;
end;

//==============================================================================

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
Result := fValue = fDefaultValue
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.GetValueAddress(DefaultValue: Boolean = False): Pointer;
begin
If DefaultValue then
  Result := Addr(fDefaultValue)
else
  Result := Addr(fValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.GetValueAsString(DefaultValue: Boolean = False): String;
begin
If DefaultValue then
  Result := IntToStr(fDefaultValue)
else
  Result := IntToStr(fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.SetValueFromString(const Str: String; DefaultValue: Boolean = False);
begin
If DefaultValue then
  SetDefaultValue(StrToInt(Str))
else
  SetValue(StrToInt(Str));
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.GetValueToStream(Stream: TStream; DefaultValue: Boolean = False);
begin
If DefaultValue then
  Stream_WriteInt32(Stream,fDefaultValue)
else
  Stream_WriteInt32(Stream,fValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.SetValueFromStream(Stream: TStream; DefaultValue: Boolean = False);
begin
If DefaultValue then
  SetDefaultValue(Stream_ReadInt32(Stream))
else
  SetValue(Stream_ReadInt32(Stream));
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.GetValueAsStream(DefaultValue: Boolean = False): TMemoryStream;
begin
Result := TMemoryStream.Create;
GetValueToStream(Result,DefaultValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.GetValueToBuffer(const Buffer; Size: TMemSize; DefaultValue: Boolean = False): TMemSize;
begin
If Size >= SizeOf(ByteBool) then
  begin
    If DefaultValue then
      Result := Ptr_WriteInt32(@Buffer,fDefaultValue)
    else
      Result := Ptr_WriteInt32(@Buffer,fValue);
  end
else raise Exception.CreateFmt('TUNSNodeInt32.GetValueToBuffer: Provided buffer is too small (%d).',[Size]);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeInt32.SetValueFromBuffer(const Buffer: Pointer; const Size: TMemSize; DefaultValue: Boolean = False);
begin
If Size >= SizeOf(ByteBool) then
  begin
    If DefaultValue then
      SetDefaultValue(Ptr_ReadInt32(@Buffer))
    else
      SetValue(Ptr_ReadInt32(@Buffer));
  end
else raise Exception.CreateFmt('TUNSNodeInt32.SetValueFromBuffer: Provided buffer is too small (%d).',[Size]);
end;

//------------------------------------------------------------------------------

Function TUNSNodeInt32.GetValueAsBuffer(out Buffer: Pointer; DefaultValue: Boolean = False): TMemSize;
begin
Result := SizeOf(Int32);
GetMem(Buffer,Result);
GetValueToBuffer(Buffer,Result,DefaultValue);
end;

end.
