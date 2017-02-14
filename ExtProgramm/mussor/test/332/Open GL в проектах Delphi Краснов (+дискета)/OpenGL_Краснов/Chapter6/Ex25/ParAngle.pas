unit ParAngle;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TfrmParAngle = class(TForm)
    TrackBar1: TTrackBar;
    Label1: TLabel;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure WindowMoving (var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WindowMove (var Msg: TWMMove); message WM_MOVE;
  end;

var
  frmParAngle: TfrmParAngle;

implementation

uses Main;

{$R *.DFM}

procedure TfrmParAngle.btnOKClick(Sender: TObject);
begin
 frmMain.udRotX.Increment := TrackBar1.Position;
 frmMain.udRotY.Increment := TrackBar1.Position;
 frmMain.udRotZ.Increment := TrackBar1.Position;
 frmParAngle.Visible := False;
 frmMain.SetProjection(nil);
end;

procedure TfrmParAngle.FormShow(Sender: TObject);
begin
 TrackBar1.Position := frmMain.udRotX.Increment;
end;

procedure TfrmParAngle.WindowMoving (var Msg: TWMSysCommand);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmParAngle.WindowMove (var Msg: TWMMove);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmParAngle.btnOKKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_RETURN then btnOK.OnClick (Sender);
end;

procedure TfrmParAngle.FormDeactivate(Sender: TObject);
begin
  Close
end;

end.
