// DemoPrjDlg.h : header file
//

#if !defined(AFX_DEMOPRJDLG_H__8C2DF2E7_FE4F_489A_8974_CFB8FCA970DD__INCLUDED_)
#define AFX_DEMOPRJDLG_H__8C2DF2E7_FE4F_489A_8974_CFB8FCA970DD__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CDemoPrjDlg dialog

class CDemoPrjDlg : public CDialog
{
// Construction
public:
	CDemoPrjDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CDemoPrjDlg)
	enum { IDD = IDD_DEMOPRJ_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDemoPrjDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CDemoPrjDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnClose();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DEMOPRJDLG_H__8C2DF2E7_FE4F_489A_8974_CFB8FCA970DD__INCLUDED_)
