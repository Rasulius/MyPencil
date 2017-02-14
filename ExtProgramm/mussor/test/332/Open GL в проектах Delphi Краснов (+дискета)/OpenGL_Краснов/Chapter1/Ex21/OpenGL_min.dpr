{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

program OpenGL_min;

uses
  Messages, Windows, OpenGL;

const
  AppName = 'OpenGL_Min';

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;            // �������� ��������������� OpenGL
  MyPaint : TPaintStruct;

// ��������� ���������� ����� ��������� PIXELFORMATDESCRIPTOR
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor; // ������ ������� ��������
 nPixelFormat : Integer;
Begin
 With pfd do begin
  nSize := sizeof (TPixelFormatDescriptor); // ������ ���������
  nVersion := 1;                            // ����� ������
  dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL; // ��������� ������� ������, ������������ ���������� � ���������
  iPixelType := PFD_TYPE_RGBA; // ����� ��� ����������� ������
  cColorBits := 16;            // ����� ������� ���������� � ������ ������ �����
  cRedBits := 0;               // ����� ������� ���������� �������� � ������ ������ RGBA
  cRedShift := 0;              // �������� �� ������ ����� ������� ���������� �������� � ������ ������ RGBA
  cGreenBits := 0;             // ����� ������� ���������� ������� � ������ ������ RGBA
  cGreenShift := 0;            // �������� �� ������ ����� ������� ���������� ������� � ������ ������ RGBA
  cBlueBits := 0;              // ����� ������� ���������� ������ � ������ ������ RGBA
  cBlueShift := 0;             // �������� �� ������ ����� ������� ���������� ������ � ������ ������ RGBA
  cAlphaBits := 0;             // ����� ������� ���������� ����� � ������ ������ RGBA
  cAlphaShift := 0;            // �������� �� ������ ����� ������� ���������� ����� � ������ ������ RGBA
  cAccumBits := 0;             // ����� ����� ������� ���������� � ������ ������������
  cAccumRedBits := 0;          // ����� ������� ���������� �������� � ������ ������������
  cAccumGreenBits := 0;        // ����� ������� ���������� ������� � ������ ������������
  cAccumBlueBits := 0;         // ����� ������� ���������� ������ � ������ ������������
  cAccumAlphaBits := 0;        // ����� ������� ���������� ����� � ������ ������������
  cDepthBits := 32;            // ������ ������ ������� (��� z)
  cStencilBits := 0;           // ������ ������ ���������
  cAuxBuffers := 0;            // ����� ��������������� �������
  iLayerType := PFD_MAIN_PLANE;// ��� ���������
  bReserved := 0;              // ����� ���������� ��������� � ������� �����
  dwLayerMask := 0;            // ������������
  dwVisibleMask := 0;          // ������ ��� ���� ������������ ������ ���������
  dwDamageMask := 0;           // ������������
 end;

 nPixelFormat := ChoosePixelFormat (hdc, @pfd); // ������ ������� - �������������� �� ��������� ������ ��������
 SetPixelFormat (hdc, nPixelFormat, @pfd);      // ������������� ������ �������� � ��������� ����������
End;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Create:
       begin
       dc := GetDC (Window);
       SetDCPixelFormat (dc);        // ���������� ������ ��������
       hrc := wglCreateContext (dc); // ������ �������� ��������������� OpenGL
       ReleaseDC (Window, dc);
       end;
  wm_Paint:
       begin
       dc := BeginPaint (Window, MyPaint);
       wglMakeCurrent (dc, hrc);     // ������������� ������� �������� ���������������

{************ ����� ������������� ������� ��������� OpenGL **************}

       glClearColor (0.85, 0.75, 0.5, 1.0); // ����������� ����� ����
       glClear (GL_COLOR_BUFFER_BIT);       // ������������ ����� ����

{************************************************************************}

       wglMakeCurrent (dc, 0); // ����� ����������� ������ ����������,
                               // ����� �������� ����� �� �������������

       EndPaint (Window, MyPaint);
       ReleaseDC (Window, dc);
       end;
  wm_Destroy :
       begin
       wglDeleteContext (hrc); // �������� ��������� ���������������
       DeleteDC (dc);
       PostQuitMessage (0);
       Exit;
       end;

  end; // case
  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
  With WindowClass do
       begin
       Style := cs_HRedraw or cs_VRedraw;
       lpfnWndProc := @WindowProc;
       cbClsExtra := 0;
       cbWndExtra := 0;
       hInstance := 0;
       hCursor := LoadCursor (0, idc_Arrow);
       lpszClassName := AppName;
       end;
  RegisterClass (WindowClass);
  Window := CreateWindow (AppName, AppName,
       ws_OverLappedWindow or ws_ClipChildren
          or ws_ClipSiBlings, // ����������� ��� OpenGL
       cw_UseDefault, cw_UseDefault,
       cw_UseDefault, cw_UseDefault,
       HWND_DESKTOP, 0, HInstance, nil);
       ShowWindow (Window, CmdShow);
       UpdateWindow (Window);
  While GetMessage (Message, 0, 0, 0) do begin
       TranslateMessage (Message);
       DispatchMessage (Message);
  end;
  Halt (Message.wParam);
end.
