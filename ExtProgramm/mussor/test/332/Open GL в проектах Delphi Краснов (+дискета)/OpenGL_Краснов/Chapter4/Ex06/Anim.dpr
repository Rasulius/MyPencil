program Anim;

uses
  Forms,
  frmMain in 'frmMain.pas' {frmCube};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGL, frmGL);
  Application.Run;
end.

