unit UniSettings_IO;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  IniFiles,
  IniFileEx,
  UniSettings_Base;

type
  TUniSettingsIO = class(TUniSettingsBase)
  public
    //--- IO operations (no lock) ----------------------------------------------
    procedure SaveToIniNoLock(Ini: TIniFileEx); overload; virtual;
    procedure SaveToIniNoLock(Ini: TIniFile); overload; virtual;
    procedure LoadFromIniNoLock(Ini: TIniFileEx); overload; virtual;
    procedure LoadFromIniNoLock(Ini: TIniFile); overload; virtual;
    //procedure SaveToRegistryNoLock
    //procedure LoadFromRegistryNoLock
    //--- IO operations (lock) -------------------------------------------------
    procedure SaveToIni(Ini: TIniFileEx); overload; virtual;
    procedure SaveToIni(Ini: TIniFile); overload; virtual;
    procedure LoadFromIni(Ini: TIniFileEx); overload; virtual;
    procedure LoadFromIni(Ini: TIniFile); overload; virtual;
    //SaveToRegistry
    //LoadFromRegistry  
  end;

implementation

uses
  SysUtils, Classes,
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

procedure TUniSettingsIO.SaveToIniNoLock(Ini: TIniFileEx);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;

  procedure WriteArrayValue(Node: TUNSNodePrimitiveArray);
  var
    ii: Integer;
  begin
    Ini.WriteInteger(Section,Key,Node.Count);
    case Node.ValueType of
      vtAoBool:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteBool(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoBool(Node).Items[ii]);
      vtAoInt8:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInt8(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt8(Node).Items[ii]);
      vtAoUInt8:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteUInt8(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt8(Node).Items[ii]);
      vtAoInt16:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInt16(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt16(Node).Items[ii]);
      vtAoUInt16:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteUInt16(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt16(Node).Items[ii]);
      vtAoInt32:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInt32(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt32(Node).Items[ii]);
      vtAoUInt32:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteUInt32(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt32(Node).Items[ii]);
      vtAoInt64:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInt64(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt64(Node).Items[ii]);
      vtAoUInt64:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteUInt64(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt64(Node).Items[ii]);
      vtAoFloat32:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteFloat32(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoFloat32(Node).Items[ii]);
      vtAoFloat64:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteFloat64(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoFloat64(Node).Items[ii]);
      vtAoDate:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteDate(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoDate(Node).Items[ii]);
      vtAoTime:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteTime(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoTime(Node).Items[ii]);
      vtAoDateTime: For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteDateTime(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoDateTime(Node).Items[ii]);
      vtAoText:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoText(Node).Items[ii]);
      vtAoBuffer:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteBinaryMemory(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoBuffer(Node).Items[ii].Memory,
                                            TUNSNodeAoBuffer(Node).Items[ii].Size,True);
    else
      raise EUNSException.CreateFmt('Invalid node value type (%d).',
        [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'SaveToIniNoLock.WriteArrayValue');
    end;
  end;

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
              Section := UNSIniSectionEncode(Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
              If not UNSIsPrimitiveArrayNode(TUNSNodeBase(NodeList.Objects[i])) then
                case TUNSNodeLeaf(NodeList.Objects[i]).ValueType of
                  vtBlank:      Ini.WriteString(Section,Key,'');
                  vtBool:       Ini.WriteBool(Section,Key,TUNSNodeBool(NodeList.Objects[i]).Value);
                  vtInt8:       Ini.WriteInt8(Section,Key,TUNSNodeInt8(NodeList.Objects[i]).Value);
                  vtUInt8:      Ini.WriteUInt8(Section,Key,TUNSNodeUInt8(NodeList.Objects[i]).Value);
                  vtInt16:      Ini.WriteInt16(Section,Key,TUNSNodeInt16(NodeList.Objects[i]).Value);
                  vtUInt16:     Ini.WriteUInt16(Section,Key,TUNSNodeUInt16(NodeList.Objects[i]).Value);
                  vtInt32:      Ini.WriteInt32(Section,Key,TUNSNodeInt32(NodeList.Objects[i]).Value);
                  vtUInt32:     Ini.WriteUInt32(Section,Key,TUNSNodeUInt32(NodeList.Objects[i]).Value);
                  vtInt64:      Ini.WriteInt64(Section,Key,TUNSNodeInt64(NodeList.Objects[i]).Value);
                  vtUInt64:     Ini.WriteUInt64(Section,Key,TUNSNodeUInt64(NodeList.Objects[i]).Value);
                  vtFloat32:    Ini.WriteFloat32(Section,Key,TUNSNodeFloat32(NodeList.Objects[i]).Value);
                  vtFloat64:    Ini.WriteFloat64(Section,Key,TUNSNodeFloat64(NodeList.Objects[i]).Value);
                  vtDate:       Ini.WriteDate(Section,Key,TUNSNodeDate(NodeList.Objects[i]).Value);
                  vtTime:       Ini.WriteTime(Section,Key,TUNSNodeTime(NodeList.Objects[i]).Value);
                  vtDateTime:   Ini.WriteDateTime(Section,Key,TUNSNodeDateTime(NodeList.Objects[i]).Value);
                  vtText:       Ini.WriteString(Section,Key,TUNSNodeText(NodeList.Objects[i]).Value);
                  vtBuffer:     Ini.WriteBinaryMemory(Section,Key,TUNSNodeBuffer(NodeList.Objects[i]).Value.Memory,
                                                      TUNSNodeBuffer(NodeList.Objects[i]).Value.Size,True);
                else
                 {vtUndefined}
                  raise EUNSException.CreateFmt('Invalid node value type (%d).',
                    [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'SaveToIniNoLock');
                end
              else WriteArrayValue(TUNSNodePrimitiveArray(NodeList.Objects[i]));
            end;  
    finally
      NodeList.Free;
    end;
  end
else EUNSException.Create('Invalid ini file.',Self,'SaveToIniNoLock');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsIO.SaveToIniNoLock(Ini: TIniFile);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;

  procedure WriteArrayValue(Node: TUNSNodePrimitiveArray);
  var
    ii: Integer;
  begin
    Ini.WriteInteger(Section,Key,Node.Count);
    case Node.ValueType of
      vtAoBool:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteBool(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoBool(Node).Items[ii]);
      vtAoInt8:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoInt8(Node).Items[ii]));
      vtAoUInt8:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoUInt8(Node).Items[ii]));
      vtAoInt16:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoInt16(Node).Items[ii]));
      vtAoUInt16:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoUInt16(Node).Items[ii]));
      vtAoInt32:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoInt32(Node).Items[ii]));
      vtAoUInt32:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteInteger(Section,Format('%s[%d]',[Key,ii]),Integer(TUNSNodeAoUInt32(Node).Items[ii]));
      vtAoInt64:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoInt64(Node).AsString(ii,vkActual));
      vtAoUInt64:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoUInt64(Node).AsString(ii,vkActual));
      vtAoFloat32:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteFloat(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoFloat32(Node).Items[ii]);
      vtAoFloat64:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteFloat(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoFloat64(Node).Items[ii]);
      vtAoDate:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteDate(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoDate(Node).Items[ii]);
      vtAoTime:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteTime(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoTime(Node).Items[ii]);
      vtAoDateTime: For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteDateTime(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoDateTime(Node).Items[ii]);
      vtAoText:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoText(Node).Items[ii]);
      vtAoBuffer:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      Ini.WriteString(Section,Format('%s[%d]',[Key,ii]),TUNSNodeAoBuffer(Node).AsString(ii,vkActual));
    else
      raise EUNSException.CreateFmt('Invalid node value type (%d).',
        [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'SaveToIniNoLock.WriteArrayValue');
    end;
  end;

begin
NodeList := TStringList.Create;
try
  ListValuesWithNodes(NodeList,False);
  For i := 0 to Pred(NodeList.Count) do
    If NodeList.Objects[i] is TUNSNodeBase then
      If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
        begin
          Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
          Section := UNSIniSectionEncode(Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
          If Length(Section) <= 0 then
            Section := '*'; // windows does not like empty section name
          If not UNSIsPrimitiveArrayNode(TUNSNodeBase(NodeList.Objects[i])) then
            case TUNSNodeLeaf(NodeList.Objects[i]).ValueType of
              vtBlank:      Ini.WriteString(Section,Key,'');
              vtBool:       Ini.WriteBool(Section,Key,TUNSNodeBool(NodeList.Objects[i]).Value);
              vtInt8:       Ini.WriteInteger(Section,Key,Integer(TUNSNodeInt8(NodeList.Objects[i]).Value));
              vtUInt8:      Ini.WriteInteger(Section,Key,Integer(TUNSNodeUInt8(NodeList.Objects[i]).Value));
              vtInt16:      Ini.WriteInteger(Section,Key,Integer(TUNSNodeInt16(NodeList.Objects[i]).Value));
              vtUInt16:     Ini.WriteInteger(Section,Key,Integer(TUNSNodeUInt16(NodeList.Objects[i]).Value));
              vtInt32:      Ini.WriteInteger(Section,Key,Integer(TUNSNodeInt32(NodeList.Objects[i]).Value));
              vtUInt32:     Ini.WriteInteger(Section,Key,Integer(TUNSNodeUInt32(NodeList.Objects[i]).Value));
              vtInt64:      Ini.WriteString(Section,Key,TUNSNodeInt64(NodeList.Objects[i]).AsString(vkActual));
              vtUInt64:     Ini.WriteString(Section,Key,TUNSNodeUInt64(NodeList.Objects[i]).AsString(vkActual));
              vtFloat32:    Ini.WriteFloat(Section,Key,TUNSNodeFloat32(NodeList.Objects[i]).Value);
              vtFloat64:    Ini.WriteFloat(Section,Key,TUNSNodeFloat64(NodeList.Objects[i]).Value);
              vtDate:       Ini.WriteDate(Section,Key,TUNSNodeDate(NodeList.Objects[i]).Value);
              vtTime:       Ini.WriteTime(Section,Key,TUNSNodeTime(NodeList.Objects[i]).Value);
              vtDateTime:   Ini.WriteDateTime(Section,Key,TUNSNodeDateTime(NodeList.Objects[i]).Value);
              vtText:       Ini.WriteString(Section,Key,TUNSNodeText(NodeList.Objects[i]).Value);
              vtBuffer:     Ini.WriteString(Section,Key,TUNSNodeBuffer(NodeList.Objects[i]).AsString(vkActual));
            else
             {vtUndefined}
              raise EUNSException.CreateFmt('Invalid node value type (%d).',
                [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'SaveToIniNoLock');
            end
          else WriteArrayValue(TUNSNodePrimitiveArray(NodeList.Objects[i]));
        end;  
finally
  NodeList.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.LoadFromIniNoLock(Ini: TIniFileEx);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;
  Buffer:   TMemoryBuffer;

  procedure ReadArrayValue(Node: TUNSNodePrimitiveArray);
  var
    ii: Integer;
  begin
    Node.PrepareEmptyItems(Ini.ReadInteger(Section,Key),vkActual);
    case Node.ValueType of
      vtAoBool:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoBool(Node).Items[ii] := Ini.ReadBool(Section,Format('%s[%d]',[Key,ii]));
      vtAoInt8:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt8(Node).Items[ii] := Ini.ReadInt8(Section,Format('%s[%d]',[Key,ii]));
      vtAoUInt8:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt8(Node).Items[ii] := Ini.ReadUInt8(Section,Format('%s[%d]',[Key,ii]));
      vtAoInt16:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt16(Node).Items[ii] := Ini.ReadInt16(Section,Format('%s[%d]',[Key,ii]));
      vtAoUInt16:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt16(Node).Items[ii] := Ini.ReadUInt16(Section,Format('%s[%d]',[Key,ii]));
      vtAoInt32:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt32(Node).Items[ii] := Ini.ReadInt32(Section,Format('%s[%d]',[Key,ii]));
      vtAoUInt32:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt32(Node).Items[ii] := Ini.ReadUInt32(Section,Format('%s[%d]',[Key,ii]));
      vtAoInt64:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt64(Node).Items[ii] := Ini.ReadInt64(Section,Format('%s[%d]',[Key,ii]));
      vtAoUInt64:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt64(Node).Items[ii] := Ini.ReadUInt64(Section,Format('%s[%d]',[Key,ii]));
      vtAoFloat32:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoFloat32(Node).Items[ii] := Ini.ReadFloat32(Section,Format('%s[%d]',[Key,ii]));
      vtAoFloat64:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoFloat64(Node).Items[ii] := Ini.ReadFloat64(Section,Format('%s[%d]',[Key,ii]));
      vtAoDate:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoDate(Node).Items[ii] := Ini.ReadDate(Section,Format('%s[%d]',[Key,ii]));
      vtAoTime:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoTime(Node).Items[ii] := Ini.ReadTime(Section,Format('%s[%d]',[Key,ii]));
      vtAoDateTime: For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoDateTime(Node).Items[ii] := Ini.ReadDateTime(Section,Format('%s[%d]',[Key,ii]));
      vtAoText:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoText(Node).Items[ii] := Ini.ReadString(Section,Format('%s[%d]',[Key,ii]));
      vtAoBuffer:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      begin
                        Buffer.Size := Ini.ReadBinaryMemory(Section,Format('%s[%d]',[Key,ii]),Buffer.Memory,True);
                        try
                          TUNSNodeAoBuffer(NodeList.Objects[i]).Items[ii] := Buffer;
                        finally
                          FreeBuffer(Buffer);
                        end;
                      end;
    else
      raise EUNSException.CreateFmt('Invalid node value type (%d).',
        [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'LoadFromIniNoLock.ReadArrayValue');
    end;
  end;

begin
If (Ini.SectionStartChar = '[') and (Ini.SectionEndChar = ']') then
  begin
    NodeList := TStringList.Create;
    try
      InitBuffer(Buffer);
      ListValuesWithNodes(NodeList,False);
      For i := 0 to Pred(NodeList.Count) do
        If NodeList.Objects[i] is TUNSNodeBase then
          If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
            begin
              Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
              Section := UNSIniSectionEncode(Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
              BeginChanging;
              try
                If not UNSIsPrimitiveArrayNode(TUNSNodeBase(NodeList.Objects[i])) then
                  case TUNSNodeLeaf(NodeList.Objects[i]).ValueType of
                    vtBlank:      ; // do nothing
                    vtBool:       TUNSNodeBool(NodeList.Objects[i]).Value := Ini.ReadBool(Section,Key);
                    vtInt8:       TUNSNodeInt8(NodeList.Objects[i]).Value := Ini.ReadInt8(Section,Key);
                    vtUInt8:      TUNSNodeUInt8(NodeList.Objects[i]).Value := Ini.ReadUInt8(Section,Key);
                    vtInt16:      TUNSNodeInt16(NodeList.Objects[i]).Value := Ini.ReadInt16(Section,Key);
                    vtUInt16:     TUNSNodeUInt16(NodeList.Objects[i]).Value := Ini.ReadUInt16(Section,Key);
                    vtInt32:      TUNSNodeInt32(NodeList.Objects[i]).Value := Ini.ReadInt32(Section,Key);
                    vtUInt32:     TUNSNodeUInt32(NodeList.Objects[i]).Value := Ini.ReadUInt32(Section,Key);
                    vtInt64:      TUNSNodeInt64(NodeList.Objects[i]).Value := Ini.ReadInt64(Section,Key);
                    vtUInt64:     TUNSNodeUInt64(NodeList.Objects[i]).Value := Ini.ReadUInt64(Section,Key);
                    vtFloat32:    TUNSNodeFloat32(NodeList.Objects[i]).Value := Ini.ReadFloat32(Section,Key);
                    vtFloat64:    TUNSNodeFloat64(NodeList.Objects[i]).Value := Ini.ReadFloat64(Section,Key);
                    vtDate:       TUNSNodeDate(NodeList.Objects[i]).Value := Ini.ReadDate(Section,Key);
                    vtTime:       TUNSNodeTime(NodeList.Objects[i]).Value := Ini.ReadTime(Section,Key);
                    vtDateTime:   TUNSNodeDateTime(NodeList.Objects[i]).Value := Ini.ReadDateTime(Section,Key);
                    vtText:       TUNSNodeText(NodeList.Objects[i]).Value := Ini.ReadString(Section,Key);
                    vtBuffer:     begin
                                    Buffer.Size := Ini.ReadBinaryMemory(Section,Key,Buffer.Memory,False);
                                    try
                                      TUNSNodeBuffer(NodeList.Objects[i]).Value := Buffer;
                                    finally
                                      FreeBuffer(Buffer);
                                    end;
                                  end;
                  else
                   {vtUndefined}
                    raise EUNSException.CreateFmt('Invalid node value type (%d).',
                      [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'LoadFromIniNoLock');
                  end
                else ReadArrayValue(TUNSNodePrimitiveArray(NodeList.Objects[i]));
              finally
                EndChanging;
              end;
            end;  
    finally
      NodeList.Free;
    end;
  end
else EUNSException.Create('Invalid ini file.',Self,'LoadFromIniNoLock');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsIO.LoadFromIniNoLock(Ini: TIniFile);
var
  NodeList: TStringList;
  i:        Integer;
  Key:      String;
  Section:  String;

  procedure ReadArrayValue(Node: TUNSNodePrimitiveArray);
  var
    ii: Integer;
  begin
    Node.PrepareEmptyItems(Ini.ReadInteger(Section,Key,0),vkActual);
    case Node.ValueType of
      vtAoBool:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoBool(Node).Items[ii] := Ini.ReadBool(Section,Format('%s[%d]',[Key,ii]),False);
      vtAoInt8:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt8(Node).Items[ii] := Int8(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoUInt8:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt8(Node).Items[ii] := UInt8(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoInt16:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt16(Node).Items[ii] := Int16(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoUInt16:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt16(Node).Items[ii] := Uint16(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoInt32:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt32(Node).Items[ii] := Int32(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoUInt32:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt32(Node).Items[ii] := Uint32(Ini.ReadInteger(Section,Format('%s[%d]',[Key,ii]),0));
      vtAoInt64:    For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoInt64(Node).FromString(ii,Ini.ReadString(Section,Format('%s[%d]',[Key,ii]),'0'),vkActual);
      vtAoUInt64:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoUInt64(Node).FromString(ii,Ini.ReadString(Section,Format('%s[%d]',[Key,ii]),'0'),vkActual);
      vtAoFloat32:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoFloat32(Node).Items[ii] := Ini.ReadFloat(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoFloat64:  For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoFloat64(Node).Items[ii] := Ini.ReadFloat(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoDate:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoDate(Node).Items[ii] := Ini.ReadDate(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoTime:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoTime(Node).Items[ii] := Ini.ReadTime(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoDateTime: For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoDateTime(Node).Items[ii] := Ini.ReadDateTime(Section,Format('%s[%d]',[Key,ii]),0.0);
      vtAoText:     For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoText(Node).Items[ii] := Ini.ReadString(Section,Format('%s[%d]',[Key,ii]),'');
      vtAoBuffer:   For ii := Node.LowIndex(vkActual) to Node.HighIndex(vkActual) do
                      TUNSNodeAoBuffer(NodeList.Objects[i]).FromString(ii,Ini.ReadString(Section,Format('%s[%d]',[Key,ii]),''));
    else
      raise EUNSException.CreateFmt('Invalid node value type (%d).',
        [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'LoadFromIniNoLock.ReadArrayValue');
    end;
  end;

begin
NodeList := TStringList.Create;
try
  ListValuesWithNodes(NodeList,False);
  For i := 0 to Pred(NodeList.Count) do
    If NodeList.Objects[i] is TUNSNodeBase then
      If UNSIsLeafNode(TUNSNodeBase(NodeList.Objects[i])) then
        begin
          Key := TUNSNodeBase(NodeList.Objects[i]).NameStr;
          Section := UNSIniSectionEncode(Copy(NodeList[i],1,Length(NodeList[i]) - Length(Key) - Length(UNS_NAME_DELIMITER)));
          BeginChanging;
          try
            If not UNSIsPrimitiveArrayNode(TUNSNodeBase(NodeList.Objects[i])) then
              case TUNSNodeLeaf(NodeList.Objects[i]).ValueType of
                vtBlank:      ; // do nothing
                vtBool:       TUNSNodeBool(NodeList.Objects[i]).Value := Ini.ReadBool(Section,Key,False);
                vtInt8:       TUNSNodeInt8(NodeList.Objects[i]).Value := Int8(Ini.ReadInteger(Section,Key,0));
                vtUInt8:      TUNSNodeUInt8(NodeList.Objects[i]).Value := UInt8(Ini.ReadInteger(Section,Key,0));
                vtInt16:      TUNSNodeInt16(NodeList.Objects[i]).Value := Int16(Ini.ReadInteger(Section,Key,0));
                vtUInt16:     TUNSNodeUInt16(NodeList.Objects[i]).Value := UInt16(Ini.ReadInteger(Section,Key,0));
                vtInt32:      TUNSNodeInt32(NodeList.Objects[i]).Value := Int32(Ini.ReadInteger(Section,Key,0));
                vtUInt32:     TUNSNodeUInt32(NodeList.Objects[i]).Value := UInt32(Ini.ReadInteger(Section,Key,0));
                vtInt64:      TUNSNodeInt64(NodeList.Objects[i]).FromString(Ini.ReadString(Section,Key,'0'),vkActual);
                vtUInt64:     TUNSNodeUInt64(NodeList.Objects[i]).FromString(Ini.ReadString(Section,Key,'0'),vkActual);
                vtFloat32:    TUNSNodeFloat32(NodeList.Objects[i]).Value := Ini.ReadFloat(Section,Key,0.0);
                vtFloat64:    TUNSNodeFloat64(NodeList.Objects[i]).Value := Ini.ReadFloat(Section,Key,0.0);
                vtDate:       TUNSNodeDate(NodeList.Objects[i]).Value := Ini.ReadDate(Section,Key,0.0);
                vtTime:       TUNSNodeTime(NodeList.Objects[i]).Value := Ini.ReadTime(Section,Key,0.0);
                vtDateTime:   TUNSNodeDateTime(NodeList.Objects[i]).Value := Ini.ReadDateTime(Section,Key,0.0);
                vtText:       TUNSNodeText(NodeList.Objects[i]).Value := Ini.ReadString(Section,Key,'');
                vtBuffer:     TUNSNodeBuffer(NodeList.Objects[i]).FromString(Ini.ReadString(Section,Key,''),vkActual);
              else
               {vtUndefined}
                raise EUNSException.CreateFmt('Invalid node value type (%d).',
                  [Ord(TUNSNodeLeaf(NodeList.Objects[i]).ValueType)],Self,'LoadFromIniNoLock');
              end
            else ReadArrayValue(TUNSNodePrimitiveArray(NodeList.Objects[i]));
          finally
            EndChanging;
          end;
        end;  
finally
  NodeList.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.SaveToIni(Ini: TIniFileEx);
begin
ReadLock;
try
  SaveToIniNoLock(Ini);
finally
  ReadUnlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsIO.SaveToIni(Ini: TIniFile);
begin
ReadLock;
try
  SaveToIniNoLock(Ini);
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettingsIO.LoadFromIni(Ini: TIniFileEx);
begin
WriteLock;
try
  LoadFromIniNoLock(Ini);
finally
  WriteUnlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TUniSettingsIO.LoadFromIni(Ini: TIniFile);
begin
WriteLock;
try
  LoadFromIniNoLock(Ini);
finally
  WriteUnlock;
end;
end;


end.
