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
    class Function GetNodeClass: TUNSNodeClass; override;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase; Master: TObject);
    property ArrayIndex: Integer read fArrayIndex write fArrayIndex;
  end;

implementation

uses
  SysUtils,
  UniSettings_NodeArray;

class Function TUNSNodeArrayItem.GetNodeClass: TUNSNodeClass;
begin
Result := ncArrayItem;
end;

//==============================================================================

constructor TUNSNodeArrayItem.Create(const Name: String; ParentNode: TUNSNodeBase; Master: TObject);
begin
inherited Create(Name,ParentNode,Master);
If not(ParentNode is TUNSNodeArray) then
  raise Exception.Create('TUNSNodeArrayItem.Create: Parent node is not of type TUNSNodeArray.');
end;

end.
 