program DDrawGL;

uses
  Forms,
  DDMain in 'DDMain.pas' {DForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDForm, DForm);
  Application.Run;
end.
