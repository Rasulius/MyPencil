program Reflection;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmGL};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Reflection';
  Application.CreateForm(TfrmGL, frmGL);
  Application.Run;
end.

