unit UniSettings_NodeArrayItem;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeBranch;

type
  TUNSNodeArrayItem = class(TUNSNodeBranch)
  private
    fArrayIndex:  Integer;
  protected
    class Function GetNodeType: TUNSNodeType; override;
    procedure SetArrayIndex(Value: Integer); virtual;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    property ArrayIndex: Integer read fArrayIndex write SetArrayIndex;
  end;

implementation

uses
  SysUtils,
  UniSettings_Exceptions, UniSettings_Utils, UniSettings_NodeArray;

procedure TUNSNodeArrayItem.SetArrayIndex(Value: Integer);
begin
fArrayIndex := Value;
fName := UNSHashedString(IntToStr(fArrayIndex));
end;

//==============================================================================

class Function TUNSNodeArrayItem.GetNodeType: TUNSNodeType;
begin
Result := ntArrayItem;
end;

//==============================================================================

constructor TUNSNodeArrayItem.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fArrayIndex := -1;
fName := UNSHashedString(IntToStr(fArrayIndex));
If ParentNode.NodeType <> ntArray then
  raise EUNSException.Create('Parent node is not of type ntArray.',Self,'Create');
end;

end.
 