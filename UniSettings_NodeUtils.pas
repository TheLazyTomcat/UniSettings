unit UniSettings_NodeUtils;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_Common, UniSettings_NodeBase;

Function UNSIsBranchNode(Node: TUNSNodeBase): Boolean;

Function UNSIsLeafNode(Node: TUNSNodeBase): Boolean;

Function UNSIsLeafNodeOfValueType(Node: TUNSNodeBase; ValueType: TUNSValueType): Boolean;

Function UNSCompatibleNodes(Node1,Node2: TUNSNodeBase): Boolean;

Function UNSIsPrimitiveArrayNode(Node: TUNSNodeBase): Boolean;

implementation

uses
  UniSettings_Utils, UniSettings_NodeLeaf;

Function UNSIsBranchNode(Node: TUNSNodeBase): Boolean;
begin
If Assigned(Node) then
  Result := Node.NodeType in [ntBranch,ntArray,ntArrayItem]
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function UNSIsLeafNode(Node: TUNSNodeBase): Boolean;
begin
If Assigned(Node) then
  Result := Node.NodeType in [ntLeaf,ntLeafArray]
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function UNSIsLeafNodeOfValueType(Node: TUNSNodeBase; ValueType: TUNSValueType): Boolean;
begin
If Assigned(Node) then
  begin
    If UNSIsLeafNode(Node) then
      Result := TUNSNodeLeaf(Node).ValueType = ValueType
    else
      Result := False;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function UNSCompatibleNodes(Node1,Node2: TUNSNodeBase): Boolean;
begin
If Assigned(Node1) and Assigned(Node2) then
  begin
    If UNSIsLeafNode(Node1) then
      begin
        If Node1.NodeType = Node2.NodeType then
          Result := TUNSNodeLeaf(Node1).ValueType = TUNSNodeLeaf(Node2).ValueType
        else
          Result := False;
      end
    else Result := Node1.NodeType = Node2.NodeType;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function UNSIsPrimitiveArrayNode(Node: TUNSNodeBase): Boolean;
begin
If Assigned(Node) then
  begin
    If UNSIsLeafNode(Node) then
      Result := UNSIsArrayValueType(TUNSNodeLeaf(Node).ValueType)
    else
      Result := False;
  end
else Result := False;
end;

end.
