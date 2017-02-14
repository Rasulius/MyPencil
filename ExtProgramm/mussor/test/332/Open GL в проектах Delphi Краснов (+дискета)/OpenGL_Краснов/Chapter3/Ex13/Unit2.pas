unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm2 = class(TForm)
    edtEyeX: TEdit;
    edtEyeY: TEdit;
    edtEyeZ: TEdit;
    edtCenterX: TEdit;
    edtCenterY: TEdit;
    edtCenterZ: TEdit;
    edtUpX: TEdit;
    edtUpY: TEdit;
    edtUpZ: TEdit;
    btnOK: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure edtEyeZKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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

procedure TForm2.FormShow(Sender: TObject);
begin
 edtEyeX.Text := FloatToStr (frmGL.EyeX);
 edtEyeY.Text := FloatToStr (frmGL.EyeY);
 edtEyeZ.Text := FloatToStr (frmGL.EyeZ);
 edtCenterX.Text := FloatToStr (frmGL.CenterX);
 edtCenterY.Text := FloatToStr (frmGL.CenterY);
 edtCenterZ.Text := FloatToStr (frmGL.CenterZ);
 edtUpX.Text := FloatToStr (frmGL.UpX);
 edtUpY.Text := FloatToStr (frmGL.UpY);
 edtUpZ.Text := FloatToStr (frmGL.UpZ);
end;

procedure TForm2.btnOKClick(Sender: TObject);
begin
 With frmGL do begin
 EyeX := StrToFloat (edtEyeX.Text);
 EyeY := StrToFloat (edtEyeY.Text);
 EyeZ := StrToFloat (edtEyeZ.Text);
 CenterX := StrToFloat (edtCenterX.Text);
 CenterY := StrToFloat (edtCenterY.Text);
 CenterZ := StrToFloat (edtCenterZ.Text);
 UpX := StrToFloat (edtUpX.Text);
 UpY := StrToFloat (edtUpY.Text);
 UpZ := StrToFloat (edtUpZ.Text);
 FormResize (nil);
 end;
end;

procedure TForm2.edtEyeZKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_RETURN then btnOKClick(nil)
end;

end.
