unit UniSettings_NodeArray;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeBranch,
  UniSettings_NodeArrayItem;

type
  TUNSNodeArray = class(TUNSNodeBranch)
  private
    Function GetItem(Index: Integer): TUNSNodeArrayItem;
  protected
    class Function GetNodeClass: TUNSNodeClass; override;
    procedure ReindexItems; virtual;
  public
    Function Add(Node: TUNSNodeBase): Integer; override;
    procedure Delete(Index: Integer); override;
    property Items[Index: Integer]: TUNSNodeArrayItem read GetItem;
  end;

implementation

uses
  SysUtils;

Function TUNSNodeArray.GetItem(Index: Integer): TUNSNodeArrayItem;
begin
Result := TUNSNodeArrayItem(SubNodes[Index]);
end;

//==============================================================================

class Function TUNSNodeArray.GetNodeClass: TUNSNodeClass;
begin
Result := ncArray;
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
If Node is TUNSNodeArrayItem then
  begin
    Result := inherited Add(Node);
    TUNSNodeArrayItem(Node).ArrayIndex := Result;
  end
else raise Exception.Create('TUNSNodeArray.Add: Added node is not of type TUNSNodeArrayItem.');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeArray.Delete(Index: Integer);
begin
inherited Delete(Index);
ReindexItems;
end;

end.
