{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

program Cube;

uses
  Messages, Windows, OpenGL, DGLUT;

const
  AppName = 'Idle';

var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  glnWidth, glnHeight : GLsizei;
  Angle: GLfloat;
  wrkX, wrkY : Array [0..49] of GLfloat;
  AppActive : bool;

// ��������� ���������� ����� ��������� PIXELFORMATDESCRIPTOR
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // ������ ������� ��������
 nPixelFormat : Integer;
Begin
 FillChar(pfd, SizeOf(pfd), 0);

 pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat(DC, @pfd);
 SetPixelFormat(DC, nPixelFormat, @pfd);
end;

{=======================================================================
��������� ���������� ���������}
procedure DrawScene;
var
 i : 0..49;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
  glRotatef(2 * Angle, 0.0, 1.0, 0.0);  // ������� �� ����
  glRotatef(Angle, 0.0, 0.0, 1.0);  // ������� �� ����
  {���� ��������� ����� �������}
  For i := 0 to 49 do begin
    glPushMatrix;                    // ��������� �����

    glTranslatef(wrkX [i], wrkY [i], 0.0);
    glRotatef(-7.2 * i, 0.0, 0.0, 1.0); // ������� ������

    glScalef (1.0, 7.0, 1.0);
    glutSolidCube (0.1);

    glPopMatrix;                     // ��������� � �����
  end;

  glPopMatrix;

  SwapBuffers(DC);                 // ����� ������
end;

procedure Idle;
begin
  // ������ "���" ���������� �������� ����
  Angle := Angle + 0.1;
  If Angle >= 360.0 then Angle := 0.0;
  InvalidateRect(Window, nil, False);
end;

function WindowProc (Window : HWnd; Message, WParam : Word;
         LParam : LongInt) : LongInt; export; stdcall;
var
  i : 0..49;
Begin
  WindowProc := 0;
  case Message of
  wm_Destroy :
      begin
      wglMakeCurrent(0, 0);
      wglDeleteContext (hrc); // �������� ��������� ���������������
      ReleaseDC (Window, dc);
      DeleteDC (dc);      
      PostQuitMessage (0);
      Exit;
      end;
  wm_Create:
      begin
      dc := GetDC (Window);
      SetDCPixelFormat (dc);
      hrc := wglCreateContext (dc); // �������� ��������� ���������������
      wglMakeCurrent (dc, hrc);    // ���������� ������� �������� ���������������

      For i := 0 to 49 do begin
          wrkX [i] := sin (Pi / 25 * i);
          wrkY [i] := cos (Pi / 25 * i);
      end;

      glEnable(GL_DEPTH_TEST);// ��������� ���� �������
      // ��������� �������� ����� 0
      glEnable(GL_LIGHTING); // ��������� ������ � �������������
      glEnable(GL_LIGHT0);   // �������� �������� ����� 0
      glEnable (GL_COLOR_MATERIAL);
      glColor3f (0.0, 0.0, 1.0);
      glClearColor (1.0, 1.0, 1.0, 1.0);

      Angle := 0;

      end;
  wm_Size:  // ��� ��������� �������� ���� ����������� ������� ������� ����
      begin
      glnWidth := LoWord (lParam);         // ������ ����
      glnHeight := HiWord (lParam);        // ������ ����
      glViewport(0, 0, glnWidth, glnHeight);
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      gluPerspective(18.0, glnWidth / glnHeight, 7.0, 13.0);
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity;
      glTranslatef(0.0, 0.0, -9.0);
      glRotatef(60.0, 1.0, 0.0, 1.0);
      InvalidateRect(Window, nil, False);
      end;
 WM_ACTIVATEAPP:
      If (wParam=WA_ACTIVE) or (wParam=WA_CLICKACTIVE)
         then AppActive := True
         else AppActive := False;
  wm_Paint:
      begin
      dc := BeginPaint (Window, ps);
      DrawScene;
      EndPaint (Window, ps);
      end;
  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
  With WindowClass do begin
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
      ws_OverLappedWindow or ws_ClipChildren or ws_ClipSiBlings,
      cw_UseDefault, cw_UseDefault,
      cw_UseDefault, cw_UseDefault,
      HWND_DESKTOP, 0, HInstance, nil);
  ShowWindow (Window, CmdShow);
  While True do begin
    If PeekMessage(Message,0, 0, 0, pm_NoRemove) then begin
       If not GetMessage(Message, 0, 0, 0 )
          then Break
          else begin
            TranslateMessage(Message);
            DispatchMessage(Message);
          end;
        end
        else
        If AppActive
           then Idle
           else WaitMessage;
  end;
end.
