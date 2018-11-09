unit UniSettings_NodeBlank;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeBlank = class(TUNSNodeLeaf)
  protected
    class Function GetNodeDataType: TUNSNodeDataType; override;
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
  end;

implementation

class Function TUNSNodeBlank.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtBlank;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
Result := 0;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.ConvToStr(const Value): String;
begin
Result := '';
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.ConvFromStr(const Str: String): Pointer;
begin
Result := nil;
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

Function TUNSNodeBlank.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
Result := nil;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetValueAsString(AccessDefVal: Boolean = False): String;
begin
Result := '';
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
begin
// do nothing;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
// do nothing
end;

end.
