/*
	TUILib Sample - Tab control with widgets on each page
*/

load "tuilib.ring"

# Global variables
oAppKernel = NULL
oAppEventManager = NULL

oAppKernel = new TUIKernel()
oAppKernel.clear()
oAppKernel.enableMouse()
oAppEventManager = new TUIEventManager(oAppKernel)

runTabsDemo()

oAppKernel.restoreTerminal()

func runTabsDemo
	# Clear screen with black background to remove any artifacts
	oAppKernel.setTermColor(WHITE, BLACK)  # White on black
	oAppKernel.clear()

	# Fill the entire screen with black to ensure no garbage
	cClearLine = copy(" ", 80)
	for nRow = 1 to 25
		oAppKernel.printAt(1, nRow, cClearLine)
	next

	# Create main window
	oWin = new TUIWindow(oAppKernel, 2, 2, 76, 23, "Tab Control Demo - ESC: Exit")
	oWin.draw()

	# Create tab control
	oTabs = new TUITabControl(oAppKernel, 4, 4, 70, 16)

	# === Page 1: General Settings ===
	oPage1 = oTabs.addPage("General")

	oLblGeneral = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblGeneral.nBgColor = BLACK
	oLblGeneral.setText("General Settings")
	oLblGeneral.nFgColor = YELLOW
	oPage1.addChild(oLblGeneral, 1, 0)

	oLblUser = new TUILabel(oAppKernel, 0, 0, 15, 1)
	oLblUser.nBgColor = BLACK
	oLblUser.setText("Username:")
	oLblUser.nFgColor = GREY
	oPage1.addChild(oLblUser, 1, 2)

	oTxtUser = new TUITextBox(oAppKernel, 0, 0, 30, 1)
	oTxtUser.setText("Admin")
	oPage1.addChild(oTxtUser, 15, 2)

	oLblLang = new TUILabel(oAppKernel, 0, 0, 15, 1)
	oLblLang.nBgColor = BLACK
	oLblLang.setText("Language:")
	oLblLang.nFgColor = GREY
	oPage1.addChild(oLblLang, 1, 4)

	oCmbLang = new TUIComboBox(oAppKernel, 0, 0, 30, 1)
	oCmbLang.addItem("English")
	oCmbLang.addItem("Spanish")
	oCmbLang.addItem("French")
	oCmbLang.addItem("German")
	oCmbLang.addItem("Arabic")
	oPage1.addChild(oCmbLang, 15, 4)

	oChkAuto = new TUICheckBox(oAppKernel, 0, 0, 30, 1)
	oChkAuto.cText = "Auto-save enabled"
	oChkAuto.lChecked = true
	oPage1.addChild(oChkAuto, 1, 6)

	oChkNotify = new TUICheckBox(oAppKernel, 0, 0, 30, 1)
	oChkNotify.cText = "Show notifications"
	oChkNotify.lChecked = true
	oPage1.addChild(oChkNotify, 1, 7)

	# === Page 2: Appearance ===
	oPage2 = oTabs.addPage("Appearance")

	oLblAppear = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblAppear.nBgColor = BLACK
	oLblAppear.setText("Appearance Settings")
	oLblAppear.nFgColor = YELLOW
	oPage2.addChild(oLblAppear, 1, 0)

	oLblTheme = new TUILabel(oAppKernel, 0, 0, 15, 1)
	oLblTheme.nBgColor = BLACK
	oLblTheme.setText("Theme:")
	oLblTheme.nFgColor = GREY
	oPage2.addChild(oLblTheme, 1, 2)

	oLstTheme = new TUIListBox(oAppKernel, 0, 0, 25, 6)
	oLstTheme.addItem("Classic Blue")
	oLstTheme.addItem("Dark Mode")
	oLstTheme.addItem("Light Mode")
	oLstTheme.addItem("High Contrast")
	oLstTheme.addItem("Custom")
	oLstTheme.nSelectedIndex = 1
	oPage2.addChild(oLstTheme, 15, 2)

	oChkBold = new TUICheckBox(oAppKernel, 0, 0, 25, 1)
	oChkBold.cText = "Bold text"
	oPage2.addChild(oChkBold, 1, 9)

	oChkLarge = new TUICheckBox(oAppKernel, 0, 0, 25, 1)
	oChkLarge.cText = "Large fonts"
	oPage2.addChild(oChkLarge, 1, 10)

	# === Page 3: Network ===
	oPage3 = oTabs.addPage("Network")

	oLblNetwork = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblNetwork.nBgColor = BLACK
	oLblNetwork.setText("Network Configuration")
	oLblNetwork.nFgColor = YELLOW
	oPage3.addChild(oLblNetwork, 1, 0)

	oLblHost = new TUILabel(oAppKernel, 0, 0, 15, 1)
	oLblHost.nBgColor = BLACK
	oLblHost.setText("Host:")
	oLblHost.nFgColor = GREY
	oPage3.addChild(oLblHost, 1, 2)

	oTxtHost = new TUITextBox(oAppKernel, 0, 0, 35, 1)
	oTxtHost.setText("localhost")
	oPage3.addChild(oTxtHost, 15, 2)

	oLblPort = new TUILabel(oAppKernel, 0, 0, 15, 1)
	oLblPort.nBgColor = BLACK
	oLblPort.setText("Port:")
	oLblPort.nFgColor = GREY
	oPage3.addChild(oLblPort, 1, 4)

	oTxtPort = new TUITextBox(oAppKernel, 0, 0, 10, 1)
	oTxtPort.setText("8080")
	oPage3.addChild(oTxtPort, 15, 4)

	oChkSSL = new TUICheckBox(oAppKernel, 0, 0, 25, 1)
	oChkSSL.cText = "Use SSL/TLS"
	oChkSSL.lChecked = true
	oPage3.addChild(oChkSSL, 1, 6)

	oChkProxy = new TUICheckBox(oAppKernel, 0, 0, 25, 1)
	oChkProxy.cText = "Use proxy server"
	oPage3.addChild(oChkProxy, 1, 7)

	oBtnTest = new TUIButton(oAppKernel, 0, 0, 18, 1)
	oBtnTest.cText = "Test Connection"
	oPage3.addChild(oBtnTest, 1, 10)

	# === Page 4: About ===
	oPage4 = oTabs.addPage("About")

	oLblAbout = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblAbout.nBgColor = BLACK
	oLblAbout.setText("About This Application")
	oLblAbout.nFgColor = YELLOW
	oPage4.addChild(oLblAbout, 1, 0)

	oLblAppName = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblAppName.nBgColor = BLACK
	oLblAppName.setText("TUILib Demo")
	oLblAppName.nFgColor = LIGHTCYAN
	oPage4.addChild(oLblAppName, 1, 2)

	oLblVersion = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblVersion.nBgColor = BLACK
	oLblVersion.setText("Version: 1.0.0")
	oLblVersion.nFgColor = GREY
	oPage4.addChild(oLblVersion, 1, 4)

	oLblAuthor = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblAuthor.nBgColor = BLACK
	oLblAuthor.setText("A comprehensive TUI framework for Ring")
	oLblAuthor.nFgColor = GREY
	oPage4.addChild(oLblAuthor, 1, 6)

	oLblFeatures = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblFeatures.nBgColor = BLACK
	oLblFeatures.setText("Features:")
	oLblFeatures.nFgColor = LIGHTGREEN
	oPage4.addChild(oLblFeatures, 1, 8)

	oLblF1 = new TUILabel(oAppKernel, 0, 0, 55, 1)
	oLblF1.nBgColor = BLACK
	oLblF1.setText("- Windows, Buttons, TextBoxes, CheckBoxes")
	oLblF1.nFgColor = WHITE
	oPage4.addChild(oLblF1, 3, 9)

	oLblF2 = new TUILabel(oAppKernel, 0, 0, 55, 1)
	oLblF2.nBgColor = BLACK
	oLblF2.setText("- ListBox, ComboBox, Grid, Menu")
	oLblF2.nFgColor = WHITE
	oPage4.addChild(oLblF2, 3, 10)

	oLblF3 = new TUILabel(oAppKernel, 0, 0, 55, 1)
	oLblF3.nBgColor = BLACK
	oLblF3.setText("- TreeView, TabControl, and more!")
	oLblF3.nFgColor = WHITE
	oPage4.addChild(oLblF3, 3, 11)

	# Draw the tab control (this will draw only active page children)
	oTabs.draw()

	# Create info label (draw after tabs)
	oLblHelp = new TUILabel(oAppKernel, 4, 21, 70, 1)
	oLblHelp.nBgColor = BLACK
	oLblHelp.setText("F3: Switch tabs | TAB: Navigate controls | Click to focus | ESC: Exit")
	oLblHelp.nFgColor = LIGHTGREEN
	oLblHelp.draw()

	# Status bar
	oStatusBar = new TUILabel(oAppKernel, 2, 25, 76, 1)
	oStatusBar.setText(oAppKernel.fixedWidth("Tab Control Demo - Active Tab: General", 76))
	oStatusBar.nFgColor = BLACK
	oStatusBar.nBgColor = GREY
	oStatusBar.draw()

	# Configure EventManager for tab-based UI
	oAppEventManager.clearWidgets()
	oAppEventManager.setTabControl(oTabs)
	oAppEventManager.setStatusBar(oStatusBar)

	# Run event loop - EventManager handles everything!
	oAppEventManager.run()
