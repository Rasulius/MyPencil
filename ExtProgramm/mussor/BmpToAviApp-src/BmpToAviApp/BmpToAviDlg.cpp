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

// BmpToAviDlg.cpp : implementation file
//

#include "stdafx.h"
#include "BmpToAviApp.h"
#include "BmpToAviDlg.h"
#include "AboutDlg.h"
#include "Persist.h"
#include "PathStr.h"
#include "FolderDialog.h"
#include "BmpSeqToAvi.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CBmpToAviDlg dialog

static const LPCTSTR COMPR_STATE_FILE_NAME = _T("ComprState.dat");

#define	REG_SETTINGS	_T("Settings")
#define	RK_SRC_FOLDER	_T("SrcFolder")
#define	RK_FRAME_RATE	_T("FrameRate")

CBmpToAviDlg::CBmpToAviDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CBmpToAviDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CBmpToAviDlg)
	m_FrameRate = 0;
	m_SrcFolder = _T("");
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	m_FrameRate = CPersist::GetFloat(REG_SETTINGS, RK_FRAME_RATE, 30);
	m_SrcFolder = CPersist::GetString(REG_SETTINGS, RK_SRC_FOLDER);
}

CBmpToAviDlg::~CBmpToAviDlg()
{
	CPersist::WriteFloat(REG_SETTINGS, RK_FRAME_RATE, m_FrameRate);
	CPersist::WriteString(REG_SETTINGS, RK_SRC_FOLDER, m_SrcFolder);
}

void CBmpToAviDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CBmpToAviDlg)
	DDX_Text(pDX, IDC_MD_FRAME_RATE, m_FrameRate);
	DDX_Text(pDX, IDC_MD_SRC_FOLDER_EDIT, m_SrcFolder);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CBmpToAviDlg, CDialog)
	//{{AFX_MSG_MAP(CBmpToAviDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_MD_SRC_BROWSE_BTN, OnSrcBrowse)
	ON_WM_DESTROY()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CBmpToAviDlg message handlers

BOOL CBmpToAviDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	CPathStr	path;
	theApp.GetAppDataFolder(path);
	path.Append(theApp.m_pszAppName);
	if (theApp.CreateFolder(path)) {
		path.Append(COMPR_STATE_FILE_NAME);
		if (PathFileExists(path))
			m_ComprState.Read(path);
		m_ComprStatePath = path;
	}
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CBmpToAviDlg::OnDestroy() 
{
	if (!m_ComprStatePath.IsEmpty())
		m_ComprState.Write(m_ComprStatePath);
	CDialog::OnDestroy();
}

void CBmpToAviDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CBmpToAviDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CBmpToAviDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CBmpToAviDlg::OnSrcBrowse() 
{
	if (CFolderDialog::BrowseFolder(NULL, m_SrcFolder, NULL, 0, m_SrcFolder))
		UpdateData(FALSE);
}

void CBmpToAviDlg::OnOK() 
{
	if (!UpdateData())
		return;
	if (m_SrcFolder.IsEmpty()) {
		AfxMessageBox(IDS_MD_NO_SRC_FOLDER);
		return;
	}
	if (!PathFileExists(m_SrcFolder)) {
		AfxMessageBox(IDS_MD_SRC_FOLDER_NOT_FOUND);
		return;
	}
	CString	Filter(LPCTSTR(IDS_AVI_FILTER));
	CFileDialog	fd(FALSE, _T(".avi"), NULL, OFN_OVERWRITEPROMPT, Filter);
	if (fd.DoModal() != IDOK)
		return;
	CWaitCursor	wc;	// sequence check can take a while
	if (CBmpSeqToAvi::MakeAvi(m_SrcFolder, fd.GetPathName(), m_FrameRate, m_ComprState))
		AfxMessageBox(IDS_MD_SUCCESS, MB_ICONINFORMATION);
}
