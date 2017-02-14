type
  TAboutForm = procedure stdcall;

var
  AboutForm : TAboutForm;

procedure About;
begin
  try
   hCDll := LoadLibrary('About');
   If hCDll <= HINSTANCE_ERROR then begin
         hCDll := NULL;
         Exit
      end
   else
      AboutForm := GetProcAddress(hCDll, 'AboutForm');
   If not Assigned (AboutForm)
      then Exit
      else AboutForm;
   If not hCDll = NULL then begin
      FreeLibrary (hCDll);
      hCdll := NULL;
     end;
  except
   Exit
  end; //try
end;

