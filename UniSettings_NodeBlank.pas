unit UniSettings_NodeBlank;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeBlank = class(TUNSNodeLeaf)
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
  end;

implementation

class Function TUNSNodeBlank.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtBlank;
end;

//==============================================================================

procedure TUNSNodeBlank.ActualFromDefault;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.DefaultFromActual;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.ExchangeActualAndDefault;
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.ActualEqualsDefault: Boolean;
begin
Result := True;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetValueAddress(DefaultValue: Boolean = False): Pointer;
begin
Result := nil;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetValueAsString(DefaultValue: Boolean = False): String;
begin
Result := '';
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.SetValueFromString(const Str: String; DefaultValue: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.GetValueToStream(Stream: TStream; DefaultValue: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.SetValueFromStream(Stream: TStream; DefaultValue: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetValueAsStream(DefaultValue: Boolean = False): TMemoryStream;
begin
Result := TMemoryStream.Create;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetValueToBuffer(const Buffer; Size: TMemSize; DefaultValue: Boolean = False): TMemSize;
begin
Result := 0;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.SetValueFromBuffer(const Buffer: Pointer; const Size: TMemSize; DefaultValue: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetValueAsBuffer(out Buffer: Pointer; DefaultValue: Boolean = False): TMemSize;
begin
Buffer := nil;
Result := 0;
end;

end.
