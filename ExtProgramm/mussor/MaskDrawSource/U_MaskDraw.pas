unit U_MaskDraw;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, jpeg, ExtCtrls, ComCtrls, GIFImage;

type
  TForm1 = class(TForm)
    MaskImg: TImage;
    SourceImg: TImage;
    DestImg0: TImage;
    Memimg1: TImage;
    Memimg2: TImage;
    DestImg3: TImage;
    DestImg4: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    StatusBar1: TStatusBar;
    procedure FormActivate(Sender: TObject);
  end;

var  Form1: TForm1;

implementation

{$R *.DFM}

{****************** FormActivate **********}
procedure TForm1.FormActivate(Sender: TObject);
var
  b:TBitmap;
  sw,sh:integer; {source width and height}
begin
  {initialize stuff}
  sw:=sourceimg.width; sh:=sourceimg.height;
  b:=TBitmap.create;
  b.loadfromfile('Clouds.bmp');
  destimg0.picture.bitmap:=b;

  destimg3.picture.bitmap:=b;
  destimg4.picture.bitmap:=b;
  with memimg1 do
  begin  width:=sw;  height:=sh;  end;
  with memimg2 do
  begin width:=sw;  height:=sh;  end;

  {Step 1: make the mask}
  with maskimg do
  begin
    width:=sw; height:=sh;
    canvas.draw(0,0,sourceimg.picture.bitmap);
    picture.bitmap.mask(canvas.pixels[1,1]);
  end;

  {Step2A: Copy mask to Mem with SrcCopy}
  MemImg1.canvas.copymode:=cmSrcCopy;
  MemImg1.canvas.draw(0,0,maskimg.picture.bitmap);
  MemImg2.canvas.copymode:=cmSrcCopy;
  MemImg2.canvas.Draw(0,0,maskimg.picture.bitmap);

  {Step2B: Copy Source to Mem with SrcErase}
  MemImg2.canvas.copymode:=cmSrcErase;
  MemImg2.canvas.draw(0,0,SourceImg.picture.bitmap);

  {Step3: Copy Mask to Dest with SrcAnd}
  DestImg3.canvas.copymode:=cmSrcAnd;
  DestImg3.canvas.draw(10,10,maskimg.picture.bitmap);
  DestImg4.canvas.copymode:=cmSrcAnd;
  DestImg4.canvas.draw(10,10,maskimg.picture.bitmap);

  {Step4: Copy Source to Dest with SrcInvert}
  DestImg4.canvas.copymode:=cmSrcInvert; {or cmSrcPaint};
  DestImg4.canvas.draw(10,10,memimg2.picture.bitmap);

  b.free;
end;


end.
