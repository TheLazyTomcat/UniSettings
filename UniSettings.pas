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
* hashed node list in US (cannot do due to indexing in array branches)
* invariant node names
* replace direct access to cd arrays with CDA_GetItemPtr
* ToString/FromString - en(/de)code strings, do not do it in lexer
* rework Us settings

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
  Classes,
  AuxTypes, MemoryBuffer,

  UniSettings_Common,

  UniSettings_Base;

type
  TUniSettings = class(TUniSettingsBase)
  public
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
  end;

implementation

uses
  UniSettings_Exceptions, UniSettings_NodeLeaf, UniSettings_NodePrimitiveArray,
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
  UniSettings_NodeAoBuffer;


Function TUniSettings.ValueFullNameNoLock(const ValueName: String): String;
begin
Result := AccessLeafNode(ValueName,'ValueFullNameNoLock').ReconstructFullName(False);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueTypeNoLock(const ValueName: String): TUNSValueType;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
If AccessLeafNodeIsArray(ValueName,'ValueTypeNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueSizeNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueValueKindMoveNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueValueKindExchangeNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueValueKindCompareNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueActualFromDefaultNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueDefaultFromActualNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueExchangeActualAndDefaultNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueActualEqualsDefaultNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueSaveNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueRestoreNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueAddressNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueAsStringNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueFromStringNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueToStreamNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueFromStreamNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueAsStreamNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueToBufferNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueFromBufferNoLock',TempNode,TempValueKind,TempIndex) then
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
If AccessLeafNodeIsArray(ValueName,'ValueAsBufferNoLock',TempNode,TempValueKind,TempIndex) then
  Result := TUNSNodePrimitiveArray(TempNode).AsBuffer(TempIndex,TempValueKind)
else
  Result := TempNode.AsBuffer(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueCountNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := AccessArrayLeafNode(ValueName,'ValueCountNoLock').ObtainCount(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemSizeNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemSize;
begin
Result := AccessArrayLeafNode(ValueName,'ValueItemSizeNoLock').ObtainItemSize(Index,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindMoveNoLock(const ValueName: String; Index: Integer; Src,Dest: TUNSValueKind);
begin
AccessArrayLeafNode(ValueName,'ValueValueKindMoveNoLock').ValueKindMove(Index,Src,Dest);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindExchangeNoLock(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind);
begin
AccessArrayLeafNode(ValueName,'ValueValueKindExchangeNoLock').ValueKindExchange(Index,ValA,ValB);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueValueKindCompareNoLock(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind): Boolean;
begin
Result := AccessArrayLeafNode(ValueName,'ValueValueKindCompareNoLock').ValueKindCompare(Index,ValA,ValB);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemActualFromDefaultNoLock(const ValueName: String; Index: Integer);
begin
AccessArrayLeafNode(ValueName,'ValueItemActualFromDefaultNoLock').ActualFromDefault(Index);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemDefaultFromActualNoLock(const ValueName: String; Index: Integer);
begin
AccessArrayLeafNode(ValueName,'ValueItemDefaultFromActualNoLock').DefaultFromActual(Index);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemExchangeActualAndDefaultNoLock(const ValueName: String; Index: Integer);
begin
AccessArrayLeafNode(ValueName,'ValueItemExchangeActualAndDefaultNoLock').ExchangeActualAndDefault(Index);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemActualEqualsDefaultNoLock(const ValueName: String; Index: Integer): Boolean;
begin
Result := AccessArrayLeafNode(ValueName,'ValueItemActualEqualsDefaultNoLock').ActualEqualsDefault(Index);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemSaveNoLock(const ValueName: String; Index: Integer);
begin
AccessArrayLeafNode(ValueName,'ValueItemSaveNoLock').Save(Index);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemRestoreNoLock(const ValueName: String; Index: Integer);
begin
AccessArrayLeafNode(ValueName,'ValueItemRestoreNoLock').Restore(Index);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAddressNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer;
begin
Result := AccessArrayLeafNode(ValueName,'ValueItemAddressNoLock').Address(Index,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsStringNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String;
begin
Result := AccessArrayLeafNode(ValueName,'ValueItemAsStringNoLock').AsString(Index,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromStringNoLock(const ValueName: String; Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueItemFromStringNoLock').FromString(Index,Str,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToStreamNoLock(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueItemToStreamNoLock').ToStream(Index,Stream,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromStreamNoLock(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueItemFromStreamNoLock').FromStream(Index,Stream,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsStreamNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryStream;
begin
Result := AccessArrayLeafNode(ValueName,'ValueItemAsStreamNoLock').AsStream(Index,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToBufferNoLock(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueItemToBufferNoLock').ToBuffer(Index,Buffer,ValueKind);
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromBufferNoLock(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueItemFromBufferNoLock').FromBuffer(Index,Buffer,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsBufferNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
begin
Result := AccessArrayLeafNode(ValueName,'ValueItemAsBufferNoLock').AsBuffer(Index,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueLowIndexNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := AccessArrayLeafNode(ValueName,'ValueLowIndexNoLock').LowIndex(ValueKind);
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueHighIndexNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
Result := AccessArrayLeafNode(ValueName,'ValueHighIndexNoLock').HighIndex(ValueKind);
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueCheckIndexNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
Result := AccessArrayLeafNode(ValueName,'ValueCheckIndexNoLock').CheckIndex(Index,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchangeNoLock(const ValueName: String; Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueExchangeNoLock').Exchange(Index1,Index2,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueMoveNoLock(const ValueName: String; SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueMoveNoLock').Move(SrcIndex,DstIndex,ValueKind);
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueDeleteNoLock(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueDeleteNoLock').Delete(Index,ValueKind);
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueClearNoLock(const ValueName: String; ValueKind: TUNSValueKind = vkActual);
begin
AccessArrayLeafNode(ValueName,'ValueClearNoLock').Clear(ValueKind);
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
