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

// BmpToAvi.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "BmpToAviApp.h"
#include "BmpToAviDlg.h"
#include "shlwapi.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CBmpToAviApp

BEGIN_MESSAGE_MAP(CBmpToAviApp, CWinApp)
	//{{AFX_MSG_MAP(CBmpToAviApp)
	//}}AFX_MSG
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CBmpToAviApp construction

CBmpToAviApp::CBmpToAviApp()
{
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CBmpToAviApp object

CBmpToAviApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CBmpToAviApp initialization

BOOL CBmpToAviApp::InitInstance()
{
	AfxEnableControlContainer();

	// Standard initialization
	// If you are not using these features and wish to reduce the size
	//  of your final executable, you should remove from the following
	//  the specific initialization routines you do not need.

#ifdef _AFXDLL
	Enable3dControls();			// Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();	// Call this when linking to MFC statically
#endif

	// Change the registry key under which our settings are stored.
	SetRegistryKey(_T("Anal Software"));

	CBmpToAviDlg dlg;
	m_pMainWnd = &dlg;
	int nResponse = dlg.DoModal();
	if (nResponse == IDOK)
	{
	}
	else if (nResponse == IDCANCEL)
	{
	}

	// Since the dialog has been closed, return FALSE so that we exit the
	//  application, rather than start the application's message pump.
	return FALSE;
}

bool CBmpToAviApp::GetAppDataFolder(CString& Folder)
{
	LPTSTR	p = Folder.GetBuffer(MAX_PATH);
	bool	retc = SUCCEEDED(SHGetSpecialFolderPath(NULL, p, CSIDL_APPDATA, 0));
	Folder.ReleaseBuffer();
	return(retc);
}

// MakeSureDirectoryPathExists doesn't support Unicode; SHCreateDirectoryEx
// is a reasonable substitute, but our version of the SDK doesn't define it
#if defined(UNICODE) && !defined(SHCreateDirectoryEx)
int WINAPI SHCreateDirectoryExW(HWND hwnd, LPCWSTR pszPath, SECURITY_ATTRIBUTES *psa)
{
	int	retc = ERROR_INVALID_FUNCTION;
	typedef int (WINAPI* lpfnSHCreateDirectoryExW)(HWND hwnd, LPCWSTR pszPath, SECURITY_ATTRIBUTES *psa);
	HMODULE hShell = LoadLibrary(_T("shell32.dll"));
	lpfnSHCreateDirectoryExW lpfn = NULL;
	if (hShell) {
		lpfn = (lpfnSHCreateDirectoryExW)GetProcAddress(hShell, "SHCreateDirectoryExW");
		if (lpfn)
			retc = lpfn(hwnd, pszPath, psa);
		FreeLibrary(hShell);
	}
	return(retc);
}
#define SHCreateDirectoryEx SHCreateDirectoryExW
#endif

bool CBmpToAviApp::CreateFolder(LPCTSTR Path)
{
#ifdef UNICODE
	return(SHCreateDirectoryEx(NULL, Path, NULL) == ERROR_SUCCESS);
#else
	CString	s(Path);
	LPTSTR	p = s.GetBuffer(MAX_PATH);
	PathAddBackslash(p);	// trailing backslash is required
	s.ReleaseBuffer();
	return(MakeSureDirectoryPathExists(s) != 0);	// very slow
#endif
}
