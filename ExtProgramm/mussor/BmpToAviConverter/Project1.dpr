program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  AviWriter in 'AviWriter.pas';


const
  outputFileName ='D:\�������\� ������\MyPencil\BmpToAviConverter\TestFolder\output.avi';
var
  anAviCreateParams: TAVICreateParams;
  aFileList: TStringList;
  aConverter: TSimpleAVIWriter;
begin
  aFileList:= TStringList.Create;
  try

    aFileList.Add('temp_0000000000.bmp');
    aFileList.Add('temp_0000000001.bmp');
    aFileList.Add('temp_0000000002.bmp');
    aFileList.Add('temp_0000000003.bmp');
    aFileList.Add('temp_0000000004.bmp');
    aFileList.Add('temp_0000000005.bmp');
    aFileList.Add('temp_0000000006.bmp');
    aFileList.Add('temp_0000000007.bmp');
    aFileList.Add('temp_0000000008.bmp');
    aFileList.Add('temp_0000000009.bmp');
    try
      anAviCreateParams := TAVICreateParams.Create('D:\�������\� ������\MyPencil\BmpToAviConverter\TestFolder',
        aFileList,12,outputFileName,'D:\�������\� ������\MyPencil\BmpToAviConverter\TestFolder',0, 640,480);

      try
        aConverter:= TSimpleAVIWriter.Create;
        try
          aConverter.ConvertBMPSeriesToAvi(anAviCreateParams);
        finally
          aConverter.Free;
        end;

      finally
        anAviCreateParams.Free;
      end;

    finally
      aFileList.Free;
    end;


    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
