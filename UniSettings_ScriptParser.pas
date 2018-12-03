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
  UniSettings_Common, UniSettings_NodeLeaf, UniSettings_ScriptCommon,
  UniSettings_ScriptLexer;

type
  TUNSParserAddValueEvent = Function(const ValueName: String; ValueType: TUNSValueType; out Node: TUNSNodeLeaf): Boolean of object;

  TUNSParserValue = record
    Name:       String;
    ValueType:  TUNSValueType;
    DefValStrs: array of String;
  end;

  TUNSParserPrefixes = array[0..9] of String;

  TUNSParserStruct = record
    Name:       String;
    Arr:        array of TUNSParserValue;
    Count:      Integer;
    Reserved1:  Integer;
    Reserved2:  Integer;
  end;

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
    fPendingDefVals:    array of String;
  protected
    Function StructIndexOf(const StructName: String): Integer; virtual;
    Function StructAdd(Struct: TUNSParserStruct): Integer; virtual;
    procedure AddNewValue(Value: TUNSParserValue); virtual;
    procedure Parse_Value; virtual;
    procedure Parse_ValueNormal; virtual;
    procedure Parse_ValueExpand; virtual;
    procedure Parse_ValueExpand_AddPendingExpansion; virtual;
    procedure Parse_PendingStructClose; virtual;
    procedure Parsing_CommandAdd; virtual;
    procedure Parsing_CommandPrefix; virtual;
    procedure Parsing_CommandStruct; virtual;
    procedure Parsing_PendingStruct; virtual;
    procedure Parsing_PendingDefValsAdd; virtual;
    procedure Parsing_PendingDefValsStruct; virtual;
  public
    constructor Create(AddMethod: TUNSParserAddValueEvent);
    destructor Destroy; override;
    procedure ReInitialize; virtual;
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
Dest.DefValStrs := Copy(Src.DefValStrs);
end;

//------------------------------------------------------------------------------

procedure UNSCopyParserStruct(Src: TUNSParserStruct; out Dest: TUNSParserStruct);
var
  i:  Integer;
begin
Dest.Name := Src.Name;
SetLength(Dest.Arr,Src.Count);
For i := Low(Src.Arr) to Pred(Src.Count) do
  UNSCopyParserValue(Src.Arr[i],Dest.Arr[i]);
Dest.Count := Src.Count;
end;

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
WriteLn(Format('Default values(%d):',[Length(Value.DefValStrs)]));
WriteLn;
For i := Low(Value.DefValStrs) to High(Value.DefValStrs) do
  WriteLn('  ',Value.DefValStrs[i]);

Inc(fAddCounter);  
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_Value;
var
  PrefixIndex:  Integer;
begin
fPendingValue.Name := '';
fPendingValue.ValueType := vtUndefined;
SetLength(fPendingValue.DefValStrs,0);
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
        If UNSIsSubcommand(fLexer[fLexer.LowIndex + 1].LexemeText,sscExpand) then
          Parse_ValueExpand   // second token is an expand subcommand
        else
          Parse_ValueNormal;  // second token must be a type identifier
      end
    else raise EUNSParsingException.CreateFmt('Invalid value name (%s).',
           [fLexer[fLexer.LowIndex].LexemeText],Self,'ParseValue',fLexer.Line);
  end
else raise EUNSParsingException.CreateFmt('Invalid token count (%d).',
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
              begin
                // inline array of default values
                SetLength(fPendingValue.DefValStrs,fLexer.Count - 2);
                For i := Low(fPendingValue.DefValStrs) to High(fPendingValue.DefValStrs) do
                  fPendingValue.DefValStrs[i] := fLexer[fLexer.LowIndex + 2 + i].LexemeText;
              end
            else
              begin
                // a default value
                SetLength(fPendingValue.DefValStrs,1);
                fPendingValue.DefValStrs[Low(fPendingValue.DefValStrs)] :=
                  fLexer[fLexer.LowIndex + 2].LexemeText;
              end;
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
  ValueIdx:     Integer;
  ValueItemIdx: Integer;
begin
// second token is an expand subcommand
If fLexer.Count >= 3 then
  begin
    If (fLexer[fLexer.LowIndex + 2].LexemeType = lxtIdentifier) then
      begin
        StructIndex := StructIndexOf(fLexer[fLexer.LowIndex + 2].LexemeText);
        If StructIndex >= 0 then
          begin
            UNSCopyParserStruct(fStructs.Arr[StructIndex],fPendingExpansion);
            fPendingExpansion.Name := fPendingValue.Name;
            // expand names
            For i := Low(fPendingExpansion.Arr) to Pred(fPendingExpansion.Count) do
              fPendingExpansion.Arr[i].Name := fPendingExpansion.Name + fPendingExpansion.Arr[i].Name;
            // load default values when present or add the expansion
            If fLexer.Count >= 4 then
              begin
                // third token must be default value or defvalbegin subcommand
                If UNSIsSubcommand(fLexer[fLexer.LowIndex + 3].LexemeText,sscDefValsBegin) then
                  begin
                    // multiline default values
                    case fState of
                      psCommandAdd:     fState := psPendingDefValsAddExpand;
                      psPendingStruct:  fState := psPendingDefValsStructExpand;
                    else
                      raise EUNSParsingException.CreateFmt('Invalid parser state (%d) for defaults.',
                        [Ord(fState)],Self,'Parse_ValueExpand',fLexer.Line);
                    end;
                    SetLength(fPendingDefVals,0);
                  end
                else
                  begin
                    // inline default values
                    i := 4;
                    ValueIdx := 0;
                    ValueItemIdx := 0;
                    while i <= fLexer.Count do
                      begin
                        
                        Inc(i);
                      end;
                    Parse_ValueExpand_AddPendingExpansion;
                    fState := psReset;
                  end;                
              end
            else
              begin
                // add the expansion
                Parse_ValueExpand_AddPendingExpansion;
                fState := psReset;
              end;
          end
        else raise EUNSParsingException.CreateFmt('Undefined structure (%s).',
               [fLexer[fLexer.LowIndex + 2].LexemeText],Self,'Parse_ValueExpand',fLexer.Line);
      end
    else raise EUNSParsingException.CreateFmt('Invalid struct name (%s).',
           [fLexer[fLexer.LowIndex + 2].LexemeText],Self,'Parse_ValueExpand',fLexer.Line);
  end
else raise EUNSParsingException.CreateFmt('Invalid token count (%d).',
       [fLexer.Count],Self,'Parse_ValueExpand',fLexer.Line);
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_ValueExpand_AddPendingExpansion;
var
  i:  Integer;
begin
case fState of
  psCommandAdd:
    For i := Low(fPendingExpansion.Arr) to Pred(fPendingExpansion.Count) do
    AddNewValue(fPendingExpansion.Arr[i]);
  psPendingStruct:
    begin
      If (fPendingStruct.Count + fPendingExpansion.Count) > Length(fPendingStruct.Arr) then
        SetLength(fPendingStruct.Arr,fPendingStruct.Count + fPendingExpansion.Count);
      For i := Low(fPendingExpansion.Arr) to Pred(fPendingExpansion.Count) do
        begin
          UNSCopyParserValue(fPendingExpansion.Arr[i],fPendingStruct.Arr[fPendingStruct.Count]);
          Inc(fPendingStruct.Count);
        end;
    end;
else
  raise EUNSParsingException.CreateFmt('Invalid parser state (%d) for expansion.',
    [Ord(fState)],Self,'Parse_ValueExpand_AddExpansion',fLexer.Line);
end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parse_PendingStructClose;
begin
If fState = psPendingStruct then
  begin
    StructAdd(fPendingStruct);
    fState := psCommandAdd;
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
    If (PrefixIndex in UNS_SCRIPT_PREFIXRANGE) and
       (fLexer[fLexer.LowIndex].LexemeType in [lxtUnknown,lxtIdentifier]) then
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
else raise EUNSParsingException.CreateFmt('Invalid token count (%d).',
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
begin
Parse_Value;
If fState = psPendingStruct then
  begin
    If Length(fPendingStruct.Arr) <= fPendingStruct.Count then
      SetLength(fPendingStruct.Arr,Length(fPendingStruct.Arr) + 8);
    UNSCopyParserValue(fPendingValue,fPendingStruct.Arr[fPendingStruct.Count]);
    Inc(fPendingStruct.Count);
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
else
  begin
    SetLength(fPendingValue.DefValStrs,Length(fPendingValue.DefValStrs) + 1);
    fPendingValue.DefValStrs[High(fPendingValue.DefValStrs)] := fLexer[fLexer.LowIndex].LexemeText;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingDefValsStruct;
begin
If UNSIsSubCommand(fLexer[fLexer.LowIndex].LexemeText,sscDefValsEnd) then
  begin
    If Length(fPendingStruct.Arr) <= fPendingStruct.Count then
      SetLength(fPendingStruct.Arr,Length(fPendingStruct.Arr) + 8);
    UNSCopyParserValue(fPendingValue,fPendingStruct.Arr[fPendingStruct.Count]);
    Inc(fPendingStruct.Count);
    fState := psPendingStruct;
  end
else
  begin
    SetLength(fPendingValue.DefValStrs,Length(fPendingValue.DefValStrs) + 1);
    fPendingValue.DefValStrs[High(fPendingValue.DefValStrs)] := fLexer[fLexer.LowIndex].LexemeText;
  end;
end;

//==============================================================================

constructor TUNSParser.Create(AddMethod: TUNSParserAddValueEvent);
begin
inherited Create;
fLexer := TUNSLexer.Create;
fLexer.RemoveComments := True;
fAddMethod := AddMethod;
ReInitialize;
fAddCounter := 0;
end;

//------------------------------------------------------------------------------

destructor TUNSParser.Destroy;
begin
fLexer.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.ReInitialize;
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
        Parse_PendingStructClose;
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
      psPendingDefValsAddExpand,
      psPendingDefValsStructExpand:;
    end;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSParser.ParseLines(const Lines: TStrings): Integer;
var
  i:  Integer;
begin
fAddCounter := 0;
fState := psCommandAdd;
For i := 0 to Pred(Lines.Count) do
  ParseLine(Lines[i]);
Parse_PendingStructClose;
Result := fAddCounter;
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
