{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}
program WinMin;

uses
   Windows, Messages,
   SysUtils; // для функции IntToStr

const
  AppName = 'WinMin';

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
var
  XPos, YPos : Integer;
  wrkPChar : PChar;
begin
  WindowProc := 0;
  case Message of
       wm_Destroy :      begin
                         PostQuitMessage (0);
                         Exit;
                         end;
       // реакция на сообщение - двойной щелчок на окне
       wm_LButtonDblClk: begin
                         xpos := LoWord ( LParam );
                         ypos := HiWord ( LParam );
                         wrkPChar := PChar ( 'X - ' + IntToStr ( xpos ) + ' Y - ' + IntToStr ( ypos ) );
                         MessageBox (0, wrkPChar, 'Двойной щелчок', mb_OK);
                         end;
  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
end;

begin
  with WindowClass do begin
    Style := cs_HRedraw or cs_VRedraw
             or cs_DblClks; // окно может реагировать на двойной щелчок
    lpfnWndProc := @WindowProc;
    cbClsExtra := 0;
    cbWndExtra := 0;
    hInstance := 0;
    hIcon := LoadIcon (0, idi_Application);
    hCursor := LoadCursor (0, idc_Arrow);
    hbrBackground := GetStockObject (White_Brush);
    lpszMenuName := '';
    lpszClassName := AppName;
  end;
  If RegisterClass (WindowClass) = 0 then Halt (255);
  Window := CreateWindow (AppName, 'Win_Min', ws_OverlappedWindow,
      cw_UseDefault, cw_UseDefault,
      cw_UseDefault, cw_UseDefault,
      0, 0, HInstance, nil);
  ShowWindow (Window, CmdShow);
  UpdateWindow (Window);
  while GetMessage (Message, 0, 0, 0) do begin
    TranslateMessage (Message);
    DispatchMessage (Message);
 end;
 Halt (Message.wParam);
end.
