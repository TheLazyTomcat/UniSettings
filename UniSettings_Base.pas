unit UniSettings_Base;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils, Classes, IniFiles,
  AuxClasses, IniFileEx,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeBranch,
  UniSettings_NodeLeaf, UniSettings_NodePrimitiveArray,
  UniSettings_ScriptParser;

type
  TUNSNode = TUNSNodeBase;

  TUniSettingsBase = class(TObject)
  private
    fValueFormatSettings: TUNSValueFormatSettings;
    fSynchronizer:        TMultiReadExclusiveWriteSynchronizer;
    fRootNode:            TUNSNodeBranch;
    fWorkingBranch:       String;
    fWorkingNode:         TUNSNodeBranch;
    fParser:              TUNSParser;
    fCreationCounter:     Integer;
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
    Function ConstructBranch(NodeNameParts: TUNSNameParts): TUNSNodeBranch; virtual;
    Function AddNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean; virtual;
    Function FindNode(NodeNameParts: TUNSNameParts): TUNSNodeBase; virtual;
    Function FindLeafNode(NodeNameParts: TUNSNameParts; out Node: TUNSNodeBase): Boolean; overload; virtual;
    Function FindLeafNode(const NodeName: String; out Node: TUNSNodeBase): Boolean; overload; virtual;
    Function FindLeafNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeBase): Boolean; overload; virtual;
    Function AccessLeafNode(const NodeName, Caller: String): TUNSNodeLeaf; virtual;
    Function AccessLeafNodeType(const NodeName: String; ValueType: TUNSValueType; const Caller: String): TUNSNodeLeaf; virtual;
    Function AccessArrayLeafNode(const NodeName, Caller: String): TUNSNodePrimitiveArray; virtual;
    Function AccessLeafNodeIsArray(const NodeName, Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean; virtual;
    Function AccessLeafNodeTypeIsArray(const NodeName: String; ValueType: TUNSValueType; const Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean; virtual;
    procedure ConstructionInitialization; virtual;
    procedure ListValuesWithNodes(List: TStrings; WorkingNodeInNames: Boolean); virtual;
    procedure BeginChanging;
    procedure EndChanging;
    procedure OnNodeChangeHandler(Sender: TObject; Node: TUNSNodeBase); virtual;
    constructor CreateInternal(RootNode: TUNSNodeBranch); overload;
  public
    constructor Create; overload;
    constructor CreateAsCopy(Source: TUniSettingsBase);
    Function CreateCopy: TUniSettingsBase; virtual;
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
    procedure SaveToIniNoLock(Ini: TIniFileEx); overload; virtual;
    procedure SaveToIniNoLock(Ini: TIniFile); overload; virtual;
    procedure LoadFromIniNoLock(Ini: TIniFileEx); overload; virtual;
    procedure LoadFromIniNoLock(Ini: TIniFile); overload; virtual;
    //procedure SaveToRegistryNoLock
    //procedure LoadFromRegistryNoLock
    //--- IO operations (lock) -------------------------------------------------
    procedure SaveToIni(Ini: TIniFileEx); overload; virtual;
    procedure SaveToIni(Ini: TIniFile); overload; virtual;
    procedure LoadFromIni(Ini: TIniFileEx); overload; virtual;
    procedure LoadFromIni(Ini: TIniFile); overload; virtual;
    //SaveToRegistry
    //LoadFromRegistry
    //--- Values management (no lock) ------------------------------------------
    Function ExistsNoLock(const ValueName: String): Boolean; virtual;
    Function AddNoLock(const ValueName: String; ValueType: TUNSValueType): Boolean; virtual;
    Function RemoveNoLock(const ValueName: String): Boolean; virtual;
    procedure ClearNoLock; virtual;
    Function ListValuesNoLock(Strings: TStrings; WorkingNodeInNames: Boolean = False): Integer; virtual;
    //--- Values management (lock) ---------------------------------------------
    Function Exists(const ValueName: String): Boolean; virtual;
    Function Add(const ValueName: String; ValueType: TUNSValueType): Boolean; virtual;
    Function Remove(const ValueName: String): Boolean; virtual;
    procedure Clear; virtual;
    Function ListValues(Strings: TStrings; WorkingNodeInNames: Boolean = False): Integer; virtual;
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
  AuxTypes, ListSorters, StrRect, MemoryBuffer,
  UniSettings_Exceptions, UniSettings_Utils, UniSettings_NodeUtils,
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

{
  UNS_LV_Compare and UNS_LV_Exchange are used when sorting value list by
  addition index.
}

Function UNS_LV_CompareFunc(Context: Pointer; Index1,Index2: Integer): Integer;
begin
Result := TUNSNodeBase(TStrings(Context).Objects[Index2]).CreationIndex -
          TUNSNodeBase(TStrings(Context).Objects[Index1]).CreationIndex;
end;

//------------------------------------------------------------------------------

procedure UNS_LV_ExchangeFunc(Context: Pointer; Index1,Index2: Integer);
begin
TStrings(Context).Exchange(Index1,Index2);
end;

//==============================================================================

Function TUniSettingsBase.GetValueFormatSettings: TUNSValueFormatSettings;
begin
ReadLock;
try
  Result := fValueFormatSettings;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.GetValueFormatSettingBool(Index: Integer): Boolean;
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

procedure TUniSettingsBase.SetValueFormatSettingBool(Index: Integer; Value: Boolean);
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

Function TUniSettingsBase.GetWorkingBranch: String;
begin
ReadLock;
try
  Result := fWorkingBranch;
  UniqueString(Result);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.SetWorkingBranch(const Branch: String);
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNodeBase;
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

Function TUniSettingsBase.CreateLeafNode(ValueType: TUNSValueType; const NodeName: String; ParentNode: TUNSNodeBranch): TUNSNodeLeaf;
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
Result.CreationIndex := fCreationCounter;
Inc(fCreationCounter);
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.ConstructBranch(NodeNameParts: TUNSNameParts): TUNSNodeBranch;
var
  CurrentBranch:  TUNSNodeBranch;
  NextNode:       TUNSNodeBase;
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
            // this can also create new array item nodes
            NodeFound := CurrentBranch.FindNode(CDA_GetItem(NodeNameParts,i),NextNode);
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
                    Exit; // array items can only be created in Node.FindNode trough the use of [#N] (new array item), so return nil
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

Function TUniSettingsBase.AddNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean;
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

Function TUniSettingsBase.FindNode(NodeNameParts: TUNSNameParts): TUNSNodeBase;
begin
Result := nil;
If NodeNameParts.Valid and not NodeNameParts.ArrItemCreate and (CDA_Count(NodeNameParts) > 0) then
  If not fWorkingNode.FindNode(NodeNameParts,CDA_Low(NodeNameParts),Result) then
    Result := nil;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.FindLeafNode(NodeNameParts: TUNSNameParts; out Node: TUNSNodeBase): Boolean;
begin
Result := False;
Node := nil;
If NodeNameParts.Valid then
  begin
    Node := FindNode(NodeNameParts);
    Result := UNSIsLeafNode(Node);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUniSettingsBase.FindLeafNode(const NodeName: String; out Node: TUNSNodeBase): Boolean;
var
  NameParts:  TUNSNameParts;
begin
Result := False;
Node := nil;
If UNSNameParts(NodeName,NameParts) > 0 then
  Result := FindLeafNode(NameParts,Node);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUniSettingsBase.FindLeafNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeBase): Boolean;
begin
If FindLeafNode(NodeName,Node) then
  Result := TUNSNodeLeaf(Node).ValueType = ValueType
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.AccessLeafNode(const NodeName, Caller: String): TUNSNodeLeaf;
begin
If not FindLeafNode(NodeName,TUNSNodeBase(Result)) then
  raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.AccessLeafNodeType(const NodeName: String; ValueType: TUNSValueType; const Caller: String): TUNSNodeLeaf;
begin
If FindLeafNode(NodeName,TUNSNodeBase(Result)) then
  begin
    If Result.ValueType <> ValueType then
      raise EUNSValueTypeNotFoundException.Create(NodeName,ValueType,Self,Caller);
  end
else raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.AccessArrayLeafNode(const NodeName, Caller: String): TUNSNodePrimitiveArray;
var
  Node: TUNSNodeLeaf;
begin
If FindLeafNode(NodeName,TUNSNodeBase(Node)) then
  begin
    If UNSIsPrimitiveArrayNode(Node) then
      Result := TUNSNodePrimitiveArray(Node)
    else
      raise EUNSValueNotAnArrayException.Create(NodeName,Self,Caller);
  end
else raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.AccessLeafNodeIsArray(const NodeName, Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean;
var
  NameParts:  TUNSNameParts;
  FoundNode:  TUNSNodeBase;
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
        If not FindLeafNode(NameParts,TUNSNodeBase(Node)) then
          raise EUNSValueNotFoundException.Create(NodeName,Self,Caller);
      end;
  end
else raise EUNSException.CreateFmt('Invalid value name ("%s").',[NodeName],Self,Caller);
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.AccessLeafNodeTypeIsArray(const NodeName: String; ValueType: TUNSValueType; const Caller: String; out Node: TUNSNodeLeaf; out ValueKind: TUNSValueKind; out Index: Integer): Boolean;
begin
If AccessLeafNodeIsArray(NodeName,Caller,Node,ValueKind,Index) then
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

procedure TUniSettingsBase.ConstructionInitialization;
begin
ClearNoLock;
fParser.Initialize;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ListValuesWithNodes(List: TStrings; WorkingNodeInNames: Boolean);
var
  Sorter: TListQuickSorter;

  procedure AddNodeToListing(Node: TUNSNodeBase);
  var
    i:        Integer;
    TempStr:  String;
  begin
    If UNSIsBranchNode(Node) then
      begin
        For i := TUNSNodeBranch(Node).LowIndex to TUNSNodeBranch(Node).HighIndex do
          AddNodeToListing(TUNSNodeBranch(Node)[i]);
      end
    else
      begin
        TempStr := Node.ReconstructFullName(False);
        If WorkingNodeInNames or (fWorkingNode = fRootNode) then
          List.AddObject(TempStr,Node)
        else
          List.AddObject(Copy(TempStr,Length(fWorkingBranch) + 2,Length(TempStr)),Node)
      end;
  end;

begin
List.Clear;
AddNodeToListing(fWorkingNode);
If List.Count > 1 then
  begin
    Sorter := TListQuickSorter.Create(Pointer(List),UNS_LV_CompareFunc,UNS_LV_ExchangeFunc);
    try
      Sorter.Sort(0,Pred(List.Count));
    finally
      Sorter.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.BeginChanging;
begin
Inc(fChangeCounter);
fChanged := False;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.EndChanging;
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

procedure TUniSettingsBase.OnNodeChangeHandler(Sender: TObject; Node: TUNSNodeBase);
begin
fChanged := True;
If (fChangeCounter <= 0) then
  begin
    If UNSIsLeafNode(Node) then
      begin
        If Assigned(fOnValueChange) then
          fOnValueChange(Self,Node.FullNameStr);
        If Assigned(fOnValueChangeCB) then
          fOnValueChangeCB(Self,Node.FullNameStr);
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

constructor TUniSettingsBase.CreateInternal(RootNode: TUNSNodeBranch);
begin
inherited Create;
fValueFormatSettings := UNS_VALUEFORMATSETTINGS_DEFAULT;
fSynchronizer := TMultiReadExclusiveWriteSynchronizer.Create;
fRootNode := RootNode;
fRootNode.Master := Self;
fRootNode.OnChange := OnNodeChangeHandler;
fWorkingBranch := '';
fWorkingNode := fRootNode;
fParser := TUNSParser.Create(Self.AddNode);
fCreationCounter := 0;
fChangeCounter := 0;
fChanged := False;
fOnTreeChange := nil;
fOnTreeChangeCB := nil;
fOnValueChange := nil;
fOnValueChangeCB := nil;
end;

//==============================================================================

constructor TUniSettingsBase.Create;
begin
CreateInternal(TUNSNodeBranch.Create(UNS_NAME_ROOTNODE,nil));
end;

//------------------------------------------------------------------------------

constructor TUniSettingsBase.CreateAsCopy(Source: TUniSettingsBase);
begin
CreateInternal(TUNSNodeBranch.CreateAsCopy(Source.fRootNode,UNS_NAME_ROOTNODE,nil));
fValueFormatSettings := Source.ValueFormatSettings;
SetWorkingBranch(Source.WorkingBranch);
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.CreateCopy: TUniSettingsBase;
type
  TUNSUniSettingsClass = class of TUniSettingsBase;
begin
Result := TUNSUniSettingsClass(Self.ClassType).CreateAsCopy(Self);
end;

//------------------------------------------------------------------------------

destructor TUniSettingsBase.Destroy;
begin
Clear;
fParser.Free;
fRootNode.Free;
fSynchronizer.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ReadLock;
begin
fSynchronizer.BeginRead;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettingsBase.ReadUnlock;
begin
fSynchronizer.EndRead;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.WriteLock;
begin
fSynchronizer.BeginWrite;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.WriteUnlock;
begin
fSynchronizer.EndWrite;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.Lock;
begin
WriteLock;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.Unlock;
begin
WriteUnlock;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromLineNoLock(const Line: String);
begin
ConstructionInitialization;
AppendFromLineNoLock(Line);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromLinesNoLock(Lines: TStrings);
begin
ConstructionInitialization;
AppendFromLinesNoLock(Lines);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromTextNoLock(const Text: String);
begin
ConstructionInitialization;
AppendFromTextNoLock(Text);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromStreamNoLock(Stream: TStream);
begin
ConstructionInitialization;
AppendFromStreamNoLock(Stream);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromCompressedStreamNoLock(Stream: TStream);
begin
ConstructionInitialization;
AppendFromCompressedStreamNoLock(Stream);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromFileNoLock(const FileName: String);
begin
ConstructionInitialization;
AppendFromFileNoLock(FileName);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromCompressedFileNoLock(const FileName: String);
begin
ConstructionInitialization;
AppendFromCompressedFileNoLock(FileName);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromResourceNoLock(const ResourceName: String);
begin
ConstructionInitialization;
AppendFromResourceNoLock(ResourceName);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromCompressedResourceNoLock(const ResourceName: String);
begin
ConstructionInitialization;
AppendFromCompressedResourceNoLock(ResourceName);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromLineNoLock(const Line: String);
begin
fParser.ParseLine(Line);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromLinesNoLock(Lines: TStrings);
begin
fParser.ParseLines(Lines);
end;
 
//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromTextNoLock(const Text: String);
begin
fParser.ParseText(Text);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromStreamNoLock(Stream: TStream);
begin
fParser.ParseStream(Stream);
end;
 
//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromCompressedStreamNoLock(Stream: TStream);
begin
fParser.ParseCompressedStream(Stream);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromFileNoLock(const FileName: String);
var
  FileStream: TFileStream;
begin
FileStream := TFileStream.Create(StrToRTL(FileName),fmOpenRead or fmShareDenyWrite);
try
  AppendFromStreamNoLock(FileStream);
finally
  FileStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromCompressedFileNoLock(const FileName: String);
var
  FileStream: TFileStream;
begin
FileStream := TFileStream.Create(StrToRTL(FileName),fmOpenRead or fmShareDenyWrite);
try
  AppendFromCompressedStreamNoLock(FileStream);
finally
  FileStream.Free;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromResourceNoLock(const ResourceName: String);
var
  ResourceStream: TResourceStream;
begin
ResourceStream := TResourceStream.Create(hInstance,StrToRTL(ResourceName),PChar(10){RT_RCDATA});
try
  AppendFromStreamNoLock(ResourceStream);
finally
  ResourceStream.Free;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromCompressedResourceNoLock(const ResourceName: String);
var
  ResourceStream: TResourceStream;
begin
ResourceStream := TResourceStream.Create(hInstance,StrToRTL(ResourceName),PChar(10){RT_RCDATA});
try
  AppendFromCompressedStreamNoLock(ResourceStream);
finally
  ResourceStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromLine(const Line: String);
begin
WriteLock;
try
  ConstructFromLineNoLock(Line);
finally
  WriteUnlock;
end;
end;  

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromLines(Lines: TStrings);
begin
WriteLock;
try
  ConstructFromLinesNoLock(Lines);
finally
  WriteUnlock;
end;
end;      

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromText(const Text: String);
begin
WriteLock;
try
  ConstructFromTextNoLock(Text);
finally
  WriteUnlock;
end;
end;  

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromStream(Stream: TStream);
begin
WriteLock;
try
  ConstructFromStreamNoLock(Stream);
finally
  WriteUnlock;
end;
end;   

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromCompressedStream(Stream: TStream);
begin
WriteLock;
try
  ConstructFromCompressedStreamNoLock(Stream);
finally
  WriteUnlock;
end;
end;        

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromFile(const FileName: String);
begin
WriteLock;
try
  ConstructFromFileNoLock(FileName);
finally
  WriteUnlock;
end;
end;   

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromCompressedFile(const FileName: String);
begin
WriteLock;
try
  ConstructFromCompressedFileNoLock(FileName);
finally
  WriteUnlock;
end;
end;  

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromResource(const ResourceName: String);
begin
WriteLock;
try
  ConstructFromResourceNoLock(ResourceName);
finally
  WriteUnlock;
end;
end;    

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ConstructFromCompressedResource(const ResourceName: String);
begin
WriteLock;
try
  ConstructFromCompressedResourceNoLock(ResourceName);
finally
  WriteUnlock;
end;
end;  

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromLine(const Line: String);
begin
WriteLock;
try
  AppendFromLineNoLock(Line);
finally
  WriteUnlock;
end;
end;    

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromLines(Lines: TStrings);
begin
WriteLock;
try
  AppendFromLinesNoLock(Lines);
finally
  WriteUnlock;
end;
end;    

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromText(const Text: String);
begin
WriteLock;
try
  AppendFromTextNoLock(Text);
finally
  WriteUnlock;
end;
end;      

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromStream(Stream: TStream);
begin
WriteLock;
try
  AppendFromStreamNoLock(Stream);
finally
  WriteUnlock;
end;
end;    

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromCompressedStream(Stream: TStream);
begin
WriteLock;
try
  AppendFromCompressedStreamNoLock(Stream);
finally
  WriteUnlock;
end;
end;         

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromFile(const FileName: String);
begin
WriteLock;
try
  AppendFromFileNoLock(FileName);
finally
  WriteUnlock;
end;
end;       

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromCompressedFile(const FileName: String);
begin
WriteLock;
try
  AppendFromCompressedFileNoLock(FileName);
finally
  WriteUnlock;
end;
end;          

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromResource(const ResourceName: String);
begin
WriteLock;
try
  AppendFromResourceNoLock(ResourceName);
finally
  WriteUnlock;
end;
end;      

//------------------------------------------------------------------------------

procedure TUniSettingsBase.AppendFromCompressedResource(const ResourceName: String);
begin
WriteLock;
try
  AppendFromCompressedResourceNoLock(ResourceName);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.SaveToIniNoLock(Ini: TIniFileEx);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;

  procedure WriteArrayValue(Node: TUNSNodePrimitiveArray);
  var
    ii: Integer;
  begin
    Ini.WriteInteger(Section,Key,Node.Count);
    case Node.ValueType of
      vtAoBool:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteBool(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoBool(Node).Items[ii]);
      vtAoInt8:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInt8(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt8(Node).Items[ii]);
      vtAoUInt8:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteUInt8(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt8(Node).Items[ii]);
      vtAoInt16:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInt16(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt16(Node).Items[ii]);
      vtAoUInt16:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteUInt16(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt16(Node).Items[ii]);
      vtAoInt32:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInt32(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt32(Node).Items[ii]);
      vtAoUInt32:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteUInt32(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt32(Node).Items[ii]);
      vtAoInt64:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInt64(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt64(Node).Items[ii]);
      vtAoUInt64:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteUInt64(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt64(Node).Items[ii]);
      vtAoFloat32:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteFloat32(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoFloat32(Node).Items[ii]);
      vtAoFloat64:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteFloat64(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoFloat64(Node).Items[ii]);
      vtAoDate:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteDate(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoDate(Node).Items[ii]);
      vtAoTime:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteTime(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoTime(Node).Items[ii]);
      vtAoDateTime: For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteDateTime(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoDateTime(Node).Items[ii]);
      vtAoText:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoText(Node).Items[ii]);
      vtAoBuffer:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteBinaryMemory(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoBuffer(Node).Items[ii].Memory,
                                            TUNSNodeAoBuffer(Node).Items[ii].Size,True);
    else
      raise EUNSException.CreateFmt('Invalid node value type (%d).',
        [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'SaveToIniNoLock.WriteArrayValue');
    end;
  end;

begin
If (Ini.SectionStartChar = '[') and (Ini.SectionEndChar = ']') then
  begin
    NodeList := TStringList.Create;
    try
      ListValuesWithNodes(NodeList,False);
      For i := 0 to Pred(NodeList.Count) do
        If NodeList.Objects[i] is TUNSNodeBase then
          If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
            begin
              Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
              Section := UNSIniSectionEncode(Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
              If not UNSIsPrimitiveArrayNode(TUNSNodeBase(NodeList.Objects[i])) then
                case TUNSNodeLeaf(NodeList.Objects[i]).ValueType of
                  vtBlank:      Ini.WriteString(Section,Key,'');
                  vtBool:       Ini.WriteBool(Section,Key,TUNSNodeBool(NodeList.Objects[i]).Value);
                  vtInt8:       Ini.WriteInt8(Section,Key,TUNSNodeInt8(NodeList.Objects[i]).Value);
                  vtUInt8:      Ini.WriteUInt8(Section,Key,TUNSNodeUInt8(NodeList.Objects[i]).Value);
                  vtInt16:      Ini.WriteInt16(Section,Key,TUNSNodeInt16(NodeList.Objects[i]).Value);
                  vtUInt16:     Ini.WriteUInt16(Section,Key,TUNSNodeUInt16(NodeList.Objects[i]).Value);
                  vtInt32:      Ini.WriteInt32(Section,Key,TUNSNodeInt32(NodeList.Objects[i]).Value);
                  vtUInt32:     Ini.WriteUInt32(Section,Key,TUNSNodeUInt32(NodeList.Objects[i]).Value);
                  vtInt64:      Ini.WriteInt64(Section,Key,TUNSNodeInt64(NodeList.Objects[i]).Value);
                  vtUInt64:     Ini.WriteUInt64(Section,Key,TUNSNodeUInt64(NodeList.Objects[i]).Value);
                  vtFloat32:    Ini.WriteFloat32(Section,Key,TUNSNodeFloat32(NodeList.Objects[i]).Value);
                  vtFloat64:    Ini.WriteFloat64(Section,Key,TUNSNodeFloat64(NodeList.Objects[i]).Value);
                  vtDate:       Ini.WriteDate(Section,Key,TUNSNodeDate(NodeList.Objects[i]).Value);
                  vtTime:       Ini.WriteTime(Section,Key,TUNSNodeTime(NodeList.Objects[i]).Value);
                  vtDateTime:   Ini.WriteDateTime(Section,Key,TUNSNodeDateTime(NodeList.Objects[i]).Value);
                  vtText:       Ini.WriteString(Section,Key,TUNSNodeText(NodeList.Objects[i]).Value);
                  vtBuffer:     Ini.WriteBinaryMemory(Section,Key,TUNSNodeBuffer(NodeList.Objects[i]).Value.Memory,
                                                      TUNSNodeBuffer(NodeList.Objects[i]).Value.Size,True);
                else
                 {vtUndefined}
                  raise EUNSException.CreateFmt('Invalid node value type (%d).',
                    [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'SaveToIniNoLock');
                end
              else WriteArrayValue(TUNSNodePrimitiveArray(NodeList.Objects[i]));
            end;  
    finally
      NodeList.Free;
    end;
  end
else EUNSException.Create('Invalid ini file.',Self,'SaveToIniNoLock');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsBase.SaveToIniNoLock(Ini: TIniFile);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;

  procedure WriteArrayValue(Node: TUNSNodePrimitiveArray);
  var
    ii: Integer;
  begin
    Ini.WriteInteger(Section,Key,Node.Count);
    case Node.ValueType of
      vtAoBool:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteBool(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoBool(Node).Items[ii]);
      vtAoInt8:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoInt8(Node).Items[ii]));
      vtAoUInt8:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoUInt8(Node).Items[ii]));
      vtAoInt16:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoInt16(Node).Items[ii]));
      vtAoUInt16:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoUInt16(Node).Items[ii]));
      vtAoInt32:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoInt32(Node).Items[ii]));
      vtAoUInt32:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoUInt32(Node).Items[ii]));
      vtAoInt64:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt64(Node).AsString(ii,vkActual));
      vtAoUInt64:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt64(Node).AsString(ii,vkActual));
      vtAoFloat32:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteFloat(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoFloat32(Node).Items[ii]);
      vtAoFloat64:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteFloat(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoFloat64(Node).Items[ii]);
      vtAoDate:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteDate(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoDate(Node).Items[ii]);
      vtAoTime:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteTime(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoTime(Node).Items[ii]);
      vtAoDateTime: For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteDateTime(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoDateTime(Node).Items[ii]);
      vtAoText:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoText(Node).Items[ii]);
      vtAoBuffer:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoBuffer(Node).AsString(ii,vkActual));
    else
      raise EUNSException.CreateFmt('Invalid node value type (%d).',
        [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'SaveToIniNoLock.WriteArrayValue');
    end;
  end;

begin
NodeList := TStringList.Create;
try
  ListValuesWithNodes(NodeList,False);
  For i := 0 to Pred(NodeList.Count) do
    If NodeList.Objects[i] is TUNSNodeBase then
      If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
        begin
          Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
          Section := UNSIniSectionEncode(Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
          If Length(Section) <= 0 then
            Section := '*'; // windows does not like empty section name
          If not UNSIsPrimitiveArrayNode(TUNSNodeBase(NodeList.Objects[i])) then
            case TUNSNodeLeaf(NodeList.Objects[i]).ValueType of
              vtBlank:      Ini.WriteString(Section,Key,'');
              vtBool:       Ini.WriteBool(Section,Key,TUNSNodeBool(NodeList.Objects[i]).Value);
              vtInt8:       Ini.WriteInteger(Section,Key,Integer(TUNSNodeInt8(NodeList.Objects[i]).Value));
              vtUInt8:      Ini.WriteInteger(Section,Key,Integer(TUNSNodeUInt8(NodeList.Objects[i]).Value));
              vtInt16:      Ini.WriteInteger(Section,Key,Integer(TUNSNodeInt16(NodeList.Objects[i]).Value));
              vtUInt16:     Ini.WriteInteger(Section,Key,Integer(TUNSNodeUInt16(NodeList.Objects[i]).Value));
              vtInt32:      Ini.WriteInteger(Section,Key,Integer(TUNSNodeInt32(NodeList.Objects[i]).Value));
              vtUInt32:     Ini.WriteInteger(Section,Key,Integer(TUNSNodeUInt32(NodeList.Objects[i]).Value));
              vtInt64:      Ini.WriteString(Section,Key,TUNSNodeInt64(NodeList.Objects[i]).AsString(vkActual));
              vtUInt64:     Ini.WriteString(Section,Key,TUNSNodeUInt64(NodeList.Objects[i]).AsString(vkActual));
              vtFloat32:    Ini.WriteFloat(Section,Key,TUNSNodeFloat32(NodeList.Objects[i]).Value);
              vtFloat64:    Ini.WriteFloat(Section,Key,TUNSNodeFloat64(NodeList.Objects[i]).Value);
              vtDate:       Ini.WriteDate(Section,Key,TUNSNodeDate(NodeList.Objects[i]).Value);
              vtTime:       Ini.WriteTime(Section,Key,TUNSNodeTime(NodeList.Objects[i]).Value);
              vtDateTime:   Ini.WriteDateTime(Section,Key,TUNSNodeDateTime(NodeList.Objects[i]).Value);
              vtText:       Ini.WriteString(Section,Key,TUNSNodeText(NodeList.Objects[i]).Value);
              vtBuffer:     Ini.WriteString(Section,Key,TUNSNodeBuffer(NodeList.Objects[i]).AsString(vkActual));
            else
             {vtUndefined}
              raise EUNSException.CreateFmt('Invalid node value type (%d).',
                [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'SaveToIniNoLock');
            end
          else WriteArrayValue(TUNSNodePrimitiveArray(NodeList.Objects[i]));
        end;  
finally
  NodeList.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.LoadFromIniNoLock(Ini: TIniFileEx);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;
  Buffer:   TMemoryBuffer;

  procedure ReadArrayValue(Node: TUNSNodePrimitiveArray);
  var
    ii: Integer;
  begin
    Node.PrepareEmptyItems(Ini.ReadInteger(Section,Key),vkActual);
    case Node.ValueType of
      vtAoBool:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoBool(Node).Items[ii] := Ini.ReadBool(Section,Format('%s[%d]',[Key,ii]));
      vtAoInt8:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt8(Node).Items[ii] := Ini.ReadInt8(Section,Format('%s[%d]',[Key,ii]));
      vtAoUInt8:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt8(Node).Items[ii] := Ini.ReadUInt8(Section,Format('%s[%d]',[Key,ii]));
      vtAoInt16:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt16(Node).Items[ii] := Ini.ReadInt16(Section,Format('%s[%d]',[Key,ii]));
      vtAoUInt16:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt16(Node).Items[ii] := Ini.ReadUInt16(Section,Format('%s[%d]',[Key,ii]));
      vtAoInt32:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt32(Node).Items[ii] := Ini.ReadInt32(Section,Format('%s[%d]',[Key,ii]));
      vtAoUInt32:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt32(Node).Items[ii] := Ini.ReadUInt32(Section,Format('%s[%d]',[Key,ii]));
      vtAoInt64:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt64(Node).Items[ii] := Ini.ReadInt64(Section,Format('%s[%d]',[Key,ii]));
      vtAoUInt64:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt64(Node).Items[ii] := Ini.ReadUInt64(Section,Format('%s[%d]',[Key,ii]));
      vtAoFloat32:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoFloat32(Node).Items[ii] := Ini.ReadFloat32(Section,Format('%s[%d]',[Key,ii]));
      vtAoFloat64:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoFloat64(Node).Items[ii] := Ini.ReadFloat64(Section,Format('%s[%d]',[Key,ii]));
      vtAoDate:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoDate(Node).Items[ii] := Ini.ReadDate(Section,Format('%s[%d]',[Key,ii]));
      vtAoTime:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoTime(Node).Items[ii] := Ini.ReadTime(Section,Format('%s[%d]',[Key,ii]));
      vtAoDateTime: For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoDateTime(Node).Items[ii] := Ini.ReadDateTime(Section,Format('%s[%d]',[Key,ii]));
      vtAoText:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoText(Node).Items[ii] := Ini.ReadString(Section,Format('%s[%d]',[Key,ii]));
      vtAoBuffer:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      begin
                        Buffer.Size := Ini.ReadBinaryMemory(Section,Format('%s[%d]',[Key,ii]),Buffer.Memory,True);
                        try
                          TUNSNodeAoBuffer(NodeList.Objects[i]).Items[ii] := Buffer;
                        finally
                          FreeBuffer(Buffer);
                        end;
                      end;
    else
      raise EUNSException.CreateFmt('Invalid node value type (%d).',
        [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'LoadFromIniNoLock.ReadArrayValue');
    end;
  end;

begin
If (Ini.SectionStartChar = '[') and (Ini.SectionEndChar = ']') then
  begin
    NodeList := TStringList.Create;
    try
      InitBuffer(Buffer);
      ListValuesWithNodes(NodeList,False);
      For i := 0 to Pred(NodeList.Count) do
        If NodeList.Objects[i] is TUNSNodeBase then
          If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
            begin
              Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
              Section := UNSIniSectionEncode(Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
              BeginChanging;
              try
                If not UNSIsPrimitiveArrayNode(TUNSNodeBase(NodeList.Objects[i])) then
                  case TUNSNodeLeaf(NodeList.Objects[i]).ValueType of
                    vtBlank:      ; // do nothing
                    vtBool:       TUNSNodeBool(NodeList.Objects[i]).Value := Ini.ReadBool(Section,Key);
                    vtInt8:       TUNSNodeInt8(NodeList.Objects[i]).Value := Ini.ReadInt8(Section,Key);
                    vtUInt8:      TUNSNodeUInt8(NodeList.Objects[i]).Value := Ini.ReadUInt8(Section,Key);
                    vtInt16:      TUNSNodeInt16(NodeList.Objects[i]).Value := Ini.ReadInt16(Section,Key);
                    vtUInt16:     TUNSNodeUInt16(NodeList.Objects[i]).Value := Ini.ReadUInt16(Section,Key);
                    vtInt32:      TUNSNodeInt32(NodeList.Objects[i]).Value := Ini.ReadInt32(Section,Key);
                    vtUInt32:     TUNSNodeUInt32(NodeList.Objects[i]).Value := Ini.ReadUInt32(Section,Key);
                    vtInt64:      TUNSNodeInt64(NodeList.Objects[i]).Value := Ini.ReadInt64(Section,Key);
                    vtUInt64:     TUNSNodeUInt64(NodeList.Objects[i]).Value := Ini.ReadUInt64(Section,Key);
                    vtFloat32:    TUNSNodeFloat32(NodeList.Objects[i]).Value := Ini.ReadFloat32(Section,Key);
                    vtFloat64:    TUNSNodeFloat64(NodeList.Objects[i]).Value := Ini.ReadFloat64(Section,Key);
                    vtDate:       TUNSNodeDate(NodeList.Objects[i]).Value := Ini.ReadDate(Section,Key);
                    vtTime:       TUNSNodeTime(NodeList.Objects[i]).Value := Ini.ReadTime(Section,Key);
                    vtDateTime:   TUNSNodeDateTime(NodeList.Objects[i]).Value := Ini.ReadDateTime(Section,Key);
                    vtText:       TUNSNodeText(NodeList.Objects[i]).Value := Ini.ReadString(Section,Key);
                    vtBuffer:     begin
                                    Buffer.Size := Ini.ReadBinaryMemory(Section,Key,Buffer.Memory,False);
                                    try
                                      TUNSNodeBuffer(NodeList.Objects[i]).Value := Buffer;
                                    finally
                                      FreeBuffer(Buffer);
                                    end;
                                  end;
                  else
                   {vtUndefined}
                    raise EUNSException.CreateFmt('Invalid node value type (%d).',
                      [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'LoadFromIniNoLock');
                  end
                else ReadArrayValue(TUNSNodePrimitiveArray(NodeList.Objects[i]));
              finally
                EndChanging;
              end;
            end;  
    finally
      NodeList.Free;
    end;
  end
else EUNSException.Create('Invalid ini file.',Self,'LoadFromIniNoLock');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsBase.LoadFromIniNoLock(Ini: TIniFile);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;

  procedure ReadArrayValue(Node: TUNSNodePrimitiveArray);
  var
    ii: Integer;
  begin
    Node.PrepareEmptyItems(Ini.ReadInteger(Section,Key,0),vkActual);
    case Node.ValueType of
      vtAoBool:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoBool(Node).Items[ii] := Ini.ReadBool(Section,Format('%s[%d]',[Key,ii]),False);
      vtAoInt8:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt8(Node).Items[ii] := Int8(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoUInt8:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt8(Node).Items[ii] := UInt8(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoInt16:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt16(Node).Items[ii] := Int16(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoUInt16:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt16(Node).Items[ii] := Uint16(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoInt32:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt32(Node).Items[ii] := Int32(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoUInt32:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt32(Node).Items[ii] := Uint32(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoInt64:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt64(Node).FromString(ii,Ini.ReadString(Section,Format('%s[%d]',[Key,ii]),'0'),vkActual);
      vtAoUInt64:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt64(Node).FromString(ii,Ini.ReadString(Section,Format('%s[%d]',[Key,ii]),'0'),vkActual);
      vtAoFloat32:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoFloat32(Node).Items[ii] := Ini.ReadFloat(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoFloat64:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoFloat64(Node).Items[ii] := Ini.ReadFloat(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoDate:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoDate(Node).Items[ii] := Ini.ReadDate(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoTime:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoTime(Node).Items[ii] := Ini.ReadTime(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoDateTime: For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoDateTime(Node).Items[ii] := Ini.ReadDateTime(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoText:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoText(Node).Items[ii] := Ini.ReadString(Section,Format('%s[%d]',[Key,ii]),'');
      vtAoBuffer:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoBuffer(NodeList.Objects[i]).FromString(ii,Ini.ReadString(Section,Format('%s[%d]',[Key,ii]),''));
    else
      raise EUNSException.CreateFmt('Invalid node value type (%d).',
        [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'LoadFromIniNoLock.ReadArrayValue');
    end;
  end;

begin
NodeList := TStringList.Create;
try
  ListValuesWithNodes(NodeList,False);
  For i := 0 to Pred(NodeList.Count) do
    If NodeList.Objects[i] is TUNSNodeBase then
      If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
        begin
          Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
          Section := UNSIniSectionEncode(Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
          BeginChanging;
          try
            If not UNSIsPrimitiveArrayNode(TUNSNodeBase(NodeList.Objects[i])) then
              case TUNSNodeLeaf(NodeList.Objects[i]).ValueType of
                vtBlank:      ; // do nothing
                vtBool:       TUNSNodeBool(NodeList.Objects[i]).Value := Ini.ReadBool(Section,Key,False);
                vtInt8:       TUNSNodeInt8(NodeList.Objects[i]).Value := Int8(Ini.ReadInteger(Section,Key,0));
                vtUInt8:      TUNSNodeUInt8(NodeList.Objects[i]).Value := UInt8(Ini.ReadInteger(Section,Key,0));
                vtInt16:      TUNSNodeInt16(NodeList.Objects[i]).Value := Int16(Ini.ReadInteger(Section,Key,0));
                vtUInt16:     TUNSNodeUInt16(NodeList.Objects[i]).Value := UInt16(Ini.ReadInteger(Section,Key,0));
                vtInt32:      TUNSNodeInt32(NodeList.Objects[i]).Value := Int32(Ini.ReadInteger(Section,Key,0));
                vtUInt32:     TUNSNodeUInt32(NodeList.Objects[i]).Value := UInt32(Ini.ReadInteger(Section,Key,0));
                vtInt64:      TUNSNodeInt64(NodeList.Objects[i]).FromString(Ini.ReadString(Section,Key,'0'),vkActual);
                vtUInt64:     TUNSNodeUInt64(NodeList.Objects[i]).FromString(Ini.ReadString(Section,Key,'0'),vkActual);
                vtFloat32:    TUNSNodeFloat32(NodeList.Objects[i]).Value := Ini.ReadFloat(Section,Key,0.0);
                vtFloat64:    TUNSNodeFloat64(NodeList.Objects[i]).Value := Ini.ReadFloat(Section,Key,0.0);
                vtDate:       TUNSNodeDate(NodeList.Objects[i]).Value := Ini.ReadDate(Section,Key,0.0);
                vtTime:       TUNSNodeTime(NodeList.Objects[i]).Value := Ini.ReadTime(Section,Key,0.0);
                vtDateTime:   TUNSNodeDateTime(NodeList.Objects[i]).Value := Ini.ReadDateTime(Section,Key,0.0);
                vtText:       TUNSNodeText(NodeList.Objects[i]).Value := Ini.ReadString(Section,Key,'');
                vtBuffer:     TUNSNodeBuffer(NodeList.Objects[i]).FromString(Ini.ReadString(Section,Key,''),vkActual);
              else
               {vtUndefined}
                raise EUNSException.CreateFmt('Invalid node value type (%d).',
                  [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'LoadFromIniNoLock');
              end
            else ReadArrayValue(TUNSNodePrimitiveArray(NodeList.Objects[i]));
          finally
            EndChanging;
          end;
        end;  
finally
  NodeList.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.SaveToIni(Ini: TIniFileEx);
begin
ReadLock;
try
  SaveToIniNoLock(Ini);
finally
  ReadUnlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsBase.SaveToIni(Ini: TIniFile);
begin
ReadLock;
try
  SaveToIniNoLock(Ini);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.LoadFromIni(Ini: TIniFileEx);
begin
WriteLock;
try
  LoadFromIniNoLock(Ini);
finally
  WriteUnlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsBase.LoadFromIni(Ini: TIniFile);
begin
WriteLock;
try
  LoadFromIniNoLock(Ini);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.ExistsNoLock(const ValueName: String): Boolean;
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNodeBase;
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
    else Result := FindLeafNode(NameParts,Node);
  end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.AddNoLock(const ValueName: String; ValueType: TUNSValueType): Boolean;
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

Function TUniSettingsBase.RemoveNoLock(const ValueName: String): Boolean;
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNodeBase;

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
          If FindLeafNode(NameParts,Node) then
            If UNSIsBranchNode(Node.ParentNode) then
              Result := TUNSNodeBranch(Node.ParentNode).Remove(Node) >= 0;
        end;
    finally
      EndChanging;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ClearNoLock;
begin
BeginChanging;
try
  fWorkingNode.Clear;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.ListValuesNoLock(Strings: TStrings; WorkingNodeInNames: Boolean = False): Integer;
var
  i:  Integer;
begin
ListValuesWithNodes(Strings,WorkingNodeInNames);
// remove node references, they are not needed
For i := 0 to Pred(Strings.Count) do
  Strings.Objects[i] := nil;
Result := Strings.Count;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.Exists(const ValueName: String): Boolean;
begin
ReadLock;
try
  Result := ExistsNoLock(ValueName);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.Add(const ValueName: String; ValueType: TUNSValueType): Boolean;
begin
WriteLock;
try
  Result := AddNoLock(ValueName,ValueType);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.Remove(const ValueName: String): Boolean;
begin
WriteLock;
try
  Result := RemoveNoLock(ValueName);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.Clear;
begin
WriteLock;
try
  ClearNoLock;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.ListValues(Strings: TStrings; WorkingNodeInNames: Boolean = False): Integer;
begin
ReadLock;
try
  Result := ListValuesNoLock(Strings,WorkingNodeInNames);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ValueKindMoveNoLock(Src,Dest: TUNSValueKind);
begin
BeginChanging;
try
  fWorkingNode.ValueKindMove(Src,Dest);
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ValueKindExchangeNoLock(ValA,ValB: TUNSValueKind);
begin
BeginChanging;
try
  fWorkingNode.ValueKindExchange(ValA,ValB);
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.ValueKindCompareNoLock(ValA,ValB: TUNSValueKind): Boolean;
begin
Result := fWorkingNode.ValueKindCompare(ValA,ValB);
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ActualFromDefaultNoLock;
begin
BeginChanging;
try
  fWorkingNode.ActualFromDefault;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.DefaultFromActualNoLock;
begin
BeginChanging;
try
  fWorkingNode.DefaultFromActual;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.ExchangeActualAndDefaultNoLock;
begin
BeginChanging;
try
  fWorkingNode.ExchangeActualAndDefault;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettingsBase.ActualEqualsDefaultNoLock: Boolean;
begin
Result := fWorkingNode.ActualEqualsDefault;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.SaveNoLock;
begin
BeginChanging;
try
  fWorkingNode.Save;
finally
  EndChanging;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsBase.RestoreNoLock;
begin
BeginChanging;
try
  fWorkingNode.Restore;
finally
  EndChanging;
end;
end;

end.
