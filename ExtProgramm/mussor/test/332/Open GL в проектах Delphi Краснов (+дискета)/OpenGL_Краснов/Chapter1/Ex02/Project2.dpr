program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
