unit UniSettings_Common;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  AuxTypes, CRC32;

type
  TUNSHashedString = record
    Str:  String;
    Hash: TCRC32;
  end;

  TDate = type TDateTime;   PDate = ^TDate;
  TTime = type TDateTime;   PTime = ^TTime;

//------------------------------------------------------------------------------

  TUNSNodeClass = (ncUndefined,ncBranch,ncArrayItem,ncArray,ncLeaf);

  TUNSValueKind = (vkActual,vkSaved,vkDefault);

  TUNSValueKinds = set of TUNSValueKind;

  TUNSValueType = (vtUndefined,   // erroneous value
                   vtBlank,       // node containing no data (usually placeholder)
                   vtBool,        // boolean value (true/false)
                   vtInt8,        // signed 8bit integer
                   vtUInt8,       // unsigned 8bit integer
                   vtInt16,       // signed 16bit integer
                   vtUInt16,      // unsigned 16bit integer
                   vtInt32,       // signed 32bit integer
                   vtUInt32,      // unsigned 32bit integer
                   vtInt64,       // signed 64bit integer
                   vtUInt64,      // unsigned 64bit integer
                   vtFloat32,     // single-precision (32bit) floating point number
                   vtFloat64,     // double-precision (64bit) floating point number
                   vtDate,        // date
                   vtTime,        // time
                   vtDateTime,    // date + time
                   vtText,        // textual data (string)
                   vtBuffer,      // general memory buffer
                   vtAoBool,      // array of boolean values
                   vtAoInt8,      // array of signed 8bit integers
                   vtAoUInt8,     // array of unsigned 8bit integers
                   vtAoInt16,     // array of signed 16bit integers
                   vtAoUInt16,    // array of unsigned 16bit integers
                   vtAoInt32,     // array of signed 32bit integers
                   vtAoUInt32,    // array of unsigned 32bit integers
                   vtAoInt64,     // array of signed 64bit integers
                   vtAoUInt64,    // array of unsigned 64bit integers
                   vtAoFloat32,   // array of single-precision floating point number
                   vtAoFloat64,   // array of double-precision floating point number
                   vtAoDate,      // array of dates
                   vtAoTime,      // array of times
                   vtAoDateTime,  // array of date + time values
                   vtAoText,      // array of strings
                   vtAoBuffer,    // array of memory buffers
                   // some aliases...
                   vtInteger   = vtInt32,
                   vtFloat     = vtFloat32,
                   vtAoInteger = vtAoInt32,
                   vtAoFloat   = vtAoFloat32);

const
  UNS_VALUETYPE_STRS: array[TUNSValueType] of String = (
    'undefined','Blank',
    'Bool','Int8','UInt8','Int16','UInt16','Int32','UInt32','Int64','UInt64',
    'Float32','Float64','Date','Time','DateTime','Text','Buffer',
    'AoBool','AoInt8','AoUInt8','AoInt16','AoUInt16','AoInt32','AoUInt32',
    'AoInt64','AoUInt64','AoFloat32','AoFloat64','AoDate','AoTime','AoDateTime',
    'AoText','AoBuffer');

type
  TUNSValueFlag = (vfNone); // atm. not implemented

  TUNSValueFlags = set of TUNSValueFlag;

//------------------------------------------------------------------------------

  TUNSValueFormatSettings = record
    NumericBools: Boolean;
    HexIntegers:  Boolean;
    HexFloats:    Boolean;
    HexDateTime:  Boolean;
  end;

const
  UNS_VALUEFORMATSETTINGS_DEFAULT: TUNSValueFormatSettings = (
    NumericBools: False;
    HexIntegers:  False;
    HexFloats:    False;
    HexDateTime:  False);

  UNS_VALUEFORMATSETTING_INDEX_NUMBOOL = 0;
  UNS_VALUEFORMATSETTING_INDEX_HEXINTS = 1;
  UNS_VALUEFORMATSETTING_INDEX_HEXFLTS = 2;
  UNS_VALUEFORMATSETTING_INDEX_HEXDTTM = 3;

//------------------------------------------------------------------------------

type
  TUNSNamePartType = (nptInvalid,nptIdentifier,nptArrayIdentifier,
                      nptArrayIndex,nptArrayIndexDef,
                      nptArrayItem,nptArrayItemDef);

  TUNSNamePart = record
    PartType:   TUNSNamePartType;
    PartStr:    TUNSHashedString;
    PartIndex:  Integer;
  end;

  TUNSNameParts = record
    Arr:    array of TUNSNamePart;
    Count:  Integer;
    Valid:  Boolean;
  end;

const
  UNS_NAME_ROOTNODE = 'root';

  UNS_NAME_INDEX_DEFAULT = -1;

  UNS_NAME_IDENTIFIER_VALIDCHARS = ['0'..'9','a'..'z','A'..'Z','_'];

  UNS_NAME_DELIMITER        = '.';
  UNS_NAME_BRACKET_LEFT     = '[';
  UNS_NAME_BRACKET_RIGHT    = ']';
  UNS_NAME_BRACKETDEF_LEFT  = '<';
  UNS_NAME_BRACKETDEF_RIGHT = '>';
  UNS_NAME_ARRAYITEM_TAG    = '#';

  UNS_NAME_BRACKETS_LEFT  = [UNS_NAME_BRACKET_LEFT,UNS_NAME_BRACKETDEF_LEFT];
  UNS_NAME_BRACKETS_RIGHT = [UNS_NAME_BRACKET_RIGHT,UNS_NAME_BRACKETDEF_RIGHT];

  UNS_NAME_BRACKETS = UNS_NAME_BRACKETS_LEFT + UNS_NAME_BRACKETS_RIGHT;

  UNS_NAME_DELIMITERS = [UNS_NAME_DELIMITER] + UNS_NAME_BRACKETS_LEFT;

  UNS_NAME_VALIDCHARS = UNS_NAME_IDENTIFIER_VALIDCHARS + UNS_NAME_DELIMITERS +
                        UNS_NAME_BRACKETS + [UNS_NAME_ARRAYITEM_TAG];

  UNS_NAME_ARRAYITEM_NEW     = 0;
  UNS_NAME_ARRAYITEM_LOW     = 1;
  UNS_NAME_ARRAYITEM_HIGH    = 2;

implementation

end.
