# Scrollable list of items

class TUIListBox from TUIWidget

	aItems = []
	nSelectedIndex = 0
	nScrollOffset = 0      # Track scroll position separately

	func addItem cItem
		add(aItems, cItem)
		# Don't auto-draw - let parent control handle drawing

	func draw
		if not lVisible
			return
		ok

		# Don't draw if dimensions are too small
		if nWidth < 3 or nHeight < 3
			return
		ok

		# Draw border - manually to respect clipped dimensions
		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)  # Yellow when focused
		else
			oKernel.setTermColor(GREY, BLACK)   # Gray when not focused
		ok

		# Top border
		cTopLine = "+" + copy("-", nWidth - 2) + "+"
		oKernel.printAt(nX, nY, cTopLine)

		# Side borders and content area
		for nRow = 1 to nHeight - 2
			oKernel.printAt(nX, nY + nRow, "|")
			oKernel.printAt(nX + nWidth - 1, nY + nRow, "|")
		next

		# Bottom border
		cBottomLine = "+" + copy("-", nWidth - 2) + "+"
		oKernel.printAt(nX, nY + nHeight - 1, cBottomLine)

		# Draw items
		nDisplayCount = nHeight - 2

		# Update scroll offset to keep selected item visible
		adjustScrollOffset()

		for nIndex = 1 to nDisplayCount
			drawItemAtLine(nIndex)
		next

		oKernel.resetTermColor()

	func adjustScrollOffset
		nDisplayCount = nHeight - 2

		# Scroll down if selected item is below visible area
		if nSelectedIndex > nScrollOffset + nDisplayCount
			nScrollOffset = nSelectedIndex - nDisplayCount
		ok

		# Scroll up if selected item is above visible area
		if nSelectedIndex < nScrollOffset + 1 and nSelectedIndex > 0
			nScrollOffset = nSelectedIndex - 1
		ok

		# Ensure scrollOffset is valid
		if nScrollOffset < 0
			nScrollOffset = 0
		ok

	func drawItemAtLine nLineNum
		# Draw a single item at the given line number (1-based, relative to content area)
		nDisplayCount = nHeight - 2

		if nLineNum < 1 or nLineNum > nDisplayCount
			return
		ok

		nItemIndex = nScrollOffset + nLineNum
		nDrawY = nY + nLineNum

		if nItemIndex >= 1 and nItemIndex <= len(aItems)
			if nItemIndex = nSelectedIndex
				if lFocused
					oKernel.setTermColor(BLACK, GREY)  # Inverted when focused
				else
					oKernel.setTermColor(BLACK, CYAN)  # Dark cyan background when not focused
				ok
			else
				oKernel.setTermColor(WHITE, BLACK)
			ok

			cItemText = aItems[nItemIndex]
			if len(cItemText) > nWidth - 4
				cItemText = substr(cItemText, 1, nWidth - 4)
			else
				cItemText = cItemText + copy(" ", nWidth - 4 - len(cItemText))
			ok

			oKernel.printAt(nX + 2, nDrawY, cItemText)
		else
			# Clear empty line
			oKernel.setTermColor(WHITE, BLACK)
			oKernel.printAt(nX + 2, nDrawY, copy(" ", nWidth - 4))
		ok

		oKernel.resetTermColor()

	func drawItemAtIndex nItemIndex
		# Draw a single item by its index in the items list
		nDisplayCount = nHeight - 2

		# Check if item is visible
		if nItemIndex < nScrollOffset + 1 or nItemIndex > nScrollOffset + nDisplayCount
			return  # Item not visible
		ok

		nLineNum = nItemIndex - nScrollOffset
		drawItemAtLine(nLineNum)

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			nOldIndex = nSelectedIndex
			nOldScrollOffset = nScrollOffset

			# Up arrow
			if oEvent.nKey = KEY_UP and nSelectedIndex > 1
				nSelectedIndex--
				adjustScrollOffset()
				if nScrollOffset != nOldScrollOffset
					# Scrolling occurred, need full redraw
					draw()
				else
					# No scroll, just redraw old and new items
					drawItemAtIndex(nOldIndex)
					drawItemAtIndex(nSelectedIndex)
				ok
				return true
			ok

			# Down arrow
			if oEvent.nKey = KEY_DOWN and nSelectedIndex < len(aItems)
				nSelectedIndex++
				adjustScrollOffset()
				if nScrollOffset != nOldScrollOffset
					# Scrolling occurred, need full redraw
					draw()
				else
					# No scroll, just redraw old and new items
					drawItemAtIndex(nOldIndex)
					drawItemAtIndex(nSelectedIndex)
				ok
				return true
			ok

			# Home key
			if oEvent.nKey = KEY_HOME and len(aItems) > 0
				nSelectedIndex = 1
				adjustScrollOffset()
				if nScrollOffset != nOldScrollOffset
					draw()
				else
					drawItemAtIndex(nOldIndex)
					drawItemAtIndex(nSelectedIndex)
				ok
				return true
			ok

			# End key
			if oEvent.nKey = KEY_END and len(aItems) > 0
				nSelectedIndex = len(aItems)
				adjustScrollOffset()
				if nScrollOffset != nOldScrollOffset
					draw()
				else
					drawItemAtIndex(nOldIndex)
					drawItemAtIndex(nSelectedIndex)
				ok
				return true
			ok

			# Page Up
			if oEvent.nKey = KEY_PGUP
				nVisibleLines = nHeight - 2
				nSelectedIndex = nSelectedIndex - nVisibleLines
				if nSelectedIndex < 1
					nSelectedIndex = 1
				ok
				adjustScrollOffset()
				draw()  # Page operations always do full redraw
				return true
			ok

			# Page Down
			if oEvent.nKey = KEY_PGDOWN
				nVisibleLines = nHeight - 2
				nSelectedIndex = nSelectedIndex + nVisibleLines
				if nSelectedIndex > len(aItems)
					nSelectedIndex = len(aItems)
				ok
				adjustScrollOffset()
				draw()  # Page operations always do full redraw
				return true
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			# Click to select item
			nMouseX = oEvent.nX
			nMouseY = oEvent.nY

			# Check if click is inside the listbox
			if nMouseX < nX or nMouseX >= nX + nWidth or nMouseY < nY or nMouseY >= nY + nHeight
				return false  # Click outside listbox
			ok

			nDisplayCount = nHeight - 2

			# Calculate which line was clicked
			# y is the top border, y+1 is first item, y+2 is second item, etc.
			nClickedLine = nMouseY - nY

			# Lines 1 through displayCount contain items
			if nClickedLine >= 1 and nClickedLine <= nDisplayCount
				nClickedIndex = nScrollOffset + nClickedLine
				if nClickedIndex >= 1 and nClickedIndex <= len(aItems)
					if nClickedIndex != nSelectedIndex
						nOldIndex = nSelectedIndex
						nSelectedIndex = nClickedIndex
						# No scroll change on click, just redraw old and new items
						drawItemAtIndex(nOldIndex)
						drawItemAtIndex(nSelectedIndex)
					ok
					return true
				ok
			ok
		ok

		return false

	func getSelected
		if nSelectedIndex > 0 and nSelectedIndex <= len(aItems)
			return aItems[nSelectedIndex]
		ok
		return ""
