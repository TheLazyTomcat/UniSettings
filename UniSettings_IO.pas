unit UniSettings_IO;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  IniFiles, Registry,
  IniFileEx,
  UniSettings_Base;

type
  TUniSettingsIO = class(TUniSettingsBase)
  public
    //--- IO operations (no lock) ----------------------------------------------
    procedure SaveToIniNoLock(Ini: TIniFile); overload; virtual;
    procedure SaveToIniNoLock(Ini: TIniFileEx); overload; virtual;
    procedure SaveToRegistryNoLock(Reg: TRegistry); overload; virtual;
    //procedure SaveToRegistryNoLock(Reg: TRegistryEx); overload; virtual;
    procedure LoadFromIniNoLock(Ini: TIniFile); overload; virtual;
    procedure LoadFromIniNoLock(Ini: TIniFileEx); overload; virtual;
    procedure LoadFromRegistryNoLock(Reg: TRegistry); overload; virtual;
    //procedure LoadFromRegistryNoLock(Reg: TRegistryEx); overload; virtual;
    //--- IO operations (lock) -------------------------------------------------
    procedure SaveToIni(Ini: TIniFile); overload; virtual;
    procedure SaveToIni(Ini: TIniFileEx); overload; virtual;
    procedure SaveToRegistry(Reg: TRegistry); overload; virtual;
    //procedure SaveToRegistry(Reg: TRegistryEx); overload; virtual;    
    procedure LoadFromIni(Ini: TIniFile); overload; virtual;
    procedure LoadFromIni(Ini: TIniFileEx); overload; virtual;
    procedure LoadFromRegistry(Reg: TRegistry); overload; virtual;
    //procedure LoadFromRegistry(Reg: TRegistryEx); overload; virtual;
  end;

implementation

uses
  SysUtils, Classes, StrUtils,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_Utils, UniSettings_Exceptions,
  UniSettings_NodeUtils, UniSettings_NodeBase, UniSettings_NodeLeaf,
  UniSettings_NodePrimitiveArray,
  // leaf nodes
  UniSettings_NodeBlank,
  UniSettings_NodeBool,
  UniSettings_NodeInt8,
  UniSettings_NodeUInt8,
  UniSettings_NodeInt16,
  UniSettings_NodeUInt16,
  UniSettings_NodeInt32,
  UniSettings_NodeUInt32,
  UniSettings_NodeInt64,
  UniSettings_NodeUInt64,
  UniSettings_NodeFloat32,
  UniSettings_NodeFloat64,
  UniSettings_NodeDateTime,
  UniSettings_NodeDate,
  UniSettings_NodeTime,
  UniSettings_NodeText,
  UniSettings_NodeBuffer,
  // leaf array nodes
  UniSettings_NodeAoBool,
  UniSettings_NodeAoInt8,
  UniSettings_NodeAoUInt8,
  UniSettings_NodeAoInt16,
  UniSettings_NodeAoUInt16,
  UniSettings_NodeAoInt32,
  UniSettings_NodeAoUInt32,
  UniSettings_NodeAoInt64,
  UniSettings_NodeAoUInt64,
  UniSettings_NodeAoFloat32,
  UniSettings_NodeAoFloat64,
  UniSettings_NodeAoDateTime,
  UniSettings_NodeAoDate,
  UniSettings_NodeAoTime,
  UniSettings_NodeAoText,
  UniSettings_NodeAoBuffer;

const
  UNS_REGISTRY_PATH_DELIM = '\';

procedure TUniSettingsIO.SaveToIniNoLock(Ini: TIniFile);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;
begin
NodeList := TStringList.Create;
try
  ListValuesWithNodes(NodeList,False);
  For i := 0 to Pred(NodeList.Count) do
    If NodeList.Objects[i] is TUNSNodeBase then
      If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
        begin
          Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
          Section := UNSIniSectionEncode(
            Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
          If Length(Section) <= 0 then
            Section := '*'; // windows does not like empty section name
          TUNSNodeLeaf(NodeList.Objects[i]).SaveTo(Ini,Section,Key);
        end;
finally
  NodeList.Free;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsIO.SaveToIniNoLock(Ini: TIniFileEx);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;
begin
If (Ini.SectionStartChar = '[') and (Ini.SectionEndChar = ']') then
  begin
    NodeList := TStringList.Create;
    try
      ListValuesWithNodes(NodeList,False);
      For i := 0 to Pred(NodeList.Count) do
        If NodeList.Objects[i] is TUNSNodeBase then
          If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
            begin
              Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
              Section := UNSIniSectionEncode(
                Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
              TUNSNodeLeaf(NodeList.Objects[i]).SaveTo(Ini,Section,Key);
            end;
    finally
      NodeList.Free;
    end;
  end
else EUNSException.Create('Invalid ini file.',Self,'SaveToIniNoLock');
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.SaveToRegistryNoLock(Reg: TRegistry);
var
  NodeList:   TStringList;
  InitialKey: String;
  i:          Integer;
  ValueName:  String;
  RegKey:     String;
begin
NodeList := TStringList.Create;
try
  InitialKey := Reg.CurrentPath;
  try
    ListValuesWithNodes(NodeList,False);
    NodeList.Sort;  // eliminates unnecessary registry key switches
    For i := 0 to Pred(NodeList.Count) do
      If NodeList.Objects[i] is TUNSNodeBase then
        If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
          begin
            ValueName := TUNSNodeBase(NodeList.Objects[i]).NameStr;
            RegKey := AnsiReplaceStr(
              Copy(NodeList[i],1,Length(NodeList[i]) - Length(ValueName) - 1),
              UNS_NAME_DELIMITER,UNS_REGISTRY_PATH_DELIM);
            If not AnsiSameText(Reg.CurrentPath,InitialKey + UNS_REGISTRY_PATH_DELIM + RegKey) then
              begin
                Reg.CloseKey;
                Reg.OpenKey(InitialKey + UNS_REGISTRY_PATH_DELIM + RegKey,True)
              end;
            TUNSNodeLeaf(NodeList.Objects[i]).SaveTo(Reg,ValueName);
          end;
  finally
    Reg.CloseKey;
    Reg.OpenKey(InitialKey,False);
  end;
finally
  NodeList.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.LoadFromIniNoLock(Ini: TIniFile);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;
begin
NodeList := TStringList.Create;
try
  ListValuesWithNodes(NodeList,False);
  BeginChanging;
  try
    For i := 0 to Pred(NodeList.Count) do
      If NodeList.Objects[i] is TUNSNodeBase then
        If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
          begin
            Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
            Section := UNSIniSectionEncode(
              Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
            TUNSNodeLeaf(NodeList.Objects[i]).LoadFrom(Ini,Section,Key);
          end;
  finally
    EndChanging;
  end;
finally
  NodeList.Free;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsIO.LoadFromIniNoLock(Ini: TIniFileEx);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;
begin
If (Ini.SectionStartChar = '[') and (Ini.SectionEndChar = ']') then
  begin
    NodeList := TStringList.Create;
    try
      ListValuesWithNodes(NodeList,False);
      BeginChanging;
      try
        For i := 0 to Pred(NodeList.Count) do
          If NodeList.Objects[i] is TUNSNodeBase then
            If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
              begin
                Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
                Section := UNSIniSectionEncode(
                  Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
                TUNSNodeLeaf(NodeList.Objects[i]).LoadFrom(Ini,Section,Key);
              end;
      finally
        EndChanging;
      end;
    finally
      NodeList.Free;
    end;
  end
else EUNSException.Create('Invalid ini file.',Self,'LoadFromIniNoLock');
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.LoadFromRegistryNoLock(Reg: TRegistry);
var
  NodeList:   TStringList;
  InitialKey: String;
  i:          Integer;
  ValueName:  String;
  RegKey:     String;
begin
NodeList := TStringList.Create;
try
  InitialKey := Reg.CurrentPath;
  try
    ListValuesWithNodes(NodeList,False);
    NodeList.Sort;
    BeginChanging;
    try
      For i := 0 to Pred(NodeList.Count) do
        If NodeList.Objects[i] is TUNSNodeBase then
          If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
            begin
              ValueName := TUNSNodeBase(NodeList.Objects[i]).NameStr;
              RegKey := AnsiReplaceStr(
                Copy(NodeList[i],1,Length(NodeList[i]) - Length(ValueName) - 1),
                UNS_NAME_DELIMITER,UNS_REGISTRY_PATH_DELIM);
              If not AnsiSameText(Reg.CurrentPath,InitialKey + UNS_REGISTRY_PATH_DELIM + RegKey) then
                begin
                  Reg.CloseKey;
                  Reg.OpenKey(InitialKey + UNS_REGISTRY_PATH_DELIM + RegKey,True)
                end;
              TUNSNodeLeaf(NodeList.Objects[i]).LoadFrom(Reg,ValueName);
            end;
    finally
      EndChanging;
    end;
  finally
    Reg.CloseKey;
    Reg.OpenKey(InitialKey,False);
  end;
finally
  NodeList.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.SaveToIni(Ini: TIniFile);
begin
ReadLock;
try
  SaveToIniNoLock(Ini);
finally
  ReadUnlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsIO.SaveToIni(Ini: TIniFileEx);
begin
ReadLock;
try
  SaveToIniNoLock(Ini);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.SaveToRegistry(Reg: TRegistry);
begin
ReadLock;
try
  SaveToRegistryNoLock(Reg);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.LoadFromIni(Ini: TIniFile);
begin
WriteLock;
try
  LoadFromIniNoLock(Ini);
finally
  WriteUnlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsIO.LoadFromIni(Ini: TIniFileEx);
begin
WriteLock;
try
  LoadFromIniNoLock(Ini);
finally
  WriteUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.LoadFromRegistry(Reg: TRegistry);
begin
WriteLock;
try
  LoadFromRegistryNoLock(Reg);
finally
  WriteUnlock;
end;
end;


end.
