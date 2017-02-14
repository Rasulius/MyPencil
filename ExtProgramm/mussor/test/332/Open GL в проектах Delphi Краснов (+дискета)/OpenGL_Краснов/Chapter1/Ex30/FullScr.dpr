program FullScr;

uses
  Forms,
  frmMain in 'frmMain.pas' {frmGL},
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGL, frmGL);
  Application.Run;
end.

