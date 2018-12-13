unit UniSettings_ScriptUtils;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_ScriptCommon;
  
Function UNSIsValidUnparsedName(const Name: String): Boolean;

Function UNSIndetifyCommand(const Str: String): TUNSScriptCommand;

Function UNSIndetifySubCommand(const Str: String): TUNSScriptSubCommand;

Function UNSIsSubCommand(const Str: String; SubCommand: TUNSScriptSubCommand): Boolean;

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

end.
