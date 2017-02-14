{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{ Constructive Solid Geometry
 /* author: Nate Robins
 *  email: ndr@pobox.com
 *  www: http://www.pobox.com/~ndr
 */}

unit frmMain;

interface

uses
  Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus, Controls,
  Dialogs, OpenGL;

type
  TfrmGL = class(TForm)
    PopupMenu1: TPopupMenu;
    Zoom1: TMenuItem;
    Decreasez1: TMenuItem;
    IncreaseZ1: TMenuItem;
    Operations1: TMenuItem;
    Aonlya1: TMenuItem;
    Bonlyb1: TMenuItem;
    AorB1: TMenuItem;
    AandB1: TMenuItem;
    AsubB1: TMenuItem;
    BsubA1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Decreasez1Click(Sender: TObject);
    procedure IncreaseZ1Click(Sender: TObject);
    procedure Aonlya1Click(Sender: TObject);
    procedure Bonlyb1Click(Sender: TObject);
    procedure AorB1Click(Sender: TObject);
    procedure AandB1Click(Sender: TObject);
    procedure AsubB1Click(Sender: TObject);
    procedure BsubA1Click(Sender: TObject);
  private
    DC: HDC;
    hrc: HGLRC;
    procedure Init;
    procedure SetDCPixelFormat;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

const
  SPHERE = 1;
  CONE   = 2;
  CUBE   = 3;

type
  csgOperation = (CSG_A, CSG_B, CSG_A_OR_B, CSG_A_AND_B,
                  CSG_A_SUB_B,  CSG_B_SUB_A);

var
  zoom : GLfloat = 0.0;

  cone_x : GLfloat = 0.0;
  cone_y : GLfloat = 0.0;
  cone_z : GLfloat = 0.0;

  cube_x : GLfloat = 0.0;
  cube_y : GLfloat = 0.0;
  cube_z : GLfloat = 0.0;

  sphere_x : GLfloat = 0.0;
  sphere_y : GLfloat = 0.0;
  sphere_z : GLfloat = 0.0;

  Op : csgOperation = CSG_A_OR_B;

implementation

uses DGLUT;

{$R *.DFM}

type
  proctype = procedure;

procedure one(a : proctype);
begin
  glEnable(GL_DEPTH_TEST);
  a;
  glDisable(GL_DEPTH_TEST);
end;

procedure procOR (a, b : proctype);
begin
  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glEnable(GL_DEPTH_TEST);
  a;
  b;
  glPopAttrib;
end;

{/* inside()
 *  sets stencil buffer to show the part of A
 *  (front or back face according to 'face')
 *  that is inside of B.
 */}
procedure inside(a, b : proctype; face, test : GLenum);
begin
  //* draw A into depth buffer, but not into color buffer */
  glEnable(GL_DEPTH_TEST);
  glColorMask(FALSE, FALSE, FALSE, FALSE);
  glCullFace(face);
  a;

  {/* use stencil buffer to find the parts of A that are inside of B
   * by first incrementing the stencil buffer wherever B's front faces
   * are...
   */}
  glDepthMask(FALSE);
  glEnable(GL_STENCIL_TEST);
  glStencilFunc(GL_ALWAYS, 0, 0);
  glStencilOp(GL_KEEP, GL_KEEP, GL_INCR);
  glCullFace(GL_BACK);
  b;

  //* ...then decrement the stencil buffer wherever B's back faces are */
  glStencilOp(GL_KEEP, GL_KEEP, GL_DECR);
  glCullFace(GL_FRONT);
  b;

  //* now draw the part of A that is inside of B */
  glDepthMask(TRUE);
  glColorMask(TRUE, TRUE, TRUE, TRUE);
  glStencilFunc(test, 0, 1);
  glDisable(GL_DEPTH_TEST);
  glCullFace(face);
  a;

  //* reset stencil test */
  glDisable(GL_STENCIL_TEST);
end;

{/* fixup()
 *  fixes up the depth buffer with A's depth values
 */}
procedure fixup (a : proctype);
begin
  //* fix up the depth buffer */
  glColorMask(FALSE, FALSE, FALSE, FALSE);
  glEnable(GL_DEPTH_TEST);
  glDisable(GL_STENCIL_TEST);
  glDepthFunc(GL_ALWAYS);
  a;

  //* reset depth func */
  glDepthFunc(GL_LESS);
end;

{/* and()
 *  boolean A and B (draw wherever A intersects B)
 *  algorithm: find where A is inside B, then find where
 *             B is inside A
 */}
procedure procAND (a, b : proctype);
begin
  inside(a, b, GL_BACK, GL_NOTEQUAL);
//#if 1  /* set to 0 for faster, but incorrect results */
  fixup(b);
//#endif
  inside(b, a, GL_BACK, GL_NOTEQUAL);
end;

{/*
 * sub()
 *  boolean A subtract B (draw wherever A is and B is NOT)
 *  algorithm: find where a is inside B, then find where
 *             the BACK faces of B are NOT in A
 */}
procedure sub (a, b : proctype);
begin
  inside(a, b, GL_FRONT, GL_NOTEQUAL);
//#if 1  /* set to 0 for faster, but incorrect results */
  fixup(b);
//#endif
  inside(b, a, GL_BACK, GL_EQUAL);
end;

{/* sphere()
 *  draw a yellow sphere
 */}
procedure procSphere;
begin
  glLoadName(2);
  glPushMatrix();
  glTranslatef(sphere_x, sphere_y, sphere_z);
  glColor3f(1.0, 1.0, 0.0);
  glutSolidSphere(5.0, 16, 16);
  glPopMatrix();
end;

{/* cube()
 *  draw a red cube
 */}
procedure procCube;
begin
  glLoadName(1);
  glPushMatrix;
  glTranslatef(cube_x, cube_y, cube_z);
  glColor3f(1.0, 0.0, 0.0);
  glutSolidCube(8.0);
  glPopMatrix;
end;

{/* cone()
 *  draw a green cone
 */}
procedure procCone;
begin
  glLoadName(3);
  glPushMatrix;
  glTranslatef(cone_x, cone_y, cone_z);
  glColor3f(0.0, 1.0, 0.0);
  glTranslatef(0.0, 0.0, -6.5);
  glutSolidCone(4.0, 15.0, 16, 16);
  glRotatef(180.0, 1.0, 0.0, 0.0);
  glutSolidCone(4.0, 0.0, 16, 1);
  glPopMatrix;
end;

var
  a : proctype = procCube;
  b : proctype = procSphere;

{=======================================================================
Инициализация}
procedure TfrmGL.Init;
const
  lightposition : Array [0..3] of GLfloat = ( -3.0, 3.0, 3.0, 0.0 );
begin
  glDepthFunc(GL_LESS);
  glEnable(GL_DEPTH_TEST);

  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHTING);
  glLightfv(GL_LIGHT0, GL_POSITION, @lightposition);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);

  glEnable(GL_COLOR_MATERIAL);

  glEnable(GL_CULL_FACE);

  glClearColor(0.0, 0.0, 1.0, 0.0);
end;


{=======================================================================
Рисование картинки}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);

  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT );

  glPushMatrix;

  Case Op of
    CSG_A: one(A);
    CSG_B: one(B);
    CSG_A_OR_B: procOR (A, B);
    CSG_A_AND_B: procAND(A, B);
    CSG_A_SUB_B: sub(A, B);
    CSG_B_SUB_A: sub(B, A);
  end;
  glPopMatrix;

  SwapBuffers(DC);
  EndPaint(Handle, ps);
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
end;

{=======================================================================
Изменение размеров окна}
procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight );
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum(-3.0, 3.0, -3.0, 3.0, 64, 256);

 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef(0.0, 0.0, -200.0 + zoom);

 InvalidateRect(Handle, nil, False);
end;

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  glDeleteLists (SPHERE, 3);
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
  Case Key of
     Ord ('Z') : begin
                 If ssShift in Shift
                    then zoom := zoom - 6.0
                    else zoom := zoom + 6.0;
                 FormResize (nil);
                 end;
     Ord ('C'): begin
	        If (@A = @procCube) and (@B = @procSphere) then begin
	           A := procSphere;
	           B := procCone;
                   end
	           else begin
                   If (@A = @procSphere) and (@B = @procCone) then begin
	              A := procCone;
	              B := procCube;
                      end
	              else begin
	              A := procCube;
	              B := procSphere;
                   end
                end;
                InvalidateRect(Handle, nil, False);
                end;
     VK_UP : If ssAlt in Shift then begin
                sphere_y := sphere_y + 0.2;
                InvalidateRect(Handle, nil, False);
             end
             else begin
             If ssShift in Shift then begin
                cone_y := cone_y + 0.2;
                InvalidateRect(Handle, nil, False);
                end
                else begin
                cube_y := cube_y + 0.2;
                InvalidateRect(Handle, nil, False);
             end;
             end;
     VK_DOWN : If ssAlt in Shift then begin
                sphere_y := sphere_y - 0.2;
                InvalidateRect(Handle, nil, False);
             end
             else begin
             If ssShift in Shift then begin
                cone_y := cone_y - 0.2;
                InvalidateRect(Handle, nil, False);
                end
                else begin
                cube_y := cube_y - 0.2;
                InvalidateRect(Handle, nil, False);
             end;
             end;
     VK_LEFT : If ssAlt in Shift then begin
                sphere_x := sphere_x - 0.2;
                InvalidateRect(Handle, nil, False);
             end
             else begin
             If ssShift in Shift then begin
                cone_x := cone_x - 0.2;
                InvalidateRect(Handle, nil, False);
                end
                else begin
                cube_x := cube_x - 0.2;
                InvalidateRect(Handle, nil, False);
             end;
             end;
     VK_RIGHT : If ssAlt in Shift then begin
                sphere_x := sphere_x + 0.2;
                InvalidateRect(Handle, nil, False);
             end
             else begin
             If ssShift in Shift then begin
                cone_x := cone_x + 0.2;
                InvalidateRect(Handle, nil, False);
                end
                else begin
                cube_x := cube_x + 0.2;
                InvalidateRect(Handle, nil, False);
             end;
             end;
  end; {case}
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

procedure TfrmGL.Decreasez1Click(Sender: TObject);
begin
 zoom := zoom - 6.0;
 FormResize (nil);
end;

procedure TfrmGL.IncreaseZ1Click(Sender: TObject);
begin
 zoom := zoom + 6.0;
 FormResize (nil);
end;

procedure TfrmGL.Aonlya1Click(Sender: TObject);
begin
  Op := CSG_A;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.Bonlyb1Click(Sender: TObject);
begin
  Op := CSG_B;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.AorB1Click(Sender: TObject);
begin
  Op := CSG_A_OR_B;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.AandB1Click(Sender: TObject);
begin
  Op := CSG_A_AND_B;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.AsubB1Click(Sender: TObject);
begin
  Op := CSG_A_SUB_B;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.BsubA1Click(Sender: TObject);
begin
  Op := CSG_B_SUB_A;
  InvalidateRect(Handle, nil, False);
end;

end.


