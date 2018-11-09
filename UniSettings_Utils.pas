unit UniSettings_Utils;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_Common;

Function UNSSameHashString(A,B: TUNSHashedString; FullEval: Boolean = False): Boolean;

procedure UNSHashString(var HashStr: TUNSHashedString);

Function UNSHashedString(const Str: String): TUNSHashedString;

Function UNSValueNameParts(const ValueName: String; out ValueNameParts: TUNSValueNameParts): Integer;

implementation

uses
  SysUtils,
  CRC32;

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

Function UNSValueNameParts(const ValueName: String; out ValueNameParts: TUNSValueNameParts): Integer;
var
  i:      Integer;
  Start:  Integer;

  procedure GrowArray;
  begin
    If Length(ValueNameParts.Arr) <= ValueNameParts.Count then
      SetLength(ValueNameParts.Arr,Length(ValueNameParts.Arr) + 8);
  end;

begin
ValueNameParts.Count := 0;
If Length(ValueName) > 0 then
  begin
    Start := 1;
    i := 1;
    while i <= Length(ValueName) do
      begin
        If (ValueName[i] = '.') or (ValueName[i] = '[') then
          begin
            GrowArray;
            ValueNameParts.Arr[ValueNameParts.Count].PartType := vptName;
            ValueNameParts.Arr[ValueNameParts.Count].PartName :=
              UNSHashedString(Copy(ValueName,Start,i - Start));
            ValueNameParts.Arr[ValueNameParts.Count].PartIndex := -1;
            Start := i + 1;
            Inc(ValueNameParts.Count);
          end
        else If ValueName[i] = ']' then
          begin
            GrowArray;
            ValueNameParts.Arr[ValueNameParts.Count].PartType := vptIndex;
            ValueNameParts.Arr[ValueNameParts.Count].PartName := UNSHashedString('');
            ValueNameParts.Arr[ValueNameParts.Count].PartIndex :=
              StrToIntDef(Copy(ValueName,Start,i - Start),-1);
            Start := i + 2;
            Inc(ValueNameParts.Count);
            Inc(i);
          end;
        Inc(i);
      end;
    If Start <= Length(ValueName) then
      begin
        GrowArray;
        ValueNameParts.Arr[ValueNameParts.Count].PartType := vptName;
        ValueNameParts.Arr[ValueNameParts.Count].PartName :=
          UNSHashedString(Copy(ValueName,Start,Length(ValueName) - Start + 1));
        ValueNameParts.Arr[ValueNameParts.Count].PartIndex := -1;
        Inc(ValueNameParts.Count);
      end;
    If ValueNameParts.Count > 1 then
      If (ValueNameParts.Arr[ValueNameParts.Count - 1].PartType = vptIndex) and
        (ValueNameParts.Arr[ValueNameParts.Count - 2].PartType = vptName) then
        begin
          ValueNameParts.Arr[ValueNameParts.Count - 2].PartType := vptBoth;
          ValueNameParts.Arr[ValueNameParts.Count - 2].PartIndex :=
            ValueNameParts.Arr[ValueNameParts.Count - 1].PartIndex;
          Dec(ValueNameParts.Count);
        end;
  end;
Result := ValueNameParts.Count;
end;

end.
