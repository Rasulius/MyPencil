unit ParObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Main, OpenGL;

type
  TfrmParObject = class(TForm)
    edtX: TEdit;
    Label1: TLabel;
    edtY: TEdit;
    Label2: TLabel;
    edtZ: TEdit;
    Label3: TLabel;
    btnOK: TButton;
    edtL: TEdit;
    Label4: TLabel;
    edtW: TEdit;
    Label5: TLabel;
    edtH: TEdit;
    Label6: TLabel;
    Button2: TButton;
    cmbKind: TComboBox;
    edtRotZ: TEdit;
    edtRotY: TEdit;
    edtRotX: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure edtXKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  protected
    procedure WindowMoving (var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WindowMove (var Msg: TWMMove); message WM_MOVE;
  end;

var
  frmParObject: TfrmParObject;

implementation

{$R *.DFM}

procedure TfrmParObject.btnOKClick(Sender: TObject);
begin
  With frmMain.objects [frmMain.PopupObject] do begin
    X := StrToFloat (edtX.Text);
    Y := StrToFloat (edtY.Text);
    Z := StrToFloat (edtZ.Text);

    L := StrToFloat (edtL.Text);
    W := StrToFloat (edtW.Text);
    H := StrToFloat (edtH.Text);

    RotX := StrToFloat (edtRotX.Text);
    RotY := StrToFloat (edtRotY.Text);
    RotZ := StrToFloat (edtRotZ.Text);

    Case cmbKind.ItemIndex of
         0 : kind := Cube;
         1 : kind := Sphere;
         2 : kind := Cylinder;
         else If cmbKind.Text = 'Параллепипед'
            then kind := Cube
            else
            If cmbKind.Text = 'Сфера' then kind := Sphere
            else kind := Cylinder;
    end;

  end;
  frmParObject.Visible := False;
  frmMain.SetProjection (nil);
end;

procedure TfrmParObject.edtXKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_RETURN then btnOK.OnClick (nil);
end;

procedure TfrmParObject.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 frmMain.SetProjection (nil);
end;

procedure TfrmParObject.Button2Click(Sender: TObject);
begin
 frmMain.ColorToGlu (frmMain.objects [frmMain.PopupObject].color [0],
                   frmMain.objects [frmMain.PopupObject].color [1],
                   frmMain.objects [frmMain.PopupObject].color [2])
end;

procedure TfrmParObject.WindowMoving (var Msg: TWMSysCommand);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmParObject.WindowMove (var Msg: TWMMove);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmParObject.FormDeactivate(Sender: TObject);
begin
 Close
end;

procedure TfrmParObject.FormResize(Sender: TObject);
begin
 frmMain.flgMouseMove := False;
 frmMain.DrawScene (GL_RENDER);
end;

procedure TfrmParObject.FormShow(Sender: TObject);
begin
 frmMain.SetProjection (nil);
 edtX.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].X);
 edtY.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].Y);
 edtZ.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].Z);
 edtH.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].H);
 edtW.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].W);
 edtL.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].L);
 edtRotX.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].RotX);
 edtRotY.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].RotY);
 edtRotZ.Text := FloatToStr (frmMain.objects [frmMain.PopupObject].RotZ);
 Case frmMain.objects [frmMain.PopupObject].kind of
    Cube : cmbKind.ItemIndex := 0;
    Sphere : cmbKind.ItemIndex := 1;
    Cylinder : cmbKind.ItemIndex := 2;
 end;
end;

end.
