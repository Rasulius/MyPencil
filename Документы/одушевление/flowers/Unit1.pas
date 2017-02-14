// Рисование цветов
// источник http://programania.com/flowers.zip
{$B-,R-}
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, math, StdCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    Button1: TButton;
    Button2: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
q=16;
//изгиб стебля и лепестков
iStebel:array[1..q] of integer=
  (7,14,20,26,32,35,38,40,41,42,40,38,34,30,18,0);

qc=5;
//цвета цветов
cc: array[0..qc-1] of integer=(
$0FDEFF,$FE6310,$630FFF,$F210FE,$FEF210);

var
Form1: TForm1;
w,w2,h,h2,qt:integer;
awto:boolean=false; //автоматически
wTimer:boolean=false;
qp: integer=0;// число повторов на 1 месте
cp: integer=0;// номер цвета цветка
ts: array[1..q] of record x,y:integer end;//точки стебля для листьев

implementation

{$R *.DFM}
{$R WindowsXP.res}

PROCEDURE stebel(xn,yn,xk,yk:integer; w:boolean);
var
i,x,y: integer;
dx,dy,v: extended;
begin
//рисование стебля
with form1.image1.Picture.Bitmap.canvas do begin
  moveTo(xn,yn);
  dx:=(xk-xn)/ q;
  dy:=(yk-yn)/ q;
  if w then begin qt:=0; v:=dx/5.5 end
       else v:=random(20)/100+0.1; //изгиб лепестков
  for i:=1 to q do begin
    x:=xn+trunc(dx*i);
    y:=yn+trunc(dy*i);
    if w then begin//стебли
      dec(x,trunc(iStebel[i]*v));inc(qt); ts[qt].x:=x; ts[qt].y:=y
    end
    else dec(y,trunc(iStebel[i]*v));//цветы и лисьтя
    lineTo(x,y)
  end;
end;
end;


PROCEDURE cwetok(x,y:integer);
var
d,r,i,j,xk,yk,c,t,nc:integer;
m: array[1..4] of byte absolute c;

Function pc(n:byte):integer;
begin
//получение цвета цветка
result:=m[n]+random(64);
if result>255 then result:=220+random(32);
if result<0   then result:=random(32);
end;

begin
c:=cp;
while c=cp do c:=random(qc); //разноцветные цветы
nc:=c;
for j:=1 to 2 do begin
i:=0;
if j=2 then begin r:=w div 50+random(4); inc(nc,2);if nc>=qc then nc:=0 end
       else begin r:=w div 12+random(40);cp:=nc end;
c:=cc[nc];
d:=r div 4;
while i<68 do begin
  xk:=x+trunc(r*sin(i/10))+random(d);
  yk:=y+trunc(r*cos(i/10))+random(d);
  form1.image1.Picture.Bitmap.canvas.pen.color:=
    rgb(pc(1),pc(2),pc(3));
  if j=1 then t:=6+random(3)
         else t:=3+random(3);
  form1.image1.Picture.Bitmap.canvas.pen.width:=t;
  stebel(x,y,xk,yk,false);
  inc(i,3);
end;
end;
end;

PROCEDURE cTrawa;
begin
form1.image1.Picture.Bitmap.canvas.pen.color:=
rgb(random(60),150+random(50),random(60));
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
d,i,j,qs,xn,yn,xk,yk,xks,yks:integer;

begin
if wTimer then exit;
wTimer:=true;
timer1.enabled:=awto;
randomize;
w:=image1.width;
h:=image1.height;
h2:=h div 2;
w2:=w div 2;

with image1.Picture.Bitmap.canvas do begin
brush.color:=$CCF0FF;
image1.Picture.Bitmap.width:=w;
image1.Picture.Bitmap.height:=h;

if random(qp)>2 then begin qp:=5;fillRect(rect(0,0,w,h))end
                else inc(qp,2);

qs:=5;
for i:=1 to qs do begin
//стебли
  xks:=w div 12+(w-w div 12) div qs*(i-1);
  yks:=h div 4+random(h div 8)-h div 8+
       abs(i-1-qs div 2)*(h div 16); //в центре выше
  cTrawa;
  pen.width:=3+random(3);
  stebel(w2+i*4-qs*4, h,  xks,yks, true);

//листья
  for j:=1 to qt-2 do begin              //снизу гуще
    for d:=-2 to 2 do if (d<>0)and(random(10)>j div 2) then begin
      cTrawa;
      pen.width:=1+random(2)+j div 8;//сверху шире
      xn:=ts[j].x;   xk:=xn+(w div 24)*d+random(20)-10;
      yn:=ts[j].y;   yk:=yn-20-random(20);
      stebel(xn, yn, xk,yk, false);
    end;
  end;

//цветы
  cwetok(xks,  yks);
end;
end;
wTimer:=false;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
Form1.Timer1Timer(Sender);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
awto:=not awto;
if awto then begin button2.caption:='Стой'; timer1.enabled:=true end
        else button2.caption:='Сама';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
color:=$B0CEE8;
end;

end.
