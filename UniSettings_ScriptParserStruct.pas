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
    SigA:   UInt32;
    Count:  Integer;
    Data:   PtrInt;
    SigB:   UInt32;
  end;
  PUNSParserStruct = ^TUNSParserStruct;

  TCDABaseType = TUNSParserValue;
  PCDABaseType = PUNSParserValue;

  TCDAArrayType = TUNSParserStruct;
  PCDAArrayType = PUNSParserStruct;

{$DEFINE CDA_DisableFunc_ItemUnique}
{$DEFINE CDA_HideFunc_CopyP}
{$DEFINE CDA_HideFunc_Copy}

{$DEFINE CDA_Interface}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Interface}

// overridden functions
Function CDA_Copy(const Src: TCDAArrayType; Index, Count: Integer): TCDAArrayType; overload;
Function CDA_Copy(const Src: TCDAArrayType): TCDAArrayType; overload;

implementation

uses
  SysUtils,
  ListSorters;

Function CDA_CompareFunc(const A,B: TUNSParserValue): Integer;{$IFDEF CanInline} inline; {$ENDIF}
begin
Result := -AnsiCompareText(A.Name,B.Name);
end;

//------------------------------------------------------------------------------

procedure CDA_ItemUnique(var Item: TCDABaseType); {$IFDEF CanInline} inline; {$ENDIF}
begin
UniqueString(Item.Name);
CDA_UniqueArray(Item.DefValStrs);
end;

//------------------------------------------------------------------------------

{$DEFINE CDA_Implementation}
{$INCLUDE '.\CountedDynArrays.inc'}
{$UNDEF CDA_Implementation}

//------------------------------------------------------------------------------

Function CDA_Copy(const Src: TCDAArrayType; Index, Count: Integer): TCDAArrayType;
begin
Result := _CDA_Copy(Src,Index,Count);
Result.Name := Src.Name;
UniqueString(Result.Name);
end;

//------------------------------------------------------------------------------

Function CDA_Copy(const Src: TCDAArrayType): TCDAArrayType;
begin
Result := _CDA_Copy(Src);
Result.Name := Src.Name;
UniqueString(Result.Name);
end;

end.
