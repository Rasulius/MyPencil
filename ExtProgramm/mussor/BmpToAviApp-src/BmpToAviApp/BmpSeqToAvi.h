// Copyleft 2008 Chris Korda
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or any later version.
/*
        chris korda

		revision history:
		rev		date	comments
        00      07jan09	initial version

        convert bitmap sequence to AVI file

*/

#ifndef BMPSEQTOAVI_INCLUDED
#define	BMPSEQTOAVI_INCLUDED

class CVideoComprState;
class CBmpToAvi;

class CBmpSeqToAvi {
public:
	static	bool	MakeAvi(LPCTSTR SrcFolder, LPCTSTR AviPath, float FrameRate, CVideoComprState& ComprState);

private:
	static	bool	CheckSeq(LPCTSTR SrcFolder, CString& NameFormat, CString& NamePrefix, int& StartFrame, int& EndFrame);
	static	void	ShowCvtError(CBmpToAvi& bta);
};

#endif
