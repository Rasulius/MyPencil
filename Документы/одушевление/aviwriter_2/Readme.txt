Easiest way to install:

Load the program group AviDemo.bpg, install the package AviPack.dpk(bpl), 
try the demos. 
Read the source of AviWriter_2.pas (in AviPack) to get help on what the
procedures and properties do.

**Current version:

AviWriter_2 ver 1.0.0.4
Changes:
Finally got On-the-fly compression working with still
being able to add an audio-stream.
Use property OnTheFlyCompression (default is true)

Also, now more than one audio file can be added.
For each wav-file a delay (ms) can be specified,
which says when it'll start playing.
Use method AddWaveFile.
In 1.0.0.3 the delay got too short. Now
it seems to work, due to really adding "silence"
from the end of the previous audio file.

Note:
Some Codecs don't support On-the-fly compression.
If OnTheFlyCompression is false, only one wave file
can be added.



**A list of codec-gotchas:
(still unclear about the exact range of occurrance)

IV50 Indeo Video 5:
Both frame dimensions must be a factor of 4.

DIVX DivX codec:
Both frame dimensions must be a factor of 4.
Gives a floating point error under certain circumstances.
More and more likely that this occurs if the frames are
too "different".
If this happens, then there's an AV in Avifil32.dll,
don't know how to prevent this.
The codec compresses real movies nicely at frametimes <=60 ms,
when changing the settings in its dialog box as follows:
Bitrate (1st page): to >=1300
Max Keyframe interval (2nd page): to <=20.

MRLE MS-RLE
Use that one if you want to make avis which play
transparently in a TAnimate.
(Thanks Eddie Shipman)
But it does not support on-the-fly compression.



Whenever a codec fails to work, there's this dreaded error
"A call to an operating system function failed"  while writing
a compressed file, or an unhandled exception.
The only way to prevent it, that I see, is, to
collect more peculiarities about the codecs and stop execution
in case of certain combinations of settings. When queried about
their capabilities, some of these guys seem to lie.

Renate Schaaf
renates@xmission.com
