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

[#add] [@N[.]]value_name &expand struct_name [field_0_defval field_1_defval ... field_n_defval]

[#add] [@N[.]]value_name &expand struct_name &defvalbegin
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
    Name:   String;
    Arr:    array of TUNSParserValue;
    Count:  Integer;
  end;

  TUNSParserStructs = record
    Arr:    array of TUNSParserStruct;
    Count:  Integer;
  end;

  TUNSParserState = (psCommandAdd,psCommandPrefix,psCommandStruct,
                     psPendingAdd,psPendingStruct);

  TUNSParser = class(TObject)
  private
    fLexer:         TUNSLexer;
    fPrefixes:      TUNSParserPrefixes;
    fStructs:       TUNSParserStructs;
    fAddCounter:    Integer;
    fAddMethod:     TUNSParserAddValueEvent;
    // parsing variables
    fState:         TUNSParserState;
    fPendingValue:  TUNSParserValue;
    fPendingStruct: TUNSParserStruct;
  protected
    //procedure ParseValue; virtual; abstract;
    //procedure Parsing_CommandAdd; virtual;
    procedure Parsing_CommandPrefix; virtual;
    //procedure Parsing_CommandStruct; virtual;
    //procedure Parsing_PendingAdd; virtual;
    //procedure Parsing_PendingStruct; virtual;
  public
    constructor Create(AddMethod: TUNSParserAddValueEvent);
    destructor Destroy; override;
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
(*
procedure TUNSParser.Parsing_Add;
var
  PrefixIndex:  Integer;
  i:            Integer;
begin
If fLexer.Count >= 2 then
  begin
    If fLexer[fLexer.LowIndex].LexemeType in [lxtIdentifier,lxtName,lxtUnparsedName] then
      begin

        // first token - alway a value name
        If fLexer[fLexer.LowIndex].LexemeText = UNS_SCRIPT_PREFIXAPPENDTAG then
          begin
            // preppend prefix... get prefix index from first char after the tag
            PrefixIndex := StrToIntDef(fLexer[fLexer.LowIndex].LexemeText[2],-1);
            If PrefixIndex in UNS_SCRIPT_PREFIXRANGE then
              fPendingValue.Name := fPrefixes[PrefixIndex] + fLexer[fLexer.LowIndex].LexemeText
            else
              raise EUNSException.CreateFmt('Invalid prefix index (%d).',[PrefixIndex],Self,'Parsing_Add');
          end
        else fPendingValue.Name := fLexer[fLexer.LowIndex].LexemeText;

        // second token - can be value type identifier or expand subcommand
        If fLexer[fLexer.LowIndex + 1].LexemeType = lxtIdentifier then
          begin
            // type identifier
            fPendingValue.ValueType := IdentifyValueType(fLexer[fLexer.LowIndex + 1].LexemeText);
            If fPendingValue.ValueType = vtUndefined then
              raise EUNSException.CreateFmt('Invalid value type (%d).',
                [Ord(fPendingValue.ValueType)],Self,'Parsing_Add');
            // now load default value(s), if present
            If fLexer.Count > 2 then
              begin
                If UNSIsArrayValueType(fPendingValue.ValueType) then
                  begin
                    // inline array values
                    SetLength(fPendingValue.DefValueStrs,fLexer.Count - 2);
                    For i := Low(fPendingValue.DefValueStrs) to High(fPendingValue.DefValueStrs) do
                      fPendingValue.DefValueStrs[i] := fLexer[fLexer.LowIndex + 2].LexemeText;
                  end
                else
                  begin
                    // default value
                    SetLength(fPendingValue.DefValueStrs,1);
                    fPendingValue.DefValueStrs[Low(fPendingValue.DefValueStrs)] :=
                      fLexer[fLexer.LowIndex + 2].LexemeText;
                  end;
              end;
          end
        else
          begin
            If fLexer[fLexer.LowIndex + 1].LexemeType = lxtSubCommand then
              begin
              end;
            raise EUNSException.CreateFmt('Subcommand expected but %s found.',
              [fLexer[fLexer.LowIndex + 1].LexemeText],Self,'Parsing_Add');
          end;
      end
    else raise EUNSException.CreateFmt('Invalid value name (%s).',
           [fLexer[fLexer.LowIndex].LexemeText],Self,'Parsing_Add');
  end
else raise EUNSException.CreateFmt('Invalid token count (%d).',[fLexer.Count],Self,'Parsing_Add');
end;
*)
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
(*
//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_Struct;
begin
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingAdd;
begin
end;

//------------------------------------------------------------------------------

procedure TUNSParser.Parsing_PendingStruct;
begin
end;
*)
//==============================================================================

constructor TUNSParser.Create(AddMethod: TUNSParserAddValueEvent);
var
  i:  Integer;
begin
inherited Create;
fLexer := TUNSLexer.Create;
fLexer.RemoveComments := True;
fAddMethod := AddMethod;
For i := Low(fPrefixes) to High(fPrefixes) do
  fPrefixes[i] := '';
SetLength(fStructs.Arr,0);
fStructs.Count := 0;
fAddCounter := 0;
end;

//------------------------------------------------------------------------------

destructor TUNSParser.Destroy;
begin
fLexer.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TUNSParser.ParseLine(const Line: String);
begin
fLexer.ProcessLine(Line);
If fLexer.Count > 0 then
  begin
    If fLexer[fLexer.LowIndex].LexemeType = lxtCommand then
      begin
        with fLexer[fLexer.LowIndex] do
          case UNSIndetifyCommand(Copy(LexemeText,2,Length(LexemeText) - 1)) of
            scAdd:    fState := psCommandAdd;
            scPrefix: fState := psCommandPrefix;
            scStruct: fState := psCommandStruct;
          end;
        fLexer.RemoveFirstLexeme;
      end;
    case fState of
      //psCommandAdd:     If fLexer.Count > 0 then
      //                    Parsing_CommandAdd;
      psCommandPrefix:  Parsing_CommandPrefix;
      //psCommandStruct:  Parsing_CommandStruct;
      //psPendingAdd:     Parsing_PendingAdd;
      //psPendingStruct:  Parsing_PendingStruct;
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
