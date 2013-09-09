program VncDllLoader;

uses
  Forms,
  MainForm in 'MainForm.pas' {Form1},
  VncServerAsDll in 'VncServerAsDll.pas',
  VncViewerAsDll in 'VncViewerAsDll.pas',
  frViewer in 'frViewer.pas' {framViewer: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
