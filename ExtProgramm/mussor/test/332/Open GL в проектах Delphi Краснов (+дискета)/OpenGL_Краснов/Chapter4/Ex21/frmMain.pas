{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

// (c) Brian Paul

unit frmMain;
interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, SysUtils, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;
    Angle: GLfloat;
    uTimerId : uint;
    view_rotx       : GLfloat;
    view_roty       : GLfloat;
    view_rotz       : GLfloat;
    gear1,
    gear2,
    gear3 : GLint;

    // для подсчета количества кадров в секунду
    newCount, frameCount, lastCount : LongInt;
    fpsRate : GLfloat;

    procedure SetDCPixelFormat;
    procedure Init;
    procedure Gear(inner_radius, outer_radius, width: GLfloat; teeth: GLint; tooth_depth: GLfloat);

  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses mmSystem;

{$R *.DFM}

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
    pos     : array[0..3] of GLfloat = (5.0, 5.0, 10.0, 0.0);
    red     : array[0..3] of GLfloat = (0.8, 0.1,  0.0, 1.0);
    green   : array[0..3] of GLfloat = (0.0, 0.8,  0.2, 1.0);
    blue    : array[0..3] of GLfloat = (0.2, 0.2,  1.0, 1.0);
begin
    // инициализация вида
    glViewport(0, 0, ClientWidth, ClientHeight);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    glFrustum( -1.0, 1.0, -ClientHeight/ClientWidth,
               ClientHeight/ClientWidth, 5.0, 60.0 );
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    glTranslatef( 0.0, 0.0, -40.0 );
    // источник света
    glLightfv( GL_LIGHT0, GL_POSITION, @pos );
    glEnable( GL_CULL_FACE );
    glEnable( GL_LIGHTING );
    glEnable( GL_LIGHT0 );
    glEnable( GL_DEPTH_TEST );

    // списки шестеренок
    gear1 := glGenLists(1);       // генерируется идентификатор списка
    glNewList(gear1, GL_COMPILE);
      glMaterialfv( GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @red );
      Gear( 1.0, 4.0, 1.0, 20, 0.7 );
    glEndList;

    gear2 := glGenLists(1);
      glNewList(gear2, GL_COMPILE);
      glMaterialfv( GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @green );
      Gear( 0.5, 2.0, 2.0, 10, 0.7 );
    glEndList;

    gear3 := glGenLists(1);
      glNewList(gear3, GL_COMPILE);
      glMaterialfv( GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @blue );
      Gear( 1.3, 2.0, 0.5, 10, 0.7 );
    glEndList;

    glEnable( GL_NORMALIZE );
end;

{=======================================================================
Рисование шестеренки}
// Параметры:
//         inner_radius - радиус отверстия внутри
//         outer_radius - радиус до центра зубьев
//         width - ширина шестеренки
//         teeth - количество зубьев
//         tooth_depth - глубина зубьев
procedure TfrmGL.Gear(inner_radius, outer_radius, width: GLfloat; teeth: GLint; tooth_depth: GLfloat);
var
    i           : GLint;
    r0, r1, r2  : GLfloat;
    angle, da   : GLfloat;
    u, v, len   : GLfloat;
begin
    r0 := inner_radius;
    r1 := outer_radius - tooth_depth/2.0;
    r2 := outer_radius + tooth_depth/2.0;

    da := 2.0*Pi/teeth/4.0;
    glShadeModel( GL_FLAT );
    glNormal3f( 0.0, 0.0, 1.0 );

    // передняя сторона
    glBegin( GL_QUAD_STRIP );
    for i := 0 to teeth do
    begin
        angle := i * 2.0*Pi/teeth;
        glVertex3f( r0*cos(angle), r0*sin(angle), width*0.5 );
        glVertex3f( r1*cos(angle), r1*sin(angle), width*0.5 );
        glVertex3f( r0*cos(angle), r0*sin(angle), width*0.5 );
        glVertex3f( r1*cos(angle+3*da), r1*sin(angle+3*da), width*0.5 );
    end;
    glEnd;

    // передняя сторона зубьев
    glBegin( GL_QUADS );
    da := 2.0*Pi/teeth/4.0;
    for i := 0 to teeth - 1 do
    begin
        angle := i*2.0*Pi/teeth;

        glVertex3f( r1*cos(angle),      r1*sin(angle),      width*0.5 );
        glVertex3f( r2*cos(angle+da),   r2*sin(angle+da),   width*0.5 );
        glVertex3f( r2*cos(angle+2*da), r2*sin(angle+2*da), width*0.5 );
        glVertex3f( r1*cos(angle+3*da), r1*sin(angle+3*da), width*0.5 );
    end;
    glEnd;

    glNormal3f( 0.0, 0.0, -1.0 );

    // задняя сторона
    glBegin( GL_QUAD_STRIP );
    for i := 0 to teeth do
    begin
        angle := i*2.0*Pi/teeth;
        glVertex3f( r1*cos(angle), r1*sin(angle), -width*0.5 );
        glVertex3f( r0*cos(angle), r0*sin(angle), -width*0.5 );
        glVertex3f( r1*cos(angle+3*da), r1*sin(angle+3*da), -width*0.5 );
        glVertex3f( r0*cos(angle), r0*sin(angle), -width*0.5 );
    end;
    glEnd;

    // обратная сторона зубьев
    glBegin( GL_QUADS );
    da := 2.0*Pi/teeth/4.0;
    for i := 0 to teeth - 1 do
    begin
        angle := i*2.0*Pi/teeth;

        glVertex3f( r1*cos(angle+3*da), r1*sin(angle+3*da), -width*0.5 );
        glVertex3f( r2*cos(angle+2*da), r2*sin(angle+2*da), -width*0.5 );
        glVertex3f( r2*cos(angle+da),   r2*sin(angle+da),   -width*0.5 );
        glVertex3f( r1*cos(angle),      r1*sin(angle),      -width*0.5 );
    end;
    glEnd;

    // внешняя сторона зубьев
    glBegin( GL_QUAD_STRIP );
    for i := 0 to teeth - 1 do
    begin
        angle := i*2.0*Pi/teeth;

        glVertex3f( r1*cos(angle),      r1*sin(angle),       width*0.5 );
        glVertex3f( r1*cos(angle),      r1*sin(angle),      -width*0.5 );
        u   := r2*cos(angle+da) - r1*cos(angle);
        v   := r2*sin(angle+da) - r1*sin(angle);
        len := sqrt( u*u + v*v );
        u   := u/len;
        v   := v/len;
        glNormal3f( v, -u, 0.0 );
        glVertex3f( r2*cos(angle+da),   r2*sin(angle+da),    width*0.5 );
        glVertex3f( r2*cos(angle+da),   r2*sin(angle+da),   -width*0.5 );
        glNormal3f( cos(angle), sin(angle), 0.0 );
        glVertex3f( r2*cos(angle+2*da), r2*sin(angle+2*da),  width*0.5 );
        glVertex3f( r2*cos(angle+2*da), r2*sin(angle+2*da), -width*0.5 );
        u   := r1*cos(angle+3*da) - r2*cos(angle+2*da);
        v   := r1*sin(angle+3*da) - r2*sin(angle+2*da);
        glNormal3f( v, -u, 0.0 );
        glVertex3f( r1*cos(angle+3*da), r1*sin(angle+3*da),  width*0.5 );
        glVertex3f( r1*cos(angle+3*da), r1*sin(angle+3*da), -width*0.5 );
        glNormal3f( cos(angle), sin(angle), 0.0 );
    end;

    glVertex3f( r1*cos(0), r1*sin(0), width*0.5 );
    glVertex3f( r1*cos(0), r1*sin(0), -width*0.5 );

    glEnd;

    glShadeModel( GL_SMOOTH );

    // внутренний цилиндр
    glBegin( GL_QUAD_STRIP );
    for i := 0 to teeth do
    begin
        angle := i*2.0*Pi/teeth;
        glNormal3f( -cos(angle), -sin(angle), 0.0 );
        glVertex3f( r0*cos(angle), r0*sin(angle), -width*0.5 );
        glVertex3f( r0*cos(angle), r0*sin(angle), width*0.5 );
    end;
    glEnd;
end;

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  frmGL.Angle := frmGL.Angle + 0.2;
  InvalidateRect(frmGL.Handle, nil, False);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT );
  glPushMatrix;
  glRotatef( view_rotx, 1.0, 0.0, 0.0 );
  glRotatef( view_roty, 0.0, 1.0, 0.0 );
  glRotatef( view_rotz, 0.0, 0.0, 1.0 );

  glPushMatrix;
  glTranslatef( -3.0, -2.0, 0.0 );
  glRotatef( angle, 0.0, 0.0, 1.0 );
  glCallList(gear1);
  glPopMatrix;

  glPushMatrix;
  glTranslatef( 3.1, -2.0, 0.0 );
  glRotatef( -2.0*angle-9.0, 0.0, 0.0, 1.0 );
  glCallList(gear2);
  glPopMatrix;

  glPushMatrix;
  glTranslatef( -3.1, 4.2, 0.0 );
  glRotatef( -2.0*angle-25.0, 0.0, 0.0, 1.0 );
  glCallList(gear3);
  glPopMatrix;

  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);

  // определяем и выводим количество кадров в секунду
  newCount := GetTickCount;
  Inc(frameCount);
  If (newCount - lastCount) > 1000 then  begin // прошла секунда
     fpsRate := frameCount * 1000 / (newCount - lastCount);
     Caption := 'FPS - ' + FloatToStr (fpsRate);
     lastCount := newCount;
     frameCount := 0;
  end;
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  view_rotx := 20.0;
  view_roty := 30.0;
  view_rotz := 0.0;

  lastCount := GetTickCount;
  frameCount := 0;

  uTimerID := timeSetEvent (2, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  Init;
  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  timeKillEvent(uTimerID);
  glDeleteLists (gear1, 1);
  glDeleteLists (gear2, 1);
  glDeleteLists (gear3, 1);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_ESCAPE : Close;
    VK_Left   : view_roty := view_roty + 5.0;
    VK_Right  : view_roty := view_roty - 5.0;
    VK_Up     : view_rotx := view_rotx + 5.0;
    VK_Down   : view_rotx := view_rotx - 5.0;
    Ord('Z')  : If ssShift in Shift
                  then view_rotz := view_rotz + 5.0
                  else view_rotz := view_rotz - 5.0;
  end;
end;

{=======================================================================
Устанавливаем формат пикселей}
procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;

begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;


end.

