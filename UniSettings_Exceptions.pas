unit UniSettings_Exceptions;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils,
  MemoryBuffer,
  UniSettings_Common;

type
  EUNSException = class(Exception)
  public
    constructor Create(const Msg, FaultingFunction: String); overload;
    constructor Create(const Msg: String; FaultingObject: TObject; const FaultingMethod: String); overload;
    constructor CreateFmt(const Msg: String; Args: array of const; const FaultingFunction: String); overload;
    constructor CreateFmt(const Msg: String; Args: array of const; FaultingObject: TObject; const FaultingMethod: String); overload;
  end;

  EUNSIndexOutOfBoundsException = class(EUNSException)
  private
    fIndex: Integer;
  public
    constructor Create(Index: Integer; const FaultingFunction: String); overload;
    constructor Create(Index: Integer; FaultingObject: TObject; const FaultingMethod: String); overload;
    property Index: Integer read fIndex;
  end;

  EUNSBufferTooSmallException = class(EUNSException)
  public
    constructor Create(Buffer: TMemoryBuffer; const FaultingFunction: String); overload;
    constructor Create(Buffer: TMemoryBuffer; FaultingObject: TObject; const FaultingMethod: String); overload;
  end;

  EUNSValueNotFoundException = class(EUNSException)
  public
    constructor Create(const ValueName: String; const FaultingFunction: String); overload;
    constructor Create(const ValueName: String; FaultingObject: TObject; const FaultingMethod: String); overload;
  end;

  EUNSValueTypeNotFoundException = class(EUNSException)
  public
    constructor Create(const ValueName: String; ValueType: TUNSValueType; const FaultingFunction: String); overload;
    constructor Create(const ValueName: String; ValueType: TUNSValueType; FaultingObject: TObject; const FaultingMethod: String); overload;
  end;

  EUNSValueNotAnArrayException = class(EUNSException)
  public
    constructor Create(const ValueName: String; const FaultingFunction: String); overload;
    constructor Create(const ValueName: String; FaultingObject: TObject; const FaultingMethod: String); overload;
  end;

  EUNSParsingException = class(EUNSException)
  private
    fLine:  String;
  public
    constructor Create(const Msg: String; FaultingObject: TObject; const FaultingMethod, Line: String); overload;
    constructor CreateFmt(const Msg: String; Args: array of const; FaultingObject: TObject; const FaultingMethod, Line: String); overload;
    property Line: String read fLine;
  end;

implementation

constructor EUNSException.Create(const Msg, FaultingFunction: String);
begin
inherited CreateFmt('%s: %s',[FaultingFunction,Msg]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor EUNSException.Create(const Msg: String; FaultingObject: TObject; const FaultingMethod: String);
begin
inherited CreateFmt('%s(%p).%s: %s',[FaultingObject.ClassName,Pointer(FaultingObject),FaultingMethod,Msg]);
end;


//------------------------------------------------------------------------------

constructor EUNSException.CreateFmt(const Msg: String; Args: array of const; const FaultingFunction: String);
begin
Create(Format(Msg,Args),FaultingFunction);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor EUNSException.CreateFmt(const Msg: String; Args: array of const; FaultingObject: TObject; const FaultingMethod: String);
begin
Create(Format(Msg,Args),FaultingObject,FaultingMethod);
end;

//******************************************************************************

constructor EUNSIndexOutOfBoundsException.Create(Index: Integer; const FaultingFunction: String);
begin
inherited CreateFmt('Index (%d) out of bounds.',[Index],Faultingfunction);
fIndex := Index;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor EUNSIndexOutOfBoundsException.Create(Index: Integer; FaultingObject: TObject; const FaultingMethod: String);
begin
inherited CreateFmt('Index (%d) out of bounds.',[Index],FaultingObject,FaultingMethod);
fIndex := Index;
end;

//******************************************************************************

constructor EUNSBufferTooSmallException.Create(Buffer: TMemoryBuffer; const FaultingFunction: String);
begin
inherited CreateFmt('Provided buffer is too small (%dB).',[Buffer.Size],FaultingFunction);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor EUNSBufferTooSmallException.Create(Buffer: TMemoryBuffer; FaultingObject: TObject; const FaultingMethod: String);
begin
inherited CreateFmt('Provided buffer is too small (%dB).',[Buffer.Size],FaultingObject,FaultingMethod);
end;

//******************************************************************************

constructor EUNSValueNotFoundException.Create(const ValueName: String; const FaultingFunction: String);
begin
inherited CreateFmt('Value (%s) not found.',[ValueName],FaultingFunction);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor EUNSValueNotFoundException.Create(const ValueName: String; FaultingObject: TObject; const FaultingMethod: String);
begin
inherited CreateFmt('Value (%s) not found.',[ValueName],FaultingObject,FaultingMethod);
end;

//******************************************************************************

constructor EUNSValueTypeNotFoundException.Create(const ValueName: String; ValueType: TUNSValueType; const FaultingFunction: String);
begin
inherited CreateFmt('Value (%s) of type %s not found.',
  [ValueName,UNS_VALUETYPE_STRS[ValueType]],FaultingFunction);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor EUNSValueTypeNotFoundException.Create(const ValueName: String; ValueType: TUNSValueType; FaultingObject: TObject; const FaultingMethod: String);
begin
inherited CreateFmt('Value (%s) of type %s not found.',
  [ValueName,UNS_VALUETYPE_STRS[ValueType]],FaultingObject,FaultingMethod);
end;

//******************************************************************************

constructor EUNSValueNotAnArrayException.Create(const ValueName: String; const FaultingFunction: String);
begin
inherited CreateFmt('Value (%s) is not an array.',[ValueName],FaultingFunction);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor EUNSValueNotAnArrayException.Create(const ValueName: String; FaultingObject: TObject; const FaultingMethod: String);
begin
inherited CreateFmt('Value (%s) is not an array.',[ValueName],FaultingObject,FaultingMethod);
end;

//******************************************************************************

constructor EUNSParsingException.Create(const Msg: String; FaultingObject: TObject; const FaultingMethod, Line: String);
begin
inherited Create(Msg,FaultingObject,FaultingMethod);
fLine := Line;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor EUNSParsingException.CreateFmt(const Msg: String; Args: array of const; FaultingObject: TObject; const FaultingMethod, Line: String);
begin
inherited CreateFmt(Msg,Args,FaultingObject,FaultingMethod);
fLine := Line;
end;

end.
