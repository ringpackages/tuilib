# Check box with a text

class TUICheckBox from TUIWidget

	lChecked = false

	func draw
		if not lVisible
			return
		ok

		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)
		else
			oKernel.setTermColor(GREY, BLACK)
		ok

		# Build the display text
		if lChecked
			cDisplayText = "[X] " + cText
		else
			cDisplayText = "[ ] " + cText
		ok

		# Clip to width
		if len(cDisplayText) > nWidth
			cDisplayText = substr(cDisplayText, 1, nWidth)
		ok

		# Pad to width to clear any previous content
		if len(cDisplayText) < nWidth
			cDisplayText = cDisplayText + copy(" ", nWidth - len(cDisplayText))
		ok

		oKernel.printAt(nX, nY, cDisplayText)

		oKernel.resetTermColor()

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			if oEvent.nKey = 32 or oEvent.nKey = 13 or oEvent.nKey = KEY_SPACE or oEvent.nKey = KEY_ENTER  # Space or Enter
				lChecked = not lChecked
				draw()
				return true
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			nMouseX = oEvent.nX
			nMouseY = oEvent.nY
			# Check if click is within checkbox bounds
			if nMouseX >= nX and nMouseX < nX + nWidth and nMouseY = nY
				lChecked = not lChecked
				draw()
				return true
			ok
		ok

		return false

	func setChecked lValue
		lChecked = lValue
		# Don't auto-draw - let parent control handle drawing
