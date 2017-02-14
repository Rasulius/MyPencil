{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 * Copyright (c) 1993-1997, Silicon Graphics, Inc.
 * ALL RIGHTS RESERVED
 * Permission to use, copy, modify, and distribute this software for
 * any purpose and without fee is hereby granted, provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation, and that
 * the name of Silicon Graphics, Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission.
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
 * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
 * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
 * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 * US Government Users Restricted Rights 
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics,
 * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
 *
 * OpenGL(R) is a registered trademark of Silicon Graphics, Inc.
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
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC : HDC;
    hrc: HGLRC;
    procedure Init;
  end;

var
  frmGL: TfrmGL;
  tobj : GLUtesselator;

implementation

{$R *.DFM}

procedure gluTessBeginPolygon (tess: GLUtesselator; polygon_data: Pointer); stdcall; external GLU32;
procedure gluGetTessProperty (tess: GLUtesselator; which: GLEnum; value: PGLdouble); stdcall; external GLU32;

//* TessProperty */
const
 GLU_TESS_WINDING_RULE   = 100140;
 GLU_TESS_BOUNDARY_ONLY  = 100141;
 GLU_TESS_TOLERANCE      = 100142;

procedure errorCallback(errorCode : GLenum);stdcall;
begin
  ShowMessage (gluErrorString(errorCode));
end;

type
  TVector = Array [0..2] of GLdouble;
  TArray4D = Array [0..3] of GLdouble;
  PTArray4D = ^TArray4D;
  TArray4F = Array [0..3] of GLfloat;
  PTVector = ^TVector;

procedure combineCallback(coords : PTVector; data : PTArray4D;
          weight : TArray4F; var dataout : Pointer); stdcall;
var
   vertex : PTVector;
begin
   GetMem (vertex, SizeOf (TVector));
   vertex^[0] := coords[0];
   vertex^[1] := coords[1];
   vertex^[2] := coords[2];
   dataOut := vertex;
end;

procedure TfrmGL.init;
var
   i : 0..20;
const
   spiral : Array [0..15] of TVector =
     ((400.0, 250.0, 0.0), (400.0, 50.0, 0.0),
      (50.0, 50.0, 0.0), (50.0, 400.0, 0.0),
      (350.0, 400.0, 0.0), (350.0, 100.0, 0.0),
      (100.0, 100.0, 0.0), (100.0, 350.0, 0.0),
      (300.0, 350.0, 0.0), (300.0, 150.0, 0.0),
      (150.0, 150.0, 0.0), (150.0, 300.0, 0.0),
      (250.0, 300.0, 0.0), (250.0, 200.0, 0.0),
      (200.0, 200.0, 0.0), (200.0, 250.0, 0.0));
   rects : Array [0..11] of TVector =
     ((50.0, 50.0, 0.0), (300.0, 50.0, 0.0),
      (300.0, 300.0, 0.0), (50.0, 300.0, 0.0),
      (100.0, 100.0, 0.0), (250.0, 100.0, 0.0),
      (250.0, 250.0, 0.0), (100.0, 250.0, 0.0),
      (150.0, 150.0, 0.0), (200.0, 150.0, 0.0),
      (200.0, 200.0, 0.0), (150.0, 200.0, 0.0));
   quad1 : Array [0..3] of TVector =
     ((50.0, 150.0, 0.0), (350.0, 150.0, 0.0),
      (350.0, 200.0, 0.0), (50.0, 200.0, 0.0));
   quad2 : Array [0..3] of TVector =
     ((100.0, 100.0, 0.0), (300.0, 100.0, 0.0),
      (300.0, 350.0, 0.0), (100.0, 350.0, 0.0));
   tri : Array [0..2] of TVector =
     ((200.0, 50.0, 0.0), (250.0, 300.0, 0.0),
      (150.0, 300.0, 0.0));

begin
   gluTessCallback(tobj, GLU_TESS_BEGIN, @glBegin);
   gluTessCallback(tobj, GLU_TESS_VERTEX, @glVertex3dv);
   gluTessCallback(tobj, GLU_TESS_END, @glEnd);
   gluTessCallback(tobj, GLU_TESS_ERROR, @errorCallback);
   gluTessCallback(tobj, GLU_TESS_COMBINE, @combineCallback);

   glNewList(1, GL_COMPILE);
      gluTessBeginPolygon(tobj, nil);
         gluTessBeginContour(tobj);
         For i := 0 to 3 do
            gluTessVertex(tobj, @rects[i], @rects[i]);
         gluTessEndContour(tobj);
         gluTessBeginContour(tobj);
         For i := 4 to 7 do
            gluTessVertex(tobj, @rects[i], @rects[i]);
         gluTessEndContour(tobj);
         gluTessBeginContour(tobj);
         For i := 8 to 11 do
            gluTessVertex(tobj, @rects[i], @rects[i]);
         gluTessEndContour(tobj);
      gluTessEndPolygon(tobj);
   glEndList;

   glNewList(2, GL_COMPILE);
      gluTessBeginPolygon(tobj, nil);
         gluTessBeginContour(tobj);
         For i := 0 to 3 do
            gluTessVertex(tobj, @rects[i], @rects[i]);
         gluTessEndContour(tobj);
         gluTessBeginContour(tobj);
         For i := 7 downto 4 do
            gluTessVertex(tobj, @rects[i], @rects[i]);
         gluTessEndContour(tobj);
         gluTessBeginContour(tobj);
         For i := 11 downto 8 do
            gluTessVertex(tobj, @rects[i], @rects[i]);
         gluTessEndContour(tobj);
      gluTessEndPolygon(tobj);
   glEndList;

   glNewList(3, GL_COMPILE);
      gluTessBeginPolygon(tobj, nil);
         gluTessBeginContour(tobj);
         For i := 0 to 15 do
            gluTessVertex(tobj, @spiral[i], @spiral[i]);
         gluTessEndContour(tobj);
      gluTessEndPolygon(tobj);
   glEndList;

   glNewList(4, GL_COMPILE);
      gluTessBeginPolygon(tobj, nil);
         gluTessBeginContour(tobj);
         For i := 0 to 3 do
            gluTessVertex(tobj, @quad1[i], @quad1[i]);
         gluTessEndContour(tobj);
         gluTessBeginContour(tobj);
         For i := 0 to 3 do
            gluTessVertex(tobj, @quad2[i], @quad2[i]);
         gluTessEndContour(tobj);
         gluTessBeginContour(tobj);
         For i := 0 to 2 do
            gluTessVertex(tobj, @tri[i], @tri[i]);
         gluTessEndContour(tobj);
      gluTessEndPolygon(tobj);
   glEndList;
end;

{=======================================================================
Рисование картинки}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT);

 glPushMatrix();
 glCallList(1);
 glTranslatef(0.0, 500.0, 0.0);
 glCallList(2);
 glTranslatef(500.0, -500.0, 0.0);
 glCallList(3);
 glTranslatef(0.0, 500.0, 0.0);
 glCallList(4);
 glPopMatrix();

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

 glClearColor (0.5, 0.5, 0.75, 1.0);
 tobj := gluNewTess;
 Init;
end;

{=======================================================================
Конец работы приложения}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 gluDeleteTess(tobj);
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC(Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewPort (0, 0, ClientWidth, ClientHeight);
 glClearColor (0.5, 0.5, 0.75, 1.0);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 If ClientWidth < ClientHeight
   then gluOrtho2D(0.0, 1000.0, 0.0, 1000.0 * ClientHeight / ClientWidth)
   else gluOrtho2D(0.0, 1000.0 * ClientWidth / ClientHeight, 0.0, 1000.0);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 currentWinding : GLdouble;
begin
 If Key = VK_ESCAPE then Close;
 If Key = Ord ('W') then begin
    gluGetTessProperty (tobj, GLU_TESS_WINDING_RULE, @currentWinding);
    If currentWinding = GLU_TESS_WINDING_ODD
       then currentWinding := GLU_TESS_WINDING_NONZERO
       else If currentWinding = GLU_TESS_WINDING_NONZERO
       then currentWinding := GLU_TESS_WINDING_POSITIVE
       else If currentWinding = GLU_TESS_WINDING_POSITIVE
       then currentWinding := GLU_TESS_WINDING_NEGATIVE
       else If currentWinding = GLU_TESS_WINDING_NEGATIVE
       then currentWinding := GLU_TESS_WINDING_ABS_GEQ_TWO
       else If currentWinding = GLU_TESS_WINDING_ABS_GEQ_TWO
       then currentWinding := GLU_TESS_WINDING_ODD;
    gluTessProperty(tobj, GLU_TESS_WINDING_RULE, currentWinding);
    Init;
    InvalidateRect(Handle, nil, False);
 end;
end;

end.

