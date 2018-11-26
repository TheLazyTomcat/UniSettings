unit UniSettings_Utils;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils,
  UniSettings_Common;

Function UNSCharInSet(C: Char; CharSet: TSysCharSet): Boolean;

Function UNSIsValidIdentifier(const Identifier: String): Boolean;

Function UNSIsValidName(const Name: String): Boolean;

Function UNSSameHashString(A,B: TUNSHashedString; FullEval: Boolean = False): Boolean;

procedure UNSHashString(var HashStr: TUNSHashedString);

Function UNSHashedString(const Str: String): TUNSHashedString;

Function UNSNameParts(const Name: String; out NameParts: TUNSNameParts): Integer;

implementation

uses
  StrUtils,
  CRC32,
  UniSettings_Exceptions;

Function UNSCharInSet(C: Char; CharSet: TSysCharSet): Boolean;
begin
{$IF SizeOf(Char) > 1}
If Ord(C) > 255 then
  Result := False
else
{$IFEND}
  Result := C in CharSet
end;

//------------------------------------------------------------------------------

Function UNSIsValidIdentifier(const Identifier: String): Boolean;
var
  i:  Integer;
begin
If Length(Identifier) > 0 then
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
Result := SameCRC32(A.Hash,B.Hash) and (not FullEval or AnsiSameText(A.Str,B.Str));
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
  i:              Integer;
  Start:          Integer;
  PrevDelimiter:  Char;

  procedure GrowPartsArray;
  begin
    If Length(NameParts.Arr) <= NameParts.Count then
      SetLength(NameParts.Arr,Length(NameParts.Arr) + 8);
  end;

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
      UNS_NAME_BRACKETDEF_RIGHT:  Result := Prev = UNS_NAME_BRACKETDEF_LEFT;
    else
      Result := True;
    end;
  end;

begin
NameParts.Count := 0;
If Length(Name) > 0 then
  begin
    Start := 1;
    i := 1;
    PrevDelimiter := UNS_NAME_DELIMITER; 
    while i <= Length(Name) do
      begin
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
        If UNSCharInSet(Name[i],UNS_NAME_DELIMITERS) then
          with NameParts do
            begin
              // last part was an (array) identifier
              GrowPartsArray;
              If CheckAndSetIdentifier(Copy(Name,Start,i - Start),Arr[Count].PartStr) then
                begin
                  If Name[i] <> UNS_NAME_DELIMITER then
                    Arr[Count].PartType := nptArrayIdentifier
                  else
                    Arr[Count].PartType := nptIdentifier;
                end
              else Arr[Count].PartType := nptInvalid;
              Arr[Count].PartIndex := UNS_NAME_INDEX_DEFAULT;
              PrevDelimiter := Name[i];
              Start := i + 1;
              Inc(Count);
            end
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
        else If UNSCharInSet(Name[i],UNS_NAME_BRACKETS_RIGHT) then
          with NameParts do
            begin
              // last part was in brackets, index or item number
              GrowPartsArray;
              If CheckDelimiters(PrevDelimiter,Name[i]) then
                begin
                  If Name[Start] = UNS_NAME_ARRAYITEM_TAG then
                    begin
                      // there is item number in the brackets
                      If Name[i] = UNS_NAME_BRACKETDEF_RIGHT then
                        Arr[Count].PartType := nptArrayItemDef
                      else
                        Arr[Count].PartType := nptArrayItem;
                      // resolve to item number (not index!)
                      If (i - Start) = 2 then
                        case Name[Start + 1] of
                          '0','N','n':  Arr[Count].PartIndex := UNS_NAME_ARRAYITEM_NEW;
                          '1','L','l':  Arr[Count].PartIndex := UNS_NAME_ARRAYITEM_LOW;
                          '2','H','h':  Arr[Count].PartIndex := UNS_NAME_ARRAYITEM_HIGH;
                        else
                          Arr[Count].PartType := nptInvalid;
                        end
                      else Arr[Count].PartType := nptInvalid;
                    end
                  else
                    begin
                      // there is item index in the brackets
                      If TryStrToInt(Copy(Name,Start,i - Start),Arr[Count].PartIndex) then
                        begin
                          If Name[i] = UNS_NAME_BRACKETDEF_RIGHT then
                            Arr[Count].PartType := nptArrayIndexDef
                          else
                            Arr[Count].PartType := nptArrayIndex;
                        end
                      else Arr[Count].PartType := nptInvalid;
                    end;
                end
              else
                begin
                  // wrong delimiter
                  Arr[Count].PartType := nptInvalid;
                  Arr[Count].PartIndex := UNS_NAME_INDEX_DEFAULT;
                end;
              Arr[Count].PartStr := UNSHashedString(Copy(Name,Start,i - Start));
              PrevDelimiter := Name[i];
              Start := i + 2; // delimiter is expected after the closing bracket
              Inc(Count);
              Inc(i);
            end;
        Inc(i);
      end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
    // process last part if present (must be identifier, nothing else is allowed)
    If Start <= Length(Name) then
      with NameParts do
        begin
          GrowPartsArray;
          If CheckAndSetIdentifier(Copy(Name,Start,Length(Name) - Start + 1),Arr[Count].PartStr) then
            Arr[Count].PartType := nptIdentifier
          else
            Arr[Count].PartType := nptInvalid;
          Arr[Count].PartIndex := UNS_NAME_INDEX_DEFAULT;
          Inc(Count);
        end;
  end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
// do sanity checks and set validity flag accordingly 
NameParts.Valid := True;
For i := Low(NameParts.Arr) to Pred(NameParts.Count) do
  begin
    case NameParts.Arr[i].PartType of
      nptInvalid:
        NameParts.Valid := False;
      nptIdentifier:;       // do nothing
      nptArrayIdentifier:   // must be followed by index or item number, or must be last
        If i < Pred(NameParts.Count) then
          NameParts.Valid := NameParts.Arr[i + 1].PartType in
            [nptArrayIndex,nptArrayIndexDef,nptArrayItem,nptArrayItemDef];
      nptArrayIndex,
      nptArrayIndexDef,
      nptArrayItem,
      nptArrayItemDef:      // must be always preceded by an array identifier
        If i > Low(NameParts.Arr) then
          NameParts.Valid := NameParts.Arr[i - 1].PartType = nptArrayIdentifier
        else
          NameParts.Valid := False;
    else
      raise EUNSException.CreateFmt('Invalid name part type (%d).',[Ord(NameParts.Arr[i].PartType)],'UNSNameParts');
    end;
    If not NameParts.Valid then
      Break{For i};
  end;
If NameParts.Valid then
  Result := NameParts.Count
else
  Result := 0;
end;

end.
