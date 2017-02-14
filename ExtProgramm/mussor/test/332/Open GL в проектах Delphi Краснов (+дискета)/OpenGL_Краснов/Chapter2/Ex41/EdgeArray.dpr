program EdgeArray;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmGL};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGL, frmGL);
  Application.Run;
end.

