unit UniSettings_Utils;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  UniSettings_Common;

Function UNSSameHashString(A,B: TUNSHashedString; FullEval: Boolean = False): Boolean;

procedure UNSHashString(var HashStr: TUNSHashedString);

Function UNSHashedString(const Str: String): TUNSHashedString;

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

end.
