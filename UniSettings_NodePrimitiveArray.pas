unit UniSettings_NodePrimitiveArray;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  UniSettings_NodeLeaf;

type
  TUNSNodePrimitiveArray = class(TUNSNodeLeaf)
  protected
    class Function GetValueItemSize: TMemSize; virtual; abstract;
  public
    class Function IsPrimitiveArray: Boolean; override;
    destructor Destroy; override;
    Function ActualFromDefault(Index: Integer): Boolean; overload; virtual; abstract;
    Function DefaultFromActual(Index: Integer): Boolean; overload; virtual; abstract;
    Function ExchangeActualAndDefault(Index: Integer): Boolean; overload; virtual; abstract;
    Function ActualEqualsDefault(Index: Integer): Boolean; overload; virtual; abstract;
    Function GetValueItemAddress(Index: Integer; AccessDefVal: Boolean = False): Pointer; virtual; abstract;
    Function GetValueItemAsString(Index: Integer; AccessDefVal: Boolean = False): String; virtual; abstract;
    procedure SetValueItemFromString(Index: Integer; const Str: String; AccessDefVal: Boolean = False); virtual; abstract;
    procedure GetValueItemToStream(Index: Integer; Stream: TStream; AccessDefVal: Boolean = False); virtual; abstract;
    procedure SetValueItemFromStream(Index: Integer; Stream: TStream; AccessDefVal: Boolean = False); virtual; abstract;
    Function GetValueItemAsStream(Index: Integer; AccessDefVal: Boolean = False): TMemoryStream; virtual; abstract;
    Function GetValueItemToBuffer(Index: Integer; Buffer: Pointer; Size: TMemSize; AccessDefVal: Boolean = False): TMemSize; virtual; abstract;
    procedure SetValueItemFromBuffer(Index: Integer; Buffer: Pointer; Size: TMemSize; AccessDefVal: Boolean = False); virtual; abstract;
    Function GetValueItemAsBuffer(Index: Integer; out Buffer: Pointer; AccessDefVal: Boolean = False): TMemSize; virtual; abstract;

    Function ValueLowIndex(AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function ValueHighIndex(AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function ValueCheckIndex(Index: Integer; AccessDefVal: Boolean = False): Boolean; virtual;

    Function ValueIndexOf(const Item; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function ValueAdd(const Item; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function ValueAppend(const Items; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function ValueInsert(Index: Integer; const Item; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    procedure ValueExchange(Index1,Index2: Integer; AccessDefVal: Boolean = False); virtual; abstract;
    procedure ValueMove(SrcIndex,DstIndex: Integer; AccessDefVal: Boolean = False); virtual; abstract;
    Function ValueRemove(const Item; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    procedure ValueDelete(Index: Integer; AccessDefVal: Boolean = False); virtual; abstract;
    procedure ValueClear(AccessDefVal: Boolean = False); virtual; abstract;
    property ValueItemSize: TMemSize read GetValueItemSize;
  end;

implementation

class Function TUNSNodePrimitiveArray.IsPrimitiveArray: Boolean;
begin
Result := True;
end;

//------------------------------------------------------------------------------

destructor TUNSNodePrimitiveArray.Destroy;
begin
ValueClear(True);
ValueClear(False);
inherited;
end;

//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.ValueCheckIndex(Index: Integer; AccessDefVal: Boolean = False): Boolean;
begin
Result := (Index >= ValueLowIndex(AccessDefVal)) and (Index <= ValueHighIndex(AccessDefVal));
end;

end.
