(*
todo (* = completed):

  tree building
* arrays
* array nodes: listsorters -> implementation uses
* access to array items trough index in value name
* name parts -> CDA
  TUniSettings copy constructor
* make copies thread safe

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
  UniSettings_NodePrimitiveArray, UniSettings_NodeBranch;

type
  TUNSNode = TUNSNodeBase;

  TUniSettings = class(TObject)
  private
    fValueFormatSettings: TUNSValueFormatSettings;
    fSynchronizer:        TMultiReadExclusiveWriteSynchronizer;
    fRootNode:            TUNSNodeBranch;
    fWorkingBranch:       String;
    fWorkingNode:         TUNSNodeBranch;
    fChangeCounter:       Integer;
    fChanged:             Boolean;
    fOnChange:            TNotifyEvent;
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
    Function CheckedLeafNodeTypeAccess(const NodeName: String; ValueType: TUNSValueType; Caller: String): TUNSNodeLeaf; virtual;
    Function CheckedLeafNodeAccessIsArray(const NodeName, Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean; virtual;
    procedure ChangingStart;
    procedure ChangingEnd;
    procedure OnChangeHandler(Sender: TObject); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    //--- Locking --------------------------------------------------------------
    procedure ReadLock; virtual;
    procedure ReadUnlock; virtual;
    procedure WriteLock; virtual;
    procedure WriteUnlock; virtual;
    procedure Lock; virtual;
    procedure Unlock; virtual;
    //--- Values management ----------------------------------------------------
    Function Exists(const ValueName: String): Boolean; virtual;
    Function Add(const ValueName: String; ValueType: TUNSValueType): Boolean; virtual;
    Function Remove(const ValueName: String): Boolean; virtual;
    procedure Clear; virtual;
    Function ListValues(Strings: TStrings): Integer; virtual;
    //--- Tree construction ----------------------------------------------------
    //--- IO operations --------------------------------------------------------
    (*
    SaveToIni
    LoadFromIni
    SaveToRegistry
    LoadFromRegistry
    *)
    //--- General value access -------------------------------------------------
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
    //--- Specific value types access ------------------------------------------
  (*
  {$DEFINE Included}{$DEFINE Included_Declaration}
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
  {$UNDEF Included_Declaration}{$UNDEF Included}
    *)
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
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

implementation

uses
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
      If Node is TUNSNodeBranch then
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
  // simple values
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
  // array values
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
    If Branch is TUNSNodeArray then
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
      If Branch is TUNSNodeArray then
        case NodeNamePart.PartIndex of
          UNS_NAME_ARRAYITEM_NEW:
            If CanCreateArrayItem then
              begin
                Node := TUNSNodeArrayItem.Create('',Branch);
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
            If NextNode is TUNSNodeBlank then
              begin
                CurrentBranch.Remove(NextNode);
                NextNode := nil;
                NodeFound := False;
              end;
            If NodeFound then
              begin
                // node was found
                If not(NextNode is TUNSNodeBranch) then
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
  If not(CDA_Last(NameParts).PartType in [nptArrayIndex,nptArrayIndexSav,
    nptArrayIndexDef,nptArrayItem,nptArrayItemSav,nptArrayItemDef]) then
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
            If BranchNode[Index] is TUNSNodeBlank then
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
        If CurrentNode is TUNSNodeBranch then
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
    If FoundNode is TUNSNodeLeaf then
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
    If Node.IsPrimitiveArray then
      Result := TUNSNodePrimitiveArray(Node)
    else
      raise EUNSValueNotAnArrayException.Create(NodeName,Self,Caller);
  end
else raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
end;

//------------------------------------------------------------------------------

Function TUniSettings.CheckedLeafNodeTypeAccess(const NodeName: String; ValueType: TUNSValueType; Caller: String): TUNSNodeLeaf;
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
        If FoundNode is TUNSNodePrimitiveArray then
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
        else EUNSValueNotAnArrayException.Create(NodeName,Self,Caller);
      end
    else
      begin
        FoundNode := FindNode(NameParts);
        If FoundNode is TUNSNodeLeaf then
          Node := TUNSNodeLeaf(FoundNode)
        else
          raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ChangingStart;
begin
Inc(fChangeCounter);
fChanged := False;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ChangingEnd;
begin
Dec(fChangeCounter);
If (fChangeCounter <= 0) and fChanged then
  begin
    fChangeCounter := 0;
    OnChangeHandler(Self);
    fChanged := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.OnChangeHandler(Sender: TObject);
begin
fChanged := True;
If (fChangeCounter <= 0) and Assigned(fOnChange) then
  fOnChange(Self);
end;

//==============================================================================

constructor TUniSettings.Create;
begin
inherited Create;
fValueFormatSettings := UNS_VALUEFORMATSETTINGS_DEFAULT;
fSynchronizer := TMultiReadExclusiveWriteSynchronizer.Create;
fRootNode := TUNSNodeBranch.Create(UNS_NAME_ROOTNODE,nil);
fRootNode.Master := Self;
fRootNode.OnChange := OnChangeHandler;
fWorkingBranch := '';
fWorkingNode := fRootNode;
fChangeCounter := 0;
fChanged := False;
fOnChange := nil;
end;

//------------------------------------------------------------------------------

destructor TUniSettings.Destroy;
begin
Clear;
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

Function TUniSettings.Exists(const ValueName: String): Boolean;
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNode;
begin
Result := False;
ReadLock;
try
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
          If Node is TUNSNodePrimitiveArray then
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
          Result := Node is TUNSNodeLeaf;
        end;
    end;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Add(const ValueName: String; ValueType: TUNSValueType): Boolean;
var
  NewNode:  TUNSNodeLeaf;
begin
WriteLock;
try
  ChangingStart;
  try
    Result := AddNode(ValueName,ValueType,NewNode);
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Remove(const ValueName: String): Boolean;
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
WriteLock;
try
  Result := False;
  If UNSNameParts(ValueName,NameParts) > 0 then
    begin
      ChangingStart;
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
            If Node is TUNSNodePrimitiveArray then
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
            If Node.ParentNode is TUNSNodeBranch then
              Result := TUNSNodeBranch(Node.ParentNode).Remove(Node) >= 0;
          end;
      finally
        ChangingEnd;
      end;
    end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Clear;
begin
WriteLock;
try
  ChangingStart;
  try
    fWorkingNode.Clear;
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ListValues(Strings: TStrings): Integer;

  procedure AddNodeToListing(Node: TUNSNode);
  var
    i:  Integer;
  begin
    If Node is TUNSNodeBranch then
      begin
        For i := TUNSNodeBranch(Node).LowIndex to TUNSNodeBranch(Node).HighIndex do
          AddNodeToListing(TUNSNodeBranch(Node)[i]);
      end
    else Strings.Add(Node.ReconstructFullName(False));
  end;

begin
Strings.Clear;
AddNodeToListing(fWorkingNode);
Result := Strings.Count;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueKindMove(Src,Dest: TUNSValueKind);
begin
WriteLock;
try
  ChangingStart;
  try
    fWorkingNode.ValueKindMove(Src,Dest);
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueKindExchange(ValA,ValB: TUNSValueKind);
begin
WriteLock;
try
  ChangingStart;
  try
    fWorkingNode.ValueKindExchange(ValA,ValB);
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
begin
WriteLock;
try
  Result := fWorkingNode.ValueKindCompare(ValA,ValB);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ActualFromDefault;
begin
WriteLock;
try
  ChangingStart;
  try
    fWorkingNode.ActualFromDefault;
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DefaultFromActual;
begin
WriteLock;
try
  ChangingStart;
  try
    fWorkingNode.DefaultFromActual;
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ExchangeActualAndDefault;
begin
WriteLock;
try
  ChangingStart;
  try
    fWorkingNode.ExchangeActualAndDefault;
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ActualEqualsDefault: Boolean;
begin
WriteLock;
try
  Result := fWorkingNode.ActualEqualsDefault;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Save;
begin
WriteLock;
try
  ChangingStart;
  try
    fWorkingNode.Save;
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Restore; 
begin
WriteLock;
try
  ChangingStart;
  try
    fWorkingNode.Restore;
  finally
    ChangingEnd;
  end;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueFullName(const ValueName: String): String;
begin
ReadLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueFullName').ReconstructFullName(False);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueType(const ValueName: String): TUNSValueType;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueType',TempNode,TempValueKind,TempIndex) then
    Result := TUNSNodePrimitiveArray(TempNode).ItemValueType
  else
    Result := TempNode.ValueType;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueSize(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemSize;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueSize',TempNode,TempValueKind,TempIndex) then
    Result := TUNSNodePrimitiveArray(TempNode).ObtainItemSize(TempIndex,TempValueKind)
  else
    Result := TempNode.ValueSize;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindMove(const ValueName: String; Src,Dest: TUNSValueKind);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueValueKindMove',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).ValueKindMove(TempIndex,Src,Dest)
  else
    TempNode.ValueKindMove(Src,Dest);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindExchange(const ValueName: String; ValA,ValB: TUNSValueKind);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueValueKindExchange',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).ValueKindExchange(TempIndex,ValA,ValB)
  else
    TempNode.ValueKindExchange(ValA,ValB);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueValueKindCompare(const ValueName: String; ValA,ValB: TUNSValueKind): Boolean;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueValueKindCompare',TempNode,TempValueKind,TempIndex) then
    Result := TUNSNodePrimitiveArray(TempNode).ValueKindCompare(TempIndex,ValA,ValB)
  else
    Result := TempNode.ValueKindCompare(ValA,ValB);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueActualFromDefault(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueActualFromDefault',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).ActualFromDefault(TempIndex)
  else
    TempNode.ActualFromDefault;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueDefaultFromActual(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueDefaultFromActual',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).DefaultFromActual(TempIndex)
  else
    TempNode.DefaultFromActual;
finally
  WriteUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchangeActualAndDefault(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueExchangeActualAndDefault',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).ExchangeActualAndDefault(TempIndex)
  else
    TempNode.ExchangeActualAndDefault;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueActualEqualsDefault(const ValueName: String): Boolean;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueActualEqualsDefault',TempNode,TempValueKind,TempIndex) then
    Result := TUNSNodePrimitiveArray(TempNode).ActualEqualsDefault(TempIndex)
  else
    Result := TempNode.ActualEqualsDefault;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueSave(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueSave',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).Save(TempIndex)
  else
    TempNode.Save;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueRestore(const ValueName: String);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueRestore',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).Restore(TempIndex)
  else
    TempNode.Restore;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAddress(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Pointer;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueAddress',TempNode,TempValueKind,TempIndex) then
    Result := TUNSNodePrimitiveArray(TempNode).Address(TempIndex,TempValueKind)
  else
    Result := TempNode.Address(ValueKind);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueAsString(const ValueName: String; ValueKind: TUNSValueKind = vkActual): String;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueAsString',TempNode,TempValueKind,TempIndex) then
    Result := TUNSNodePrimitiveArray(TempNode).AsString(TempIndex,TempValueKind)
  else
    Result := TempNode.AsString(ValueKind);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromString(const ValueName: String; const Str: String; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueFromString',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).FromString(TempIndex,Str,TempValueKind)
  else
    TempNode.FromString(Str,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueToStream(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueToStream',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).ToStream(TempIndex,Stream,TempValueKind)
  else
    TempNode.ToStream(Stream,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromStream(const ValueName: String; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueFromStream',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).FromStream(TempIndex,Stream,TempValueKind)
  else
    TempNode.FromStream(Stream,ValueKind);
finally
  WriteUnlock;
end;
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueAsStream(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryStream;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueAsStream',TempNode,TempValueKind,TempIndex) then
    Result := TUNSNodePrimitiveArray(TempNode).AsStream(TempIndex,TempValueKind)
  else
    Result := TempNode.AsStream(ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueToBuffer(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueToBuffer',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).ToBuffer(TempIndex,Buffer,TempValueKind)
  else
    TempNode.ToBuffer(Buffer,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromBuffer(const ValueName: String; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
WriteLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueFromBuffer',TempNode,TempValueKind,TempIndex) then
    TUNSNodePrimitiveArray(TempNode).FromBuffer(TempIndex,Buffer,TempValueKind)
  else
    TempNode.FromBuffer(Buffer,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsBuffer(const ValueName: String; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
var
  TempNode:       TUNSNodeLeaf;
  TempValueKind:  TUNSValueKind;
  TempIndex:      Integer;
begin
ReadLock;
try
  If CheckedLeafNodeAccessIsArray(ValueName,'ValueAsBuffer',TempNode,TempValueKind,TempIndex) then
    Result := TUNSNodePrimitiveArray(TempNode).AsBuffer(TempIndex,TempValueKind)
  else
    Result := TempNode.AsBuffer(ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueCount(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueCount').ObtainCount(ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemSize(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemSize;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemSize').ObtainItemSize(Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindMove(const ValueName: String; Index: Integer; Src,Dest: TUNSValueKind);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueValueKindMove').ValueKindMove(Index,Src,Dest);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueValueKindExchange(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueValueKindExchange').ValueKindExchange(Index,ValA,ValB);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueValueKindCompare(const ValueName: String; Index: Integer; ValA,ValB: TUNSValueKind): Boolean;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueValueKindCompare').ValueKindCompare(Index,ValA,ValB);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemActualFromDefault(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemActualFromDefault').ActualFromDefault(Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemDefaultFromActual(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemDefaultFromActual').DefaultFromActual(Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemExchangeActualAndDefault(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemExchangeActualAndDefault').ExchangeActualAndDefault(Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemActualEqualsDefault(const ValueName: String; Index: Integer): Boolean;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemActualEqualsDefault').ActualEqualsDefault(Index);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemSave(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemSave').Save(Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemRestore(const ValueName: String; Index: Integer);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemRestore').Restore(Index);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAddress(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Pointer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAddress').Address(Index,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsString(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): String;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsString').AsString(Index,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromString(const ValueName: String; Index: Integer; const Str: String; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromString').FromString(Index,Str,ValueKind);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToStream(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
ReadLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemToStream').ToStream(Index,Stream,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromStream(const ValueName: String; Index: Integer; Stream: TStream; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromStream').FromStream(Index,Stream,ValueKind);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsStream(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryStream;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsStream').AsStream(Index,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
ReadLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemToBuffer').ToBuffer(Index,Buffer,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromBuffer').FromBuffer(Index,Buffer,ValueKind);
finally
  WriteUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsBuffer(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsBuffer').AsBuffer(Index,ValueKind);
finally
  ReadUnlock;
end;
end; 

//------------------------------------------------------------------------------

Function TUniSettings.ValueLowIndex(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueLowIndex').LowIndex(ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueHighIndex(const ValueName: String; ValueKind: TUNSValueKind = vkActual): Integer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueHighIndex').HighIndex(ValueKind);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

Function TUniSettings.ValueCheckIndex(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual): Boolean;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueCheckIndex').CheckIndex(Index,ValueKind);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchange(const ValueName: String; Index1,Index2: Integer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueExchange').Exchange(Index1,Index2,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueMove(const ValueName: String; SrcIndex,DstIndex: Integer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueMove').Move(SrcIndex,DstIndex,ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueDelete(const ValueName: String; Index: Integer; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueDelete').Delete(Index,ValueKind);
finally
  WriteUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueClear(const ValueName: String; ValueKind: TUNSValueKind = vkActual);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueClear').Clear(ValueKind);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------
(*
{$DEFINE Included}{$DEFINE Included_Implementation}
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
{$UNDEF Included_Implementation}{$UNDEF Included}
*)
end.
