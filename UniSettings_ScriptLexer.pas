unit UniSettings_ScriptLexer;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  AuxClasses;

type
  TUNSTokenType = (ttUnknown,ttIdentifier,ttCommand,ttSubCommand,
                   ttName,ttUnparsedName,ttText,ttComment);

  TUNSToken = record
    Lexeme:     String;
    TokenType:  TUNSTokenType;
  end;

  TUNSTokens = record
    Arr:    array of TUNSToken;
    Count:  Integer;
  end;

  TUNSLexerState = (lxsTraverse,lxsText,lxsQuotedText,lxsComment);

  TUNSLexer = class(TCustomListObject)
  private
    fRemoveComments:  Boolean;
    fLine:            String;
    fTokens:          TUNSTokens;
    // lexing variables
    fStage:           TUNSLexerState;
    fPosition:        Integer;
    fLexemeStart:     Integer;
    fLexemeLength:    Integer;
    Function GetToken(Index: Integer): TUNSToken;
  protected
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    procedure SetCount(Value: Integer); override;
    // list management
    Function Add(const Lexeme: String; TokenType: TUNSTokenType): Integer; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    // lexing methods
    procedure DiscernTokenType(var Token: TUNSToken); virtual;
    procedure InitializeLexing(const Line: String); virtual;
    procedure Lexing_Traverse; virtual;
    procedure Lexing_Text; virtual;
    procedure Lexing_QuotedText; virtual;
    procedure Lexing_Comment; virtual;
  public
    destructor Destroy; override;
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    Function ProcessLine(const Line: String): Integer; virtual;
    procedure RemoveFirstToken; virtual;
    property RemoveComments: Boolean read fRemoveComments write fRemoveComments;
    property Line: String read fLine;
    property Tokens[Index: Integer]: TUNSToken read GetToken; default;
  end;

implementation

uses
  UniSettings_Exceptions, UniSettings_Utils, UniSettings_ScriptCommon,
  UniSettings_ScriptUtils;

Function TUNSLexer.GetToken(Index: Integer): TUNSToken;
begin
If CheckIndex(Index) then
  Result := fTokens.Arr[Index]
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetToken');
end;

//==============================================================================

Function TUNSLexer.GetCapacity: Integer;
begin
Result := Length(fTokens.Arr);
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.SetCapacity(Value: Integer);
begin
SetLength(fTokens.Arr,Value);
If Value < fTokens.Count then
  fTokens.Count := Value;
end;

//------------------------------------------------------------------------------

Function TUNSLexer.GetCount: Integer;
begin
Result := fTokens.Count;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.SetCount(Value: Integer);
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TUNSLexer.Add(const Lexeme: String; TokenType: TUNSTokenType): Integer;
begin
Grow;
Result := fTokens.Count;
fTokens.Arr[Result].Lexeme := Lexeme;
fTokens.Arr[Result].TokenType := TokenType;
Inc(fTokens.Count);
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    For i := Index to Pred(HighIndex) do
      fTokens.Arr[i] := fTokens.Arr[i + 1];
    Dec(fTokens.Count);
    // do not shrink
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'Delete');
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.Clear;
begin
fTokens.Count := 0;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.DiscernTokenType(var Token: TUNSToken);
begin
If (Token.TokenType = ttUnknown) and (Length(Token.Lexeme) > 0) then
  case Token.Lexeme[1] of
    UNS_SCRIPT_COMMANDTAG:
      If UNSIsValidIdentifier(Copy(Token.Lexeme,2,Length(Token.Lexeme))) then
        Token.TokenType := ttCommand;
    UNS_SCRIPT_SUBCOMMANDTAG:
      If UNSIsValidIdentifier(Copy(Token.Lexeme,2,Length(Token.Lexeme))) then
        Token.TokenType := ttSubCommand;
  else
    If UNSIsValidIdentifier(Token.Lexeme) then
      Token.TokenType := ttIdentifier
    else If UNSIsValidName(Token.Lexeme) then
      Token.TokenType := ttName
    else If UNSIsValidUnparsedName(Token.Lexeme) then
      Token.TokenType := ttUnparsedName;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.InitializeLexing(const Line: String);
begin
Clear;
fLine := Line;
fStage := lxsTraverse;
fPosition := 1;
fLexemeStart := 1;
fLexemeLength := 0;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.Lexing_Traverse;
begin
If not(fLine[fPosition] in UNS_SCRIPT_WHITESPACES) then
  begin
    case fLine[fPosition] of
      UNS_SCRIPT_COMMENTTAGSINGLE:
        begin
          fStage := lxsText;
          fLexemeStart := fPosition;
          fLexemeLength := 1;
          If fPosition < Length(fLine) then
            If fLine[fPosition + 1] = UNS_SCRIPT_COMMENTTAGSINGLE then
              begin
                fStage := lxsComment;
                fLexemeStart := fPosition + 2;
                fLexemeLength := 0;
                Inc(fPosition);
              end;
        end;
      UNS_SCRIPT_TEXTQUOTECHAR:
        begin
          fStage := lxsQuotedText;
          fLexemeStart := fPosition + 1;
          fLexemeLength := 0;
        end;
    else
      fStage := lxsText;
      fLexemeStart := fPosition;
      fLexemeLength := 1;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.Lexing_Text;
begin
If fLine[fPosition] in UNS_SCRIPT_WHITESPACES then
  begin
    Add(Copy(fLine,fLexemeStart,fLexemeLength),ttUnknown);
    fStage := lxsTraverse;
  end
else Inc(fLexemeLength);
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.Lexing_QuotedText;

  Function QuoteAhead: Boolean;
  begin
    Result := False;
    If fPosition < Length(fLine) then
      Result := fLine[fPosition + 1] = UNS_SCRIPT_TEXTQUOTECHAR;
  end;

begin
If fLine[fPosition] = UNS_SCRIPT_TEXTQUOTECHAR then
  begin
    If not QuoteAhead then
      begin
        Add(Copy(fLine,fLexemeStart,fLexemeLength),ttText);
        fStage := lxsTraverse;
      end
    else
      begin
        Inc(fPosition);
        Inc(fLexemeLength);
      end;
  end;
Inc(fLexemeLength);
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.Lexing_Comment;
begin
Inc(fLexemeLength);
end;

//==============================================================================

destructor TUNSLexer.Destroy;
begin
Clear;
inherited;
end;

//------------------------------------------------------------------------------

Function TUNSLexer.LowIndex: Integer;
begin
Result := 0;
end;

//------------------------------------------------------------------------------

Function TUNSLexer.HighIndex: Integer;
begin
Result := Pred(fTokens.Count);
end;

//------------------------------------------------------------------------------

Function TUNSLexer.ProcessLine(const Line: String): Integer;
var
  i:  Integer;
begin
InitializeLexing(Line);
while fPosition <= Length(fLine) do
  begin
    case fStage of
      lxsTraverse:   Lexing_Traverse;
      lxsText:       Lexing_Text;
      lxsQuotedText: Lexing_QuotedText;
      lxsComment:    Lexing_Comment;
    end;
    Inc(fPosition);
  end;
// process lingering stuff
case fStage of
  lxsText:       Add(Copy(fLine,fLexemeStart,fLexemeLength),ttUnknown);
  lxsQuotedText: Add(Copy(fLine,fLexemeStart,fLexemeLength),ttText);
  lxsComment:    Add(Copy(fLine,fLexemeStart,fLexemeLength),ttComment);
end;
// decide final types
For i := LowIndex to HighIndex do
  DiscernTokenType(fTokens.Arr[i]);
// remove comments
If fRemoveComments then
  For i := HighIndex downto LowIndex do
    If fTokens.Arr[i].TokenType = ttComment then
      Delete(i);
Result := fTokens.Count;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.RemoveFirstToken;
begin
If fTokens.Count > 0 then
  Delete(LowIndex);
end;

end.
