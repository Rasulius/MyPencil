program AviDemo;

uses
  Forms,
  MainU in 'MainU.pas' {MainForm},
  HelperProcs in 'HelperProcs.pas',
  Thumblist in 'Thumblist.pas',
  AviThread in 'AviThread.pas',
  AviDialogU in 'AviDialogU.pas' {AviDialog},
  ProgressU in 'ProgressU.pas' {ProgressForm},
  BadBitmapU in 'BadBitmapU.pas' {BadBitmapForm},
  ThumbFile in 'ThumbFile.pas',
  PersistentDialogU in 'PersistentDialogU.pas' {PersistentDialog};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

