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
    Function GetSavedValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(const Value): String; override;
    Function ConvFromStr(const Str: String): Pointer; override;
  public
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    procedure Save; override;
    procedure Restore; override;
    Function Address(ValueKind: TUNSValueKind = vkActual): Pointer; override;
    Function AsString(ValueKind: TUNSValueKind = vkActual): String; override;
    procedure FromString(const Str: String; ValueKind: TUNSValueKind = vkActual); override;
    procedure ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual); override;
    procedure FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual); override;
    procedure ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); override;
    procedure FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); override;
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

Function TUNSNodeBlank.GetSavedValueSize: TMemSize;
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

procedure TUNSNodeBlank.Save;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.Restore;
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.Address(ValueKind: TUNSValueKind = vkActual): Pointer;
begin
Result := nil;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.AsString(ValueKind: TUNSValueKind = vkActual): String;
begin
Result := '';
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.FromString(const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
// do nothing;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
// do nothing
end;

end.
