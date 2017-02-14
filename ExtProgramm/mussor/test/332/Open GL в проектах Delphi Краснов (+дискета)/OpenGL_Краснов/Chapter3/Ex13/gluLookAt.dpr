program gluLookAt;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmGL},
  Unit2 in 'Unit2.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGL, frmGL);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

