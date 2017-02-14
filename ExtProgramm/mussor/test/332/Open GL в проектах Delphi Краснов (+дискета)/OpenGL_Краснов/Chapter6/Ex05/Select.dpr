{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

program Select;

uses
  Messages,  Windows,  OpenGL;

const
  AppName = 'GLSelect';
  MaxSelect = 4;     // ������ ������ ������

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  ps : TPaintStruct;
  mouseX, mouseY : Integer;                       // ���������� �������
  windW, windH : GLint;                           // ������� ����
  {--- ��� ������ ��������� ---}
  vp : Array [0..3] of GLint;                     // ������ ������� �������
  SelectBuf : Array [0..MaxSelect - 1] of GLint;  // ������ ��� ������ ������
  hit : GLint;

{=======================================================================
��������� ��������}
procedure Render (mode : GLenum); // �������� - ����� (������/���������)
begin
 // ������� �����������
 If mode = GL_SELECT then glLoadName (1); // ������� ��� ������ 1
 glColor3f (1.0, 0.0, 0.0);
 glBegin(GL_POLYGON);
       glVertex2f(-1, -1);
       glVertex2f(-1, 1);
       glVertex2f(-0.1, 0);
 glEnd;

 // ����� �����������
 If mode = GL_SELECT then glLoadName (2); // ������� ��� ������ 2
 glColor3f (0.0, 0.0, 1.0);
 glBegin(GL_POLYGON);
       glVertex2f(0.1, 0);
       glVertex2f(1, 1);
       glVertex2f(1, -1);
 glEnd;
end;

{=======================================================================
����� ������� � �����}
function DoSelect(x : GLint; y : GLint) : GLint;
var
 hits : GLint;
begin
 glRenderMode(GL_SELECT);               // �������� ����� ������
 // ����� ������ ����� ��� ������ ��������� ������
 glInitNames;                           // ������������� ����� ����
 glPushName(0);                         // ��������� ����� � ���� ����

 glLoadIdentity;
 gluPickMatrix(x, windH - y, 2, 2, @vp);

 Render(GL_SELECT); // ������ ������� � ����������� ��������

 hits := glRenderMode(GL_SELECT);

 if hits <= 0
    then Result := -1
    else Result := SelectBuf [(hits - 1) * 4 + 3];
end;

{=======================================================================
������ �������}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;

 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; export; stdcall;
begin
  WindowProc := 0;
  case Message of
  WM_PAINT:    begin
               BeginPaint (Window, ps);

               glLoadIdentity;
               glClear(GL_COLOR_BUFFER_BIT);
               Render(GL_RENDER); // ������ ������ �������� ��� ������

               SwapBuffers (dc);
               EndPaint (Window, ps);
               end;
  WM_LBUTTONDOWN: {--- ������� �� ������ ���� ---}
               begin
               mouseX := LoWord (lParam);
               mouseY := HiWord (lParam);
               hit := DoSelect(mouseX, mouseY);    // ����� ������� ��� ��������
               case hit of
                 -1 : MessageBox (Window, '������ �����', '������ ������', 0);
                  1 : MessageBox (Window, '������� �����������', '������ ������', 0);
                  2 : MessageBox (Window, '����� �����������', '������ ������', 0);
               end;
               end;
  WM_DESTROY : begin
               wglMakeCurrent (0, 0);
               wglDeleteContext (hrc);
               ReleaseDC (Window, dc);
               DeleteDC (dc);
               PostQuitMessage (0);
               Exit;
               end;
  WM_CREATE:   begin
               dc := GetDC (Window);
               SetDCPixelFormat (dc);
               hrc := wglCreateContext (dc);
               wglMakeCurrent (dc, hrc);
               glSelectBuffer(MaxSelect, @SelectBuf); // �������� ������ ������
               glClearColor (0.5, 0.5, 0.75, 1.0);    // ���� ����
               end;
  WM_SIZE:     begin
               windW := LOWORD (lParam);
               windH := HIWORD (lParam);
               glViewport(0, 0, windW, windH);
               glGetIntegerv(GL_VIEWPORT, @vp);
               end;
  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
end;

begin
   With WindowClass do begin
     Style := cs_HRedraw or cs_VRedraw;
     lpfnWndProc := @WindowProc;
     hCursor := LoadCursor (0, idc_Arrow);
     lpszClassName := AppName;
   end;
   RegisterClass (WindowClass);
   Window := CreateWindow (AppName, '����� �������',
   ws_OverlappedWindow or ws_ClipChildren or ws_Clipsiblings,
   cw_UseDefault, cw_UseDefault,  cw_UseDefault, cw_UseDefault,
   HWND_DESKTOP, 0, HInstance, nil);
   ShowWindow (Window, CmdShow);
   While GetMessage (Message, 0, 0, 0) do begin
     TranslateMessage (Message);
     DispatchMessage (Message);
   end;
end.

