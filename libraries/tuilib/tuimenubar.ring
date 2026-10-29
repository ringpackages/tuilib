# Horizontal menu bar with drop-down menus

class TUIMenuBar from TUIWidget

	aMenus = []             # List of TUIMenu objects
	nSelectedIndex = 0      # Currently selected menu (0 = none, 1-based otherwise)
	oActiveMenu = NULL      # Currently open menu
	lActive = false       # Is menu bar active (has focus)?

	# Colors
	nNormalFgColor = BLACK      # Black text
	nNormalBgColor = GREY      # Light gray background
	nSelectedFgColor = WHITE    # White text
	nSelectedBgColor = BLUE     # Blue background
	nHotKeyFgColor = BLUE      # Blue for hotkey letters

	func init oTUIKernel, nPosX, nPosY, nSizeW
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, 1)
		return self

	func addMenu oMenu
		add(aMenus, oMenu)
		return self

	func createMenu cTitle
		oMenu = new TUIMenu(oKernel)
		oMenu.setTitle(cTitle)
		add(aMenus, oMenu)
		# Return reference to the menu in the array so modifications affect the stored object
		return ref(aMenus[len(aMenus)])

	func draw
		if not lVisible
			return
		ok

		# Draw menu bar background
		oKernel.setTermColor(nNormalFgColor, nNormalBgColor)
		cBgLine = copy(" ", nWidth)
		oKernel.printAt(nX, nY, cBgLine)

		# Draw menu titles
		nCurrentX = nX + 1
		for nIndex = 1 to len(aMenus)
			oMenu = aMenus[nIndex]
			cTitleText = " " + oMenu.cTitle + " "

			# Determine colors
			if nIndex = nSelectedIndex
				oKernel.setTermColor(nSelectedFgColor, nSelectedBgColor)
			else
				oKernel.setTermColor(nNormalFgColor, nNormalBgColor)
			ok

			oKernel.printAt(nCurrentX, nY, cTitleText)
			nCurrentX = nCurrentX + len(cTitleText)
		next

		oKernel.resetTermColor()

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			return handleKeyboard(oEvent.nKey)
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			return handleMouse(oEvent.nX, oEvent.nY, true)
		ok

		return false

	func handleKeyboard nKey
		# F2 to activate menu bar
		if nKey = KEY_F2
			if not lActive
				activate()
				runMenuLoop()
			ok
			return true
		ok

		return false

	func handleMouse nMouseX, nMouseY, lClicking
		# Check if click is on menu bar
		if nMouseY = nY and nMouseX >= nX and nMouseX < nX + nWidth
			# Find which menu was clicked
			nCurrentX = nX + 1
			for nIndex = 1 to len(aMenus)
				oMenu = aMenus[nIndex]
				nTitleLen = len(oMenu.cTitle) + 2

				if nMouseX >= nCurrentX and nMouseX < nCurrentX + nTitleLen
					if lClicking
						# Open this menu
						nSelectedIndex = nIndex
						lActive = true
						draw()
						openMenu(nIndex)
						runMenuLoop()
					ok
					return true
				ok
				nCurrentX = nCurrentX + nTitleLen
			next
			return true
		ok

		return false

	func activate
		lActive = true
		if nSelectedIndex = 0 and len(aMenus) > 0
			nSelectedIndex = 1
		ok
		draw()

	func deactivate
		lActive = false
		nSelectedIndex = 0
		if oActiveMenu != NULL
			oActiveMenu.hide()
			oActiveMenu = NULL
		ok
		draw()

	func openMenu nMenuIndex
		if nMenuIndex < 1 or nMenuIndex > len(aMenus)
			return
		ok

		oMenu = aMenus[nMenuIndex]

		# Calculate menu position (below the menu title)
		nMenuX = nX + 1
		for nIndex = 1 to nMenuIndex - 1
			nMenuX = nMenuX + len(aMenus[nIndex].cTitle) + 2
		next

		# Adjust if menu would go off screen
		if nMenuX + oMenu.nWidth > oKernel.getCols()
			nMenuX = oKernel.getCols() - oMenu.nWidth
		ok

		oMenu.show(nMenuX, nY + 1)
		oActiveMenu = oMenu

	func closeMenu
		if oActiveMenu != NULL
			oActiveMenu.hide()
			oActiveMenu = NULL
		ok
		lActive = false
		nSelectedIndex = 0
		draw()

	func moveNext
		if len(aMenus) = 0
			return
		ok

		if oActiveMenu != NULL
			oActiveMenu.hide()
		ok

		nSelectedIndex++
		if nSelectedIndex > len(aMenus)
			nSelectedIndex = 1
		ok

		draw()
		openMenu(nSelectedIndex)

	func movePrevious
		if len(aMenus) = 0
			return
		ok

		if oActiveMenu != NULL
			oActiveMenu.hide()
		ok

		nSelectedIndex--
		if nSelectedIndex < 1
			nSelectedIndex = len(aMenus)
		ok

		draw()
		openMenu(nSelectedIndex)

	func isMenuActive
		return oActiveMenu != NULL or lActive

	func getActiveMenu
		return oActiveMenu

	func getMenuByTitle cTitle
		for oMenu in aMenus
			if oMenu.cTitle = cTitle
				return oMenu
			ok
		next
		return NULL

	func closeDeepestSubmenu oMenu
		# Close only the deepest submenu in the hierarchy (one level)
		if oMenu.oActiveSubmenu = NULL
			return
		ok

		if oMenu.oActiveSubmenu.oActiveSubmenu = NULL
			# This menu's submenu is the deepest - close it
			oMenu.oActiveSubmenu.hide()
			oMenu.oActiveSubmenu = NULL
			oMenu.draw()
		else
			# Go deeper
			closeDeepestSubmenu(oMenu.oActiveSubmenu)
		ok

	func runMenuLoop
		# Dedicated loop for menu interaction
		# This prevents the main event loop from interfering

		# Only button presses are clicks, so the release of the click that opened
		# the menu doesn't close it
		lMenuRunning = true

		while lMenuRunning
			oInput = oKernel.pollEvent()
			if oInput = NULL
				oKernel.sleep(1)
				loop
			ok

			if oInput.cType = TUI_EVENT_KEYBOARD
				nKey = oInput.nKey

				# Escape - close menu
				if nKey = 27 or nKey = KEY_ESCAPE
					if oActiveMenu != NULL and oActiveMenu.oActiveSubmenu != NULL
						# Close submenu first
						oActiveMenu.closeAllSubmenus()
						oActiveMenu.draw()
					but oActiveMenu != NULL
						# Close the dropdown
						closeMenu()
						lMenuRunning = false
					else
						# Deactivate menu bar
						deactivate()
						lMenuRunning = false
					ok
				ok

				# Left arrow - close one level of submenu or previous menu
				if nKey = KEY_LEFT
					if oActiveMenu != NULL
						# Get the deepest active menu
						oDeepMenu = oActiveMenu.getDeepestActiveMenu()

						if oDeepMenu != oActiveMenu
							# We're in a submenu - close just the deepest one
							# Find the parent of the deepest menu and close its submenu
							closeDeepestSubmenu(oActiveMenu)
						else
							# We're at the top level menu - move to previous menu
							movePrevious()
						ok
					else
						# No menu open - move to previous menu
						movePrevious()
					ok
				ok

				# Right arrow - next menu or open submenu
				if nKey = KEY_RIGHT
					if oActiveMenu != NULL
						# Get the deepest active menu in the hierarchy
						oDeepMenu = oActiveMenu.getDeepestActiveMenu()
						oItem = oDeepMenu.getSelectedItem()
						if oItem != NULL and oItem.cItemType = TUI_MENUITEM_SUBMENU and oItem.lEnabled
							# Open the submenu of the currently selected item
							oDeepMenu.openSubmenu(oItem)
						else
							# No submenu to open - move to next top-level menu
							# First close all submenus and clear their areas
							if oActiveMenu.oActiveSubmenu != NULL
								oActiveMenu.closeAllSubmenus()
							ok
							moveNext()
						ok
					else
						moveNext()
					ok
				ok

				# Up arrow
				if nKey = KEY_UP
					if oActiveMenu != NULL
						oActiveMenu.movePreviousDeep()
					ok
				ok

				# Down arrow
				if nKey = KEY_DOWN
					if oActiveMenu != NULL
						oActiveMenu.moveNextDeep()
					but lActive and nSelectedIndex > 0
						openMenu(nSelectedIndex)
					ok
				ok

				# Enter or Space - activate item
				if nKey = 13 or nKey = KEY_ENTER or nKey = 32 or nKey = KEY_SPACE
					if oActiveMenu != NULL
						cResult = oActiveMenu.activateSelectedDeep()
						if cResult = "close"
							closeMenu()
							lMenuRunning = false
						ok
					but lActive and nSelectedIndex > 0
						openMenu(nSelectedIndex)
					ok
				ok

			# Mouse over an open menu: select the item under the mouse
			but oInput.nAction = TUI_MOUSE_MOVE
				if oActiveMenu != NULL
					oActiveMenu.handleMouseDeep(oInput.nX, oInput.nY, false)
				ok

			# Mouse click
			but oInput.nAction = TUI_MOUSE_PRESS and oInput.nButton = TUI_BUTTON_LEFT
				nMouseX = oInput.nX
				nMouseY = oInput.nY
				# Check if click is on menu bar
				if nMouseY = nY and nMouseX >= nX and nMouseX < nX + nWidth
					# Find which menu was clicked
					nCurrentX = nX + 1
					nClickedMenu = 0
					for nIndex = 1 to len(aMenus)
						oMenu = aMenus[nIndex]
						nTitleLen = len(oMenu.cTitle) + 2

						if nMouseX >= nCurrentX and nMouseX < nCurrentX + nTitleLen
							nClickedMenu = nIndex
							exit
						ok
						nCurrentX = nCurrentX + nTitleLen
					next

					if nClickedMenu > 0
						if nClickedMenu = nSelectedIndex and oActiveMenu != NULL
							# Clicking on same menu - close it
							closeMenu()
							lMenuRunning = false
						else
							# Switch to different menu
							if oActiveMenu != NULL
								oActiveMenu.hide()
							ok
							nSelectedIndex = nClickedMenu
							draw()
							openMenu(nSelectedIndex)
						ok
					ok
				# Check if click is in active menu or submenus
				but oActiveMenu != NULL
					cResult = oActiveMenu.handleMouseDeep(nMouseX, nMouseY, true)
					if cResult = "close"
						closeMenu()
						lMenuRunning = false
					but cResult = "outside"
						# Clicked outside all menus - close
						closeMenu()
						lMenuRunning = false
					ok
				else
					# Clicked outside - close
					deactivate()
					lMenuRunning = false
				ok
			ok
		end
