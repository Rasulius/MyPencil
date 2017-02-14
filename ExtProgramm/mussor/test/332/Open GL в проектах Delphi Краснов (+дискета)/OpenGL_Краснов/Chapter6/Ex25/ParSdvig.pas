unit ParSdvig;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TfrmParSdvig = class(TForm)
    TrackBar1: TTrackBar;
    Label1: TLabel;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure btnOKKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure WindowMoving (var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WindowMove (var Msg: TWMMove); message WM_MOVE;
  end;

var
  frmParSdvig: TfrmParSdvig;

implementation

uses Main;

{$R *.DFM}

procedure TfrmParSdvig.btnOKClick(Sender: TObject);
begin
 frmMain.udAddX.Increment := TrackBar1.Position;
 frmMain.udAddY.Increment := TrackBar1.Position;
 frmMain.udAddZ.Increment := TrackBar1.Position;
 frmParSdvig.Visible := False;
 frmMain.SetProjection(nil);
end;

procedure TfrmParSdvig.FormShow(Sender: TObject);
begin
 TrackBar1.Position := frmMain.udAddX.Increment;
end;

procedure TfrmParSdvig.FormDeactivate(Sender: TObject);
begin
  Close
end;

procedure TfrmParSdvig.WindowMoving (var Msg: TWMSysCommand);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmParSdvig.WindowMove (var Msg: TWMMove);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmParSdvig.btnOKKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_RETURN then btnOK.OnClick (Sender);
end;

end.
