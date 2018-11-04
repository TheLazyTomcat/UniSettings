unit UniSettings_Common;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  AuxTypes, CRC32, MemoryBuffer;

type
  TUNSHashedString = record
    Str:  String;
    Hash: TCRC32;
  end;

  TDate = type TDateTime;
  TTime = type TDateTime;

  TUNSAoBool = record
    Arr:    array of Boolean;
    Count:  Integer;
  end;

  TUNSAoInt8 = record
    Arr:    array of Int8;
    Count:  Integer;
  end;

  TUNSAoUInt8 = record
    Arr:    array of UInt8;
    Count:  Integer;
  end;

  TUNSAoInt16 = record
    Arr:    array of Int16; 
    Count:  Integer;
  end;

  TUNSAoUInt16 = record
    Arr:    array of UInt16;
    Count:  Integer;
  end;

  TUNSAoInt32 = record
    Arr:    array of Int32;
    Count:  Integer;
  end;

  TUNSAoUInt32 = record
    Arr:    array of UInt32;
    Count:  Integer;
  end;

  TUNSAoInt64 = record
    Arr:    array of Int64; 
    Count:  Integer;
  end;

  TUNSAoUInt64 = record
    Arr:    array of UInt64; 
    Count:  Integer;
  end;

  TUNSAoFloat32 = record
    Arr:    array of Float32; 
    Count:  Integer;
  end;

  TUNSAoFloat64 = record
    Arr:    array of Float64; 
    Count:  Integer;
  end;

  TUNSAoData = record
    Arr:    array of TDate; 
    Count:  Integer;
  end;

  TUNSAoTime = record
    Arr:    array of TTime;
    Count:  Integer;
  end;

  TUNSAoDateTime = record
    Arr:    array of TDateTime; 
    Count:  Integer;
  end;

  TUNSAoText = record
    Arr:    array of String;
    Count:  Integer;
  end;

  TUNSAoBuffer = record
    Arr:    array of TMemoryBuffer;
    Count:  Integer;
  end;

  TUNSNodeClass = (ncUndefined,ncBranch,ncArrayItem,ncArray,ncLeaf);

  TUNSNodeDataType = (ndtUndefined,   // erroneous value
                      ndtBlank,       // node containing no data (usually placeholder)
                      ndtBool,        // boolean value (true/false)
                      ndtInt8,        // signed 8bit integer
                      ndtUInt8,       // unsigned 8bit integer
                      ndtInt16,       // signed 16bit integer
                      ndtUInt16,      // unsigned 16bit integer
                      ndtInt32,       // signed 32bit integer
                      ndtUInt32,      // unsigned 32bit integer
                      ndtInt64,       // signed 64bit integer
                      ndtUInt64,      // unsigned 64bit integer
                      ndtFloat32,     // single-precision (32bit) floating point number
                      ndtFloat64,     // double-precision (64bit) floating point number
                      ndtDate,        // date
                      ndtTime,        // time
                      ndtDateTime,    // date + time
                      ndtText,        // textual data (string)
                      ndtBuffer,      // general memory buffer
                      ndtAoBool,      // array of boolean values
                      ndtAoInt8,      // array of signed 8bit integers
                      ndtAoUInt8,     // array of unsigned 8bit integers
                      ndtAoInt16,     // array of signed 16bit integers
                      ndtAoUInt16,    // array of unsigned 16bit integers
                      ndtAoInt32,     // array of signed 32bit integers
                      ndtAoUInt32,    // array of unsigned 32bit integers
                      ndtAoInt64,     // array of signed 64bit integers
                      ndtAoUInt64,    // array of unsigned 64bit integers
                      ndtAoFloat32,   // array of single-precision floating point number
                      ndtAoFloat64,   // array of double-precision floating point number
                      ndtAoDate,      // array of dates
                      ndtAoTime,      // array of times
                      ndtAoDateTime,  // array of date + time values
                      ndtAoText,      // array of strings
                      ndtAoBuffer);   // array of memory buffers

  TUNSNodeFlag = (nfConst);

  TUNSNodeFlags = set of TUNSNodeFlag;

const
  UNS_STRS_NODEDATATYPE: array[TUNSNodeDataType] of String = (
    'undefined','blank',
    'Bool','Int8','UInt8','Int16','UInt16','Int32','UInt32','Int64','UInt64',
    'Float32','Float64','Date','Time','DateTime','Text','Buffer',
    'AoBool','AoInt8','AoUInt8','AoInt16','AoUInt16','AoInt32','AoUInt32',
    'AoInt64','AoUInt64','AoFloat32','AoFloat64','AoDate','AoTime','AoDateTime',
    'AoText','AoBuffer');

  UNS_NAME_ROOTNODE = 'root';

  UNS_PATH_DELIMITER = '.';

implementation

end.
