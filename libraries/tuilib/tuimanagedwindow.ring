# Movable, resizable window with minimize, maximize and close buttons

class TUIManagedWindow from TUIWidget

	cTitle = ""
	aChildren = []              # Child widgets
	aChildRelX = []             # Relative X positions
	aChildRelY = []             # Relative Y positions

	# Window state
	lMaximized = false
	lMinimized = false
	lDragging = false
	lResizing = false
	nDragOffsetX = 0
	nDragOffsetY = 0
	cResizeEdge = ""            # "right", "bottom", "corner"

	# Saved state for restore
	nSavedX = 0
	nSavedY = 0
	nSavedWidth = 0
	nSavedHeight = 0

	# Minimum size
	nMinWidth = 20
	nMinHeight = 6

	# Window controls (buttons in title bar)
	lShowMinimize = true
	lShowMaximize = true
	lShowClose = true

	# Colors
	nTitleFgColor = WHITE          # White
	nTitleBgColor = BLUE           # Blue
	nActiveTitleBgColor = BLUE     # Blue when active
	nInactiveTitleBgColor = DARKGREY   # Dark gray when inactive
	nBorderFgColor = GREY          # Light gray
	nBorderBgColor = BLACK          # Black
	nContentBgColor = BLACK         # Black background for content

	# Callbacks
	cOnClose = NULL
	cOnMinimize = NULL
	cOnMaximize = NULL
	cOnRestore = NULL
	cOnMove = NULL
	cOnResize = NULL

	# Active state
	lActive = false

	# Parent window manager
	oWindowManager = NULL

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH, cNewTitle
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		cTitle = cNewTitle
		nSavedX = nPosX
		nSavedY = nPosY
		nSavedWidth = nSizeW
		nSavedHeight = nSizeH
		aChildren = []
		aChildRelX = []
		aChildRelY = []
		return self

	func setTitle cNewTitle
		cTitle = cNewTitle
		return self

	func setActive lFlag
		lActive = lFlag
		return self

	func addChild oWidget, nRelX, nRelY
		# Add child with position relative to window content area
		add(aChildren, ref(oWidget))
		add(aChildRelX, nRelX)
		add(aChildRelY, nRelY)
		# Set initial position
		oWidget.nX = nX + 1 + nRelX
		oWidget.nY = nY + 2 + nRelY
		return self

	func removeChild oWidget
		for nIndex = 1 to len(aChildren)
			if aChildren[nIndex] = oWidget
				del(aChildren, nIndex)
				del(aChildRelX, nIndex)
				del(aChildRelY, nIndex)
				exit
			ok
		next
		return self

	func updateChildPositions
		# Update all children to their correct absolute positions
		nContentX = nX + 1
		nContentY = nY + 2

		for nIndex = 1 to len(aChildren)
			aChildren[nIndex].nX = nContentX + aChildRelX[nIndex]
			aChildren[nIndex].nY = nContentY + aChildRelY[nIndex]
		next

	func draw
		if not lVisible
			return
		ok

		if lMinimized
			drawMinimized()
			return
		ok

		# Draw window border and background
		drawBorder()

		# Draw title bar
		drawTitleBar()

		# Draw content area background
		drawContentArea()

		# Update child positions and draw them
		updateChildPositions()
		drawChildren()

		oKernel.resetTermColor()

	func drawBorder
		oKernel.setTermColor(nBorderFgColor, nBorderBgColor)

		# Top border
		cTopLine = "+"
		for nIndex = 1 to nWidth - 2
			cTopLine = cTopLine + "-"
		next
		cTopLine = cTopLine + "+"
		oKernel.printAt(nX, nY, cTopLine)

		# Side borders
		for nRow = nY + 1 to nY + nHeight - 2
			oKernel.printAt(nX, nRow, "|")
			oKernel.printAt(nX + nWidth - 1, nRow, "|")
		next

		# Bottom border with resize corner hint
		cBottomLine = "+"
		for nIndex = 1 to nWidth - 3
			cBottomLine = cBottomLine + "-"
		next
		cBottomLine = cBottomLine + "=#"  # Resize corner indicator
		oKernel.printAt(nX, nY + nHeight - 1, cBottomLine)

	func drawTitleBar
		# Title bar background
		if lActive
			oKernel.setTermColor(nTitleFgColor, nActiveTitleBgColor)
		else
			oKernel.setTermColor(nTitleFgColor, nInactiveTitleBgColor)
		ok

		# Build title bar content
		nTitleBarWidth = nWidth - 2

		# Window control buttons (right side): [_] [O] [X]
		nControlsWidth = 0
		cControls = ""
		if lShowMinimize
			cControls = cControls + "[_]"
			nControlsWidth = nControlsWidth + 3
		ok
		if lShowMaximize
			if lMaximized
				cControls = cControls + "[o]"  # Restore button
			else
				cControls = cControls + "[O]"  # Maximize button
			ok
			nControlsWidth = nControlsWidth + 3
		ok
		if lShowClose
			cControls = cControls + "[X]"
			nControlsWidth = nControlsWidth + 3
		ok

		# Calculate title display
		nAvailableWidth = nTitleBarWidth - nControlsWidth - 1
		cDisplayTitle = " " + cTitle
		if len(cDisplayTitle) > nAvailableWidth
			cDisplayTitle = substr(cDisplayTitle, 1, nAvailableWidth - 3) + "..."
		ok

		# Pad title
		nPadding = nTitleBarWidth - len(cDisplayTitle) - nControlsWidth
		if nPadding < 0
			nPadding = 0
		ok

		cTitleBar = cDisplayTitle + copy(" ", nPadding) + cControls

		# Ensure exact width
		if len(cTitleBar) < nTitleBarWidth
			cTitleBar = cTitleBar + copy(" ", nTitleBarWidth - len(cTitleBar))
		ok
		if len(cTitleBar) > nTitleBarWidth
			cTitleBar = substr(cTitleBar, 1, nTitleBarWidth)
		ok

		oKernel.printAt(nX + 1, nY + 1, cTitleBar)

	func drawContentArea
		oKernel.setTermColor(WHITE, nContentBgColor)

		# Fill content area
		cContentLine = copy(" ", nWidth - 2)
		for nRow = nY + 2 to nY + nHeight - 2
			oKernel.printAt(nX + 1, nRow, cContentLine)
		next

	func drawChildren
		# Content area bounds
		nContentLeft = nX + 1
		nContentTop = nY + 2
		nContentRight = nX + nWidth - 1
		nContentBottom = nY + nHeight - 2
		nContentWidth = nWidth - 2
		nContentHeight = nHeight - 3

		for nIndex = 1 to len(aChildren)
			oChild = aChildren[nIndex]

			# Check if child Y position is within content area
			if oChild.nY < nContentTop or oChild.nY > nContentBottom
				oChild.lVisible = false
				loop
			ok

			# Check if child X position starts within content area
			if oChild.nX < nContentLeft or oChild.nX >= nContentRight
				oChild.lVisible = false
				loop
			ok

			# Save original dimensions
			nOriginalWidth = oChild.nWidth
			nOriginalHeight = oChild.nHeight

			# Calculate how much of the child fits in the content area (width)
			nAvailableWidth = nContentRight - oChild.nX
			if oChild.nX + oChild.nWidth > nContentRight
				oChild.nWidth = nAvailableWidth
			ok

			# Calculate how much of the child fits in the content area (height)
			nAvailableHeight = nContentBottom - oChild.nY + 1
			if oChild.nY + oChild.nHeight > nContentBottom + 1
				oChild.nHeight = nAvailableHeight
			ok

			# Only draw if there's space
			if oChild.nWidth > 0 and oChild.nHeight > 0
				oChild.lVisible = true
				oChild.draw()
			else
				oChild.lVisible = false
			ok

			# Restore original dimensions
			oChild.nWidth = nOriginalWidth
			oChild.nHeight = nOriginalHeight
		next

	func drawMinimized
		# Draw minimized window (just title bar)
		oKernel.setTermColor(nTitleFgColor, nInactiveTitleBgColor)

		nBarWidth = len(cTitle) + 12
		if nBarWidth < 20
			nBarWidth = 20
		ok

		cMinBar = "[" + cTitle
		if len(cMinBar) > nBarWidth - 8
			cMinBar = substr(cMinBar, 1, nBarWidth - 11) + "..."
		ok
		cMinBar = cMinBar + copy(" ", nBarWidth - len(cMinBar) - 5) + "][O]"

		oKernel.printAt(nX, nY, cMinBar)

	func handleEvent oEvent
		if not lVisible
			return false
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			return handleMouse(oEvent.nX, oEvent.nY, oEvent.vData)
		ok

		if oEvent.cType = TUI_EVENT_KEYBOARD
			return handleKeyboard(oEvent.nKey)
		ok

		return false

	func handleMouse nMouseX, nMouseY, lClicking
		if not lVisible
			return false
		ok

		if lMinimized
			return handleMinimizedMouse(nMouseX, nMouseY, lClicking)
		ok

		# Check if click is within window bounds
		if nMouseX < nX or nMouseX >= nX + nWidth or nMouseY < nY or nMouseY >= nY + nHeight
			return false
		ok

		# Note: TUIWindowManager handles bringing window to front

		# Check title bar clicks (y + 1 is title bar row)
		if nMouseY = nY + 1 and lClicking
			return handleTitleBarClick(nMouseX)
		ok

		# Check resize corner (bottom-right)
		if nMouseY = nY + nHeight - 1 and nMouseX >= nX + nWidth - 2 and lClicking
			startResize("corner")
			return true
		ok

		# Check right edge for resize
		if nMouseX = nX + nWidth - 1 and nMouseY > nY + 1 and nMouseY < nY + nHeight - 1 and lClicking
			startResize("right")
			return true
		ok

		# Check bottom edge for resize
		if nMouseY = nY + nHeight - 1 and nMouseX > nX and nMouseX < nX + nWidth - 2 and lClicking
			startResize("bottom")
			return true
		ok

		# Content area bounds
		nContentLeft = nX + 1
		nContentTop = nY + 2
		nContentRight = nX + nWidth - 1
		nContentBottom = nY + nHeight - 2

		# Check if click is in content area
		if nMouseX < nContentLeft or nMouseX >= nContentRight or nMouseY < nContentTop or nMouseY > nContentBottom
			return true  # Click on border, consume but don't pass to children
		ok

		# Update child positions first (important after resize!)
		updateChildPositions()

		# Unfocus all children first
		for oChild in aChildren
			if oChild.lFocused
				oChild.lFocused = false

				# Save and clip dimensions before drawing
				nOriginalWidth = oChild.nWidth
				nOriginalHeight = oChild.nHeight

				nAvailableWidth = nContentRight - oChild.nX
				if nAvailableWidth > 0 and oChild.nWidth > nAvailableWidth
					oChild.nWidth = nAvailableWidth
				ok

				nAvailableHeight = nContentBottom - oChild.nY + 1
				if nAvailableHeight > 0 and oChild.nHeight > nAvailableHeight
					oChild.nHeight = nAvailableHeight
				ok

				# Draw with clipped dimensions
				if oChild.nWidth > 0 and oChild.nHeight > 0
					oChild.draw()
				ok

				# Restore original dimensions
				oChild.nWidth = nOriginalWidth
				oChild.nHeight = nOriginalHeight
			ok
		next

		# Pass to children (reverse order for z-order)
		for nIndex = len(aChildren) to 1 step -1
			oChild = aChildren[nIndex]
			if oChild.lVisible
				# Check if click is within THIS child's bounds
				if nMouseX >= oChild.nX and nMouseX < oChild.nX + oChild.nWidth and nMouseY >= oChild.nY and nMouseY < oChild.nY + oChild.nHeight
					# Also check if the click point is within content area
					if nMouseX >= nContentLeft and nMouseX < nContentRight and nMouseY >= nContentTop and nMouseY <= nContentBottom
						# Focus this child
						oChild.lFocused = true

						# Save original dimensions and clip BEFORE handleEvent
						# This ensures any draw() calls within handleEvent use clipped dimensions
						nOriginalWidth = oChild.nWidth
						nOriginalHeight = oChild.nHeight

						# Clip width
						nAvailableWidth = nContentRight - oChild.nX
						if nAvailableWidth > 0 and oChild.nWidth > nAvailableWidth
							oChild.nWidth = nAvailableWidth
						ok

						# Clip height
						nAvailableHeight = nContentBottom - oChild.nY + 1
						if nAvailableHeight > 0 and oChild.nHeight > nAvailableHeight
							oChild.nHeight = nAvailableHeight
						ok

						# Create and pass the event (child may draw itself)
						oChildEvent = new TUIEvent(TUI_EVENT_MOUSE)
						oChildEvent.nX = nMouseX
						oChildEvent.nY = nMouseY
						oChildEvent.vData = lClicking
						oChild.handleEvent(oChildEvent)

						# Restore original dimensions
						oChild.nWidth = nOriginalWidth
						oChild.nHeight = nOriginalHeight

						# Show cursor for text input controls
						if ismethod(oChild, "showCursor")
							oChild.showCursor()
						ok

						return true
					ok
				ok
			ok
		next

		return true  # Consume click within window

	func drawChildClipped oChild, nContentLeft, nContentTop, nContentRight, nContentBottom
		# Draw a child with proper clipping to content area
		# contentRight is the X position of the right border (exclusive)
		# contentBottom is the Y position of the bottom border (exclusive for content)

		if oChild.nY < nContentTop or oChild.nY > nContentBottom
			return
		ok
		if oChild.nX < nContentLeft or oChild.nX >= nContentRight
			return
		ok

		# Save original dimensions
		nOriginalWidth = oChild.nWidth
		nOriginalHeight = oChild.nHeight

		# Clip width - contentRight is exclusive (the border column)
		nAvailableWidth = nContentRight - oChild.nX
		if nAvailableWidth < 1
			return
		ok
		if oChild.nWidth > nAvailableWidth
			oChild.nWidth = nAvailableWidth
		ok

		# Clip height - contentBottom is the last valid content row
		nAvailableHeight = nContentBottom - oChild.nY + 1
		if nAvailableHeight < 1
			return
		ok
		if oChild.nHeight > nAvailableHeight
			oChild.nHeight = nAvailableHeight
		ok

		# Draw if there's space
		if oChild.nWidth > 0 and oChild.nHeight > 0
			oChild.draw()
		ok

		# Restore original dimensions
		oChild.nWidth = nOriginalWidth
		oChild.nHeight = nOriginalHeight

	func handleTitleBarClick nMouseX
		# Calculate button positions (from right)
		nButtonX = nX + nWidth - 2

		if lShowClose
			if nMouseX >= nButtonX - 2 and nMouseX <= nButtonX
				close()
				return true
			ok
			nButtonX = nButtonX - 3
		ok

		if lShowMaximize
			if nMouseX >= nButtonX - 2 and nMouseX <= nButtonX
				if lMaximized
					restore()
				else
					maximize()
				ok
				return true
			ok
			nButtonX = nButtonX - 3
		ok

		if lShowMinimize
			if nMouseX >= nButtonX - 2 and nMouseX <= nButtonX
				minimize()
				return true
			ok
			nButtonX = nButtonX - 3
		ok

		# Click on title area - start dragging
		startDrag(nMouseX, nY + 1)
		return true

	func handleMinimizedMouse nMouseX, nMouseY, lClicking
		# Check if click is on minimized bar
		nBarWidth = len(cTitle) + 12
		if nBarWidth < 20
			nBarWidth = 20
		ok

		if nMouseY = nY and nMouseX >= nX and nMouseX < nX + nBarWidth and lClicking
			# Check restore button [O]
			if nMouseX >= nX + nBarWidth - 4 and nMouseX <= nX + nBarWidth - 2
				restore()
				return true
			ok
			# Click anywhere else - also restore
			restore()
			return true
		ok

		return false

	func handleKeyboard nKey
		# Content area bounds for clipping
		nContentRight = nX + nWidth - 1
		nContentBottom = nY + nHeight - 2

		# Handle Tab key for navigating between children
		if nKey = 9 and len(aChildren) > 0  # Tab key
			focusNextChild()
			return true
		ok

		# Pass keyboard to children
		for oChild in aChildren
			if oChild.lFocused
				# Save and clip dimensions before event handling
				nOriginalWidth = oChild.nWidth
				nOriginalHeight = oChild.nHeight

				nAvailableWidth = nContentRight - oChild.nX
				if nAvailableWidth > 0 and oChild.nWidth > nAvailableWidth
					oChild.nWidth = nAvailableWidth
				ok

				nAvailableHeight = nContentBottom - oChild.nY + 1
				if nAvailableHeight > 0 and oChild.nHeight > nAvailableHeight
					oChild.nHeight = nAvailableHeight
				ok

				# Handle the event (child may draw itself)
				oChildEvent = new TUIEvent(TUI_EVENT_KEYBOARD)
				oChildEvent.nKey = nKey
				lHandled = oChild.handleEvent(oChildEvent)

				# Restore original dimensions
				oChild.nWidth = nOriginalWidth
				oChild.nHeight = nOriginalHeight

				if lHandled
					return true
				ok
			ok
		next

		return false

	func focusNextChild
		# Navigate to next focusable child control using Tab
		if len(aChildren) = 0
			return
		ok

		# Count focusable children
		nFocusableCount = 0
		for oChild in aChildren
			if oChild.lFocusable and oChild.lVisible
				nFocusableCount++
			ok
		next

		# If no focusable children, do nothing
		if nFocusableCount = 0
			return
		ok

		# Content area bounds for clipping when drawing
		nContentLeft = nX + 1
		nContentTop = nY + 2
		nContentRight = nX + nWidth - 1
		nContentBottom = nY + nHeight - 2

		# Find current focused index
		nCurrentIndex = 0
		for nIndex = 1 to len(aChildren)
			if aChildren[nIndex].lFocused
				nCurrentIndex = nIndex
				exit
			ok
		next

		# Unfocus current child
		if nCurrentIndex > 0
			aChildren[nCurrentIndex].lFocused = false
			drawChildClipped(aChildren[nCurrentIndex], nContentLeft, nContentTop, nContentRight, nContentBottom)
		ok

		# Find next focusable child (skip non-focusable ones like TUILabel)
		nNextIndex = nCurrentIndex
		nAttempts = 0
		while nAttempts < len(aChildren)
			nNextIndex++
			if nNextIndex > len(aChildren)
				nNextIndex = 1
			ok

			# Check if this child is focusable
			if aChildren[nNextIndex].lFocusable and aChildren[nNextIndex].lVisible
				exit
			ok

			nAttempts++
		end

		# Focus next focusable child
		aChildren[nNextIndex].lFocused = true
		drawChildClipped(aChildren[nNextIndex], nContentLeft, nContentTop, nContentRight, nContentBottom)

		# Show cursor if it's a text control
		if ismethod(aChildren[nNextIndex], "showCursor")
			aChildren[nNextIndex].showCursor()
		ok

	func startDrag nMouseX, nMouseY
		if lMaximized
			return  # Can't drag maximized window
		ok
		lDragging = true
		nDragOffsetX = nMouseX - nX
		nDragOffsetY = nMouseY - nY

	func updateDrag nMouseX, nMouseY
		if not lDragging
			return
		ok

		nNewX = nMouseX - nDragOffsetX
		nNewY = nMouseY - nDragOffsetY

		# Keep window on screen
		if nNewX < 1
			nNewX = 1
		ok
		if nNewY < 1
			nNewY = 1
		ok
		if nNewX + nWidth > oKernel.getCols()
			nNewX = oKernel.getCols() - nWidth
		ok
		if nNewY + nHeight > oKernel.getRows()
			nNewY = oKernel.getRows() - nHeight
		ok

		nX = nNewX
		nY = nNewY

		if cOnMove != NULL
			call cOnMove(self)
		ok

	func stopDrag
		lDragging = false

	func startResize cEdge
		if lMaximized
			return  # Can't resize maximized window
		ok
		lResizing = true
		cResizeEdge = cEdge

	func updateResize nMouseX, nMouseY
		if not lResizing
			return
		ok

		nNewWidth = nWidth
		nNewHeight = nHeight

		if cResizeEdge = "right" or cResizeEdge = "corner"
			nNewWidth = nMouseX - nX + 1
		ok

		if cResizeEdge = "bottom" or cResizeEdge = "corner"
			nNewHeight = nMouseY - nY + 1
		ok

		# Enforce minimum size
		if nNewWidth < nMinWidth
			nNewWidth = nMinWidth
		ok
		if nNewHeight < nMinHeight
			nNewHeight = nMinHeight
		ok

		# Keep on screen
		if nX + nNewWidth > oKernel.getCols()
			nNewWidth = oKernel.getCols() - nX
		ok
		if nY + nNewHeight > oKernel.getRows()
			nNewHeight = oKernel.getRows() - nY
		ok

		nWidth = nNewWidth
		nHeight = nNewHeight

		if cOnResize != NULL
			call cOnResize(self)
		ok

	func stopResize
		lResizing = false

	func minimize
		if lMinimized
			return
		ok

		# Save old bounds for redraw
		nOldX = nX
		nOldY = nY
		nOldW = nWidth
		nOldH = nHeight
		lWasMaximized = lMaximized

		# Save current state if not maximized
		if not lMaximized
			nSavedX = nX
			nSavedY = nY
			nSavedWidth = nWidth
			nSavedHeight = nHeight
		ok

		lMinimized = true
		lMaximized = false  # Clear maximized state when minimizing

		# Request redraw of old area from window manager
		if oWindowManager != NULL
			oWindowManager.redrawRegion(nOldX, nOldY, nOldW, nOldH)
		ok

		if cOnMinimize != NULL
			call cOnMinimize(self)
		ok

	func maximize
		if lMaximized
			return
		ok

		# Save current state
		if not lMinimized
			nSavedX = nX
			nSavedY = nY
			nSavedWidth = nWidth
			nSavedHeight = nHeight
		ok

		lMinimized = false
		lMaximized = true

		# Fill screen (leave room for edges)
		nX = 1
		nY = 1
		nWidth = oKernel.getCols() - 1
		nHeight = oKernel.getRows() - 1

		if cOnMaximize != NULL
			call cOnMaximize(self)
		ok

	func restore
		lMinimized = false
		lMaximized = false

		nX = nSavedX
		nY = nSavedY
		nWidth = nSavedWidth
		nHeight = nSavedHeight

		# Request a full redraw from window manager
		if oWindowManager != NULL
			oWindowManager.requestFullRedraw()
		ok

		if cOnRestore != NULL
			call cOnRestore(self)
		ok

	func close
		lVisible = false

		if cOnClose != NULL
			call cOnClose(self)
		ok

		if oWindowManager != NULL
			oWindowManager.removeWindow(self)
			oWindowManager.requestFullRedraw()
		ok

	func setOnClose cHandler
		cOnClose = cHandler
		return self

	func setOnMinimize cHandler
		cOnMinimize = cHandler
		return self

	func setOnMaximize cHandler
		cOnMaximize = cHandler
		return self

	func setOnRestore cHandler
		cOnRestore = cHandler
		return self

	func setOnMove cHandler
		cOnMove = cHandler
		return self

	func setOnResize cHandler
		cOnResize = cHandler
		return self

	func getContentX
		return nX + 1

	func getContentY
		return nY + 2

	func getContentWidth
		return nWidth - 2

	func getContentHeight
		return nHeight - 3
