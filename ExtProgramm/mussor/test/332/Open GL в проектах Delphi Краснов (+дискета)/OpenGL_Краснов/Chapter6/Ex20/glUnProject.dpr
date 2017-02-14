program glUnProject;

uses
  Forms,
  frmMain in 'frmMain.pas' {frmGL};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGL, frmGL);
  Application.Run;
end.

