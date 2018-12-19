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
    procedure SetNodeNameStr(const Value: String); override;
    procedure SetName(Value: TUNSHashedString); virtual;
    procedure SetArrayIndex(Value: Integer); virtual;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    property Name: TUNSHashedString read fName write SetName;
    property ArrayIndex: Integer read fArrayIndex write SetArrayIndex;
  end;

implementation

uses
  SysUtils,
  UniSettings_Exceptions, UniSettings_Utils, UniSettings_NodeArray;

procedure TUNSNodeArrayItem.SetName(Value: TUNSHashedString);
begin
// drop value
end;

//------------------------------------------------------------------------------

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

//------------------------------------------------------------------------------

procedure TUNSNodeArrayItem.SetNodeNameStr(const Value: String);
begin
// drop value
end;

//==============================================================================

constructor TUNSNodeArrayItem.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fArrayIndex := -1;
fName := UNSHashedString(IntToStr(fArrayIndex));
If not(ParentNode is TUNSNodeArray) then
  raise EUNSException.Create('Parent node is not of type TUNSNodeArray.',Self,'Create');
end;

end.
 