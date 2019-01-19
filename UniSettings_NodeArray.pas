unit UniSettings_NodeArray;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeBranch,
  UniSettings_NodeArrayItem, UniSettings_NodeList;

type
  TUNSNodeArray = class(TUNSNodeBranch)
  private
    Function GetItem(Index: Integer): TUNSNodeArrayItem;
  protected
    class Function GetNodeType: TUNSNodeType; override;
    class Function CreateSubNodesList: TUNSNodeList; override;
    procedure ReindexItems; virtual;
  public
    Function Add(Node: TUNSNodeBase): Integer; override;
    procedure Delete(Index: Integer); override;
    property Items[Index: Integer]: TUNSNodeArrayItem read GetItem; default;
  end;

implementation

uses
  SysUtils,
  UniSettings_Exceptions;

Function TUNSNodeArray.GetItem(Index: Integer): TUNSNodeArrayItem;
begin
Result := TUNSNodeArrayItem(SubNodes[Index]);
end;

//==============================================================================

class Function TUNSNodeArray.GetNodeType: TUNSNodeType;
begin
Result := ntArray;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeArray.CreateSubNodesList: TUNSNodeList;
begin
Result := TUNSNodeList.Create;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeArray.ReindexItems;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  Items[i].ArrayIndex := i;
end;

//==============================================================================

Function TUNSNodeArray.Add(Node: TUNSNodeBase): Integer;
begin
If Node.NodeType = ntArrayItem then
  begin
    Result := inherited Add(Node);
    TUNSNodeArrayItem(Node).ArrayIndex := Result;
  end
else raise EUNSException.Create('Added node is not of type ntArrayItem.',Self,'Add');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeArray.Delete(Index: Integer);
begin
inherited Delete(Index);
ReindexItems;
end;

end.
