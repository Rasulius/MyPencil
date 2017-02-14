{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program WinKeys;

uses
   Windows, Messages;

const
  AppName = 'WinKeys';

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
Begin
  WindowProc := 0;
  case Message of
       wm_Destroy : begin
                    PostQuitMessage (0);
                    Exit;
                    end;
       wm_Char:  // анализ нажатой клавиши
       case wParam of
       { X, x } $58, $78 : If HiWord (GetKeyState (vk_Shift)) = 0 { Shift }
                          then MessageBox(Window, 'X', 'Нажата клавиша', MB_OK)
                          else MessageBox(Window, 'X вместе с Shift', 'Нажата клавиша', MB_OK);
       end; // wm_char
  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
       With WindowClass do
        begin
        Style := cs_DblClks;
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
       If RegisterClass (WindowClass) = 0 then
          Halt (255);
       Window := CreateWindow (AppName, 'Обработка мыши',
        ws_OverlappedWindow, 100, 100, 250, 150, 0, 0, HInstance, nil);
       ShowWindow (Window, CmdShow);
       UpdateWindow (Window);
       while GetMessage (Message, 0, 0, 0) do
        begin
         TranslateMessage (Message);
         DispatchMessage (Message);   
        end;
      Halt (Message.wParam);
End.

