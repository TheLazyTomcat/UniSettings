unit UniSettings_NodeBuffer;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeLeaf;

type
  TUNSNodeBuffer = class(TUNSNodeLeaf)
  private
    fValue:         TMemoryBuffer;
    fDefaultValue:  TMemoryBuffer;
    procedure SetValue(NewValue: TMemoryBuffer);
    procedure SetDefaultValue(NewValue: TMemoryBuffer);
  protected
    class Function SameMemoryBuffers(A,B: TMemoryBuffer): Boolean; virtual;
    class Function GetNodeDataType: TUNSNodeDataType; override;
    Function GetValueSize(AccessDefVal: Integer): TMemSize; override;
    Function ConvToStr(const Value): String; override;
    Function ConvFromStr(const Str: String): Pointer; override;
  public
    procedure ActualFromDefault; override;
    procedure DefaultFromActual; override;
    procedure ExchangeActualAndDefault; override;
    Function ActualEqualsDefault: Boolean; override;
    Function GetValueAddress(AccessDefVal: Boolean = False): Pointer; override;
    Function GetValueAsString(AccessDefVal: Boolean = False): String; override;
    procedure SetValueFromString(const Str: String; AccessDefVal: Boolean = False); override;
    procedure GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False); override;
    procedure GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    procedure SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False); override;
    property Value: TMemoryBuffer read fValue write SetValue;
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

class Function TUNSNodeBuffer.GetNodeDataType: TUNSNodeDataType;
begin
Result := ndtBuffer;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.GetValueSize(AccessDefVal: Integer): TMemSize;
begin
If AccessDefVal <> 0 then
  Result := fDefaultValue.Size
else
  Result := fValue.Size;
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

Function TUNSNodeBuffer.GetValueAddress(AccessDefVal: Boolean = False): Pointer;
begin
If AccessDefVal then
  Result := fDefaultValue.Memory
else
  Result := fValue.Memory;
end;

//------------------------------------------------------------------------------

Function TUNSNodeBuffer.GetValueAsString(AccessDefVal: Boolean = False): String;
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

procedure TUNSNodeBuffer.SetValueFromString(const Str: String; AccessDefVal: Boolean = False);
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

procedure TUNSNodeBuffer.GetValueToStream(Stream: TStream; AccessDefVal: Boolean = False);
begin
If AccessDefVal then
  Stream_WriteBuffer(Stream,fDefaultValue.Memory^,fDefaultValue.Size)
else
  Stream_WriteBuffer(Stream,fValue.Memory^,fValue.Size);
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.SetValueFromStream(Stream: TStream; AccessDefVal: Boolean = False);
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

procedure TUNSNodeBuffer.GetValueToBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
begin
If Buffer.Size >= GetValueSize(Ord(AccessDefVal)) then
  begin
    If AccessDefVal then
      Ptr_WriteBuffer(Buffer.Memory,fDefaultValue.Memory^,fDefaultValue.Size)
    else
      Ptr_WriteBuffer(Buffer.Memory,fValue.Memory^,fValue.Size);
  end
else raise EUNSBufferTooSmallException.Create(Buffer,Self,'GetValueToBuffer');
end;

//------------------------------------------------------------------------------

procedure TUNSNodeBuffer.SetValueFromBuffer(Buffer: TMemoryBuffer; AccessDefVal: Boolean = False);
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

end.
