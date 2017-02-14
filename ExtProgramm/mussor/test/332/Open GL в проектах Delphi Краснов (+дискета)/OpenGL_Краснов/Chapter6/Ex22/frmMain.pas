{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit frmMain;

interface

uses
 Windows, Messages, Classes, Graphics, Forms, ExtCtrls, Menus,
 Controls, Dialogs, SysUtils, StdCtrls,
 OpenGL;

type
  TFBBuffer = Array [0..1023] of GLFloat;

type
  TfrmGL = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    DC: HDC;
    hrc: HGLRC;
    Angle: GLfloat;
    uTimerId : uint;  // идентификатор таймера - необходимо запомнить
    fb: TFBBuffer;
    Timer : Boolean;
    
    procedure SetDCPixelFormat;
    procedure PrintBuffer(b: TFBBuffer; n: Integer);
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;

implementation

uses mmSystem;

{$R *.DFM}

procedure Render (mode: GLenum);
begin
  If mode = GL_FEEDBACK then glPassThrough(1);
  glColor3f (1.0, 0.0, 0.0);
  glNormal3f (0.0, 0.0, -1.0);
  glBegin (GL_QUADS);
    glVertex3f (-0.5, -0.5, 0.0);
    glVertex3f (0.5, -0.5, 0.0);
    glVertex3f (0.5, 0.5, 0.0);
    glVertex3f (-0.5, 0.5, 0.0);
  glEnd;

  If mode = GL_FEEDBACK then glPassThrough(2);
  glColor3f (1.0, 1.0, 0.0);
  glBegin (GL_POINTS);
    glNormal3f (0.0, 0.0, -1.0);
    glVertex3f (0.0, 0.0, -0.5);
  glEnd;
end;

{=======================================================================
Обработка таймера}
procedure FNTimeCallBack(uTimerID, uMessage: UINT;dwUser, dw1, dw2: DWORD) stdcall;
begin
  // Каждый "тик" изменяется значение угла
  With frmGL do begin
    Angle := Angle + 0.1;
    If Angle >= 360.0 then Angle := 0.0;
    InvalidateRect(Handle, nil, False);
  end;
end;

procedure TfrmGL.PrintBuffer(b: TFBBuffer; n: Integer);
var
  i, j, k, vcount : Integer;
  token : Single;
  vert : String;
begin
  Memo1.Clear;
  i := n;
  While i <> 0 do begin
    token := b[n-i];
    DEC(i);
    If token = GL_PASS_THROUGH_TOKEN then begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add(Format('Passthrough: %.2f', [b[n-i]]));
      DEC(i);
    end
    else If token = GL_POLYGON_TOKEN then begin
      vcount := Round(b[n-i]);
      Memo1.Lines.Add(Format('Polygon - %d vertices (XYZ RGBA):', [vcount]));
      DEC(i);
      For k := 1 to vcount do begin
        vert := '  ';
        For j := 0 to 6 do begin
          vert := vert + Format('%4.2f ', [b[n-i]]);
          DEC(i);
        end;
        Memo1.Lines.Add(vert);
      end;
    end
    else If token = GL_POINT_TOKEN then begin
      Memo1.Lines.Add('Vertex - (XYZ RGBA):');
      vert := '  ';
      For j := 0 to 6 do begin
        vert := vert + Format('%4.2f ', [b[n-i]]);
        DEC(i);
      end;
      Memo1.Lines.Add(vert);
    end;
  end;

end;

{=======================================================================
Перерисовка окна}
procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
  n: Integer;
begin
  BeginPaint(Handle, ps);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glLoadIdentity;
  glRotatef(Angle, 1, 0, 0.1);
  Render(GL_RENDER);

  glRenderMode(GL_FEEDBACK);
  Render(GL_FEEDBACK);
  n := glRenderMode(GL_RENDER);

  If n > 0 then PrintBuffer(fb, n);

  SwapBuffers(DC);
  EndPaint(Handle, ps);
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
const
  position : Array [0..2] of GLFloat = (0, 0, -1);
  diffuse : Array [0..3] of GLFloat = (1, 1, 1, 1);
  ambient : Array [0..3] of GLFloat = (0.4, 0.4, 0.8, 1);
begin
  Angle := 0;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);

  glViewport(0, 0, (ClientWidth - Memo1.Width), ClientHeight);
  glEnable(GL_DEPTH_TEST);
  glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);
  glEnable(GL_COLOR_MATERIAL);
  glPointSize(20);
  glEnable(GL_POINT_SMOOTH);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_POSITION, @position);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @diffuse);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);

  glClearColor (0.25, 0.75, 0.25, 0.0);
  Timer := True;
  uTimerID := timeSetEvent (2, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
  glFeedbackBuffer(SizeOf (fb), GL_3D_COLOR, @fb);
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

{=======================================================================
Конец работы программы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  If Timer then timeKillEvent(uTimerID);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;


procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close else
  If Key = VK_SPACE then begin
     Timer := not Timer;
     If not Timer
        then timeKillEvent(uTimerID)
        else uTimerID := timeSetEvent (2, 0, @FNTimeCallBack, 0, TIME_PERIODIC);
  end;
end;

procedure TfrmGL.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Caption := IntToStr (X) + ' ' + IntToStr (Y)
end;

end.

