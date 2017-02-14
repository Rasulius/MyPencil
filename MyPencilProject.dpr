program MyPencilProject;

uses
  Forms,
  MyPencil in 'MyPencil.pas' {Form1},
  ColorEditor in 'ColorEditor.pas',
  FilmEditor in 'FilmEditor.pas',
  FilmManager in 'FilmManager.pas',
  StandartResolutions in 'StandartResolutions.pas',
  ImageUtils in 'ImageUtils.pas',
  DrawStateMachine in 'DrawStateMachine.pas',
  MagicBrush in 'MagicBrush.pas',
  MagicBrushFactory in 'MagicBrushFactory.pas',
  MagicBrushFirstComplect in 'MagicBrushFirstComplect.pas',
  ProjectUtils in 'ProjectUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
