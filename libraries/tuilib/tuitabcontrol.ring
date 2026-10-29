# Tabbed pages control

class TUITabControl from TUIWidget

	aPages = []
	nActivePageIndex = 1

	# Colors
	nTabFgColor = BLACK         # Black
	nTabBgColor = GREY         # Light gray
	nActiveTabFgColor = WHITE  # White
	nActiveTabBgColor = BLUE   # Blue
	nContentFgColor = WHITE    # White
	nContentBgColor = BLACK     # Black
	nBorderFgColor = GREY      # Light gray

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		aPages = []
		return self

	func addPage cTitle
		oPage = new TUITabPage(cTitle)
		add(aPages, ref(oPage))
		if len(aPages) = 1
			nActivePageIndex = 1
		ok
		return oPage

	func removePage nPageIndex
		if nPageIndex >= 1 and nPageIndex <= len(aPages)
			del(aPages, nPageIndex)
			if nActivePageIndex > len(aPages)
				nActivePageIndex = len(aPages)
			ok
			if nActivePageIndex < 1 and len(aPages) > 0
				nActivePageIndex = 1
			ok
		ok

	func setActivePage nPageIndex
		if nPageIndex >= 1 and nPageIndex <= len(aPages)
			nActivePageIndex = nPageIndex
			draw()
		ok

	func nextPage
		if len(aPages) = 0
			return
		ok
		nActivePageIndex++
		if nActivePageIndex > len(aPages)
			nActivePageIndex = 1  # Wrap around
		ok
		draw()

	func previousPage
		if len(aPages) = 0
			return
		ok
		nActivePageIndex--
		if nActivePageIndex < 1
			nActivePageIndex = len(aPages)  # Wrap around
		ok
		draw()

	func getActivePage
		if nActivePageIndex >= 1 and nActivePageIndex <= len(aPages)
			return aPages[nActivePageIndex]
		ok
		return NULL

	func draw
		if not lVisible
			return
		ok

		# Draw tab bar
		drawTabs()

		# Draw content area border
		drawContentArea()

		# Draw active page children
		drawActivePageChildren()

		oKernel.resetTermColor()

	func drawTabs
		oKernel.setTermColor(nTabFgColor, nTabBgColor)

		# Draw tab bar background
		cTabBarLine = copy(" ", nWidth)
		oKernel.printAt(nX, nY, cTabBarLine)

		# Draw each tab
		nCurrentX = nX
		for nIndex = 1 to len(aPages)
			oPage = aPages[nIndex]
			cTabText = " " + oPage.cTitle + " "

			if nIndex = nActivePageIndex
				oKernel.setTermColor(nActiveTabFgColor, nActiveTabBgColor)
			else
				oKernel.setTermColor(nTabFgColor, nTabBgColor)
			ok

			oKernel.printAt(nCurrentX, nY, cTabText)
			nCurrentX = nCurrentX + len(cTabText)

			# Draw separator
			oKernel.setTermColor(nTabFgColor, nTabBgColor)
			if nCurrentX < nX + nWidth
				oKernel.printAt(nCurrentX, nY, "|")
				nCurrentX++
			ok
		next

		# Fill rest of tab bar
		if nCurrentX < nX + nWidth
			oKernel.setTermColor(nTabFgColor, nTabBgColor)
			oKernel.printAt(nCurrentX, nY, copy(" ", nX + nWidth - nCurrentX))
		ok

	func drawContentArea
		oKernel.setTermColor(nBorderFgColor, nContentBgColor)

		# Draw border around content area (below tabs)
		# Top line
		cTopLine = "+"
		for nIndex = 1 to nWidth - 2
			cTopLine = cTopLine + "-"
		next
		cTopLine = cTopLine + "+"
		oKernel.printAt(nX, nY + 1, cTopLine)

		# Side borders and content fill
		cContentLine = copy(" ", nWidth - 2)
		for nRow = nY + 2 to nY + nHeight - 2
			oKernel.printAt(nX, nRow, "|")
			oKernel.setTermColor(nContentFgColor, nContentBgColor)
			oKernel.printAt(nX + 1, nRow, cContentLine)
			oKernel.setTermColor(nBorderFgColor, nContentBgColor)
			oKernel.printAt(nX + nWidth - 1, nRow, "|")
		next

		# Bottom line
		cBottomLine = "+"
		for nIndex = 1 to nWidth - 2
			cBottomLine = cBottomLine + "-"
		next
		cBottomLine = cBottomLine + "+"
		oKernel.printAt(nX, nY + nHeight - 1, cBottomLine)

	func drawActivePageChildren
		if nActivePageIndex < 1 or nActivePageIndex > len(aPages)
			return
		ok

		# First, hide all children from all pages
		for nPage = 1 to len(aPages)
			oTabPage = aPages[nPage]
			for nChild = 1 to len(oTabPage.aChildren)
				oTabPage.aChildren[nChild].lVisible = false
			next
		next

		oPage = aPages[nActivePageIndex]

		# Content area starts at (x + 1, y + 2)
		nContentX = nX + 1
		nContentY = nY + 2
		nContentWidth = nWidth - 2
		nContentHeight = nHeight - 3

		# Update positions and draw children of active page
		for nIndex = 1 to len(oPage.aChildren)
			oChild = oPage.aChildren[nIndex]
			oChild.nX = nContentX + oPage.aChildRelX[nIndex]
			oChild.nY = nContentY + oPage.aChildRelY[nIndex]

			# Only draw if within content area
			if oChild.nY >= nContentY and oChild.nY < nContentY + nContentHeight
				if oChild.nX >= nContentX and oChild.nX < nContentX + nContentWidth
					oChild.lVisible = true
					oChild.draw()
				ok
			ok
		next

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			return handleKeyboard(oEvent.nKey)
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			return handleMouse(oEvent.nX, oEvent.nY)
		ok

		return false

	func handleKeyboard nKey
		# Ctrl+Tab or Tab to switch tabs (simplified: just use left/right)
		# Left arrow - previous tab
		if nKey = KEY_LEFT and nActivePageIndex > 1
			nActivePageIndex--
			draw()
			return true
		ok

		# Right arrow - next tab
		if nKey = KEY_RIGHT and nActivePageIndex < len(aPages)
			nActivePageIndex++
			draw()
			return true
		ok

		# Home - first tab
		if nKey = KEY_HOME and len(aPages) > 0
			nActivePageIndex = 1
			draw()
			return true
		ok

		# End - last tab
		if nKey = KEY_END and len(aPages) > 0
			nActivePageIndex = len(aPages)
			draw()
			return true
		ok

		# Pass keyboard events to active page children
		oPage = getActivePage()
		if oPage != NULL
			for oChild in oPage.aChildren
				if oChild.lFocused
					oChildEvent = new TUIEvent(TUI_EVENT_KEYBOARD)
					oChildEvent.nKey = nKey
					if oChild.handleEvent(oChildEvent)
						return true
					ok
				ok
			next
		ok

		return false

	func handleMouse nMouseX, nMouseY
		# Check if click is on tab bar
		if nMouseY = nY
			return handleTabClick(nMouseX)
		ok

		# Check if click is in content area
		if nMouseX > nX and nMouseX < nX + nWidth - 1 and nMouseY > nY + 1 and nMouseY < nY + nHeight - 1
			return handleContentClick(nMouseX, nMouseY)
		ok

		return false

	func handleTabClick nMouseX
		# Find which tab was clicked
		nCurrentX = nX
		for nIndex = 1 to len(aPages)
			oPage = aPages[nIndex]
			cTabText = " " + oPage.cTitle + " "
			nTabEnd = nCurrentX + len(cTabText)

			if nMouseX >= nCurrentX and nMouseX < nTabEnd
				if nIndex != nActivePageIndex
					nActivePageIndex = nIndex
					draw()
				ok
				return true
			ok

			nCurrentX = nTabEnd + 1  # +1 for separator
		next

		return false

	func handleContentClick nMouseX, nMouseY
		oPage = getActivePage()
		if oPage = NULL
			return false
		ok

		# Pass click to children
		for nIndex = len(oPage.aChildren) to 1 step -1
			oChild = oPage.aChildren[nIndex]
			if oChild.lVisible
				oChildEvent = new TUIEvent(TUI_EVENT_MOUSE)
				oChildEvent.nX = nMouseX
				oChildEvent.nY = nMouseY
				oChildEvent.vData = true
				if oChild.handleEvent(oChildEvent)
					return true
				ok
			ok
		next

		return true  # Consume click in content area
