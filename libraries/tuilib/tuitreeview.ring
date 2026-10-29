# Hierarchical tree control

class TUITreeView from TUIWidget

	aRootNodes = []
	aVisibleNodes = []      # Flattened list of visible nodes
	nSelectedIndex = 0      # Index in visibleNodes
	nScrollY = 0            # Scroll offset

	# Colors
	nNodeFgColor = WHITE       # White
	nNodeBgColor = BLACK        # Black
	nSelectedFgColor = BLACK    # Black
	nSelectedBgColor = LIGHTCYAN   # Cyan
	nExpanderFgColor = YELLOW   # Yellow

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		aRootNodes = []
		aVisibleNodes = []
		return self

	func addRootNode oNode
		oNode.nLevel = 0
		add(aRootNodes, ref(oNode))
		updateVisibleNodes()
		return oNode

	func addRootText cNewText
		oNode = new TUITreeNode(cNewText)
		oNode.nLevel = 0
		add(aRootNodes, ref(oNode))
		updateVisibleNodes()
		return oNode

	func updateVisibleNodes
		aVisibleNodes = []
		for nIndex = 1 to len(aRootNodes)
			addNodeToVisible(aRootNodes[nIndex])
		next

	func addNodeToVisible oNode
		add(aVisibleNodes, ref(oNode))
		if oNode.lExpanded and oNode.hasChildren()
			for nIndex = 1 to len(oNode.aChildren)
				addNodeToVisible(oNode.aChildren[nIndex])
			next
		ok

	func draw
		if not lVisible
			return
		ok

		# Draw border
		oKernel.setTermColor(GREY, nNodeBgColor)
		oKernel.drawRect(nX, nY, nWidth, nHeight)

		# Calculate visible area
		nVisibleHeight = nHeight - 2
		nContentWidth = nWidth - 2

		# Draw visible nodes
		for nIndex = 1 to nVisibleHeight
			nNodeIndex = nScrollY + nIndex
			nDrawY = nY + nIndex

			if nNodeIndex <= len(aVisibleNodes)
				oNode = aVisibleNodes[nNodeIndex]
				drawNode(oNode, nDrawY, nContentWidth, nNodeIndex = nSelectedIndex + 1)
			else
				# Clear empty line
				oKernel.setTermColor(nNodeFgColor, nNodeBgColor)
				oKernel.printAt(nX + 1, nDrawY, copy(" ", nContentWidth))
			ok
		next

		oKernel.resetTermColor()

	func drawNode oNode, nDrawY, nContentWidth, lSelected
		# Calculate indent based on level
		nIndent = oNode.nLevel * 2

		# Current X position
		nCurrentX = nX + 1

		# Draw indent spaces
		if nIndent > 0
			oKernel.setTermColor(nNodeFgColor, nNodeBgColor)
			oKernel.printAt(nCurrentX, nDrawY, copy(" ", nIndent))
			nCurrentX = nCurrentX + nIndent
		ok

		# Draw expander [+] or [-] or spaces
		oKernel.setTermColor(nExpanderFgColor, nNodeBgColor)
		if oNode.hasChildren()
			if oNode.lExpanded
				oKernel.printAt(nCurrentX, nDrawY, "[-]")
			else
				oKernel.printAt(nCurrentX, nDrawY, "[+]")
			ok
		else
			oKernel.printAt(nCurrentX, nDrawY, "   ")
		ok
		nCurrentX = nCurrentX + 3

		# Draw node text
		if lSelected
			oKernel.setTermColor(nSelectedFgColor, nSelectedBgColor)
		else
			oKernel.setTermColor(nNodeFgColor, nNodeBgColor)
		ok

		# Calculate available width for text
		nAvailableWidth = nContentWidth - nIndent - 3 - 1  # -1 for space before text
		cNodeText = " " + oNode.cText

		# Truncate or pad text
		if len(cNodeText) > nAvailableWidth
			cNodeText = substr(cNodeText, 1, nAvailableWidth)
		else
			cNodeText = cNodeText + copy(" ", nAvailableWidth - len(cNodeText))
		ok

		oKernel.printAt(nCurrentX, nDrawY, cNodeText)

	func drawNodeAtIndex nNodeIndex
		# Draw a single node at the given index (0-based)
		# Only draws if the node is currently visible on screen
		nVisibleHeight = nHeight - 2
		nContentWidth = nWidth - 2

		# Check if node is in visible range
		if nNodeIndex < nScrollY or nNodeIndex >= nScrollY + nVisibleHeight
			return
		ok

		# Calculate screen position
		nScreenRow = nNodeIndex - nScrollY + 1
		nDrawY = nY + nScreenRow

		if nNodeIndex < len(aVisibleNodes)
			oNode = aVisibleNodes[nNodeIndex + 1]
			drawNode(oNode, nDrawY, nContentWidth, nNodeIndex = nSelectedIndex)
		ok

		oKernel.resetTermColor()

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			return handleKeyboard(oEvent.nKey)
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			return handleMouse(oEvent.nX, oEvent.nY)
		ok

		return false

	func handleKeyboard nKey
		if len(aVisibleNodes) = 0
			return false
		ok

		# Up arrow
		if nKey = KEY_UP and nSelectedIndex > 0
			nOldIndex = nSelectedIndex
			nOldScrollY = nScrollY
			nSelectedIndex--
			adjustScroll()
			if nScrollY != nOldScrollY
				# Scrolling occurred, need full redraw
				draw()
			else
				# No scroll, just redraw old and new nodes
				drawNodeAtIndex(nOldIndex)
				drawNodeAtIndex(nSelectedIndex)
			ok
			return true
		ok

		# Down arrow
		if nKey = KEY_DOWN and nSelectedIndex < len(aVisibleNodes) - 1
			nOldIndex = nSelectedIndex
			nOldScrollY = nScrollY
			nSelectedIndex++
			adjustScroll()
			if nScrollY != nOldScrollY
				# Scrolling occurred, need full redraw
				draw()
			else
				# No scroll, just redraw old and new nodes
				drawNodeAtIndex(nOldIndex)
				drawNodeAtIndex(nSelectedIndex)
			ok
			return true
		ok

		# Left arrow - collapse or go to parent
		if nKey = KEY_LEFT
			oNode = aVisibleNodes[nSelectedIndex + 1]
			if oNode.lExpanded and oNode.hasChildren()
				oNode.collapse()
				updateVisibleNodes()
				draw()
			but oNode.oParent != NULL
				# Find parent in visible nodes - just selection change, no structure change
				nOldIndex = nSelectedIndex
				nOldScrollY = nScrollY
				for nIndex = 1 to len(aVisibleNodes)
					if aVisibleNodes[nIndex] = oNode.oParent
						nSelectedIndex = nIndex - 1
						adjustScroll()
						if nScrollY != nOldScrollY
							draw()
						else
							drawNodeAtIndex(nOldIndex)
							drawNodeAtIndex(nSelectedIndex)
						ok
						exit
					ok
				next
			ok
			return true
		ok

		# Right arrow - expand or go to first child
		if nKey = KEY_RIGHT
			oNode = aVisibleNodes[nSelectedIndex + 1]
			if oNode.hasChildren()
				if not oNode.lExpanded
					oNode.expand()
					updateVisibleNodes()
					draw()
				else
					# Go to first child - just selection change, no structure change
					nOldIndex = nSelectedIndex
					nOldScrollY = nScrollY
					nSelectedIndex++
					adjustScroll()
					if nScrollY != nOldScrollY
						draw()
					else
						drawNodeAtIndex(nOldIndex)
						drawNodeAtIndex(nSelectedIndex)
					ok
				ok
			ok
			return true
		ok

		# Enter or Space - toggle expand/collapse
		if nKey = 13 or nKey = 32 or nKey = KEY_ENTER or nKey = KEY_SPACE
			oNode = aVisibleNodes[nSelectedIndex + 1]
			if oNode.hasChildren()
				oNode.toggle()
				updateVisibleNodes()
				draw()
			ok
			return true
		ok

		# Home
		if nKey = KEY_HOME
			nSelectedIndex = 0
			adjustScroll()
			draw()
			return true
		ok

		# End
		if nKey = KEY_END
			nSelectedIndex = len(aVisibleNodes) - 1
			adjustScroll()
			draw()
			return true
		ok

		# Page Up
		if nKey = KEY_PGUP
			nVisibleHeight = nHeight - 2
			nSelectedIndex = nSelectedIndex - nVisibleHeight
			if nSelectedIndex < 0
				nSelectedIndex = 0
			ok
			adjustScroll()
			draw()
			return true
		ok

		# Page Down
		if nKey = KEY_PGDOWN
			nVisibleHeight = nHeight - 2
			nSelectedIndex = nSelectedIndex + nVisibleHeight
			if nSelectedIndex >= len(aVisibleNodes)
				nSelectedIndex = len(aVisibleNodes) - 1
			ok
			adjustScroll()
			draw()
			return true
		ok

		return false

	func handleMouse nMouseX, nMouseY
		# Check if click is inside tree
		if nMouseX < nX + 1 or nMouseX >= nX + nWidth - 1 or nMouseY < nY + 1 or nMouseY >= nY + nHeight - 1
			return false
		ok

		# Calculate which node was clicked
		nClickedLine = nMouseY - nY
		nClickedIndex = nScrollY + nClickedLine

		if nClickedIndex < 1 or nClickedIndex > len(aVisibleNodes)
			return false
		ok

		oNode = aVisibleNodes[nClickedIndex]

		# Calculate click position relative to node
		nIndent = oNode.nLevel * 2
		nExpanderStart = nX + 1 + nIndent
		nExpanderEnd = nExpanderStart + 3

		# Check if clicked on expander [+] or [-]
		if nMouseX >= nExpanderStart and nMouseX < nExpanderEnd and oNode.hasChildren()
			oNode.toggle()
			updateVisibleNodes()
			# Adjust selectedIndex if needed
			if nSelectedIndex >= len(aVisibleNodes)
				nSelectedIndex = len(aVisibleNodes) - 1
			ok
			draw()
			return true
		ok

		# Clicked on node text - select it
		nOldIndex = nSelectedIndex
		nSelectedIndex = nClickedIndex - 1
		# Only redraw the old and new selected nodes
		if nOldIndex != nSelectedIndex
			drawNodeAtIndex(nOldIndex)
			drawNodeAtIndex(nSelectedIndex)
		ok
		return true

	func adjustScroll
		nVisibleHeight = nHeight - 2

		# Scroll down if selected is below visible area
		if nSelectedIndex >= nScrollY + nVisibleHeight
			nScrollY = nSelectedIndex - nVisibleHeight + 1
		ok

		# Scroll up if selected is above visible area
		if nSelectedIndex < nScrollY
			nScrollY = nSelectedIndex
		ok

	func getSelectedNode
		if nSelectedIndex >= 0 and nSelectedIndex < len(aVisibleNodes)
			return aVisibleNodes[nSelectedIndex + 1]
		ok
		return NULL

	func expandAll
		for oNode in aRootNodes
			oNode.expandAll()
		next
		updateVisibleNodes()
		draw()

	func collapseAll
		for oNode in aRootNodes
			oNode.collapseAll()
		next
		updateVisibleNodes()
		if nSelectedIndex >= len(aVisibleNodes)
			nSelectedIndex = len(aVisibleNodes) - 1
		ok
		draw()
