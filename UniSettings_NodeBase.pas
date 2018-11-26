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
    fFlags:         TUNSValueFlags;
    fConvSettings:  TFormatSettings;
    fChanged:       Boolean;
    fOnChange:      TNotifyEvent;
    class Function GetNodeClass: TUNSNodeClass; virtual;
    class Function GetValueType: TUNSValueType; virtual;
    procedure SetNodeNameStr(const Value: String); virtual;
    procedure SetMaster(Value: TObject); virtual;
    Function GetNodeLevel: Integer; virtual;
    Function GetMaxNodeLevel: Integer; virtual;
    procedure SetChanged(Value: Boolean); virtual;
    Function ReconstructFullNameInternal(TopLevelCall: Boolean; IncludeRoot: Boolean): String; virtual;
    Function ValueFormatSettings: TUNSValueFormatSettings; virtual;
    procedure DoChange; virtual;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    Function GetFlag(Flag: TUNSValueFlag): Boolean; virtual;
    procedure SetFlag(Flag: TUNSValueFlag); virtual;
    procedure ResetFlag(Flag: TUNSValueFlag); virtual;
    Function ReconstructFullName(IncludeRoot: Boolean = False): String; virtual;
    procedure ActualFromDefault; overload; virtual; abstract;
    procedure DefaultFromActual; overload; virtual; abstract;
    procedure ExchangeActualAndDefault; overload; virtual; abstract;
    Function ActualEqualsDefault: Boolean; overload; virtual; abstract;
    property NodeClass: TUNSNodeClass read GetNodeClass;
    property ValueType: TUNSValueType read GetValueType;
    property Name: TUNSHashedString read fName write fName;       
    property NameStr: String read fName.Str write SetNodeNameStr;
    property ParentNode: TUNSNodeBase read fParentNode;
    property Master: TObject read fMaster write SetMaster;
    property NodeLevel: Integer read GetNodeLevel;
    property MaxNodeLevel: Integer read GetMaxNodeLevel;    
    property Flags: TUNSValueFlags read fFlags write fFlags;
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

class Function TUNSNodeBase.GetValueType: TUNSValueType;
begin
Result := vtUndefined;
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

Function TUNSNodeBase.ReconstructFullNameInternal(TopLevelCall: Boolean; IncludeRoot: Boolean): String;
var
  TempStr:  String;
begin
case GetNodeClass of
  ncBranch:     If TopLevelCall then
                  TempStr := fName.Str
                else
                  TempStr := fName.Str + UNS_NAME_DELIMITER;
  ncArray:      If TopLevelCall then
                  TempStr := Format('%s[]',[fName.Str])
                else If (TUNSNodeArray(Self).Count <= 0) then
                  TempStr := Format('%s[]',[fName.Str]) + UNS_NAME_DELIMITER
                else
                  TempStr := fName.Str;
  ncArrayItem:  If Assigned(fParentNode) then
                  begin
                    If TopLevelCall or (TUNSNodeArrayItem(Self).Count <= 0) then
                      TempStr := Format('[%d]',[TUNSNodeArrayItem(Self).ArrayIndex])
                    else
                      TempStr := Format('[%d]',[TUNSNodeArrayItem(Self).ArrayIndex]) + UNS_NAME_DELIMITER;
                  end
                else raise EUNSException.Create('Parent node not assigned.',Self,'ReconstructFullNameInternal');
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
else Result := fParentNode.ReconstructFullNameInternal(False,IncludeRoot) + TempStr;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBase.ValueFormatSettings: TUNSValueFormatSettings;
begin
If Assigned(fMaster) then
  Result := TUniSettings(fMaster).ValueFormatSettings
else
  Result := UNS_VALUEFORMATSETTINGS_DEFAULT;
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

end.
