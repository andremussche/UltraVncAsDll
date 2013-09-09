unit frViewer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls;

type
  TframViewer = class(TFrame)
    pnlEmbed: TPanel;
  private
    FViewerHandle: THandle;
  public
    destructor Destroy; override;

    procedure EmbedViewer(aViewer: THandle);
    property  EmbeddedViewer: THandle read FViewerHandle;
  end;

implementation

uses
  VncViewerAsDll;

{$R *.dfm}

{ TframViewer }

destructor TframViewer.Destroy;
begin
  ShowWindow(FViewerHandle, SW_HIDE);
  Windows.SetParent(FViewerHandle, 0);

  TVncViewerAsDll.VncViewerDll_CloseConnection(FViewerHandle);
  inherited;
end;

procedure TframViewer.EmbedViewer(aViewer: THandle);
var
  style, exStyle: Cardinal;
  //r: TRect;
begin
  FViewerHandle := aViewer;

  //put in panel
  Windows.SetParent(aViewer, pnlEmbed.Handle);

  //Windows.GetWindowRect(FLastViewer, r);
  //pnl.Width  := r.Right  - r.Left;
  //pnl.Height := r.Bottom - r.Top;
  //resize within tab
  Windows.SetWindowPos(aViewer, 0, 0, 0, pnlEmbed.Width, pnlEmbed.Height, SWP_ASYNCWINDOWPOS);

  //remove borders, captionbar, etc
  style   := GetWindowLong(aViewer, GWL_STYLE);
  exStyle := GetWindowLong(aViewer, GWL_EXSTYLE);
  style   := style and not (WS_POPUP or WS_CAPTION or WS_BORDER or WS_THICKFRAME or WS_DLGFRAME or DS_MODALFRAME);
  exStyle := exStyle and not (WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE or WS_EX_TOOLWINDOW);
  SetWindowLong(aViewer, GWL_STYLE, style);
  SetWindowLong(aViewer, GWL_EXSTYLE, exStyle);

  //show (?)
  Windows.ShowWindow(aViewer, SW_SHOW);
end;

end.
