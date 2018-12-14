unit UniSettings_NodePrimitiveArray;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodePrimitiveArray = class(TUNSNodeLeaf)
  protected
    Function GetValueCount: Integer;
    Function GetValueItemSize(Index: Integer): TMemSize; virtual; abstract;
    Function GetSavedValueItemSize(Index: Integer): TMemSize; virtual; abstract;
    Function GetDefaultValueItemSize(Index: Integer): TMemSize; virtual; abstract;
    procedure ClearSaved; virtual; abstract;
  public
    class Function IsPrimitiveArray: Boolean; override;
    destructor Destroy; override;
    Function ItemActualFromDefault(Index: Integer): Boolean; overload; virtual; abstract;
    Function ItemDefaultFromActual(Index: Integer): Boolean; overload; virtual; abstract;
    Function ItemExchangeActualAndDefault(Index: Integer): Boolean; overload; virtual; abstract;
    Function ItemActualEqualsDefault(Index: Integer): Boolean; overload; virtual; abstract;
    
    Function ItemAddress(Index: Integer; AccessDefVal: Boolean = False): Pointer; virtual; abstract;
    Function ItemAsString(Index: Integer; AccessDefVal: Boolean = False): String; virtual; abstract;
    procedure ItemFromString(Index: Integer; const Str: String; AccessDefVal: Boolean = False); virtual; abstract;
    procedure ItemToStream(Index: Integer; Stream: TStream; AccessDefVal: Boolean = False); virtual; abstract;
    procedure ItemFromStream(Index: Integer; Stream: TStream; AccessDefVal: Boolean = False); virtual; abstract;
    Function ItemAsStream(Index: Integer; AccessDefVal: Boolean = False): TMemoryStream; virtual; abstract;
    procedure ItemToBuffer(Index: Integer; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual; abstract;
    procedure ItemFromBuffer(Index: Integer; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual; abstract;
    Function ItemAsBuffer(Index: Integer; AccessDefVal: Boolean = False): TMemoryBuffer; virtual; abstract;

    Function LowIndex(AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function HighIndex(AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function CheckIndex(Index: Integer; AccessDefVal: Boolean = False): Boolean; virtual;

    Function IndexOf(const Item; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function Add(const Item; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function Append(const Items; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    Function Insert(Index: Integer; const Item; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    procedure Exchange(Index1,Index2: Integer; AccessDefVal: Boolean = False); virtual; abstract;
    procedure Move(SrcIndex,DstIndex: Integer; AccessDefVal: Boolean = False); virtual; abstract;
    Function Remove(const Item; AccessDefVal: Boolean = False): Integer; virtual; abstract;
    procedure Delete(Index: Integer; AccessDefVal: Boolean = False); virtual; abstract;
    procedure Clear(AccessDefVal: Boolean = False); virtual; abstract;

    property ItemSize[Index: Integer]: TMemSize read GetValueItemSize;
    property SavedItemSize[Index: Integer]: TMemSize read GetSavedValueItemSize;
    property DefaultValueItemSize[Index: Integer]: TMemSize read GetDefaultValueItemSize;

    property Count: Integer read GetValueCount;
    property SavedCount: Integer read GetValueCount;
    property DefaultCount: Integer read GetValueCount;
  end;

implementation

Function TUNSNodePrimitiveArray.GetValueCount: Integer;
begin
// this method is only a placeholder!
Result := 0;
end;

//==============================================================================

class Function TUNSNodePrimitiveArray.IsPrimitiveArray: Boolean;
begin
Result := True;
end;

//------------------------------------------------------------------------------

destructor TUNSNodePrimitiveArray.Destroy;
begin
Clear(True);
ClearSaved;
Clear(False);
inherited;
end;

//------------------------------------------------------------------------------

Function TUNSNodePrimitiveArray.CheckIndex(Index: Integer; AccessDefVal: Boolean = False): Boolean;
begin
Result := (Index >= LowIndex(AccessDefVal)) and (Index <= HighIndex(AccessDefVal));
end;

end.
