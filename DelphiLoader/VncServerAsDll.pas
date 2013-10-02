{$OPTIMIZATION OFF}
unit VncServerAsDll;

interface

uses
  Windows;

const
  C_MAXPWLEN = 8;
  C_OK       = 0;

type
  PvncPropertiesStruct = ^TvncPropertiesStruct;
  PvncPropertiesPollStruct = ^TvncPropertiesPollStruct;

  TVncServerAsDll = class
  protected
    class var
      FDll: THandle;
      FStarted: Boolean;
  public
    class function Load    : Boolean;
    class function UnLoad  : Boolean;
    class function IsLoaded: Boolean;
    class function Started : Boolean;

    class function WinVNCDll_Init             (aInstance: LongWord): Integer;
    class function WinVNCDll_CreateServer     (): Integer;
    class function WinVNCDll_GetProperties    (aStruct: PvncPropertiesStruct): Integer;
    class function WinVNCDll_SetProperties    (aStruct: PvncPropertiesStruct): Integer;
    class function WinVNCDll_SetPollProperties(aStruct: PvncPropertiesPollStruct): Integer;
    class function WinVNCDll_GetPollProperties(aStruct: PvncPropertiesPollStruct): Integer;
    class function WinVNCDll_AuthClientCount  (): Integer;
    class function WinVNCDll_UnAuthClientCount(): Integer;
    class function WinVNCDll_ListenForClient  (aRemoteClient, aIDCode: PAnsiChar): Integer;
    class function WinVNCDll_RunServer        (): Integer;
    class function WinVNCDll_DestroyServer    (): Integer;
  end;

  //vncProperties.h
  TvncPropertiesStruct = record
    DebugMode: Integer;
    Avilog: Integer;
    path: PAnsiChar;
    DebugLevel: Integer;

    AllowLoopback: Integer;
    LoopbackOnly: Integer;
    AllowShutdown: Integer;
    AllowProperties: Integer;
    AllowEditClients: Integer;
    FileTransferTimeout: Integer;
    KeepAliveInterval: Integer;
    SocketKeepAliveTimeout: Integer;

    DisableTrayIcon: Integer;
    MSLogonRequired: Integer;
    NewMSLogon: Integer;

    UseDSMPlugin: Integer;
    ConnectPriority: Integer;
    DSMPlugin      : PAnsiChar;
    DSMPluginConfig: PAnsiChar;

    //user settings:
    //***************************

    FileTransferEnabled: Integer;
    FTUserImpersonation: Integer;
    BlankMonitorEnabled: Integer;
    BlankInputsOnly: Integer;
    CaptureAlphaBlending: Integer;
    BlackAlphaBlending: Integer;

    DefaultScale: Integer;
    //int UseDSMPlugin;
    //char * DSMPlugin;
    //char * DSMPluginConfig;

    primary: Integer;
    secondary: Integer;

    // Connection prefs
    SocketConnect: Integer;
    HTTPConnect: Integer;
    XDMCPConnect: Integer;
    AutoPortSelect: Integer;
    PortNumber: Integer;
    HTTPPortNumber: Integer;
    InputsEnabled: Integer;
    LocalInputsDisabled: Integer;
    IdleTimeout: Integer;
    EnableJapInput: Integer;
    clearconsole: Integer;
    sendbuffer: Integer;

    // Connection querying settings
    QuerySetting: Integer;
    QueryTimeout: Integer;
    QueryAccept: Integer;
    QueryIfNoLogon: Integer;

    // Lock settings
    LockSetting: Integer;

    // Wallpaper removal
    RemoveWallpaper: Integer;
    // UI Effects
    RemoveEffects: Integer;
    RemoveFontSmoothing: Integer;
    // Composit desktop removal
    RemoveAero: Integer;

    password     : array[0..C_MAXPWLEN-1] of AnsiChar;
    password_view: array[0..C_MAXPWLEN-1] of AnsiChar;
  end;

  TvncPropertiesPollStruct = record
    TurboMode: Integer;
    PollUnderCursor: Integer;
    PollForeground: Integer;
    PollFullScreen: Integer;
    OnlyPollConsole: Integer;
    OnlyPollOnEvent: Integer;
    MaxCpu: Integer;
    EnableDriver: Integer;
    EnableHook: Integer;
    EnableVirtual: Integer;
    SingleWindow: Integer;
    SingleWindowName: array[0..32-1] of AnsiChar;
  end;

implementation

type
  //WinVNCdll.cpp
  TWinVNCDll_Init               = function(hInstance: LongWord): Integer;stdcall;
  TWinVNCDll_CreateServer       = function(): Integer;stdcall;
  TWinVNCDll_GetProperties      = function(aStruct: PvncPropertiesStruct): Integer;stdcall;
  TWinVNCDll_SetProperties      = function(aStruct: PvncPropertiesStruct): Integer;stdcall;
  TWinVNCDll_GetPollProperties  = function(aStruct: PvncPropertiesPollStruct): Integer;stdcall;
  TWinVNCDll_SetPollProperties  = function(aStruct: PvncPropertiesPollStruct): Integer;stdcall;
  TWinVNCDll_AuthClientCount    = function(): Integer;stdcall;
  TWinVNCDll_UnAuthClientCount  = function(): Integer;stdcall;
  TWinVNCDll_ListenForClient    = function(aRemoteClient, aIDCode: PAnsiChar): Integer;stdcall;
  TWinVNCDll_RunServer          = function(): Integer;stdcall;
  TWinVNCDll_DestroyServer      = function(): Integer;stdcall;

var
  pWinVNCDll_Init             : TWinVNCDll_Init;
  pWinVNCDll_CreateServer     : TWinVNCDll_CreateServer;
  pWinVNCDll_GetProperties    : TWinVNCDll_GetProperties;
  pWinVNCDll_SetProperties    : TWinVNCDll_SetProperties;
  pWinVNCDll_GetPollProperties: TWinVNCDll_GetPollProperties;
  pWinVNCDll_SetPollProperties: TWinVNCDll_SetPollProperties;
  pWinVNCDll_AuthClientCount  : TWinVNCDll_AuthClientCount;
  pWinVNCDll_UnAuthClientCount: TWinVNCDll_UnAuthClientCount;
  pWinVNCDll_ListenForClient  : TWinVNCDll_ListenForClient;
  pWinVNCDll_RunServer        : TWinVNCDll_RunServer;
  pWinVNCDll_DestroyServer    : TWinVNCDll_DestroyServer;

{ TVncServerAsDll }

class function TVncServerAsDll.IsLoaded: Boolean;
begin
  Result := (FDll > 0);
end;

class function TVncServerAsDll.Load: Boolean;
begin
  FDll   := LoadLibrary(PChar('vncserver.dll'));   //new filename
  if FDll <= 0 then
    FDll   := LoadLibrary(PChar('winvncdll.dll')); //old filename
  Result := (FDll > 0);
  if not Result then Exit;

  pWinVNCDll_Init              := GetProcAddress(FDll, 'WinVNCDll_Init');
  pWinVNCDll_CreateServer      := GetProcAddress(FDll, 'WinVNCDll_CreateServer');
  pWinVNCDll_GetProperties     := GetProcAddress(FDll, 'WinVNCDll_GetProperties');
  pWinVNCDll_SetProperties     := GetProcAddress(FDll, 'WinVNCDll_SetProperties');
  pWinVNCDll_GetPollProperties := GetProcAddress(FDll, 'WinVNCDll_GetPollProperties');
  pWinVNCDll_SetPollProperties := GetProcAddress(FDll, 'WinVNCDll_SetPollProperties');
  pWinVNCDll_AuthClientCount   := GetProcAddress(FDll, 'WinVNCDll_AuthClientCount');
  pWinVNCDll_UnAuthClientCount := GetProcAddress(FDll, 'WinVNCDll_UnAuthClientCount');
  pWinVNCDll_ListenForClient   := GetProcAddress(FDll, 'WinVNCDll_ListenForClient');
  pWinVNCDll_RunServer         := GetProcAddress(FDll, 'WinVNCDll_RunServer');
  pWinVNCDll_DestroyServer     := GetProcAddress(FDll, 'WinVNCDll_DestroyServer');
end;

class function TVncServerAsDll.UnLoad: Boolean;
begin
  Result := FreeLibrary(FDll);
  FDll   := 0;
  FStarted := False;
end;

class function TVncServerAsDll.Started: Boolean;
begin
  Result := IsLoaded and
            FStarted;
end;

class function TVncServerAsDll.WinVNCDll_Init(aInstance: LongWord): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_Init));
  Result := pWinVNCDll_Init(aInstance);
  Assert(Result = 0);
end;

class function TVncServerAsDll.WinVNCDll_AuthClientCount: Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_AuthClientCount));
  Result := pWinVNCDll_AuthClientCount;
end;

class function TVncServerAsDll.WinVNCDll_ListenForClient(aRemoteClient,
  aIDCode: PAnsiChar): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_ListenForClient));
  Result := pWinVNCDll_ListenForClient(aRemoteClient, aIDCode);
end;

class function TVncServerAsDll.WinVNCDll_CreateServer: Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_CreateServer));
  Result := pWinVNCDll_CreateServer;
end;

class function TVncServerAsDll.WinVNCDll_GetPollProperties(aStruct: PvncPropertiesPollStruct): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_GetPollProperties));
  Result := pWinVNCDll_GetPollProperties(aStruct);
end;

class function TVncServerAsDll.WinVNCDll_GetProperties(aStruct: PvncPropertiesStruct): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_GetProperties));
  //note: properties are default or loaded from "ultravnc.ini"
  Result := pWinVNCDll_GetProperties(aStruct);
  Assert(Result = 0);
end;

class function TVncServerAsDll.WinVNCDll_SetPollProperties(
  aStruct: PvncPropertiesPollStruct): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_SetPollProperties));
  Result := pWinVNCDll_SetPollProperties(aStruct);
  Assert(Result = 0);
end;

class function TVncServerAsDll.WinVNCDll_SetProperties(aStruct: PvncPropertiesStruct): Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_SetProperties));
  Result := pWinVNCDll_SetProperties(aStruct);
  Assert(Result = 0);
end;

class function TVncServerAsDll.WinVNCDll_UnAuthClientCount: Integer;
begin
  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_UnAuthClientCount));
  Result := pWinVNCDll_UnAuthClientCount;
end;

class function TVncServerAsDll.WinVNCDll_RunServer: Integer;
begin
  FStarted := False;

  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_RunServer));
  Result := pWinVNCDll_RunServer;

  FStarted := (Result = C_OK);
end;

class function TVncServerAsDll.WinVNCDll_DestroyServer: Integer;
begin
  FStarted := False;

  Assert(FDll > 0);
  Assert(Assigned(pWinVNCDll_DestroyServer));
  Result := pWinVNCDll_DestroyServer;
end;

end.
