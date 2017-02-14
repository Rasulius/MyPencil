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

// BmpToAviApp.h : main header file for the BMPTOAVI application
//

#if !defined(AFX_BMPTOAVIAPP_H__0F6429FB_12B2_4B2E_B1A8_EEABC924E1C1__INCLUDED_)
#define AFX_BMPTOAVIAPP_H__0F6429FB_12B2_4B2E_B1A8_EEABC924E1C1__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

// MakeSureDirectoryPathExists doesn't support Unicode; SHCreateDirectoryEx
// is a reasonable substitute, but our version of the SDK doesn't define it
#ifdef	UNICODE
#ifndef	SHCreateDirectoryEx
int WINAPI SHCreateDirectoryExW(HWND hwnd, LPCWSTR pszPath, SECURITY_ATTRIBUTES *psa);
#define SHCreateDirectoryEx SHCreateDirectoryExW
#endif
#else
#include "imagehlp.h"	// for MakeSureDirectoryPathExists
#endif

/////////////////////////////////////////////////////////////////////////////
// CBmpToAviApp:
// See BmpToAviApp.cpp for the implementation of this class
//

class CBmpToAviApp : public CWinApp
{
public:
	CBmpToAviApp();

// Operations
	static	bool	GetAppDataFolder(CString& Folder);
	static	bool	CreateFolder(LPCTSTR Path);

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CBmpToAviApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CBmpToAviApp)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

extern CBmpToAviApp theApp;

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BMPTOAVIAPP_H__0F6429FB_12B2_4B2E_B1A8_EEABC924E1C1__INCLUDED_)
