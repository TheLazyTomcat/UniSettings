unit UniSettings_NodeBase;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils,
  AuxClasses,
  UniSettings_Common;

type
  TUNSNodeBase = class; // forward declaration for the following event type 

  TUNSNodeChangeEvent = procedure(Sender: TObject; Node: TUNSNodeBase) of object;

  TUNSNodeBase = class(TCustomObject)
  protected
    fName:            TUNSHashedString;
    fParentNode:      TUNSNodeBase;
    fFullName:        TUNSHashedString;
    fMaster:          TObject;
    fAdditionIdx:     Integer;
    fFlags:           TUNSValueFlags;
    fConvSettings:    TFormatSettings;
    fChanged:         Boolean;
    fChangeCounter:   Integer;
    fOnChange:        TUNSNodeChangeEvent;
    class Function GetNodeType: TUNSNodeType; virtual;
    procedure SetMaster(Value: TObject); virtual;
    Function GetNodeLevel: Integer; virtual;
    Function GetMaxNodeLevel: Integer; virtual;
    Function ReconstructFullNameInternal(TopLevelCall: Boolean; IncludeRoot: Boolean): String; virtual;
    Function ValueFormatSettings: TUNSValueFormatSettings; virtual;
    procedure BeginChanging; virtual;
    procedure EndChanging; virtual;
    procedure DoChange; virtual;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    constructor CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
    Function CreateCopy(const Name: String; ParentNode: TUNSNodeBase): TUNSNodeBase;
    Function GetFlag(Flag: TUNSValueFlag): Boolean; virtual;
    procedure SetFlag(Flag: TUNSValueFlag); virtual;
    procedure ResetFlag(Flag: TUNSValueFlag); virtual;
    Function ReconstructFullName(IncludeRoot: Boolean = False): String; virtual;
    procedure ValueKindMove(Src,Dest: TUNSValueKind); overload; virtual; abstract;
    procedure ValueKindExchange(ValA,ValB: TUNSValueKind); overload; virtual; abstract;
    Function ValueKindCompare(ValA,ValB: TUNSValueKind): Boolean; overload; virtual; abstract;
    procedure ActualFromDefault; overload; virtual;
    procedure DefaultFromActual; overload; virtual;
    procedure ExchangeActualAndDefault; overload; virtual;
    Function ActualEqualsDefault: Boolean; overload; virtual;
    procedure Save; overload; virtual;
    procedure Restore; overload; virtual;
    property NodeType: TUNSNodeType read GetNodeType;
    property Name: TUNSHashedString read fName;
    property NameStr: String read fName.Str;
    property FullName: TUNSHashedString read fFullName;
    property FullNameStr: String read fFullName.Str;
    property ParentNode: TUNSNodeBase read fParentNode;
    property Master: TObject read fMaster write SetMaster;
    property AdditionIndex: Integer read fAdditionIdx write fAdditionIdx;
    property NodeLevel: Integer read GetNodeLevel;
    property MaxNodeLevel: Integer read GetMaxNodeLevel;    
    property Flags: TUNSValueFlags read fFlags write fFlags;
    property OnChange: TUNSNodeChangeEvent read fOnChange write fOnChange;
  end;

Function UNSIsBranchNode(Node: TUNSNodeBase): Boolean;
Function UNSIsLeafNode(Node: TUNSNodeBase): Boolean;
Function UNSIsLeafNodeOfValueType(Node: TUNSNodeBase; ValueType: TUNSValueType): Boolean;
Function UNSCompatibleNodes(Node1,Node2: TUNSNodeBase): Boolean;
Function UNSIsPrimitiveArrayNode(Node: TUNSNodeBase): Boolean;

implementation

uses
  UniSettings_Utils, UniSettings_Exceptions, UniSettings_NodeLeaf,
  UniSettings_NodeBranch, UniSettings_NodeArray, UniSettings_NodeArrayItem,
  UniSettings;

Function UNSIsBranchNode(Node: TUNSNodeBase): Boolean;
begin
If Assigned(Node) then
  Result := Node.NodeType in [ntBranch,ntArray,ntArrayItem]
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function UNSIsLeafNode(Node: TUNSNodeBase): Boolean;
begin
If Assigned(Node) then
  Result := Node.NodeType in [ntLeaf,ntLeafArray]
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function UNSIsLeafNodeOfValueType(Node: TUNSNodeBase; ValueType: TUNSValueType): Boolean;
begin
If Assigned(Node) then
  begin
    If UNSIsLeafNode(Node) then
      Result := TUNSNodeLeaf(Node).ValueType = ValueType
    else
      Result := False;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function UNSCompatibleNodes(Node1,Node2: TUNSNodeBase): Boolean;
begin
If Assigned(Node1) and Assigned(Node2) then
  begin
    If UNSIsLeafNode(Node1) then
      begin
        If Node1.NodeType = Node2.NodeType then
          Result := TUNSNodeLeaf(Node1).ValueType = TUNSNodeLeaf(Node2).ValueType
        else
          Result := False;
      end
    else Result := Node1.NodeType = Node2.NodeType;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function UNSIsPrimitiveArrayNode(Node: TUNSNodeBase): Boolean;
begin
If Assigned(Node) then
  begin
    If UNSIsLeafNode(Node) then
      Result := UNSIsArrayValueType(TUNSNodeLeaf(Node).ValueType)
    else
      Result := False;
  end
else Result := False;
end;

//==============================================================================

class Function TUNSNodeBase.GetNodeType: TUNSNodeType;
begin
Result := ntUndefined;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.SetMaster(Value: TObject);
begin
fMaster := Value;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.GetNodeLevel: Integer;
begin
If Assigned(fParentNode) then
  Result := fParentNode.GetNodeLevel + 1
else
  Result := 0;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.GetMaxNodeLevel: Integer;
begin
Result := GetNodeLevel;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.ReconstructFullNameInternal(TopLevelCall: Boolean; IncludeRoot: Boolean): String;
var
  TempStr:  String;
begin
case GetNodeType of
  ntBranch:     If TopLevelCall then
                  TempStr := fName.Str
                else
                  TempStr := fName.Str + UNS_NAME_DELIMITER;
  ntArray:      If TopLevelCall then
                  TempStr := Format('%s[]',[fName.Str])
                else If (TUNSNodeArray(Self).Count <= 0) then
                  TempStr := Format('%s[]',[fName.Str]) + UNS_NAME_DELIMITER
                else
                  TempStr := fName.Str;
  ntArrayItem:  If Assigned(fParentNode) then
                  begin
                    If TopLevelCall or (TUNSNodeArrayItem(Self).Count <= 0) then
                      TempStr := Format('[%d]',[TUNSNodeArrayItem(Self).ArrayIndex])
                    else
                      TempStr := Format('[%d]',[TUNSNodeArrayItem(Self).ArrayIndex]) + UNS_NAME_DELIMITER;
                  end
                else raise EUNSException.Create('Parent node not assigned.',Self,'ReconstructFullNameInternal');
  ntLeaf,
  ntLeafArray:  TempStr := fName.Str;
else
  {ncUndefined}
  TempStr := '';
end;
If not Assigned(fParentNode) then
  begin
    If IncludeRoot then
      Result := TempStr
    else
      Result := '';
  end
else Result := fParentNode.ReconstructFullNameInternal(False,IncludeRoot) + TempStr;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.ValueFormatSettings: TUNSValueFormatSettings;
begin
If fMaster is TUniSettings then
  Result := TUniSettings(fMaster).ValueFormatSettings
else
  Result := UNS_VALUEFORMATSETTINGS_DEFAULT;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.BeginChanging;
begin
Inc(fChangeCounter);
fChanged := False;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.EndChanging;
begin
Dec(fChangeCounter);
If (fChangeCounter <= 0) and fChanged then
  begin
    fChangeCounter := 0;  
    If Assigned(fOnChange) then
      fOnChange(Self,Self);
    fChanged := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.DoChange;
begin
fChanged := True;
If Assigned(fOnChange) and (fChangeCounter <= 0) then
  fOnChange(Self,Self);
end;

//==============================================================================

constructor TUNSNodeBase.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create;
fName.Str := Name;
UniqueString(fName.Str);
UNSHashString(fName);
fParentNode := ParentNode; // must be before reconstructing full name
fFullName.Str := ReconstructFullNameInternal(True,False);
UNSHashString(fFullName);
fMaster := nil;
fAdditionIdx := -1;
fFlags := [];
FillChar(fConvSettings,SizeOf(fConvSettings),0);
fConvSettings.DecimalSeparator := '.';
fConvSettings.LongDateFormat := 'yyyy-mm-dd';
fConvSettings.ShortDateFormat := fConvSettings.LongDateFormat;
fConvSettings.DateSeparator := '-';
fConvSettings.LongTimeFormat := 'hh:nn:ss';
fConvSettings.ShortTimeFormat := fConvSettings.LongTimeFormat;
fConvSettings.TimeSeparator := ':';
fChanged := False;
fChangeCounter := 0;
fOnChange := nil;
end;

//------------------------------------------------------------------------------

constructor TUNSNodeBase.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
Create(Name,ParentNode);
If not UNSCompatibleNodes(Self,Source) then
  raise EUNSException.CreateFmt('Incompatible source class (%s).',[Source.ClassName],Self,'CreateCopy');
fFlags := Source.Flags;
// copy data in descendants
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.CreateCopy(const Name: String; ParentNode: TUNSNodeBase): TUNSNodeBase;
type
  TUNSNodeClass = class of TUNSNodeBase;
begin
Result := TUNSNodeClass(Self.ClassType).CreateAsCopy(Self,Name,ParentNode);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.GetFlag(Flag: TUNSValueFlag): Boolean;
begin
Result := Flag in fFlags;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.SetFlag(Flag: TUNSValueFlag);
begin
Include(fFlags,Flag);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.ResetFlag(Flag: TUNSValueFlag);
begin
Exclude(fFlags,Flag);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.ReconstructFullName(IncludeRoot: Boolean = False): String;
begin
Result := ReconstructFullNameInternal(True,IncludeRoot);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.ActualFromDefault;
begin
ValueKindMove(vkDefault,vkActual);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.DefaultFromActual;
begin
ValueKindMove(vkActual,vkDefault);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.ExchangeActualAndDefault;
begin
ValueKindExchange(vkActual,vkDefault);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.ActualEqualsDefault: Boolean;
begin
Result := ValueKindCompare(vkActual,vkDefault);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.Save;
begin
ValueKindMove(vkActual,vkSaved);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.Restore;
begin
ValueKindMove(vkSaved,vkActual);
end;

end.
