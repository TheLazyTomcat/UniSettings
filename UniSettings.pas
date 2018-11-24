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
    fFormatSettings:  TUNSFormatSettings;
    fSynchronizer:    TMultiReadExclusiveWriteSynchronizer;
    fRootNode:        TUNSNodeBranch;
    fWorkingPath:     String;
    fWorkingNode:     TUNSNodeBranch;
    fOnChange:        TNotifyEvent;
    Function GetWorkingPath: String;
    procedure SetWorkingPath(const Path: String);
  protected
    Function CreateLeafNode(ValueType: TUNSValueType; const NodeName: String; ParentNode: TUNSNodeBranch): TUNSNodeLeaf; virtual;
    Function GetSubNode(NodeNamePart: TUNSNamePart; Branch: TUNSNodeBranch; out Node: TUNSNode; CanCreate: Boolean): Boolean; virtual;
    Function ConstructPath(NodeNameParts: TUNSNameParts): TUNSNodeBranch; virtual;
    Function FindNode(NodeNameParts: TUNSNameParts): TUNSNode; virtual;
    Function AddNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean; virtual;
    Function FindLeafNode(const NodeName: String; out Node: TUNSNodeLeaf): Boolean; overload; virtual;
    Function FindLeafNode(const NodeName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean; overload; virtual;
    Function CheckedLeafNodeAccess(const NodeName, Caller: String): TUNSNodeLeaf; virtual;
    Function CheckedLeafArrayNodeAccess(const NodeName, Caller: String): TUNSNodePrimitiveArray; virtual;
    Function CheckedLeafNodeTypeAccess(const NodeName: String; ValueType: TUNSValueType; Caller: String): TUNSNodeLeaf; virtual;
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
    procedure ActualFromDefault; virtual;
    procedure DefaultFromActual; virtual;
    procedure ExchangeActualAndDefault; virtual;
    Function ActualEqualsDefault: Boolean; virtual;
    procedure ValueActualFromDefault(const ValueName: String; Index: Integer = 0); virtual;
    procedure ValueDefaultFromActual(const ValueName: String; Index: Integer = 0); virtual;
    procedure ValueExchangeActualAndDefault(const ValueName: String; Index: Integer = 0); virtual;
    Function ValueActualEqualsDefault(const ValueName: String; Index: Integer = 0): Boolean; virtual;
    Function ValueFullPath(const ValueName: String): String; virtual;
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
  {$UNDEF Included_Declaration}{$UNDEF Included}

    //--- Properties -----------------------------------------------------------
    property WorkingPath: String read GetWorkingPath write SetWorkingPath;
    //--- Format settings properties -------------------------------------------
    property FormatSettings: TUNSFormatSettings read fFormatSettings;
    property NumericBools: Boolean read fFormatSettings.NumericBools write fFormatSettings.NumericBools;
    property HexIntegers: Boolean read fFormatSettings.HexIntegers write fFormatSettings.HexIntegers;
    property HexFloats: Boolean read fFormatSettings.HexFloats write fFormatSettings.HexFloats;
    property HexDateTime: Boolean read fFormatSettings.HexDateTime write fFormatSettings.HexDateTime;
    //--- Events ---------------------------------------------------------------
    property OnChange: TNotifyEvent read fOnChange write fOnChange;

    property RootNode: TUNSNodeBranch read fRootNode;
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


Function TUniSettings.GetWorkingPath: String;
begin
ReadLock;
try
  Result := fWorkingPath;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.SetWorkingPath(const Path: String);
var
  NameParts:  TUNSNameParts;
  Node:       TUNSNode;
begin
WriteLock;
try
  fWorkingPath := '';
  fWorkingNode := fRootNode;
  If UNSNameParts(Path,NameParts) > 0 then
    begin
      Node := FindNode(NameParts);
      If Node is TUNSNodeBranch then
        begin
          fWorkingPath := Path;
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
  vptIdentifier,
  vptArrayIdentifier:
    begin
      Result := Branch.FindNode(NodeNamePart.PartName,Node,False);
      Exit;
    end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  vptArrayIndex,
  vptArrayIndexDef:
    If Branch is TUNSNodeArray then
      begin
        If TUNSNodeArray(Branch).CheckIndex(NodeNamePart.PartIndex) then
          Node := TUNSNodeArray(Branch)[NodeNamePart.PartIndex];
      end
    else raise EUNSException.CreateFmt('Invalid name part type (%d) for a given node branch class (%s).',
                 [Ord(NodeNamePart.PartType),Branch.ClassName],Self,'GetSubNode');
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  vptArrayItem,
  vptArrayItemDef:
    begin
      If Branch is TUNSNodeArray then
        case NodeNamePart.PartIndex of
          UNS_PATH_ARRAYITEM_NEW:
            If CanCreate then
              begin
                Node := TUNSNodeArrayItem.Create('',Branch);
                Branch.Add(Node);
              end;
          UNS_PATH_ARRAYITEM_LOW:
            If TUNSNodeArray(Branch).Count > 0 then
              Node := TUNSNodeArray(Branch)[TUNSNodeArray(Branch).LowIndex];
          UNS_PATH_ARRAYITEM_HIGH:
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

Function TUniSettings.ConstructPath(NodeNameParts: TUNSNameParts): TUNSNodeBranch;
var
  CurrentBranch:  TUNSNodeBranch;
  NextNode:       TUNSNode;
  i:              Integer;
begin
Result := nil;
If NodeNameParts.Count > 0 then
  begin
    If NodeNameParts.Valid then
      begin
        CurrentBranch := fWorkingNode;
        For i := Low(NodeNameParts.Arr) to Pred(NodeNameParts.Count) do
          begin
            If GetSubNode(NodeNameParts.Arr[i],CurrentBranch,NextNode,True) then
              begin
                // node was found
                If NextNode is TUNSNodeBranch then
                  CurrentBranch := TUNSNodeBranch(NextNode)
                else
                  Break{For i};
              end
            else
              begin
                // node was NOT found, create it
                case NodeNameParts.Arr[i].PartType of
                  vptIdentifier:
                    NextNode := TUNSNodeBranch.Create(NodeNameParts.Arr[i].PartName.Str,CurrentBranch);
                  vptArrayIdentifier:
                    NextNode := TUNSNodeArray.Create(NodeNameParts.Arr[i].PartName.Str,CurrentBranch);
                  vptArrayIndex,
                  vptArrayIndexDef,
                  vptArrayItem,
                  vptArrayItemDef:
                    Exit; // array items can only be created in GetSubNode trough the use of [#N] (new array item), return nil
                else
                  raise EUNSException.CreateFmt('Invalid name part type (%d).',
                    [Ord(NodeNameParts.Arr[i].PartType)],Self,'ConstructPath');
                end;
                CurrentBranch.Add(NextNode);
                CurrentBranch := TUNSNodeBranch(NextNode);
              end;
          end;
        Result := CurrentBranch;
      end
    else raise EUNSException.Create('Invalid path.',Self,'ConstructPath');
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
begin
  Node := nil;
  Result := False;
  If UNSNameParts(NodeName,NameParts) > 0 then
    // must not end with index or array item
    If not(NameParts.Arr[Pred(NameParts.Count)].PartType in
      [vptArrayIndex,vptArrayIndexDef,vptArrayItem,vptArrayItemDef]) then
      begin
        Dec(NameParts.Count);
        try
          BranchNode := ConstructPath(NameParts);
        finally
          Inc(NameParts.Count);
        end;
        If Assigned(BranchNode) then
          begin
            Node := CreateLeafNode(ValueType,NameParts.Arr[Pred(NameParts.Count)].PartName.Str,BranchNode);
            If BranchNode.CheckIndex(BranchNode.Add(Node)) then
              Result := True
            else
              FreeAndNil(Node);
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
    If Assigned(FoundNode) then
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

//==============================================================================

constructor TUniSettings.Create;
begin
inherited Create;
fFormatSettings := UNS_FORMATSETTINGS_DEFAULT;
fSynchronizer := TMultiReadExclusiveWriteSynchronizer.Create;
fRootNode := TUNSNodeBranch.Create(UNS_NAME_ROOTNODE,nil);
fRootNode.Master := Self;
fWorkingPath := '';
fWorkingNode := fRootNode;
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
        [vptArrayIndex,vptArrayIndexDef,vptArrayItem,vptArrayItemDef] then
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
                  vptArrayIndex:
                    Result := TUNSNodePrimitiveArray(Node).ValueCheckIndex(PartIndex,False);
                  vptArrayIndexDef:
                    Result := TUNSNodePrimitiveArray(Node).ValueCheckIndex(PartIndex,True);
                  vptArrayItem:
                    If PartIndex in [UNS_PATH_ARRAYITEM_LOW,UNS_PATH_ARRAYITEM_HIGH] then
                      Result := TUNSNodePrimitiveArray(Node).ValueCount > 0;
                  vptArrayItemDef:
                    If PartIndex in [UNS_PATH_ARRAYITEM_LOW,UNS_PATH_ARRAYITEM_HIGH] then
                      Result := TUNSNodePrimitiveArray(Node).DefaultValueCount > 0;
                end;
            end;
        end
      else
        begin
          Node := FindNode(NameParts);
          If Assigned(Node) then
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
      [vptArrayIndex,vptArrayIndexDef,vptArrayItem,vptArrayItemDef]) then
      begin
        Node := FindNode(NameParts);
        If Assigned(Node) then
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
  fRootNode.Clear;
  fWorkingPath := '';
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
    else Strings.Add(Node.ReconstructFullPath(False));
  end;

begin
Strings.Clear;
AddNodeToListing(fWorkingNode);
Result := Strings.Count;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ActualFromDefault;
begin
WriteLock;
try
  fWorkingNode.ActualFromDefault;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.DefaultFromActual;
begin
WriteLock;
try
  fWorkingNode.DefaultFromActual;
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ExchangeActualAndDefault;
begin
WriteLock;
try
  fWorkingNode.ExchangeActualAndDefault;
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
        TUNSNodePrimitiveArray(Node).ActualFromDefault(Index)
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
        TUNSNodePrimitiveArray(Node).DefaultFromActual(Index)
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
        TUNSNodePrimitiveArray(Node).ExchangeActualAndDefault(Index)
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
        Result := TUNSNodePrimitiveArray(Node).ActualEqualsDefault(Index)
      else
        Result := Node.ActualEqualsDefault;
    end
  else raise EUNSValueNotFoundException.Create(ValueName,Self,'ValueActualEqualsDefault');
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueFullPath(const ValueName: String): String;
begin
ReadLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueFullPath').ReconstructFullPath(False);
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
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemSize').ValueItemSize;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAddress(const ValueName: String; AccessDefVal: Boolean = False): Pointer;
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueAddress').GetValueAddress(AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsString(const ValueName: String; AccessDefVal: Boolean = False): String;
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueAsString').GetValueAsString(AccessDefVal)
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromString(const ValueName: String; const Str: String; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueFromString').SetValueFromString(Str,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueToStream(const ValueName: String; Stream: TStream; AccessDefVal: Boolean = False);
begin
ReadLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueToStream').GetValueToStream(Stream,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromStream(const ValueName: String; Stream: TStream; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueFromStream').SetValueFromStream(Stream,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsStream(const ValueName: String; AccessDefVal: Boolean = False): TMemoryStream;
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueAsStream').GetValueAsStream(AccessDefVal);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueToBuffer(const ValueName: String; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
ReadLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueToBuffer').GetValueToBuffer(Buffer,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueFromBuffer(const ValueName: String; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafNodeAccess(ValueName,'ValueFromBuffer').SetValueFromBuffer(Buffer,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueAsBuffer(const ValueName: String; AccessDefVal: Boolean = False): TMemoryBuffer;
begin
ReadLock;
try
  Result := CheckedLeafNodeAccess(ValueName,'ValueFromBuffer').GetValueAsBuffer(AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAddress(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): Pointer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAddress').GetValueItemAddress(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsString(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): String;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsString').GetValueItemAsString(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromString(const ValueName: String; Index: Integer; const Str: String; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromString').SetValueItemFromString(Index,Str,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToStream(const ValueName: String; Index: Integer; Stream: TStream; AccessDefVal: Boolean = False);
begin
ReadLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemToStream').GetValueItemToStream(Index,Stream,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromStream(const ValueName: String; Index: Integer; Stream: TStream; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromStream').SetValueItemFromStream(Index,Stream,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsStream(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): TMemoryStream;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsStream').GetValueItemAsStream(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemToBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
ReadLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemToBuffer').GetValueItemToBuffer(Index,Buffer,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueItemFromBuffer(const ValueName: String; Index: Integer; Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueItemFromBuffer').SetValueItemFromBuffer(Index,Buffer,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueItemAsBuffer(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): TMemoryBuffer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueItemAsBuffer').GetValueItemAsBuffer(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueLowIndex(const ValueName: String; AccessDefVal: Boolean = False): Integer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueLowIndex').ValueLowIndex(AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueHighIndex(const ValueName: String; AccessDefVal: Boolean = False): Integer;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueHighIndex').ValueHighIndex(AccessDefVal);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

Function TUniSettings.ValueCheckIndex(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False): Boolean;
begin
ReadLock;
try
  Result := CheckedLeafArrayNodeAccess(ValueName,'ValueCheckIndex').ValueCheckIndex(Index,AccessDefVal);
finally
  ReadUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueExchange(const ValueName: String; Index1,Index2: Integer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueExchange').ValueExchange(Index1,Index2,AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ValueMove(const ValueName: String; SrcIndex,DstIndex: Integer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueMove').ValueMove(SrcIndex,DstIndex,AccessDefVal);
finally
  WriteUnlock;
end;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ValueDelete(const ValueName: String; Index: Integer; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueDelete').ValueDelete(Index,AccessDefVal);
finally
  WriteUnlock;
end;
end;
  
//------------------------------------------------------------------------------

procedure TUniSettings.ValueClear(const ValueName: String; AccessDefVal: Boolean = False);
begin
WriteLock;
try
  CheckedLeafArrayNodeAccess(ValueName,'ValueClear').ValueClear(AccessDefVal);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

{$DEFINE Included}{$DEFINE Included_Implementation}
  {$INCLUDE '.\UniSettings_NodeBool.pas'}
{$UNDEF Included_Implementation}{$UNDEF Included}

end.
