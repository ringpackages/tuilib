# Desktop that manages a stack of TUIManagedWindow objects

class TUIWindowManager

	oKernel = NULL
	aWindows = []               # List of windows (z-order: last = top)
	nActiveWindowIndex = 0      # Index of active window (0 = none)
	lRunning = false

	# Flag to request a full redraw in the next loop iteration
	lPendingFullRedraw = false

	# Desktop colors and pattern
	nDesktopBgColor = BLUE         # Blue desktop
	nDesktopFgColor = GREY
	cDesktopPattern = ""        # Optional pattern character (e.g., "░" or "▒")

	# Desktop widgets (drawn before windows)
	aDesktopWidgets = []

	# Callbacks
	cOnExit = NULL

	func init oTUIKernel
		oKernel = ref(oTUIKernel)
		aWindows = []
		aDesktopWidgets = []
		return self

	func requestFullRedraw
		lPendingFullRedraw = true

	func setDesktopPattern cPattern
		cDesktopPattern = cPattern
		return self

	func setDesktopColors nFg, nBg
		nDesktopFgColor = nFg
		nDesktopBgColor = nBg
		return self

	func addDesktopWidget oWidget
		add(aDesktopWidgets, ref(oWidget))
		return self

	func removeDesktopWidget oWidget
		nPos = find(aDesktopWidgets, oWidget)
		if nPos > 0
			del(aDesktopWidgets, nPos)
		ok
		return self

	func addWindow oWin
		oWin.oWindowManager = ref(self)
		oWin.lActive = false
		add(aWindows, ref(oWin))
		nActiveWindowIndex = len(aWindows)
		aWindows[nActiveWindowIndex].lActive = true
		return self

	func removeWindow oWin
		# Find and remove the window
		nPos = find(aWindows, oWin)
		if nPos > 0
			del(aWindows, nPos)

			# Update active window index
			if nPos = nActiveWindowIndex
				if len(aWindows) > 0
					nActiveWindowIndex = len(aWindows)
					aWindows[nActiveWindowIndex].lActive = true
				else
					nActiveWindowIndex = 0
				ok
			but nPos < nActiveWindowIndex
				nActiveWindowIndex = nActiveWindowIndex - 1
			ok
		ok
		return self

	func bringToFront nWinIndex
		if nWinIndex < 1 or nWinIndex > len(aWindows)
			return self
		ok

		if nWinIndex = nActiveWindowIndex
			return self  # Already at front
		ok

		# Deactivate current active window
		if nActiveWindowIndex > 0 and nActiveWindowIndex <= len(aWindows)
			aWindows[nActiveWindowIndex].lActive = false
		ok

		# Move window to end (top of z-order)
		if nWinIndex < len(aWindows)
			oTempWin = aWindows[nWinIndex]
			del(aWindows, nWinIndex)
			add(aWindows, ref(oTempWin))
		ok

		# Activate the window
		nActiveWindowIndex = len(aWindows)
		aWindows[nActiveWindowIndex].lActive = true

		return self

	func cycleWindows
		# Cycle to next window
		if len(aWindows) < 2
			return
		ok

		# Deactivate current
		if nActiveWindowIndex > 0 and nActiveWindowIndex <= len(aWindows)
			aWindows[nActiveWindowIndex].lActive = false
		ok

		# Move top window to bottom
		oTempWin = aWindows[len(aWindows)]
		del(aWindows, len(aWindows))
		insert(aWindows, 1, ref(oTempWin))

		# Activate new top window
		nActiveWindowIndex = len(aWindows)
		if nActiveWindowIndex > 0
			aWindows[nActiveWindowIndex].lActive = true
		ok

	func getActiveWindow
		if nActiveWindowIndex > 0 and nActiveWindowIndex <= len(aWindows)
			return aWindows[nActiveWindowIndex]
		ok
		return NULL

	func drawDesktop
		oKernel.setTermColor(nDesktopFgColor, nDesktopBgColor)

		# Fill screen with pattern or solid color
		if len(cDesktopPattern) > 0
			cClearLine = ""
			for nIndex = 1 to oKernel.getCols()
				cClearLine = cClearLine + cDesktopPattern
			next
		else
			cClearLine = copy(" ", oKernel.getCols())
		ok

		for nRow = 1 to oKernel.getRows()
			oKernel.printAt(1, nRow, cClearLine)
		next

	func drawDesktopWidgets
		# Draw all desktop widgets
		for oWidget in aDesktopWidgets
			if oWidget.lVisible
				oWidget.draw()
			ok
		next

	func drawAll
		drawDesktop()
		drawDesktopWidgets()

		# Draw windows bottom to top
		# Use local variable for count to avoid any reference issues
		nWindowCount = len(aWindows)
		for nIndex = 1 to nWindowCount
			oWin = aWindows[nIndex]
			if oWin.lVisible
				oWin.draw()
			ok
		next

		oKernel.resetTermColor()

	func clearRegion nRegionX, nRegionY, nRegionW, nRegionH
		# Clear a rectangular region with desktop background
		oKernel.setTermColor(nDesktopFgColor, nDesktopBgColor)

		if len(cDesktopPattern) > 0
			cClearLine = ""
			for nIndex = 1 to nRegionW
				cClearLine = cClearLine + cDesktopPattern
			next
		else
			cClearLine = copy(" ", nRegionW)
		ok

		for nRow = nRegionY to nRegionY + nRegionH - 1
			if nRow >= 1 and nRow <= oKernel.getRows()
				oKernel.printAt(nRegionX, nRow, cClearLine)
			ok
		next
		oKernel.resetTermColor()

	func redrawRegion nRegionX, nRegionY, nRegionW, nRegionH
		# Redraw all windows that intersect with the given region
		# First clear the region with desktop background
		clearRegion(nRegionX, nRegionY, nRegionW, nRegionH)

		# Draw desktop widgets that intersect with the region
		for oWidget in aDesktopWidgets
			if oWidget.lVisible
				if rectanglesIntersect(oWidget.nX, oWidget.nY, oWidget.nWidth, oWidget.nHeight, nRegionX, nRegionY, nRegionW, nRegionH)
					oWidget.draw()
				ok
			ok
		next

		# Draw windows bottom to top, but only if they intersect
		for nIndex = 1 to len(aWindows)
			oWin = aWindows[nIndex]
			if oWin.lVisible and not oWin.lMinimized
				if rectanglesIntersect(oWin.nX, oWin.nY, oWin.nWidth, oWin.nHeight, nRegionX, nRegionY, nRegionW, nRegionH)
					oWin.draw()
				ok
			ok
		next

		oKernel.resetTermColor()

	func rectanglesIntersect nX1, nY1, nW1, nH1, nX2, nY2, nW2, nH2
		# Check if two rectangles intersect
		if nX1 >= nX2 + nW2 or nX2 >= nX1 + nW1
			return false
		ok
		if nY1 >= nY2 + nH2 or nY2 >= nY1 + nH1
			return false
		ok
		return true

	func redrawWindowAndBelow nWinIndex
		# Redraw a window and all windows below it that might be affected
		if nWinIndex < 1 or nWinIndex > len(aWindows)
			return
		ok

		oWin = aWindows[nWinIndex]

		# Clear and redraw the region where this window is
		redrawRegion(oWin.nX, oWin.nY, oWin.nWidth, oWin.nHeight)

	func run
		lRunning = true

		# Initial draw
		drawAll()

		while lRunning
			lNeedFullRedraw = false
			oInput = oKernel.pollEvent()

			if oInput != NULL and oInput.cType = TUI_EVENT_KEYBOARD
				nKey = oInput.nKey

				# Global keys
				if nKey = 27 or nKey = KEY_ESCAPE
					# ESC - exit window manager
					lRunning = false
					loop
				ok

				# F12 to cycle windows
				if nKey = KEY_F12
					cycleWindows()
					lNeedFullRedraw = true
				ok

				# Pass to active window (including Tab key for control navigation)
				oActiveWin = getActiveWindow()
				if oActiveWin != NULL and nKey != KEY_F12
					oActiveWin.handleEvent(oInput)
					# Don't redraw entire window - the child's handleEvent already redraws itself
					# Only show cursor for text controls
					showFocusedChildCursor(oActiveWin)
				ok

			but oInput != NULL and oInput.cType = TUI_EVENT_MOUSE
				lNeedFullRedraw = handleMouseEvent(oInput)
			ok

			if lNeedFullRedraw or lPendingFullRedraw
				drawAll()
				lPendingFullRedraw = false
			ok

			# Ensure cursor is visible for focused text controls after all drawing
			oActiveWin = getActiveWindow()
			if oActiveWin != NULL
				showFocusedChildCursor(oActiveWin)
			ok

			if oInput = NULL
				oKernel.sleep(1)
			ok
		end
		oKernel.flush()

		if cOnExit != NULL
			call cOnExit()
		ok

	func handleMouseEvent oInput
		# Drag/resize the active window, or send a click to the window under the mouse
		# Returns true if the desktop needs a full redraw
		nMouseX = oInput.nX
		nMouseY = oInput.nY
		nAction = oInput.nAction
		oActiveWin = getActiveWindow()

		if oActiveWin != NULL and (oActiveWin.lDragging or oActiveWin.lResizing)
			if nAction = TUI_MOUSE_DRAG and oInput.nButton = TUI_BUTTON_LEFT
				# Save old bounds for smart redraw
				nOldX = oActiveWin.nX
				nOldY = oActiveWin.nY
				nOldW = oActiveWin.nWidth
				nOldH = oActiveWin.nHeight

				if oActiveWin.lDragging
					oActiveWin.updateDrag(nMouseX, nMouseY)
					if nOldX != oActiveWin.nX or nOldY != oActiveWin.nY
						# Redraw old position (what was underneath), then the window
						redrawRegion(nOldX, nOldY, nOldW, nOldH)
						oActiveWin.draw()
					ok
				else
					oActiveWin.updateResize(nMouseX, nMouseY)
					if nOldW != oActiveWin.nWidth or nOldH != oActiveWin.nHeight
						# Redraw the larger of old/new area, then the window
						redrawRegion(nOldX, nOldY, max(nOldW, oActiveWin.nWidth), max(nOldH, oActiveWin.nHeight))
						oActiveWin.draw()
					ok
				ok
			but nAction = TUI_MOUSE_RELEASE or nAction = TUI_MOUSE_MOVE or nAction = TUI_MOUSE_PRESS
				# Button released (a move without a button means the release was missed)
				oActiveWin.stopDrag()
				oActiveWin.stopResize()
				oActiveWin.draw()
			ok
			return false
		ok

		if nAction != TUI_MOUSE_PRESS or oInput.nButton != TUI_BUTTON_LEFT
			return false
		ok

		# Find the window under the mouse (top to bottom)
		lNeedFullRedraw = false
		for nIndex = len(aWindows) to 1 step -1
			oWin = aWindows[nIndex]
			if oWin.lVisible
				# Check if click is within window bounds
				if nMouseX >= oWin.nX and nMouseX < oWin.nX + oWin.nWidth and nMouseY >= oWin.nY and nMouseY < oWin.nY + oWin.nHeight
					# Bring clicked window to front if not already
					if nIndex != nActiveWindowIndex
						bringToFront(nIndex)
						lNeedFullRedraw = true
					ok

					# Handle the click
					oWin.handleEvent(oInput)

					# Only redraw if no full redraw is pending
					if not lNeedFullRedraw and not lPendingFullRedraw
						oWin.draw()
					ok

					exit
				ok
			ok
		next
		return lNeedFullRedraw

	func showFocusedChildCursor oWin
		# Find and show cursor for focused text control in window
		for oChild in oWin.aChildren
			if oChild.lFocused and ismethod(oChild, "showCursor")
				oChild.showCursor()
				return
			ok
		next

	func stop
		lRunning = false

	func setOnExit cHandler
		cOnExit = cHandler
		return self
