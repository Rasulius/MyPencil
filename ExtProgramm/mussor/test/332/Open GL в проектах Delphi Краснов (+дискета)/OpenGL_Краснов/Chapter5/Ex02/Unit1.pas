{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Classes, Graphics, Forms, Controls, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

procedure AboutForm; stdcall; export;

implementation

{$R *.DFM}

procedure AboutForm; stdcall; export;
begin
    Form1 := TForm1.Create ( Application );
    Form1.ShowModal;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
     Close
end;

end.

