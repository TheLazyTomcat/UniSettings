(*
#add

[#add] [@N[.]]value_name value_type [value_defval]

[#add] [@N[.]]value_name value_arraytype [value_defval_0 value_defval_1 ... value_defval_n]

[#add] [@N[.]]value_name value_arraytype &defvalbegin
  value_defval_0
  value_defval_1
  ...
  value_defval_n
&defvalend

[#add] [@N[.]]value_name[.] &expand struct_name [field_0_defval field_1_defval ... field_n_defval]

[#add] [@N[.]]value_name[.] &expand struct_name &defvalbegin
  field_0_defval
  field_1_defval
  ...
  field_n_defval
&defvalend

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

#prefix  prefix_index  prefix_string

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

#struct struct_name
  field_0
  field_1
  ...
  field_n
*)
unit UniSettings_ScriptParser;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, CountedDynArrays, CountedDynArrayString,
  UniSettings_Common, UniSettings_NodeLeaf, UniSettings_ScriptCommon,
  UniSettings_ScriptLexer, UniSettings_ScriptParserStruct;

type
  TUNSParserAddValueEvent = Function(const ValueName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean of object;

  TUNSParserPrefixes = array[0..9] of String;

  TUNSParserStructs = record
    Arr:    array of TUNSParserStruct;
    SigA:   UInt32;
    Count:  Integer;
    Data:   PtrInt;
    SigB:   UInt32;
  end;
  PUNSParserStructs = ^TUNSParserStructs;

  TCDABaseType = TUNSParserStruct;
  PCDABaseType = PUNSParserStruct;

  TCDAArrayType = TUNSParserStructs;
  PCDAArrayType = PUNSParserStructs;

{$DEFINE CDA_DisableFunc_ItemUnique}

{$DEFINE CDA_Interface}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Interface}

type
  TUNSParserState = (psReset,psCommandAdd,psCommandPrefix,psCommandStruct,
                     psPendingStruct,psAddPendingDefVals,psStructPendingDefVals,
                     psAddExpandPendingDefVals,psStructExpandPendingDefVals);

  TUNSParser = class(TObject)
  private
    fLexer:             TUNSLexer;
    fPrefixes:          TUNSParserPrefixes;
    fStructs:           TUNSParserStructs;
    fAddCounter:        Integer;
    fAddMethod:         TUNSParserAddValueEvent;
    // parsing variables
    fState:             TUNSParserState;
    fPendingValue:      TUNSParserValue;
    fPendingStruct:     TUNSParserStruct;
    fPendingExpansion:  TUNSParserStruct;
    fPendingDefVals:    TStringCountedDynArray;
  protected
    Function StructIndexOf(const StructName: String): Integer; virtual;
    Function StructAdd(Struct: TUNSParserStruct): Integer; virtual;
    procedure AddNewValue(Value: TUNSParserValue); virtual;
    procedure Parsing_Value; virtual;
    procedure Parsing_Value_Normal; virtual;
    procedure Parsing_Value_Expand; virtual;
    procedure Parsing_Value_Expand_InitPendingDefVals; virtual;
    procedure Parsing_Value_Expand_AssignPendingDefVals; virtual;
    procedure Parsing_Value_Expand_AddPendingExpansion(ResetState: Boolean); virtual;
    procedure Parsing_CommandAdd; virtual;
    procedure Parsing_CommandPrefix; virtual;
    procedure Parsing_CommandStruct; virtual;
    procedure Parsing_PendingStruct; virtual;
    procedure Parsing_PendingStruct_Close; virtual;
    procedure Parsing_AddPendingDefVals; virtual;
    procedure Parsing_StructPendingDefVals; virtual;
    procedure Parsing_AddExpandPendingDefVals; virtual;
    procedure Parsing_StructExpandPendingDefVals; virtual;
  public
    constructor Create(AddMethod: TUNSParserAddValueEvent);
    destructor Destroy; override;
    procedure Initialize; virtual;
    procedure ParseLine(const Line: String); virtual;
    Function ParseLines(const Lines: TStrings): Integer; virtual;
    Function ParseText(const Text: String): Integer; virtual;
    Function ParseStream(Stream: TStream): Integer; virtual;
    Function ParseCompressedStream(Stream: TStream): Integer; virtual;
  end;

implementation

uses
  SysUtils,
  ExplicitStringLists, SimpleCompress, ListSorters,
  UniSettings_Exceptions, UniSettings_Utils, UniSettings_NodePrimitiveArray,
  UniSettings_ScriptUtils;

Function CDA_CompareFunc(const A,B: TUNSParserStruct): Integer; {$IFDEF CanInline} inline; {$ENDIF}
begin
Result := -AnsiCompareText(A.Name,B.Name);
end;

//------------------------------------------------------------------------------

procedure CDA_ItemUnique(var Item: TCDABaseType); {$IFDEF CanInline} inline; {$ENDIF}
begin
CDA_UniqueArray(Item);
end;

//------------------------------------------------------------------------------

{$DEFINE CDA_Implementation}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Implementation}


//******************************************************************************

Function UNSCopyParserValue(const Src: TUNSParserValue): TUNSParserValue;
begin
Result.Name := Src.Name;
Result.ValueType := Src.ValueType;
Result.DefValStrs := CDA_Copy(Src.DefValStrs);
end;

//******************************************************************************

Function TUNSParser.StructIndexOf(const StructName: String): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := CDA_Low(fStructs) to CDA_High(fStructs) do
  If AnsiSameText(CDA_GetItem(fStructs,i).Name,StructName) then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

Function TUNSParser.StructAdd(Struct: TUNSParserStruct): Integer;
begin
Result := StructIndexOf(Struct.Name);
If Result < 0 then
  Result := CDA_Add(fStructs,CDA_Copy(Struct))
else
  raise EUNSParsingException.CreateFmt('Structure %s redeclared.',[Struct.Name],Self,'StructAdd','');
end;

//------------------------------------------------------------------------------

procedure TUNSParser.AddNewValue(Value: TUNSParserValue);
var
  Node: TUNSNodeLeaf;
  i:    Integer;
begin
If Assigned(fAddMethod) then
  begin
    If fAddMethod(Value.Name,Value.ValueType,Node) then
      begin
        If CDA_Count(Value.DefValStrs) > 0 then
          begin
            If UNSIsArrayValueType(Value.ValueType) then
              begin
                // first add as many items as there is default values...
                TUNSNodePrimitiveArray(Node).Clear(vkActual);
                TUNSNodePrimitiveArray(Node).Clear(vkSaved);
                TUNSNodePrimitiveArray(Node).PrepareEmptyItems(CDA_Count(Value.DefValStrs),vkDefault);
                // ...then resolve the values from strings
                For i := CDA_Low(Value.DefValStrs) to CDA_High(Value.DefValStrs) do
                  TUNSNodePrimitiveArray(Node).FromString(i,CDA_GetItem(Value.DefValStrs,i),vkDefault);
              end
            else Node.FromString(CDA_First(Value.DefValStrs),vkDefault);
            Node.ActualFromDefault;
          end;
      end
    else raise EUNSException.CreateFmt('Unable to add value %s of type %s.',
           [Value.Name,UNS_VALUETYPE_STRS[Value.ValueType]],Self,'AddNewValue');
  end;
Inc(fAddCounter);  
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_Value;
var
  PrefixIndex:  Integer;
begin
fPendingValue.Name := '';
fPendingValue.ValueType := vtUndefined;
CDA_Clear(fPendingValue.DefValStrs);
If fLexer.Count >= 2 then
  begin
    If fLexer[fLexer.LowIndex].TokenType in [ttIdentifier,ttName,ttUnparsedName] then
      begin
        // first token is alway a value name
        If fLexer[fLexer.LowIndex].Lexeme[1] = UNS_SCRIPT_PREFIXAPPENDTAG then
          begin
            // prepend prefix... get prefix index from first char after the tag
            PrefixIndex := StrToIntDef(fLexer[fLexer.LowIndex].Lexeme[2],-1);
            If PrefixIndex in UNS_SCRIPT_PREFIXRANGE then
              with fLexer[fLexer.LowIndex] do
                fPendingValue.Name := fPrefixes[PrefixIndex] + Copy(Lexeme,3,Length(Lexeme) - 2)
            else
              raise EUNSParsingException.CreateFmt('Invalid prefix index (%d).',
                [PrefixIndex],Self,'ParseValue',fLexer.Line);
          end
        else fPendingValue.Name := fLexer[fLexer.LowIndex].Lexeme;
        // second token can be either value type identifier or expand subcommand
        If UNSIsSubCommand(fLexer[fLexer.LowIndex + 1].Lexeme,sscExpand) then
          Parsing_Value_Expand  // second token is an expand subcommand
        else
          Parsing_Value_Normal; // second token must be a type identifier
      end
    else raise EUNSParsingException.CreateFmt('Invalid value name (%s).',
           [fLexer[fLexer.LowIndex].Lexeme],Self,'ParseValue',fLexer.Line);
  end
else raise EUNSParsingException.CreateFmt('Token count (%d) too low.',
       [fLexer.Count],Self,'ParseValue',fLexer.Line);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_Value_Normal;
var
  i:  Integer;
begin
// second token must be a type identifier
fPendingValue.ValueType := UNSIdentifyValueType(fLexer[fLexer.LowIndex + 1].Lexeme);
If fPendingValue.ValueType <> vtUndefined then
  begin
    If fLexer.Count > 2 then
      begin
        // third token must be default value or defvalbegin subcommand
        If UNSIsSubcommand(fLexer[fLexer.LowIndex + 2].Lexeme,sscDefValsBegin) then
          begin
            // third token is a defvalbegin subcommand, value type must be an array
            If UNSIsArrayValueType(fPendingValue.ValueType) then
              case fState of
                psCommandAdd:     fState := psAddPendingDefVals;
                psPendingStruct:  fState := psStructPendingDefVals;
              else
                raise EUNSParsingException.CreateFmt('Invalid parser state (%d).',
                  [Ord(fState)],Self,'ParseValue_Normal',fLexer.Line);
              end
            else raise EUNSParsingException.CreateFmt('Invalid value type (%d) for DefValsBegin subcommand.',
                   [Ord(fPendingValue.ValueType)],Self,'ParseValue_Normal',fLexer.Line);
          end
        else
          begin
            // third token is a default value
            If UNSIsArrayValueType(fPendingValue.ValueType) then
              // inline array of default values
              For i := (fLexer.LowIndex + 2) to Pred(fLexer.Count) do
                CDA_Add(fPendingValue.DefValStrs,fLexer[fLexer.LowIndex + i].Lexeme)
            else
              // single default value
              CDA_Add(fPendingValue.DefValStrs,fLexer[fLexer.LowIndex + 2].Lexeme);
          end;
      end;
  end
else raise EUNSParsingException.CreateFmt('Invalid value type (%d).',
       [Ord(fPendingValue.ValueType)],Self,'ParseValue_Normal',fLexer.Line);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_Value_Expand;
var
  StructIndex:  Integer;
  i:            Integer;
  DefValsIdx:   Integer;
begin
// second token is an expand subcommand
If fLexer.Count >= 3 then
  begin
    If fLexer[fLexer.LowIndex + 2].TokenType = ttIdentifier then
      begin
        StructIndex := StructIndexOf(fLexer[fLexer.LowIndex + 2].Lexeme);
        If StructIndex >= 0 then
          begin
            fPendingExpansion := CDA_Copy(CDA_GetItem(fStructs,StructIndex));
            fPendingExpansion.Name := fPendingValue.Name;
            // expand names
            For i := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
              CDA_GetItemPtr(fPendingExpansion,i)^.Name := fPendingExpansion.Name + CDA_GetItem(fPendingExpansion,i).Name;
            // load default values when present or add the expansion
            If fLexer.Count >= 4 then
              begin
                Parsing_Value_Expand_InitPendingDefVals;
                // third token must be default value or defvalbegin subcommand
                If UNSIsSubCommand(fLexer[fLexer.LowIndex + 3].Lexeme,sscDefValsBegin) then
                  begin
                    // multiline default values
                    case fState of
                      psCommandAdd:     fState := psAddExpandPendingDefVals;
                      psPendingStruct:  fState := psStructExpandPendingDefVals;
                    else
                      raise EUNSParsingException.CreateFmt('Invalid parser state (%d).',
                        [Ord(fState)],Self,'Parsing_ValueExpand',fLexer.Line);
                    end;
                  end
                else
                  begin
                    // inline default values
                    DefValsIdx := CDA_Low(fPendingDefVals);
                    For i := (fLexer.LowIndex + 3) to fLexer.HighIndex do
                      If not UNSIsSubCommand(fLexer[i].Lexeme,sscOriginal) then
                        begin
                          If CDA_CheckIndex(fPendingDefVals,DefValsIdx) then
                            begin
                              CDA_SetItem(fPendingDefVals,DefValsIdx,fLexer[i].Lexeme);
                              Inc(DefValsIdx);
                            end
                          else Break{For i};
                        end
                      else Inc(DefValsIdx);
                    Parsing_Value_Expand_AssignPendingDefVals;
                    Parsing_Value_Expand_AddPendingExpansion(True);
                  end;
              end
            else  Parsing_Value_Expand_AddPendingExpansion(True); // add the expansion
          end
        else raise EUNSParsingException.CreateFmt('Undefined structure (%s).',
               [fLexer[fLexer.LowIndex + 2].Lexeme],Self,'Parsing_ValueExpand',fLexer.Line);
      end
    else raise EUNSParsingException.CreateFmt('Invalid structure name (%s).',
           [fLexer[fLexer.LowIndex + 2].Lexeme],Self,'Parsing_ValueExpand',fLexer.Line);
  end
else raise EUNSParsingException.CreateFmt('Token count (%d) too low.',
       [fLexer.Count],Self,'Parsing_ValueExpand',fLexer.Line);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_Value_Expand_InitPendingDefVals;
var
  ValIdx,ValItemIdx:  Integer;
begin
CDA_Clear(fPendingDefVals);
For ValIdx := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
  with CDA_GetItem(fPendingExpansion,ValIdx) do
    For ValItemIdx := CDA_Low(DefValStrs) to CDA_High(DefValStrs) do
      CDA_Add(fPendingDefVals,CDA_GetItem(DefValStrs,ValItemIdx));
CDA_SetData(fPendingDefVals,CDA_Low(fPendingDefVals));
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_Value_Expand_AssignPendingDefVals;
var
  ValIdx,ValItemIdx:  Integer;
  PendingDefValsIdx:  Integer;
begin
PendingDefValsIdx := CDA_Low(fPendingDefVals);
For ValIdx := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
  For ValItemIdx := CDA_Low(CDA_GetItemPtr(fPendingExpansion,ValIdx)^.DefValStrs) to
                   CDA_High(CDA_GetItemPtr(fPendingExpansion,ValIdx)^.DefValStrs) do
    begin
      If PendingDefValsIdx <= CDA_High(fPendingDefVals) then
        begin
          CDA_SetItem(CDA_GetItemPtr(fPendingExpansion,ValIdx)^.DefValStrs,ValItemIdx,
            CDA_GetItem(fPendingDefVals,PendingDefValsIdx));
          Inc(PendingDefValsIdx);
        end
      else Exit;
    end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_Value_Expand_AddPendingExpansion(ResetState: Boolean);
var
  i:  Integer;
begin
case fState of
  psCommandAdd:
    For i := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
      AddNewValue(CDA_GetItem(fPendingExpansion,i));
  psPendingStruct:
    For i := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
      CDA_Add(fPendingStruct,UNSCopyParserValue(CDA_GetItem(fPendingExpansion,i)));
else
  raise EUNSParsingException.CreateFmt('Invalid parser state (%d) for expansion.',
    [Ord(fState)],Self,'Parsing_ValueExpand_AddExpansion',fLexer.Line);
end;
If ResetState then
  fState := psReset;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_CommandAdd;
begin
Parsing_Value;
If fState = psCommandAdd then
  AddNewValue(fPendingValue)
else If fState = psReset then
  fState := psCommandAdd;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_CommandPrefix;
var
  PrefixIndex:  Integer;
begin
If fLexer.Count >= 2 then
  begin
    PrefixIndex := StrToIntDef(fLexer[fLexer.LowIndex].Lexeme,-1);
    If (PrefixIndex in UNS_SCRIPT_PREFIXRANGE) then
      begin
        If fLexer[fLexer.LowIndex + 1].TokenType in [ttIdentifier,ttName] then
          fPrefixes[PrefixIndex] := fLexer[fLexer.LowIndex + 1].Lexeme
        else
          raise EUNSParsingException.CreateFmt('Invalid prefix (%s)',
            [fLexer[fLexer.LowIndex + 1].Lexeme],Self,'Parsing_CommandPrefix',fLexer.Line);
      end
    else raise EUNSParsingException.CreateFmt('Invalid prefix index (%s)',
           [fLexer[fLexer.LowIndex].Lexeme],Self,'Parsing_CommandPrefix',fLexer.Line);
  end
else raise EUNSParsingException.CreateFmt('Token count (%d) too low.',
       [fLexer.Count],Self,'Parsing_CommandPrefix',fLexer.Line);
fState := psCommandAdd;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_CommandStruct;
begin
If fLexer.Count > 0 then
  begin
    If fLexer[fLexer.LowIndex].TokenType = ttIdentifier then
      begin
        fPendingStruct.Name := fLexer[fLexer.LowIndex].Lexeme;
        fPendingStruct.Count := 0;
        fState := psPendingStruct;
      end
    else raise EUNSParsingException.CreateFmt('Invalid structure name (%s)',
           [fLexer[fLexer.LowIndex].Lexeme],Self,'Parsing_CommandStruct',fLexer.Line);
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingStruct;
begin
Parsing_Value;
If fState = psPendingStruct then
  CDA_Add(fPendingStruct,UNSCopyParserValue(fPendingValue,))
else If fState = psReset then
  fState := psPendingStruct;  
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingStruct_Close;
begin
If fState = psPendingStruct then
  begin
    StructAdd(fPendingStruct);
    fState := psCommandAdd;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_AddPendingDefVals;
begin
If fLexer.Count > 0 then
  begin
    If UNSIsSubCommand(fLexer[fLexer.LowIndex].Lexeme,sscDefValsEnd) then
      begin
        AddNewValue(fPendingValue);
        fState := psCommandAdd;
      end
    else CDA_Add(fPendingValue.DefValStrs,fLexer[fLexer.LowIndex].Lexeme);
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_StructPendingDefVals;
begin
If fLexer.Count > 0 then
  begin
    If UNSIsSubCommand(fLexer[fLexer.LowIndex].Lexeme,sscDefValsEnd) then
      begin
        CDA_Add(fPendingStruct,UNSCopyParserValue(fPendingValue));
        fState := psPendingStruct;
      end
    else CDA_Add(fPendingValue.DefValStrs,fLexer[fLexer.LowIndex].Lexeme);
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_AddExpandPendingDefVals;
begin
If fLexer.Count > 0 then
  begin
    If UNSIsSubCommand(fLexer[fLexer.LowIndex].Lexeme,sscDefValsEnd) then
      begin
        Parsing_Value_Expand_AssignPendingDefVals;
        fState := psCommandAdd;
        Parsing_Value_Expand_AddPendingExpansion(False);
      end
    else
      begin
        If not UNSIsSubCommand(fLexer[fLexer.LowIndex].Lexeme,sscOriginal) and
          CDA_CheckIndex(fPendingDefVals,CDA_GetData(fPendingDefVals)) then
            CDA_SetItem(fPendingDefVals,CDA_GetData(fPendingDefVals),fLexer[fLexer.LowIndex].Lexeme);
        CDA_SetData(fPendingDefVals,CDA_GetData(fPendingDefVals) + 1);
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_StructExpandPendingDefVals;
begin
If fLexer.Count > 0 then
  begin
    If UNSIsSubCommand(fLexer[fLexer.LowIndex].Lexeme,sscDefValsEnd) then
      begin
        Parsing_Value_Expand_AssignPendingDefVals;
        fState := psPendingStruct;
        Parsing_Value_Expand_AddPendingExpansion(False);
      end
    else
      begin
        If not UNSIsSubCommand(fLexer[fLexer.LowIndex].Lexeme,sscOriginal) and
          CDA_CheckIndex(fPendingDefVals,CDA_GetData(fPendingDefVals)) then
            CDA_SetItem(fPendingDefVals,CDA_GetData(fPendingDefVals),fLexer[fLexer.LowIndex].Lexeme);
        CDA_SetData(fPendingDefVals,CDA_GetData(fPendingDefVals) + 1);
      end;
  end;
end;

//==============================================================================

constructor TUNSParser.Create(AddMethod: TUNSParserAddValueEvent);
begin
inherited Create;
fLexer := TUNSLexer.Create;
fLexer.RemoveComments := True;
CDA_Init(fStructs);
fAddCounter := 0;
fAddMethod := AddMethod;
Initialize;
CDA_Init(fPendingValue.DefValStrs);
CDA_Init(fPendingStruct);
CDA_Init(fPendingExpansion);
CDA_Init(fPendingDefVals);
end;

//------------------------------------------------------------------------------

destructor TUNSParser.Destroy;
begin
fLexer.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Initialize;
var
  i:  Integer;
begin
For i := Low(fPrefixes) to High(fPrefixes) do
  fPrefixes[i] := '';
CDA_Clear(fStructs);
fState := psCommandAdd;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.ParseLine(const Line: String);
begin
fLexer.ProcessLine(Line);
If fLexer.Count > 0 then
  begin
    If fLexer[fLexer.LowIndex].TokenType = ttCommand then
      begin
        Parsing_PendingStruct_Close;
        with fLexer[fLexer.LowIndex] do
          case UNSIndetifyCommand(Copy(Lexeme,2,Length(Lexeme) - 1)) of
            scAdd:    fState := psCommandAdd;
            scPrefix: fState := psCommandPrefix;
            scStruct: fState := psCommandStruct;
          end;
        fLexer.RemoveFirstToken;
      end;
    case fState of
      psReset:                      fState := psCommandAdd;
      psCommandAdd:                 If fLexer.Count > 0 then
                                      Parsing_CommandAdd;
      psCommandPrefix:              Parsing_CommandPrefix;
      psCommandStruct:              Parsing_CommandStruct;
      psPendingStruct:              Parsing_PendingStruct;
      psAddPendingDefVals:          Parsing_AddPendingDefVals;
      psStructPendingDefVals:       Parsing_StructPendingDefVals;
      psAddExpandPendingDefVals:    Parsing_AddExpandPendingDefVals;
      psStructExpandPendingDefVals: Parsing_StructExpandPendingDefVals;
    end;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSParser.ParseLines(const Lines: TStrings): Integer;
var
  OldCntr:  Integer;
  i:        Integer;
begin
OldCntr := fAddCounter;
try
  fState := psCommandAdd;
  For i := 0 to Pred(Lines.Count) do
    ParseLine(Lines[i]);
  Parsing_PendingStruct_Close;  // in case script ends with a structure declaration
finally
  Result := fAddCounter - OldCntr;
end;
end;

//------------------------------------------------------------------------------

Function TUNSParser.ParseText(const Text: String): Integer;
var
  Lines:  TStringList;
begin
Lines := TStringList.Create;
try
  Lines.Text := Text;
  Result := ParseLines(Lines);
finally
  Lines.Free;
end;
end;

//------------------------------------------------------------------------------

Function TUNSParser.ParseStream(Stream: TStream): Integer;
var
  UTF8Lines:  TUTF8StringList;
  Lines:      TStringList;
begin
UTF8Lines := TUTF8StringList.Create;
try
  UTF8Lines.LoadFromStream(Stream);
  Lines := TStringList.Create;
  try
    Lines.Assign(UTF8Lines);
    Result := ParseLines(Lines);
  finally
    Lines.Free;
  end;
finally
  UTF8Lines.Free;
end;
end;

//------------------------------------------------------------------------------

Function TUNSParser.ParseCompressedStream(Stream: TStream): Integer;
var
  MemStream:  TMemoryStream;
begin
MemStream := TMemoryStream.Create;
try
  If ZDecompressStream(Stream,MemStream) then
    begin
      MemStream.Seek(0,soBeginning);
      Result := ParseStream(MemStream);
    end
  else Result := 0;
finally
  MemStream.Free;
end;
end;

end.
