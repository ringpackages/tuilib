/*
	TUILib Sample - Menu bar and tab control together
*/

load "tuilib.ring"

# Global variables (used by the event handlers)
oAppKernel = NULL
oAppEventManager = NULL
oAppStatusBar = NULL

oAppKernel = new TUIKernel()
oAppKernel.clear()
oAppKernel.enableMouse()
oAppEventManager = new TUIEventManager(oAppKernel)

runMenuTabsDemo()

oAppKernel.restoreTerminal()

func runMenuTabsDemo
	# Clear screen
	oAppKernel.setTermColor(WHITE, BLACK)
	oAppKernel.clear()

	cClearLine = copy(" ", 80)
	for nRow = 1 to 25
		oAppKernel.printAt(1, nRow, cClearLine)
	next

	# Set the default background color for this demo (black)
	oAppKernel.setDefaultColors(WHITE, BLACK)

	# Clear any previously registered screen widgets
	oAppKernel.clearScreenWidgets()

	# ========================================
	# Create Menu Bar at the top
	# ========================================
	oMenuBar = new TUIMenuBar(oAppKernel, 1, 1, 80)

	# ===== FILE MENU =====
	oFileMenu = oMenuBar.createMenu("File")

	oFileMenu.addNormalItem("New", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Creating new document...", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+N")

	oFileMenu.addNormalItem("Open", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Opening file...", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+O")

	oFileMenu.addNormalItem("Save", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Saving file...", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+S")

	oFileMenu.addSeparator()

	oFileMenu.addNormalItem("Exit", func oItem {
		oAppEventManager.stop()
	})

	# ===== EDIT MENU =====
	oEditMenu = oMenuBar.createMenu("Edit")

	oEditMenu.addNormalItem("Undo", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Undo last action", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+Z")

	oEditMenu.addNormalItem("Redo", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Redo action", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+Y")

	oEditMenu.addSeparator()

	oEditMenu.addNormalItem("Cut", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Cut to clipboard", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+X")

	oEditMenu.addNormalItem("Copy", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Copy to clipboard", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+C")

	oEditMenu.addNormalItem("Paste", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Paste from clipboard", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+V")

	# ===== VIEW MENU =====
	oViewMenu = oMenuBar.createMenu("View")

	oViewMenu.addCheckboxItem("Toolbar", true, func oItem {
		if oItem.lChecked
			oAppStatusBar.setText(oAppKernel.fixedWidth("Toolbar shown", 78))
		else
			oAppStatusBar.setText(oAppKernel.fixedWidth("Toolbar hidden", 78))
		ok
		oAppStatusBar.draw()
	})

	oViewMenu.addCheckboxItem("Status Bar", true, func oItem {
		if oItem.lChecked
			oAppStatusBar.setText(oAppKernel.fixedWidth("Status bar shown", 78))
		else
			oAppStatusBar.setText(oAppKernel.fixedWidth("Status bar hidden", 78))
		ok
		oAppStatusBar.draw()
	})

	oViewMenu.addSeparator()

	# Zoom submenu
	oZoomMenu = new TUIMenu(oAppKernel)
	oZoomMenu.addNormalItem("Zoom In", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Zooming in...", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl++")
	oZoomMenu.addNormalItem("Zoom Out", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Zooming out...", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+-")
	oZoomMenu.addNormalItem("100%", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Zoom reset to 100%", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+0")

	oViewMenu.addSubmenu("Zoom", oZoomMenu)

	# ===== SETTINGS MENU =====
	oSettingsMenu = oMenuBar.createMenu("Settings")

	oSettingsMenu.addNormalItem("Preferences", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Opening preferences... (See tabs below!)", 78))
		oAppStatusBar.draw()
	})

	oSettingsMenu.addNormalItem("Keyboard Shortcuts", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Showing keyboard shortcuts...", 78))
		oAppStatusBar.draw()
	})

	# ===== HELP MENU =====
	oHelpMenu = oMenuBar.createMenu("Help")

	oHelpMenu.addNormalItem("Documentation", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Opening documentation...", 78))
		oAppStatusBar.draw()
	}).setShortcut("F1")

	oHelpMenu.addSeparator()

	oHelpMenu.addNormalItem("About", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("TUILib - Menu + Tabs Demo", 78))
		oAppStatusBar.draw()
	})

	oMenuBar.draw()

	# ========================================
	# Create Tab Control below the menu bar
	# ========================================
	oTabs = new TUITabControl(oAppKernel, 2, 3, 76, 18)

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

	oLblInfo1 = new TUILabel(oAppKernel, 0, 0, 65, 1)
	oLblInfo1.nBgColor = BLACK
	oLblInfo1.setText("Configure your general application settings here.")
	oLblInfo1.nFgColor = LIGHTGREEN
	oPage1.addChild(oLblInfo1, 1, 10)

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
	oLstTheme.nSelectedIndex = 2
	oPage2.addChild(oLstTheme, 15, 2)

	oChkBold = new TUICheckBox(oAppKernel, 0, 0, 25, 1)
	oChkBold.cText = "Bold text"
	oPage2.addChild(oChkBold, 1, 9)

	oChkLarge = new TUICheckBox(oAppKernel, 0, 0, 25, 1)
	oChkLarge.cText = "Large fonts"
	oPage2.addChild(oChkLarge, 1, 10)

	oLblInfo2 = new TUILabel(oAppKernel, 0, 0, 65, 1)
	oLblInfo2.nBgColor = BLACK
	oLblInfo2.setText("Customize the look and feel of your application.")
	oLblInfo2.nFgColor = LIGHTGREEN
	oPage2.addChild(oLblInfo2, 1, 12)

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

	oLblInfo3 = new TUILabel(oAppKernel, 0, 0, 65, 1)
	oLblInfo3.nBgColor = BLACK
	oLblInfo3.setText("Configure network and connection settings.")
	oLblInfo3.nFgColor = LIGHTGREEN
	oPage3.addChild(oLblInfo3, 1, 12)

	# === Page 4: About ===
	oPage4 = oTabs.addPage("About")

	oLblAbout = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblAbout.nBgColor = BLACK
	oLblAbout.setText("About This Application")
	oLblAbout.nFgColor = YELLOW
	oPage4.addChild(oLblAbout, 1, 0)

	oLblAppName = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblAppName.nBgColor = BLACK
	oLblAppName.setText("TUILib - Combined Demo")
	oLblAppName.nFgColor = LIGHTCYAN
	oPage4.addChild(oLblAppName, 1, 2)

	oLblVersion = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblVersion.nBgColor = BLACK
	oLblVersion.setText("Version: 1.0.0")
	oLblVersion.nFgColor = GREY
	oPage4.addChild(oLblVersion, 1, 4)

	oLblDesc = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblDesc.nBgColor = BLACK
	oLblDesc.setText("This demo shows Menu Bar and Tab Control together")
	oLblDesc.nFgColor = GREY
	oPage4.addChild(oLblDesc, 1, 6)

	oLblFeatures = new TUILabel(oAppKernel, 0, 0, 60, 1)
	oLblFeatures.nBgColor = BLACK
	oLblFeatures.setText("Features demonstrated:")
	oLblFeatures.nFgColor = LIGHTGREEN
	oPage4.addChild(oLblFeatures, 1, 8)

	oLblF1 = new TUILabel(oAppKernel, 0, 0, 55, 1)
	oLblF1.nBgColor = BLACK
	oLblF1.setText("- Menu bar with submenus and checkboxes")
	oLblF1.nFgColor = WHITE
	oPage4.addChild(oLblF1, 3, 9)

	oLblF2 = new TUILabel(oAppKernel, 0, 0, 55, 1)
	oLblF2.nBgColor = BLACK
	oLblF2.setText("- Tab control with multiple pages")
	oLblF2.nFgColor = WHITE
	oPage4.addChild(oLblF2, 3, 10)

	oLblF3 = new TUILabel(oAppKernel, 0, 0, 55, 1)
	oLblF3.nBgColor = BLACK
	oLblF3.setText("- Various controls on each tab page")
	oLblF3.nFgColor = WHITE
	oPage4.addChild(oLblF3, 3, 11)

	# Register tabs with kernel for smart redrawing when menus close
	oAppKernel.registerScreenWidget(oTabs)

	# Draw tabs
	oTabs.draw()

	# ========================================
	# Create Help label and Status Bar
	# ========================================
	oLblHelp = new TUILabel(oAppKernel, 2, 22, 76, 1)
	oLblHelp.nBgColor = BLACK
	oLblHelp.setText("F2/Click: Menu | F3: Switch Tabs | TAB: Navigate | ESC: Exit")
	oLblHelp.nFgColor = LIGHTGREEN
	oLblHelp.draw()

	# Register lblHelp with kernel for smart redrawing
	oAppKernel.registerScreenWidget(oLblHelp)

	oAppStatusBar = new TUILabel(oAppKernel, 1, 25, 80, 1)
	oAppStatusBar.setText(oAppKernel.fixedWidth("Menu + Tabs Demo - Click on controls to interact with them", 80))
	oAppStatusBar.nFgColor = BLACK
	oAppStatusBar.nBgColor = GREY
	oAppStatusBar.draw()

	# Configure EventManager for menu + tabs UI
	oAppEventManager.clearWidgets()
	oAppEventManager.setMenuBar(oMenuBar)
	oAppEventManager.setTabControl(oTabs)
	oAppEventManager.setStatusBar(oAppStatusBar)

	# Run event loop - EventManager handles everything!
	oAppEventManager.run()
