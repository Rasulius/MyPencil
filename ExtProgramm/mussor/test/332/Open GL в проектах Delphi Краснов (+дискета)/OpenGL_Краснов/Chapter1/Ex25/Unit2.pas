{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.DFM}

procedure TForm2.Button1Click(Sender: TObject);
var
 frmGL : TfrmGL;
begin
 frmGL := TfrmGL.Create (nil);
 frmGL.Top := random (round(ClientWidth / 2));
 frmGL.Left := random (round(ClientHeight / 2));
 frmGL.Show;
end;

end.
