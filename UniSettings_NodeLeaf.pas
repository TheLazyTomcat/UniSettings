unit UniSettings_NodeLeaf;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils, Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase;

type
  TUNSNodeLeaf = class(TUNSNodeBase)
  protected
    class Function GetNodeClass: TUNSNodeClass; override;
    Function GetValueSize: TMemSize; virtual; abstract;
    Function GetDefaultValueSize: TMemSize; virtual; abstract;
    Function ConvToStr(const Value): String; virtual; abstract;
    Function ConvFromStr(const Str: String): Pointer; virtual; abstract;
    Function ObtainValueSize(AccessDefVal: Boolean): TMemSize; virtual;
  public
    class Function IsPrimitiveArray: Boolean; virtual;
    Function Address(AccessDefVal: Boolean = False): Pointer; virtual; abstract;
    Function AsString(AccessDefVal: Boolean = False): String; virtual; abstract;
    procedure FromString(const Str: String; AccessDefVal: Boolean = False); virtual; abstract;
    procedure ToStream(Stream: TStream; AccessDefVal: Boolean = False); virtual; abstract;
    procedure FromStream(Stream: TStream; AccessDefVal: Boolean = False); virtual; abstract;
    Function AsStream(AccessDefVal: Boolean = False): TMemoryStream; virtual;
    procedure ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual; abstract;
    procedure FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual; abstract;
    Function AsBuffer(AccessDefVal: Boolean = False): TMemoryBuffer; virtual; 
    property ValueSize: TMemSize read GetValueSize;
    property DefaultValueSize: TMemSize read GetDefaultValueSize;
  end;

implementation

class Function TUNSNodeLeaf.GetNodeClass: TUNSNodeClass;
begin
Result := ncLeaf;
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.ObtainValueSize(AccessDefVal: Boolean): TMemSize;
begin
If AccessDefVal then
  Result := GetDefaultValueSize
else
  Result := GetValueSize;
end;

//==============================================================================

class Function TUNSNodeLeaf.IsPrimitiveArray: Boolean;
begin
Result := False;
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.AsStream(AccessDefVal: Boolean = False): TMemoryStream;
begin
Result := TMemoryStream.Create;
ToStream(Result,AccessDefVal);
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.AsBuffer(AccessDefVal: Boolean = False): TMemoryBuffer;
begin
If AccessDefVal then
  GetBuffer(Result,GetDefaultValueSize)
else
  GetBuffer(Result,GetValueSize);
ToBuffer(Result,AccessDefVal);
end;

end.
