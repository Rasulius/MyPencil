procedure Hole (Rad : GLFloat);
begin
  glBegin(GL_QUAD_STRIP);
  For i := 0 to 2 * Level - 1 do begin
    glVertex3f(Rad * sin (Pi / (4 * Level) * i - Pi /4),
               Rad * cos (Pi / (4 * Level) * i - Pi /4), 0.0);
    glVertex3f(-Rad + Rad * i / 10, Rad, 0.0);
    glVertex3f(Rad * sin (Pi / (4 * Level) * (i + 1) - Pi /4),
               Rad * cos (Pi / (4 * Level) * (i + 1) - Pi /4), 0.0);
    glVertex3f(-Rad + Rad * (i + 1) / 10, Rad, 0.0);
  end;
  glEnd;

  glBegin(GL_QUAD_STRIP);
  For i := 0 to 2 * Level - 1 do begin
    glVertex3f(Rad * sin (Pi / (4 * Level) * i + Pi / 4),
               Rad * cos (Pi / (4 * Level) * i + Pi / 4), 0.0);
    glVertex3f(Rad, Rad - Rad * i / 10, 0.0);
    glVertex3f(Rad * sin (Pi / (4 * Level) * (i + 1) + Pi / 4),
               Rad * cos (Pi / (4 * Level) * (i + 1) + Pi / 4), 0.0);
    glVertex3f(Rad, Rad - Rad * (i + 1)/ 10, 0.0);
  end;
  glEnd;

  glBegin(GL_QUAD_STRIP);
  For i := 0 to 2 * Level - 1 do begin
    glVertex3f(Rad * sin (Pi / (4 * Level) * i - 3 * Pi / 4 ),
               Rad * cos (Pi / (4 * Level) * i - 3 * Pi / 4), 0.0);
    glVertex3f(-Rad, -Rad + Rad * i / 10, 0.0);
    glVertex3f(Rad * sin (Pi / (4 * Level) * (i + 1) - 3 * Pi / 4 ),
               Rad * cos (Pi / (4 * Level) * (i + 1) - 3 * Pi / 4), 0.0);
    glVertex3f(-Rad, -Rad + Rad * (i + 1) / 10, 0.0);
  end;
  glEnd;

  glBegin(GL_QUAD_STRIP);
  For i := 0 to 2 * Level - 1 do begin
    glVertex3f(Rad * sin (Pi / (4 * Level) * i + 3 * Pi / 4 ),
               Rad * cos (Pi / (4 * Level) * i + 3 * Pi / 4), 0.0);
    glVertex3f(Rad - Rad * i / 10, -Rad, 0.0);
    glVertex3f(Rad * sin (Pi / (4 * Level) * (i + 1) + 3 * Pi / 4),
               Rad * cos (Pi / (4 * Level) * (i + 1) + 3 * Pi / 4), 0.0);
    glVertex3f(Rad - Rad * (i + 1) / 10, -Rad, 0.0);
  end;
  glEnd;
end;
