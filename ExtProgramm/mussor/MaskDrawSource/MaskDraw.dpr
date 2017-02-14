program MaskDraw;

uses
  Forms,
  U_MaskDraw in 'U_MaskDraw.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
