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
    procedure actStartExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actLoadExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure actLoadViewerExecute(Sender: TObject);
    procedure actAddViewerExecute(Sender: TObject);
    procedure actCloseViewerExecute(Sender: TObject);
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
  VncServerAsDll, VncViewerAsDll;

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
  options.m_NoStatus := False;
  options.m_ShowToolbar   := True;
  options.m_nServerScale  := 2;
  options.m_clearPassword := 'test';
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

  props.RemoveWallpaper := 1;
  props.RemoveEffects := 1;
  props.RemoveFontSmoothing := 1;
  props.RemoveAero := 1;

  props.CaptureAlphaBlending := 0;

  props.DebugLevel := 10;
  props.DebugMode  := 1;
  props.AllowLoopback := 1;
  props.LoopbackOnly := 1;

  TVncServerAsDll.WinVNCDll_SetProperties(@props);
  TVncServerAsDll.WinVNCDll_GetProperties(@props);

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

destructor TForm1.Destroy;
begin
  FViewers.Free;
  inherited;
end;

end.
