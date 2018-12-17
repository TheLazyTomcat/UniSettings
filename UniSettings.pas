(*
todo (* = completed):

  tree building
* arrays
  array nodes: listsorters -> implementation uses
  access to array items trough index in value name
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
    Function GetSubNode(NodeNamePart: TUNSNamePart; Branch: TUNSNodeBranch; out Node: TUNSNode; CanCreate: Boolean): Boolean; virtual;
    Function ConstructBranch(NodeNameParts: TUNSNameParts): TUNSNodeBranch; virtual;
    Function FindNode(NodeNameParts: TUNSNameParts): TUNSNode; virtual;
    Function AddNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean; virtual;
    Function FindLeafNode(const NodeName: String; out Node: TUNSNodeLeaf): Boolean; overload; virtual;
    Function FindLeafNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean; overload; virtual;
    Function CheckedLeafNodeAccess(const NodeName, Caller: String): TUNSNodeLeaf; virtual;
    Function CheckedLeafArrayNodeAccess(const NodeName, Caller: String): TUNSNodePrimitiveArray; virtual;
    Function CheckedLeafNodeTypeAccess(const NodeName: String; ValueType: TUNSValueType; Caller: String): TUNSNodeLeaf; virtual;
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
    //--- Common value access --------------------------------------------------
    (*
    procedure ActualFromDefault; virtual;
    procedure DefaultFromActual; virtual;
    procedure ExchangeActualAndDefault; virtual;
    Function ActualEqualsDefault: Boolean; virtual;
    procedure ValueActualFromDefault(const ValueName: String; Index: Integer = 0); virtual;
    procedure ValueDefaultFromActual(const ValueName: String; Index: Integer = 0); virtual;
    procedure ValueExchangeActualAndDefault(const ValueName: String; Index: Integer = 0); virtual;
    Function ValueActualEqualsDefault(const ValueName: String; Index: Integer = 0): Boolean; virtual;
    Function ValueFullName(const ValueName: String): String; virtual;
    Function ValueType(const ValueName: String): TUNSValueType; virtual;
    Function ValueSize(const ValueName: String; AccessDefVal: Boolean = False): TMemSize; virtual;
    Function ValueCount(const ValueName: String; AccessDefVal: Boolean = False): Integer; virtual;
    Function ValueItemSize(const ValueName: String): TMemSize; virtual;
    Function ValueAddress(const ValueName: String; AccessDefVal: Boolean = False): Pointer; virtual;
    Function ValueAsString(const ValueName: String; AccessDefVal: Boolean = False): String; virtual;
    procedure ValueFromString(const ValueName: String; const Str: String; AccessDefVal: Boolean = False); virtual;
    procedure ValueToStream(const ValueName: String; Stream: TStream; AccessDefVal: Boolean = False); virtual;
    procedure ValueFromStream(const ValueName: String; Stream: TStream; AccessDefVal: Boolean = False); virtual;
    Function ValueAsStream(const ValueName: String; AccessDefVal: Boolean = False): TMemoryStream; virtual;
    procedure ValueToBuffer(const ValueName: String; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual;
    procedure ValueFromBuffer(const ValueName: String; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual;
    Function ValueAsBuffer(const ValueName: String; AccessDefVal: Boolean = False): TMemoryBuffer; virtual;
    Function ValueItemAddress(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): Pointer; virtual;
    Function ValueItemAsString(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): String; virtual;
    procedure ValueItemFromString(const ValueName: String; Index: Integer; const Str: String; AccessDefVal: Boolean = False); virtual;
    procedure ValueItemToStream(const ValueName: String; Index: Integer; Stream: TStream; AccessDefVal: Boolean = False); virtual;
    procedure ValueItemFromStream(const ValueName: String; Index: Integer; Stream: TStream; AccessDefVal: Boolean = False); virtual;
    Function ValueItemAsStream(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): TMemoryStream; virtual;
    procedure ValueItemToBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual;
    procedure ValueItemFromBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); virtual;
    Function ValueItemAsBuffer(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): TMemoryBuffer; virtual;
    Function ValueLowIndex(const ValueName: String; AccessDefVal: Boolean = False): Integer; virtual;
    Function ValueHighIndex(const ValueName: String; AccessDefVal: Boolean = False): Integer; virtual;
    Function ValueCheckIndex(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): Boolean; virtual;
    procedure ValueExchange(const ValueName: String; Index1,Index2: Integer; AccessDefVal: Boolean = False); virtual;
    procedure ValueMove(const ValueName: String; SrcIndex,DstIndex: Integer; AccessDefVal: Boolean = False); virtual;
    procedure ValueDelete(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False); virtual;
    procedure ValueClear(const ValueName: String; AccessDefVal: Boolean = False); virtual;
    //--- Inidividual value types access ---------------------------------------
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
    property NumericBools: Boolean index UNS_VALUEFORMATSETTING_INDEX_NUMBOOL read GetValueFormatSettingBool write SetValueFormatSettingBool;
    property HexIntegers: Boolean index UNS_VALUEFORMATSETTING_INDEX_HEXINTS read GetValueFormatSettingBool write SetValueFormatSettingBool;
    property HexFloats: Boolean index UNS_VALUEFORMATSETTING_INDEX_HEXFLTS read GetValueFormatSettingBool write SetValueFormatSettingBool;
    property HexDateTime: Boolean index UNS_VALUEFORMATSETTING_INDEX_HEXDTTM read GetValueFormatSettingBool write SetValueFormatSettingBool;
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
          fWorkingBranch := Branch;
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
(*
  vtAoBool,
  vtAoInt8,
  vtAoUInt8,
  vtAoInt16,
  vtAoUInt16,
  vtAoInt32,
  vtAoUInt32,
  vtAoInt64,
  vtAoUInt64,
  vtAoFloat32,
  vtAoFloat64,
  vtAoDate,
  vtAoTime,
  vtAoDateTime,
  vtAoText,
  vtAoBuffer:;
*)
else
 {vtUndefined}
  raise EUNSException.CreateFmt('Invalid node value type (%d).',[Ord(ValueType)],Self,'CreateLeafNode');
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.GetSubNode(NodeNamePart: TUNSNamePart; Branch: TUNSNodeBranch; out Node: TUNSNode; CanCreate: Boolean): Boolean;
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
  nptArrayItemDef:
    begin
      If Branch is TUNSNodeArray then
        case NodeNamePart.PartIndex of
          UNS_NAME_ARRAYITEM_NEW:
            If CanCreate then
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
If NodeNameParts.Count > 0 then
  begin
    If NodeNameParts.Valid then
      begin
        CurrentBranch := fWorkingNode;
        For i := Low(NodeNameParts.Arr) to Pred(NodeNameParts.Count) do
          begin
            NodeFound := GetSubNode(NodeNameParts.Arr[i],CurrentBranch,NextNode,True);
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
                case NodeNameParts.Arr[i].PartType of
                  nptIdentifier:
                    NextNode := TUNSNodeBranch.Create(NodeNameParts.Arr[i].PartStr.Str,CurrentBranch);
                  nptArrayIdentifier:
                    NextNode := TUNSNodeArray.Create(NodeNameParts.Arr[i].PartStr.Str,CurrentBranch);
                  nptArrayIndex,
                  nptArrayIndexDef,
                  nptArrayItem,
                  nptArrayItemDef:
                    Exit; // array items can only be created in GetSubNode trough the use of [#N] (new array item), return nil
                else
                  raise EUNSException.CreateFmt('Invalid name part type (%d).',
                    [Ord(NodeNameParts.Arr[i].PartType)],Self,'ConstructBranch');
                end;
                CurrentBranch.Add(NextNode);
                CurrentBranch := TUNSNodeBranch(NextNode);
              end;
          end;
        Result := CurrentBranch;
      end
    else raise EUNSException.Create('Invalid name.',Self,'ConstructBranch');
  end
else Result := fRootNode;
end;

//------------------------------------------------------------------------------

Function TUniSettings.FindNode(NodeNameParts: TUNSNameParts): TUNSNode;
var
  CurrentNode:  TUNSNode;
  i:            Integer;
begin
Result := nil;
If NodeNameParts.Valid and (NodeNameParts.Count > 0) then
  begin
    CurrentNode := fWorkingNode;
    For i := Low(NodeNameParts.Arr) to Pred(NodeNameParts.Count) do
      begin
        If CurrentNode is TUNSNodeBranch then
          begin
            If not GetSubNode(NodeNameParts.Arr[i],TUNSNodeBranch(CurrentNode),CurrentNode,False) then
              Exit;
          end
        else Exit;
      end;
    Result := CurrentNode;
  end;
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
    // must not end with index or array item
    If not(NameParts.Arr[Pred(NameParts.Count)].PartType in
      [nptArrayIndex,nptArrayIndexDef,nptArrayItem,nptArrayItemDef]) then
      begin
        Dec(NameParts.Count);
        try
          BranchNode := ConstructBranch(NameParts);
        finally
          Inc(NameParts.Count);
        end;
        If Assigned(BranchNode) then
          begin
            Index := BranchNode.IndexOf(NameParts.Arr[Pred(NameParts.Count)].PartStr);
            If BranchNode.CheckIndex(Index) then
              If BranchNode[Index] is TUNSNodeBlank then
                begin
                  BranchNode.Delete(Index);
                  Index := -1;
                end;
            If not BranchNode.CheckIndex(Index) then
              begin
                Node := CreateLeafNode(ValueType,NameParts.Arr[Pred(NameParts.Count)].PartStr.Str,BranchNode);
                If BranchNode.CheckIndex(BranchNode.Add(Node)) then
                  Result := True
                else
                  FreeAndNil(Node);
              end;
          end;
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
      If NameParts.Arr[Pred(NameParts.Count)].PartType in
        [nptArrayIndex,nptArrayIndexDef,nptArrayItem,nptArrayItemDef] then
        begin
          // last name part is an index
          Dec(NameParts.Count);
          try
            Node := FindNode(NameParts);
          finally
            Inc(NameParts.Count);
          end;
          If Node is TUNSNodePrimitiveArray then
            with NameParts.Arr[Pred(NameParts.Count)] do
              begin
                case NameParts.Arr[Pred(NameParts.Count)].PartType of
                  //nptArrayIndex:
                    //Result := TUNSNodePrimitiveArray(Node).CheckIndex(PartIndex,False);
                  //nptArrayIndexDef:
                    //Result := TUNSNodePrimitiveArray(Node).CheckIndex(PartIndex,True);
                  nptArrayItem:
                    If PartIndex in [UNS_NAME_ARRAYITEM_LOW,UNS_NAME_ARRAYITEM_HIGH] then
                      Result := TUNSNodePrimitiveArray(Node).Count > 0;
                  nptArrayItemDef:
                    If PartIndex in [UNS_NAME_ARRAYITEM_LOW,UNS_NAME_ARRAYITEM_HIGH] then
                      Result := TUNSNodePrimitiveArray(Node).DefaultCount > 0;
                end;
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
  Result := AddNode(ValueName,ValueType,NewNode);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.Remove(const ValueName: String): Boolean;
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNode;
begin
WriteLock;
try
  Result := False;
  If UNSNameParts(ValueName,NameParts) > 0 then
    // must not end with index or array item
    If not(NameParts.Arr[Pred(NameParts.Count)].PartType in
      [nptArrayIndex,nptArrayIndexDef,nptArrayItem,nptArrayItemDef]) then
      begin
        Node := FindNode(NameParts);
        If Node.ParentNode is TUNSNodeBranch then
          Result := TUNSNodeBranch(Node.ParentNode).Remove(Node) >= 0;
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
    fRootNode.Clear;
  finally
    ChangingEnd;
  end;
  fWorkingBranch := '';
  fWorkingNode := fRootNode;
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
(*
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
ReadLock;
try
  Result := fWorkingNode.ActualEqualsDefault;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueActualFromDefault(const ValueName: String; Index: Integer = 0);
var
  Node: TUNSNodeLeaf;
begin
WriteLock;
try
  If FindLeafNode(ValueName,Node) then
    begin
      If Node.IsPrimitiveArray then
        TUNSNodePrimitiveArray(Node).ItemActualFromDefault(Index)
      else
        Node.ActualFromDefault;
    end
  else raise EUNSValueNotFoundException.Create(ValueName,Self,'ValueActualFromDefault');
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueDefaultFromActual(const ValueName: String; Index: Integer = 0);
var
  Node: TUNSNodeLeaf;
begin
WriteLock;
try
  If FindLeafNode(ValueName,Node) then
    begin
      If Node.IsPrimitiveArray then
        TUNSNodePrimitiveArray(Node).ItemDefaultFromActual(Index)
      else
        Node.DefaultFromActual;
    end
  else raise EUNSValueNotFoundException.Create(ValueName,Self,'ValueDefaultFromActual');
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchangeActualAndDefault(const ValueName: String; Index: Integer = 0);
var
  Node: TUNSNodeLeaf;
begin
WriteLock;
try
  If FindLeafNode(ValueName,Node) then
    begin
      If Node.IsPrimitiveArray then
        TUNSNodePrimitiveArray(Node).ItemExchangeActualAndDefault(Index)
      else
        Node.ExchangeActualAndDefault;
    end
  else raise EUNSValueNotFoundException.Create(ValueName,Self,'ValueExchangeActualAndDefault');
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueActualEqualsDefault(const ValueName: String; Index: Integer = 0): Boolean;
var
  Node: TUNSNodeLeaf;
begin
ReadLock;
try
  Result := False;
  If FindLeafNode(ValueName,Node) then
    begin
      If Node.IsPrimitiveArray then
        Result := TUNSNodePrimitiveArray(Node).ItemActualEqualsDefault(Index)
      else
        Result := Node.ActualEqualsDefault;
    end
  else raise EUNSValueNotFoundException.Create(ValueName,Self,'ValueActualEqualsDefault');
finally
  ReadUnlock;
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
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueDataType').ValueType;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueSize(const ValueName: String; AccessDefVal: Boolean = False): TMemSize;
begin
ReadLock;
try
  with CheckedLeafNodeAccess(ValueName,'ValueSize') do
    If AccessDefVal then
      Result := DefaultValueSize
    else
      Result := ValueSize;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueCount(const ValueName: String; AccessDefVal: Boolean = False): Integer;
begin
ReadLock;
try
  with CheckedLeafArrayNodeAccess(ValueName,'ValueCount') do
    If AccessDefVal then
      Result := DefaultValueSize
    else
      Result := ValueSize;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemSize(const ValueName: String): TMemSize;
begin
ReadLock;
try
  //Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemSize').ValueItemSize;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAddress(const ValueName: String; AccessDefVal: Boolean = False): Pointer;
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueAddress').Address(AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsString(const ValueName: String; AccessDefVal: Boolean = False): String;
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueAsString').AsString(AccessDefVal)
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromString(const ValueName: String; const Str: String; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueFromString').FromString(Str,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueToStream(const ValueName: String; Stream: TStream; AccessDefVal: Boolean = False);
begin
ReadLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueToStream').ToStream(Stream,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromStream(const ValueName: String; Stream: TStream; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueFromStream').FromStream(Stream,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsStream(const ValueName: String; AccessDefVal: Boolean = False): TMemoryStream;
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueAsStream').AsStream(AccessDefVal);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueToBuffer(const ValueName: String; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
ReadLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueToBuffer').ToBuffer(Buffer,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromBuffer(const ValueName: String; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueFromBuffer').FromBuffer(Buffer,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsBuffer(const ValueName: String; AccessDefVal: Boolean = False): TMemoryBuffer;
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueFromBuffer').AsBuffer(AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAddress(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): Pointer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAddress').ItemAddress(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsString(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): String;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsString').ItemAsString(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromString(const ValueName: String; Index: Integer; const Str: String; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromString').ItemFromString(Index,Str,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToStream(const ValueName: String; Index: Integer; Stream: TStream; AccessDefVal: Boolean = False);
begin
ReadLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemToStream').ItemToStream(Index,Stream,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromStream(const ValueName: String; Index: Integer; Stream: TStream; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromStream').ItemFromStream(Index,Stream,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsStream(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): TMemoryStream;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsStream').ItemAsStream(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
ReadLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemToBuffer').ItemToBuffer(Index,Buffer,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromBuffer').ItemFromBuffer(Index,Buffer,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsBuffer(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): TMemoryBuffer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsBuffer').ItemAsBuffer(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueLowIndex(const ValueName: String; AccessDefVal: Boolean = False): Integer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueLowIndex').LowIndex(AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueHighIndex(const ValueName: String; AccessDefVal: Boolean = False): Integer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueHighIndex').HighIndex(AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueCheckIndex(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): Boolean;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueCheckIndex').CheckIndex(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchange(const ValueName: String; Index1,Index2: Integer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueExchange').Exchange(Index1,Index2,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueMove(const ValueName: String; SrcIndex,DstIndex: Integer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueMove').Move(SrcIndex,DstIndex,AccessDefVal);
finally
  WriteUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueDelete(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueDelete').Delete(Index,AccessDefVal);
finally
  WriteUnlock;
end;
end;
  
//------------------------------------------------------------------------------

procedure TUniSettings.ValueClear(const ValueName: String; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueClear').Clear(AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

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
