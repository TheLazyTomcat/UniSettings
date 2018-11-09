unit UniSettings;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils,
  AuxClasses,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeBranch;

type
  TUNSNode = TUNSNodeBase;

  TUniSettings = class(TObject)
  private
    fFormatSettings:  TUNSFormatSettings;
    fSynchronizer:    TMultiReadExclusiveWriteSynchronizer;
    fRootNode:        TUNSNodeBranch;
    fOnChange:        TNotifyEvent;
  protected
    Function FindNode(const NodeName: String): TUNSNode; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    //--- Locking --------------------------------------------------------------
    procedure ReadLock; virtual;
    procedure ReadUnlock; virtual;
    procedure WriteLock; virtual;
    procedure WriteUnlock; virtual;
    procedure Lock; virtual;
    procedure Unlock; virtual;
    //--- Values and Nodes management ------------------------------------------
    //Function AddValue(const ValueName: String; );
    procedure Clear; virtual;
    //--- Format settings ------------------------------------------------------
    property FormatSettings: TUNSFormatSettings read fFormatSettings;
    property NumericBools: Boolean read fFormatSettings.NumericBools write fFormatSettings.NumericBools;
    property HexIntegers: Boolean read fFormatSettings.HexIntegers write fFormatSettings.HexIntegers;
    property HexFloats: Boolean read fFormatSettings.HexFloats write fFormatSettings.HexFloats;
    property HexDateTime: Boolean read fFormatSettings.HexDateTime write fFormatSettings.HexDateTime;
    //--- Events ---------------------------------------------------------------
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

implementation

uses
  UniSettings_Utils, UniSettings_NodeArray, UniSettings_NodeArrayItem,
  UniSettings_NodePrimitiveArray;

Function TUniSettings.FindNode(const NodeName: String): TUNSNode;
var
  NameParts:    TUNSValueNameParts;
  CurrentNode:  TUNSNode;
  i:            Integer;
begin
Result := nil;
If UNSValueNameParts(NodeName,NameParts) > 0 then
  begin
    CurrentNode := fRootNode;
    For i := Low(NameParts.Arr) to Pred(NameParts.Count) do
      If CurrentNode is TUNSNodeBranch then
        case NameParts.Arr[i].PartType of
          vptName:
            If not TUNSNodeBranch(CurrentNode).FindNode(NameParts.Arr[i].PartName,CurrentNode,False) then
              Exit;
          vptIndex:
            If CurrentNode is TUNSNodeArray then
              begin
                If TUNSNodeArray(CurrentNode).CheckIndex(NameParts.Arr[i].PartIndex) then
                  CurrentNode := TUNSNodeArray(CurrentNode)[NameParts.Arr[i].PartIndex]
                else
                  Exit;
              end
            else Exit;  
          vptBoth:
            begin
              If TUNSNodeBranch(CurrentNode).FindNode(NameParts.Arr[i].PartName,CurrentNode,False) then
                begin
                  If not(CurrentNode is TUNSNodePrimitiveArray) then
                    Exit;
                end
              else Exit;
            end;
        end
      else Exit;
    Result := CurrentNode;
  end;
end;

//==============================================================================

constructor TUniSettings.Create;
begin
inherited Create;
fFormatSettings := UNS_FORMATSETTINGS_DEFAULT;
fSynchronizer := TMultiReadExclusiveWriteSynchronizer.Create;
fRootNode := TUNSNodeBranch.Create(UNS_NAME_ROOTNODE,nil);
fRootNode.Master := Self;
fOnChange := nil;
end;

//------------------------------------------------------------------------------

destructor TUniSettings.Destroy;
begin
Clear;
fRootNode.Free;
fSynchronizer.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.ReadLock;
begin
fSynchronizer.BeginRead;
end;
 
//------------------------------------------------------------------------------

procedure TUniSettings.ReadUnlock;
begin
fSynchronizer.EndRead;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.WriteLock;
begin
fSynchronizer.BeginWrite;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.WriteUnlock;
begin
fSynchronizer.EndWrite;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Lock;
begin
WriteLock;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Unlock;
begin
WriteUnlock;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.Clear;
begin
WriteLock;
try
  fRootNode.Clear;
finally
  WriteUnlock;
end;
end;

end.
