# Drop-down style selector (cycles through the items)

class TUIComboBox from TUIWidget

	aItems = []
	nSelectedIndex = 1
	lExpanded = false

	func addItem cItem
		add(aItems, cItem)
		if nSelectedIndex = 0
			nSelectedIndex = 1
		ok
		# Don't auto-draw - let parent control handle drawing

	func draw
		if not lVisible
			return
		ok

		# Draw main box
		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)
		else
			oKernel.setTermColor(GREY, BLACK)
		ok

		# Don't draw if width is too small
		if nWidth < 5
			return
		ok

		cDisplayText = ""
		if nSelectedIndex > 0 and nSelectedIndex <= len(aItems)
			cDisplayText = aItems[nSelectedIndex]
		ok

		# Calculate inner width (excluding brackets and dropdown arrow)
		nInnerWidth = nWidth - 4
		if nInnerWidth < 1
			nInnerWidth = 1
		ok

		if len(cDisplayText) > nInnerWidth
			cDisplayText = substr(cDisplayText, 1, nInnerWidth)
		else
			cDisplayText = cDisplayText + copy(" ", nInnerWidth - len(cDisplayText))
		ok

		# Build full display and clip to width
		cFullDisplay = "[" + cDisplayText + " v]"
		if len(cFullDisplay) > nWidth
			cFullDisplay = substr(cFullDisplay, 1, nWidth)
		ok

		oKernel.printAt(nX, nY, cFullDisplay)
		oKernel.resetTermColor()

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			# Up arrow
			if oEvent.nKey = KEY_UP and nSelectedIndex > 1
				nSelectedIndex--
				draw()
				return true
			ok

			# Down arrow
			if oEvent.nKey = KEY_DOWN and nSelectedIndex < len(aItems)
				nSelectedIndex++
				draw()
				return true
			ok

			# Home key
			if oEvent.nKey = KEY_HOME and len(aItems) > 0
				nSelectedIndex = 1
				draw()
				return true
			ok

			# End key
			if oEvent.nKey = KEY_END and len(aItems) > 0
				nSelectedIndex = len(aItems)
				draw()
				return true
			ok

			# Enter or Space to toggle dropdown (future enhancement)
			if oEvent.nKey = 13 or oEvent.nKey = 32 or oEvent.nKey = KEY_ENTER or oEvent.nKey = KEY_SPACE
				# Could implement dropdown expansion here
				return true
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			nMouseX = oEvent.nX
			nMouseY = oEvent.nY

			# Check if click is within combobox bounds
			if nMouseX >= nX and nMouseX < nX + nWidth and nMouseY = nY
				# Click to cycle through items
				if nSelectedIndex < len(aItems)
					nSelectedIndex++
				else
					nSelectedIndex = 1
				ok
				draw()
				return true
			ok
		ok

		return false

	func getSelected
		if nSelectedIndex > 0 and nSelectedIndex <= len(aItems)
			return aItems[nSelectedIndex]
		ok
		return ""
