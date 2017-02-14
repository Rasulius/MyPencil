program Light;

uses
  Forms,
  frmMain in 'frmMain.pas' {frmGL},
  Unit1 in 'Unit1.pas' {frmInfo};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGL, frmGL);
  Application.CreateForm(TfrmInfo, frmInfo);
  Application.Run;
end.

