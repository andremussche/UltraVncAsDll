{$OPTIMIZATION OFF}
unit VncViewerAsDll;

interface

uses
  SysUtils,
  Windows;

const
  C_MAX_PATH = 260;

type
  PVNCOptionsStruct = ^TVNCOptionsStruct;

  THandleProcedure = procedure(aHandle: THandle);stdcall;

  TVncViewerAsDll = class
  protected
    class var
      FDll: THandle;
      FStarted: Boolean;
  public
    class function Load    : Boolean;
    class function UnLoad  : Boolean;
    class function IsLoaded: Boolean;

    class function VncViewerDll_Init           (aInstance: LongWord): Integer;
    class function VncViewerDll_GetOptions     (aStruct: PVNCOptionsStruct): Integer;
    class function VncViewerDll_SetOptions     (aStruct: PVNCOptionsStruct): Integer;
    //
    class function VncViewerDll_NewConnection  (aHost: PAnsiChar; aPort: Integer = 5900): THandle;
    class function VncViewerDll_ToolbarHandle: THandle;
    class function VncViewerDll_ToolbarWindow: THandle;

    class function VncViewerDll_CloseConnection(aConnectionWindow: THandle): Integer;
    //
    class procedure VncViewerDll_SetWindowSizedCallback(aCallback: THandleProcedure);
  end;

  TVNCOptionsStruct = record
    // process options
    m_listening : Boolean;
    m_listenPort : Integer;
    m_connectionSpecified: Boolean;
    m_configSpecified : Boolean;
    m_cmdlnUser: array[0..256-1] of AnsiChar; // act: add user option on command line
    m_clearPassword: array[0..256-1] of AnsiChar; // Modif sf@2002
    m_quickoption : Integer     ; // Modif sf@2002 - v1.1.2
    m_configFilename: array[0..C_MAX_PATH-1] of AnsiChar;
    m_restricted : Boolean;

    // default connection options - can be set through Dialog
    m_ViewOnly : Boolean;
    m_NoStatus : Boolean;
    m_NoHotKeys : Boolean;
    m_FullScreen : Boolean;
    m_Directx : Boolean;
    m_ShowToolbar : Boolean;

    autoDetect : Boolean;
    m_Use8Bit : Integer;	// sf@2005 - Now has 7 possible values (defines in rfbproto.h file)
              // 0 : Full colors
              // 1 : 256 colors
              // 2 : 64 colors
              // 3 : 8 colors
              // 4 : 8 Grey colors
              // 5 : 4 colors
              // 6 : 2 Grey colors
    m_PreferredEncoding : Integer;

    m_SwapMouse : Boolean;
    m_Emul3Buttons : Boolean;
    m_JapKeyboard : Boolean;
    m_Emul3Timeout : Integer;
    m_Emul3Fuzz : Integer;
    m_Shared : Boolean;
    m_DeiconifyOnBell : Boolean;
    m_DisableClipboard : Boolean;
    m_localCursor : Integer;
    m_throttleMouse : Integer; // adzm 2010-10
    m_scaling : Boolean;
    m_fAutoScaling : Boolean;
    m_scale_num : Integer;
    m_scale_den: Integer; // Numerator & denominator
    // Tight specific
    m_useCompressLevel : Boolean;
    m_compressLevel : Integer;
    m_enableJpegCompression : Boolean;
    m_jpegQualityLevel : Integer;
    m_requestShapeUpdates : Boolean;
    m_ignoreShapeUpdates : Boolean;

    // Modif sf@2002 - Server Scaling
    m_nServerScale : Integer; // Divider of the Target Server's screensize
    // Reconnect
    m_reconnectcounter : Integer;
    // Modif sf@2002 - Cache
    m_fEnableCache : Boolean;
    // Modif sz@2002 - DSM Plugin
    m_fUseDSMPlugin : Boolean;
    m_szDSMPluginFilename: array[0..C_MAX_PATH-1] of AnsiChar;
    m_oldplugin : Boolean;

    // sf@2003 - Autoscaling
    m_saved_scale_num : Integer;
    m_saved_scale_den : Integer;
    m_saved_scaling : Boolean;

    // Keyboard can be specified on command line as 8-digit hex
    m_kbdname: array[0..9-1] of AnsiChar;
    m_kbdSpecified : Boolean;

    // Connection options we don't do through the dialog
    // Which encodings do we allow?
    //Boolean	m_UseEnc[LASTENCODING+1];

    m_host_options: array[0..256-1] of AnsiChar;
    m_port : Integer;
    m_proxyhost: array[0..256-1] of AnsiChar;
    m_proxyport : Integer;
    m_fUseProxy : Boolean;

    m_selected_screen : Integer;

    // Logging
    m_logLevel : Integer;
    m_logToFile : Boolean;
    m_logToConsole : Boolean;
    m_logFilename: array[0..C_MAX_PATH-1] of AnsiChar;

    // for debugging purposes
    m_delay : Integer;

    // sf@2007 - AutoReconnect
    m_autoReconnect : Integer;

    // Fix by Act : No User and/Or password if the first VNC connection is rejected
    m_NoMoreCommandLineUserPassword : Boolean;

    m_fExitCheck : Boolean; //PGM @ Advantig
    m_FTTimeout : Integer;
    m_keepAliveInterval : Integer;
    m_socketKeepAliveTimeout : Integer; // adzm 2010-08

    //adzm - 2009-06-21
    m_fAutoAcceptIncoming : Boolean;

    //adzm 2009-07-19
    m_fAutoAcceptNoDSM : Boolean;

    //adzm 2010-05-12
    m_fRequireEncryption : Boolean;

    //adzm 2010-07-04
    m_preemptiveUpdates : Boolean;
  end;

implementation

type
  TVncViewerDll_Init           = function(aInstance: LongWord): Integer;stdcall;
  TVncViewerDll_GetOptions     = function(aStruct: PVNCOptionsStruct): Integer;stdcall;
  TVncViewerDll_SetOptions     = function(aStruct: PVNCOptionsStruct): Integer;stdcall;
  //
  TVncViewerDll_NewConnection  = function(aHost: PAnsiChar; aPort: Integer = 5900): THandle;stdcall;
  TVncViewerDll_CloseConnection= function(aConnectionWindow: THandle): Integer;stdcall;
  TVncViewerDll_ToolbarHandle  = function: THandle;
  TVncViewerDll_ToolbarWindow  = function: THandle;
  //
  TVncViewerDll_SetWindowSizedCallback = function(aCallback: Pointer{TProcedure}): Integer;stdcall;

var
  pVncViewerDll_Init            : TVncViewerDll_Init;
  pVncViewerDll_GetOptions      : TVncViewerDll_GetOptions;
  pVncViewerDll_SetOptions      : TVncViewerDll_SetOptions;
  //                              //
  pVncViewerDll_NewConnection   : TVncViewerDll_NewConnection;
  pVncViewerDll_CloseConnection : TVncViewerDll_CloseConnection;
  pVncViewerDll_ToolbarHandle   : TVncViewerDll_ToolbarHandle;
  pVncViewerDll_ToolbarWindow   : TVncViewerDll_ToolbarWindow;
  //
  pVncViewerDll_SetWindowSizedCallback: TVncViewerDll_SetWindowSizedCallback;

{ TVncViewerAsDll }

class function TVncViewerAsDll.IsLoaded: Boolean;
begin
  Result := (FDll > 0);
end;

class function TVncViewerAsDll.Load: Boolean;
begin
  FDll   := LoadLibrary(PChar('VncViewerAsDll.dll'));
  Result := (FDll > 0);
  if not Result then Exit;

  pVncViewerDll_Init           := GetProcAddress(FDll, 'VncViewerDll_Init');
  pVncViewerDll_GetOptions     := GetProcAddress(FDll, 'VncViewerDll_GetOptions');
  pVncViewerDll_SetOptions     := GetProcAddress(FDll, 'VncViewerDll_SetOptions');
  //
  pVncViewerDll_NewConnection  := GetProcAddress(FDll, 'VncViewerDll_NewConnection');
  pVncViewerDll_CloseConnection:= GetProcAddress(FDll, 'VncViewerDll_CloseConnection');
  pVncViewerDll_ToolbarHandle  := GetProcAddress(FDll, 'VncViewerDll_ToolbarHandle');
  pVncViewerDll_ToolbarWindow  := GetProcAddress(FDll, 'VncViewerDll_ToolbarWindow');
  //
  pVncViewerDll_SetWindowSizedCallback:= GetProcAddress(FDll, 'VncViewerDll_SetWindowSizedCallback');
end;

class function TVncViewerAsDll.UnLoad: Boolean;
begin
  Result := FreeLibrary(FDll);
  FDll   := 0;
end;

class function TVncViewerAsDll.VncViewerDll_Init(aInstance: LongWord): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pVncViewerDll_Init));
  //Result := pVncViewerDll_Init(aInstance);   do NOT load resources from own .exe!
  Result := pVncViewerDll_Init(FDll);   //load resources from loaded dll!
  Assert(Result = 0);
end;

class function TVncViewerAsDll.VncViewerDll_GetOptions(
  aStruct: PVNCOptionsStruct): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pVncViewerDll_GetOptions));
  Result := pVncViewerDll_GetOptions(aStruct);
  Assert(Result = 0);
end;

class function TVncViewerAsDll.VncViewerDll_SetOptions(
  aStruct: PVNCOptionsStruct): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pVncViewerDll_SetOptions));
  Result := pVncViewerDll_SetOptions(aStruct);
  Assert(Result = 0);
end;

class procedure TVncViewerAsDll.VncViewerDll_SetWindowSizedCallback(aCallback: THandleProcedure);
var
  iResult: Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pVncViewerDll_SetWindowSizedCallback));
  iResult := pVncViewerDll_SetWindowSizedCallback(@aCallback);
  Assert(iResult = 0);
end;

class function TVncViewerAsDll.VncViewerDll_ToolbarHandle: THandle;
begin
  Assert(FDll > 0);
  Assert(Assigned(pVncViewerDll_ToolbarHandle));
  Result := pVncViewerDll_ToolbarHandle;
  Assert(Result <> 0);
end;

class function TVncViewerAsDll.VncViewerDll_ToolbarWindow: THandle;
begin
  Assert(FDll > 0);
  Assert(Assigned(pVncViewerDll_ToolbarWindow));
  Result := pVncViewerDll_ToolbarWindow;
  Assert(Result <> 0);
end;

class function TVncViewerAsDll.VncViewerDll_NewConnection(aHost: PAnsiChar;
  aPort: Integer): THandle;
begin
  Assert(FDll > 0);
  Assert(Assigned(pVncViewerDll_NewConnection));
  Result := pVncViewerDll_NewConnection(aHost, aPort);
  Assert(Result <> 0);
end;

class function TVncViewerAsDll.VncViewerDll_CloseConnection(
  aConnectionWindow: THandle): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pVncViewerDll_CloseConnection));
  Result := pVncViewerDll_CloseConnection(aConnectionWindow);
  Assert(Result = 0);
end;

end.
