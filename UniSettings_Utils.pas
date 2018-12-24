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

Function UNSSameHashString(A,B: TUNSHashedString; FullEval: Boolean = True): Boolean;

procedure UNSHashString(var HashStr: TUNSHashedString);

Function UNSHashedString(const Str: String): TUNSHashedString;

Function UNSNameParts(const Name: String; out NameParts: TUNSNameParts): Integer;

Function UNSIdentifyValueType(const Str: String): TUNSValueType;

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

Function UNSSameHashString(A,B: TUNSHashedString; FullEval: Boolean = True): Boolean;
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

end.
