unit UniSettings_NodeLeaf;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils, Classes,
  AuxTypes, MemoryBuffer,
  UniSettings_Common, UniSettings_NodeBase;

type
  TUNSNodeLeaf = class(TUNSNodeBase)
  protected
    class Function SameValues(const A,B): Boolean; virtual; abstract;
    class Function GetNodeClass: TUNSNodeClass; override;
    Function GetValueSize: TMemSize; virtual; abstract;
    Function GetSavedValueSize: TMemSize; virtual; abstract;
    Function GetDefaultValueSize: TMemSize; virtual; abstract;
    Function ObtainValueSize(ValueKind: TUNSValueKind): TMemSize; virtual;
    Function ConvToStr(const Value): String; virtual; abstract;
    Function ConvFromStr(const Str: String): Pointer; virtual; abstract;    
  public
    class Function IsPrimitiveArray: Boolean; virtual;
    Function NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean; virtual;
    Function Address(ValueKind: TUNSValueKind = vkActual): Pointer; overload; virtual; abstract;
    Function AsString(ValueKind: TUNSValueKind = vkActual): String; overload; virtual; abstract;
    procedure FromString(const Str: String; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    procedure ToStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    procedure FromStream(Stream: TStream; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    Function AsStream(ValueKind: TUNSValueKind = vkActual): TMemoryStream; overload; virtual;
    procedure ToBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    procedure FromBuffer(Buffer: TMemoryBuffer; ValueKind: TUNSValueKind = vkActual); overload; virtual; abstract;
    Function AsBuffer(ValueKind: TUNSValueKind = vkActual): TMemoryBuffer; overload; virtual;
    property ValueSize: TMemSize read GetValueSize;
    property SsvedValueSize: TMemSize read GetSavedValueSize;
    property DefaultValueSize: TMemSize read GetDefaultValueSize;
  end;

implementation

uses
  UniSettings_Exceptions;

class Function TUNSNodeLeaf.GetNodeClass: TUNSNodeClass;
begin
Result := ncLeaf;
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.ObtainValueSize(ValueKind: TUNSValueKind): TMemSize;
begin
case ValueKind of
  vkActual:   Result := GetValueSize;
  vkSaved:    Result := GetSavedValueSize;
  vkDefault:  Result := GetDefaultValueSize;
else
  raise EUNSInvalidValueKindException.Create(ValueKind,Self,'ObtainValueSize');
end;
end;

//==============================================================================

class Function TUNSNodeLeaf.IsPrimitiveArray: Boolean;
begin
Result := False;
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.NodeEquals(Node: TUNSNodeLeaf; CompareValueKinds: TUNSValueKinds = [vkActual]): Boolean;
begin
Result := Self is Node.ClassType;
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.AsStream(ValueKind: TUNSValueKind = vkActual): TMemoryStream;
begin
Result := TMemoryStream.Create;
ToStream(Result,ValueKind);
end;

//------------------------------------------------------------------------------

Function TUNSNodeLeaf.AsBuffer(ValueKind: TUNSValueKind = vkActual): TMemoryBuffer;
begin
GetBuffer(Result,ObtainValueSize(ValueKind));
ToBuffer(Result,ValueKind);
end;

end.
