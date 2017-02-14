program Demo;

uses
  Forms,
  Unit1 in 'unit1.pas' {frmMain},
  OptDlg in 'optdlg.pas' {frmOption},
  Vfw in 'vfw.pas',
  ScrCam in 'scrcam.pas',
  FlashWnd in 'flashwnd.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmOption, frmOption);
  Application.Run;
end.
