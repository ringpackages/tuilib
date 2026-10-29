# Drop-down/popup menu with items and nested submenus

class TUIMenu

	oKernel = NULL
	aItems = []             # List of TUIMenuItem objects
	nX = 0                  # Position X
	nY = 0                  # Position Y
	nWidth = 0              # Calculated width
	nHeight = 0             # Calculated height
	nSelectedIndex = 1      # Currently selected item (1-based)
	lVisible = false        # Is menu visible?
	oParent = NULL          # Parent menu (for submenus)
	oParentItem = NULL      # Parent TUIMenuItem that opened this submenu
	oActiveSubmenu = NULL   # Currently open submenu
	cTitle = ""             # Menu title (for menubar)

	# Colors
	nNormalFgColor = BLACK      # Black
	nNormalBgColor = GREY      # Light gray
	nSelectedFgColor = WHITE
	nSelectedBgColor = BLUE
	nDisabledFgColor = DARKGREY    # Dark gray
	nShortcutFgColor = DARKGREY    # Dark gray for shortcuts
	nBorderFgColor = BLACK      # Black border

	func init oTUIKernel
		oKernel = ref(oTUIKernel)
		return self

	func setTitle cNewTitle
		cTitle = cNewTitle
		return self

	func addItem oItem
		add(aItems, oItem)
		calculateSize()
		return self

	func addNormalItem cText, cHandler
		oItem = new TUIMenuItem(cText, TUI_MENUITEM_NORMAL)
		oItem.setOnClick(cHandler)
		add(aItems, oItem)
		calculateSize()
		return ref(aItems[len(aItems)])

	func addCheckboxItem cText, lChecked, cHandler
		oItem = new TUIMenuItem(cText, TUI_MENUITEM_CHECKBOX)
		oItem.setChecked(lChecked)
		oItem.setOnClick(cHandler)
		add(aItems, oItem)
		calculateSize()
		return ref(aItems[len(aItems)])

	func addSeparator
		oItem = new TUIMenuItem("", TUI_MENUITEM_SEPARATOR)
		add(aItems, oItem)
		calculateSize()
		return ref(aItems[len(aItems)])

	func addSubmenu cText, oSubmenu
		oItem = new TUIMenuItem(cText, TUI_MENUITEM_SUBMENU)
		oItem.setSubmenu(ref(oSubmenu))
		oSubmenu.oParent = ref(self)
		oSubmenu.oParentItem = oItem
		add(aItems, oItem)
		calculateSize()
		return ref(aItems[len(aItems)])

	func calculateSize
		# Calculate menu width based on items
		nMaxWidth = 0
		for oItem in aItems
			nSizeW = oItem.getDisplayWidth()
			if nSizeW > nMaxWidth
				nMaxWidth = nSizeW
			ok
		next
		nWidth = nMaxWidth + 4  # Add padding
		if nWidth < 10
			nWidth = 10
		ok

		# Calculate height
		nHeight = len(aItems) + 2  # Items + top/bottom border

	func setPosition nPosX, nPosY
		nX = nPosX
		nY = nPosY
		return self

	func show nPosX, nPosY
		nX = nPosX
		nY = nPosY
		lVisible = true
		nSelectedIndex = 1
		# Skip to first non-separator item
		while nSelectedIndex <= len(aItems) and aItems[nSelectedIndex].cItemType = TUI_MENUITEM_SEPARATOR
			nSelectedIndex++
		end
		draw()

	func hide
		if not lVisible
			return
		ok
		lVisible = false
		if oActiveSubmenu != NULL
			oActiveSubmenu.hide()
			oActiveSubmenu = NULL
		ok
		# Clear the menu area by drawing spaces
		clear()

	func clear
		# Clear the area where the menu was drawn
		# First clear the region with the default background color
		oKernel.clearRegion(nX, nY, nWidth, nHeight)
		# Only redraw widgets if this is a top-level menu (no parent)
		# Submenus should not trigger widget redraw as parent menus are still visible
		if oParent = NULL and len(oKernel.aScreenWidgets) > 0
			oKernel.redrawRegion(nX, nY, nWidth, nHeight)
		ok

	func draw
		if not lVisible
			return
		ok

		# Use simple ASCII characters for maximum compatibility
		# + for corners, - for horizontal, | for vertical

		oKernel.setTermColor(nBorderFgColor, nNormalBgColor)

		# Build and draw top border: +----+
		cTopBorder = "+"
		for nIndex = 1 to nWidth - 2
			cTopBorder = cTopBorder + "-"
		next
		cTopBorder = cTopBorder + "+"
		oKernel.printAt(nX, nY, cTopBorder)

		# Draw each item
		for nIndex = 1 to len(aItems)
			oItem = aItems[nIndex]
			drawItem(nIndex, oItem)
		next

		# Build and draw bottom border: +----+
		cBottomBorder = "+"
		for nIndex = 1 to nWidth - 2
			cBottomBorder = cBottomBorder + "-"
		next
		cBottomBorder = cBottomBorder + "+"
		oKernel.printAt(nX, nY + len(aItems) + 1, cBottomBorder)

		oKernel.resetTermColor()

	func drawItem nItemIndex, oItem
		nPosY = nY + nItemIndex
		nContentWidth = nWidth - 2  # Minus left and right borders

		# Determine colors based on selection state
		if nItemIndex = nSelectedIndex
			nFg = nSelectedFgColor
			nBg = nSelectedBgColor
		else
			if oItem.lEnabled
				nFg = nNormalFgColor
			else
				nFg = nDisabledFgColor
			ok
			nBg = nNormalBgColor
		ok

		if oItem.cItemType = TUI_MENUITEM_SEPARATOR
			# Draw separator line: +----+
			oKernel.setTermColor(nBorderFgColor, nNormalBgColor)
			cSepLine = "+"
			for nIndex = 1 to nWidth - 2
				cSepLine = cSepLine + "-"
			next
			cSepLine = cSepLine + "+"
			oKernel.printAt(nX, nPosY, cSepLine)
		else
			# Build the complete line: |content|

			# Start with left border
			oKernel.setTermColor(nBorderFgColor, nNormalBgColor)
			oKernel.printAt(nX, nPosY, "|")

			# Build content text
			cDisplayText = ""

			# Checkbox prefix
			if oItem.cItemType = TUI_MENUITEM_CHECKBOX
				if oItem.lChecked
					cDisplayText = "[X] "
				else
					cDisplayText = "[ ] "
				ok
			ok

			# Add item text
			cDisplayText = cDisplayText + oItem.cText

			# Calculate remaining space
			nTextLen = len(cDisplayText)

			# Handle submenu arrow or shortcut
			if oItem.cItemType = TUI_MENUITEM_SUBMENU
				# Add arrow at end
				cArrowText = " >"
				nPadding = nContentWidth - nTextLen - len(cArrowText)
				if nPadding > 0
					cDisplayText = cDisplayText + copy(" ", nPadding) + cArrowText
				else
					cDisplayText = cDisplayText + cArrowText
				ok
			but len(oItem.cShortcut) > 0
				# Add shortcut at end
				nPadding = nContentWidth - nTextLen - len(oItem.cShortcut)
				if nPadding > 0
					cDisplayText = cDisplayText + copy(" ", nPadding) + oItem.cShortcut
				else
					cDisplayText = cDisplayText + " " + oItem.cShortcut
				ok
			else
				# Just pad to fill width
				if nTextLen < nContentWidth
					cDisplayText = cDisplayText + copy(" ", nContentWidth - nTextLen)
				ok
			ok

			# Truncate if too long
			if len(cDisplayText) > nContentWidth
				cDisplayText = substr(cDisplayText, 1, nContentWidth)
			ok

			# Ensure exact width by padding if needed
			if len(cDisplayText) < nContentWidth
				cDisplayText = cDisplayText + copy(" ", nContentWidth - len(cDisplayText))
			ok

			# Print content with proper colors
			oKernel.setTermColor(nFg, nBg)
			oKernel.printAt(nX + 1, nPosY, cDisplayText)

			# Draw right border
			oKernel.setTermColor(nBorderFgColor, nNormalBgColor)
			oKernel.printAt(nX + nWidth - 1, nPosY, "|")
		ok

	func handleKeyboard nKey
		if not lVisible
			return false
		ok

		# If submenu is active, let it handle keys first
		if oActiveSubmenu != NULL
			if oActiveSubmenu.handleKeyboard(nKey)
				return true
			ok
		ok

		# Up arrow
		if nKey = KEY_UP
			movePrevious()
			return true
		ok

		# Down arrow
		if nKey = KEY_DOWN
			moveNext()
			return true
		ok

		# Left arrow - close submenu or go to parent
		if nKey = KEY_LEFT
			if oActiveSubmenu != NULL
				oActiveSubmenu.hide()
				oActiveSubmenu = NULL
				draw()
				return true
			but oParent != NULL
				# Close this menu and return to parent
				return false  # Let parent handle it
			ok
		ok

		# Right arrow - open submenu
		if nKey = KEY_RIGHT
			if nSelectedIndex >= 1 and nSelectedIndex <= len(aItems)
				oItem = aItems[nSelectedIndex]
				if oItem.cItemType = TUI_MENUITEM_SUBMENU and oItem.lEnabled
					openSubmenu(oItem)
					return true
				ok
			ok
		ok

		# Enter or Space - activate item
		if nKey = 13 or nKey = KEY_ENTER or nKey = 32 or nKey = KEY_SPACE
			if nSelectedIndex >= 1 and nSelectedIndex <= len(aItems)
				oItem = aItems[nSelectedIndex]
				if oItem.lEnabled
					if oItem.cItemType = TUI_MENUITEM_SUBMENU
						openSubmenu(oItem)
					but oItem.cItemType = TUI_MENUITEM_CHECKBOX
						oItem.toggle()
						draw()
						if oItem.cOnClick != NULL
							call oItem.cOnClick(oItem)
						ok
					but oItem.cItemType = TUI_MENUITEM_NORMAL
						if oItem.cOnClick != NULL
							call oItem.cOnClick(oItem)
						ok
						return false  # Signal to close menu
					ok
				ok
			ok
			return true
		ok

		# Escape - close menu
		if nKey = 27 or nKey = KEY_ESCAPE
			if oActiveSubmenu != NULL
				oActiveSubmenu.hide()
				oActiveSubmenu = NULL
				draw()
			else
				return false  # Signal to close this menu
			ok
			return true
		ok

		return false

	func handleMouse nMouseX, nMouseY, lClicking
		if not lVisible
			return false
		ok

		# Check if click is in active submenu first
		if oActiveSubmenu != NULL
			if oActiveSubmenu.handleMouse(nMouseX, nMouseY, lClicking)
				return true
			ok
		ok

		# Check if mouse is in this menu
		if nMouseX >= nX and nMouseX < nX + nWidth and nMouseY > nY and nMouseY < nY + nHeight - 1
			# Calculate which item was clicked
			nItemIndex = nMouseY - nY
			if nItemIndex >= 1 and nItemIndex <= len(aItems)
				oItem = aItems[nItemIndex]

				if oItem.cItemType != TUI_MENUITEM_SEPARATOR
					# Hover - change selection
					if nSelectedIndex != nItemIndex
						# Close any open submenu when moving to different item
						if oActiveSubmenu != NULL
							oActiveSubmenu.hide()
							oActiveSubmenu = NULL
						ok
						nSelectedIndex = nItemIndex
						draw()

						# Auto-open submenu on hover
						if oItem.cItemType = TUI_MENUITEM_SUBMENU and oItem.lEnabled
							openSubmenu(oItem)
						ok
					ok

					# Click
					if lClicking and oItem.lEnabled
						if oItem.cItemType = TUI_MENUITEM_SUBMENU
							if oActiveSubmenu = NULL
								openSubmenu(oItem)
							ok
						but oItem.cItemType = TUI_MENUITEM_CHECKBOX
							oItem.toggle()
							draw()
							if oItem.cOnClick != NULL
								call oItem.cOnClick(oItem)
							ok
						but oItem.cItemType = TUI_MENUITEM_NORMAL
							if oItem.cOnClick != NULL
								call oItem.cOnClick(oItem)
							ok
							return false  # Signal to close menu hierarchy
						ok
					ok
				ok
				return true
			ok
		ok

		return false

	func openSubmenu oItem
		if oItem.oSubmenu != NULL
			# Close any existing submenu
			if oActiveSubmenu != NULL
				oActiveSubmenu.hide()
			ok

			# Position submenu to the right of this menu
			nSubX = nX + nWidth - 1
			nSubY = nY + find(aItems, oItem)

			# Adjust if would go off screen
			if nSubX + oItem.oSubmenu.nWidth > oKernel.getCols()
				nSubX = nX - oItem.oSubmenu.nWidth + 1
			ok

			oItem.oSubmenu.show(nSubX, nSubY)
			oActiveSubmenu = oItem.oSubmenu
		ok

	func moveNext
		if len(aItems) = 0
			return
		ok

		nStartIndex = nSelectedIndex
		nSelectedIndex++

		# Skip separators
		while nSelectedIndex <= len(aItems) and aItems[nSelectedIndex].cItemType = TUI_MENUITEM_SEPARATOR
			nSelectedIndex++
		end

		# Wrap around
		if nSelectedIndex > len(aItems)
			nSelectedIndex = 1
			while nSelectedIndex <= len(aItems) and aItems[nSelectedIndex].cItemType = TUI_MENUITEM_SEPARATOR
				nSelectedIndex++
			end
		ok

		# If we went full circle, stay at start
		if nSelectedIndex > len(aItems)
			nSelectedIndex = nStartIndex
		ok

		draw()

	func movePrevious
		if len(aItems) = 0
			return
		ok

		nStartIndex = nSelectedIndex
		nSelectedIndex--

		# Skip separators
		while nSelectedIndex >= 1 and aItems[nSelectedIndex].cItemType = TUI_MENUITEM_SEPARATOR
			nSelectedIndex--
		end

		# Wrap around
		if nSelectedIndex < 1
			nSelectedIndex = len(aItems)
			while nSelectedIndex >= 1 and aItems[nSelectedIndex].cItemType = TUI_MENUITEM_SEPARATOR
				nSelectedIndex--
			end
		ok

		# If we went full circle, stay at start
		if nSelectedIndex < 1
			nSelectedIndex = nStartIndex
		ok

		draw()

	func getItemAt nItemIndex
		if nItemIndex >= 1 and nItemIndex <= len(aItems)
			return aItems[nItemIndex]
		ok
		return NULL

	func getItemById cIDValue
		for oItem in aItems
			if oItem.cID = cIDValue
				return oItem
			ok
		next
		return NULL

	func getSelectedItem
		if nSelectedIndex >= 1 and nSelectedIndex <= len(aItems)
			return aItems[nSelectedIndex]
		ok
		return NULL

	func closeAllSubmenus
		if oActiveSubmenu != NULL
			oActiveSubmenu.closeAllSubmenus()
			oActiveSubmenu.hide()
			oActiveSubmenu = NULL
		ok

	func getDeepestActiveMenu
		# Returns the deepest active submenu in the chain
		if oActiveSubmenu != NULL
			return oActiveSubmenu.getDeepestActiveMenu()
		ok
		return self

	func moveNextDeep
		# Move to next item in the deepest active menu
		if oActiveSubmenu != NULL
			oActiveSubmenu.moveNextDeep()
		else
			moveNext()
		ok

	func movePreviousDeep
		# Move to previous item in the deepest active menu
		if oActiveSubmenu != NULL
			oActiveSubmenu.movePreviousDeep()
		else
			movePrevious()
		ok

	func activateSelectedDeep
		# Activate the selected item in the deepest active menu
		# Returns "close" if menu should close, "stay" otherwise
		if oActiveSubmenu != NULL
			return oActiveSubmenu.activateSelectedDeep()
		ok

		if nSelectedIndex >= 1 and nSelectedIndex <= len(aItems)
			oItem = aItems[nSelectedIndex]
			if oItem.lEnabled
				if oItem.cItemType = TUI_MENUITEM_SUBMENU
					openSubmenu(oItem)
					return "stay"
				but oItem.cItemType = TUI_MENUITEM_CHECKBOX
					oItem.toggle()
					draw()
					if oItem.cOnClick != NULL
						call oItem.cOnClick(oItem)
					ok
					return "stay"
				but oItem.cItemType = TUI_MENUITEM_NORMAL
					if oItem.cOnClick != NULL
						call oItem.cOnClick(oItem)
					ok
					return "close"
				ok
			ok
		ok
		return "stay"

	func handleMouseDeep nMouseX, nMouseY, lClicking
		# Handle mouse in this menu or any submenu
		# Returns "close" to close hierarchy, "handled" if handled, "outside" if click was outside

		# First check submenus (deepest first)
		if oActiveSubmenu != NULL
			cResult = oActiveSubmenu.handleMouseDeep(nMouseX, nMouseY, lClicking)
			if cResult != "outside"
				return cResult
			ok
		ok

		# Check if mouse is in this menu (including borders)
		# Menu occupies: y (top border), y+1 to y+len(items) (items), y+len(items)+1 (bottom border)
		if nMouseX >= nX and nMouseX < nX + nWidth and nMouseY >= nY and nMouseY <= nY + nHeight - 1
			# Calculate which item (items start at y+1)
			nItemIndex = nMouseY - nY
			if nItemIndex >= 1 and nItemIndex <= len(aItems)
				oItem = aItems[nItemIndex]

				if oItem.cItemType != TUI_MENUITEM_SEPARATOR
					# Update selection
					if nSelectedIndex != nItemIndex
						# Close any open submenu when moving to different item
						if oActiveSubmenu != NULL
							oActiveSubmenu.closeAllSubmenus()
							oActiveSubmenu.hide()
							oActiveSubmenu = NULL
						ok
						nSelectedIndex = nItemIndex
						draw()

						# Auto-open submenu on hover
						if oItem.cItemType = TUI_MENUITEM_SUBMENU and oItem.lEnabled
							openSubmenu(oItem)
						ok
					ok

					# Handle click
					if lClicking and oItem.lEnabled
						if oItem.cItemType = TUI_MENUITEM_SUBMENU
							if oActiveSubmenu = NULL
								openSubmenu(oItem)
							ok
							return "handled"
						but oItem.cItemType = TUI_MENUITEM_CHECKBOX
							oItem.toggle()
							draw()
							if oItem.cOnClick != NULL
								call oItem.cOnClick(oItem)
							ok
							return "handled"
						but oItem.cItemType = TUI_MENUITEM_NORMAL
							if oItem.cOnClick != NULL
								call oItem.cOnClick(oItem)
							ok
							return "close"
						ok
					ok
				ok
				return "handled"
			ok
			# Click on border area - still inside menu
			return "handled"
		ok

		return "outside"
