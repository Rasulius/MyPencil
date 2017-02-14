program Project;

uses
  Forms,
  Main in 'Main.pas' {frmGL};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGL, frmGL);
  Application.Run;
end.
