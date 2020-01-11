// DemoPrjDlg.cpp : implementation file
//

#include "stdafx.h"
#include "DemoPrj.h"
#include "DemoPrjDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

typedef int (__stdcall * _OCRINIT)();
typedef char* (__stdcall * _OCR_C)(char* ocr_type,char* file_name);
typedef void (__stdcall * _OCRDONE)();

HINSTANCE hLibrary;
int init_ret;
_OCRINIT ocrinit;
_OCRDONE ocrdone;
_OCR_C ocr_c;


/////////////////////////////////////////////////////////////////////////////
// CDemoPrjDlg dialog

CDemoPrjDlg::CDemoPrjDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CDemoPrjDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CDemoPrjDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDemoPrjDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDemoPrjDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CDemoPrjDlg, CDialog)
	//{{AFX_MSG_MAP(CDemoPrjDlg)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_CLOSE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDemoPrjDlg message handlers

BOOL CDemoPrjDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	hLibrary=LoadLibrary("AdvOCR.dll");
	if (hLibrary)
	{
      ocrinit=(_OCRINIT)GetProcAddress(hLibrary,"OcrInit");
	  ocrdone=(_OCRDONE)GetProcAddress(hLibrary,"OcrDone");
	  ocr_c=(_OCR_C)GetProcAddress(hLibrary,"OCR_C");
      init_ret=(*ocrinit)();
	  if (!init_ret) MessageBox("识别引擎初始化失败!");
	}

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CDemoPrjDlg::OnPaint() 
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

HCURSOR CDemoPrjDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CDemoPrjDlg::OnOK() 
{
	// TODO: Add extra validation here
	if (init_ret)
	{
	   CFileDialog l_Dlg(TRUE,NULL,NULL,OFN_OVERWRITEPROMPT,"All Files(*.*)|*.*||");
       int iRet = l_Dlg.DoModal();
       CString l_strFileName;
       l_strFileName = l_Dlg.GetPathName();
       if(iRet == IDOK) 
	   SetDlgItemText(IDC_EDIT1,(*ocr_c)("alibaba",l_strFileName.GetBuffer(0)));
	}
	//CDialog::OnOK();
}

void CDemoPrjDlg::OnClose()
{
    (*ocrdone)();
    FreeLibrary(hLibrary);
	CDialog::OnClose();
}
