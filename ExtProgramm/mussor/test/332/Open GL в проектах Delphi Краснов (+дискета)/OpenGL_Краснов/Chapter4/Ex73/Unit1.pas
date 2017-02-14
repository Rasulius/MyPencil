{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 *  multimirror.c
 *  Celeste Fowler, 1997
 *
 *  An example of creating multiple reflections (as in a room with
 *  mirrors on opposite walls.
 *
 */}

unit Unit1;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, SysUtils, OpenGL, StdCtrls, Math;

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
    procedure SetDCPixelFormat;
    procedure draw_scene(passes:GLint; cullFace:GLenum;
		stencilVal:GLuint; mirror:GLint);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  time : LongInt;

var
  cone, qsphere:GLUquadricObj ;
  draw_passes : longint = 8;
  headsUp : Boolean = False;
  Angle : GLfloat = 0.0;

type
  TMirror = record
    verts : Array [0..3, 0..2] of GLfloat;
    scale : Array [0..2] of GLfloat;
    trans : Array [0..2] of GLfloat;
  end;

var
  mirrors : Array[0..1] of Tmirror;

const
  nMirrors : GLint = 2;

implementation

uses DGLUT;

{$R *.DFM}

{==========================================================================}
procedure Init;
const
  lightpos:Array[0..3]of GLfloat = (0.5, 0.75, 1.5, 1);
begin
  //* mirror on the left wall */
  With mirrors [0] do begin
       verts [0][0]:= -1.0;
       verts [0][1]:= -0.75;
       verts [0][2]:= -0.75;

       verts [1][0]:= -1.0;
       verts [1][1]:= 0.75;
       verts [1][2]:= -0.75;

       verts [2][0]:= -1.0;
       verts [2][1]:= 0.75;
       verts [2][2]:= 0.75;

       verts [3][0]:= -1.0;
       verts [3][1]:= -0.75;
       verts [3][2]:= 0.75;

       scale [0] := -1;
       scale [1] := 1;
       scale [2] := 1;

       trans [0] := 2;
       trans [1] := 0;
       trans [2] := 0;
  end;

  //* mirror on the right wall */
  With mirrors [1] do begin
       verts [0][0]:= 1.0;
       verts [0][1]:= -0.75;
       verts [0][2]:= 0.75;

       verts [1][0]:= 1.0;
       verts [1][1]:= 0.75;
       verts [1][2]:= 0.75;

       verts [2][0]:= 1.0;
       verts [2][1]:= 0.75;
       verts [2][2]:= -0.75;

       verts [3][0]:= 1.0;
       verts [3][1]:= -0.75;
       verts [3][2]:= -0.75;

       scale [0] := -1;
       scale [1] := 1;
       scale [2] := 1;

       trans [0] := -2;
       trans [1] := 0;
       trans [2] := 0;
  end;

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_POSITION, @lightpos);

  glEnable(GL_CULL_FACE);

  glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

  cone := gluNewQuadric;
  qsphere := gluNewQuadric;
end;

procedure make_viewpoint;
var
  localwidth : GLfloat;
  localheight : GLfloat;
begin
  If headsUp then begin
      localwidth:= (1 + 2*(draw_passes/nMirrors)) * 1.25;
      localheight := localwidth / tan( (30.0/360.0) * (2.0*PI) ) + 1;

      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      gluPerspective(60, 1, localheight - 3, localheight + 3);
      gluLookAt(0, localheight, 0, 0, 0, 0, 0, 0, 1);
      end
      else begin
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      gluPerspective(60, 1, 0.01, 4 + 2*(draw_passes / nMirrors));
      gluLookAt(-2, 0, 0.75, 0, 0, 0, 0, 1, 0);
  end;

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure draw_room;
const
  {material for the walls, floor, ceiling }
  wall_mat:Array[0..3]of GLfloat = (1.0, 1.0, 1.0, 1.0);
begin
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @wall_mat);
  glBegin(GL_QUADS);

  { floor }
  glNormal3f(0, 1, 0);
  glVertex3f(-1, -1, 1);
  glVertex3f(1, -1, 1);
  glVertex3f(1, -1, -1);
  glVertex3f(-1, -1, -1);

  { ceiling }
  glNormal3f(0, -1, 0);
  glVertex3f(-1, 1, -1);
  glVertex3f(1, 1, -1);
  glVertex3f(1, 1, 1);
  glVertex3f(-1, 1, 1);

  { left wall }
  glNormal3f(1, 0, 0);
  glVertex3f(-1, -1, -1);
  glVertex3f(-1, 1, -1);
  glVertex3f(-1, 1, 1);
  glVertex3f(-1, -1, 1);

  { right wall }
  glNormal3f(-1, 0, 0);
  glVertex3f(1, -1, 1);
  glVertex3f(1, 1, 1);
  glVertex3f(1, 1, -1);
  glVertex3f(1, -1, -1);

  { far wall }
  glNormal3f(0, 0, 1);
  glVertex3f(-1, -1, -1);
  glVertex3f(1, -1, -1);
  glVertex3f(1, 1, -1);
  glVertex3f(-1, 1, -1);

  {/* back wall */}
  glNormal3f(0, 0, -1);
  glVertex3f(-1, 1, 1);
  glVertex3f(1, 1, 1);
  glVertex3f(1, -1, 1);
  glVertex3f(-1, -1, 1);
  glEnd;
end;

procedure draw_cone;
const
  cone_mat:Array[0..3]of GLfloat  = (0.0, 0.5, 1.0, 1.0);
begin
  glPushMatrix;
  glTranslatef(0, -1, 0);
  glRotatef(-90, 1, 0, 0);

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @cone_mat);

  gluCylinder(cone, 0.3, 0, 1.25, 20, 1);

  glPopMatrix;
end;

procedure draw_sphere;
const
  sphere_mat:Array[0..3]of GLfloat = (1.0, 0.5, 0.0, 1.0);
begin
  glPushMatrix;
  glTranslatef(0, -0.3, 0);
  glRotatef(Angle, 0, 1, 0);
  glTranslatef(0.6, 0, 0);

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @sphere_mat);
  gluSphere(qsphere, 0.3, 20, 20);

  glPopMatrix;
end;

procedure draw_mirror(m : TMirror);
begin
  glBegin(GL_QUADS);
    glVertex3fv(@m.verts[0]);
    glVertex3fv(@m.verts[1]);
    glVertex3fv(@m.verts[2]);
    glVertex3fv(@m.verts[3]);
  glEnd;
end;

function reflect_through_mirror(m:TMirror ; cullFace:GLenum):GLenum;
var
  newCullFace:GLenum;
begin
  If cullface = GL_FRONT
     then newCullFace := GL_BACK
     else newCullFace := GL_FRONT;

  glMatrixMode(GL_PROJECTION);
  glScalef(m.scale[0], m.scale[1], m.scale[2]);
  glTranslatef(m.trans[0], m.trans[1], m.trans[2]);
  glMatrixMode(GL_MODELVIEW);

  {/* must flip the cull face since reflection reverses the orientation
   * of the polygons */}
  glCullFace(newCullFace);
  Result:=newCullFace;
end;

procedure undo_reflect_through_mirror(m : TMirror ; cullFace : GLenum);
begin
  glMatrixMode(GL_PROJECTION);
  glTranslatef(-m.trans[0], -m.trans[1], -m.trans[2]);
  glScalef(1.0/m.scale[0], 1.0/m.scale[1], 1.0/m.scale[2]);
  glMatrixMode(GL_MODELVIEW);

  glCullFace(cullFace);
end;

const
  stencilmask : longint = $FFFFFFFF;

procedure TfrmGL.draw_scene(passes:GLint; cullFace:GLenum;
		stencilVal:GLuint; mirror: GLint);
var
  newCullFace : GLenum;
  passesPerMirror, passesPerMirrorRem, i : GLint;
  curMirror, drawMirrors : GLUint;
begin
  {/* one pass to draw the real scene */}
  passes := passes - 1;
  {/* only draw in my designated locations */}

  glStencilFunc(GL_EQUAL, stencilVal, stencilmask);
  {/* draw things which may obscure the mirrors first */}
  draw_sphere;
  draw_cone;

  {/* now draw the appropriate number of mirror reflections.  for
   * best results, we perform a depth-first traversal by allocating
   * a number of passes for each of the mirrors. */                }
  If mirror <> -1 then begin
      passesPerMirror := round(passes / (nMirrors - 1));
      passesPerMirrorRem := passes mod (nMirrors - 1);
      If passes > nMirrors - 1
         then drawMirrors := nMirrors - 1
         else drawMirrors := passes;
      end
      else begin
      {/* mirror == -1 means that this is the initial scene (there was no
        * mirror) */}
      passesPerMirror := round(passes / nMirrors);
      passesPerMirrorRem := passes mod nMirrors;
      If passes > nMirrors
         then drawMirrors := nMirrors
         else drawMirrors := passes;
  end;
  i := 0;
  While drawMirrors > 0 do begin
    curMirror := i mod nMirrors;
    If curMirror <> mirror then begin
      drawMirrors := drawMirrors - 1;

      {/* draw mirror into stencil buffer but not color or depth buffers */}
      glColorMask(False, False, False, False);
      glDepthMask(False);
      glStencilOp(GL_KEEP, GL_KEEP, GL_INCR);
      draw_mirror(mirrors[curMirror]);
      glColorMask(True, True, True, True);
      glDepthMask(True);
      glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

      {/* draw reflected scene */}
      newCullFace := reflect_through_mirror(mirrors[curMirror], cullFace);
      If passesPerMirrorRem<>0 then begin
          draw_scene(passesPerMirror + 1, newCullFace, stencilVal + 1, curMirror);
          passesPerMirrorRem := passesPerMirrorRem - 1;
          end
          else draw_scene(passesPerMirror, newCullFace, stencilVal + 1,
	  	 curMirror);
      undo_reflect_through_mirror(mirrors[curMirror], cullFace);

      {/* back to our stencil value */}
      glStencilFunc(GL_EQUAL, stencilVal, stencilmask);
    end;
    inc(i);
  end;

  draw_room;
end;

{=========================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glDisable(GL_STENCIL_TEST);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

  If not headsUp then glEnable(GL_STENCIL_TEST);

  draw_scene(draw_passes, GL_BACK, 0, -1);
  glDisable(GL_STENCIL_TEST);

  If headsUp then begin
      {/* draw a red floor on the original scene */}
      glDisable(GL_LIGHTING);
      glBegin(GL_QUADS);
      glColor3f(1, 0, 0);
      glVertex3f(-1, -0.95, 1);
      glVertex3f(1, -0.95, 1);
      glVertex3f(1, -0.95, -1);
      glVertex3f(-1, -0.95, -1);
      glEnd;
      glEnable(GL_LIGHTING);
   end;

  SwapBuffers(DC);
  EndPaint(Handle, ps);

  Angle := Angle + 0.25 * (GetTickCount - time) * 360 / 1000;
  If Angle >= 360.0 then Angle := 0.0;
  time := GetTickCount;

  InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Init;
  time := GetTickCount;
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight );
  make_viewpoint;
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
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
  If Key = VK_ESCAPE then Close;
  If Key = Ord ('H') then begin
     headsUp := not headsUp;
     make_viewpoint;
  end;
  If Key = VK_RIGHT then begin
     draw_passes := draw_passes + 1;
     make_viewpoint;
  end;
  If Key = VK_LEFT then begin
     draw_passes := draw_passes - 1;
     If draw_passes < 1 then draw_passes := 1;
     make_viewpoint;
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

 pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;

 nPixelFormat := ChoosePixelFormat(DC, @pfd);
 SetPixelFormat(DC, nPixelFormat, @pfd);
end;

end.

