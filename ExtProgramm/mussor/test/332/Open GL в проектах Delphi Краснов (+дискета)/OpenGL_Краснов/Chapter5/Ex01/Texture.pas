const                     // параметры текстуры
  TexImageWidth = 64;
  TexParams : Array [0..3] of GLfloat = (0.0, 0.0, 1.0, 0.0);

var
  TexImage : Array [1 .. 3 * TexImageWidth] of GLuByte;

procedure MakeTexImage;
begin
  j := 1;
  While j < TexImageWidth * 3 do begin
    TexImage [j] := 248;     // красный
    TexImage [j + 1] := 150; // зеленый
    TexImage [j + 2] := 41;  // синий
    TexImage [j + 3] := 205; // красный
    TexImage [j + 4] := 52;  // зеленый
    TexImage [j + 5] := 24;  // синий
    Inc (j, 6);
  end;

  glTexParameteri (GL_TEXTURE_1D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri (GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri (GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  glTexImage1D (GL_TEXTURE_1D, 0, 3, TexImageWidth, 0, GL_RGB, GL_UNSIGNED_BYTE, @TexImage);

  glEnable (GL_TEXTURE_GEN_S);

  glTexGeni  (GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
  glTexGenfv (GL_S, GL_OBJECT_PLANE, @TexParams);
end;
