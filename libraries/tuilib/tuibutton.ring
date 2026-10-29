# Push button (Enter, Space or mouse click)

class TUIButton from TUIWidget

	cOnClick = NULL
	lPressed = false
	nNormalFgColor = BLACK      # Black text
	nNormalBgColor = GREY      # Light gray background
	nFocusedFgColor = WHITE    # White text
	nFocusedBgColor = LIGHTBLUE     # Light blue background
	nPressedFgColor = WHITE    # White text
	nPressedBgColor = BLUE     # Blue background

	func draw
		if not lVisible
			return
		ok

		# Determine colors based on state
		nFg = nNormalFgColor
		nBg = nNormalBgColor

		if lFocused and lPressed
			nFg = nPressedFgColor
			nBg = nPressedBgColor
		but lFocused
			nFg = nFocusedFgColor
			nBg = nFocusedBgColor
		ok

		if not lEnabled
			nFg = DARKGREY
			nBg = BLACK
		ok

		oKernel.setTermColor(nFg, nBg)

		# Center the text in the button
		cDisplayText = cText
		if len(cDisplayText) > nWidth - 4
			cDisplayText = substr(cDisplayText, 1, nWidth - 4)
		ok

		nPadding = (nWidth - len(cDisplayText)) / 2
		cPaddedText = copy(" ", floor(nPadding)) + cDisplayText + copy(" ", ceil(nPadding))

		# Ensure exact width
		if len(cPaddedText) < nWidth
			cPaddedText = cPaddedText + copy(" ", nWidth - len(cPaddedText))
		but len(cPaddedText) > nWidth
			cPaddedText = substr(cPaddedText, 1, nWidth)
		ok

		oKernel.printAt(nX, nY, cPaddedText)
		oKernel.resetTermColor()

	func handleEvent oEvent
		if not lEnabled
			return
		ok

		if oEvent.cType = TUI_EVENT_KEYBOARD
			# Enter or Space key (check both ASCII and RogueUtil constants)
			if oEvent.nKey = 13 or oEvent.nKey = 32 or oEvent.nKey = KEY_ENTER or oEvent.nKey = KEY_SPACE
				if not lPressed
					# Button press
					lPressed = true
					draw()
					oKernel.sleep(100)  # Visual feedback
					lPressed = false
					draw()

					# Call onClick handler if defined
					if cOnClick != NULL
						call cOnClick()
					ok
				ok
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			nMouseX = oEvent.nX
			nMouseY = oEvent.nY

			# Check if click is within button bounds
			if nMouseX >= nX and nMouseX < nX + nWidth and nMouseY = nY
				# Mouse click on button
				if not lPressed
					lPressed = true
					draw()
					oKernel.sleep(100)  # Visual feedback
					lPressed = false
					draw()

					# Call onClick handler if defined
					if cOnClick != NULL
						call cOnClick()
					ok
					return true
				ok
			ok
		ok

		return false

	func setOnClick cHandler
		cOnClick = cHandler
