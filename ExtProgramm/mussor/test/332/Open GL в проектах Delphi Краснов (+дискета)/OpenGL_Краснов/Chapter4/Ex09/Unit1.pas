{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * (c) Copyright 1993, Silicon Graphics, Inc.
 *               1993-1995 Microsoft Corporation
 * ALL RIGHTS RESERVED
 */}

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
  end;

var
  frmGL: TfrmGL;

implementation

uses DGlut;

{$R *.DFM}


// Initialize z-buffer, projection matrix, light source,
// and lighting model.  Do not specify a material property here.
procedure   MyInit;
const
    position        : array[0..3] of GLfloat = ( 0.0, 3.0, 2.0, 0.0 );
    lmodel_ambient  : array[0..3] of GLfloat = ( 0.4, 0.4, 0.4, 1.0 );
begin
    glEnable(GL_DEPTH_TEST);

    glLightfv(GL_LIGHT0, GL_POSITION, @position);
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);

    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);

    glClearColor(0.0, 0.1, 0.1, 0.0);
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.FormPaint(Sender: TObject);
const
    no_mat              : array[0..3] of GLfloat = ( 0.0, 0.0, 0.0, 1.0 );
    mat_ambient         : array[0..3] of GLfloat = ( 0.7, 0.7, 0.7, 1.0 );
    mat_ambient_color   : array[0..3] of GLfloat = ( 0.8, 0.8, 0.2, 1.0 );
    mat_diffuse         : array[0..3] of GLfloat = ( 0.1, 0.5, 0.8, 1.0 );
    mat_specular        : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
    no_shininess        : array[0..0] of GLfloat = ( 0.0 );
    low_shininess       : array[0..0] of GLfloat = ( 5.0 );
    high_shininess      : array[0..0] of GLfloat = ( 100.0 );
    mat_emission        : array[0..3] of GLfloat = ( 0.3, 0.2, 0.2, 0.0 );
begin
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    // draw sphere in first row, first column
    // diffuse reflection only; no ambient or specular
    glPushMatrix;
    glTranslatef (-3.75, 3.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @no_mat);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
    glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in first row, second column
    // diffuse and specular reflection; low shininess; no ambient
    glPushMatrix;
    glTranslatef (-1.25, 3.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @no_mat);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, @low_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in first row, third column
    // diffuse and specular reflection; high shininess; no ambient
    glPushMatrix;
    glTranslatef (1.25, 3.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @no_mat);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, @high_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in first row, fourth column
    // diffuse reflection; emission; no ambient or specular reflection
    glPushMatrix;
    glTranslatef (3.75, 3.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @no_mat);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
    glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @mat_emission);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in second row, first column
    // ambient and diffuse reflection; no specular
    glPushMatrix;
    glTranslatef (-3.75, 0.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
    glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in second row, second column
    // ambient, diffuse and specular reflection; low shininess
    glPushMatrix;
    glTranslatef (-1.25, 0.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, @low_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in second row, third column
    // ambient, diffuse and specular reflection; high shininess
    glPushMatrix;
    glTranslatef (1.25, 0.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, @high_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in second row, fourth column
    // ambient and diffuse reflection; emission; no specular
    glPushMatrix;
    glTranslatef (3.75, 0.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
    glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @mat_emission);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in third row, first column
    // colored ambient and diffuse reflection; no specular
    glPushMatrix;
    glTranslatef (-3.75, -3.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient_color);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
    glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in third row, second column
    // colored ambient, diffuse and specular reflection; low shininess
    glPushMatrix;
    glTranslatef (-1.25, -3.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient_color);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, @low_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in third row, third column
    // colored ambient, diffuse and specular reflection; high shininess
    glPushMatrix;
    glTranslatef (1.25, -3.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient_color);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, @high_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @no_mat);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;

    // draw sphere in third row, fourth column
    // colored ambient and diffuse reflection; emission; no specular
    glPushMatrix;
    glTranslatef (3.75, -3.0, 0.0);
    glMaterialfv(GL_FRONT, GL_AMBIENT, @mat_ambient_color);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, @mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, @no_mat);
    glMaterialfv(GL_FRONT, GL_SHININESS, @no_shininess);
    glMaterialfv(GL_FRONT, GL_EMISSION, @mat_emission);
    glutSolidSphere(1.0, 16, 16);
    glPopMatrix;



  SwapBuffers(DC);
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
 MyInit;
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
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 if ClientWidth <= (ClientHeight * 2)
    then glOrtho (-6.0, 6.0, -3.0*(ClientHeight*2)/ClientWidth,
         3.0*(ClientHeight*2)/ClientWidth, -10.0, 10.0)
    else
        glOrtho (-6.0*ClientWidth/(ClientHeight*2),
        6.0*ClientWidth/(ClientHeight*2), -3.0, 3.0, -10.0, 10.0);
    glMatrixMode(GL_MODELVIEW);

 InvalidateRect(Handle, nil, False);
end;

end.

