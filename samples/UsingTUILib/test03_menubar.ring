/*
	TUILib Sample - Menu bar with shortcuts, check box items, separators and nested submenus
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

runMenuDemo()

oAppKernel.restoreTerminal()

func runMenuDemo
	# Set the default background color for this demo (blue)
	oAppKernel.setDefaultColors(WHITE, BLUE)
	oAppKernel.clearScreenWidgets()     # Clear any widgets from previous demo

	# Create status bar first (will be updated by menu actions)
	# Using $statusBar as a global variable so menu handlers can access it
	oAppStatusBar = new TUILabel(oAppKernel, 1, 25, 78, 1)
	oAppStatusBar.nFgColor = BLACK
	oAppStatusBar.nBgColor = GREY
	oAppStatusBar.setText(oAppKernel.fixedWidth("Menu Demo - Click menus or press F2 to activate | ESC to exit", 78))

	# Create content labels for the demo screen text
	# These will be registered with kernel for automatic redrawing when menus close
	oLblTitle = new TUILabel(oAppKernel, 30, 10, 20, 1)
	oLblTitle.setText("MENU BAR DEMO")
	oLblTitle.nFgColor = WHITE
	oLblTitle.nBgColor = BLUE

	oLblHelp1 = new TUILabel(oAppKernel, 20, 12, 40, 1)
	oLblHelp1.setText("Click on menu items or press F2")
	oLblHelp1.nFgColor = WHITE
	oLblHelp1.nBgColor = BLUE

	oLblHelp2 = new TUILabel(oAppKernel, 20, 13, 40, 1)
	oLblHelp2.setText("Use arrow keys to navigate menus")
	oLblHelp2.nFgColor = WHITE
	oLblHelp2.nBgColor = BLUE

	oLblHelp3 = new TUILabel(oAppKernel, 20, 14, 45, 1)
	oLblHelp3.setText("Press Enter to select, Escape to close")
	oLblHelp3.nFgColor = WHITE
	oLblHelp3.nBgColor = BLUE

	oLblFeatures = new TUILabel(oAppKernel, 20, 16, 30, 1)
	oLblFeatures.setText("Features demonstrated:")
	oLblFeatures.nFgColor = WHITE
	oLblFeatures.nBgColor = BLUE

	oLblF1 = new TUILabel(oAppKernel, 22, 17, 40, 1)
	oLblF1.setText("- Normal menu items with shortcuts")
	oLblF1.nFgColor = WHITE
	oLblF1.nBgColor = BLUE

	oLblF2 = new TUILabel(oAppKernel, 22, 18, 35, 1)
	oLblF2.setText("- Checkbox items (View menu)")
	oLblF2.nFgColor = WHITE
	oLblF2.nBgColor = BLUE

	oLblF3 = new TUILabel(oAppKernel, 22, 19, 45, 1)
	oLblF3.setText("- Nested submenus (Format > Font > Size)")
	oLblF3.nFgColor = WHITE
	oLblF3.nBgColor = BLUE

	oLblF4 = new TUILabel(oAppKernel, 22, 20, 40, 1)
	oLblF4.setText("- Separators between item groups")
	oLblF4.nFgColor = WHITE
	oLblF4.nBgColor = BLUE

	# Register all labels with the kernel for automatic redrawing
	oAppKernel.registerScreenWidget(oLblTitle)
	oAppKernel.registerScreenWidget(oLblHelp1)
	oAppKernel.registerScreenWidget(oLblHelp2)
	oAppKernel.registerScreenWidget(oLblHelp3)
	oAppKernel.registerScreenWidget(oLblFeatures)
	oAppKernel.registerScreenWidget(oLblF1)
	oAppKernel.registerScreenWidget(oLblF2)
	oAppKernel.registerScreenWidget(oLblF3)
	oAppKernel.registerScreenWidget(oLblF4)
	oAppKernel.registerScreenWidget(oAppStatusBar)

	# Create menu bar
	oMenuBar = new TUIMenuBar(oAppKernel, 1, 1, 80)

	# ===== FILE MENU =====
	oFileMenu = oMenuBar.createMenu("File")

	oFileMenu.addNormalItem("New", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("File > New clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+N")

	oFileMenu.addNormalItem("Open...", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("File > Open clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+O")

	oFileMenu.addNormalItem("Save", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("File > Save clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+S")

	oFileMenu.addNormalItem("Save As...", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("File > Save As clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+Shift+S")

	oFileMenu.addSeparator()

	# Recent Files submenu
	oRecentMenu = new TUIMenu(oAppKernel)
	oRecentMenu.addNormalItem("document1.txt", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Opening document1.txt...", 78))
		oAppStatusBar.draw()
	})
	oRecentMenu.addNormalItem("document2.txt", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Opening document2.txt...", 78))
		oAppStatusBar.draw()
	})
	oRecentMenu.addNormalItem("project.ring", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Opening project.ring...", 78))
		oAppStatusBar.draw()
	})
	oRecentMenu.addSeparator()
	oRecentMenu.addNormalItem("Clear Recent", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Recent files cleared", 78))
		oAppStatusBar.draw()
	})

	oFileMenu.addSubmenu("Recent Files", oRecentMenu)

	oFileMenu.addSeparator()

	oFileMenu.addNormalItem("Exit", func oItem {
		oAppEventManager.stop()
	})

	# ===== EDIT MENU =====
	oEditMenu = oMenuBar.createMenu("Edit")

	oEditMenu.addNormalItem("Undo", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Edit > Undo clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+Z")

	oEditMenu.addNormalItem("Redo", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Edit > Redo clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+Y")

	oEditMenu.addSeparator()

	oEditMenu.addNormalItem("Cut", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Edit > Cut clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+X")

	oEditMenu.addNormalItem("Copy", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Edit > Copy clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+C")

	oEditMenu.addNormalItem("Paste", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Edit > Paste clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+V")

	oEditMenu.addSeparator()

	oEditMenu.addNormalItem("Select All", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Edit > Select All clicked", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+A")

	# ===== VIEW MENU =====
	oViewMenu = oMenuBar.createMenu("View")

	oViewMenu.addCheckboxItem("Show Toolbar", true, func oItem {
		if oItem.lChecked
			oAppStatusBar.setText(oAppKernel.fixedWidth("Toolbar is now visible", 78))
		else
			oAppStatusBar.setText(oAppKernel.fixedWidth("Toolbar is now hidden", 78))
		ok
		oAppStatusBar.draw()
	})

	oViewMenu.addCheckboxItem("Show Status Bar", true, func oItem {
		if oItem.lChecked
			oAppStatusBar.setText(oAppKernel.fixedWidth("Status bar is now visible", 78))
		else
			oAppStatusBar.setText(oAppKernel.fixedWidth("Status bar is now hidden", 78))
		ok
		oAppStatusBar.draw()
	})

	oViewMenu.addCheckboxItem("Show Line Numbers", false, func oItem {
		if oItem.lChecked
			oAppStatusBar.setText(oAppKernel.fixedWidth("Line numbers enabled", 78))
		else
			oAppStatusBar.setText(oAppKernel.fixedWidth("Line numbers disabled", 78))
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
	oZoomMenu.addNormalItem("Reset Zoom", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Zoom reset to 100%", 78))
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+0")

	oViewMenu.addSubmenu("Zoom", oZoomMenu)

	oViewMenu.addSeparator()

	oViewMenu.addNormalItem("Full Screen", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Toggling full screen mode...", 78))
		oAppStatusBar.draw()
	}).setShortcut("F11")

	# ===== FORMAT MENU =====
	oFormatMenu = oMenuBar.createMenu("Format")

	# Font submenu with nested submenu
	oFontMenu = new TUIMenu(oAppKernel)
	oFontMenu.addNormalItem("Arial", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Font changed to Arial", 78))
		oAppStatusBar.draw()
	})
	oFontMenu.addNormalItem("Times New Roman", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Font changed to Times New Roman", 78))
		oAppStatusBar.draw()
	})
	oFontMenu.addNormalItem("Courier New", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Font changed to Courier New", 78))
		oAppStatusBar.draw()
	})
	oFontMenu.addSeparator()

	# Font size nested submenu
	oFontSizeMenu = new TUIMenu(oAppKernel)
	oFontSizeMenu.addNormalItem("10 pt", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Font size: 10 pt", 78))
		oAppStatusBar.draw()
	})
	oFontSizeMenu.addNormalItem("12 pt", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Font size: 12 pt", 78))
		oAppStatusBar.draw()
	})
	oFontSizeMenu.addNormalItem("14 pt", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Font size: 14 pt", 78))
		oAppStatusBar.draw()
	})
	oFontSizeMenu.addNormalItem("16 pt", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Font size: 16 pt", 78))
		oAppStatusBar.draw()
	})
	oFontSizeMenu.addNormalItem("18 pt", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Font size: 18 pt", 78))
		oAppStatusBar.draw()
	})

	oFontMenu.addSubmenu("Size", oFontSizeMenu)

	oFormatMenu.addSubmenu("Font", oFontMenu)

	oFormatMenu.addSeparator()

	oFormatMenu.addCheckboxItem("Bold", false, func oItem {
		if oItem.lChecked
			oAppStatusBar.setText(oAppKernel.fixedWidth("Bold enabled", 78))
		else
			oAppStatusBar.setText(oAppKernel.fixedWidth("Bold disabled", 78))
		ok
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+B")

	oFormatMenu.addCheckboxItem("Italic", false, func oItem {
		if oItem.lChecked
			oAppStatusBar.setText(oAppKernel.fixedWidth("Italic enabled", 78))
		else
			oAppStatusBar.setText(oAppKernel.fixedWidth("Italic disabled", 78))
		ok
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+I")

	oFormatMenu.addCheckboxItem("Underline", false, func oItem {
		if oItem.lChecked
			oAppStatusBar.setText(oAppKernel.fixedWidth("Underline enabled", 78))
		else
			oAppStatusBar.setText(oAppKernel.fixedWidth("Underline disabled", 78))
		ok
		oAppStatusBar.draw()
	}).setShortcut("Ctrl+U")

	# ===== HELP MENU =====
	oHelpMenu = oMenuBar.createMenu("Help")

	oHelpMenu.addNormalItem("View Help", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Opening help...", 78))
		oAppStatusBar.draw()
	}).setShortcut("F1")

	oHelpMenu.addNormalItem("Keyboard Shortcuts", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Showing keyboard shortcuts...", 78))
		oAppStatusBar.draw()
	})

	oHelpMenu.addSeparator()

	oHelpMenu.addNormalItem("Check for Updates", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Checking for updates...", 78))
		oAppStatusBar.draw()
	})

	oHelpMenu.addSeparator()

	oHelpMenu.addNormalItem("About", func oItem {
		oAppStatusBar.setText(oAppKernel.fixedWidth("TUILib - Menu Demo", 78))
		oAppStatusBar.draw()
	})

	# Draw initial screen
	drawMenuDemoScreen(oMenuBar)

	# Configure EventManager for menu-based UI
	oAppEventManager.clearWidgets()
	oAppEventManager.setMenuBar(oMenuBar)
	oAppEventManager.setStatusBar(oAppStatusBar)

	# Run event loop - EventManager handles everything!
	oAppEventManager.run()

func drawMenuDemoScreen oMenuBar
	# Clear the main area (below the menu bar, above the status bar)
	oAppKernel.setTermColor(WHITE, BLUE)
	cClearLine = copy(" ", 80)
	for nRow = 2 to 24
		oAppKernel.printAt(1, nRow, cClearLine)
	next

	oMenuBar.draw()

	# Draw the registered screen widgets (labels)
	for oWidget in oAppKernel.aScreenWidgets
		if oWidget.lVisible
			oWidget.draw()
		ok
	next

	oAppKernel.resetTermColor()
