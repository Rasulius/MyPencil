{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

program Project1;

uses
  Messages, Windows, OpenGL;

const
  AppName = 'WinError';

var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  lpMsgBuf: PChar;

// ��������� ���������� ����� ��������� PIXELFORMATDESCRIPTOR
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // ������ ������� ��������
 nPixelFormat : Integer;
Begin
 With pfd do begin
  nSize := sizeof (TPIXELFORMATDESCRIPTOR); // ������ ���������
  nVersion := 1;                            // ����� ������
  dwFlags := PFD_DRAW_TO_WINDOW OR PFD_SUPPORT_OPENGL; // ��������� ������� ������, ������������ ���������� � ���������
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
         LParam : LongInt) : LongInt; export; stdcall;
Begin
  WindowProc := 0;
  case Message of
  wm_Destroy :
      begin
      wglDeleteContext (hrc); // �������� ��������� ���������������
      ReleaseDC (Window, dc);
      DeleteDC (dc);
      PostQuitMessage (0);
      Exit;
      end;
  wm_Create:
      begin
//      dc := GetDC (Window);
      SetDCPixelFormat (dc);
      hrc := wglCreateContext (dc);

      FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
                    nil, GetLastError(), LANG_NEUTRAL, @lpMsgBuf, 0, nil);

      MessageBox(Window, lpMsgBuf, 'GetLastError', MB_OK);

      end;
  wm_Paint:
      begin
      BeginPaint (Window, ps);
      wglMakeCurrent (dc, hrc);    // ���������� ������� �������� ���������������

      glClearColor (0.5, 0.1, 0.2, 1.0);
      glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // ��������� ����� ����� � ����� �������

      wglMakeCurrent (0,0);
      EndPaint (Window, ps);
      end;

  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
  End;

procedure WinMain;
Begin
  With WindowClass do
      begin
      Style := CS_HRedraw OR cs_VRedraw;
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

  Window := CreateWindow (AppName, AppName,
      ws_OverLappedWindow OR ws_ClipChildren OR ws_ClipSiBlings, // ����������� ��� OpenGL
      cw_UseDefault, cw_UseDefault,
      cw_UseDefault, cw_UseDefault,
      HWND_DESKTOP, 0, HInstance, nil);
      ShowWindow (Window, CmdShow);
      UpdateWindow (Window);
  While GetMessage (Message, 0, 0, 0) do
      begin
      TranslateMessage (Message);
      DispatchMessage (Message);
      end;
  Halt (Message.wParam);
end;

begin
  WinMain;
end.

