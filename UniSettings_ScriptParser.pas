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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

#property property_name new_property_value  
*)
unit UniSettings_ScriptParser;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, ListSorters, CountedDynArrays, CountedDynArrayString,
  UniSettings_Common, UniSettings_NodeLeaf, UniSettings_ScriptCommon,
  UniSettings_ScriptLexer;

type
  TUNSParserAddValueEvent = Function(const ValueName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean of object;

  TUNSParserValue = record
    Name:       String;
    ValueType:  TUNSValueType;
    DefValStrs: TStringCountedDynArray;
  end;

  TUNSParserPrefixes = array[0..9] of String;

  TUNSParserStruct = record
    Name:       String;
    Arr:        array of TUNSParserValue;
    Count:      Integer;
    Data:       PtrInt;
  end;

  TCDABaseType = TUNSParserValue;
  TCDAArrayType = TUNSParserStruct;

{$DEFINE CDA_Interface}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Interface}

type
  TUNSParserStructs = record
    Arr:    array of TUNSParserStruct;
    Count:  Integer;
  end;

  TUNSParserState = (psReset,psCommandAdd,psCommandPrefix,psCommandStruct,
                     psPendingStruct,psPendingDefValsAdd,psPendingDefValsStruct,
                     psPendingDefValsAddExpand,psPendingDefValsStructExpand);

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
    procedure Parse_Value; virtual;
    procedure Parse_ValueNormal; virtual;
    procedure Parse_ValueExpand; virtual;
    procedure Parse_ValueExpand_AddPendingExpansion; virtual;
    procedure Parse_PendingStruct_Close; virtual;
    procedure Parse_PendingExpansion_InitDefVals; virtual;
    procedure Parse_PendingExpansion_AssignDefVals; virtual;
    procedure Parsing_CommandAdd; virtual;
    procedure Parsing_CommandPrefix; virtual;
    procedure Parsing_CommandStruct; virtual;
    procedure Parsing_PendingStruct; virtual;
    procedure Parsing_PendingDefValsAdd; virtual;
    procedure Parsing_PendingDefValsStruct; virtual;
    procedure Parsing_PendingDefValsAddExpand; virtual;
    procedure Parsing_PendingDefValsStructExpand; virtual;
  public
    constructor Create(AddMethod: TUNSParserAddValueEvent);
    destructor Destroy; override;
    procedure Initialize; virtual;
    procedure ParseLine(const Line: String); virtual;
    Function ParseLines(const Lines: TStrings): Integer; virtual;
    Function ParseString(const Str: String): Integer; virtual;    
    Function ParseStream(Stream: TStream): Integer; virtual;
    Function ParseCompressedStream(Stream: TStream): Integer; virtual;
  end;

implementation

uses
  SysUtils,
  ExplicitStringLists, SimpleCompress,
  UniSettings_Exceptions, UniSettings_Utils, UniSettings_ScriptUtils;

procedure UNSCopyParserValue(Src: TUNSParserValue; out Dest: TUNSParserValue);
begin
Dest.Name := Src.Name;
Dest.ValueType := Src.ValueType;
Dest.DefValStrs := CDA_Copy(Src.DefValStrs);
end;

//------------------------------------------------------------------------------

procedure UNSCopyParserStruct(Src: TUNSParserStruct; out Dest: TUNSParserStruct);
var
  i:  Integer;
begin
Dest := CDA_Copy(Src);
For i := CDA_Low(Dest) to CDA_High(Dest) do
  CDA_UniqueArray(Dest.Arr[i].DefValStrs);
Dest.Name := Src.Name;
end;

//------------------------------------------------------------------------------

Function CDA_CompareFunc(const A,B: TUNSParserValue): Integer;
begin
Result := -AnsiCompareText(A.Name,B.Name);
end;

{$DEFINE CDA_Implementation}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Implementation}

//******************************************************************************

Function TUNSParser.StructIndexOf(const StructName: String): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := Low(fStructs.Arr) to Pred(fStructs.Count) do
  If AnsiSameText(fStructs.Arr[i].Name,StructName) then
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
  begin
    If Length(fStructs.Arr) <= fStructs.Count then
      SetLength(fStructs.Arr,Length(fStructs.Arr) + 8);
    Result := fStructs.Count;
    UNSCopyParserStruct(Struct,fStructs.Arr[Result]);
    Inc(fStructs.Count);
  end
else raise EUNSParsingException.CreateFmt('Structure %s redeclared.',[Struct.Name],Self,'StructAdd','');
end;

//------------------------------------------------------------------------------

procedure TUNSParser.AddNewValue(Value: TUNSParserValue);
var
  i:  Integer;
begin
{$message 'implement'}
WriteLn;
WriteLn('--- new value ---');
WriteLn;
WriteLn(Format('%-10s %s',[UNS_VALUETYPE_STRS[Value.ValueType],Value.Name]));
WriteLn;
WriteLn(Format('Default values(%d):',[CDA_Count(Value.DefValStrs)]));
WriteLn;
For i := CDA_Low(Value.DefValStrs) to CDA_High(Value.DefValStrs) do
  WriteLn('  ',CDA_GetItem(Value.DefValStrs,i));

Inc(fAddCounter);  
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_Value;
var
  PrefixIndex:  Integer;
begin
fPendingValue.Name := '';
fPendingValue.ValueType := vtUndefined;
CDA_Clear(fPendingValue.DefValStrs);
If fLexer.Count >= 2 then
  begin
    If fLexer[fLexer.LowIndex].LexemeType in [lxtIdentifier,lxtName,lxtUnparsedName] then
      begin
        // first token is alway a value name
        If fLexer[fLexer.LowIndex].LexemeText[1] = UNS_SCRIPT_PREFIXAPPENDTAG then
          begin
            // prepend prefix... get prefix index from first char after the tag
            PrefixIndex := StrToIntDef(fLexer[fLexer.LowIndex].LexemeText[2],-1);
            If PrefixIndex in UNS_SCRIPT_PREFIXRANGE then
              with fLexer[fLexer.LowIndex] do
                fPendingValue.Name := fPrefixes[PrefixIndex] + Copy(LexemeText,3,Length(LexemeText) - 2)
            else
              raise EUNSParsingException.CreateFmt('Invalid prefix index (%d).',
                [PrefixIndex],Self,'ParseValue',fLexer.Line);
          end
        else fPendingValue.Name := fLexer[fLexer.LowIndex].LexemeText;
        // second token can be either value type identifier or expand subcommand
        If UNSIsSubCommand(fLexer[fLexer.LowIndex + 1].LexemeText,sscExpand) then
          Parse_ValueExpand   // second token is an expand subcommand
        else
          Parse_ValueNormal;  // second token must be a type identifier
      end
    else raise EUNSParsingException.CreateFmt('Invalid value name (%s).',
           [fLexer[fLexer.LowIndex].LexemeText],Self,'ParseValue',fLexer.Line);
  end
else raise EUNSParsingException.CreateFmt('Token count (%d) too low.',
       [fLexer.Count],Self,'ParseValue',fLexer.Line);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_ValueNormal;
var
  i:  Integer;
begin
// second token must be a type identifier
fPendingValue.ValueType := UNSIdentifyValueType(fLexer[fLexer.LowIndex + 1].LexemeText);
If fPendingValue.ValueType <> vtUndefined then
  begin
    If fLexer.Count > 2 then
      begin
        // third token must be default value or defvalbegin subcommand
        If UNSIsSubcommand(fLexer[fLexer.LowIndex + 2].LexemeText,sscDefValsBegin) then
          begin
            // third token is a defvalbegin subcommand, value type must be an array
            If UNSIsArrayValueType(fPendingValue.ValueType) then
              case fState of
                psCommandAdd:     fState := psPendingDefValsAdd;
                psPendingStruct:  fState := psPendingDefValsStruct;
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
                CDA_Add(fPendingValue.DefValStrs,fLexer[fLexer.LowIndex + i].LexemeText)
            else
              // single default value
              CDA_Add(fPendingValue.DefValStrs,fLexer[fLexer.LowIndex + 2].LexemeText);
          end;
      end;
  end
else raise EUNSParsingException.CreateFmt('Invalid value type (%d).',
       [Ord(fPendingValue.ValueType)],Self,'ParseValue_Normal',fLexer.Line);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_ValueExpand;
var
  StructIndex:  Integer;
  i:            Integer;
  DefValsIdx:   Integer;
begin
// second token is an expand subcommand
If fLexer.Count >= 3 then
  begin
    If fLexer[fLexer.LowIndex + 2].LexemeType = lxtIdentifier then
      begin
        StructIndex := StructIndexOf(fLexer[fLexer.LowIndex + 2].LexemeText);
        If StructIndex >= 0 then
          begin
            UNSCopyParserStruct(fStructs.Arr[StructIndex],fPendingExpansion);
            fPendingExpansion.Name := fPendingValue.Name;
            // expand names
            For i := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
              fPendingExpansion.Arr[i].Name := fPendingExpansion.Name + fPendingExpansion.Arr[i].Name;
            // load default values when present or add the expansion
            If fLexer.Count >= 4 then
              begin
                Parse_PendingExpansion_InitDefVals;
                // third token must be default value or defvalbegin subcommand
                If UNSIsSubCommand(fLexer[fLexer.LowIndex + 3].LexemeText,sscDefValsBegin) then
                  begin
                    // multiline default values
                    case fState of
                      psCommandAdd:     fState := psPendingDefValsAddExpand;
                      psPendingStruct:  fState := psPendingDefValsStructExpand;
                    else
                      raise EUNSParsingException.CreateFmt('Invalid parser state (%d).',
                        [Ord(fState)],Self,'Parse_ValueExpand',fLexer.Line);
                    end;
                  end
                else
                  begin
                    // inline default values
                    DefValsIdx := CDA_Low(fPendingDefVals);
                    For i := (fLexer.LowIndex + 3) to fLexer.HighIndex do
                      If not UNSIsSubCommand(fLexer[i].LexemeText,sscOriginal) then
                        begin
                          If CDA_CheckIndex(fPendingDefVals,DefValsIdx) then
                            begin
                              CDA_SetItem(fPendingDefVals,DefValsIdx,fLexer[i].LexemeText);
                              Inc(DefValsIdx);
                            end
                          else Break{For i};
                        end;
                    Parse_PendingExpansion_AssignDefVals;
                    Parse_ValueExpand_AddPendingExpansion;
                  end;
              end
            else Parse_ValueExpand_AddPendingExpansion;  // add the expansion
          end
        else raise EUNSParsingException.CreateFmt('Undefined structure (%s).',
               [fLexer[fLexer.LowIndex + 2].LexemeText],Self,'Parse_ValueExpand',fLexer.Line);
      end
    else raise EUNSParsingException.CreateFmt('Invalid structure name (%s).',
           [fLexer[fLexer.LowIndex + 2].LexemeText],Self,'Parse_ValueExpand',fLexer.Line);
  end
else raise EUNSParsingException.CreateFmt('Token count (%d) too low.',
       [fLexer.Count],Self,'Parse_ValueExpand',fLexer.Line);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_ValueExpand_AddPendingExpansion;
var
  i:          Integer;
  TempValue:  TUNSParserValue;
begin
case fState of
  psCommandAdd:
    For i := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
      AddNewValue(CDA_GetItem(fPendingExpansion,i));
  psPendingStruct:
    For i := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
      begin
        UNSCopyParserValue(CDA_GetItem(fPendingExpansion,i),TempValue);
        CDA_Add(fPendingStruct,TempValue);
      end;
else
  raise EUNSParsingException.CreateFmt('Invalid parser state (%d) for expansion.',
    [Ord(fState)],Self,'Parse_ValueExpand_AddExpansion',fLexer.Line);
end;
fState := psReset;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_PendingStruct_Close;
begin
If fState = psPendingStruct then
  begin
    StructAdd(fPendingStruct);
    fState := psCommandAdd;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_PendingExpansion_InitDefVals;
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

procedure TUNSParser.Parse_PendingExpansion_AssignDefVals;
var
  ValIdx,ValItemIdx:  Integer;
  PendingDefValsIdx:  Integer;
begin
PendingDefValsIdx := CDA_Low(fPendingDefVals);
For ValIdx := CDA_Low(fPendingExpansion) to CDA_High(fPendingExpansion) do
  For ValItemIdx := CDA_Low(fPendingExpansion.Arr[ValIdx].DefValStrs) to
    CDA_High(fPendingExpansion.Arr[ValIdx].DefValStrs) do
    begin
      If PendingDefValsIdx <= CDA_High(fPendingDefVals) then
        begin
          CDA_SetItem(fPendingExpansion.Arr[ValIdx].DefValStrs,ValItemIdx,
            CDA_GetItem(fPendingDefVals,PendingDefValsIdx));
          Inc(PendingDefValsIdx);
        end
      else Exit;
    end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_CommandAdd;
begin
Parse_Value;
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
    PrefixIndex := StrToIntDef(fLexer[fLexer.LowIndex].LexemeText,-1);
    If (PrefixIndex in UNS_SCRIPT_PREFIXRANGE) then
      begin
        If fLexer[fLexer.LowIndex + 1].LexemeType in [lxtIdentifier,lxtName] then
          fPrefixes[PrefixIndex] := fLexer[fLexer.LowIndex + 1].LexemeText
        else
          raise EUNSParsingException.CreateFmt('Invalid prefix (%s)',
            [fLexer[fLexer.LowIndex + 1].LexemeText],Self,'Parsing_CommandPrefix',fLexer.Line);
      end
    else raise EUNSParsingException.CreateFmt('Invalid prefix index (%s)',
           [fLexer[fLexer.LowIndex].LexemeText],Self,'Parsing_CommandPrefix',fLexer.Line);
  end
else raise EUNSParsingException.CreateFmt('Token count (%d) too low.',
       [fLexer.Count],Self,'Parsing_CommandPrefix',fLexer.Line);
fState := psCommandAdd;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_CommandStruct;
begin
If fLexer[fLexer.LowIndex].LexemeType = lxtIdentifier then
  begin
    fPendingStruct.Name := fLexer[fLexer.LowIndex].LexemeText;
    fPendingStruct.Count := 0;
    fState := psPendingStruct;
  end
else raise EUNSParsingException.CreateFmt('Invalid structure name (%s)',
       [fLexer[fLexer.LowIndex].LexemeText],Self,'Parsing_CommandStruct',fLexer.Line);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingStruct;
var
  TempValue:  TUNSParserValue;
begin
Parse_Value;
If fState = psPendingStruct then
  begin
    UNSCopyParserValue(fPendingValue,TempValue);
    CDA_Add(fPendingStruct,TempValue);
  end
else If fState = psReset then
  fState := psPendingStruct;  
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingDefValsAdd;
begin
If UNSIsSubCommand(fLexer[fLexer.LowIndex].LexemeText,sscDefValsEnd) then
  begin
    AddNewValue(fPendingValue);
    fState := psCommandAdd;
  end
else CDA_Add(fPendingValue.DefValStrs,fLexer[fLexer.LowIndex].LexemeText);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingDefValsStruct;
var
  TempValue:  TUNSParserValue;
begin
If UNSIsSubCommand(fLexer[fLexer.LowIndex].LexemeText,sscDefValsEnd) then
  begin
    UNSCopyParserValue(fPendingValue,TempValue);
    CDA_Add(fPendingStruct,TempValue);
    fState := psPendingStruct;
  end
else CDA_Add(fPendingValue.DefValStrs,fLexer[fLexer.LowIndex].LexemeText);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingDefValsAddExpand;
begin
If UNSIsSubCommand(fLexer[fLexer.LowIndex].LexemeText,sscDefValsEnd) then
  begin
    Parse_PendingExpansion_AssignDefVals;
    fState := psCommandAdd;    
    Parse_ValueExpand_AddPendingExpansion;
  end
else If not UNSIsSubCommand(fLexer[fLexer.LowIndex].LexemeText,sscOriginal) then
  begin
    If CDA_CheckIndex(fPendingDefVals,CDA_GetData(fPendingDefVals)) then
      begin
        CDA_SetItem(fPendingDefVals,CDA_GetData(fPendingDefVals),fLexer[fLexer.LowIndex].LexemeText);
        CDA_SetData(fPendingDefVals,CDA_GetData(fPendingDefVals) + 1);
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingDefValsStructExpand;
begin
If UNSIsSubCommand(fLexer[fLexer.LowIndex].LexemeText,sscDefValsEnd) then
  begin
    Parse_PendingExpansion_AssignDefVals;
    fState := psPendingStruct;    
    Parse_ValueExpand_AddPendingExpansion;
  end
else If not UNSIsSubCommand(fLexer[fLexer.LowIndex].LexemeText,sscOriginal) then
  begin
    If CDA_CheckIndex(fPendingDefVals,CDA_GetData(fPendingDefVals)) then
      begin
        CDA_SetItem(fPendingDefVals,CDA_GetData(fPendingDefVals),fLexer[fLexer.LowIndex].LexemeText);
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
fAddMethod := AddMethod;
Initialize;
fAddCounter := 0;
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
SetLength(fStructs.Arr,0);
fStructs.Count := 0;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.ParseLine(const Line: String);
begin
fLexer.ProcessLine(Line);
If fLexer.Count > 0 then
  begin
    If fLexer[fLexer.LowIndex].LexemeType = lxtCommand then
      begin
        Parse_PendingStruct_Close;
        with fLexer[fLexer.LowIndex] do
          case UNSIndetifyCommand(Copy(LexemeText,2,Length(LexemeText) - 1)) of
            scAdd:    fState := psCommandAdd;
            scPrefix: fState := psCommandPrefix;
            scStruct: fState := psCommandStruct;
          end;
        fLexer.RemoveFirstLexeme;
      end;
    case fState of
      psReset:                      fState := psCommandAdd;
      psCommandAdd:                 If fLexer.Count > 0 then
                                      Parsing_CommandAdd;
      psCommandPrefix:              Parsing_CommandPrefix;
      psCommandStruct:              Parsing_CommandStruct;
      psPendingStruct:              Parsing_PendingStruct;
      psPendingDefValsAdd:          Parsing_PendingDefValsAdd;
      psPendingDefValsStruct:       Parsing_PendingDefValsStruct;
      psPendingDefValsAddExpand:    Parsing_PendingDefValsAddExpand;
      psPendingDefValsStructExpand: Parsing_PendingDefValsStructExpand;
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
  Parse_PendingStruct_Close;  // in case script ends with a structure declaration
finally
  Result := fAddCounter - OldCntr;
end;
end;

//------------------------------------------------------------------------------

Function TUNSParser.ParseString(const Str: String): Integer;
var
  Lines:  TStringList;
begin
Lines := TStringList.Create;
try
  Lines.Text := Str;
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
    Result := ParseStream(MemStream)
  else
    Result := 0;
finally
  MemStream.Free;
end;
end;

end.
