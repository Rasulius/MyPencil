{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TForm1 = class(TForm)
    procedure FormDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure MesDblClick (var MyMessage : TWMMouse); message wm_LButtonDblClk;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{=======================================================================
Обработка сообщения wm_LButtonDblClk}
procedure TForm1.MesDblClick (var MyMessage : TWMMouse);
var
  xPos, yPos : Integer;
begin
  xPos := MyMessage.XPos;
  yPos := MyMessage.YPos;
  ShowMessage ('X - ' + IntToStr (xPos) + ' Y - ' + IntToStr (yPos));
end;

{=======================================================================
Обработка события DblClick}
procedure TForm1.FormDblClick(Sender: TObject);
begin
  ShowMessage ('OK');
end;

end.
