{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

procedure TForm2.Button1Click(Sender: TObject);
var
   H : HWND;
begin
   H := FindWindow ('TForm1', nil);
   If H <> 0 then SendMessage (H, WM_SYSCOMMAND, SC_MINIMIZE, 0)
end;


procedure TForm2.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Caption := 'x=' + IntToStr (X) + ', y=' + IntToStr (Y)
end;

procedure TForm2.Button2Click(Sender: TObject);
var
   dc : HDC;
begin
    dc := GetDC (0);
    Rectangle (dc, 10, 10, 110, 110);
    ReleaseDC (Handle, dc);
    DeleteDC (DC);
end;

end.
