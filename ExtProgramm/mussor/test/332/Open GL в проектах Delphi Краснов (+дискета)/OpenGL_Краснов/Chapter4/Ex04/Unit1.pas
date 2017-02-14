unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

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
    Label5: TLabel;
    Bevel1: TBevel;
    Label6: TLabel;
    Label7: TLabel;
    lblMatAmbient: TLabel;
    lblMatDiffuse: TLabel;
    Label10: TLabel;
    lblMatSpecular: TLabel;
    Label12: TLabel;
    Label8: TLabel;
    lblMatEmission: TLabel;
    Label9: TLabel;
    lblMatShininess: TLabel;
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
  lblMatAmbient.Caption := '(' + FloatToStr (frmGL.MaterialAmbient[0])  +
                        '; ' + FloatToStr (frmGL.MaterialAmbient[1]) +
                        '; ' + FloatToStr (frmGL.MaterialAmbient[2]) + ')';
  lblMatDiffuse.Caption := '(' + FloatToStr (frmGL.MaterialDiffuse[0])  +
                        '; ' + FloatToStr (frmGL.MaterialDiffuse[1]) +
                        '; ' + FloatToStr (frmGL.MaterialDiffuse[2]) + ')';
  lblMatSpecular.Caption := '(' + FloatToStr (frmGL.MaterialSpecular[0])  +
                        '; ' + FloatToStr (frmGL.MaterialSpecular[1]) +
                        '; ' + FloatToStr (frmGL.MaterialSpecular[2]) + ')';
  lblMatEmission.Caption := '(' + FloatToStr (frmGL.MaterialEmission[0])  +
                        '; ' + FloatToStr (frmGL.MaterialEmission[1]) +
                        '; ' + FloatToStr (frmGL.MaterialEmission[2]) + ')';
  lblMatShininess.Caption := FloatToStr (frmGL.Shininess);
end;


procedure TfrmInfo.FormDeactivate(Sender: TObject);
begin
  Close
end;



end.
