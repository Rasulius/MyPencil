{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

{*********************************************************************}

{(c) Copyright 1993, Silicon Graphics, Inc.

ALL RIGHTS RESERVED}

program Select;

uses
  Messages,  Windows,  OpenGL;

const
  AppName = 'GL_Select';
  MAXOBJS = 20;                       // ������������ ����� ��������
  MAXSELECT = 4;                      // ������ ������ ������

{--- ������ ��� �������� �������� ---}
type
  TGLObject = record                  // ������ - �����������
     {������� ������������}
     v1 : Array [0..1] of GLFloat;
     v2 : Array [0..1] of GLFloat;
     v3 : Array [0..1] of GLFloat;
     color : Array [0..2] of GLFloat; // ���� �������
  end;

Var
  Window : HWnd;
  Message : TMsg;
  WindowClass : TWndClass;
  windW, windH : GLint;
  dc : HDC;
  hrc : HGLRC;
  ps : TPAINTSTRUCT;
  objects : Array [0..MAXOBJS - 1] of TGLObject;  // ������ ��������
  vp : Array [0..3] of GLint;
  selectBuf : Array [0..MAXSELECT - 1] of GLuint;// ����� ������
  hit : GLint;
  mouseX, mouseY : Integer;

{=======================================================================
������������� ��������}
procedure InitObjects;
var
  i : GLint ;
  x, y : GLfloat ;
begin
  For i := 0 to MAXOBJS - 1 do begin
    x := random(300) - 150;
    y := random(300) - 150;
    // ������� ������������ - ��������
    objects[i].v1[0] := x + random(50) - 25;
    objects[i].v2[0] := x + random(50) - 25;
    objects[i].v3[0] := x + random(50) - 25;
    objects[i].v1[1] := y + random(50) - 25;
    objects[i].v2[1] := y + random(50) - 25;
    objects[i].v3[1] := y + random(50) - 25;
    // ����� ���������� ����������
    objects[i].color[0] := (random(100) + 50) / 150.0;
    objects[i].color[1] := (random(100) + 50) / 150.0;
    objects[i].color[2] := (random(100) + 50) / 150.0;
  end;
end;

{=======================================================================
��������� ������� ��������}
procedure Render (mode : GLenum); // �������� - ����� (������/���������)
var
  i : GLuint;
begin
  For i := 0 to MAXOBJS - 1 do begin
    If mode = GL_SELECT then glLoadName(i); // �������� ���������� �����
    glColor3fv(@objects[i].color);          // ���� ��� ���������� �������
    glBegin(GL_POLYGON);                    // ������ �����������
        glVertex2fv(@objects[i].v1);
        glVertex2fv(@objects[i].v2);
        glVertex2fv(@objects[i].v3);
    glEnd;
  end;
end;

{=======================================================================
����� ������� � �����}
function DoSelect(x : GLint; y : GLint) : GLint;
var
  hits : GLint;
begin
  glSelectBuffer(MAXSELECT, @selectBuf); // �������� ������ ������
  glRenderMode(GL_SELECT); // ����� ������
  // ����� ������ ����� ��� ������ ��������� ������
  glInitNames;             // ������������� ����� ����
  glPushName(0);           // ��������� ����� � ���� ����

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPickMatrix(x, windH-y, 4, 4, @vp);
  gluOrtho2D(-175, 175, -175, 175);
  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_SELECT); // ������ ������ �������� � �������

  hits := glRenderMode(GL_RENDER);

  if hits <= 0
     then DoSelect := -1
     else DoSelect := selectBuf[3];
end;

{=======================================================================
��������� ����� ������� ����� h}
procedure RecolorTri (h : GLint);
begin
  objects[h].color[0] := (random(100) + 50) / 150.0;
  objects[h].color[1] := (random(100) + 50) / 150.0;
  objects[h].color[2] := (random(100) + 50) / 150.0;
end;

{=======================================================================
�������� ��������� ��������� ��������}
procedure DrawScene;
begin
  glPushMatrix;

  glGetIntegerv(GL_VIEWPORT, @vp);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluOrtho2D(-175, 175, -175, 175);
  glMatrixMode(GL_MODELVIEW);

  glClear(GL_COLOR_BUFFER_BIT);

  Render(GL_RENDER); // ������ ������ �������� ��� ������

  glPopMatrix;

  glFlush;
end;

procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPIXELFORMATDESCRIPTOR; // ������ ������� ��������
 nPixelFormat : Integer;
Begin
 With pfd do
  begin
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
  dwLayerMask := 0;            //
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
  wm_Destroy : begin
               wglMakeCurrent (0, 0);
               wglDeleteContext (hrc);
               ReleaseDC (Window, DC);
               DeleteDC (DC);
               PostQuitMessage (0);
               Exit;
               end;
  WM_CREATE:   begin
               Randomize;
               dc := GetDC (Window);
               SetDCPixelFormat (dc);
               hrc := wglCreateContext (dc);
               wglMakeCurrent (dc, hrc);
               InitObjects;
               end;
  WM_SIZE:     begin
               windW := LOWORD (lParam);
               windH := HIWORD (lParam);
               glViewport(0, 0, windW, windH);
               end;
  WM_PAINT:    begin
               BeginPaint (Window, ps);
               DrawScene;
               EndPaint (Window, ps);
               end;
  WM_LBUTTONDOWN: {--- ������� �� ������ ���� ---}
               begin
               mouseX := LoWord (lParam);
               mouseY := HiWord (lParam);
               hit := DoSelect(mouseX, mouseY);    // ����� ������� ��� ��������
               If hit <> -1 then RecolorTri(hit);  // ������������� ������
               InvalidateRect(Window, nil, False); // ��������� ��������
               end;
  end; // case

  WindowProc := DefWindowProc (Window, Message, WParam, LParam);
End;

Begin
   With WindowClass do begin
     Style := cs_HRedraw or cs_VRedraw;
     lpfnWndProc := @WindowProc;
     hCursor := LoadCursor (0, idc_Arrow);
     lpszClassName := AppName;
   end;
   RegisterClass (WindowClass);
   Window := CreateWindow (AppName, AppName,
   ws_OverlappedWindow or ws_ClipChildren or ws_Clipsiblings,
   cw_UseDefault, cw_UseDefault,  cw_UseDefault, cw_UseDefault,
   HWND_DESKTOP, 0, HInstance, nil);
   ShowWindow (Window, CmdShow);
   While GetMessage (Message, 0, 0, 0) do begin
     TranslateMessage (Message);
     DispatchMessage (Message);
   end;
End.

