{$IFNDEF Included}
unit UniSettings_NodeBuffer;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase, UniSettings_NodeLeaf;

type
  TUNSNodeBuffer = class(TUNSNodeLeaf)
  private
    fValue:         TMemoryBuffer;
    fSavedValue:    TMemoryBuffer;
    fDefaultValue:  TMemoryBuffer;
    procedure SetValue(NewValue: TMemoryBuffer);
    procedure SetDefaultValue(NewValue: TMemoryBuffer);
  protected
    class Function SameMemoryBuffers(A,B: TMemoryBuffer): Boolean; virtual;
    class Function GetValueType: TUNSValueType; override;
    Function GetValueSize: TMemSize; override;
    Function GetDefaultValueSize: TMemSize; override;
    Function ConvToStr(const Value): String; override;
    Function ConvFromStr(const Str: String): Pointer; override;
  public
    constructor Create(const Name: String; ParentNode: TUNSNodeBase);
    constructor CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    procedure Save; override;
    procedure Restore; override;
    Function Address(AccessDefVal: Boolean = False): Pointer; override;
    Function AsString(AccessDefVal: Boolean = False): String; override;
    procedure FromString(const Str: String; AccessDefVal: Boolean = False); override;
    procedure ToStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure FromStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    procedure FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    property Value: TMemoryBuffer read fValue write SetValue;
    property SavedValue: TMemoryBuffer read fSavedValue;
    property DefaultValue: TMemoryBuffer read fDefaultValue write SetDefaultValue;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect,
  UniSettings_Exceptions;

procedure TUNSNodeBuffer.SetValue(NewValue: TMemoryBuffer);
begin
If not SameMemoryBuffers(NewValue,fValue) then
  begin
    ReallocBuffer(fValue,NewValue.Size);
    Move(NewValue.Memory^,fValue.Memory^,fValue.Size);
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.SetDefaultValue(NewValue: TMemoryBuffer);
begin
If not SameMemoryBuffers(NewValue,fDefaultValue) then
  begin
    ReallocBuffer(fDefaultValue,NewValue.Size);
    Move(NewValue.Memory^,fDefaultValue.Memory^,fDefaultValue.Size);
    DoChange;
  end;
end;

//==============================================================================

class Function TUNSNodeBuffer.SameMemoryBuffers(A,B: TMemoryBuffer): Boolean;
var
  i:      TMemSize;
  ABuff:  PByte;
  BBuff:  PByte;
begin
If A.Size = B.Size then
  begin
    ABuff := A.Memory;
    BBuff := B.Memory;
    Result := True;
    If A.Size > 0 then
      begin
        For i := 0 to Pred(A.Size) do
          If ABuff^ = BBuff^ then
            begin
              Inc(ABuff);
              Inc(BBuff);
            end
          else
            begin
              Result := False;
              Break{For i};
            end;
      end;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

class Function TUNSNodeBuffer.GetValueType: TUNSValueType;
begin
Result := vtBuffer;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.GetValueSize: TMemSize;
begin
Result := fValue.Size;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.GetDefaultValueSize: TMemSize;
begin
Result := fDefaultValue.Size;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.ConvToStr(const Value): String;
begin
Result := '';
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.ConvFromStr(const Str: String): Pointer;
begin
Result := nil;
end;

//==============================================================================

constructor TUNSNodeBuffer.Create(const Name: String; ParentNode: TUNSNodeBase);
begin
inherited Create(Name,ParentNode);
FillChar(fValue,SizeOf(TMemoryBuffer),0);
FillChar(fSavedValue,SizeOf(TMemoryBuffer),0);
FillChar(fDefaultValue,SizeOf(TMemoryBuffer),0);
end;

//------------------------------------------------------------------------------

constructor TUNSNodeBuffer.CreateAsCopy(Source: TUNSNodeBase; const Name: String; ParentNode: TUNSNodeBase);
begin
inherited CreateAsCopy(Source,Name,ParentNode);
ReallocBuffer(fValue,TUNSNodeBuffer(Source).Value.Size);
Move(TUNSNodeBuffer(Source).Value.Memory^,fValue.Memory^,fValue.Size);
ReallocBuffer(fSavedValue,TUNSNodeBuffer(Source).SavedValue.Size);
Move(TUNSNodeBuffer(Source).SavedValue.Memory^,fSavedValue.Memory^,fSavedValue.Size);
ReallocBuffer(fDefaultValue,TUNSNodeBuffer(Source).DefaultValue.Size);
Move(TUNSNodeBuffer(Source).DefaultValue.Memory^,fDefaultValue.Memory^,fDefaultValue.Size);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.ActualFromDefault;
begin
If not ActualEqualsDefault then
  begin
    ReallocBuffer(fValue,fDefaultValue.Size);
    Move(fDefaultValue.Memory^,fValue.Memory^,fValue.Size);
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.DefaultFromActual;
begin
If not ActualEqualsDefault then
  begin
    ReallocBuffer(fDefaultValue,fValue.Size);
    Move(fValue.Memory^,fDefaultValue.Memory^,fDefaultValue.Size);
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.ExchangeActualAndDefault;
var
  Temp: TMemoryBuffer;
begin
If not ActualEqualsDefault then
  begin
    // no need to copy the memory, just exchange buffer objects
    Temp := fDefaultValue;
    fDefaultValue := fValue;
    fValue := Temp;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.ActualEqualsDefault: Boolean;
begin
Result := SameMemoryBuffers(fValue,fDefaultValue);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.Save;
begin
ReallocBuffer(fSavedValue,fValue.Size);
Move(fValue.Memory^,fSavedValue.Memory^,fSavedValue.Size);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.Restore;
begin
SetValue(fSavedValue);
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.Address(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := fDefaultValue.Memory
else
  Result := fValue.Memory;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.AsString(AccessDefVal: Boolean = False): String;
var
  WorkBuff: TMemoryBuffer;
  i:        TMemSize;
  TempStr:  String;
begin
If AccessDefVal then
  WorkBuff := fDefaultValue
else
  WorkBuff := fValue;
If WorkBuff.Size > 0 then
  begin
    SetLength(Result,WorkBuff.Size * 2);
    For i := 0 to Pred(WorkBuff.Size) do
      begin
        TempStr := IntToHex(PByte(PtrUInt(WorkBuff.Memory) + PtrUInt(i))^,2);
        Result[(i * 2) + 1] := TempStr[1];
        Result[(i * 2) + 2] := TempStr[2];
      end;
  end
else Result := '';
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.FromString(const Str: String; AccessDefVal: Boolean = False);
var
  TempSize: TMemSize;
  i:        TMemSize;
  TempPtr:  PByte;
begin
TempSize := TMemSize(Length(Str) div 2);
If AccessDefVal then
  begin
    ReallocBuffer(fDefaultValue,TempSize);
    TempPtr := fDefaultValue.Memory;
  end
else
  begin
    ReallocBuffer(fValue,TempSize);
    TempPtr := fValue.Memory;
  end;
For i := 0 to Pred(TempSize) do
  begin
    TempPtr^ := Byte(StrToInt('$' + Copy(Str,(i * 2) + 1,2)));
    Inc(TempPtr);
  end;
DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.ToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteBuffer(Stream,fDefaultValue.Memory^,fDefaultValue.Size)
else
  Stream_WriteBuffer(Stream,fValue.Memory^,fValue.Size);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.FromStream(Stream: TStream; AccessDefVal: Boolean = False);
var
  TempSize: TMemSize;
begin
TempSize := TMemSize(Stream.Size - Stream.Position);
If AccessDefVal then
  begin
    ReallocBuffer(fDefaultValue,TempSize);
    Stream_ReadBuffer(Stream,fDefaultValue.Memory^,fDefaultValue.Size);
  end
else
  begin
    ReallocBuffer(fValue,TempSize);
    Stream_ReadBuffer(Stream,fValue.Memory^,fValue.Size);
  end;
DoChange;
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.ToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= ObtainValueSize(AccessDefVal) then
  begin
    If AccessDefVal then
      Ptr_WriteBuffer(Buffer.Memory,fDefaultValue.Memory^,fDefaultValue.Size)
    else
      Ptr_WriteBuffer(Buffer.Memory,fValue.Memory^,fValue.Size);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.FromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  begin
    ReallocBuffer(fDefaultValue,Buffer.Size);
    Ptr_ReadBuffer(Buffer.Memory,fDefaultValue.Memory^,fDefaultValue.Size);
  end
else
  begin
    ReallocBuffer(fValue,Buffer.Size);
    Ptr_ReadBuffer(Buffer.Memory,fValue.Memory^,fValue.Size);
  end;
DoChange;
end;

{$WARNINGS OFF} // supresses warnings on lines after the final end
end.

{$ELSE Included}

{$WARNINGS ON}

{$IFDEF Included_Declaration}
    Function BufferValueGet(const ValueName: String; CreateCopy: Boolean = True; AccessDefVal: Boolean = False): TMemoryBuffer; virtual;
    procedure BufferValueSet(const ValueName: String; NewValue: TMemoryBuffer; CreateCopy: Boolean = True; AccessDefVal: Boolean = False); virtual;
{$ENDIF}

//==============================================================================

{$IFDEF Included_Implementation}

Function TUniSettings.BufferValueGet(const ValueName: String; CreateCopy: Boolean = True; AccessDefVal: Boolean = False): TMemoryBuffer;
var
  Temp: TMemoryBuffer;
begin
ReadLock;
try
  with TUNSNodeBuffer(CheckedLeafNodeTypeAccess(ValueName,vtBuffer,'BufferValueGet')) do
    If AccessDefVal then
      Temp := Value
    else
      Temp := DefaultValue;
  If CreateCopy then
    CopyBuffer(Temp,Result)
  else
    Result := Temp;
finally
  ReadUnlock;
end;
end;

//------------------------------------------------------------------------------

procedure TUniSettings.BufferValueSet(const ValueName: String; NewValue: TMemoryBuffer; CreateCopy: Boolean = True; AccessDefVal: Boolean = False);
var
  Temp: TMemoryBuffer;
begin
WriteLock;
try
  If CreateCopy then
    CopyBuffer(NewValue,Temp)
  else
    Temp := NewValue;
  with TUNSNodeBuffer(CheckedLeafNodeTypeAccess(ValueName,vtBuffer,'BufferValueSet')) do
    If AccessDefVal then
      Value := Temp
    else
      DefaultValue := Temp;
finally
  WriteUnlock;
end;
end;

{$ENDIF}

{$ENDIF Included}
