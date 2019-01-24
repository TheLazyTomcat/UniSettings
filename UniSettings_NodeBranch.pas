unit UniSettings_NodeBranch;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeList;

type
  TUNSNodeBranch = class(TUNSNodeBase)
  private
    fSubNodes:  TUNSNodeList;
    Function GetCount: Integer;
    Function GetSubNode(Index: Integer): TUNSNodeBase;
  protected
    class Function GetNodeType: TUNSNodeType; override;
    procedure SetMaster(Value: TObject); override;
    Function GetMaxNodeLevel: Integer; override;
    class Function CreateSubNodesList: TUNSNodeList; virtual;
    procedure SubNodeChangeHandler(Sender: TObject; Node: TUNSNodeBase); virtual;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    constructor CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
    destructor Destroy; override;
    Function LowIndex: Integer; virtual;
    Function HighIndex: Integer; virtual;
    Function CheckIndex(Index: Integer): Boolean; virtual;
    Function IndexOf(Node: TUNSNodeBase): Integer; overload; virtual;
    Function IndexOf(Name: TUNSHashedString): Integer; overload; virtual;
    Function IndexOf(const Name: String): Integer; overload; virtual;
    Function Add(Node: TUNSNodeBase): Integer; virtual;
    Function Remove(Node: TUNSNodeBase): Integer; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    Function FindNode(Name: TUNSHashedString; out Node: TUNSNodeBase): Boolean; overload; virtual;
    Function FindNode(const Name: String; out Node: TUNSNodeBase): Boolean; overload; virtual;
    Function FindNode(NamePart: TUNSNamePart; out Node: TUNSNodeBase): Boolean; overload; virtual;
    Function FindNode(NameParts: TUNSNameParts; PartIndex: Integer; out Node: TUNSNodeBase): Boolean; overload; virtual;
    procedure ValueKindMove(Src,Dest: TUNSValueKind); override;
    procedure ValueKindExchange(ValA,ValB: TUNSValueKind); override;
    Function ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean; override;
    property SubNodes[Index: Integer]: TUNSNodeBase read GetSubNode; default;
    property Count: Integer read GetCount;
  end;

implementation

uses
  SysUtils,
  UniSettings_Exceptions, UniSettings_Utils, UniSettings_NodeUtils;

Function TUNSNodeBranch.GetCount: Integer;
begin
Result := fSubNodes.Count;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.GetSubNode(Index: Integer): TUNSNodeBase;
begin
If CheckIndex(Index) then
  Result := fSubNodes[Index].Node
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetSubNode');
end;

//==============================================================================

class Function TUNSNodeBranch.GetNodeType: TUNSNodeType;
begin
Result := ntBranch;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.SetMaster(Value: TObject);
var
  i:  Integer;
begin
inherited;
For i := LowIndex to HighIndex do
  fSubNodes[i].Node.Master := Value;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.GetMaxNodeLevel: Integer;
var
  i,Temp: Integer;
begin
Result := inherited GetMaxNodeLevel;
For i := LowIndex to HighIndex do
  begin
    Temp := fSubNodes[i].Node.MaxNodeLevel;
    If Temp > Result  then
      Result := Temp;
  end;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeBranch.CreateSubNodesList: TUNSNodeList;
begin
Result := TUNSHashedNodeList.Create;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.SubNodeChangeHandler(Sender: TObject; Node: TUNSNodeBase);
begin
If Assigned(fOnChange) then
  fOnChange(Self,Node);
end;

//==============================================================================

constructor TUNSNodeBranch.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
fSubNodes := CreateSubNodesList;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeBranch.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
var
  i:  Integer;
begin
inherited CreateAsCopy(Source,Name,ParentNode);
For i := TUNSNodeBranch(Source).LowIndex to TUNSNodeBranch(Source).HighIndex do
  Add(TUNSNodeBranch(Source)[i].CreateCopy(TUNSNodeBranch(Source)[i].NameStr,Self));
end;

//------------------------------------------------------------------------------

destructor TUNSNodeBranch.Destroy;
begin
fSubNodes.Free;
inherited;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.LowIndex: Integer;
begin
Result := fSubNodes.LowIndex;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.HighIndex: Integer;
begin
Result := fSubNodes.HighIndex;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.CheckIndex(Index: Integer): Boolean;
begin
Result := fSubNodes.CheckIndex(Index);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.IndexOf(Node: TUNSNodeBase): Integer;
begin
Result := fSubNodes.IndexOf(Node);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.IndexOf(Name: TUNSHashedString): Integer;
begin
Result := fSubNodes.IndexOf(Name);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.IndexOf(const Name: String): Integer;
begin
Result := fSubNodes.IndexOf(Name);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.Add(Node: TUNSNodeBase): Integer;
begin
Result := fSubNodes.Add(Node.Name,Node);
fSubNodes[Result].Node.Master := fMaster;
fSubNodes[Result].Node.OnChange := SubNodeChangeHandler;
DoChange;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.Remove(Node: TUNSNodeBase): Integer;
begin
Result := fSubNodes.Remove(Node);
If Result >= 0 then
  DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.Delete(Index: Integer);
begin
fSubNodes.Delete(Index);
DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.Clear;
begin
fSubNodes.Clear;
DoChange;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.FindNode(Name: TUNSHashedString; out Node: TUNSNodeBase): Boolean;
var
  Index:  Integer;
begin
Node := nil;
Index := IndexOf(Name);
If CheckIndex(Index) then
  begin
    Node := fSubNodes[Index].Node;
    Result := True;
  end
else Result := False;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.FindNode(const Name: String; out Node: TUNSNodeBase): Boolean;
begin
Result := FindNode(UNSHashedString(Name),Node);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.FindNode(NamePart: TUNSNamePart; out Node: TUNSNodeBase): Boolean;
begin
Node := nil;
If NamePart.PartType in [nptIdentifier,nptArrayIdentifier] then
  Result := FindNode(NamePart.PartStr,Node)
else
  Result := False;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.FindNode(NameParts: TUNSNameParts; PartIndex: Integer; out Node: TUNSNodeBase): Boolean;
var
  TempNode: TUNSNodeBase;
begin
Node := nil;
Result := False;
If CDA_CheckIndex(NameParts,PartIndex) then
  If FindNode(CDA_GetItem(NameParts,PartIndex),TempNode) then
    begin
      If PartIndex < CDA_High(NameParts) then
        begin
          If UNSIsBranchNode(TempNode) then
            Result := TUNSNodeBranch(TempNode).FindNode(NameParts,PartIndex + 1,Node);
        end
      else
        begin
          Node := TempNode;
          Result := True;
        end;
    end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.ValueKindMove(Src,Dest: TUNSValueKind);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fSubNodes[i].Node.ValueKindMove(Src,Dest);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.ValueKindExchange(ValA,ValB: TUNSValueKind);
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fSubNodes[i].Node.ValueKindExchange(ValA,ValB);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean;
var
  i:  Integer;
begin
Result := True;
For i := LowIndex to HighIndex do
  If not fSubNodes[i].Node.ValueKindCompare(ValA,ValB) then
    begin
      Result := False;
      Break{For i};
    end;
end;

end.
