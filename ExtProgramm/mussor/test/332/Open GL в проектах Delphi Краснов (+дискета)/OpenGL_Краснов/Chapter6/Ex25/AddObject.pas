unit AddObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Main, OpenGL;

type
  TfrmAddObject = class(TForm)
    edtX: TEdit;
    Label1: TLabel;
    edtY: TEdit;
    Label2: TLabel;
    edtZ: TEdit;
    Label3: TLabel;
    btnOK: TButton;
    edtL: TEdit;
    Label4: TLabel;
    edtK: TEdit;
    Label5: TLabel;
    edtH: TEdit;
    Label6: TLabel;
    cmbKind: TComboBox;
    edtRotX: TEdit;
    edtRotY: TEdit;
    edtRotZ: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure edtXKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDeactivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  protected
    procedure WindowMoving (var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WindowMove (var Msg: TWMMove); message WM_MOVE;
  end;

var
  frmAddObject: TfrmAddObject;

implementation

{$R *.DFM}

procedure TfrmAddObject.btnOKClick(Sender: TObject);
begin
  With frmMain.objects [frmMain.objectcount + 1] do begin
    X := StrToFloat (edtX.Text);
    Y := StrToFloat (edtY.Text);
    Z := StrToFloat (edtZ.Text);

    L := StrToFloat (edtL.Text);
    W := StrToFloat (edtK.Text);
    H := StrToFloat (edtH.Text);

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

    RotX := StrToFloat (edtRotX.Text);
    RotY := StrToFloat (edtRotY.Text);
    RotZ := StrToFloat (edtRotZ.Text);

    color[0] := (random(100) + 50) / 150.0;
    color[1] := (random(100) + 50) / 150.0;
    color[2] := (random(100) + 50) / 150.0;
  end;
  frmMain.Save;
  Inc (frmMain.objectcount);
  Visible := False;
  frmMain.flgMouseMove := False;
  frmMain.DrawScene (GL_RENDER);
end;

procedure TfrmAddObject.edtXKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_RETURN then btnOK.OnClick (Sender);
end;

procedure TfrmAddObject.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.SetProjection(nil);
end;

procedure TfrmAddObject.FormResize(Sender: TObject);
begin
 frmMain.SetProjection (nil);
end;

procedure TfrmAddObject.FormDeactivate(Sender: TObject);
begin
 Close
end;

procedure TfrmAddObject.WindowMoving (var Msg: TWMSysCommand);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmAddObject.WindowMove (var Msg: TWMMove);
begin
 inherited;
 frmMain.SetProjection (nil);
end;


end.
