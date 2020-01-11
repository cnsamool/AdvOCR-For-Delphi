// DemoPrj.h : main header file for the DEMOPRJ application
//

#if !defined(AFX_DEMOPRJ_H__A0BDFE72_A5C0_4ED9_98FC_C6B3ACB90F68__INCLUDED_)
#define AFX_DEMOPRJ_H__A0BDFE72_A5C0_4ED9_98FC_C6B3ACB90F68__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CDemoPrjApp:
// See DemoPrj.cpp for the implementation of this class
//

class CDemoPrjApp : public CWinApp
{
public:
	CDemoPrjApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDemoPrjApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CDemoPrjApp)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DEMOPRJ_H__A0BDFE72_A5C0_4ED9_98FC_C6B3ACB90F68__INCLUDED_)
