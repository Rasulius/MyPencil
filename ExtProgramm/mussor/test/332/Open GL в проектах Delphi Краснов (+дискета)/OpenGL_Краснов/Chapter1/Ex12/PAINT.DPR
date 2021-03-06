{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

program Paint;

{****************** ������������� ��������� ����������  *****************}
{* ������� GDI (��������� ������������ ����������) ��������������� �    *}
{* ��������� ���������� ����� ����������� ��������� ������, ����������  *}
{* "�������� ����������".                                               *}
{* ��������� "�������� ����������" �������� �������� �������������� ��- *}
{* ��������, � ����� ��������� �������� ����������� - �����, ���������, *}
{* ����� � �.�. ������ ��� �������� ��������� ������� ��� �����������   *}
{* ����������, ���������� ��������� ������ �������� �������� ���������� *}
{* ������.                                                              *}
{* ����� ����, ��� ��������� ���������� � ����������, ��� ������ ���    *}
{* ����������.                                                          *}
{************************************************************************}

uses
   Windows, Messages;

const
  AppName = 'WinPaint';

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
Var
    dc : HDC;               { ������ �� ��������, ������ �������������� ��� ������ � ����� }
    MyPaint : TPaintStruct; { ��������� ��� ������ ������� ����������� }
    Brush : hBrush;         { ��� "�����" }
    Pen : hPen;             { ��� "��������" }
Begin
  WindowProc := 0;
  case Message of
       wm_Destroy : begin
                    PostQuitMessage (0);
                    Exit;
                    end;
       wm_Paint:    begin { ��������� ���������� ��� ������������� ����������� ���� }
                    dc := BeginPaint (Window, MyPaint); { �������� �������� ���������� }
// ������� ����������� ����������� ��������� - �������� ������ �� �������
                    Brush := CreateSolidBrush (RGB (0, 255, 255)); { ����� }
                    Pen := CreatePen (PS_SOLID, 1, RGB (0, 0, 0)); { �������� }
                    SelectObject (dc, Brush); { �������� ������ ��� �������� ��������� }
                    SelectObject (dc, Pen);   { �������� ������ ��� �������� ��������� }
                    Rectangle (dc, 10, 10, 110, 110); { ������ ������������� }
                    Brush := CreateSolidBrush (RGB (255, 255, 0));
                    Pen := CreatePen (PS_SOLID, 1, RGB (255, 0, 0));
                    SelectObject (dc, Brush);
                    SelectObject (dc, Pen);
                    Ellipse (dc, 130, 10, 230, 110); { ������ ������ }
                    DeleteObject (Pen); { ��� ����������� ���������������� ��������� }
                    DeleteObject (Brush); { ���������� ������� ��� ����������� ������� }
                    EndPaint (Window, MyPaint); { ���������� �������� �� ����������� � ���� }
                    ReleaseDC (Window, dc); { ����������� �������� }
                    end;
  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

procedure WinMain;
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
       Window := CreateWindow (AppName, '������ ��������� � ����',
        ws_OverlappedWindow, 100, 100, 250, 150, 0, 0, HInstance, nil);
       ShowWindow (Window, CmdShow);
       UpdateWindow (Window);
       while GetMessage (Message, 0, 0, 0) do
        begin
         TranslateMessage (Message);
         DispatchMessage (Message);   
        end;
      Halt (Message.wParam);
End;

begin
  WinMain;
end.
