unit ScaleLetter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TfrmScaleLetter = class(TForm)
    trcScaleLetter: TTrackBar;
    Label1: TLabel;
    btnOK: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure trcScaleLetterChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
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
  frmScaleLetter: TfrmScaleLetter;

implementation

uses Main;

{$R *.DFM}


procedure TfrmScaleLetter.FormShow(Sender: TObject);
begin
 trcScaleLetter.Position := frmMain.ScaleLetter;
end;

procedure TfrmScaleLetter.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmMain.SetProjection(nil);
end;

procedure TfrmScaleLetter.FormResize(Sender: TObject);
begin
 frmMain.SetProjection (nil);
end;

procedure TfrmScaleLetter.FormDeactivate(Sender: TObject);
begin
  Close
end;

procedure TfrmScaleLetter.WindowMoving (var Msg: TWMSysCommand);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmScaleLetter.WindowMove (var Msg: TWMMove);
begin
 inherited;
 frmMain.SetProjection (nil);
end;

procedure TfrmScaleLetter.btnOKClick(Sender: TObject);
begin
 frmMain.ScaleLetter := trcScaleLetter.Position;
 frmScaleLetter.Visible := False;
 frmMain.SetProjection(nil);
end;

procedure TfrmScaleLetter.trcScaleLetterChange(Sender: TObject);
begin
 frmMain.ScaleLetter := trcScaleLetter.Position;
 frmMain.SetProjection (nil);
end;

procedure TfrmScaleLetter.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_ESCAPE then Close;
  If Key = VK_RETURN then btnOK.OnClick (Sender);
end;

end.
