/*
	TUILib Sample - Two tree views with custom keyboard and mouse handlers
*/

load "tuilib.ring"

# Global variables (used by the event handlers)
oAppKernel = NULL
oAppEventManager = NULL
nAppActiveTree = 1
oAppStatusBar = NULL
oAppTree1 = NULL
oAppTree2 = NULL

oAppKernel = new TUIKernel()
oAppKernel.clear()
oAppKernel.enableMouse()
oAppEventManager = new TUIEventManager(oAppKernel)

runTreeDemo()

oAppKernel.restoreTerminal()

func runTreeDemo
	# Create main window
	oWin = new TUIWindow(oAppKernel, 2, 2, 76, 23, "Tree View Demo - ESC: Exit")

	# Create info labels
	oLblTitle = new TUILabel(oAppKernel, 4, 4, 70, 1)
	oLblTitle.setText("File System Explorer (Tree View)")
	oLblTitle.nFgColor = YELLOW

	oLblHelp = new TUILabel(oAppKernel, 4, 21, 70, 1)
	oLblHelp.setText("Arrow Keys: Navigate | +/-/Enter/Space: Expand/Collapse | ESC: Exit")
	oLblHelp.nFgColor = LIGHTGREEN

	# Create tree view
	oAppTree1 = new TUITreeView(oAppKernel, 4, 6, 35, 14)

	# Build a file system tree
	oRootC = oAppTree1.addRootText("C:")

	# Program Files
	oProgFiles = oRootC.addChildText("Program Files")
	oOffice = oProgFiles.addChildText("Office Suite")
	oOffice.addChildText("writer.exe")
	oOffice.addChildText("sheets.exe")
	oOffice.addChildText("slides.exe")
	oRing = oProgFiles.addChildText("Ring")
	oRing.addChildText("ring.exe")
	oRing.addChildText("ring2exe.exe")
	oRing.addChildText("ringpm.exe")
	oLibs = oRing.addChildText("lib")
	oLibs.addChildText("stdlib.ring")
	oLibs.addChildText("guilib.ring")

	# Users
	oUsers = oRootC.addChildText("Users")
	oUser1 = oUsers.addChildText("User1")
	oDocs = oUser1.addChildText("Documents")
	oDocs.addChildText("report.docx")
	oDocs.addChildText("budget.xlsx")
	oPics = oUser1.addChildText("Pictures")
	oPics.addChildText("photo1.jpg")
	oPics.addChildText("photo2.png")
	oDesktop = oUser1.addChildText("Desktop")
	oDesktop.addChildText("shortcut.lnk")

	# Windows
	oWinDir = oRootC.addChildText("Windows")
	oSys32 = oWinDir.addChildText("System32")
	oSys32.addChildText("cmd.exe")
	oSys32.addChildText("notepad.exe")
	oWinDir.addChildText("explorer.exe")

	# Second root - D: drive
	oRootD = oAppTree1.addRootText("D:")
	oProjects = oRootD.addChildText("Projects")
	oProj1 = oProjects.addChildText("TUI Library")
	oProj1.addChildText("tui.ring")
	oProj1.addChildText("demo.ring")
	oProj1.addChildText("README.md")
	oProj2 = oProjects.addChildText("Web App")
	oProj2.addChildText("index.html")
	oProj2.addChildText("style.css")
	oProj2.addChildText("app.js")

	# Expand some nodes by default
	oRootC.expand()
	oProgFiles.expand()

	oAppTree1.updateVisibleNodes()

	# Create second tree for demonstration
	oLblTree2 = new TUILabel(oAppKernel, 42, 4, 30, 1)
	oLblTree2.setText("Organization Chart")
	oLblTree2.nFgColor = YELLOW

	oAppTree2 = new TUITreeView(oAppKernel, 42, 6, 32, 14)

	# Build organization tree
	oCeo = oAppTree2.addRootText("CEO - Person 1")

	oCto = oCeo.addChildText("CTO - Person 2")
	oDev = oCto.addChildText("Dev Manager")
	oDev.addChildText("Senior Dev")
	oDev.addChildText("Junior Dev")
	oDev.addChildText("Intern")
	oQa = oCto.addChildText("QA Manager")
	oQa.addChildText("QA Engineer")
	oQa.addChildText("Test Analyst")

	oCfo = oCeo.addChildText("CFO - Person 3")
	oCfo.addChildText("Accountant")
	oCfo.addChildText("Financial Analyst")

	oCoo = oCeo.addChildText("COO - Person 4")
	oHr = oCoo.addChildText("HR Manager")
	oHr.addChildText("Recruiter")
	oOps = oCoo.addChildText("Operations")
	oOps.addChildText("Support Lead")
	oOps.addChildText("Support Agent")

	oCeo.expand()
	oCto.expand()

	oAppTree2.updateVisibleNodes()

	# Add all controls to window
	oWin.addChild(oLblTitle)
	oWin.addChild(oLblHelp)
	oWin.addChild(oAppTree1)
	oWin.addChild(oLblTree2)
	oWin.addChild(oAppTree2)

	# Draw window (draws all children automatically)
	oWin.draw()

	# Status bar (outside window)
	oAppStatusBar = new TUILabel(oAppKernel, 2, 25, 76, 1)
	oAppStatusBar.setText(oAppKernel.fixedWidth("Tree View Demo - Arrows: Navigate | F4: Switch trees | ESC: Exit", 76))
	oAppStatusBar.nFgColor = BLACK
	oAppStatusBar.nBgColor = GREY
	oAppStatusBar.draw()

	# Focus on first tree
	oAppTree1.lFocused = true

	# Register trees with EventManager for mouse handling
	oAppEventManager.registerWidget(oAppTree1)
	oAppEventManager.registerWidget(oAppTree2)
	oAppEventManager.setFocus(oAppTree1)

	# Set up keyboard handler for tree-specific navigation
	oAppEventManager.setOnKeyboard(func oEvent {
		nKey = oEvent.nKey

		# F4 to switch between trees
		if nKey = KEY_F4
			if nAppActiveTree = 1
				nAppActiveTree = 2
				oAppTree1.lFocused = false
				oAppTree2.lFocused = true
				oAppStatusBar.setText(oAppKernel.fixedWidth("Organization Chart tree active", 76))
			else
				nAppActiveTree = 1
				oAppTree1.lFocused = true
				oAppTree2.lFocused = false
				oAppStatusBar.setText(oAppKernel.fixedWidth("File System tree active", 76))
			ok
			oAppStatusBar.draw()
			oAppTree1.draw()
			oAppTree2.draw()
			return true
		ok

		# Pass keyboard to active tree
		if nAppActiveTree = 1
			oAppTree1.handleEvent(oEvent)
			oNode = oAppTree1.getSelectedNode()
			if oNode != NULL
				oAppStatusBar.setText(oAppKernel.fixedWidth("Selected: " + oNode.cText, 76))
				oAppStatusBar.draw()
			ok
		else
			oAppTree2.handleEvent(oEvent)
			oNode = oAppTree2.getSelectedNode()
			if oNode != NULL
				oAppStatusBar.setText(oAppKernel.fixedWidth("Selected: " + oNode.cText, 76))
				oAppStatusBar.draw()
			ok
		ok

		return true
	})

	# Set up mouse handler for tree clicking
	oAppEventManager.setOnMouse(func oEvent {
		# Check which tree was clicked
		if oAppTree1.handleEvent(oEvent)
			if nAppActiveTree != 1
				nAppActiveTree = 1
				oAppTree1.lFocused = true
				oAppTree2.lFocused = false
				oAppTree2.draw()
			ok
			oNode = oAppTree1.getSelectedNode()
			if oNode != NULL
				oAppStatusBar.setText(oAppKernel.fixedWidth("Selected: " + oNode.cText, 76))
				oAppStatusBar.draw()
			ok
			return true
		ok

		if oAppTree2.handleEvent(oEvent)
			if nAppActiveTree != 2
				nAppActiveTree = 2
				oAppTree1.lFocused = false
				oAppTree2.lFocused = true
				oAppTree1.draw()
			ok
			oNode = oAppTree2.getSelectedNode()
			if oNode != NULL
				oAppStatusBar.setText(oAppKernel.fixedWidth("Selected: " + oNode.cText, 76))
				oAppStatusBar.draw()
			ok
			return true
		ok

		return false
	})

	# Run event loop
	oAppEventManager.run()
