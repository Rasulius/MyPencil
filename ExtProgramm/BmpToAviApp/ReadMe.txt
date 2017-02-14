BmpToAvi converts a folder containing bitmaps (BMP files) to an AVI
video file.  It's built on the BmpToAvi DirectShow filter DLL, and
doesn't use VfW so there's no 2GB limit.  The bitmaps must be numbered
sequentially, e.g. 000000.bmp, 000001.bmp, etc.  Any number of bitmaps
can be converted.  Note that the bitmaps must all have the same
attributes, i.e. frame size and bits per pixel.  The application checks
for inconsistent attributes and/or missing frames before the conversion
begins.  

The download contains the following items: 

BmpToAvi.exe
    The converter application. 
BmpToAvi.ax
    The DirectShow source filter; must be registered, via reg.bat! 
BmpToAvi.dll
    The filter's wrapper DLL; must be in the same folder as the .exe! 
reg.bat
    Batch file to register the source filter. 
unreg.bat
    Batch file to unregister the source filter.
ReadMe.txt
    This help file.

INSTALLING:

To run BmpToAvi, you must have previously registered the BmpToAvi
filter, otherwise you will get the error, "Can't create BmpToAvi filter,
Class not registered".  Use the batch file reg.bat to register the
filter, and use unreg.bat to unregister it.  Also note that BmpToAvi.dll
must reside in the same folder as the application.  

LICENSE: 

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.  This program is distributed in the hope that
it will be useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
the GNU General Public License for more details.  You should have
received a copy of the GNU General Public License along with this
program; if not, write to the Free Software Foundation, Inc., 59 Temple
Place, Suite 330, Boston, MA 02111 USA.

Kopyleft 2009 Chris Korda, all rites reversed.

END 
