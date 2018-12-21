unit UniSettings_ScriptParserStruct;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  AuxTypes, CountedDynArrays, CountedDynArrayString,
  UniSettings_Common;

type
  TUNSParserValue = record
    Name:       String;
    ValueType:  TUNSValueType;
    DefValStrs: TStringCountedDynArray;
  end;
  PUNSParserValue = ^TUNSParserValue;

  TUNSParserStruct = record
    Name:   String;
    Arr:    array of TUNSParserValue;
    Count:  Integer;
    Data:   PtrInt;
  end;
  PUNSParserStruct = ^TUNSParserStruct;

  TCDABaseType = TUNSParserValue;
  PCDABaseType = PUNSParserValue;

  TCDAArrayType = TUNSParserStruct;
  PCDAArrayType = PUNSParserStruct;

{$DEFINE CDA_Interface}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Interface}

implementation

uses
  SysUtils,
  ListSorters;

Function CDA_CompareFunc(const A,B: TUNSParserValue): Integer;
begin
Result := -AnsiCompareText(A.Name,B.Name);
end;

//------------------------------------------------------------------------------

{$DEFINE CDA_Implementation}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Implementation}

end.
