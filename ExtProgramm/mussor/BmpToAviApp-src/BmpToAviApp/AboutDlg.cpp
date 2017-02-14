// Copyleft 2008 Chris Korda
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or any later version.
/*
        chris korda
 
		revision history:
		rev		date	comments
        00      07jan09	initial version

        about dialog
 
*/

#include "stdafx.h"
#include "Resource.h"
#include "AboutDlg.h"

const LPCTSTR CAboutDlg::HOME_PAGE_URL = _T("http://fractice.sourceforge.net");

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	DDX_Control(pDX, IDC_ABOUT_LICENSE, m_License);
	DDX_Control(pDX, IDC_ABOUT_URL, m_AboutUrl);
	DDX_Control(pDX, IDC_ABOUT_TEXT, m_AboutText);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg message handlers

BOOL CAboutDlg::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	m_AboutUrl.SetUrl(HOME_PAGE_URL);
	m_License.SetWindowText(LDS(IDS_APP_LICENSE));
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}
