{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

program Paint;

uses
   Windows, Messages;

const
  AppName = 'WinPaint';

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  xPos, yPos : Integer;
  Down : Boolean;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
Var
    dc : HDC;               { ссылка на контекст, должна использоваться для работы с окном }
    MyPaint : TPaintStruct; { структура для работы функций отображения }
Begin
  WindowProc := 0;
  case Message of
       wm_Destroy : begin
                    DeleteDC (dc);
                    PostQuitMessage (0);
                    Exit;
                    end;
       wm_Create :  Down := False;
       WM_LBUTTONDOWN, WM_LBUTTONUP : Down := not Down;
       wm_MouseMove : begin
                      If Down then begin
                      xpos := LoWord ( LParam );
                      ypos := HiWord ( LParam );
                      InvalidateRect(Window, nil, False);
                      end;
                      end;
       wm_Paint:    begin
                    If Down then begin
                    dc := BeginPaint (Window, MyPaint);
                    Ellipse (dc, xPos, yPos, xPos + 2, yPos + 2);
                    EndPaint (Window, MyPaint);
                    ReleaseDC (Window, dc);
                    end;
                    end;
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

