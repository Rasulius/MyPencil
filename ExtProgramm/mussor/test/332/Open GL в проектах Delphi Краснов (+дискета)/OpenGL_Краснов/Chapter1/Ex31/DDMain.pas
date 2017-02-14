{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

unit DDMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, DDraw, OpenGL, StdCtrls;

type
  TDForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    hrc : HGLRC;
  end;

var
  DForm : TDForm;
  DD : IDirectDraw2;

implementation

{$R *.DFM}

{=======================================================================
Формат пикселя}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

procedure TDForm.FormCreate(Sender: TObject);
var
 DD1: IDirectDraw;  // Temp object for getting an IDirectDraw2 interface.
begin
 try
    // Show form before messing with screen resolution.
    Show;
    // Create and initialize a DirectDraw object.
    if DirectDrawCreate(nil, DD1, nil) <> DD_OK then
      raise Exception.Create('DirectDrawCreate() failed');
    DD1._AddRef;
    if DD1.QueryInterface(IID_IDirectDraw2, DD) <> DD_OK then
      raise Exception.Create('QueryInterface() failed');
    DD1._Release;
    if DD.SetCooperativeLevel(Handle, DDSCL_FULLSCREEN or DDSCL_EXCLUSIVE or
                              DDSCL_NOWINDOWCHANGES) <> DD_OK then
      raise Exception.Create('SetCooperativeLevel() failed');
    // You can either pass resolution and color depth as params, or use 640x480x16 as default.
    if ParamCount = 3 then begin
      if DD.SetDisplayMode(StrToInt(ParamStr(1)), StrToInt(ParamStr(2)),
                           StrToInt(ParamStr(3)), 0, 0) <> DD_OK then
        raise Exception.Create('SetDisplayMode() failed');
    end
    else if DD.SetDisplayMode(640, 480, 16, 0, 0) <> DD_OK then
        raise Exception.Create('SetDisplayMode() failed');
    // Go full screen.
    WindowState := wsMaximized;
    // Initialize OpenGL.
    SetDCPixelFormat(Canvas.Handle);
    hrc := wglCreateContext(Canvas.Handle);
 except
    on E:Exception do begin
    ShowMessage (E.Message);
    Close;
 end;
 end;
end;

procedure TDForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 // Make sure to restore screen settings before exiting.
 if DD.RestoreDisplayMode <> DD_OK then
    raise Exception.Create('RestoreDisplayMode() failed');
end;

procedure TDForm.FormPaint(Sender: TObject);
begin
 If hrc = 0 then Close;
 wglMakeCurrent (Canvas.Handle, hrc);
 glClearColor (0.1, 0.5, 0.25, 1.0);
 glClear(GL_COLOR_BUFFER_BIT);
 wglMakeCurrent (0, 0);
end;

procedure TDForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close
end;

end.
