unit UniSettings_Utils;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils,
  UniSettings_Common;

Function UNSCharInSet(C: Char; CharSet: TSysCharSet): Boolean;

Function UNSIsValidIdentifier(const Identifier: String): Boolean;

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
Result := True;
If Length(Identifier) > 0 then
  begin
    For i := 1 to Length(Identifier) do
      If not UNSCharInSet(Identifier[i],UNS_PATH_IDENTIFIER_VALIDCHARS) then
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
      UNS_PATH_BRACKET_RIGHT:     Result := Prev = UNS_PATH_BRACKET_LEFT;
      UNS_PATH_BRACKETDEF_RIGHT:  Result := Prev = UNS_PATH_BRACKETDEF_LEFT;
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
    PrevDelimiter := UNS_PATH_DELIMITER; 
    while i <= Length(Name) do
      begin
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
        If UNSCharInSet(Name[i],UNS_PATH_DELIMITERS) then
          with NameParts do
            begin
              // last part was an (array) identifier
              GrowPartsArray;
              If CheckAndSetIdentifier(Copy(Name,Start,i - Start),Arr[Count].PartName) then
                begin
                  If Name[i] <> UNS_PATH_DELIMITER then
                    Arr[Count].PartType := vptArrayIdentifier
                  else
                    Arr[Count].PartType := vptIdentifier;
                end
              else Arr[Count].PartType := vptInvalid;
              Arr[Count].PartIndex := UNS_PATH_INDEX_DEFAULT;
              PrevDelimiter := Name[i];
              Start := i + 1;
              Inc(Count);
            end
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
        else If UNSCharInSet(Name[i],UNS_PATH_BRACKETS_RIGHT) then
          with NameParts do
            begin
              // last part was in brackets, index or item number
              GrowPartsArray;
              If CheckDelimiters(PrevDelimiter,Name[i]) then
                begin
                  If Name[Start] = UNS_PATH_ARRAYITEM_TAG then
                    begin
                      // there is item number in the brackets
                      If Name[i] = UNS_PATH_BRACKETDEF_RIGHT then
                        Arr[Count].PartType := vptArrayItemDef
                      else
                        Arr[Count].PartType := vptArrayItem;
                      // resolve to item number (not index!)
                      If (i - Start) = 2 then
                        case Name[Start + 1] of
                          '0','N','n':  Arr[Count].PartIndex := UNS_PATH_ARRAYITEM_NEW;
                          '1','L','l':  Arr[Count].PartIndex := UNS_PATH_ARRAYITEM_LOW;
                          '2','H','h':  Arr[Count].PartIndex := UNS_PATH_ARRAYITEM_HIGH;
                        else
                          Arr[Count].PartType := vptInvalid;
                        end
                      else Arr[Count].PartType := vptInvalid;
                    end
                  else
                    begin
                      // there is item index in the brackets
                      If TryStrToInt(Copy(Name,Start,i - Start),Arr[Count].PartIndex) then
                        begin
                          If Name[i] = UNS_PATH_BRACKETDEF_RIGHT then
                            Arr[Count].PartType := vptArrayIndexDef
                          else
                            Arr[Count].PartType := vptArrayIndex;
                        end
                      else Arr[Count].PartType := vptInvalid;
                    end;
                end
              else
                begin
                  // wrong delimiter
                  Arr[Count].PartType := vptInvalid;
                  Arr[Count].PartIndex := UNS_PATH_INDEX_DEFAULT;
                end;
              Arr[Count].PartName := UNSHashedString(Copy(Name,Start,i - Start));
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
          If CheckAndSetIdentifier(Copy(Name,Start,Length(Name) - Start + 1),Arr[Count].PartName) then
            Arr[Count].PartType := vptIdentifier
          else
            Arr[Count].PartType := vptInvalid;
          Arr[Count].PartIndex := UNS_PATH_INDEX_DEFAULT;
          Inc(Count);
        end;
  end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
// do sanity checks and set validity flag accordingly 
NameParts.Valid := True;
For i := Low(NameParts.Arr) to Pred(NameParts.Count) do
  begin
    case NameParts.Arr[i].PartType of
      vptInvalid:
        NameParts.Valid := False;
      vptIdentifier:;       // do nothing
      vptArrayIdentifier:   // must be followed by index or item number, or must be last
        If i < Pred(NameParts.Count) then
          NameParts.Valid := NameParts.Arr[i + 1].PartType in
            [vptArrayIndex,vptArrayIndexDef,vptArrayItem,vptArrayItemDef];
      vptArrayIndex,
      vptArrayIndexDef,
      vptArrayItem,
      vptArrayItemDef:      // must be always preceded by an array identifier
        If i > Low(NameParts.Arr) then
          NameParts.Valid := NameParts.Arr[i - 1].PartType = vptArrayIdentifier
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
