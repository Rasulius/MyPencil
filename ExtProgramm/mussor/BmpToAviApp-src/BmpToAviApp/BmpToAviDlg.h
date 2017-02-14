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

// BmpToAviDlg.h : header file
//

#if !defined(AFX_BMPTOAVIDLG_H__FD89746C_3295_4B02_BE4F_FE90D73D9955__INCLUDED_)
#define AFX_BMPTOAVIDLG_H__FD89746C_3295_4B02_BE4F_FE90D73D9955__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CBmpToAviDlg dialog

#include "VideoComprState.h"

class CBmpToAvi;

class CBmpToAviDlg : public CDialog
{
// Construction
public:
	CBmpToAviDlg(CWnd* pParent = NULL);	// standard constructor
	~CBmpToAviDlg();

// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CBmpToAviDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
// Dialog Data
	//{{AFX_DATA(CBmpToAviDlg)
	enum { IDD = IDD_BMPTOAVI_DIALOG };
	float	m_FrameRate;
	CString	m_SrcFolder;
	//}}AFX_DATA

// Generated message map functions
	//{{AFX_MSG(CBmpToAviDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	virtual void OnOK();
	afx_msg void OnSrcBrowse();
	afx_msg void OnDestroy();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

// Member data
	HICON m_hIcon;
	CVideoComprState	m_ComprState;
	CString	m_ComprStatePath;

// Helpers
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BMPTOAVIDLG_H__FD89746C_3295_4B02_BE4F_FE90D73D9955__INCLUDED_)
