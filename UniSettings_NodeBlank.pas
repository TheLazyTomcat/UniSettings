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
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(const Value): String; override;
    Function ConvFromStr(const Str: String): Pointer; override;
  public
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
  end;

implementation

class Function TUNSNodeBlank.GetValueType: TUNSValueType;
begin
Result := vtBlank;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetValueSize: TMemSize;
begin
Result := 0;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.GetDefaultValueSize: TMemSize;
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

Function TUNSNodeBlank.Address(AccessDefVal: Boolean = False): Pointer;
begin
Result := nil;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.AsString(AccessDefVal: Boolean = False): String;
begin
Result := '';
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.FromString(const Str: String; AccessDefVal: Boolean = False);
begin
// do nothing;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
// do nothing
end;

end.
