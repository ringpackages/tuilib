# Main event loop: focus, keyboard/mouse dispatch, menu bar, tab control and status bar

class TUIEventManager

	oKernel = NULL
	aWidgets = []
	oFocusedWidget = NULL
	lRunning = false
	aEventHandlers = []

	# High-level UI components
	oMenuBar = NULL          # Optional TUIMenuBar
	oTabControl = NULL       # Optional TUITabControl
	oStatusBar = NULL        # Optional status bar (TUILabel)

	# Tab control integration
	oTabFocusedControl = NULL  # Currently focused control inside a tab

	# Custom event handlers (application logic)
	cOnKeyboard = NULL
	cOnMouse = NULL
	cOnTimer = NULL
	nTimerInterval = 0         # Timer interval in iterations (0 = disabled)
	nTimerCounter = 0

	func init oTUIKernel
		oKernel = ref(oTUIKernel)
		return self

	func registerWidget oWidget
		add(aWidgets, ref(oWidget))

	func unregisterWidget oWidget
		nPos = find(aWidgets, oWidget)
		if nPos > 0
			del(aWidgets, nPos)
		ok

	func clearWidgets
		aWidgets = []
		oFocusedWidget = NULL
		oTabFocusedControl = NULL

	func setOnKeyboard cHandler
		cOnKeyboard = cHandler
		return self

	func setOnMouse cHandler
		cOnMouse = cHandler
		return self

	func setOnTimer cHandler, nInterval
		cOnTimer = cHandler
		nTimerInterval = nInterval
		nTimerCounter = 0
		return self

	# The menu bar, tab control and status bar are shared (not copied); pass NULL to remove them

	func setMenuBar oBar
		oMenuBar = NULL
		if isObject(oBar) oMenuBar = ref(oBar) ok
		return self

	func setTabControl oTabs
		oTabControl = NULL
		if isObject(oTabs) oTabControl = ref(oTabs) ok
		return self

	func setStatusBar oLabel
		oStatusBar = NULL
		if isObject(oLabel) oStatusBar = ref(oLabel) ok
		return self

	func setStatus cText
		if oStatusBar != NULL
			oStatusBar.setText(oKernel.fixedWidth(cText, oStatusBar.nWidth))
			oStatusBar.draw()
		ok

	func setFocus oWidget
		if oFocusedWidget != NULL
			oFocusedWidget.lFocused = false
			oFocusedWidget.draw()
		ok
		oFocusedWidget = oWidget
		if oWidget != NULL
			oWidget.lFocused = true
			oWidget.draw()
			# Show cursor for text input controls
			if ismethod(oWidget, "showCursor")
				oWidget.showCursor()
			ok
		ok

	func setTabFocus oWidget
		# Set focus to a control inside a TUITabControl
		if oTabFocusedControl != NULL
			oTabFocusedControl.lFocused = false
			oTabFocusedControl.draw()
		ok
		oTabFocusedControl = oWidget
		if oWidget != NULL
			oWidget.lFocused = true
			oWidget.draw()
			# Show cursor for text input controls
			if ismethod(oWidget, "showCursor")
				oWidget.showCursor()
			ok
		ok

	func clearTabFocus
		if oTabFocusedControl != NULL
			oTabFocusedControl.lFocused = false
			oTabFocusedControl.draw()
			oTabFocusedControl = NULL
		ok

	func addEventListener cEventType, cHandler
		add(aEventHandlers, [cEventType, cHandler])

	func fireEvent oEvent
		for aHandler in aEventHandlers
			if aHandler[1] = oEvent.cType
				cHandlerName = aHandler[2]
				call cHandlerName(oEvent)
			ok
		next

	func run
		lRunning = true

		while lRunning
			# Keyboard and mouse events (mouse moves and releases are ignored here)
			oInput = oKernel.pollEvent()
			if oInput != NULL
				if oInput.cType = TUI_EVENT_KEYBOARD
					handleKeyboardEvent(oInput)
				but oInput.nAction = TUI_MOUSE_PRESS and oInput.nButton = TUI_BUTTON_LEFT
					handleLeftClick(oInput)
				ok
			ok

			# Call timer handler if set
			if cOnTimer != NULL and nTimerInterval > 0
				nTimerCounter++
				if nTimerCounter >= nTimerInterval
					nTimerCounter = 0
					call cOnTimer()
				ok
			ok

			# Ensure cursor is visible for focused text controls after all drawing
			if oTabFocusedControl != NULL and ismethod(oTabFocusedControl, "showCursor")
				oTabFocusedControl.showCursor()
			but oFocusedWidget != NULL and ismethod(oFocusedWidget, "showCursor")
				oFocusedWidget.showCursor()
			ok

			# Small delay to prevent CPU overuse (only when there is no waiting input)
			if oInput = NULL
				oKernel.sleep(1)
			ok
		end
		oKernel.flush()

	func handleKeyboardEvent oEvent
		nKey = oEvent.nKey
		oEvent.oTarget = oFocusedWidget
		lEventHandled = false

		# Handle ESC key
		if nKey = 27 or nKey = KEY_ESCAPE
			lEventHandled = handleEscapeKey()
		ok

		# Handle F2 for menu bar
		if not lEventHandled and nKey = KEY_F2 and oMenuBar != NULL
			handleMenuBarActivation()
			lEventHandled = true
		ok

		# Handle F3 key for switching tab pages (only if tabControl is set)
		if not lEventHandled and nKey = KEY_F3 and oTabControl != NULL
			lEventHandled = handleTabPageSwitch()
		ok

		# Call custom keyboard handler if set
		if not lEventHandled and cOnKeyboard != NULL
			lEventHandled = call cOnKeyboard(oEvent)
		ok

		# Handle TAB key for focus navigation between controls
		if not lEventHandled and nKey = TUI_KEY_TAB
			lEventHandled = handleTabFocusNavigation()
		ok

		# If we have a TUITabControl with a focused control inside, send keys there
		if not lEventHandled and oTabControl != NULL and oTabFocusedControl != NULL
			oTabFocusedControl.handleEvent(oEvent)
			oTabFocusedControl.draw()
			lEventHandled = true
		ok

		# Send to focused widget if not handled
		if not lEventHandled and oFocusedWidget != NULL
			oFocusedWidget.handleEvent(oEvent)

			# Check if widget has a pending mouse click (e.g., TUIGrid after edit mode)
			handlePendingMouseClick()
		ok

		# Fire to listeners
		fireEvent(oEvent)

	func handleLeftClick oEvent
		# Call custom mouse handler first if set
		lMouseHandled = false
		if cOnMouse != NULL
			lMouseHandled = call cOnMouse(oEvent)
		ok

		if not lMouseHandled
			handleMouseClick(oEvent.nX, oEvent.nY, true)
		ok

	func handleEscapeKey
		# Handle ESC key press

		# If we have a focused control in a tab, unfocus it first
		if oTabControl != NULL and oTabFocusedControl != NULL
			clearTabFocus()
			setStatus("Control unfocused - Click to focus another")
			return true
		ok

		# Default: stop running
		lRunning = false
		return true

	func handleMenuBarActivation
		# Activate the menu bar
		oMenuBar.activate()
		oMenuBar.openMenu(1)
		oMenuBar.runMenuLoop()
		# Menu bar handles its own cleanup via kernel.redrawRegion

	func handleTabPageSwitch
		# Handle F3 key - switch tab pages
		if oTabControl != NULL
			oTabControl.nextPage()
			oTabControl.draw()
			oPage = oTabControl.getActivePage()
			if oPage != NULL and oStatusBar != NULL
				setStatus("Active Tab: " + oPage.cTitle)
			ok
			# Clear any focused control when switching tabs
			clearTabFocus()
			return true
		ok
		return false

	func handleTabFocusNavigation
		# Handle TAB key - navigate between controls

		# If we have a TUITabControl, navigate between controls in the active page
		if oTabControl != NULL
			oPage = oTabControl.getActivePage()
			if oPage != NULL and len(oPage.aChildren) > 0
				# Find next focusable control in tab page
				nextTabPageControl()
				return true
			ok
		ok

		# Otherwise, focus next widget in the main widget list
		focusNext()
		return true

	func nextTabPageControl
		# Navigate to next control in active tab page
		oPage = oTabControl.getActivePage()
		if oPage = NULL or len(oPage.aChildren) = 0
			return
		ok

		# Find current focused index
		nCurrentIndex = 0
		for nIndex = 1 to len(oPage.aChildren)
			if oPage.aChildren[nIndex].lFocused
				nCurrentIndex = nIndex
				exit
			ok
		next

		# Count focusable children
		nFocusableCount = 0
		for oChild in oPage.aChildren
			if oChild.lFocusable and oChild.lVisible
				nFocusableCount++
			ok
		next

		# If no focusable children, do nothing
		if nFocusableCount = 0
			return
		ok

		# Clear current focus
		if nCurrentIndex > 0
			oPage.aChildren[nCurrentIndex].lFocused = false
			oPage.aChildren[nCurrentIndex].draw()
		ok

		# Find next focusable control (skip non-focusable ones like TUILabel)
		nNextIndex = nCurrentIndex
		nAttempts = 0
		while nAttempts < len(oPage.aChildren)
			nNextIndex++
			if nNextIndex > len(oPage.aChildren)
				nNextIndex = 1
			ok

			# Check if this child is focusable
			if oPage.aChildren[nNextIndex].lFocusable and oPage.aChildren[nNextIndex].lVisible
				exit
			ok

			nAttempts++
		end

		# Set focus to next focusable control
		setTabFocus(oPage.aChildren[nNextIndex])

		if oStatusBar != NULL
			cCtrlName = controlName(oPage.aChildren[nNextIndex])
			setStatus("Focused: " + cCtrlName + " - Use keyboard to interact")
		ok

	func handlePendingMouseClick
		# Check if focused widget has a pending mouse click
		if oFocusedWidget = NULL
			return
		ok

		if not ismethod(oFocusedWidget, "hasPendingMouseClick")
			return
		ok

		if not oFocusedWidget.hasPendingMouseClick()
			return
		ok

		aClickInfo = oFocusedWidget.getPendingMouseClick()
		if aClickInfo = NULL
			return
		ok

		nMouseX = aClickInfo[1]
		nMouseY = aClickInfo[2]
		vMouseData = aClickInfo[3]

		# Find widget at click location
		oClickedWidget = findWidgetAt(nMouseX, nMouseY)
		if oClickedWidget != NULL
			if oClickedWidget != oFocusedWidget
				setFocus(oClickedWidget)
			ok

			oMouseEvent = new TUIEvent(TUI_EVENT_MOUSE)
			oMouseEvent.nX = nMouseX
			oMouseEvent.nY = nMouseY
			oMouseEvent.vData = vMouseData
			oMouseEvent.oTarget = oClickedWidget
			oClickedWidget.handleEvent(oMouseEvent)
		ok

	func handleMouseClick nMouseX, nMouseY, vMouseData
		# Check if click is on menu bar
		if oMenuBar != NULL
			if oMenuBar.handleMouse(nMouseX, nMouseY, true)
				# Menu was activated and handled
				return
			ok
		ok

		# Check if click is on tab control
		if oTabControl != NULL
			# Check if clicking on tab headers
			if nMouseY = oTabControl.nY
				oEvent = new TUIEvent(TUI_EVENT_MOUSE)
				oEvent.nX = nMouseX
				oEvent.nY = nMouseY
				oEvent.vData = true
				if oTabControl.handleEvent(oEvent)
					clearTabFocus()  # Unfocus any control when switching tabs
					oPage = oTabControl.getActivePage()
					if oPage != NULL and oStatusBar != NULL
						setStatus("Active Tab: " + oPage.cTitle)
					ok
					return
				ok
			ok

			# Check if clicking inside tab content area
			if nMouseX > oTabControl.nX and nMouseX < oTabControl.nX + oTabControl.nWidth - 1
				if nMouseY > oTabControl.nY + 1 and nMouseY < oTabControl.nY + oTabControl.nHeight - 1
					handleTabContentClick(nMouseX, nMouseY, vMouseData)
					return
				ok
			ok
		ok

		# Find widget under mouse cursor
		oClickedWidget = findWidgetAt(nMouseX, nMouseY)
		if oClickedWidget != NULL
			if oClickedWidget != oFocusedWidget
				setFocus(oClickedWidget)
			ok

			oEvent = new TUIEvent(TUI_EVENT_MOUSE)
			oEvent.nX = nMouseX
			oEvent.nY = nMouseY
			oEvent.vData = vMouseData
			oEvent.oTarget = oClickedWidget
			oClickedWidget.handleEvent(oEvent)
		ok

	func handleTabContentClick nMouseX, nMouseY, vMouseData
		# Handle click inside tab control content area
		oPage = oTabControl.getActivePage()
		if oPage = NULL
			return
		ok

		# Find clicked control (reverse order for z-order)
		oClickedControl = NULL
		for nIndex = len(oPage.aChildren) to 1 step -1
			oChild = oPage.aChildren[nIndex]
			if oChild.lVisible
				if nMouseX >= oChild.nX and nMouseX < oChild.nX + oChild.nWidth
					if nMouseY >= oChild.nY and nMouseY < oChild.nY + oChild.nHeight
						oClickedControl = oChild
						exit
					ok
				ok
			ok
		next

		if oClickedControl != NULL
			# Set focus to this control
			setTabFocus(oClickedControl)

			# Pass mouse event to control
			oChildEvent = new TUIEvent(TUI_EVENT_MOUSE)
			oChildEvent.nX = nMouseX
			oChildEvent.nY = nMouseY
			oChildEvent.vData = true
			oClickedControl.handleEvent(oChildEvent)
			oClickedControl.draw()

			# Show cursor for text controls
			if ismethod(oClickedControl, "showCursor")
				oClickedControl.showCursor()
			ok

			# Update status
			if oStatusBar != NULL
				cCtrlName = controlName(oClickedControl)
				setStatus("Focused: " + cCtrlName + " - Use keyboard to interact")
			ok
		ok

	func controlName oWidget
		# Class name without the tui prefix (textbox, checkbox, etc.)
		cName = classname(oWidget)
		if left(cName, 3) = "tui" return substr(cName, 4) ok
		return cName

	func stop
		lRunning = false

	func focusNext
		if len(aWidgets) = 0
			return
		ok

		# Count focusable widgets
		nFocusableCount = 0
		for oWidget in aWidgets
			if oWidget.lFocusable and oWidget.lVisible
				nFocusableCount++
			ok
		next

		# If no focusable widgets, do nothing
		if nFocusableCount = 0
			return
		ok

		# Find first focusable widget if none focused
		if oFocusedWidget = NULL
			for oWidget in aWidgets
				if oWidget.lFocusable and oWidget.lVisible
					setFocus(oWidget)
					return
				ok
			next
			return
		ok

		# Find current index and next focusable widget
		nCurrentIndex = find(aWidgets, oFocusedWidget)
		if nCurrentIndex = 0
			nCurrentIndex = 1
		ok

		# Search for next focusable widget
		nNextIndex = nCurrentIndex
		nAttempts = 0
		while nAttempts < len(aWidgets)
			nNextIndex++
			if nNextIndex > len(aWidgets)
				nNextIndex = 1
			ok

			if aWidgets[nNextIndex].lFocusable and aWidgets[nNextIndex].lVisible
				setFocus(aWidgets[nNextIndex])
				return
			ok

			nAttempts++
		end

	func findWidgetAt nMouseX, nMouseY
		# Find which widget is at the given mouse coordinates
		for oWidget in aWidgets
			if isPointInWidget(oWidget, nMouseX, nMouseY)
				return oWidget
			ok
		next
		return NULL

	func isPointInWidget oWidget, nMouseX, nMouseY
		# Check if point (mx, my) is inside widget bounds
		if nMouseX >= oWidget.nX and nMouseX < oWidget.nX + oWidget.nWidth
			if nMouseY >= oWidget.nY and nMouseY < oWidget.nY + oWidget.nHeight
				return true
			ok
		ok
		return false

	# Helper method to draw all widgets
	func drawAll
		for oWidget in aWidgets
			if oWidget.lVisible
				oWidget.draw()
			ok
		next
		if oMenuBar != NULL
			oMenuBar.draw()
		ok
		if oTabControl != NULL
			oTabControl.draw()
		ok
		if oStatusBar != NULL
			oStatusBar.draw()
		ok
