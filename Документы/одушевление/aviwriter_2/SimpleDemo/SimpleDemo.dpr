program SimpleDemo;

{%File '..\Readme.txt'}

uses
  Forms,
  MainU in 'MainU.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

