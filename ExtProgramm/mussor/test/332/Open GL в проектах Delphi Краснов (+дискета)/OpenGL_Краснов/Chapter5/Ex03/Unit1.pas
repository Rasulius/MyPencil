{**********************************************************************}
{* Иллюстрация к книге "OpenGL в проектах Delphi"                     *}
{* Краснов М.В. softgl@chat.ru                                        *}
{**********************************************************************}

// модуль визуального задания значений параметров
// форма, размещаемая в DLL
unit Unit1;

interface

uses
  Windows, Messages, Sysutils, Classes, Forms, StdCtrls, ExtCtrls,
  OpenGL, Controls, ComCtrls, Tabnotbk;

// вводимые типы - указатели на передававемые переменные
type
  PBoolean = ^Boolean;
  TMaterial = 1..7;
  PMaterial = ^TMaterial;
  TSetMaterial = procedure stdcall; // процедура, вызываемая из библиотеки

  Array3D = Array [1..3] of GlFloat;
  Array4D = Array [1..4] of GlFloat;
  PArray3D = ^Array3D;
  PArray4D = ^Array4D;

type
  TForm1 = class(TForm)
    btnApply: TButton;
    btnCancel: TButton;
    btnOK: TButton;
    TabbedNotebook1: TTabbedNotebook;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ScrollBarRed: TScrollBar;
    ScrollBarGreen: TScrollBar;
    ScrollBarBlue: TScrollBar;
    Label9: TLabel;
    ComboBoxMaterial: TComboBox;
    Label10: TLabel;
    CheckBoxLight: TCheckBox;
    CheckBoxSquare: TCheckBox;
    CheckBoxOC: TCheckBox;
    udLPosX: TUpDown;
    edtLPositionX: TEdit;
    edtLPositionY: TEdit;
    udLPosY: TUpDown;
    edtLPositionZ: TEdit;
    udLPosZ: TUpDown;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label11: TLabel;
    edtRPositionX: TEdit;
    udRPosX: TUpDown;
    Label12: TLabel;
    edtRPositionY: TEdit;
    udRPosY: TUpDown;
    Label13: TLabel;
    edtRPositionZ: TEdit;
    udRPosZ: TUpDown;
    Label14: TLabel;
    edtFAmbientR: TEdit;
    edtFAmbientG: TEdit;
    udFAmbR: TUpDown;
    udFAmbG: TUpDown;
    edtFAmbientB: TEdit;
    udFAmbB: TUpDown;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    edtFAmbientS: TEdit;
    udFAmbS: TUpDown;
    Label18: TLabel;
    Label19: TLabel;
    btnError: TButton;
    lblError: TLabel;
    cbCursor: TCheckBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure CheckBoxOCClick(Sender: TObject);
    procedure udLPosXChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udLPosYChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udLPosZChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udRPosXChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udRPosYChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udRPosZChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udFAmbRChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udFAmbGChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udFAmbBChanging(Sender: TObject; var AllowChange: Boolean);
    procedure udFAmbSChanging(Sender: TObject; var AllowChange: Boolean);
    procedure btnErrorClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure Proverka;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1 : TForm1;
  hCDll : THandle;
  wrkPFlagOc : PBoolean;
  wrkPFlagSquare : PBoolean;
  wrkPFlagLight : PBoolean;
  wrkPFlagCursor : PBoolean;
  wrkPColorRed : PGLFloat;
  wrkPColorGreen : PGLFloat;
  wrkPColorBlue : PGLFloat;
  wrkPMaterial : PMaterial;
  SetMaterial  : TSetMaterial;
  wrkPLPosition : PArray4D;
  wrkPFAmbient  : PArray4D;
  wrkPRPosition : PArray3D;

// процедура, размещаемая в DLL
procedure ParamForm (PFlagOc, PFlagSquare,
          PFlagLight, PFlagCursor : PBoolean;
          PColorRed, PColorGreen, PColorBlue : PGLFloat;
          PMaterial : PMaterial;
          PLPosition : PArray4D;
          PFAmbient  : PArray4D;
          PRPosition : PArray3D); stdcall; export;

implementation

{$R *.DFM}

// процедура проверки полей редактирования
procedure TForm1.Proverka;
var
 iW : Integer;
 dW : Double;
begin
 If edtFAmbientR.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtFAmbientR.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtFAmbientG.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtFAmbientG.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtFAmbientB.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtFAmbientB.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtFAmbientS.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtFAmbientS.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtLPositionX.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtLPositionX.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtLPositionY.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtLPositionY.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtLPositionZ.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtLPositionZ.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtRPositionX.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtRPositionX.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtRPositionY.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtRPositionY.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
 If edtRPositionZ.Text = '' then raise EAbort.Create ('Заполните все поля!');
 Val (edtRPositionZ.Text, dW, iW);
 If (iW<>0) then raise EAbort.Create ('Числовые данные введены с ошибкой!');
end;

// процедура считывания значений параметров
procedure Start;
var
 wrkString : String;
begin
 If wrkPFlagOc^ then Form1.CheckBoxOC.Checked := True
                else Form1.CheckBoxOC.Checked := False;
 If wrkPFlagSquare^ then Form1.CheckBoxSquare.Checked := True
                    else Form1.CheckBoxSquare.Checked := False;
 If wrkPFlagLight^ then Form1.CheckBoxLight.Checked := True
                   else Form1.CheckBoxLight.Checked := False;
 If wrkPFlagCursor^ then Form1.cbCursor.Checked := True
                    else Form1.cbCursor.Checked := False;
 // Установка скроллбаров цветов
 Form1.ScrollBarRed.Position := round (wrkPColorRed^ * 100);
 Form1.ScrollBarGreen.Position := round (wrkPColorGreen^ * 100);
 Form1.ScrollBarBlue.Position := round (wrkPColorBlue^ * 100);
 // материал
 Form1.ComboBoxMaterial.ItemIndex := wrkPMaterial^ - 1;
 Form1.btnApply.Enabled := False;
 Form1.btnCancel.Enabled := False;
 // заполнение полей редактирования
 Str (wrkPLPosition^ [1] : 6 : 2, wrkString);
 Form1.edtLPositionX.Text := wrkString;
 Form1.udLPosX.Position := round (wrkPLPosition^ [1] * 100 + 15000);
 Str (wrkPLPosition^ [2] : 6 : 2, wrkString);
 Form1.edtLPositionY.Text := wrkString;
 Form1.udLPosY.Position := round (wrkPLPosition^ [2] * 100 + 15000);
 Str (wrkPLPosition^ [3] : 6 : 2, wrkString);
 Form1.edtLPositionZ.Text := wrkString;
 Form1.udLPosZ.Position := round (wrkPLPosition^ [3] * 100 + 15000);
 Str (wrkPRPosition^ [1] : 6 : 2, wrkString);
 Form1.edtRPositionX.Text := wrkString;
 Form1.udRPosX.Position := round (wrkPRPosition^ [1] * 100 + 15000);
 Str (wrkPRPosition^ [2] : 6 : 2, wrkString);
 Form1.edtRPositionY.Text := wrkString;
 Form1.udRPosY.Position := round (wrkPRPosition^ [2] * 100 + 15000);
 Str (wrkPRPosition^ [3] : 6 : 2, wrkString);
 Form1.edtRPositionZ.Text := wrkString;
 Form1.udRPosZ.Position := round (wrkPRPosition^ [3] * 100 + 15000);
 Str (wrkPFAmbient^ [1] : 5 : 3, wrkString);
 Form1.edtFAmbientR.Text := wrkString;
 Form1.udFAmbR.Position := round (wrkPFAmbient^ [1] * 1000 + 15000);
 Str (wrkPFAmbient^ [2] : 5 : 3, wrkString);
 Form1.edtFAmbientG.Text := wrkString;
 Form1.udFAmbG.Position := round (wrkPFAmbient^ [2] * 1000 + 15000);
 Str (wrkPFAmbient^ [3] : 5 : 3, wrkString);
 Form1.edtFAmbientB.Text := wrkString;
 Form1.udFAmbB.Position := round (wrkPFAmbient^ [3] * 1000 + 15000);
 Str (wrkPFAmbient^ [4] : 5 : 3, wrkString);
 Form1.edtFAmbientS.Text := wrkString;
 Form1.udFAmbS.Position := round (wrkPFAmbient^ [4] * 1000 + 15000);
end;

// процедура установки значений параметров
procedure Apply;
var
 wrkSingle : Single;
 wrkInteger : Integer;
begin
 // проверка на заполнение полей редактирования
 try
   Form1.Proverka
 except
   on E : EAbort do
   With Form1 do begin
     TabbedNotebook1.Visible := False;
     btnApply.Visible := False;
     btnCancel.Visible := False;
     btnOK.Visible := False;
     btnError.Visible := True;
     lblError.Caption := E.Message;
     lblError.Visible := True;
     Exit; // ошибка, данные применять нельзя
   end;// with
 end; // try
 If Form1.CheckBoxOC.Checked
    then wrkPFlagOc^ := True
    else wrkPFlagOc^ := False;
 If Form1.CheckBoxSquare.Checked
    then wrkPFlagSquare^ := True
    else wrkPFlagSquare^ := False;
 If Form1.CheckBoxLight.Checked
    then wrkPFlagLight^ := True
    else wrkPFlagLight^ := False;
 If Form1.cbCursor.Checked
    then wrkPFlagCursor^ := True
    else wrkPFlagCursor^ := False;
 // установка цветов
 wrkPColorRed^ := Form1.ScrollBarRed.Position / 100;
 wrkPColorGreen^ := Form1.ScrollBarGreen.Position / 100;
 wrkPColorBlue^ := Form1.ScrollBarBlue.Position / 100;
 glColor3f (wrkPColorRed^, wrkPColorGreen^, wrkPColorBlue^);
 // материал (основан на нуле)
 wrkPMaterial^ := Form1.ComboBoxMaterial.ItemIndex + 1;
 // считывание данных из полей редактирования (UpDown)
 Val (Form1.edtLPositionX.Text, wrkSingle, wrkInteger);
 wrkPLPosition^ [1] := wrkSingle;
 Val (Form1.edtLPositionY.Text, wrkSingle, wrkInteger);
 wrkPLPosition^ [2] := wrkSingle;
 Val (Form1.edtLPositionZ.Text, wrkSingle, wrkInteger);
 wrkPLPosition^ [3] := wrkSingle;
 Val (Form1.edtRPositionX.Text, wrkSingle, wrkInteger);
 wrkPRPosition^ [1] := wrkSingle;
 Val (Form1.edtRPositionY.Text, wrkSingle, wrkInteger);
 wrkPRPosition^ [2] := wrkSingle;
 Val (Form1.edtRPositionZ.Text, wrkSingle, wrkInteger);
 wrkPRPosition^ [3] := wrkSingle;
 Val (Form1.edtFAmbientR.Text, wrkSingle, wrkInteger);
 wrkPFAmbient^ [1] := wrkSingle;
 Val (Form1.edtFAmbientG.Text, wrkSingle, wrkInteger);
 wrkPFAmbient^ [2] := wrkSingle;
 Val (Form1.edtFAmbientB.Text, wrkSingle, wrkInteger);
 wrkPFAmbient^ [3] := wrkSingle;
 Val (Form1.edtFAmbientS.Text, wrkSingle, wrkInteger);
 wrkPFAmbient^ [4] := wrkSingle;
 // считывание процедуры из библиотеки
 hCDll := LoadLibrary ('InitRC');
 If hCDll <= HINSTANCE_ERROR then begin
    hCDll := NULL;
    Exit
    end
    else
    SetMaterial := GetProcAddress (hCDll, 'SetMaterial');
 SetMaterial;
 If not hCDll = NULL then begin
    FreeLibrary(hCDll);
    hCdll := NULL;
 end;
end;

// процедура, размещаемая в DLL
procedure ParamForm (PFlagOc, PFlagSquare,
          PFlagLight, PFlagCursor : PBoolean;
          PColorRed, PColorGreen, PColorBlue : PGLFloat;
          PMaterial : PMaterial;
          PLPosition : PArray4D;
          PFAmbient  : PArray4D;
          PRPosition : PArray3D); stdcall; export;
begin
 ShowCursor (True);
 Form1 := TForm1.Create (Application);
 wrkPFlagOc := PFlagOc;
 wrkPFlagSquare := PFlagSquare;
 wrkPFlagLight := PFlagLight;
 wrkPFlagCursor := PFlagCursor;
 wrkPColorRed := PColorRed;
 wrkPColorGreen := PColorGreen;
 wrkPColorBlue := PColorBlue;
 wrkPMaterial := PMaterial;
 wrkPLPosition := PLPosition ;
 wrkPFAmbient  := PFAmbient  ;
 wrkPRPosition := PRPosition ;
 Start;
 Form1.btnCancel.Enabled := False;
 Form1.btnApply.Enabled := False;
 Form1.TabbedNotebook1.PageIndex := 0;
 Form1.Show;
end;

procedure TForm1.btnOKClick (Sender: TObject);
begin
 Apply;
 Close; // завершение работы диалогового окна
end;

procedure TForm1.btnApplyClick (Sender: TObject);
begin
 Apply;
 btnCancel.Enabled := False;
 btnApply.Enabled := False;
end;

// процедура считывания значений параметров
procedure TForm1.btnCancelClick (Sender: TObject);
begin
 Start;
end;

// включение кнопок, процедура должна вызываться при измении параметров
procedure TForm1.CheckBoxOCClick (Sender: TObject);
begin
 btnApply.Enabled := True;
 btnCancel.Enabled := True;
end;

procedure TForm1.udLPosXChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 Str (((udLPosX.Position - 15000) / 100) : 6 : 2, wrkString);
 edtLPositionX.Text := wrkString;
end;

procedure TForm1.udLPosYChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 Str (((udLPosY.Position - 15000) / 100) : 6 : 2, wrkString);
 edtLPositionY.Text := wrkString;
end;

procedure TForm1.udLPosZChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 Str (((udLPosZ.Position - 15000) / 100) : 6 : 2, wrkString);
 edtLPositionZ.Text := wrkString;
end;

procedure TForm1.udRPosXChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 Str (((udRPosX.Position - 15000) / 100) : 6 : 2, wrkString);
 edtRPositionX.Text := wrkString;
end;

procedure TForm1.udRPosYChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 Str (((udRPosY.Position - 15000) / 100) : 6 : 2, wrkString);
 edtRPositionY.Text := wrkString;
end;


procedure TForm1.udRPosZChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 Str (((udRPosZ.Position - 15000) / 100) : 6 : 2, wrkString);
 edtRPositionZ.Text := wrkString;
end;

procedure TForm1.udFAmbRChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 If udFAmbR.Position < 15000 then udFAmbR.Position := 15000;
 If udFAmbR.Position > 16000 then udFAmbR.Position := 16000;
 Str (((udFAmbR.Position - 15000) / 1000) : 5 : 3, wrkString);
 edtFAmbientR.Text := wrkString;
end;

procedure TForm1.udFAmbGChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 If udFAmbG.Position < 15000 then udFAmbG.Position := 15000;
 If udFAmbG.Position > 16000 then udFAmbG.Position := 16000;
 Str (((udFAmbG.Position - 15000) / 1000) : 5 : 3, wrkString);
 edtFAmbientG.Text := wrkString;
end;

procedure TForm1.udFAmbBChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 If udFAmbB.Position < 15000 then udFAmbB.Position := 15000;
 If udFAmbB.Position > 16000 then udFAmbB.Position := 16000;
 Str (((udFAmbB.Position - 15000) / 1000) : 5 : 3, wrkString);
 edtFAmbientB.Text := wrkString;
end;

procedure TForm1.udFAmbSChanging(Sender: TObject;
  var AllowChange: Boolean);
var
 wrkString : String;
begin
 If udFAmbS.Position < 15000 then udFAmbS.Position := 15000;
 If udFAmbS.Position > 16000 then udFAmbS.Position := 16000;
 Str (((udFAmbS.Position - 15000) / 1000) : 5 : 3, wrkString);
 edtFAmbientS.Text := wrkString;
end;

// кнопка - ошибка
procedure TForm1.btnErrorClick(Sender: TObject);
begin
 TabbedNotebook1.Visible := True;
 btnApply.Visible := True;
 btnCancel.Visible := True;
 btnOK.Visible := True;
 btnError.Visible := False;
 lblError.Visible := False;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 If wrkPFlagCursor^ = False
    then ShowCursor (False)
    else ShowCursor (True); // рисовать ли курсор
end;

end.

