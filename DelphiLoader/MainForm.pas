unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdCtrls, ComCtrls, ExtCtrls, frViewer,
  Generics.Collections;

type
  TForm1 = class(TForm)
    ActionList1: TActionList;
    actStart: TAction;
    actStop: TAction;
    actLoad: TAction;
    actLoadViewer: TAction;
    actAddViewer: TAction;
    actCloseViewer: TAction;
    GroupBox1: TGroupBox;
    btnLoad: TButton;
    btnStart: TButton;
    btnStop: TButton;
    GroupBox2: TGroupBox;
    btnClient: TButton;
    Button1: TButton;
    Button2: TButton;
    FlowPanel1: TFlowPanel;
    Button3: TButton;
    tmrRepeaterCheck: TTimer;
    Button4: TButton;
    procedure actStartExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actLoadExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure actLoadViewerExecute(Sender: TObject);
    procedure actAddViewerExecute(Sender: TObject);
    procedure actCloseViewerExecute(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure tmrRepeaterCheckTimer(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    FViewers: TObjectList<TframViewer>;
  public
    procedure AfterConstruction;override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

uses
  VncServerAsDll, VncViewerAsDll, JclDebug, JclHookExcept, StrUtils, IOUtils;

{$R *.dfm}

procedure TForm1.actAddViewerExecute(Sender: TObject);
var
  options: TVNCOptionsStruct;
  fr: TframViewer;
  viewer: THandle;
begin
  FillChar(options, SizeOf(options), 0);
  TVncViewerAsDll.VncViewerDll_GetOptions(@options);

  options.m_ViewOnly := True;
  options.m_NoStatus := True;
  options.m_ShowToolbar   := True;
  options.m_nServerScale  := 2;
  options.m_clearPassword := 'test';

//  options.m_proxyhost := 'localhost';
//  options.m_proxyport := 5901;
//  options.m_fUseProxy := True;

  TVncViewerAsDll.VncViewerDll_SetOptions(@options);

//  ts := TTabSheet.Create(PageControl1);
//  ts.PageControl := PageControl1;
//  ts.Caption     := 'localhost';
  fr := TframViewer.Create(FlowPanel1);
  fr.Name   := 'viewer' + FormatDateTime('hhnnsszzz', now) + IntToStr(FViewers.Count);
  fr.Width  := 400;
  fr.Height := 400;
  fr.Parent := FlowPanel1;
  FViewers.Add(fr);

  //make new VNC client connection
  viewer := TVncViewerAsDll.VncViewerDll_NewConnection('localhost', 5900);
  fr.EmbedViewer(viewer);
end;

procedure TForm1.actCloseViewerExecute(Sender: TObject);
begin
  TVncViewerAsDll.VncViewerDll_CloseConnection(FViewers.Last.EmbeddedViewer);
  FViewers.Remove(FViewers.Last);
end;

procedure TForm1.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  actLoad.Enabled  := not TVncServerAsDll.IsLoaded;
  actStart.Enabled := TVncServerAsDll.IsLoaded and
                      not TVncServerAsDll.Started;
  actStop.Enabled  := TVncServerAsDll.IsLoaded and
                      TVncServerAsDll.Started;

  actLoadViewer.Enabled  := not TVncViewerAsDll.IsLoaded;
  actAddViewer.Enabled   := TVncViewerAsDll.IsLoaded;
  actCloseViewer.Enabled := TVncViewerAsDll.IsLoaded and
                            (FViewers.Count > 0);
end;

procedure TForm1.actLoadExecute(Sender: TObject);
begin
  TVncServerAsDll.Load;
  TVncServerAsDll.WinVNCDll_Init(HInstance);
end;

procedure ClientResized(aConnectionWindow: THandle);stdcall;
var
  r: TRect;
  fr: TframViewer;
  style, exStyle: Cardinal;
begin
  Windows.GetClientRect(aConnectionWindow, r);

  for fr in Form1.FViewers do
  begin
    if fr.EmbeddedViewer = aConnectionWindow then
    begin
      //update new screen size
      fr.Width  := r.Right  + 5;
      fr.Height := r.Bottom + 5;
      Windows.SetWindowPos(aConnectionWindow, 0, 0, 0, fr.Width, fr.Height, SWP_ASYNCWINDOWPOS);

      //remove borders, captionbar, etc
      style   := GetWindowLong(aConnectionWindow, GWL_STYLE);
      exStyle := GetWindowLong(aConnectionWindow, GWL_EXSTYLE);
      style   := style and not (WS_POPUP or WS_CAPTION or
                                WS_BORDER or WS_THICKFRAME or WS_DLGFRAME or DS_MODALFRAME or
                                WS_VSCROLL or WS_HSCROLL);
      exStyle := exStyle and not (WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE or WS_EX_CLIENTEDGE or
                                  WS_EX_TOOLWINDOW or WS_EX_LEFTSCROLLBAR or WS_EX_RIGHTSCROLLBAR);
      SetWindowLong(aConnectionWindow, GWL_STYLE, style);
      SetWindowLong(aConnectionWindow, GWL_EXSTYLE, exStyle);

      //remove scrollbar
      Windows.ShowScrollBar(aConnectionWindow, SB_BOTH, False);

      ShowWindow(TVncViewerAsDll.VncViewerDll_ToolbarHandle, SW_SHOW);
      ShowWindow(TVncViewerAsDll.VncViewerDll_ToolbarWindow, SW_SHOW);
    end;
  end;
end;

procedure TForm1.actLoadViewerExecute(Sender: TObject);
begin
  TVncViewerAsDll.Load;
  TVncViewerAsDll.VncViewerDll_Init(HInstance);

  TVncViewerAsDll.VncViewerDll_SetWindowSizedCallback(ClientResized);
end;

procedure TForm1.actStartExecute(Sender: TObject);
var
  props: TvncPropertiesStruct;
  pollprops: TvncPropertiesPollStruct;
begin
  //create
  TVncServerAsDll.WinVNCDll_CreateServer;

  //setup
  FillChar(props, SizeOf(props), 0);
  TVncServerAsDll.WinVNCDll_GetProperties(@props);
  //note: properties are default or loaded from "ultravnc.ini"
  //we set some minimal values to allow local testing (in case of default values)
  props.AllowLoopback := 1;
  props.PortNumber    := 5900;
  props.password      := 'test';
  props.password_view := 'guest';

  props.RemoveWallpaper := 0;
  props.RemoveEffects := 0;
  props.RemoveFontSmoothing := 0;
  props.RemoveAero := 0;
  props.CaptureAlphaBlending := 1;

  props.DebugLevel := 10;
  props.DebugMode  := 1;
  props.AllowLoopback := 1;
//  props.LoopbackOnly := 1;

  TVncServerAsDll.WinVNCDll_SetProperties(@props);

  //setup
  FillChar(pollprops, SizeOf(pollprops), 0);
  TVncServerAsDll.WinVNCDll_GetPollProperties(@pollprops);
  pollprops.EnableDriver := 0;  //no black screen flickering!
  pollprops.EnableHook   := 1;  //fast, using vnchooks.dll but no load flickering
  TVncServerAsDll.WinVNCDll_SetPollProperties(@pollprops);

  //run!
  TVncServerAsDll.WinVNCDll_RunServer;
end;

procedure TForm1.actStopExecute(Sender: TObject);
begin
  TVncServerAsDll.WinVNCDll_DestroyServer;
end;

procedure TForm1.AfterConstruction;
begin
  inherited;
  FViewers := TObjectList<TframViewer>.Create(True);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  clientid: Integer;
begin
  clientid := TVncServerAsDll.WinVNCDll_ListenForClient('localhost', 'ID:1234');
  if clientid > 0 then
    tmrRepeaterCheck.Enabled := True;
end;

procedure TForm1.tmrRepeaterCheckTimer(Sender: TObject);
begin
  tmrRepeaterCheck.Enabled := False;
  try
    if TVncServerAsDll.WinVNCDll_UnAuthClientCount = 0 then
      TVncServerAsDll.WinVNCDll_ListenForClient('localhost', 'ID:1234');
  finally
    tmrRepeaterCheck.Enabled := True;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  options: TVNCOptionsStruct;
  fr: TframViewer;
  viewer: THandle;
begin
  FillChar(options, SizeOf(options), 0);
  TVncViewerAsDll.VncViewerDll_GetOptions(@options);

  options.m_ViewOnly := True;
  options.m_NoStatus := False;
  options.m_ShowToolbar   := True;
  options.m_nServerScale  := 2;
  options.m_clearPassword := 'test';

  options.m_proxyhost := 'localhost';
  options.m_proxyport := 5901;
  options.m_fUseProxy := True;

  TVncViewerAsDll.VncViewerDll_SetOptions(@options);

  fr := TframViewer.Create(FlowPanel1);
  fr.Name   := 'viewer' + FormatDateTime('hhnnsszzz', now) + IntToStr(FViewers.Count);
  fr.Width  := 400;
  fr.Height := 400;
  fr.Parent := FlowPanel1;
  FViewers.Add(fr);

  //make new VNC client connection
  viewer := TVncViewerAsDll.VncViewerDll_NewConnection('ID', 1234);
  fr.EmbedViewer(viewer);
end;

destructor TForm1.Destroy;
begin
  FViewers.Free;
  inherited;
end;

procedure WriteStackListToFile(const aError: Exception; const AStackTrace: TJclStackInfoList; const aErrorText: string);
var
  str:TStrings;
begin
  str    := TStringList.create;
  try
    if AStackTrace <> nil then
      AStackTrace.AddToStrings(Str,True,False,True);
    TFile.WriteAllText(
      'Exception_' + FormatDateTime('yyyymmdd-hhnnsszzz', Now) + '.log',
      aErrorText + str.Text);
  finally
    str.Free;
  end;
end;

procedure WriteAnyException(ExceptObj: Exception; ExceptAddr: Pointer; OSException: Boolean);
var
  sError:string;
  lstack: TJclStackInfoList;
  iTID: Cardinal;
begin
  if ExceptObj = nil then
    sError := 'Unknown/Empty exception'
  else
    sError := Format('%s at adress %p: %s',
                    [ExceptObj.ClassName, ExceptAddr,
                     ExceptObj.Message]);

  //if exception in our own code?
  if OSException then
    sError := 'OS ' + sError;
  //if GetCurrentProcessId <> FMainProcessId then
  //  sError := format('External process (%d) %s',[GetCurrentProcessId, sError]);

  iTID := GetCurrentThreadId;
  if GetCurrentThreadId = MainThreadID then
    sError := format('%s' + #13 + '{occured in main thread}',[sError])
  else
  begin
    sError := format('%s' + #13 + '{occured in sub thread(TID=%d, class=%s, name=%s, created=%s, parent=%s)}',
                     [sError, iTID,
                      JclDebugThreadList.ThreadClassNames[iTID],
                      JclDebugThreadList.ThreadNames[iTID],
                      DateTimeToStr(JclDebugThreadList.ThreadCreationTime[iTID]),
                      IfThen(JclDebugThreadList.ThreadParentIDs[iTID] <> iTID,
                             JclDebugThreadList.ThreadInfos[ JclDebugThreadList.ThreadParentIDs[iTID] ],
                             '')
                     ]);
  end;
  sError := 'HOOK: ' + sError;

  //WriteMemoryDump(0)
  //if ExceptObj is ETestFailure then
  //  lStack := jclDebug.JclCreateStackList(False, 0, nil)
  //else
    lStack := jclDebug.JclLastExceptStackList;
  try
    if (lstack = nil) or (lstack.Count < 3) then
    begin
      lstack.Free;
      lStack := TJclStackInfoList.Create(True, 0, nil);
    end;

    sError := sError + #13#13'Stack:'#13;
    {$IOCHECKS OFF}
    WriteStackListToFile(ExceptObj, lStack, sError);
    {$IOCHECKS ON}
  finally
    lstack.Free;
  end;
end;

procedure AnyExceptionNotify(ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
begin
  try
    //terminated? -> do not quit, always write exception logs!
    //if Application.Terminated then exit;

    //delphi thread name, ignore
    if (ExceptObj is EExternalexception) and
       {$WARN SYMBOL_PLATFORM OFF}
       (EExternalexception(ExceptObj).Exceptionrecord^.ExceptionCode = 1080890248) then
    begin
      Exit;
    end;
    //if ExceptObj is EIdSilentException then exit;    //EIdClosedSocket
    //if ExceptObj is EIdSocketError then exit;
    //if (ExceptObj is EAbort) and not (ExceptObj is ETestFailure) then exit;
    if not (ExceptObj is Exception) then Exit;

    WriteAnyException(ExceptObj as Exception, ExceptAddr, OSException);
  except
    //eat exceptions during exception handling...
  end;
end;

initialization
  JclHookThreads;
  //{$IFDEF ShowAllExceptions}
  JclHookExceptions;
  // Assign notification procedure for hooked RaiseException API call. This
  // allows being notified of any exception
  JclAddExceptNotifier(AnyExceptionNotify);
  //{$ENDIF}

end.
