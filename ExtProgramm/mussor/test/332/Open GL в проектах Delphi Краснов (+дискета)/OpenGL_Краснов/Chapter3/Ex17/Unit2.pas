unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm2 = class(TForm)
    edt00: TEdit;
    edt10: TEdit;
    edt20: TEdit;
    edt30: TEdit;
    edt01: TEdit;
    edt11: TEdit;
    edt21: TEdit;
    edt31: TEdit;
    edt02: TEdit;
    edt12: TEdit;
    edt22: TEdit;
    edt32: TEdit;
    edt03: TEdit;
    edt13: TEdit;
    edt23: TEdit;
    edt33: TEdit;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.DFM}

procedure TForm2.btnOKClick(Sender: TObject);
begin
 With frmGL do begin
  mt [0, 0] := StrToFloat (edt00.Text);
  mt [0, 1] := StrToFloat (edt01.Text);
  mt [0, 2] := StrToFloat (edt02.Text);
  mt [0, 3] := StrToFloat (edt03.Text);
  mt [1, 0] := StrToFloat (edt10.Text);
  mt [1, 1] := StrToFloat (edt11.Text);
  mt [1, 2] := StrToFloat (edt12.Text);
  mt [1, 3] := StrToFloat (edt13.Text);
  mt [2, 0] := StrToFloat (edt20.Text);
  mt [2, 1] := StrToFloat (edt21.Text);
  mt [2, 2] := StrToFloat (edt22.Text);
  mt [2, 3] := StrToFloat (edt23.Text);
  mt [3, 0] := StrToFloat (edt30.Text);
  mt [3, 1] := StrToFloat (edt31.Text);
  mt [3, 2] := StrToFloat (edt32.Text);
  mt [3, 3] := StrToFloat (edt33.Text);
  FormResize (nil);
 end;
end;

end.
