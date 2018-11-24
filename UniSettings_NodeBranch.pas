unit UniSettings_NodeBranch;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_Common, UniSettings_NodeBase;

type
  TUNSNodeBranch = class(TUNSNodeBase)
  private
    fSubNodes:  array of TUNSNodeBase;
    fCount:     Integer;
    Function GetSubNode(Index: Integer): TUNSNodeBase;
  protected
    class Function GetNodeClass: TUNSNodeClass; override;
    procedure SetMaster(Value: TObject); override;
    Function GetMaxNodeLevel: Integer; override;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
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
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    property SubNodes[Index: Integer]: TUNSNodeBase read GetSubNode; default;
    property Count: Integer read fCount;
  end;

implementation

uses
  SysUtils,
  UniSettings_Utils;

const
  UNS_BRANCHNODE_GROWFACTOR = 128;

Function TUNSNodeBranch.GetSubNode(Index: Integer): TUNSNodeBase;
begin
If CheckIndex(Index) then
  Result := fSubNodes[Index]
else
  raise Exception.CreateFmt('TUNSNodeBranch.GetSubNode: Index (%d) out of bounds.',[Index]);
end;

//==============================================================================

class Function TUNSNodeBranch.GetNodeClass: TUNSNodeClass;
begin
Result := ncBranch;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.SetMaster(Value: TObject);
var
  i:  Integer;
begin
inherited;
For i := LowIndex to HighIndex do
  fSubNodes[i].Master := Value;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.GetMaxNodeLevel: Integer;
var
  i,Temp: Integer;
begin
Result := inherited GetMaxNodeLevel;
For i := LowIndex to HighIndex do
  begin
    Temp := fSubNodes[i].MaxNodeLevel;
    If Temp > Result  then
      Result := Temp;
  end;
end;

//==============================================================================

constructor TUNSNodeBranch.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
SetLength(fSubNodes,0);
fCount := 0;
end;

//------------------------------------------------------------------------------

destructor TUNSNodeBranch.Destroy;
begin
Clear;
inherited;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.LowIndex: Integer;
begin
Result := Low(fSubNodes);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.HighIndex: Integer;
begin
Result := Pred(fCount);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.CheckIndex(Index: Integer): Boolean;
begin
Result := (Index >= LowIndex) and (Index <= HighIndex);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.IndexOf(Node: TUNSNodeBase): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If fSubNodes[i] = Node then
    begin
      Result := i;
      Break{For i};
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.IndexOf(Name: TUNSHashedString): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If UNSSameHashString(Name,fSubNodes[i].Name) then
    begin
      Result := i;
      Break{For i};
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSNodeBranch.IndexOf(const Name: String): Integer;
begin
Result := IndexOf(UNSHashedString(Name));
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.Add(Node: TUNSNodeBase): Integer;
begin
If fCount >= Length(fSubNodes) then
  SetLength(fSubNodes,Length(fSubNodes) + UNS_BRANCHNODE_GROWFACTOR);
Result := fCount;
fSubNodes[Result] := Node;
fSubNodes[Result].Master := fMaster;
Inc(fCount);
DoChange;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.Remove(Node: TUNSNodeBase): Integer;
begin
Result := IndexOf(Node);
If CheckIndex(Result) then
  Delete(Result);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    fSubNodes[Index].Free;
    For i := Index to Pred(HighIndex) do
      fSubNodes[i] := fSubNodes[i + 1];
    Dec(fCount);
    DoChange;
  end
else raise Exception.CreateFmt('TUNSNodeBranch.Delete: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.Clear;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  FreeAndNil(fSubNodes[i]);
fCount := 0;
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
    Node := fSubNodes[Index];
    Result := True;
  end
else
  If Recursive then
    For i := LowIndex to HighIndex do
      If fSubNodes[i] is TUNSNodeBranch then
        If TUNSNodeBranch(fSubNodes[i]).FindNode(Name,Node,Recursive) then
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
    If not(Node.NodeClass in [ncBranch,ncArray,ncArrayItem]) then
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
    If not(Node.NodeClass = ncLeaf) then
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

procedure TUNSNodeBranch.ActualFromDefault;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fSubNodes[i].ActualFromDefault;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.DefaultFromActual;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fSubNodes[i].DefaultFromActual;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBranch.ExchangeActualAndDefault;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fSubNodes[i].ExchangeActualAndDefault;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBranch.ActualEqualsDefault: Boolean;
var
  i:  Integer;
begin
Result := True;
For i := LowIndex to HighIndex do
  If not fSubNodes[i].ActualEqualsDefault then
    begin
      Result := False;
      Break{For i};
    end;
end;

end.
