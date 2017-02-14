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

// stdafx.h : include file for standard system include files,
//  or project specific include files that are used frequently, but
//      are changed infrequently
//

#if !defined(AFX_STDAFX_H__87ABD419_9513_44A2_B64B_295A81D9C78B__INCLUDED_)
#define AFX_STDAFX_H__87ABD419_9513_44A2_B64B_295A81D9C78B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define VC_EXTRALEAN		// Exclude rarely-used stuff from Windows headers

#define WINVER	0x0500		// for IDC_HAND

#include <afxwin.h>         // MFC core and standard components
#include <afxext.h>         // MFC extensions
#include <afxdisp.h>        // MFC Automation classes
#include <afxdtctl.h>		// MFC support for Internet Explorer 4 Common Controls
#ifndef _AFX_NO_AFXCMN_SUPPORT
#include <afxcmn.h>			// MFC support for Windows Common Controls
#endif // _AFX_NO_AFXCMN_SUPPORT

#pragma warning(disable : 4100)	// unreferenced formal parameter

// minimal base for non-CObject classes
#include "WObject.h"

// load string from resource via temporary object
#define LDS(x) CString((LPCTSTR)x)

// optimized FPU rounding
inline int round(double x)
{
	int		temp;
	__asm	fld		x		// load real
	__asm	fistp	temp	// store integer and pop stack
	return(temp);
}

#if _MFC_VER < 0x0800
#define genericException generic	// generic was deprecated in .NET 2005
#endif

#define IDM_ABOUTBOX	0x0010		// system menu about command

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__87ABD419_9513_44A2_B64B_295A81D9C78B__INCLUDED_)
