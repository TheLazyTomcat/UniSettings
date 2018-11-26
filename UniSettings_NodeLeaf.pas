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
    Function GetValueSize(AccessDefVal: Integer): TMemSize; virtual; abstract;
    Function ConvToStr(const Value): String; virtual; abstract;
    Function ConvFromStr(const Str: String): Pointer; virtual; abstract;
  public
    class Function IsPrimitiveArray: Boolean; virtual;
    Function GetValueAddress(AccessDefVal: Boolean = False): Pointer; virtual; abstract;
    Function GetValueAsString(AccessDefVal: Boolean = False): String; virtual; abstract;
    procedure SetValueFromString(const Str: String; AccessDefVal: Boolean = False); virtual; abstract;
    procedure GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False); virtual; abstract;
    procedure SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False); virtual; abstract;
    Function GetValueAsStream(AccessDefVal: Boolean = False): TMemoryStream; virtual;
    procedure GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual; abstract;
    procedure SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual; abstract;
    Function GetValueAsBuffer(AccessDefVal: Boolean = False): TMemoryBuffer; virtual; 
    property ValueSize: TMemSize index 1 read GetValueSize;
    property DefaultValueSize: TMemSize index 0 read GetValueSize;
  end;

implementation

class Function TUNSNodeLeaf.GetNodeClass: TUNSNodeClass;
begin
Result := ncLeaf;
end;

//==============================================================================

class Function TUNSNodeLeaf.IsPrimitiveArray: Boolean;
begin
Result := False;
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.GetValueAsStream(AccessDefVal: Boolean = False): TMemoryStream;
begin
Result := TMemoryStream.Create;
GetValueToStream(Result,AccessDefVal);
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.GetValueAsBuffer(AccessDefVal: Boolean = False): TMemoryBuffer;
begin
GetBuffer(Result,GetValueSize(Ord(AccessDefVal)));
GetValuetoBuffer(Result,AccessDefVal);
end;

end.
