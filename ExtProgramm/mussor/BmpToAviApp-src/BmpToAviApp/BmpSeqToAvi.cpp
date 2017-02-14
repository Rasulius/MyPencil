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

#include "stdafx.h"
#include "Resource.h"
#include "BmpSeqToAvi.h"
#include "BmpToAvi.h"
#include "Dib.h"
#include "PathStr.h"
#include "ProgressDlg.h"
#include "SortArray.h"

bool CBmpSeqToAvi::CheckSeq(LPCTSTR SrcFolder, CString& NameFormat,
								 CString& NamePrefix, int& StartFrame, int& EndFrame)
{
	CPathStr	path(SrcFolder);
	path.Append(_T("*.bmp"));
	CFileFind	ff;
	BOOL	bWorking = ff.FindFile(path);
	int		FrameNumPos = 0;
	int		FrameNumLen = 0;
	CSortArray<int, int>	FrameSeq;
	CString	FirstName;
	while (bWorking) {
		bWorking = ff.FindNextFile();
		CString	name = ff.GetFileName();
		if (ff.IsDirectory())
			continue;
		static const LPCTSTR	digits = _T("0123456789");
		int	numpos = name.FindOneOf(digits);
		if (numpos >= 0) {
			int	numlen = _tcsspn(name.Mid(numpos), digits);
			if (numlen) {
				if (!FrameNumLen) {
					FrameNumPos = numpos;
					FrameNumLen = numlen;
					NamePrefix = name.Left(numpos);
					NameFormat.Format(_T("%%s%%0%dd.bmp"), numlen);
					FirstName = name;
				} else {
					if (numpos != FrameNumPos || numlen != FrameNumLen) {
						CString	msg;
						AfxFormatString2(msg, IDS_MD_BAD_FILENAME_FORMAT, 
							name, FirstName);
						AfxMessageBox(msg);
						return(FALSE);	// inconsistent file name format
					}
				}
				int	FrameNum = atoi(name.Mid(numpos));
				FrameSeq.SortedInsert(FrameNum);
			}
		}
	}
	int	frames = FrameSeq.GetSize();
	if (!frames) {
		AfxMessageBox(IDS_MD_BITMAP_SEQ_NOT_FOUND);
		return(FALSE);	// bitmap sequence not found
	}
	int	FrameNum = FrameSeq[0];
	for (int i = 1; i < frames; i++) {
		FrameNum++;
		if (FrameSeq[i] != FrameNum) {
			CString	msg;
			msg.Format(IDS_MD_MISSING_FRAME, FrameNum);
			AfxMessageBox(msg);	// missing frame number
			return(FALSE);
		}
	}
	StartFrame = FrameSeq[0];
	EndFrame = FrameSeq[frames - 1];
	return(TRUE);
}

class CMyProgressDlg : public CProgressDlg {
public:
	void	OnCancel();
};

void CMyProgressDlg::OnCancel()
{
	if (AfxMessageBox(IDS_MD_CANCEL_CHECK, MB_YESNO | MB_DEFBUTTON2) == IDYES)
		m_Canceled = TRUE;
}

void CBmpSeqToAvi::ShowCvtError(CBmpToAvi& bta)
{
	CString	s, t;
	bta.GetLastErrorString(s, t);
	AfxMessageBox(s + _T("\n") + t);
}

bool CBmpSeqToAvi::MakeAvi(LPCTSTR SrcFolder, LPCTSTR AviPath, 
						   float FrameRate, CVideoComprState& ComprState)
{
	int	StartFrame, EndFrame;
	CString	NameFormat, NamePrefix;
	if (!CheckSeq(SrcFolder, NameFormat, NamePrefix, StartFrame, EndFrame))
		return(FALSE);
	CBmpToAvi	RecAvi;
	CMyProgressDlg	ProgDlg;
	BMPTOAVI_PARMS	JobParms;
	ZeroMemory(&JobParms, sizeof(BMPTOAVI_PARMS));
	bool	First = TRUE;
	for (int i = StartFrame; i <= EndFrame; i++) {
		CPathStr	path(SrcFolder);
		CString	FileName;
		FileName.Format(NameFormat, NamePrefix, i);
		path.Append(FileName);
		CDib	dib;
		if (!dib.Read(path)) {
			CString	msg;
			AfxFormatString1(msg, IDS_MD_BITMAP_READ_ERROR, path);
			AfxMessageBox(msg);
			return(FALSE);	// bitmap read error
		}
		BITMAP	bmp;
		dib.GetBitmap(&bmp);
		BMPTOAVI_PARMS	BmpParms = {
			bmp.bmWidth,		// Width
			bmp.bmHeight,		// Height
			bmp.bmBitsPixel,	// BitCount
			FrameRate			// FrameRate
		};
		if (First) {
			First = FALSE;
			JobParms = BmpParms;
			if (!ComprState.m_Name.IsEmpty())
				RecAvi.SetComprState(ComprState);
			if (!RecAvi.Open(JobParms, AviPath, TRUE)) {
				if (RecAvi.GetLastError())	// if user didn't cancel
					ShowCvtError(RecAvi);
				return(FALSE);	// filter error
			}
			RecAvi.GetComprState(ComprState);
			ProgDlg.Create();
			ProgDlg.SetRange(StartFrame, EndFrame);
		} else {
			if (memcmp(&BmpParms, &JobParms, sizeof(BMPTOAVI_PARMS))) {
				CString	msg;
				AfxFormatString1(msg, IDS_MD_BAD_BITMAP_PROPS, FileName);
				AfxMessageBox(msg);
				return(FALSE);	// inconsistent bitmap properties
			}
		}
		if (!RecAvi.AddFrame(dib)) {
			ShowCvtError(RecAvi);
			return(FALSE);	// add frame error
		}
		if (ProgDlg.Canceled())
			return(FALSE);
		ProgDlg.SetPos(i);
	}
	return(TRUE);
}

