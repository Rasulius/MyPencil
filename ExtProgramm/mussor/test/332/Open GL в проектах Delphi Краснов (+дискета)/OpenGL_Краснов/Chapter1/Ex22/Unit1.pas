{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

{*********************************************************************}
{***                ТЕСТИРОВАНИЕ ФОРМАТА ПИКСЕЛЕЙ                  ***}
{*********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, Forms, OpenGL, Classes, Controls, ExtCtrls, ComCtrls,
  StdCtrls, Dialogs, SysUtils;

type
  TfrmGL = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    cbxDOUBLEBUFFER: TCheckBox;
    cbxSTEREO: TCheckBox;
    cbxDRAW_TO_WINDOW: TCheckBox;
    cbxDRAW_TO_BITMAP: TCheckBox;
    cbxSUPPORT_GDI: TCheckBox;
    cbxSUPPORT_OPENGL: TCheckBox;
    cbxGENERIC_FORMAT: TCheckBox;
    cbxNEED_PALETTE: TCheckBox;
    cbxNEED_SYSTEM_PALETTE: TCheckBox;
    cbxSWAP_EXCHANGE: TCheckBox;
    cbxSWAP_COPY: TCheckBox;
    cbxSWAP_LAYER_BUFFERS: TCheckBox;
    cbxGENERIC_ACCELERATED: TCheckBox;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    edtColorBits: TEdit;
    edtRedBits: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edtGreenBits: TEdit;
    Label4: TLabel;
    edtBlueBits: TEdit;
    Label5: TLabel;
    edtAlphaBits: TEdit;
    edtAccumBits: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    edtAccumRedBits: TEdit;
    Label8: TLabel;
    edtAccumGreenBits: TEdit;
    Label9: TLabel;
    edtAccumBlueBits: TEdit;
    Label10: TLabel;
    edtAccumAlphaBits: TEdit;
    Label11: TLabel;
    edtDepthBits: TEdit;
    Label12: TLabel;
    edtStencilBits: TEdit;
    TabSheet3: TTabSheet;
    Label13: TLabel;
    edtRedShift: TEdit;
    Label14: TLabel;
    edtGreenShift: TEdit;
    edtBlueShift: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    edtAlphaShift: TEdit;
    nVersion: TLabel;
    edtVersion: TEdit;
    Bevel1: TBevel;
    btnTest: TButton;
    Bevel2: TBevel;
    cbxDEPTH_DONTCARE: TCheckBox;
    cbxDOUBLEBUFFER_DONTCARE: TCheckBox;
    cbxSTEREO_DONTCARE: TCheckBox;
    Label17: TLabel;
    edtAuxBuffers: TEdit;
    edtReserved: TEdit;
    Label18: TLabel;
    edtLayerMask: TEdit;
    Label19: TLabel;
    edtVisibleMask: TEdit;
    Label20: TLabel;
    edtDamageMask: TEdit;
    Label21: TLabel;
    TabSheet4: TTabSheet;
    Panel2: TPanel;
    Label22: TLabel;
    rbPFD_TYPE_RGBA: TRadioButton;
    rbPFD_TYPE_COLORINDEX: TRadioButton;
    Panel3: TPanel;
    Label23: TLabel;
    rbPFD_MAIN_PLANE: TRadioButton;
    rbPFD_OVERLAY_PLANE: TRadioButton;
    rbPFD_UNDERLAY_PLANE: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    hrc: HGLRC;
    pfd : TPIXELFORMATDESCRIPTOR;
    flgSwap : Boolean;
    procedure SetDCPixelFormat;
    procedure TestPixelFormat;
  end;

var
  frmGL: TfrmGL;

implementation

{$R *.DFM}

{=======================================================================
Отображение установленного формата пикселей в контролах}
procedure TfrmGL.TestPixelFormat;
begin
  If (pfd.dwFlags and PFD_DOUBLEBUFFER) <> 0
     then begin
     flgSwap := True;
     cbxDOUBLEBUFFER.Checked := True
     end
     else begin
     flgSwap := False;
     cbxDOUBLEBUFFER.Checked := False;
     end;
  If (pfd.dwFlags and PFD_STEREO) <> 0
     then cbxSTEREO.Checked := True
     else cbxSTEREO.Checked := False;
  If (pfd.dwFlags and PFD_DRAW_TO_WINDOW) <> 0
     then cbxDRAW_TO_WINDOW.Checked := True
     else cbxDRAW_TO_WINDOW.Checked := False;
  If (pfd.dwFlags and PFD_DRAW_TO_BITMAP) <> 0
     then cbxDRAW_TO_BITMAP.Checked := True
     else cbxDRAW_TO_BITMAP.Checked := False;
  If (pfd.dwFlags and PFD_SUPPORT_GDI) <> 0
     then cbxSUPPORT_GDI.Checked := True
     else cbxSUPPORT_GDI.Checked := False;
  If (pfd.dwFlags and PFD_SUPPORT_OPENGL) <> 0
     then cbxSUPPORT_OPENGL.Checked := True
     else cbxSUPPORT_OPENGL.Checked := False;
  If (pfd.dwFlags and PFD_GENERIC_FORMAT) <> 0
     then cbxGENERIC_FORMAT.Checked := True
     else cbxGENERIC_FORMAT.Checked := False;
  If (pfd.dwFlags and PFD_NEED_PALETTE) <> 0
     then cbxNEED_PALETTE.Checked := True
     else cbxNEED_PALETTE.Checked := False;
  If (pfd.dwFlags and PFD_NEED_SYSTEM_PALETTE) <> 0
     then cbxNEED_SYSTEM_PALETTE.Checked := True
     else cbxNEED_SYSTEM_PALETTE.Checked := False;
  If (pfd.dwFlags and PFD_SWAP_EXCHANGE) <> 0
     then cbxSWAP_EXCHANGE.Checked := True
     else cbxSWAP_EXCHANGE.Checked := False;
  If (pfd.dwFlags and PFD_SWAP_COPY) <> 0
     then cbxSWAP_COPY.Checked := True
     else cbxSWAP_COPY.Checked := False;
  If (pfd.dwFlags and PFD_SWAP_LAYER_BUFFERS) <> 0
     then cbxSWAP_LAYER_BUFFERS.Checked := True
     else cbxSWAP_LAYER_BUFFERS.Checked := False;
  If (pfd.dwFlags and PFD_GENERIC_ACCELERATED) <> 0
     then cbxGENERIC_ACCELERATED.Checked := True
     else cbxGENERIC_ACCELERATED.Checked := False;

  // флаги PFD_DEPTH_DONTCARE, PFD_DOUBLEBUFFER_DONTCARE, PFD_STEREO_DONTCARE
  // используются только в ChoosePixelFormat

  edtColorBits.Text := IntToStr(pfd.cColorBits);
  edtRedBits.Text := IntToStr(pfd.cRedBits);
  edtGreenBits.Text := IntToStr(pfd.cGreenBits);
  edtBlueBits.Text := IntToStr(pfd.cBlueBits);
  edtAlphaBits.Text := IntToStr(pfd.cAlphaBits);
  edtAccumBits.Text := IntToStr(pfd.cAccumBits);
  edtAccumRedBits.Text := IntToStr(pfd.cAccumRedBits);
  edtAccumGreenBits.Text := IntToStr(pfd.cAccumGreenBits);
  edtAccumBlueBits.Text := IntToStr(pfd.cAccumBlueBits);
  edtAccumAlphaBits.Text := IntToStr(pfd.cAccumAlphaBits);
  edtDepthBits.Text := IntToStr(pfd.cDepthBits);
  edtStencilBits.Text := IntToStr(pfd.cStencilBits);
  edtRedShift.Text := IntToStr(pfd.cRedShift);
  edtGreenShift.Text := IntToStr(pfd.cGreenShift);
  edtBlueShift.Text := IntToStr(pfd.cBlueShift);
  edtAlphaShift.Text := IntToStr(pfd.cAlphaShift);
  edtVersion.Text := IntToStr(pfd.nVersion);
  edtAuxBuffers.Text := IntToStr (pfd.cAuxBuffers);
  edtReserved.Text := IntToStr (pfd.bReserved);
  edtLayerMask.Text := IntToStr (pfd.dwLayerMask);
  edtVisibleMask.Text := IntToStr (pfd.dwVisibleMask);
  edtDamageMask.Text := IntToStr (pfd.dwDamageMask);

  If pfd.iPixelType = PFD_TYPE_RGBA
     then rbPFD_TYPE_RGBA.Checked := True
     else rbPFD_TYPE_COLORINDEX.Checked := True;
  If pfd.iLayerType = PFD_MAIN_PLANE
     then rbPFD_MAIN_PLANE.Checked := True
     else If pfd.iLayerType = PFD_OVERLAY_PLANE
     then rbPFD_OVERLAY_PLANE.Checked := True
     else rbPFD_UNDERLAY_PLANE.Checked := True;
end;

{=======================================================================
Заполнение полей структуры pfd данными из контролов}
procedure TfrmGL.SetDCPixelFormat;
var
 nPixelFormat : Integer;
begin
 With pfd do begin
  nSize := sizeof (TPIXELFORMATDESCRIPTOR);
  nVersion := StrToInt (edtVersion.Text);

  dwFlags := 0;
  If cbxDOUBLEBUFFER.Checked then dwFlags := PFD_DOUBLEBUFFER;
  If cbxSTEREO.Checked then dwFlags := dwFlags or PFD_STEREO;
  If cbxDRAW_TO_WINDOW.Checked then dwFlags := dwFlags or PFD_DRAW_TO_WINDOW;
  If cbxDRAW_TO_BITMAP.Checked then dwFlags := dwFlags or PFD_DRAW_TO_BITMAP;
  If cbxSUPPORT_GDI.Checked then dwFlags := dwFlags or PFD_SUPPORT_GDI;
  If cbxSUPPORT_OPENGL.Checked then dwFlags := dwFlags or PFD_SUPPORT_OPENGL;
  If cbxGENERIC_FORMAT.Checked then dwFlags := dwFlags or PFD_GENERIC_FORMAT;
  If cbxNEED_PALETTE.Checked then dwFlags := dwFlags or PFD_NEED_PALETTE;
  If cbxNEED_SYSTEM_PALETTE.Checked then dwFlags := dwFlags or PFD_NEED_SYSTEM_PALETTE;
  If cbxSWAP_EXCHANGE.Checked then dwFlags := dwFlags or PFD_SWAP_EXCHANGE;
  If cbxSWAP_COPY.Checked then dwFlags := dwFlags or PFD_SWAP_COPY;
  If cbxSWAP_LAYER_BUFFERS.Checked then dwFlags := dwFlags or PFD_SWAP_LAYER_BUFFERS;
  If cbxGENERIC_ACCELERATED.Checked then dwFlags := dwFlags or PFD_GENERIC_ACCELERATED;
  If cbxDEPTH_DONTCARE.Checked then dwFlags := dwFlags or PFD_DEPTH_DONTCARE;
  If cbxDOUBLEBUFFER_DONTCARE.Checked then dwFlags := dwFlags or PFD_DOUBLEBUFFER_DONTCARE;
  If cbxSTEREO_DONTCARE.Checked then dwFlags := dwFlags or PFD_STEREO_DONTCARE;

  If rbPFD_TYPE_RGBA.Checked
     then iPixelType := PFD_TYPE_RGBA
     else iPixelType := PFD_TYPE_COLORINDEX;

  cColorBits := StrToInt(edtColorBits.Text);
  cRedBits := StrToInt(edtRedBits.Text);
  cRedShift := StrToInt(edtRedShift.Text);
  cGreenBits := StrToInt(edtGreenBits.Text);
  cGreenShift := StrToInt(edtGreenShift.Text);
  cBlueBits := StrToInt(edtBlueBits.Text);
  cBlueShift := StrToInt(edtBlueShift.Text);
  cAlphaBits := StrToInt(edtAlphaBits.Text);
  cAlphaShift := StrToInt(edtAlphaShift.Text);
  cAccumBits := StrToInt(edtAccumBits.Text);
  cAccumRedBits := StrToInt(edtAccumRedBits.Text);
  cAccumGreenBits := StrToInt(edtAccumGreenBits.Text);
  cAccumBlueBits := StrToInt(edtAccumBlueBits.Text);
  cAccumAlphaBits := StrToInt(edtAccumAlphaBits.Text);
  cDepthBits := StrToInt(edtDepthBits.Text);
  cStencilBits := StrToInt(edtStencilBits.Text);
  cAuxBuffers := StrToInt(edtAuxBuffers.Text);

  If rbPFD_MAIN_PLANE.Checked
     then iLayerType := PFD_MAIN_PLANE
     else
     If rbPFD_OVERLAY_PLANE.Checked
     then iLayerType := PFD_OVERLAY_PLANE;
     {---  else iLayerType := PFD_UNDERLAY_PLANE; ---}
     // константа PFD_UNDERLAY_PLANE равна -1, а iLayerType
     // имеет тип Byte, поэтому в такое значение
     // не может быть устанавлен

  bReserved := StrToInt(edtReserved.Text);
  dwLayerMask := StrToInt(edtLayerMask.Text);
  dwVisibleMask := StrToInt(edtVisibleMask.Text);
  dwDamageMask := StrToInt(edtDamageMask.Text);
  end;

  nPixelFormat := ChoosePixelFormat (Canvas.Handle, @pfd);
  SetPixelFormat (Canvas.Handle, nPixelFormat, @pfd);
  DescribePixelFormat(Canvas.Handle, nPixelFormat, sizeof(TPixelFormatDescriptor), pfd);
  TestPixelFormat;
end;

{=======================================================================
Создание окна}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
  Randomize;
  SetDCPixelFormat;
  If GetPixelFormat(Canvas.Handle) = 0
     then Showmessage ('Не установлен формат пикселей!');
  hrc := wglCreateContext (Canvas.Handle);
end;

{=======================================================================
Рисование в окне}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
  If hrc = 0 then ShowMessage ('Отсутствует контекст воспроизведения OpenGL!');
  wglMakeCurrent(Canvas.Handle, hrc);
  glClearColor (random, random, random, random);
  glClear (GL_COLOR_BUFFER_BIT);
  If flgSwap then SwapBuffers (Canvas.Handle);
  wglMakeCurrent(0, 0);
end;

{=======================================================================
Завершение работы}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  wglDeleteContext (hrc);
end;

{=======================================================================
Щелчок на кнопке "Test"}
procedure TfrmGL.btnTestClick(Sender: TObject);
begin
  wglDeleteContext (hrc);
  SetDCPixelFormat;
  hrc := wglCreateContext (Canvas.Handle);
  frmGL.Refresh;
end;

{=======================================================================
Обработка нажатия клавиши}
procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
end;

end.

