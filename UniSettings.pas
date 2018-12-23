(*
todo (* = completed):

* tree building
  IO
* arrays
* array nodes: listsorters -> implementation uses
* access to array items trough index in value name
* name parts -> CDA
* TUniSettings copy constructor
* make copies thread safe
* integer can be 64bit...
* per value change tracking (rework change system)
* remove flags from values (let's leave them there for now)
* remove IS where possible, replace with node type checks
* remove IsPrimitiveArray method
* hashes (branch list, node list)
  hashed node list in US
* replace direct access to cd arrays with CDA_GetItemPtr
* ToString/FromString - en(/de)code strings, do not do it in lexer

* nodes

*   Move(Src, Dest);
*   Exchange(A,B);
*   Compare(A,B): Boolean;
*   Equals(Node; ValType): Boolean;

* copy constructor(s)
* value save-restore system (saved value read only)
* explicit value initialization

* buffers - free replaced buffers (eg. def->curr and v.v.)
* unify nomenclature
* replacing blank nodes
*)
unit UniSettings;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils, Classes,
  AuxTypes, AuxClasses, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray, UniSettings_NodeBranch,
  UniSettings_ScriptParser;

type
  TUNSNode = TUNSNodeBase;

  TUniSettings = class(TObject)
  private
    fValueFormatSettings: TUNSValueFormatSettings;
    fSynchronizer:        TMultiReadExclusiveWriteSynchronizer;
    fRootNode:            TUNSNodeBranch;
    fWorkingBranch:       String;
    fWorkingNode:         TUNSNodeBranch;
    fParser:              TUNSParser;
    fAdditionCounter:     Integer;
    fChangeCounter:       Integer;
    fChanged:             Boolean;
    fOnTreeChange:        TNotifyEvent;
    fOnTreeChangeCB:      TNotifyCallback;
    fOnValueChange:       TStringEvent;
    fOnValueChangeCB:     TStringCallback;
    Function GetValueFormatSettings: TUNSValueFormatSettings;
    Function GetValueFormatSettingBool(Index: Integer): Boolean;
    procedure SetValueFormatSettingBool(Index: Integer; Value: Boolean);
    Function GetWorkingBranch: String;
    procedure SetWorkingBranch(const Branch: String);
  protected
    Function CreateLeafNode(ValueType: TUNSValueType; const NodeName: String; ParentNode: TUNSNodeBranch): TUNSNodeLeaf; virtual;
    Function GetSubNode(NodeNamePart: TUNSNamePart; Branch: TUNSNodeBranch; out Node: TUNSNode; CanCreateArrayItem: Boolean): Boolean; virtual;
    Function ConstructBranch(NodeNameParts: TUNSNameParts): TUNSNodeBranch; virtual;
    Function AddNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean; virtual;
    Function FindNode(NodeNameParts: TUNSNameParts): TUNSNode; virtual;    
    Function FindLeafNode(const NodeName: String; out Node: TUNSNodeLeaf): Boolean; overload; virtual;
    Function FindLeafNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean; overload; virtual;
    Function CheckedLeafNodeAccess(const NodeName, Caller: String): TUNSNodeLeaf; virtual;
    Function CheckedLeafArrayNodeAccess(const NodeName, Caller: String): TUNSNodePrimitiveArray; virtual;
    Function CheckedLeafNodeTypeAccess(const NodeName: String; ValueType: TUNSValueType; const Caller: String): TUNSNodeLeaf; virtual;
    Function CheckedLeafNodeAccessIsArray(const NodeName, Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean; virtual;
    Function CheckedLeafNodeTypeAccessIsArray(const NodeName: String; ValueType: TUNSValueType; const Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean; virtual;
    procedure ConstructionInitialization; virtual;
    procedure BeginChanging;
    procedure EndChanging;
    procedure OnNodeChangeHandler(Sender: TObject; Node: TUNSNodeBase); virtual;
    constructor Create(RootNode: TUNSNodeBranch); overload;
  public
    constructor Create; overload;
    constructor CreateAsCopy(Source: TUniSettings);
    Function CreateCopy: TUniSettings; virtual;
    destructor Destroy; override;
    //--- Locking --------------------------------------------------------------
    procedure ReadLock; virtual;
    procedure ReadUnlock; virtual;
    procedure WriteLock; virtual;
    procedure WriteUnlock; virtual;
    procedure Lock; virtual;
    procedure Unlock; virtual;
    //--- Tree construction (no lock) ------------------------------------------
    procedure ConstructFromLineNoLock(const Line: String); virtual;
    procedure ConstructFromLinesNoLock(Lines: TStrings); virtual;
    procedure ConstructFromTextNoLock(const Text: String); virtual;
    procedure ConstructFromStreamNoLock(Stream: TStream); virtual;
    procedure ConstructFromCompressedStreamNoLock(Stream: TStream); virtual;
    procedure ConstructFromFileNoLock(const FileName: String); virtual;
    procedure ConstructFromCompressedFileNoLock(const FileName: String); virtual;
    procedure ConstructFromResourceNoLock(const ResourceName: String); virtual;
    procedure ConstructFromCompressedResourceNoLock(const ResourceName: String); virtual;
    procedure AppendFromLineNoLock(const Line: String); virtual;
    procedure AppendFromLinesNoLock(Lines: TStrings); virtual;
    procedure AppendFromTextNoLock(const Text: String); virtual;
    procedure AppendFromStreamNoLock(Stream: TStream); virtual;
    procedure AppendFromCompressedStreamNoLock(Stream: TStream); virtual;
    procedure AppendFromFileNoLock(const FileName: String); virtual;
    procedure AppendFromCompressedFileNoLock(const FileName: String); virtual;
    procedure AppendFromResourceNoLock(const ResourceName: String); virtual;
    procedure AppendFromCompressedResourceNoLock(const ResourceName: String); virtual;
    //--- Tree construction (lock) ---------------------------------------------
    procedure ConstructFromLine(const Line: String); virtual;
    procedure ConstructFromLines(Lines: TStrings); virtual;
    procedure ConstructFromText(const Text: String); virtual;
    procedure ConstructFromStream(Stream: TStream); virtual;
    procedure ConstructFromCompressedStream(Stream: TStream); virtual;
    procedure ConstructFromFile(const FileName: String); virtual;
    procedure ConstructFromCompressedFile(const FileName: String); virtual;
    procedure ConstructFromResource(const ResourceName: String); virtual;
    procedure ConstructFromCompressedResource(const ResourceName: String); virtual;
    procedure AppendFromLine(const Line: String); virtual;
    procedure AppendFromLines(Lines: TStrings); virtual;
    procedure AppendFromText(const Text: String); virtual;
    procedure AppendFromStream(Stream: TStream); virtual;
    procedure AppendFromCompressedStream(Stream: TStream); virtual;
    procedure AppendFromFile(const FileName: String); virtual;
    procedure AppendFromCompressedFile(const FileName: String); virtual;
    procedure AppendFromResource(const ResourceName: String); virtual;
    procedure AppendFromCompressedResource(const ResourceName: String); virtual;
    //--- IO operations (no lock) ----------------------------------------------
    (*
    SaveToIniNoLock
    LoadFromIniNoLock
    SaveToRegistryNoLock
    LoadFromRegistryNoLock
    *)
    //--- IO operations (lock) -------------------------------------------------
    (*
    SaveToIni
    LoadFromIni
    SaveToRegistry
    LoadFromRegistry
    *)
    //--- Values management (no lock) ------------------------------------------
    Function ExistsNoLock(const ValueName: String): Boolean; virtual;
    Function AddNoLock(const ValueName: String; ValueType: TUNSValueType): Boolean; virtual;
    Function RemoveNoLock(const ValueName: String): Boolean; virtual;
    procedure ClearNoLock; virtual;
    Function ListValuesNoLock(Strings: TStrings; PreserveAdditionOrder: Boolean = False): Integer; virtual;
    //--- Values management (lock) ---------------------------------------------
    Function Exists(const ValueName: String): Boolean; virtual;
    Function Add(const ValueName: String; ValueType: TUNSValueType): Boolean; virtual;
    Function Remove(const ValueName: String): Boolean; virtual;
    procedure Clear; virtual;
    Function ListValues(Strings: TStrings; PreserveAdditionOrder: Boolean = False): Integer; virtual;
    //--- General value access (no lock) ---------------------------------------
    procedure ValueKindMoveNoLock(Src,Dest: TUNSValueKind); virtual;
    procedure ValueKindExchangeNoLock(ValA,ValB: TUNSValueKind); virtual;
    Function ValueKindCompareNoLock(ValA,ValB: TUNSValueKind): Boolean; virtual;
    procedure ActualFromDefaultNoLock; virtual;
    procedure DefaultFromActualNoLock; virtual;
    procedure ExchangeActualAndDefaultNoLock; virtual;
    Function ActualEqualsDefaultNoLock: Boolean; virtual;
    procedure SaveNoLock; virtual;
    procedure RestoreNoLock; virtual;
    Function ValueFullNameNoLock(const ValueName: String): String; virtual;
    Function ValueTypeNoLock(const ValueName: String): TUNSValueType; virtual;
    Function ValueSizeNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemSize; virtual;
    procedure ValueValueKindMoveNoLock(const ValueName: String; Src,Dest: TUNSValueKind); overload; virtual;
    procedure ValueValueKindExchangeNoLock(const ValueName: String; ValA,ValB: TUNSValueKind); overload; virtual;
    Function ValueValueKindCompareNoLock(const ValueName: String; ValA,ValB: TUNSValueKind): Boolean; overload; virtual;
    procedure ValueActualFromDefaultNoLock(const ValueName: String); virtual;
    procedure ValueDefaultFromActualNoLock(const ValueName: String); virtual;
    procedure ValueExchangeActualAndDefaultNoLock(const ValueName: String); virtual;
    Function ValueActualEqualsDefaultNoLock(const ValueName: String): Boolean; virtual;
    procedure ValueSaveNoLock(const ValueName: String); virtual;
    procedure ValueRestoreNoLock(const ValueName: String); virtual;
    Function ValueAddressNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Pointer; virtual;
    Function ValueAsStringNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String; virtual;
    procedure ValueFromStringNoLock(const ValueName: String; const Str: String; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueToStreamNoLock(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueFromStreamNoLock(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual); virtual;
    Function ValueAsStreamNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryStream; virtual;
    procedure ValueToBufferNoLock(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueFromBufferNoLock(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    Function ValueAsBufferNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer; virtual;
    Function ValueCountNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function ValueItemSizeNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemSize; virtual;
    procedure ValueValueKindMoveNoLock(const ValueName: String; Index: Integer; Src,Dest: TUNSValueKind); overload; virtual;
    procedure ValueValueKindExchangeNoLock(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind); overload; virtual;
    Function ValueValueKindCompareNoLock(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind): Boolean; overload; virtual;
    procedure ValueItemActualFromDefaultNoLock(const ValueName: String; Index: Integer); virtual;
    procedure ValueItemDefaultFromActualNoLock(const ValueName: String; Index: Integer); virtual;
    procedure ValueItemExchangeActualAndDefaultNoLock(const ValueName: String; Index: Integer); virtual;
    Function ValueItemActualEqualsDefaultNoLock(const ValueName: String; Index: Integer): Boolean; virtual;
    procedure ValueItemSaveNoLock(const ValueName: String; Index: Integer); virtual;
    procedure ValueItemRestoreNoLock(const ValueName: String; Index: Integer); virtual;
    Function ValueItemAddressNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer; virtual;
    Function ValueItemAsStringNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String; virtual;
    procedure ValueItemFromStringNoLock(const ValueName: String; Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueItemToStreamNoLock(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueItemFromStreamNoLock(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual); virtual;
    Function ValueItemAsStreamNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryStream; virtual;
    procedure ValueItemToBufferNoLock(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueItemFromBufferNoLock(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    Function ValueItemAsBufferNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer; virtual;
    Function ValueLowIndexNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function ValueHighIndexNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function ValueCheckIndexNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure ValueExchangeNoLock(const ValueName: String; Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueMoveNoLock(const ValueName: String; SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueDeleteNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueClearNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual); virtual;
    //--- General value access (lock) ------------------------------------------
    procedure ValueKindMove(Src,Dest: TUNSValueKind); virtual;
    procedure ValueKindExchange(ValA,ValB: TUNSValueKind); virtual;
    Function ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean; virtual;
    procedure ActualFromDefault; virtual;
    procedure DefaultFromActual; virtual;
    procedure ExchangeActualAndDefault; virtual;
    Function ActualEqualsDefault: Boolean; virtual;
    procedure Save; virtual;
    procedure Restore; virtual;
    Function ValueFullName(const ValueName: String): String; virtual;
    Function ValueType(const ValueName: String): TUNSValueType; virtual;
    Function ValueSize(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemSize; virtual;
    procedure ValueValueKindMove(const ValueName: String; Src,Dest: TUNSValueKind); overload; virtual;
    procedure ValueValueKindExchange(const ValueName: String; ValA,ValB: TUNSValueKind); overload; virtual;
    Function ValueValueKindCompare(const ValueName: String; ValA,ValB: TUNSValueKind): Boolean; overload; virtual;
    procedure ValueActualFromDefault(const ValueName: String); virtual;
    procedure ValueDefaultFromActual(const ValueName: String); virtual;
    procedure ValueExchangeActualAndDefault(const ValueName: String); virtual;
    Function ValueActualEqualsDefault(const ValueName: String): Boolean; virtual;
    procedure ValueSave(const ValueName: String); virtual;
    procedure ValueRestore(const ValueName: String); virtual;
    Function ValueAddress(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Pointer; virtual;
    Function ValueAsString(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String; virtual;
    procedure ValueFromString(const ValueName: String; const Str: String; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueToStream(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueFromStream(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual); virtual;
    Function ValueAsStream(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryStream; virtual;
    procedure ValueToBuffer(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueFromBuffer(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    Function ValueAsBuffer(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer; virtual;
    Function ValueCount(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function ValueItemSize(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemSize; virtual;
    procedure ValueValueKindMove(const ValueName: String; Index: Integer; Src,Dest: TUNSValueKind); overload; virtual;
    procedure ValueValueKindExchange(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind); overload; virtual;
    Function ValueValueKindCompare(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind): Boolean; overload; virtual;
    procedure ValueItemActualFromDefault(const ValueName: String; Index: Integer); virtual;
    procedure ValueItemDefaultFromActual(const ValueName: String; Index: Integer); virtual;
    procedure ValueItemExchangeActualAndDefault(const ValueName: String; Index: Integer); virtual;
    Function ValueItemActualEqualsDefault(const ValueName: String; Index: Integer): Boolean; virtual;
    procedure ValueItemSave(const ValueName: String; Index: Integer); virtual;
    procedure ValueItemRestore(const ValueName: String; Index: Integer); virtual;
    Function ValueItemAddress(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer; virtual;
    Function ValueItemAsString(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String; virtual;
    procedure ValueItemFromString(const ValueName: String; Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueItemToStream(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueItemFromStream(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual); virtual;
    Function ValueItemAsStream(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryStream; virtual;
    procedure ValueItemToBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueItemFromBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); virtual;
    Function ValueItemAsBuffer(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer; virtual;
    Function ValueLowIndex(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function ValueHighIndex(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer; virtual;
    Function ValueCheckIndex(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean; virtual;
    procedure ValueExchange(const ValueName: String; Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueMove(const ValueName: String; SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueDelete(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual); virtual;
    procedure ValueClear(const ValueName: String; ValueKind: TUNSValueKind = vkActual); virtual;
    //--- Type-specific value access -------------------------------------------
  {$DEFINE UNS_Included}{$DEFINE UNS_Include_Declaration}
    // simple types
    {$INCLUDE '.\UniSettings_NodeBool.pas'}
    {$INCLUDE '.\UniSettings_NodeInt8.pas'}
    {$INCLUDE '.\UniSettings_NodeUInt8.pas'}
    {$INCLUDE '.\UniSettings_NodeInt16.pas'}
    {$INCLUDE '.\UniSettings_NodeUInt16.pas'}
    {$INCLUDE '.\UniSettings_NodeInt32.pas'}
    {$INCLUDE '.\UniSettings_NodeUInt32.pas'}
    {$INCLUDE '.\UniSettings_NodeInt64.pas'}
    {$INCLUDE '.\UniSettings_NodeUInt64.pas'}
    {$INCLUDE '.\UniSettings_NodeFloat32.pas'}
    {$INCLUDE '.\UniSettings_NodeFloat64.pas'}
    {$INCLUDE '.\UniSettings_NodeDateTime.pas'}
    {$INCLUDE '.\UniSettings_NodeDate.pas'}
    {$INCLUDE '.\UniSettings_NodeTime.pas'}
    {$INCLUDE '.\UniSettings_NodeText.pas'}
    {$INCLUDE '.\UniSettings_NodeBuffer.pas'}
    // array types
    {$INCLUDE '.\UniSettings_NodeAoBool.pas'}
    {$INCLUDE '.\UniSettings_NodeAoInt8.pas'}
    {$INCLUDE '.\UniSettings_NodeAoUInt8.pas'}
    {$INCLUDE '.\UniSettings_NodeAoInt16.pas'}
    {$INCLUDE '.\UniSettings_NodeAoUInt16.pas'}
    {$INCLUDE '.\UniSettings_NodeAoInt32.pas'}
    {$INCLUDE '.\UniSettings_NodeAoUInt32.pas'}
    {$INCLUDE '.\UniSettings_NodeAoInt64.pas'}
    {$INCLUDE '.\UniSettings_NodeAoUInt64.pas'}
    {$INCLUDE '.\UniSettings_NodeAoFloat32.pas'}
    {$INCLUDE '.\UniSettings_NodeAoFloat64.pas'}
    {$INCLUDE '.\UniSettings_NodeAoDateTime.pas'}
    {$INCLUDE '.\UniSettings_NodeAoDate.pas'}
    {$INCLUDE '.\UniSettings_NodeAoTime.pas'}
    {$INCLUDE '.\UniSettings_NodeAoText.pas'}
    {$INCLUDE '.\UniSettings_NodeAoBuffer.pas'}
  {$UNDEF UNS_Include_Declaration}{$UNDEF UNS_Included}
    //--- Properties -----------------------------------------------------------
    property WorkingBranch: String read GetWorkingBranch write SetWorkingBranch;
    //--- Format settings properties -------------------------------------------
    property ValueFormatSettings: TUNSValueFormatSettings read GetValueFormatSettings;
    property NumericBools: Boolean index UNS_VALUEFORMATSETTING_INDEX_NUMBOOL
      read GetValueFormatSettingBool write SetValueFormatSettingBool;
    property HexIntegers: Boolean index UNS_VALUEFORMATSETTING_INDEX_HEXINTS
      read GetValueFormatSettingBool write SetValueFormatSettingBool;
    property HexFloats: Boolean index UNS_VALUEFORMATSETTING_INDEX_HEXFLTS
      read GetValueFormatSettingBool write SetValueFormatSettingBool;
    property HexDateTime: Boolean index UNS_VALUEFORMATSETTING_INDEX_HEXDTTM
      read GetValueFormatSettingBool write SetValueFormatSettingBool;
    //--- Events ---------------------------------------------------------------
    property OnTreeChange: TNotifyEvent read fOnTreeChange write fOnTreeChange;
    property OnTreeChangeEvent: TNotifyEvent read fOnTreeChange write fOnTreeChange;
    property OnTreeChangeCallback: TNotifyCallback read fOnTreeChangeCB write fOnTreeChangeCB;
    property OnValueChange: TStringEvent read fOnValueChange write fOnValueChange;
    property OnValueChangeEvent: TStringEvent read fOnValueChange write fOnValueChange;
    property OnValueChangeCallback: TStringCallback read fOnValueChangeCB write fOnValueChangeCB;
  end;

implementation

uses
  StrRect, ListSorters,
  UniSettings_Utils, UniSettings_Exceptions,
  // leaf nodes
  UniSettings_NodeBlank,
  UniSettings_NodeBool,
  UniSettings_NodeInt8,
  UniSettings_NodeUInt8,
  UniSettings_NodeInt16,
  UniSettings_NodeUInt16,
  UniSettings_NodeInt32,
  UniSettings_NodeUInt32,
  UniSettings_NodeInt64,
  UniSettings_NodeUInt64,
  UniSettings_NodeFloat32,
  UniSettings_NodeFloat64,
  UniSettings_NodeDateTime,
  UniSettings_NodeDate,
  UniSettings_NodeTime,
  UniSettings_NodeText,
  UniSettings_NodeBuffer,
  // leaf array nodes
  UniSettings_NodeAoBool,
  UniSettings_NodeAoInt8,
  UniSettings_NodeAoUInt8,
  UniSettings_NodeAoInt16,
  UniSettings_NodeAoUInt16,
  UniSettings_NodeAoInt32,
  UniSettings_NodeAoUInt32,
  UniSettings_NodeAoInt64,
  UniSettings_NodeAoUInt64,
  UniSettings_NodeAoFloat32,
  UniSettings_NodeAoFloat64,
  UniSettings_NodeAoDateTime,
  UniSettings_NodeAoDate,
  UniSettings_NodeAoTime,
  UniSettings_NodeAoText,
  UniSettings_NodeAoBuffer,
  // branch nodes
  UniSettings_NodeArray,
  UniSettings_NodeArrayItem;

type
  TUNSUniSettingsClass = class of TUniSettings;

Function TUniSettings.GetValueFormatSettings: TUNSValueFormatSettings;
begin
ReadLock;
try
  Result := fValueFormatSettings;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.GetValueFormatSettingBool(Index: Integer): Boolean;
begin
ReadLock;
try
  Result := False;
  case Index of
    UNS_VALUEFORMATSETTING_INDEX_NUMBOOL:  Result := fValueFormatSettings.NumericBools;
    UNS_VALUEFORMATSETTING_INDEX_HEXINTS:  Result := fValueFormatSettings.HexIntegers;
    UNS_VALUEFORMATSETTING_INDEX_HEXFLTS:  Result := fValueFormatSettings.HexFloats;
    UNS_VALUEFORMATSETTING_INDEX_HEXDTTM:  Result := fValueFormatSettings.HexDateTime;
  else
    raise EUNSException.CreateFmt('Invalid value format setting index (%d).',
                                  [Index],Self,'GetValueFormatSettingBool');
  end;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.SetValueFormatSettingBool(Index: Integer; Value: Boolean);
begin
WriteLock;
try
  case Index of
    UNS_VALUEFORMATSETTING_INDEX_NUMBOOL:  fValueFormatSettings.NumericBools := Value;
    UNS_VALUEFORMATSETTING_INDEX_HEXINTS:  fValueFormatSettings.HexIntegers := Value;
    UNS_VALUEFORMATSETTING_INDEX_HEXFLTS:  fValueFormatSettings.HexFloats := Value;
    UNS_VALUEFORMATSETTING_INDEX_HEXDTTM:  fValueFormatSettings.HexDateTime := Value;
  else
    raise EUNSException.CreateFmt('Invalid value format setting index (%d).',
                                  [Index],Self,'SetValueFormatSettingBool');
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.GetWorkingBranch: String;
begin
ReadLock;
try
  Result := fWorkingBranch;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.SetWorkingBranch(const Branch: String);
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNode;
begin
WriteLock;
try
  fWorkingBranch := '';
  fWorkingNode := fRootNode;
  If UNSNameParts(Branch,NameParts) > 0 then
    begin
      Node := FindNode(NameParts);
      If UNSIsBranchNode(Node) then
        begin
          fWorkingBranch := Node.ReconstructFullName(False);
          fWorkingNode := TUNSNodeBranch(Node);
        end;
    end;
finally
  WriteUnlock;
end;
end;

//==============================================================================

Function TUniSettings.CreateLeafNode(ValueType: TUNSValueType; const NodeName: String; ParentNode: TUNSNodeBranch): TUNSNodeLeaf;
begin
case ValueType of
  // simple types
  vtBlank:       Result := TUNSNodeBlank.Create(NodeName,ParentNode);
  vtBool:        Result := TUNSNodeBool.Create(NodeName,ParentNode);
  vtInt8:        Result := TUNSNodeInt8.Create(NodeName,ParentNode);
  vtUInt8:       Result := TUNSNodeUInt8.Create(NodeName,ParentNode);
  vtInt16:       Result := TUNSNodeInt16.Create(NodeName,ParentNode);
  vtUInt16:      Result := TUNSNodeUInt16.Create(NodeName,ParentNode);
  vtInt32:       Result := TUNSNodeInt32.Create(NodeName,ParentNode);
  vtUInt32:      Result := TUNSNodeUInt32.Create(NodeName,ParentNode);
  vtInt64:       Result := TUNSNodeInt64.Create(NodeName,ParentNode);
  vtUInt64:      Result := TUNSNodeUInt64.Create(NodeName,ParentNode);
  vtFloat32:     Result := TUNSNodeFloat32.Create(NodeName,ParentNode);
  vtFloat64:     Result := TUNSNodeFloat64.Create(NodeName,ParentNode);
  vtDate:        Result := TUNSNodeDate.Create(NodeName,ParentNode);
  vtTime:        Result := TUNSNodeTime.Create(NodeName,ParentNode);
  vtDateTime:    Result := TUNSNodeDateTime.Create(NodeName,ParentNode);
  vtText:        Result := TUNSNodeText.Create(NodeName,ParentNode);
  vtBuffer:      Result := TUNSNodeBuffer.Create(NodeName,ParentNode);
  // array types
  vtAoBool:      Result := TUNSNodeAoBool.Create(NodeName,ParentNode);
  vtAoInt8:      Result := TUNSNodeAoInt8.Create(NodeName,ParentNode);
  vtAoUInt8:     Result := TUNSNodeAoUInt8.Create(NodeName,ParentNode);
  vtAoInt16:     Result := TUNSNodeAoInt16.Create(NodeName,ParentNode);
  vtAoUInt16:    Result := TUNSNodeAoUInt16.Create(NodeName,ParentNode);
  vtAoInt32:     Result := TUNSNodeAoInt32.Create(NodeName,ParentNode);
  vtAoUInt32:    Result := TUNSNodeAoUInt32.Create(NodeName,ParentNode);
  vtAoInt64:     Result := TUNSNodeAoInt64.Create(NodeName,ParentNode);
  vtAoUInt64:    Result := TUNSNodeAoUInt64.Create(NodeName,ParentNode);
  vtAoFloat32:   Result := TUNSNodeAoFloat32.Create(NodeName,ParentNode);
  vtAoFloat64:   Result := TUNSNodeAoFloat64.Create(NodeName,ParentNode);
  vtAoDate:      Result := TUNSNodeAoDate.Create(NodeName,ParentNode);
  vtAoTime:      Result := TUNSNodeAoTime.Create(NodeName,ParentNode);
  vtAoDateTime:  Result := TUNSNodeAoDateTime.Create(NodeName,ParentNode);
  vtAoText:      Result := TUNSNodeAoText.Create(NodeName,ParentNode);
  vtAoBuffer:    Result := TUNSNodeAoBuffer.Create(NodeName,ParentNode);
else
 {vtUndefined}
  raise EUNSException.CreateFmt('Invalid node value type (%d).',[Ord(ValueType)],Self,'CreateLeafNode');
end;
Result.AdditionIndex := fAdditionCounter;
Inc(fAdditionCounter);
end;

//------------------------------------------------------------------------------

Function TUniSettings.GetSubNode(NodeNamePart: TUNSNamePart; Branch: TUNSNodeBranch; out Node: TUNSNode; CanCreateArrayItem: Boolean): Boolean;
begin
Node := nil;
case NodeNamePart.PartType of
  nptIdentifier,
  nptArrayIdentifier:
    begin
      Result := Branch.FindNode(NodeNamePart.PartStr,Node,False);
      Exit;
    end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  nptArrayIndex,
  nptArrayIndexSav,
  nptArrayIndexDef:
    If Branch.NodeType = ntArray then
      begin
        If TUNSNodeArray(Branch).CheckIndex(NodeNamePart.PartIndex) then
          Node := TUNSNodeArray(Branch)[NodeNamePart.PartIndex];
      end
    else raise EUNSException.CreateFmt('Invalid name part type (%d) for a given node branch class (%s).',
                 [Ord(NodeNamePart.PartType),Branch.ClassName],Self,'GetSubNode');
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  nptArrayItem,
  nptArrayItemSav,
  nptArrayItemDef:
    begin
      If Branch.NodeType = ntArray then
        case NodeNamePart.PartIndex of
          UNS_NAME_ARRAYITEM_NEW:
            If CanCreateArrayItem then
              begin
                Node := TUNSNodeArrayItem.Create('',Branch);
                TUNSNodeArrayItem(Node).ArrayIndex := Branch.Count;
                Branch.Add(Node);
              end;
          UNS_NAME_ARRAYITEM_LOW:
            If TUNSNodeArray(Branch).Count > 0 then
              Node := TUNSNodeArray(Branch)[TUNSNodeArray(Branch).LowIndex];
          UNS_NAME_ARRAYITEM_HIGH:
            If TUNSNodeArray(Branch).Count > 0 then
              Node := TUNSNodeArray(Branch)[TUNSNodeArray(Branch).HighIndex];
        end
      else raise EUNSException.CreateFmt('Invalid name part type (%d) for a given node branch class (%s).',
                   [Ord(NodeNamePart.PartType),Branch.ClassName],Self,'GetSubNode');
    end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
else
  raise EUNSException.CreateFmt('Invalid name part type (%d).',[Ord(NodeNamePart.PartType)],Self,'GetSubNode');
end;
Result := Assigned(Node);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ConstructBranch(NodeNameParts: TUNSNameParts): TUNSNodeBranch;
var
  CurrentBranch:  TUNSNodeBranch;
  NextNode:       TUNSNode;
  i:              Integer;
  NodeFound:      Boolean;
begin
Result := nil;
If CDA_Count(NodeNameParts) > 0 then
  begin
    If NodeNameParts.Valid then
      begin
        CurrentBranch := fWorkingNode;
        For i := CDA_Low(NodeNameParts) to CDA_High(NodeNameParts) do
          begin
            NodeFound := GetSubNode(CDA_GetItem(NodeNameParts,i),CurrentBranch,NextNode,True);
            If UNSIsLeafNodeOfValueType(NextNode,vtBlank) then
              begin
                CurrentBranch.Remove(NextNode);
                NextNode := nil;
                NodeFound := False;
              end;
            If NodeFound then
              begin
                // node was found
                If not UNSIsBranchNode(NextNode) then
                  begin
                    CurrentBranch := nil;
                    Break{For i};
                  end
                else CurrentBranch := TUNSNodeBranch(NextNode);
              end
            else
              begin
                // node was NOT found, create it
                case CDA_GetItem(NodeNameParts,i).PartType of
                  nptIdentifier:
                    NextNode := TUNSNodeBranch.Create(CDA_GetItem(NodeNameParts,i).PartStr.Str,CurrentBranch);
                  nptArrayIdentifier:
                    NextNode := TUNSNodeArray.Create(CDA_GetItem(NodeNameParts,i).PartStr.Str,CurrentBranch);
                  nptArrayIndex,nptArrayIndexSav,nptArrayIndexDef,
                  nptArrayItem,nptArrayItemSav,nptArrayItemDef:
                    Exit; // array items can only be created in GetSubNode trough the use of [#N] (new array item), so return nil
                else
                  raise EUNSException.CreateFmt('Invalid name part type (%d).',
                    [Ord(CDA_GetItem(NodeNameParts,i).PartType)],Self,'ConstructBranch');
                end;
                CurrentBranch.Add(NextNode);
                CurrentBranch := TUNSNodeBranch(NextNode);
              end;
          end;
        Result := CurrentBranch;
      end
    else raise EUNSException.Create('Invalid name.',Self,'ConstructBranch');
  end
else Result := fWorkingNode;
end;

//------------------------------------------------------------------------------

Function TUniSettings.AddNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean;
var
  NameParts:  TUNSNameParts;
  BranchNode: TUNSNodeBranch;
  Index:      Integer;
begin
Node := nil;
Result := False;
If UNSNameParts(NodeName,NameParts) > 0 then
  // must not end with array index or array item
  If not NameParts.EndsWithIndex then
    begin
      If NamePartsHideLast(NameParts) then
        try
          BranchNode := ConstructBranch(NameParts);
        finally
          NamePartsShowLast(NameParts);
        end
      else BranchNode := nil;
      If Assigned(BranchNode) then
        begin
          Index := BranchNode.IndexOf(CDA_Last(NameParts).PartStr);
          If BranchNode.CheckIndex(Index) then
            If UNSIsLeafNodeOfValueType(BranchNode[Index],vtBlank) then
              begin
                BranchNode.Delete(Index);
                Index := -1;
              end;
          If not BranchNode.CheckIndex(Index) then
            begin
              Node := CreateLeafNode(ValueType,CDA_Last(NameParts).PartStr.Str,BranchNode);
              If BranchNode.CheckIndex(BranchNode.Add(Node)) then
                Result := True
              else
                FreeAndNil(Node);
            end;
        end;
    end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.FindNode(NodeNameParts: TUNSNameParts): TUNSNode;
var
  CurrentNode:  TUNSNode;
  i:            Integer;
begin
Result := nil;
If NodeNameParts.Valid and (CDA_Count(NodeNameParts) > 0) then
  begin
    CurrentNode := fWorkingNode;
    For i := CDA_Low(NodeNameParts) to CDA_High(NodeNameParts) do
      begin
        If UNSIsBranchNode(CurrentNode) then
          begin
            If not GetSubNode(CDA_GetItem(NodeNameParts,i),TUNSNodeBranch(CurrentNode),CurrentNode,False) then
              Exit;
          end
        else Exit;
      end;
    Result := CurrentNode;
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.FindLeafNode(const NodeName: String; out Node: TUNSNodeLeaf): Boolean;
var
  NameParts:  TUNSNameParts;
  FoundNode:  TUNSNode;
begin
Result := False;
Node := nil;
If UNSNameParts(NodeName,NameParts) > 0 then
  begin
    FoundNode := FindNode(NameParts);
    If UNSIsLeafNode(FoundNode) then
      begin
        Node := TUNSNodeLeaf(FoundNode);
        Result := True;
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.FindLeafNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean;
begin
If FindLeafNode(NodeName,Node) then
  Result := Node.ValueType = ValueType
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TUniSettings.CheckedLeafNodeAccess(const NodeName, Caller: String): TUNSNodeLeaf;
begin
If not FindLeafNode(NodeName,Result) then
  raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
end;

//------------------------------------------------------------------------------

Function TUniSettings.CheckedLeafArrayNodeAccess(const NodeName, Caller: String): TUNSNodePrimitiveArray;
var
  Node: TUNSNodeLeaf;
begin
If FindLeafNode(NodeName,Node) then
  begin
    If UNSIsPrimitiveArrayNode(Node) then
      Result := TUNSNodePrimitiveArray(Node)
    else
      raise EUNSValueNotAnArrayException.Create(NodeName,Self,Caller);
  end
else raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
end;

//------------------------------------------------------------------------------

Function TUniSettings.CheckedLeafNodeTypeAccess(const NodeName: String; ValueType: TUNSValueType; const Caller: String): TUNSNodeLeaf;
begin
If FindLeafNode(NodeName,Result) then
  begin
    If Result.ValueType <> ValueType then
      raise EUNSValueTypeNotFoundException.Create(NodeName,ValueType,Self,Caller);
  end
else raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
end;

//------------------------------------------------------------------------------

Function TUniSettings.CheckedLeafNodeAccessIsArray(const NodeName, Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean;
var
  NameParts:  TUNSNameParts;
  FoundNode:  TUNSNode;
begin
Result := False;
Index := -1;
ValueKind := vkActual;
Node := nil;
If UNSNameParts(NodeName,NameParts) > 0 then
  begin
    If NameParts.EndsWithIndex then
      begin
        If NamePartsHideLast(NameParts) then
          try
            FoundNode := FindNode(NameParts);
          finally
            NamePartsShowLast(NameParts);
          end
        else FoundNode := nil;
        If UNSIsPrimitiveArrayNode(FoundNode) then
          begin
            Node := TUNSNodeLeaf(FoundNode);
            // resolve value kind
            case CDA_Last(NameParts).PartType of
              nptArrayIndex,nptArrayItem:       ValueKind := vkActual;
              nptArrayIndexSav,nptArrayItemSav: ValueKind := vkSaved;
              nptArrayIndexDef,nptArrayItemDef: ValueKind := vkDefault;
            else
              raise EUNSException.CreateFmt('Invalid name part type (%d).',
                [Ord(CDA_Last(NameParts).PartType)],Self,Caller);
            end;
            // resolve index
            case CDA_Last(NameParts).PartType of
              nptArrayIndex,
              nptArrayIndexSav,
              nptArrayIndexDef:
                Index := CDA_Last(NameParts).PartIndex;
              nptArrayItem,
              nptArrayItemSav,
              nptArrayItemDef:              
                case CDA_Last(NameParts).PartIndex of
                  UNS_NAME_ARRAYITEM_LOW:
                    Index := TUNSNodePrimitiveArray(Node).LowIndex(ValueKind);
                  UNS_NAME_ARRAYITEM_HIGH:
                    Index := TUNSNodePrimitiveArray(Node).HighIndex(ValueKind);
                else
                  Index := -1;
                end;
            end;
            Result := True;
          end
        else raise EUNSValueNotAnArrayException.Create(NodeName,Self,Caller);
      end
    else
      begin
        FoundNode := FindNode(NameParts);
        If UNSIsLeafNode(FoundNode) then
          Node := TUNSNodeLeaf(FoundNode)
        else
          raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.CheckedLeafNodeTypeAccessIsArray(const NodeName: String; ValueType: TUNSValueType; const Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean;
begin
If CheckedLeafNodeAccessIsArray(NodeName,Caller,Node,ValueKind,Index) then
  begin
    If TUNSNodePrimitiveArray(Node).ItemValueType <> ValueType then
      raise EUNSValueTypeNotFoundException.Create(NodeName,ValueType,Self,Caller);
    Result := True;
  end
else
  begin
    If Node.ValueType <> ValueType then
      raise EUNSValueTypeNotFoundException.Create(NodeName,ValueType,Self,Caller);
    Result := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructionInitialization;
begin
ClearNoLock;
fParser.Initialize;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BeginChanging;
begin
Inc(fChangeCounter);
fChanged := False;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.EndChanging;
begin
Dec(fChangeCounter);
If (fChangeCounter <= 0) and fChanged then
  begin
    fChangeCounter := 0;
    If Assigned(fOnTreeChange) then
      fOnTreeChange(Self);
    If Assigned(fOnTreeChangeCB) then
      fOnTreeChangeCB(Self);
    fChanged := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.OnNodeChangeHandler(Sender: TObject; Node: TUNSNodeBase);
var
  TempStr:  String;
begin
fChanged := True;
If (fChangeCounter <= 0) then
  begin
    If UNSIsLeafNode(Node) then
      begin
        If Assigned(fOnValueChange) Or Assigned(fOnValueChangeCB) then
          begin
            TempStr := Node.ReconstructFullName(False);
            If Assigned(fOnValueChange) then
              fOnValueChange(Self,TempStr);
            If Assigned(fOnValueChangeCB) then
              fOnValueChangeCB(Self,TempStr);
          end;
      end
    else
      begin
        If Assigned(fOnTreeChange) then
          fOnTreeChange(Self);
        If Assigned(fOnTreeChangeCB) then
          fOnTreeChangeCB(Self);
      end;
  end;
end;

//------------------------------------------------------------------------------

constructor TUniSettings.Create(RootNode: TUNSNodeBranch);
begin
inherited Create;
fValueFormatSettings := UNS_VALUEFORMATSETTINGS_DEFAULT;
fSynchronizer := TMultiReadExclusiveWriteSynchronizer.Create;
fRootNode := RootNode;
fRootNode.Master := Self;
fRootNode.OnChange := OnNodeChangeHandler;
fWorkingBranch := '';
fWorkingNode := fRootNode;
fParser := TUNSParser.Create(AddNode);
fAdditionCounter := 0;
fChangeCounter := 0;
fChanged := False;
fOnTreeChange := nil;
fOnTreeChangeCB := nil;
fOnValueChange := nil;
fOnValueChangeCB := nil;
end;

//==============================================================================

constructor TUniSettings.Create;
begin
Create(TUNSNodeBranch.Create(UNS_NAME_ROOTNODE,nil));
end;

//------------------------------------------------------------------------------

constructor TUniSettings.CreateAsCopy(Source: TUniSettings);
begin
Create(TUNSNodeBranch.CreateAsCopy(Source.fRootNode,UNS_NAME_ROOTNODE,nil));
fValueFormatSettings := Source.ValueFormatSettings;
SetWorkingBranch(Source.WorkingBranch);
end;

//------------------------------------------------------------------------------

Function TUniSettings.CreateCopy: TUniSettings;
begin
Result := TUNSUniSettingsClass(Self.ClassType).CreateAsCopy(Self);
end;

//------------------------------------------------------------------------------

destructor TUniSettings.Destroy;
begin
Clear;
fParser.Free;
fRootNode.Free;
fSynchronizer.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ReadLock;
begin
fSynchronizer.BeginRead;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ReadUnlock;
begin
fSynchronizer.EndRead;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.WriteLock;
begin
fSynchronizer.BeginWrite;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.WriteUnlock;
begin
fSynchronizer.EndWrite;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Lock;
begin
WriteLock;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Unlock;
begin
WriteUnlock;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromLineNoLock(const Line: String);
begin
ConstructionInitialization;
AppendFromLineNoLock(Line);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromLinesNoLock(Lines: TStrings);
begin
ConstructionInitialization;
AppendFromLinesNoLock(Lines);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromTextNoLock(const Text: String);
begin
ConstructionInitialization;
AppendFromTextNoLock(Text);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromStreamNoLock(Stream: TStream);
begin
ConstructionInitialization;
AppendFromStreamNoLock(Stream);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromCompressedStreamNoLock(Stream: TStream);
begin
ConstructionInitialization;
AppendFromCompressedStreamNoLock(Stream);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromFileNoLock(const FileName: String);
begin
ConstructionInitialization;
AppendFromFileNoLock(FileName);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromCompressedFileNoLock(const FileName: String);
begin
ConstructionInitialization;
AppendFromCompressedFileNoLock(FileName);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromResourceNoLock(const ResourceName: String);
begin
ConstructionInitialization;
AppendFromResourceNoLock(ResourceName);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromCompressedResourceNoLock(const ResourceName: String);
begin
ConstructionInitialization;
AppendFromCompressedResourceNoLock(ResourceName);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromLineNoLock(const Line: String);
begin
fParser.ParseLine(Line);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromLinesNoLock(Lines: TStrings);
begin
fParser.ParseLines(Lines);
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromTextNoLock(const Text: String);
begin
fParser.ParseText(Text);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromStreamNoLock(Stream: TStream);
begin
fParser.ParseStream(Stream);
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromCompressedStreamNoLock(Stream: TStream);
begin
fParser.ParseCompressedStream(Stream);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromFileNoLock(const FileName: String);
var
  FileStream: TFileStream;
begin
FileStream := TFileStream.Create(StrToRTL(FileName),fmOpenRead or fmShareDenyWrite);
try
  ConstructFromStreamNoLock(FileStream);
finally
  FileStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromCompressedFileNoLock(const FileName: String);
var
  FileStream: TFileStream;
begin
FileStream := TFileStream.Create(StrToRTL(FileName),fmOpenRead or fmShareDenyWrite);
try
  ConstructFromCompressedStreamNoLock(FileStream);
finally
  FileStream.Free;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromResourceNoLock(const ResourceName: String);
var
  ResourceStream: TResourceStream;
begin
ResourceStream := TResourceStream.Create(hInstance,StrToRTL(ResourceName),PChar(10){RT_RCDATA});
try
  ConstructFromStreamNoLock(ResourceStream);
finally
  ResourceStream.Free;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromCompressedResourceNoLock(const ResourceName: String);
var
  ResourceStream: TResourceStream;
begin
ResourceStream := TResourceStream.Create(hInstance,StrToRTL(ResourceName),PChar(10){RT_RCDATA});
try
  ConstructFromCompressedStreamNoLock(ResourceStream);
finally
  ResourceStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromLine(const Line: String);
begin
WriteLock;
try
  ConstructFromLineNoLock(Line);
finally
  WriteUnlock;
end;
end;  

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromLines(Lines: TStrings);
begin
WriteLock;
try
  ConstructFromLinesNoLock(Lines);
finally
  WriteUnlock;
end;
end;      

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromText(const Text: String);
begin
WriteLock;
try
  ConstructFromTextNoLock(Text);
finally
  WriteUnlock;
end;
end;  

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromStream(Stream: TStream);
begin
WriteLock;
try
  ConstructFromStreamNoLock(Stream);
finally
  WriteUnlock;
end;
end;   

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromCompressedStream(Stream: TStream);
begin
WriteLock;
try
  ConstructFromCompressedStreamNoLock(Stream);
finally
  WriteUnlock;
end;
end;        

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromFile(const FileName: String);
begin
WriteLock;
try
  ConstructFromFileNoLock(FileName);
finally
  WriteUnlock;
end;
end;   

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromCompressedFile(const FileName: String);
begin
WriteLock;
try
  ConstructFromCompressedFileNoLock(FileName);
finally
  WriteUnlock;
end;
end;  

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromResource(const ResourceName: String);
begin
WriteLock;
try
  ConstructFromResourceNoLock(ResourceName);
finally
  WriteUnlock;
end;
end;    

//------------------------------------------------------------------------------

procedure TUniSettings.ConstructFromCompressedResource(const ResourceName: String);
begin
WriteLock;
try
  ConstructFromCompressedResourceNoLock(ResourceName);
finally
  WriteUnlock;
end;
end;  

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromLine(const Line: String);
begin
WriteLock;
try
  AppendFromLineNoLock(Line);
finally
  WriteUnlock;
end;
end;    

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromLines(Lines: TStrings);
begin
WriteLock;
try
  AppendFromLinesNoLock(Lines);
finally
  WriteUnlock;
end;
end;    

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromText(const Text: String);
begin
WriteLock;
try
  AppendFromTextNoLock(Text);
finally
  WriteUnlock;
end;
end;      

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromStream(Stream: TStream);
begin
WriteLock;
try
  AppendFromStreamNoLock(Stream);
finally
  WriteUnlock;
end;
end;    

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromCompressedStream(Stream: TStream);
begin
WriteLock;
try
  AppendFromCompressedStreamNoLock(Stream);
finally
  WriteUnlock;
end;
end;         

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromFile(const FileName: String);
begin
WriteLock;
try
  AppendFromFileNoLock(FileName);
finally
  WriteUnlock;
end;
end;       

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromCompressedFile(const FileName: String);
begin
WriteLock;
try
  AppendFromCompressedFileNoLock(FileName);
finally
  WriteUnlock;
end;
end;          

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromResource(const ResourceName: String);
begin
WriteLock;
try
  AppendFromResourceNoLock(ResourceName);
finally
  WriteUnlock;
end;
end;      

//------------------------------------------------------------------------------

procedure TUniSettings.AppendFromCompressedResource(const ResourceName: String);
begin
WriteLock;
try
  AppendFromCompressedResourceNoLock(ResourceName);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ExistsNoLock(const ValueName: String): Boolean;
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNode;
begin
Result := False;
If UNSNameParts(ValueName,NameParts) > 0 then
  begin
    If NameParts.EndsWithIndex then
      begin
        // last name part is an index or item
        If NamePartsHideLast(NameParts) then
          try
            Node := FindNode(NameParts);
          finally
            NamePartsShowLast(NameParts);
          end
        else Node := nil;
        If UNSIsPrimitiveArrayNode(Node) then
          case CDA_Last(NameParts).PartType of
            nptArrayIndex:
              Result := TUNSNodePrimitiveArray(Node).CheckIndex(CDA_Last(NameParts).PartIndex,vkActual);
            nptArrayIndexSav:
              Result := TUNSNodePrimitiveArray(Node).CheckIndex(CDA_Last(NameParts).PartIndex,vkSaved);
            nptArrayIndexDef:
              Result := TUNSNodePrimitiveArray(Node).CheckIndex(CDA_Last(NameParts).PartIndex,vkDefault);
            nptArrayItem:
              If CDA_Last(NameParts).PartIndex in [UNS_NAME_ARRAYITEM_LOW,UNS_NAME_ARRAYITEM_HIGH] then
                Result := TUNSNodePrimitiveArray(Node).Count > 0;
            nptArrayItemSav:
              If CDA_Last(NameParts).PartIndex in [UNS_NAME_ARRAYITEM_LOW,UNS_NAME_ARRAYITEM_HIGH] then
                Result := TUNSNodePrimitiveArray(Node).SavedCount > 0;
            nptArrayItemDef:
              If CDA_Last(NameParts).PartIndex in [UNS_NAME_ARRAYITEM_LOW,UNS_NAME_ARRAYITEM_HIGH] then
                Result := TUNSNodePrimitiveArray(Node).DefaultCount > 0;
          end;
      end
    else
      begin
        Node := FindNode(NameParts);
        Result := UNSIsLeafNode(Node);
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.AddNoLock(const ValueName: String; ValueType: TUNSValueType): Boolean;
var
  NewNode:  TUNSNodeLeaf;
begin
BeginChanging;
try
  Result := AddNode(ValueName,ValueType,NewNode);
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.RemoveNoLock(const ValueName: String): Boolean;
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNode;

  Function ArrayItemRemove(ArrayNode: TUNSNodePrimitiveArray; PartIndex: Integer; ValueKind: TUNSValueKind): Boolean;
  begin
    Result := True;
    case PartIndex of
      UNS_NAME_ARRAYITEM_LOW:
        ArrayNode.Delete(ArrayNode.LowIndex(ValueKind),ValueKind);
      UNS_NAME_ARRAYITEM_HIGH:
        ArrayNode.Delete(ArrayNode.HighIndex(ValueKind),ValueKind);
    else
      Result := False;
    end;
  end;

begin
Result := False;
If UNSNameParts(ValueName,NameParts) > 0 then
  begin
    BeginChanging;
    try
      If NameParts.EndsWithIndex then
        begin
          // last name part is an index or item
          If NamePartsHideLast(NameParts) then
            try
              Node := FindNode(NameParts);
            finally
              NamePartsShowLast(NameParts);
            end
          else Node := nil;
          Result := True;
          If UNSIsPrimitiveArrayNode(Node) then
            case CDA_Last(NameParts).PartType of
              nptArrayIndex:
                TUNSNodePrimitiveArray(Node).Delete(CDA_Last(NameParts).PartIndex,vkActual);
              nptArrayIndexSav:
                TUNSNodePrimitiveArray(Node).Delete(CDA_Last(NameParts).PartIndex,vkSaved);
              nptArrayIndexDef:
                TUNSNodePrimitiveArray(Node).Delete(CDA_Last(NameParts).PartIndex,vkDefault);
              nptArrayItem:
                Result := ArrayItemRemove(TUNSNodePrimitiveArray(Node),CDA_Last(NameParts).PartIndex,vkActual);
              nptArrayItemSav:
                Result := ArrayItemRemove(TUNSNodePrimitiveArray(Node),CDA_Last(NameParts).PartIndex,vkSaved);
              nptArrayItemDef:
                Result := ArrayItemRemove(TUNSNodePrimitiveArray(Node),CDA_Last(NameParts).PartIndex,vkDefault);
            else
              Result := False;
            end
          else Result := False;
        end
      else
        begin
          Node := FindNode(NameParts);
          If UNSIsBranchNode(Node.ParentNode) then
            Result := TUNSNodeBranch(Node.ParentNode).Remove(Node) >= 0;
        end;
    finally
      EndChanging;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ClearNoLock;
begin
BeginChanging;
try
  fWorkingNode.Clear;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

Function UNS_LV_Compare(Context: Pointer; Index1,Index2: Integer): Integer;
begin
Result := TUNSNodeBase(TStrings(Context).Objects[Index2]).AdditionIndex -
          TUNSNodeBase(TStrings(Context).Objects[Index1]).AdditionIndex;
end;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---

procedure UNS_LV_Exchange(Context: Pointer; Index1,Index2: Integer);
begin
TStrings(Context).Exchange(Index1,Index2);
end;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---

Function TUniSettings.ListValuesNoLock(Strings: TStrings; PreserveAdditionOrder: Boolean = False): Integer;
var
  Sorter: TListQuickSorter;

  procedure AddNodeToListing(Node: TUNSNode);
  var
    i:  Integer;
  begin
    If UNSIsBranchNode(Node) then
      begin
        For i := TUNSNodeBranch(Node).LowIndex to TUNSNodeBranch(Node).HighIndex do
          AddNodeToListing(TUNSNodeBranch(Node)[i]);
      end
    else Strings.AddObject(Node.ReconstructFullName(False),Node);
  end;

begin
Strings.Clear;
AddNodeToListing(fWorkingNode);
If PreserveAdditionOrder and (Strings.Count > 0) then
  begin
    Sorter := TListQuickSorter.Create(Pointer(Strings),UNS_LV_Compare,UNS_LV_Exchange);
    try
      Sorter.Sort(0,Pred(Strings.Count));
    finally
      Sorter.Free;
    end;
  end;
Result := Strings.Count;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Exists(const ValueName: String): Boolean;
begin
ReadLock;
try
  Result := ExistsNoLock(ValueName);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Add(const ValueName: String; ValueType: TUNSValueType): Boolean;
begin
WriteLock;
try
  Result := AddNoLock(ValueName,ValueType);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Remove(const ValueName: String): Boolean;
begin
WriteLock;
try
  Result := RemoveNoLock(ValueName);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Clear;
begin
WriteLock;
try
  ClearNoLock;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ListValues(Strings: TStrings; PreserveAdditionOrder: Boolean = False): Integer;
begin
ReadLock;
try
  Result := ListValuesNoLock(Strings,PreserveAdditionOrder);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueKindMoveNoLock(Src,Dest: TUNSValueKind);
begin
BeginChanging;
try
  fWorkingNode.ValueKindMove(Src,Dest);
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueKindExchangeNoLock(ValA,ValB: TUNSValueKind);
begin
BeginChanging;
try
  fWorkingNode.ValueKindExchange(ValA,ValB);
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueKindCompareNoLock(ValA,ValB: TUNSValueKind): Boolean;
begin
Result := fWorkingNode.ValueKindCompare(ValA,ValB);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ActualFromDefaultNoLock;
begin
BeginChanging;
try
  fWorkingNode.ActualFromDefault;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DefaultFromActualNoLock;
begin
BeginChanging;
try
  fWorkingNode.DefaultFromActual;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ExchangeActualAndDefaultNoLock;
begin
BeginChanging;
try
  fWorkingNode.ExchangeActualAndDefault;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ActualEqualsDefaultNoLock: Boolean;
begin
Result := fWorkingNode.ActualEqualsDefault;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.SaveNoLock;
begin
BeginChanging;
try
  fWorkingNode.Save;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.RestoreNoLock;
begin
BeginChanging;
try
  fWorkingNode.Restore;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueFullNameNoLock(const ValueName: String): String;
begin
Result := CheckedLeafNodeAccess(ValueName,'ValueFullNameNoLock').ReconstructFullName(False);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueTypeNoLock(const ValueName: String): TUNSValueType;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueTypeNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).ItemValueType
else
  Result := TempNode.ValueType;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueSizeNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemSize;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueSizeNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).ObtainItemSize(TempIndex,TempValueKind)
else
  Result := TempNode.ValueSize;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindMoveNoLock(const ValueName: String; Src,Dest: TUNSValueKind);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueValueKindMoveNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).ValueKindMove(TempIndex,Src,Dest)
else
  TempNode.ValueKindMove(Src,Dest);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindExchangeNoLock(const ValueName: String; ValA,ValB: TUNSValueKind);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueValueKindExchangeNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).ValueKindExchange(TempIndex,ValA,ValB)
else
  TempNode.ValueKindExchange(ValA,ValB);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueValueKindCompareNoLock(const ValueName: String; ValA,ValB: TUNSValueKind): Boolean;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueValueKindCompareNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).ValueKindCompare(TempIndex,ValA,ValB)
else
  Result := TempNode.ValueKindCompare(ValA,ValB);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueActualFromDefaultNoLock(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueActualFromDefaultNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).ActualFromDefault(TempIndex)
else
  TempNode.ActualFromDefault;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueDefaultFromActualNoLock(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueDefaultFromActualNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).DefaultFromActual(TempIndex)
else
  TempNode.DefaultFromActual;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchangeActualAndDefaultNoLock(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueExchangeActualAndDefaultNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).ExchangeActualAndDefault(TempIndex)
else
  TempNode.ExchangeActualAndDefault;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueActualEqualsDefaultNoLock(const ValueName: String): Boolean;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueActualEqualsDefaultNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).ActualEqualsDefault(TempIndex)
else
  Result := TempNode.ActualEqualsDefault;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueSaveNoLock(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueSaveNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).Save(TempIndex)
else
  TempNode.Save;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueRestoreNoLock(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueRestoreNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).Restore(TempIndex)
else
  TempNode.Restore;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAddressNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Pointer;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueAddressNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).Address(TempIndex,TempValueKind)
else
  Result := TempNode.Address(ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueAsStringNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueAsStringNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).AsString(TempIndex,TempValueKind)
else
  Result := TempNode.AsString(ValueKind);
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromStringNoLock(const ValueName: String; const Str: String; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueFromStringNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).FromString(TempIndex,Str,TempValueKind)
else
  TempNode.FromString(Str,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueToStreamNoLock(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueToStreamNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).ToStream(TempIndex,Stream,TempValueKind)
else
  TempNode.ToStream(Stream,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromStreamNoLock(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueFromStreamNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).FromStream(TempIndex,Stream,TempValueKind)
else
  TempNode.FromStream(Stream,ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueAsStreamNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryStream;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueAsStreamNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).AsStream(TempIndex,TempValueKind)
else
  Result := TempNode.AsStream(ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueToBufferNoLock(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueToBufferNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).ToBuffer(TempIndex,Buffer,TempValueKind)
else
  TempNode.ToBuffer(Buffer,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromBufferNoLock(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueFromBufferNoLock',TempNode,TempValueKind,TempIndex) then
  TUNSNodePrimitiveArray(TempNode).FromBuffer(TempIndex,Buffer,TempValueKind)
else
  TempNode.FromBuffer(Buffer,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsBufferNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If CheckedLeafNodeAccessIsArray(ValueName,'ValueAsBufferNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).AsBuffer(TempIndex,TempValueKind)
else
  Result := TempNode.AsBuffer(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueCountNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueCountNoLock').ObtainCount(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemSizeNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemSize;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemSizeNoLock').ObtainItemSize(Index,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindMoveNoLock(const ValueName: String; Index: Integer; Src,Dest: TUNSValueKind);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueValueKindMoveNoLock').ValueKindMove(Index,Src,Dest);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindExchangeNoLock(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueValueKindExchangeNoLock').ValueKindExchange(Index,ValA,ValB);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueValueKindCompareNoLock(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind): Boolean;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueValueKindCompareNoLock').ValueKindCompare(Index,ValA,ValB);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemActualFromDefaultNoLock(const ValueName: String; Index: Integer);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemActualFromDefaultNoLock').ActualFromDefault(Index);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemDefaultFromActualNoLock(const ValueName: String; Index: Integer);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemDefaultFromActualNoLock').DefaultFromActual(Index);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemExchangeActualAndDefaultNoLock(const ValueName: String; Index: Integer);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemExchangeActualAndDefaultNoLock').ExchangeActualAndDefault(Index);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemActualEqualsDefaultNoLock(const ValueName: String; Index: Integer): Boolean;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemActualEqualsDefaultNoLock').ActualEqualsDefault(Index);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemSaveNoLock(const ValueName: String; Index: Integer);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemSaveNoLock').Save(Index);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemRestoreNoLock(const ValueName: String; Index: Integer);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemRestoreNoLock').Restore(Index);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAddressNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAddressNoLock').Address(Index,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsStringNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsStringNoLock').AsString(Index,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromStringNoLock(const ValueName: String; Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromStringNoLock').FromString(Index,Str,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToStreamNoLock(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemToStreamNoLock').ToStream(Index,Stream,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromStreamNoLock(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromStreamNoLock').FromStream(Index,Stream,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsStreamNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryStream;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsStreamNoLock').AsStream(Index,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToBufferNoLock(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemToBufferNoLock').ToBuffer(Index,Buffer,ValueKind);
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromBufferNoLock(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromBufferNoLock').FromBuffer(Index,Buffer,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsBufferNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsBufferNoLock').AsBuffer(Index,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueLowIndexNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueLowIndexNoLock').LowIndex(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueHighIndexNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueHighIndexNoLock').HighIndex(ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueCheckIndexNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
Result := CheckedLeafArrayNodeAccess(ValueName,'ValueCheckIndexNoLock').CheckIndex(Index,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchangeNoLock(const ValueName: String; Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueExchangeNoLock').Exchange(Index1,Index2,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueMoveNoLock(const ValueName: String; SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueMoveNoLock').Move(SrcIndex,DstIndex,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueDeleteNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueDeleteNoLock').Delete(Index,ValueKind);
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueClearNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual);
begin
CheckedLeafArrayNodeAccess(ValueName,'ValueClearNoLock').Clear(ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueKindMove(Src,Dest: TUNSValueKind);
begin
WriteLock;
try
  ValueKindMoveNoLock(Src,Dest);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueKindExchange(ValA,ValB: TUNSValueKind);
begin
WriteLock;
try
  ValueKindExchangeNoLock(ValA,ValB);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
WriteLock;
try
  Result := ValueKindCompareNoLock(ValA,ValB);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ActualFromDefault;
begin
WriteLock;
try
  ActualFromDefaultNoLock;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DefaultFromActual;
begin
WriteLock;
try
  DefaultFromActualNoLock;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ExchangeActualAndDefault;
begin
WriteLock;
try
  ExchangeActualAndDefaultNoLock;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ActualEqualsDefault: Boolean;
begin
WriteLock;
try
  Result := ActualEqualsDefaultNoLock;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Save;
begin
WriteLock;
try
  SaveNoLock;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Restore; 
begin
WriteLock;
try
  RestoreNoLock;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueFullName(const ValueName: String): String;
begin
ReadLock;
try
  Result := ValueFullNameNoLock(ValueName);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueType(const ValueName: String): TUNSValueType;
begin
ReadLock;
try
  Result := ValueTypeNoLock(ValueName);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueSize(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemSize;
begin
ReadLock;
try
  Result := ValueSizeNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindMove(const ValueName: String; Src,Dest: TUNSValueKind);
begin
WriteLock;
try
  ValueValueKindMoveNoLock(ValueName,Src,Dest);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindExchange(const ValueName: String; ValA,ValB: TUNSValueKind);
begin
WriteLock;
try
  ValueValueKindExchangeNoLock(ValueName,ValA,ValB);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueValueKindCompare(const ValueName: String; ValA,ValB: TUNSValueKind): Boolean;
begin
ReadLock;
try
  Result := ValueValueKindCompareNoLock(ValueName,ValA,ValB);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueActualFromDefault(const ValueName: String);
begin
WriteLock;
try
  ValueActualFromDefaultNoLock(ValueName);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueDefaultFromActual(const ValueName: String);
begin
WriteLock;
try
  ValueDefaultFromActualNoLock(ValueName);
finally
  WriteUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchangeActualAndDefault(const ValueName: String);
begin
WriteLock;
try
  ValueExchangeActualAndDefaultNoLock(ValueName);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueActualEqualsDefault(const ValueName: String): Boolean;
begin
ReadLock;
try
  Result := ValueActualEqualsDefaultNoLock(ValueName);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueSave(const ValueName: String);
begin
WriteLock;
try
  ValueSaveNoLock(ValueName);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueRestore(const ValueName: String);
begin
WriteLock;
try
  ValueRestoreNoLock(ValueName);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAddress(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Pointer;
begin
ReadLock;
try
  Result := ValueAddressNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueAsString(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
begin
ReadLock;
try
  Result := ValueAsStringNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromString(const ValueName: String; const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueFromStringNoLock(ValueName,Str,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueToStream(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
ReadLock;
try
  ValueToStreamNoLock(ValueName,Stream,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromStream(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueFromStreamNoLock(ValueName,Stream,ValueKind);
finally
  WriteUnlock;
end;
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueAsStream(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryStream;
begin
ReadLock;
try
  Result := ValueAsStreamNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueToBuffer(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
ReadLock;
try
  ValueToBufferNoLock(ValueName,Buffer,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromBuffer(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueFromBufferNoLock(ValueName,Buffer,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsBuffer(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
begin
ReadLock;
try
  Result := ValueAsBufferNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueCount(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := ValueCountNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemSize(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemSize;
begin
ReadLock;
try
  Result := ValueItemSizeNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindMove(const ValueName: String; Index: Integer; Src,Dest: TUNSValueKind);
begin
WriteLock;
try
  ValueValueKindMoveNoLock(ValueName,Index,Src,Dest);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindExchange(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind);
begin
WriteLock;
try
  ValueValueKindExchangeNoLock(ValueName,Index,ValA,ValB);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueValueKindCompare(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind): Boolean;
begin
ReadLock;
try
  Result := ValueValueKindCompareNoLock(ValueName,Index,ValA,ValB);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemActualFromDefault(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  ValueItemActualFromDefaultNoLock(ValueName,Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemDefaultFromActual(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  ValueItemDefaultFromActualNoLock(ValueName,Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemExchangeActualAndDefault(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  ValueItemExchangeActualAndDefaultNoLock(ValueName,Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemActualEqualsDefault(const ValueName: String; Index: Integer): Boolean;
begin
ReadLock;
try
  Result := ValueItemActualEqualsDefaultNoLock(ValueName,Index);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemSave(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  ValueItemSaveNoLock(ValueName,Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemRestore(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  ValueItemRestoreNoLock(ValueName,Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAddress(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer;
begin
ReadLock;
try
  Result := ValueItemAddressNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsString(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String;
begin
ReadLock;
try
  Result := ValueItemAsStringNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromString(const ValueName: String; Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueItemFromStringNoLock(ValueName,Index,Str,ValueKind);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToStream(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
ReadLock;
try
  ValueItemToStreamNoLock(ValueName,Index,Stream,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromStream(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueItemFromStreamNoLock(ValueName,Index,Stream,ValueKind);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsStream(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryStream;
begin
ReadLock;
try
  Result := ValueItemAsStreamNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
ReadLock;
try
  ValueItemToBufferNoLock(ValueName,Index,Buffer,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueItemFromBufferNoLock(ValueName,Index,Buffer,ValueKind);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsBuffer(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
begin
ReadLock;
try
  Result := ValueItemAsBufferNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueLowIndex(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := ValueLowIndexNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueHighIndex(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := ValueHighIndexNoLock(ValueName,ValueKind);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueCheckIndex(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
ReadLock;
try
  Result := ValueCheckIndexNoLock(ValueName,Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchange(const ValueName: String; Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueExchangeNoLock(ValueName,Index1,Index2,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueMove(const ValueName: String; SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueMoveNoLock(ValueName,SrcIndex,DstIndex,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueDelete(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueDeleteNoLock(ValueName,Index,ValueKind);
finally
  WriteUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueClear(const ValueName: String; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  ValueClearNoLock(ValueName,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

{$DEFINE UNS_Included}{$DEFINE UNS_Include_Implementation}
  // simple types
  {$INCLUDE '.\UniSettings_NodeBool.pas'}
  {$INCLUDE '.\UniSettings_NodeInt8.pas'}
  {$INCLUDE '.\UniSettings_NodeUInt8.pas'}
  {$INCLUDE '.\UniSettings_NodeInt16.pas'}
  {$INCLUDE '.\UniSettings_NodeUInt16.pas'}
  {$INCLUDE '.\UniSettings_NodeInt32.pas'}
  {$INCLUDE '.\UniSettings_NodeUInt32.pas'}
  {$INCLUDE '.\UniSettings_NodeInt64.pas'}
  {$INCLUDE '.\UniSettings_NodeUInt64.pas'}
  {$INCLUDE '.\UniSettings_NodeFloat32.pas'}
  {$INCLUDE '.\UniSettings_NodeFloat64.pas'}
  {$INCLUDE '.\UniSettings_NodeDateTime.pas'}
  {$INCLUDE '.\UniSettings_NodeDate.pas'}
  {$INCLUDE '.\UniSettings_NodeTime.pas'}
  {$INCLUDE '.\UniSettings_NodeText.pas'}
  {$INCLUDE '.\UniSettings_NodeBuffer.pas'}
  // array types
  {$INCLUDE '.\UniSettings_NodeAoBool.pas'}
  {$INCLUDE '.\UniSettings_NodeAoInt8.pas'}
  {$INCLUDE '.\UniSettings_NodeAoUInt8.pas'}
  {$INCLUDE '.\UniSettings_NodeAoInt16.pas'}
  {$INCLUDE '.\UniSettings_NodeAoUInt16.pas'}
  {$INCLUDE '.\UniSettings_NodeAoInt32.pas'}
  {$INCLUDE '.\UniSettings_NodeAoUInt32.pas'}
  {$INCLUDE '.\UniSettings_NodeAoInt64.pas'}
  {$INCLUDE '.\UniSettings_NodeAoUInt64.pas'}
  {$INCLUDE '.\UniSettings_NodeAoFloat32.pas'}
  {$INCLUDE '.\UniSettings_NodeAoFloat64.pas'}
  {$INCLUDE '.\UniSettings_NodeAoDateTime.pas'}
  {$INCLUDE '.\UniSettings_NodeAoDate.pas'}
  {$INCLUDE '.\UniSettings_NodeAoTime.pas'}
  {$INCLUDE '.\UniSettings_NodeAoText.pas'}
  {$INCLUDE '.\UniSettings_NodeAoBuffer.pas'}
{$UNDEF UNS_Include_Implementation}{$UNDEF UNS_Included}

end.
