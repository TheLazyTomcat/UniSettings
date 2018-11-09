unit UniSettings_NodeBase;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils,
  AuxClasses,
  UniSettings_Common;

type
  TUNSNodeBase = class(TCustomObject)
  protected
    fName:          TUNSHashedString;
    fParentNode:    TUNSNodeBase;
    fMaster:        TObject;
    fFlags:         TUNSNodeFlags;
    fConvSettings:  TFormatSettings;
    fChanged:       Boolean;
    fOnChange:      TNotifyEvent;
{*} class Function GetNodeClass: TUNSNodeClass; virtual;
{*} class Function GetNodeDataType: TUNSNodeDataType; virtual;
    procedure SetNodeNameStr(const Value: String); virtual;
{*} procedure SetMaster(Value: TObject); virtual;
    Function GetNodeLevel: Integer; virtual;
{*} Function GetMaxNodeLevel: Integer; virtual;
    procedure SetChanged(Value: Boolean); virtual;
    Function ReconstructFullPathInternal(TopLevelCall: Boolean; IncludeRoot: Boolean): String; virtual;
    Function FormatSettings: TUNSFormatSettings; virtual;
    procedure DoChange; virtual;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    procedure SetFlag(Flag: TUNSNodeFlag); virtual;
    procedure ResetFlag(Flag: TUNSNodeFlag); virtual;
    Function ReconstructFullPath(IncludeRoot: Boolean = False): String; virtual;
{!} procedure ActualFromDefault; overload; virtual; abstract;
{!} procedure DefaultFromActual; overload; virtual; abstract;
{!} procedure ExchangeActualAndDefault; overload; virtual; abstract;
{!} Function ActualEqualsDefault: Boolean; overload; virtual; abstract;
    property NodeClass: TUNSNodeClass read GetNodeClass;
    property NodeDataType: TUNSNodeDataType read GetNodeDataType;
    property Name: TUNSHashedString read fName write fName;       
    property NameStr: String read fName.Str write SetNodeNameStr;
    property ParentNode: TUNSNodeBase read fParentNode;
    property Master: TObject read fMaster write SetMaster;
    property NodeLevel: Integer read GetNodeLevel;
    property MaxNodeLevel: Integer read GetMaxNodeLevel;    
    property Flags: TUNSNodeFlags read fFlags write fFlags;
    property Changed: Boolean read fChanged write SetChanged;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

implementation

uses
  UniSettings_Utils, UniSettings_Exceptions, UniSettings_NodeBranch,
  UniSettings_NodeArray, UniSettings_NodeArrayItem, UniSettings;

class Function TUNSNodeBase.GetNodeClass: TUNSNodeClass;
begin
Result := ncUndefined;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeBase.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtUndefined;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.SetNodeNameStr(const Value: String);
begin
fName.Str := Value;
UNSHashString(fName);
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

procedure TUNSNodeBase.SetChanged(Value: Boolean);
begin
If Value <> fChanged then
  begin
    fChanged := Value;
    If Value and Assigned(fParentNode) then
      fParentNode.Changed := Value;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.ReconstructFullPathInternal(TopLevelCall: Boolean; IncludeRoot: Boolean): String;
var
  TempStr:  String;
begin
case GetNodeClass of
  ncBranch:     TempStr := fName.Str + UNS_PATH_DELIMITER;
  ncArray:      If TopLevelCall then
                  TempStr := Format('%s[]',[fName.Str])
                else If (TUNSNodeArray(Self).Count <= 0) then
                  TempStr := Format('%s[]',[fName.Str]) + UNS_PATH_DELIMITER
                else
                  TempStr := fName.Str;
  ncArrayItem:  If Assigned(fParentNode) then
                  begin
                    If TopLevelCall or (TUNSNodeArrayItem(Self).Count <= 0) then
                      TempStr := Format('[%d]',[TUNSNodeArrayItem(Self).ArrayIndex])
                    else
                      TempStr := Format('[%d]',[TUNSNodeArrayItem(Self).ArrayIndex]) + UNS_PATH_DELIMITER;
                  end
                else raise EUNSException.Create('Parent node not assigned.',Self,'ReconstructFullPathInternal');
  ncLeaf:       TempStr := fName.Str;
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
else Result := Result + fParentNode.ReconstructFullPathInternal(False,IncludeRoot);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.FormatSettings: TUNSFormatSettings;
begin
If Assigned(fMaster) then
  Result := TUniSettings(fMaster).FormatSettings
else
  Result := UNS_FORMATSETTINGS_DEFAULT;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.DoChange;
begin
SetChanged(True);
If Assigned(fOnChange) then
  fOnChange(Self);
end;

//==============================================================================

constructor TUNSNodeBase.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create;
fName := UNSHashedString(Name);
fParentNode := ParentNode;
fMaster := nil;
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
fOnChange := nil;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.SetFlag(Flag: TUNSNodeFlag);
begin
Include(fFlags,Flag);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBase.ResetFlag(Flag: TUNSNodeFlag);
begin
Exclude(fFlags,Flag);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.ReconstructFullPath(IncludeRoot: Boolean = False): String;
begin
Result := ReconstructFullPathInternal(True,IncludeRoot);
end;

end.
