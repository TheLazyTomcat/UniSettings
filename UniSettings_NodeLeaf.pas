unit UniSettings_NodeLeaf;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  UniSettings_Common, UniSettings_NodeBase;

type
  TUNSNodeLeaf = class(TUNSNodeBase)
  protected
    class Function GetNodeClass: TUNSNodeClass; override;
  public
    class Function IsPrimitiveArray: Boolean; virtual;
    Function GetValueAddress(DefaultValue: Boolean = False): Pointer; virtual; abstract;
    Function GetValueAsString(DefaultValue: Boolean = False): String; virtual; abstract;
    procedure SetValueFromString(const Str: String; DefaultValue: Boolean = False); virtual; abstract;
    procedure GetValueToStream(Stream: TStream; DefaultValue: Boolean = False); virtual; abstract;
    procedure SetValueFromStream(Stream: TStream; DefaultValue: Boolean = False); virtual; abstract;
    Function GetValueAsStream(DefaultValue: Boolean = False): TMemoryStream; virtual; abstract;
    Function GetValueToBuffer(const Buffer; Size: TMemSize; DefaultValue: Boolean = False): TMemSize; virtual; abstract;
    procedure SetValueFromBuffer(const Buffer: Pointer; const Size: TMemSize; DefaultValue: Boolean = False); virtual; abstract;
    Function GetValueAsBuffer(out Buffer: Pointer; DefaultValue: Boolean = False): TMemSize; virtual; abstract;
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

end.
