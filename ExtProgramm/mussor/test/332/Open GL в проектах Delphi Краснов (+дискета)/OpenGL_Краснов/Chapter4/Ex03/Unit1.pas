unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmInfo = class(TForm)
    Label1: TLabel;
    lblAmbient: TLabel;
    lblDiffuse: TLabel;
    Label3: TLabel;
    lblSpecular: TLabel;
    Label4: TLabel;
    Label2: TLabel;
    lblRGB: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInfo: TfrmInfo;

implementation

uses frmMain;

{$R *.DFM}

procedure TfrmInfo.FormShow(Sender: TObject);
begin
  lblAmbient.Caption := '(' + FloatToStr (frmGL.Ambient[0])  +
                        '; ' + FloatToStr (frmGL.Ambient[1]) +
                        '; ' + FloatToStr (frmGL.Ambient[2]) + ')';
  lblDiffuse.Caption := '(' + FloatToStr (frmGL.Diffuse[0])  +
                        '; ' + FloatToStr (frmGL.Diffuse[1]) +
                        '; ' + FloatToStr (frmGL.Diffuse[2]) + ')';
  lblSpecular.Caption := '(' + FloatToStr (frmGL.Specular[0])  +
                        '; ' + FloatToStr (frmGL.Specular[1]) +
                        '; ' + FloatToStr (frmGL.Specular[2]) + ')';
  lblRGB.Caption := '(' + FloatToStr (frmGL.R)  +
                    '; ' + FloatToStr (frmGL.G) +
                    '; ' + FloatToStr (frmGL.B) + ')';
end;


procedure TfrmInfo.FormDeactivate(Sender: TObject);
begin
  Close
end;

end.
