unit UniSettings_NodeBlank;

{$INCLUDE '.\UniSettings_defs.inc'}
{$DEFINE UNS_NodeBlank}

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
    procedure ValueKindMove(Src,Dest: TUNSValueKind); override;
    procedure ValueKindExchange(ValA,ValB: TUNSValueKind); override;
    Function ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean; override;
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

procedure TUNSNodeBlank.ValueKindMove(Src,Dest: TUNSValueKind);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBlank.ValueKindExchange(ValA,ValB: TUNSValueKind);
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TUNSNodeBlank.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
Result := True;
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
