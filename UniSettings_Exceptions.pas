unit UniSettings_Exceptions;

{$INCLUDE '.\UniSettings_defs.inc'}

interface

uses
  SysUtils,
  MemoryBuffer;

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

end.
