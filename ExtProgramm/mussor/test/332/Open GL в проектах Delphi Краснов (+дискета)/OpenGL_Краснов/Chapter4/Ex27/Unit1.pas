{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{ Copyright (c) Brian Paul}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
  private
    DC : HDC;
    hrc: HGLRC;
    procedure Draw1;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

var
 speed_test          : boolean = FALSE;
 smooth              : boolean = TRUE;
 lighting            : boolean = TRUE;

const
 MAXVERTS = 10000;

var
 verts               : array[0..MAXVERTS-1,0..2] of GLfloat;
 norms               : array[0..MAXVERTS-1,0..2] of GLfloat;
 numverts            : GLint;

 xrot, yrot          : GLfloat;

procedure   ReadSurface(const Filename: string);
var
 F: TextFile;
begin
 AssignFile(F,FileName);
 Reset(F);
 try
  numverts := 0;
  While not Eof(F) and (numverts < MAXVERTS) do begin
      Read(F,verts[numverts][0],verts[numverts][1],verts[numverts][2],
               norms[numverts][0],norms[numverts][1],norms[numverts][2]);
      Inc(numverts);
  end;
  Dec(numverts);
 finally
  CloseFile(F);
 end;
end;

procedure   DrawSurface;
var
 i: GLUint;
begin
 glBegin( GL_TRIANGLE_STRIP );
  For i := 0 to numverts - 1 do begin
   glNormal3fv( @norms[i] );
   glVertex3fv( @verts[i] );
  end;
 glEnd;
end;

procedure TfrmGL.Draw1;
begin
 glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glPushMatrix;
 glRotatef( yrot, 0.0, 1.0, 0.0 );
 glRotatef( xrot, 1.0, 0.0, 0.0 );

 DrawSurface;

 glPopMatrix;

 SwapBuffers(DC);
end;


{=======================================================================
Перерисовка окна}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 If speed_test then begin
      xrot := 0.0;
      while xrot<=360.0 do begin
          draw1;
          xrot := xrot + 10.0;
      end;
      speed_test := False;
      end
      else draw1;
end;

procedure   InitMaterials;
const
 ambient             : array[0..3] of GLfloat = ( 0.1, 0.1, 0.1, 1.0 );
 diffuse             : array[0..3] of GLfloat = ( 0.5, 1.0, 1.0, 1.0 );
 position0           : array[0..3] of GLfloat = ( 0.0, 0.0, 20.0, 0.0 );
 position1           : array[0..3] of GLfloat = ( 0.0, 0.0, -20.0, 0.0 );
 front_mat_shininess : array[0..0] of GLfloat = ( 60.0 );
 front_mat_specular  : array[0..3] of GLfloat = ( 0.2, 0.2, 0.2, 1.0 );
 front_mat_diffuse   : array[0..3] of GLfloat = ( 0.5, 0.28, 0.38, 1.0 );
 lmodel_ambient      : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
begin
 glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);
 glLightfv(GL_LIGHT0, GL_DIFFUSE, @diffuse);
 glLightfv(GL_LIGHT0, GL_POSITION, @position0);
 glEnable(GL_LIGHT0);

 glLightfv(GL_LIGHT1, GL_AMBIENT, @ambient);
 glLightfv(GL_LIGHT1, GL_DIFFUSE, @diffuse);
 glLightfv(GL_LIGHT1, GL_POSITION, @position1);
 glEnable(GL_LIGHT1);

 glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);
 glEnable(GL_LIGHTING);

 glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, @front_mat_shininess);
 glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @front_mat_specular);
 glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, @front_mat_diffuse);
end;

procedure   Init;
begin
 glClearColor(0.0, 0.0, 0.0, 0.0);

 glEnable(GL_DEPTH_TEST);

 InitMaterials;

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 glFrustum( -1.0, 1.0, -1.0, 1.0, 5, 25 );

 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 glTranslatef( 0.0, 0.0, -6.0 );
end;

{=======================================================================
Формат пикселя}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
Создание формы}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 glClearColor (0.5, 0.5, 0.75, 1.0); // цвет фона
 ReadSurface( 'isosurf.dat' );
 Init;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
 If Key = VK_LEFT then begin
    yrot := yrot - 15.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_RIGHT then begin
    yrot := yrot + 15.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_UP then begin
    xrot := xrot + 15.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = VK_DOWN then begin
    xrot := xrot - 15.0;
    InvalidateRect(Handle, nil, False);
 end;
 If Key = Ord ('S') then begin
    smooth := not smooth;
    If smooth
       then glShadeModel(GL_SMOOTH)
       else glShadeModel(GL_FLAT);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = Ord ('L') then begin
    lighting := not lighting;
    If lighting
       then glEnable(GL_LIGHTING)
       else glDisable(GL_LIGHTING);
    InvalidateRect(Handle, nil, False);
 end;
 If Key = Ord ('T') then begin
    speed_test := True;
    InvalidateRect(Handle, nil, False);
 end;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 InvalidateRect(Handle, nil, False);
end;

end.

