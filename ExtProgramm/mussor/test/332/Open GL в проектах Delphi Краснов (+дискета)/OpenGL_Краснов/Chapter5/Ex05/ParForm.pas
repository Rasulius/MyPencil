// Модуль отображения окна параметров
type
   PInteger = ^Integer;
   PBoolean = ^Boolean;
   PGlFloat = ^GlFloat;
   TParamForm = procedure (PFlagOc, PFlagSquare,
                           PFlagLight, PFlagCursor : PBoolean;
                           PColorRed, PColorGreen, PColorBlue : PGlFloat;
                           PMaterial : PMaterial;
                           PLPosition : PArray4D;
                           PFAmbient  : PArray4D;
                           PRPosition : PArray3D) stdcall;

var
   ParamForm : TParamForm;

procedure CreateParWindow;
begin
   hCDll := LoadLibrary('ParForm.dll');
   If hCDll <= HINSTANCE_ERROR then begin
         hCDll := NULL;
         exit
      end
      else ParamForm := GetProcAddress(hCDll, 'ParamForm');
   If not Assigned (ParamForm) then exit
      else ParamForm (@flgOc, @flgSquare, @flgLight, @flgCursor,
                      @Colors [1], @Colors [2], @Colors [3],
                      PMaterials, PLPosition, PFAmbient, PRPosition);
   If not hCDll = NULL then begin
      FreeLibrary(hCDll);
      hCdll := NULL;
   end;
end;
