unit UniSettings_ScriptCommon;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

const
  UNS_SCRIPT_COMMANDTAG       = '#';
  UNS_SCRIPT_SUBCOMMANDTAG    = '&';
  UNS_SCRIPT_PREFIXAPPENDTAG  = '@';
  UNS_SCRIPT_HEXNUMBERTAG     = '$';
  UNS_SCRIPT_COMMENTTAGSINGLE = '/';
  UNS_SCRIPT_TEXTQUOTECHAR    = '"';
  UNS_SCRIPT_PREFIXCHARS      = ['0'..'9'];
  UNS_SCRIPT_WHITESPACES      = [#0..#32];
  UNS_SCRIPT_PREFIXRANGE      = [0..9];

type
  TUNSScriptCommand = (scAdd,scPrefix,scStruct);

const
  UNS_SCRIPT_COMMAND_STRS: array[TUNSScriptCommand] of String =
    ('add','prefix','struct');

type
  TUNSScriptSubCommand = (sscExpand,sscDefValBegin,sscDefValEnd);

const  
  UNS_SCRIPT_SUBCOMMAND_STRS: array[TUNSScriptSubCommand] of string =
    ('expand','defvalbegin','defvalend');

implementation

end.
