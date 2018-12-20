unit UniSettings_Utils;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils,
  AuxTypes,
  UniSettings_Common;

Function UNSIsArrayValueType(ValueType: TUNSValueType): Boolean;

Function UNSCharInSet(C: Char; CharSet: TSysCharSet): Boolean;

Function UNSIsValidIdentifier(const Identifier: String): Boolean;

Function UNSIsValidName(const Name: String): Boolean;

Function UNSSameHashString(A,B: TUNSHashedString; FullEval: Boolean = False): Boolean;

procedure UNSHashString(var HashStr: TUNSHashedString);

Function UNSHashedString(const Str: String): TUNSHashedString;

Function UNSNameParts(const Name: String; out NameParts: TUNSNameParts): Integer;

Function UNSIdentifyValueType(const Str: String): TUNSValueType;

Function UNSUInt64ToStr(Value: UInt64): String;

Function UNSStrToUInt64(const Str: String): UInt64;

Function UNSTryStrToUInt64(const Str: String; out Value: UInt64): Boolean;

Function UNSStrToUInt64Def(const Str: String; Default: UInt64): UInt64;

implementation

uses
  StrUtils,
  CRC32,
  UniSettings_Exceptions;

Function UNSIsArrayValueType(ValueType: TUNSValueType): Boolean;
begin
Result := ValueType in [vtAoBool,vtAoInt8,vtAoUInt8,vtAoInt16,vtAoUInt16,
  vtAoInt32,vtAoUInt32,vtAoInt64,vtAoUInt64,vtAoFloat32,vtAoFloat64,vtAoDate,
  vtAoTime,vtAoDateTime,vtAoText,vtAoBuffer]
end;

//------------------------------------------------------------------------------

Function UNSCharInSet(C: Char; CharSet: TSysCharSet): Boolean;
begin
{$IF SizeOf(Char) > 1}
If Ord(C) > 255 then
  Result := False
else
{$IFEND}
  Result := AnsiChar(C) in CharSet
end;

//------------------------------------------------------------------------------

Function UNSIsValidIdentifier(const Identifier: String): Boolean;
var
  i:  Integer;
begin
If Length(Identifier) > 1 then
  begin
    If UNSCharInSet(Identifier[1],UNS_NAME_IDENTIFIER_VALIDFIRSTCHARS) then
      begin
        Result := True;      
        For i := 1 to Length(Identifier) do
          If not UNSCharInSet(Identifier[i],UNS_NAME_IDENTIFIER_VALIDCHARS) then
            begin
              Result := False;
              Break{For i};
            end;
      end
    else Result := False;
  end
else If Length(Identifier) = 1 then
  Result := UNSCharInSet(Identifier[1],UNS_NAME_IDENTIFIER_ONECHAR_VALIDCHARS)
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function UNSIsValidName(const Name: String): Boolean;
var
  i:  Integer;
begin
If Length(Name) > 0 then
  begin
    Result := True;
    For i := 1 to Length(Name) do
      If not UNSCharInSet(Name[i],UNS_NAME_VALIDCHARS) then
        begin
          Result := False;
          Break{For i};
        end;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function UNSSameHashString(A,B: TUNSHashedString; FullEval: Boolean = False): Boolean;
begin
If SameCRC32(A.Hash,B.Hash) then
  begin
    If FullEval then
      Result := AnsiSameText(A.Str,B.Str)
    else
      Result := True;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure UNSHashString(var HashStr: TUNSHashedString);
begin
HashStr.Hash := StringCRC32(AnsiLowerCase(HashStr.Str));
end;

//------------------------------------------------------------------------------

Function UNSHashedString(const Str: String): TUNSHashedString;
begin
Result.Str := Str;
UNSHashString(Result);
end;

//------------------------------------------------------------------------------

Function UNSNameParts(const Name: String; out NameParts: TUNSNameParts): Integer;
var
  i,Start:        Integer;
  PrevDelimiter:  Char;
  TempPart:       TUNSNamePart;

  Function CheckAndSetIdentifier(const Str: String; out HashedStr: TUNSHashedString): Boolean;
  begin
    HashedStr := UNSHashedString(Str);
    Result := UNSIsValidIdentifier(Str);
  end;

  Function CheckDelimiters(Prev,Current: Char): Boolean;
  begin
    // check if brackets match
    case Current of
      UNS_NAME_BRACKET_RIGHT:     Result := Prev = UNS_NAME_BRACKET_LEFT;
      UNS_NAME_BRACKETSAV_RIGHT:  Result := Prev = UNS_NAME_BRACKETSAV_LEFT;      
      UNS_NAME_BRACKETDEF_RIGHT:  Result := Prev = UNS_NAME_BRACKETDEF_LEFT;
    else
      Result := True;
    end;
  end;

begin
CDA_Clear(NameParts);
If Length(Name) > 0 then
  begin
    Start := 1;
    i := 1;
    PrevDelimiter := UNS_NAME_DELIMITER; 
    while i <= Length(Name) do
      begin
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
        If UNSCharInSet(Name[i],UNS_NAME_DELIMITERS) then
          begin
            // last part was an (array) identifier
            If CheckAndSetIdentifier(Copy(Name,Start,i - Start),TempPart.PartStr) then
              begin
                If Name[i] <> UNS_NAME_DELIMITER then
                  TempPart.PartType := nptArrayIdentifier
                else
                  TempPart.PartType := nptIdentifier;
              end
            else TempPart.PartType := nptInvalid;
            TempPart.PartIndex := UNS_NAME_INDEX_DEFAULT;
            CDA_Add(NameParts,TempPart);
            PrevDelimiter := Name[i];
            Start := i + 1;
          end
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
        else If UNSCharInSet(Name[i],UNS_NAME_BRACKETS_RIGHT) then
          begin
            // last part was in brackets, index or item number
            If CheckDelimiters(PrevDelimiter,Name[i]) then
              begin
                // left bracket matches the right one
                If Name[Start] = UNS_NAME_ARRAYITEM_TAG then
                  begin
                    // there is item number in the brackets
                    case Name[i] of
                      UNS_NAME_BRACKET_RIGHT:     TempPart.PartType := nptArrayItem;
                      UNS_NAME_BRACKETSAV_RIGHT:  TempPart.PartType := nptArrayItemSav;
                      UNS_NAME_BRACKETDEF_RIGHT:  TempPart.PartType := nptArrayItemDef;
                    else
                      TempPart.PartType := nptInvalid;
                    end;
                    // resolve to item number (not index!)
                    If (i - Start) = 2 then
                      case Name[Start + 1] of
                        '0','N','n':  TempPart.PartIndex := UNS_NAME_ARRAYITEM_NEW;
                        '1','L','l':  TempPart.PartIndex := UNS_NAME_ARRAYITEM_LOW;
                        '2','H','h':  TempPart.PartIndex := UNS_NAME_ARRAYITEM_HIGH;
                      else
                        TempPart.PartType := nptInvalid;
                      end
                    else TempPart.PartType := nptInvalid;
                  end
                else
                  begin
                    // there is item index in the brackets
                    If TryStrToInt(Copy(Name,Start,i - Start),TempPart.PartIndex) then
                      begin
                        case Name[i] of
                          UNS_NAME_BRACKET_RIGHT:     TempPart.PartType := nptArrayIndex;
                          UNS_NAME_BRACKETSAV_RIGHT:  TempPart.PartType := nptArrayIndexSav;
                          UNS_NAME_BRACKETDEF_RIGHT:  TempPart.PartType := nptArrayIndexDef;
                        else
                          TempPart.PartType := nptInvalid;
                        end;
                      end
                    else TempPart.PartType := nptInvalid;
                  end;
              end
            else
              begin
                // wrong delimiter
                TempPart.PartType := nptInvalid;
                TempPart.PartIndex := UNS_NAME_INDEX_DEFAULT;
              end;
            TempPart.PartStr := UNSHashedString(Copy(Name,Start,i - Start));
            CDA_Add(NameParts,TempPart);
            PrevDelimiter := Name[i];
            Start := i + 2; // delimiter is expected after the closing bracket
            Inc(i);
          end;
        Inc(i);
      end{while};
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
    // process last part if present (must be identifier, nothing else is allowed)
    If Start <= Length(Name) then
      begin
        If CheckAndSetIdentifier(Copy(Name,Start,Length(Name) - Start + 1),TempPart.PartStr) then
          TempPart.PartType := nptIdentifier
        else
          TempPart.PartType := nptInvalid;
        TempPart.PartIndex := UNS_NAME_INDEX_DEFAULT;
        CDA_Add(NameParts,TempPart);
      end;
  end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
// do sanity checks and set validity flag accordingly 
NameParts.Valid := True;
For i := CDA_Low(NameParts) to CDA_High(NameParts) do
  with CDA_GetItem(NameParts,i) do
    begin
      case PartType of
        nptInvalid:
          NameParts.Valid := False;
        nptIdentifier:;       // do nothing
        nptArrayIdentifier:   // must be followed by index or item number, or must be last
          If i < CDA_Count(NameParts) then
            NameParts.Valid := CDA_GetItem(NameParts,i + 1).PartType in
              [nptArrayIndex,nptArrayIndexSav,nptArrayIndexDef,nptArrayItem,nptArrayItemSav,nptArrayItemDef];
        nptArrayIndex,
        nptArrayIndexSav,
        nptArrayIndexDef,
        nptArrayItem,
        nptArrayItemSav,
        nptArrayItemDef:      // must be always preceded by an array identifier
          If i > CDA_Low(NameParts) then
            NameParts.Valid := CDA_GetItem(NameParts,i - 1).PartType = nptArrayIdentifier
          else
            NameParts.Valid := False;
      else
        raise EUNSException.CreateFmt('Invalid name part type (%d).',[Ord(PartType)],'UNSNameParts');
      end;
      If not NameParts.Valid then
        Break{For i};
    end;
If CDA_Count(NameParts) > 0 then
  NameParts.EndsWithIndex := CDA_Last(NameParts).PartType in [nptArrayIndex,
    nptArrayIndexSav,nptArrayIndexDef,nptArrayItem,nptArrayItemSav,nptArrayItemDef]
else
  NameParts.EndsWithIndex := False;
If NameParts.Valid then
  Result := CDA_Count(NameParts)
else
  Result := 0;
end;

//------------------------------------------------------------------------------

Function UNSIdentifyValueType(const Str: String): TUNSValueType;
var
  i:  TUNSValueType;
begin
Result := vtUndefined;
For i := Low(TUNSValueType) to High(TUNSValueType) do
  If AnsiSameText(Str,UNS_VALUETYPE_STRS[i]) then
    begin
      Result := i;
      Break{For i};
    end;
end;

{===============================================================================
    UInt64 <-> String conversions (code copied from IniFileEx library)
===============================================================================}

const
  UNS_UInt64BitTable: array[0..63] of String = (
    '00000000000000000001','00000000000000000002','00000000000000000004','00000000000000000008',
    '00000000000000000016','00000000000000000032','00000000000000000064','00000000000000000128',
    '00000000000000000256','00000000000000000512','00000000000000001024','00000000000000002048',
    '00000000000000004096','00000000000000008192','00000000000000016384','00000000000000032768',
    '00000000000000065536','00000000000000131072','00000000000000262144','00000000000000524288',
    '00000000000001048576','00000000000002097152','00000000000004194304','00000000000008388608',
    '00000000000016777216','00000000000033554432','00000000000067108864','00000000000134217728',
    '00000000000268435456','00000000000536870912','00000000001073741824','00000000002147483648',
    '00000000004294967296','00000000008589934592','00000000017179869184','00000000034359738368',
    '00000000068719476736','00000000137438953472','00000000274877906944','00000000549755813888',
    '00000001099511627776','00000002199023255552','00000004398046511104','00000008796093022208',
    '00000017592186044416','00000035184372088832','00000070368744177664','00000140737488355328',
    '00000281474976710656','00000562949953421312','00001125899906842624','00002251799813685248',
    '00004503599627370496','00009007199254740992','00018014398509481984','00036028797018963968',
    '00072057594037927936','00144115188075855872','00288230376151711744','00576460752303423488',
    '01152921504606846976','02305843009213693952','04611686018427387904','09223372036854775808');

//------------------------------------------------------------------------------    

Function UNSUInt64ToStr(Value: UInt64): String;
var
  i,j:      Integer;
  CharOrd:  Integer;
  Carry:    Integer;
begin
Result := (StringOfChar('0',Length(UNS_UInt64BitTable[0])));
Carry := 0;
For i := 0 to 63 do
  If ((Value shr i) and 1) <> 0 then
    For j := Length(Result) downto 1 do
      begin
        CharOrd := (Ord(Result[j]) - Ord('0')) + (Ord(UNS_UInt64BitTable[i][j]) - Ord('0')) + Carry;
        Carry := CharOrd div 10;
        Result[j] := Char(Ord('0') + CharOrd mod 10);
      end;
// remove leading zeroes
i := 0;
repeat
  Inc(i);
until (Result[i] <> '0') or (i >= Length(Result));
Result := Copy(Result,i,Length(Result));
end;

//------------------------------------------------------------------------------

Function UNSStrToUInt64(const Str: String): UInt64;
var
  TempStr:  String;
  ResStr:   String;
  i:        Integer;

  Function CompareValStr(const S1,S2: String): Integer;
  var
    ii: Integer;
  begin
    Result := 0;
    For ii := 1 to Length(S1) do
      If Ord(S1[ii]) < Ord(S2[ii]) then
        begin
          Result := 1;
          Break{For ii};
        end
      else If Ord(S1[ii]) > Ord(S2[ii]) then
        begin
          Result := -1;
          Break{For ii};
        end      
  end;

  Function SubtractValStr(const S1,S2: String; out Res: String): Integer;
  var
    ii:       Integer;
    CharVal:  Integer;
  begin
    SetLength(Res,Length(S1));
    Result := 0;
    For ii := Length(S1) downto 1 do
      begin
        CharVal := Ord(S1[ii]) - Ord(S2[ii]) + Result;
        If CharVal < 0 then
          begin
            CharVal := CharVal + 10;
            Result := -1;
          end
        else Result := 0;
        Res[ii] := Char(Abs(CharVal) + Ord('0'));
      end;
    If Result < 0 then
      Res := S1;  
  end;

begin
Result := 0;
// rectify string
If Length(Str) < Length(UNS_UInt64BitTable[0]) then
  TempStr := StringOfChar('0',Length(UNS_UInt64BitTable[0]) - Length(Str)) + Str
else If Length(Str) > Length(UNS_UInt64BitTable[0]) then
  raise EConvertError.CreateFmt('UNSStrToUInt64: "%s" is not a valid integer string.',[Str])
else
  TempStr := Str;
// check if string contains only numbers  
For i := 1 to Length(TempStr) do
  If not(Ord(TempStr[i]) in [Ord('0')..Ord('9')]) then
    raise EConvertError.CreateFmt('UNSStrToUInt64: "%s" is not a valid integer string.',[Str]);
For i := 63 downto 0 do
  If SubtractValStr(TempStr,UNS_UInt64BitTable[i],ResStr) >= 0 then
    If CompareValStr(ResStr,UNS_UInt64BitTable[i]) > 0 then
      begin
        Result := Result or (UInt64(1) shl i);
        TempStr := ResStr;
      end
    else raise EConvertError.CreateFmt('UNSStrToUInt64: "%s" is not a valid integer string.',[Str]);
end;

//------------------------------------------------------------------------------

Function UNSTryStrToUInt64(const Str: String; out Value: UInt64): Boolean;
begin
try
  Value := UNSStrToUInt64(Str);
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function UNSStrToUInt64Def(const Str: String; Default: UInt64): UInt64;
begin
If not UNSTryStrToUInt64(Str,Result) then
  Result := Default;
end;

end.
