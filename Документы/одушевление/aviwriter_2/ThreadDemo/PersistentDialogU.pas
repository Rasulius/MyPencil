unit PersistentDialogU;

//Base class for a dialog form which can be created and freed
//on the fly, but can still be persistent when created with
//the constructor 'make'. It then streams out its dfm file to
//a temp directory and reads it back in when recreated.
//User must take care of erasing the temp-folder when
//application finishes.

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TPersistentDialog = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    fTempDir: string;
    fOnFirstCreate: TNotifyEvent;
    { Private declarations }
  public
    constructor Make(const TempDir: string);
    destructor Destroy; override;
    function GetPopupPosition(p: TPoint; w, h, sw, sh: integer): TPoint;
    property OnFirstCreate: TNotifyEvent read fOnFirstCreate write fOnFirstCreate;
    { Public declarations }
  end;

var
  PersistentDialog: TPersistentDialog;

implementation

{$R *.DFM}

uses FileCtrl;

{ TPersistentDialog }

destructor TPersistentDialog.Destroy;
begin
  if fTempDir <> '' then
    if DirectoryExists(fTempDir) then
    begin
      Visible := false;
      WriteComponentResFile(fTempDir + '\' + ClassName + '.dfm', Self);
    end;
  inherited;
end;

constructor TPersistentDialog.Make(const TempDir: string);
var p: TPoint;
begin
  if (TempDir <> '') and FileExists(TempDir + '\' + ClassName + '.dfm') then
  begin
    CreateNew(nil);
    ReadComponentResFile(TempDir + '\' + ClassName + '.dfm', Self);
    if Assigned(OnCreate) then
      OnCreate(Self);
  end
  else
  begin
    Create(nil);
    if Assigned(fOnFirstCreate) then fOnFirstCreate(Self);
  end;
  if Length(TempDir) > 0 then
    fTempDir := TempDir
  else
    fTempDir := '';
  GetCursorPos(p);
  p := GetPopupPosition(p, Width, Height, screen.Width, screen.Height);
  SetBounds(p.x, p.y, Width, Height);
end;

function TPersistentDialog.GetPopupPosition(p: TPoint; w, h, sw, sh: integer): TPoint;
begin
  if p.x > w + 10 then
    Result.x := p.x - w - 10
  else
    Result.x := p.x + 10;
  if p.y - (h div 2) > 0 then
    Result.y := p.y - (h div 2)
  else
    Result.y := p.y;
end;

end.

