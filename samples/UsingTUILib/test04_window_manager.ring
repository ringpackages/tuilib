/*
	TUILib Sample - Window manager: movable, resizable windows on a desktop
*/

load "tuilib.ring"

# Global variables
oAppKernel = NULL
oAppEventManager = NULL

oAppKernel = new TUIKernel()
oAppKernel.clear()
oAppKernel.enableMouse()
oAppEventManager = new TUIEventManager(oAppKernel)

runWindowDemo()

oAppKernel.restoreTerminal()

func runWindowDemo
	# Create window manager
	oWm = new TUIWindowManager(oAppKernel)

	# Set desktop colors and pattern
	oWm.setDesktopColors(8, 1)  # Gray on blue
	oWm.setDesktopPattern(" ")  # Light shade pattern

	# Add a desktop widget (title bar at top)
	oDesktopTitle = new TUILabel(oAppKernel, 1, 1, 80, 1)
	oDesktopTitle.setText(oAppKernel.fixedWidth("  TUI Desktop - Press ESC to exit | F12 to cycle windows", 80))
	oDesktopTitle.nFgColor = WHITE
	oDesktopTitle.nBgColor = BLACK
	oWm.addDesktopWidget(oDesktopTitle)

	# Add a taskbar at bottom
	oTaskbar = new TUILabel(oAppKernel, 1, 25, 80, 1)
	oTaskbar.setText(oAppKernel.fixedWidth("  [Start]  Information | User Form | Select Country | Status", 80))
	oTaskbar.nFgColor = BLACK
	oTaskbar.nBgColor = GREY
	oWm.addDesktopWidget(oTaskbar)

	# ===== Window 1: Information Window =====
	oWin1 = new TUIManagedWindow(oAppKernel, 3, 3, 38, 14, "Information")
	oWin1.nContentBgColor = BLACK

	oLbl1 = new TUILabel(oAppKernel, 0, 0, 34, 1)
	oLbl1.nBgColor = BLACK
	oLbl1.setText("Window Manager Demo")
	oLbl1.nFgColor = YELLOW
	oWin1.addChild(oLbl1, 1, 0)

	oLbl2 = new TUILabel(oAppKernel, 0, 0, 34, 1)
	oLbl2.nBgColor = BLACK
	oLbl2.setText("Features:")
	oLbl2.nFgColor = LIGHTCYAN
	oWin1.addChild(oLbl2, 1, 2)

	oLbl3 = new TUILabel(oAppKernel, 0, 0, 34, 1)
	oLbl3.nBgColor = BLACK
	oLbl3.setText("- Drag title bar to move")
	oLbl3.nFgColor = WHITE
	oWin1.addChild(oLbl3, 1, 3)

	oLbl4 = new TUILabel(oAppKernel, 0, 0, 34, 1)
	oLbl4.nBgColor = BLACK
	oLbl4.setText("- Drag =# corner to resize")
	oLbl4.nFgColor = WHITE
	oWin1.addChild(oLbl4, 1, 4)

	oLbl5 = new TUILabel(oAppKernel, 0, 0, 34, 1)
	oLbl5.nBgColor = BLACK
	oLbl5.setText("- Click [_] to minimize")
	oLbl5.nFgColor = WHITE
	oWin1.addChild(oLbl5, 1, 5)

	oLbl6 = new TUILabel(oAppKernel, 0, 0, 34, 1)
	oLbl6.nBgColor = BLACK
	oLbl6.setText("- Click [O] to maximize")
	oLbl6.nFgColor = WHITE
	oWin1.addChild(oLbl6, 1, 6)

	oLbl7 = new TUILabel(oAppKernel, 0, 0, 34, 1)
	oLbl7.nBgColor = BLACK
	oLbl7.setText("- Click [X] to close")
	oLbl7.nFgColor = WHITE
	oWin1.addChild(oLbl7, 1, 7)

	oLbl8 = new TUILabel(oAppKernel, 0, 0, 34, 1)
	oLbl8.nBgColor = BLACK
	oLbl8.setText("- Press F12 to cycle windows")
	oLbl8.nFgColor = LIGHTGREEN
	oWin1.addChild(oLbl8, 1, 9)

	# ===== Window 2: Form Window with Controls =====
	oWin2 = new TUIManagedWindow(oAppKernel, 20, 7, 42, 15, "User Form")
	oWin2.nContentBgColor = BLACK
	oWin2.nActiveTitleBgColor = GREEN  # Green title bar

	# Name field
	oLblName = new TUILabel(oAppKernel, 0, 0, 10, 1)
	oLblName.nBgColor = BLACK
	oLblName.setText("Name:")
	oLblName.nFgColor = GREY
	oWin2.addChild(oLblName, 1, 0)

	oTxtName = new TUITextBox(oAppKernel, 0, 0, 28, 1)
	oTxtName.setText("Sample User")
	oWin2.addChild(oTxtName, 10, 0)

	# Email field
	oLblEmail = new TUILabel(oAppKernel, 0, 0, 10, 1)
	oLblEmail.nBgColor = BLACK
	oLblEmail.setText("Email:")
	oLblEmail.nFgColor = GREY
	oWin2.addChild(oLblEmail, 1, 2)

	oTxtEmail = new TUITextBox(oAppKernel, 0, 0, 28, 1)
	oTxtEmail.setText("user@example.com")
	oWin2.addChild(oTxtEmail, 10, 2)

	# Checkboxes
	oChk1 = new TUICheckBox(oAppKernel, 0, 0, 25, 1)
	oChk1.cText = "Subscribe to news"
	oChk1.lChecked = true
	oWin2.addChild(oChk1, 1, 4)

	oChk2 = new TUICheckBox(oAppKernel, 0, 0, 20, 1)
	oChk2.cText = "Remember me"
	oWin2.addChild(oChk2, 1, 5)

	# Buttons
	oBtnOK = new TUIButton(oAppKernel, 0, 0, 12, 3)
	oBtnOK.cText = "[ OK ]"
	oBtnOK.nFgColor = WHITE
	oBtnOK.nBgColor = GREEN
	oWin2.addChild(oBtnOK, 5, 8)

	oBtnCancel = new TUIButton(oAppKernel, 0, 0, 12, 3)
	oBtnCancel.cText = "[Cancel]"
	oBtnCancel.nFgColor = WHITE
	oBtnCancel.nBgColor = RED
	oWin2.addChild(oBtnCancel, 20, 8)

	# ===== Window 3: List Window =====
	oWin3 = new TUIManagedWindow(oAppKernel, 45, 4, 32, 14, "Select Country")
	oWin3.nContentBgColor = BLACK
	oWin3.nActiveTitleBgColor = MAGENTA  # Purple title bar

	oLblSelect = new TUILabel(oAppKernel, 0, 0, 28, 1)
	oLblSelect.nBgColor = BLACK
	oLblSelect.setText("Choose your country:")
	oLblSelect.nFgColor = LIGHTCYAN
	oWin3.addChild(oLblSelect, 1, 0)

	oLstCountry = new TUIListBox(oAppKernel, 0, 0, 28, 8)
	oLstCountry.addItem("Country A")
	oLstCountry.addItem("Country B")
	oLstCountry.addItem("Country C")
	oLstCountry.addItem("Country D")
	oLstCountry.addItem("Country E")
	oLstCountry.addItem("Country F")
	oLstCountry.addItem("Country G")
	oLstCountry.addItem("Country H")
	oLstCountry.addItem("Country I")
	oLstCountry.addItem("Country J")
	oWin3.addChild(oLstCountry, 1, 2)

	# ===== Window 4: Progress/Info Window =====
	oWin4 = new TUIManagedWindow(oAppKernel, 8, 13, 40, 9, "Status")
	oWin4.nContentBgColor = BLACK
	oWin4.nActiveTitleBgColor = CYAN  # Cyan title bar

	oLblStatus = new TUILabel(oAppKernel, 0, 0, 36, 1)
	oLblStatus.nBgColor = BLACK
	oLblStatus.setText("System Status:")
	oLblStatus.nFgColor = YELLOW
	oWin4.addChild(oLblStatus, 1, 0)

	oLblCPU = new TUILabel(oAppKernel, 0, 0, 36, 1)
	oLblCPU.nBgColor = BLACK
	oLblCPU.setText("CPU: 45%")
	oLblCPU.nFgColor = LIGHTGREEN
	oWin4.addChild(oLblCPU, 1, 2)

	oLblMem = new TUILabel(oAppKernel, 0, 0, 36, 1)
	oLblMem.nBgColor = BLACK
	oLblMem.setText("Memory: 2.4 GB / 8 GB")
	oLblMem.nFgColor = LIGHTGREEN
	oWin4.addChild(oLblMem, 1, 3)

	oLblDisk = new TUILabel(oAppKernel, 0, 0, 36, 1)
	oLblDisk.nBgColor = BLACK
	oLblDisk.setText("Disk: 120 GB / 500 GB")
	oLblDisk.nFgColor = LIGHTGREEN
	oWin4.addChild(oLblDisk, 1, 4)

	oLblNet = new TUILabel(oAppKernel, 0, 0, 36, 1)
	oLblNet.nBgColor = BLACK
	oLblNet.setText("Network: Connected")
	oLblNet.nFgColor = LIGHTCYAN
	oWin4.addChild(oLblNet, 1, 5)

	# Add windows to manager
	oWm.addWindow(oWin1)
	oWm.addWindow(oWin2)
	oWm.addWindow(oWin3)
	oWm.addWindow(oWin4)

	# Run the window manager
	oWm.run()
