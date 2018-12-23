unit UniSettings_HashedNodeList;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  AuxClasses,
  UniSettings_Common, UniSettings_NodeBase;

type
  TUNSHashedNodeListItem = record
    Name: TUNSHashedString;
    Node: TUNSNodeBase;
  end;

  TUNSHashedNodeList = class(TCustomListObject)
  private
    fItems: array of TUNSHashedNodeListItem;
    fCount: Integer;
    Function GetItem(Index: Integer): TUNSHashedNodeListItem;
    procedure SetItem(Index: Integer; Item: TUNSHashedNodeListItem);
  protected
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    procedure SetCount(Value: Integer); override;
    Function IndexOf_Iter(Name: TUNSHashedString): Integer; virtual;  // iterative search
    Function IndexOf_Bin(Name: TUNSHashedString): Integer; virtual;   // binary search
    Function IndexForAddition(Name: TUNSHashedString): Integer; virtual;
  public
    destructor Destroy; override;
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    Function Find(Name: TUNSHashedString; out Node: TUNSNodeBase): Boolean; overload; virtual;
    Function Find(const Name: String; out Node: TUNSNodeBase): Boolean; overload; virtual;
    Function IndexOf(Node: TUNSNodeBase): Integer; overload; virtual;
    Function IndexOf(Name: TUNSHashedString): Integer; overload; virtual;
    Function IndexOf(const Name: String): Integer; overload; virtual;
    Function Add(Name: TUNSHashedString; Node: TUNSNodeBase): Integer; overload; virtual;
    Function Add(const Name: String; Node: TUNSNodeBase): Integer; overload; virtual;
    Function Remove(Node: TUNSNodeBase): Integer; overload; virtual;
    Function Remove(Name: TUNSHashedString): Integer; overload; virtual;
    Function Remove(const Name: String): Integer; overload; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    property Items[Index: Integer]: TUNSHashedNodeListItem read GetItem write SetItem; default;
  end;

implementation

uses
  AuxTypes,
  UniSettings_Exceptions, UniSettings_Utils;

Function TUNSHashedNodeList.GetItem(Index: Integer): TUNSHashedNodeListItem;
begin
If CheckIndex(Index) then
  Result := fItems[Index]
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetItem');
end;

//------------------------------------------------------------------------------

procedure TUNSHashedNodeList.SetItem(Index: Integer; Item: TUNSHashedNodeListItem);
begin
If CheckIndex(Index) then
  fItems[Index] := Item
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'SetItem');
end;

//==============================================================================

Function TUNSHashedNodeList.GetCapacity: Integer;
begin
Result := Length(fItems);
end;

//------------------------------------------------------------------------------

procedure TUNSHashedNodeList.SetCapacity(Value: Integer);
begin
SetLength(fItems,Value);
If Value < fCount then
  fCount := Value;
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.GetCount: Integer;
begin
Result := fCount;
end;

//------------------------------------------------------------------------------

procedure TUNSHashedNodeList.SetCount(Value: Integer);
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.IndexOf_Iter(Name: TUNSHashedString): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If UNSSameHashString(fItems[i].Name,Name,True) then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.IndexOf_Bin(Name: TUNSHashedString): Integer;
var
  LowIdx:   Integer;
  HighIdx:  Integer;
  Index:    Integer;  
  Temp:     Int64;
begin
Result := -1;
LowIdx := LowIndex;
HighIdx := HighIndex;
while HighIdx >= LowIdx do
  begin
    Index := ((HighIdx - LowIdx) shr 1) + LowIdx;
    Temp := Int64(fItems[Index].Name.Hash) - Int64(Name.Hash);
    If Temp > 0 then
      HighIdx := Index - 1
    else If Temp < 0 then
      LowIdx := Index + 1 
    else {Temp = 0}
      begin
        Result := Index;
        Break{while};
      end;
  end;
end;
 
//------------------------------------------------------------------------------

Function TUNSHashedNodeList.IndexForAddition(Name: TUNSHashedString): Integer;
var
  i:  Integer;
begin
Result := fCount;
For i := LowIndex to HighIndex do
  If UInt32(Name.Hash) <= UInt32(fItems[i].Name.Hash) then
    begin
      If UInt32(Name.Hash) < UInt32(fItems[i].Name.Hash) then
        begin
          Result := i;
          Break{For i}
        end
      else raise EUNSException.CreateFmt('Hash collision for names %s and %s.',
        [Name.Str,fItems[i].Name.Str],Self,'IndexForAddition');
    end;
end;

//==============================================================================

destructor TUNSHashedNodeList.Destroy;
begin
Clear;
inherited;
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.LowIndex: Integer;
begin
Result := Low(fItems);
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.HighIndex: Integer;
begin
Result := Pred(fCount);
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.Find(Name: TUNSHashedString; out Node: TUNSNodeBase): Boolean;
var
  Index:  Integer;
begin
Index := IndexOf(Name);
If CheckIndex(Index) then
  begin
    Node := fItems[Index].Node;
    Result := True;
  end
else
  begin
    Node := nil;
    Result := False;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.Find(const Name: String; out Node: TUNSNodeBase): Boolean;
begin
Result := Find(UNSHashedString(Name),Node);
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.IndexOf(Node: TUNSNodeBase): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If fItems[i].Node = Node then
    begin
      Result := i;
      Break{For i};
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSHashedNodeList.IndexOf(Name: TUNSHashedString): Integer;
begin
If fCount > 8 then
  Result := IndexOf_Bin(Name)
else
  Result := IndexOf_Iter(Name)
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSHashedNodeList.IndexOf(const Name: String): Integer;
begin
Result := IndexOf(UNSHashedString(Name));
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.Add(Name: TUNSHashedString; Node: TUNSNodeBase): Integer;
var
  i:  Integer;
begin
Result := IndexOf(Name);
If not CheckIndex(Result) then
  begin
    If Length(fItems) <= fCount then
      SetLength(fItems,Length(fItems) + 32);
    Result := IndexForAddition(Name);
    For i := HighIndex downto Result do
      fItems[i + 1] := fItems[i];
    fItems[Result].Name := Name;
    fItems[Result].Node := Node;  
    Inc(fCount);
  end
else If Node <> fItems[Result].Node then
  raise EUNSException.CreateFmt('Name "%s" is already registered for different node.',[Name.Str],Self,'Add');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSHashedNodeList.Add(const Name: String; Node: TUNSNodeBase): Integer;
begin
Result := Add(UNSHashedString(Name),Node);
end;

//------------------------------------------------------------------------------

Function TUNSHashedNodeList.Remove(Node: TUNSNodeBase): Integer;
begin
Result := IndexOf(Node);
If CheckIndex(Result) then
  Delete(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSHashedNodeList.Remove(Name: TUNSHashedString): Integer;
begin
Result := IndexOf(Name);
If CheckIndex(Result) then
  Delete(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUNSHashedNodeList.Remove(const Name: String): Integer;
begin
Result := Remove(UNSHashedString(Name));
end;

//------------------------------------------------------------------------------

procedure TUNSHashedNodeList.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    For i := Index to Pred(HighIndex) do
      fItems[i] := fItems[i + 1];
    Dec(fCount);
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'Delete');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUNSHashedNodeList.Clear;
begin
fCount := 0;
SetLength(fItems,0);
end;

end.
