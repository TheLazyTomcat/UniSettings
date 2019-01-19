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
    Function FindNode(Name: TUNSHashedString; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean; overload; virtual;
    Function FindNode(const Name: String; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean; overload; virtual;
    Function FindBranchNode(Name: TUNSHashedString; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean; overload; virtual;
    Function FindBranchNode(const Name: String; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean; overload; virtual;
    Function FindLeafNode(Name: TUNSHashedString; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean; overload; virtual;
    Function FindLeafNode(const Name: String; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean; overload; virtual;
    procedure ValueKindMove(Src,Dest: TUNSValueKind); override;
    procedure ValueKindExchange(ValA,ValB: TUNSValueKind); override;
    Function ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean; override;
    property SubNodes[Index: Integer]: TUNSNodeBase read GetSubNode; default;
    property Count: Integer read GetCount;
  end;

implementation

uses
  SysUtils,
  UniSettings_Exceptions, UniSettings_Utils;

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

Function TUNSNodeBranch.FindNode(Name: TUNSHashedString; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean;
var
  Index,i:  Integer;
begin
Node := nil;
Result := False;
Index := IndexOf(Name);
If CheckIndex(Index) then
  begin
    Node := fSubNodes[Index].Node;
    Result := True;
  end
else
  If Recursive then
    For i := LowIndex to HighIndex do
      If UNSIsBranchNode(fSubNodes[i].Node) then
        If TUNSNodeBranch(fSubNodes[i].Node).FindNode(Name,Node,Recursive) then
          begin
            Result := True;
            Break{For i};
          end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.FindNode(const Name: String; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean;
begin
Result := FindNode(UNSHashedString(Name),Node,Recursive);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.FindBranchNode(Name: TUNSHashedString; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean;
begin
If FindNode(Name,Node,Recursive) then
  begin
    If not UNSIsBranchNode(Node) then
      begin
        Result := False;
        Node := nil;
      end
    else Result := True;
  end
else Result := False;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.FindBranchNode(const Name: String; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean;
begin
Result := FindBranchNode(UNSHashedString(Name),Node,Recursive);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.FindLeafNode(Name: TUNSHashedString; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean;
begin
If FindNode(Name,Node,Recursive) then
  begin
    If not UNSIsLeafNode(Node) then
      begin
        Result := False;
        Node := nil;
      end
    else Result := True;
  end
else Result := False;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.FindLeafNode(const Name: String; out Node: TUNSNodeBase; Recursive: Boolean = False): Boolean;
begin
Result := FindLeafNode(UNSHashedString(Name),Node,Recursive);
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
