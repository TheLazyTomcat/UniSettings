unit UniSettings_ScriptUtils;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_ScriptCommon;
  
Function UNSIsValidUnparsedName(const Name: String): Boolean;

Function UNSIndetifyCommand(const Str: String): TUNSScriptCommand;

Function UNSIndetifySubCommand(const Str: String): TUNSScriptSubCommand;

Function UNSIsSubCommand(const Str: String; SubCommand: TUNSScriptSubCommand): Boolean;

Function UNSEncodeString(const Str: String): String;

Function UNSDecodeString(const Str: String): String;

implementation

uses
  SysUtils,
  UniSettings_Exceptions, UniSettings_Utils;

Function UNSIsValidUnparsedName(const Name: String): Boolean;
begin
Result := False;
If Length(Name) > 0 then
  begin
    If Name[1] = UNS_SCRIPT_PREFIXAPPENDTAG then
      begin
        If Length(Name) >= 2 then
          begin
            Result := UNSCharInSet(Name[2],UNS_SCRIPT_PREFIXCHARS) and
                      UNSIsValidName(Copy(Name,3,Length(Name) - 2))
          end;
      end
    else Result := UNSIsValidName(Name);
  end;
end;

//------------------------------------------------------------------------------

Function UNSIndetifyCommand(const Str: String): TUNSScriptCommand;
var
  i:  TUNSScriptCommand;
begin
If Length(Str) > 1 then
  For i := Low(TUNSScriptCommand) to High(TUNSScriptCommand) do
    If AnsiSameText(Str,UNS_SCRIPT_COMMAND_STRS[i]) then
      begin
        Result := i;
        Exit;
      end;
raise EUNSException.CreateFmt('Unknown command %s.',[Str],'UNSIndetifyCommand');
end;

//------------------------------------------------------------------------------

Function UNSIndetifySubCommand(const Str: String): TUNSScriptSubCommand;
var
  i:    TUNSScriptSubCommand;
  Temp: String;
begin
If Length(Str) > 1 then
  For i := Low(TUNSScriptSubCommand) to High(TUNSScriptSubCommand) do
    If AnsiSameText(Temp,UNS_SCRIPT_SUBCOMMAND_STRS[i]) then
      begin
        Result := i;
        Exit;
      end;
raise EUNSException.CreateFmt('Unknown subcommand %s.',[Str],'UNSIndetifySubCommand');
end;

//------------------------------------------------------------------------------

Function UNSIsSubCommand(const Str: String; SubCommand: TUNSScriptSubCommand): Boolean;
begin
If Length(Str) > 0 then
  begin
    Result := (Str[1] = UNS_SCRIPT_SUBCOMMANDTAG) and
              AnsiSameText(UNS_SCRIPT_SUBCOMMAND_STRS[SubCommand],
                           Copy(Str,2,Length(Str) - 1));
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function UNSEncodeString(const Str: String): String;
var
  i,ResPos: Integer;

  Function MustBeQuoted: Boolean;
  var
    ii: Integer;
  begin
    case Str[1] of
      UNS_SCRIPT_COMMANDTAG,
      UNS_SCRIPT_SUBCOMMANDTAG,
      UNS_SCRIPT_PREFIXAPPENDTAG,
      UNS_SCRIPT_COMMENTTAGSINGLE:  Result := True;
    else
      Result := False;
      For ii := 1 to Length(Str) do
        If (Str[ii] = UNS_SCRIPT_TEXTQUOTECHAR) or
          (Ord(Str[ii]) > 127) or (Ord(Str[ii]) <= 32) then
          begin
            Result := True;
            Break{For ii};
          end;
    end;
  end;

  Function CountQuoteChars: Integer;
  var
    ii: Integer;
  begin
    Result := 0;
    For ii := 1 to Length(Str) do
      If Str[ii] = UNS_SCRIPT_TEXTQUOTECHAR then
        Inc(Result);
  end;

begin
If Length(Str) > 0 then
  begin
    If MustBeQuoted then
      begin
        SetLength(Result,Length(Str) + CountQuoteChars + 2);
        Result[1] := UNS_SCRIPT_TEXTQUOTECHAR;
        Result[Length(Result)] := UNS_SCRIPT_TEXTQUOTECHAR;
        ResPos := 2;
        For i := 1 to Length(Str) do
          begin
            Result[ResPos] := Str[i];
            If Str[i] = UNS_SCRIPT_TEXTQUOTECHAR then
              begin
                Result[ResPos + 1] := Str[i];
                Inc(ResPos);
              end;
            Inc(ResPos);
          end;
      end
    else Result := Str;
  end
else Result := StringOfChar(UNS_SCRIPT_TEXTQUOTECHAR,2);
end;

//------------------------------------------------------------------------------

Function UNSDecodeString(const Str: String): String;
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

end.

