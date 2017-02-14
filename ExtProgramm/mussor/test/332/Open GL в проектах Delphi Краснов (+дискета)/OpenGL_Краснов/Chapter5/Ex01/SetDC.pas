procedure SetDCPixelFormat;
var
  nPixelFormat : Integer;
  pfd : TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf (pfd), 0);

  with pfd do begin
    nSize     := SizeOf (pfd);
    nVersion  := 1;
    dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;
    iPixelType:= PFD_TYPE_RGBA;
    cColorBits:= 16;
    cAccumBits:= 32;
    cDepthBits:= 32;
    cStencilBits := 8;
    iLayerType:= PFD_MAIN_PLANE;
  end;

  nPixelFormat := ChoosePixelFormat (DC, @pfd);
  SetPixelFormat (DC, nPixelFormat, @pfd);
end;
