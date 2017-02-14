; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CAboutDlg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "bmptoavi.h"
LastPage=0

ClassCount=5
Class1=CAboutDlg
Class2=CBmpToAviApp
Class3=CBmpToAviDlg
Class4=CHyperlink
Class5=CProgressDlg

ResourceCount=3
Resource1=IDD_BMPTOAVI_DIALOG
Resource2=IDD_ABOUTBOX
Resource3=IDD_PROGRESS

[CLS:CAboutDlg]
Type=0
BaseClass=CDialog
HeaderFile=AboutDlg.h
ImplementationFile=AboutDlg.cpp
LastObject=CAboutDlg

[CLS:CBmpToAviApp]
Type=0
BaseClass=CWinApp
HeaderFile=BmpToAviApp.h
ImplementationFile=BmpToAvi.cpp

[CLS:CBmpToAviDlg]
Type=0
BaseClass=CDialog
HeaderFile=BmpToAviDlg.h
ImplementationFile=BmpToAviDlg.cpp

[CLS:CHyperlink]
Type=0
BaseClass=CStatic
HeaderFile=Hyperlink.h
ImplementationFile=Hyperlink.cpp

[CLS:CProgressDlg]
Type=0
BaseClass=CDialog
HeaderFile=ProgressDlg.h
ImplementationFile=ProgressDlg.cpp

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAboutDlg
ControlCount=5
Control1=IDC_STATIC,static,1342177283
Control2=IDC_ABOUT_TEXT,static,1342308480
Control3=IDOK,button,1342373889
Control4=IDC_ABOUT_URL,static,1342308608
Control5=IDC_ABOUT_LICENSE,edit,1352730628

[DLG:IDD_BMPTOAVI_DIALOG]
Type=1
Class=CBmpToAviDlg
ControlCount=8
Control1=IDC_STATIC,static,1342308352
Control2=IDC_MD_SRC_FOLDER_EDIT,edit,1350631552
Control3=IDC_MD_SRC_BROWSE_BTN,button,1342242816
Control4=IDC_STATIC,static,1342308352
Control5=IDC_MD_FRAME_RATE,edit,1350631552
Control6=IDOK,button,1342242817
Control7=IDCANCEL,button,1342242816
Control8=IDC_STATIC,static,1342308864

[DLG:IDD_PROGRESS]
Type=1
Class=CProgressDlg
ControlCount=2
Control1=IDC_PROGRESS,msctls_progress32,1350565889
Control2=IDCANCEL,button,1342242816

