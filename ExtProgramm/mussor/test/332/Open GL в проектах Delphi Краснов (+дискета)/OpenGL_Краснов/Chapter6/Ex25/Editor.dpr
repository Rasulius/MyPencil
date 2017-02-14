program Editor;

uses
  Forms,
  Main in 'Main.pas' {frmMain},
  Splash in 'Splash.pas' {SplashWindow},
  ParObject in 'ParObject.pas' {frmParObject},
  ParSdvig in 'ParSdvig.pas' {frmParSdvig},
  ParAngle in 'ParAngle.pas' {frmParAngle},
  AddObject in 'AddObject.pas' {frmAddObject},
  ScaleLetter in 'ScaleLetter.pas' {frmScaleLetter};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmParObject, frmParObject);
  Application.CreateForm(TfrmParSdvig, frmParSdvig);
  Application.CreateForm(TfrmParAngle, frmParAngle);
  Application.CreateForm(TfrmAddObject, frmAddObject);
  Application.CreateForm(TfrmScaleLetter, frmScaleLetter);
  Application.Run;
end.
