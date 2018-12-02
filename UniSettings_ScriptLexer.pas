unit UniSettings_ScriptLexer;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  AuxClasses;

type
  TUNSLexemeType = (lxtUnknown,lxtIdentifier,lxtCommand,lxtSubCommand,
                    lxtName,lxtUnparsedName,lxtText,lxtComment);

  TUNSLexeme = record
    LexemeType: TUNSLexemeType;
    LexemeText: String;
  end;

  TUNSLexemes = record
    Arr:    array of TUNSLexeme;
    Count:  Integer;
  end;

  TUNSLexerState = (lxsTraverse,lxsText,lxsQuotedText,lxsComment);

  TUNSLexer = class(TCustomListObject)
  private
    fRemoveComments:  Boolean;
    fLine:            String;
    fLexemes:         TUNSLexemes;
    // lexing variables
    fStage:           TUNSLexerState;
    fPosition:        Integer;
    fLexemeStart:     Integer;
    fLexemeLength:    Integer;
    Function GetLexeme(Index: Integer): TUNSLexeme;
  protected
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    procedure SetCount(Value: Integer); override;
    // list management
    Function Add(LexemeType: TUNSLexemeType; const LexemeText: String): Integer; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    // lexing methods
    procedure DiscernLexemeType(var Lexeme: TUNSLexeme); virtual;
    Function RectifyQuotes(const Str: String): String; virtual;
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
    procedure RemoveFirstLexeme; virtual;
    property RemoveComments: Boolean read fRemoveComments write fRemoveComments;
    property Line: String read fLine;
    property Lexemes[Index: Integer]: TUNSLexeme read GetLexeme; default;
  end;

implementation

uses
  UniSettings_Exceptions, UniSettings_Utils, UniSettings_ScriptCommon,
  UniSettings_ScriptUtils;

Function TUNSLexer.GetLexeme(Index: Integer): TUNSLexeme;
begin
If CheckIndex(Index) then
  Result := fLexemes.Arr[Index]
else
  raise EUNSIndexOutOfBoundsException.Create(Index,Self,'GetLexeme');
end;

//==============================================================================

Function TUNSLexer.GetCapacity: Integer;
begin
Result := Length(fLexemes.Arr);
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.SetCapacity(Value: Integer);
begin
SetLength(fLexemes.Arr,Value);
If Value < fLexemes.Count then
  fLexemes.Count := Value;
end;

//------------------------------------------------------------------------------

Function TUNSLexer.GetCount: Integer;
begin
Result := fLexemes.Count;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.SetCount(Value: Integer);
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TUNSLexer.Add(LexemeType: TUNSLexemeType; const LexemeText: String): Integer;
begin
Grow;
Result := fLexemes.Count;
fLexemes.Arr[Result].LexemeType := LexemeType;
fLexemes.Arr[Result].LexemeText := LexemeText;
Inc(fLexemes.Count);
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    For i := Index to Pred(HighIndex) do
      fLexemes.Arr[i] := fLexemes.Arr[i + 1];
    Dec(fLexemes.Count);
    // do not shrink
  end
else raise EUNSIndexOutOfBoundsException.Create(Index,Self,'Delete');
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.Clear;
begin
fLexemes.Count := 0;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.DiscernLexemeType(var Lexeme: TUNSLexeme);
begin
If (Lexeme.LexemeType = lxtUnknown) and (Length(Lexeme.LexemeText) > 0) then
  case Lexeme.LexemeText[1] of
    UNS_SCRIPT_COMMANDTAG:
      If UNSIsValidIdentifier(Copy(Lexeme.LexemeText,2,Length(Lexeme.LexemeText))) then
        Lexeme.LexemeType := lxtCommand;
    UNS_SCRIPT_SUBCOMMANDTAG:
      If UNSIsValidIdentifier(Copy(Lexeme.LexemeText,2,Length(Lexeme.LexemeText))) then
        Lexeme.LexemeType := lxtSubCommand;
  else
    If UNSIsValidIdentifier(Lexeme.LexemeText) then
      Lexeme.LexemeType := lxtIdentifier
    else If UNSIsValidName(Lexeme.LexemeText) then
      Lexeme.LexemeType := lxtName
    else If UNSIsValidUnparsedName(Lexeme.LexemeText) then
      Lexeme.LexemeType := lxtUnparsedName;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSLexer.RectifyQuotes(const Str: String): String;
var
  i,ResPos: Integer;
begin
SetLength(Result,Length(Str));
ResPos := 1;
For i := 1 to Length(Str) do
  begin
    If (Str[i] = UNS_SCRIPT_TEXTQUOTECHAR) and (i > 1) then
      If Str[i - 1] = UNS_SCRIPT_TEXTQUOTECHAR then
        Continue; // char is not copied into result and ResPos is not increased
    Result[ResPos] := Str[i];
    Inc(ResPos);    
  end;
SetLength(Result,ResPos - 1);
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
    Add(lxtUnknown,Copy(fLine,fLexemeStart,fLexemeLength));
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
        Add(lxtText,RectifyQuotes(Copy(fLine,fLexemeStart,fLexemeLength)));
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
Result := Pred(fLexemes.Count);
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
  lxsText:       Add(lxtUnknown,Copy(fLine,fLexemeStart,fLexemeLength));
  lxsQuotedText: Add(lxtText,RectifyQuotes(Copy(fLine,fLexemeStart,fLexemeLength)));
  lxsComment:    Add(lxtComment,Copy(fLine,fLexemeStart,fLexemeLength));
end;
// decide final types
For i := LowIndex to HighIndex do
  DiscernLexemeType(fLexemes.Arr[i]);
// remove comments
If fRemoveComments then
  For i := HighIndex downto LowIndex do
    If fLexemes.Arr[i].LexemeType = lxtComment then
      Delete(i);
Result := fLexemes.Count;
end;

//------------------------------------------------------------------------------

procedure TUNSLexer.RemoveFirstLexeme;
begin
If fLexemes.Count > 0 then
  Delete(LowIndex);
end;

end.
