# Single line text input

class TUITextBox from TUIWidget

	nMaxLength = 50
	nCursorPos = 0

	func draw
		if not lVisible
			return
		ok

		# Don't draw if width is too small
		if nWidth < 3
			return
		ok

		# Draw border
		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)  # Yellow when focused
		else
			oKernel.setTermColor(GREY, BLACK)   # Gray when not focused
		ok

		# Build the full display: [text...]
		nInnerWidth = nWidth - 2
		if nInnerWidth < 1
			nInnerWidth = 1
		ok

		cDisplayText = cText
		if len(cDisplayText) > nInnerWidth
			cDisplayText = substr(cDisplayText, 1, nInnerWidth)
		else
			cDisplayText = cDisplayText + copy(" ", nInnerWidth - len(cDisplayText))
		ok

		# Print as single line to ensure clipping
		cFullDisplay = "[" + cDisplayText + "]"
		if len(cFullDisplay) > nWidth
			cFullDisplay = substr(cFullDisplay, 1, nWidth)
		ok

		oKernel.printAt(nX, nY, cFullDisplay)

		# Show cursor if focused
		if lFocused
			showCursor()
		else
			oKernel.setCursorVisible(0)
		ok

		oKernel.resetTermColor()

	func showCursor
		# Position and show the cursor
		oKernel.gotoXY(nX + 1 + nCursorPos, nY)
		oKernel.setCursorVisible(1)

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			nKey = oEvent.nKey

			# Backspace
			if nKey = 8 and len(cText) > 0 and nCursorPos > 0
				cText = substr(cText, 1, nCursorPos - 1) + substr(cText, nCursorPos + 1)
				nCursorPos--
				draw()
				return true
			ok

			# Delete
			if nKey = KEY_DELETE and nCursorPos < len(cText)
				cText = substr(cText, 1, nCursorPos) + substr(cText, nCursorPos + 2)
				draw()
				return true
			ok

			# Left arrow
			if nKey = KEY_LEFT and nCursorPos > 0
				nCursorPos--
				showCursor()  # Just update cursor position, no full redraw
				return true
			ok

			# Right arrow
			if nKey = KEY_RIGHT and nCursorPos < len(cText)
				nCursorPos++
				showCursor()  # Just update cursor position, no full redraw
				return true
			ok

			# Home key
			if nKey = KEY_HOME
				nCursorPos = 0
				showCursor()  # Just update cursor position, no full redraw
				return true
			ok

			# End key
			if nKey = KEY_END
				nCursorPos = len(cText)
				showCursor()  # Just update cursor position, no full redraw
				return true
			ok

			# Regular character
			if nKey >= 32 and nKey <= 126 and len(cText) < nMaxLength
				cText = substr(cText, 1, nCursorPos) + char(nKey) + substr(cText, nCursorPos + 1)
				nCursorPos++
				draw()
				return true
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			nMouseX = oEvent.nX
			nMouseY = oEvent.nY

			# Check if click is within textbox bounds
			if nMouseX >= nX and nMouseX < nX + nWidth and nMouseY = nY
				# Click to position cursor
				# Calculate position within text (accounting for border)
				nRelativeX = nMouseX - nX - 1

				if nRelativeX >= 0 and nRelativeX <= len(cText)
					nCursorPos = nRelativeX
				else
					nCursorPos = len(cText)
				ok

				# Set focus and show cursor immediately
				lFocused = true
				draw()
				showCursor()  # Ensure cursor is visible after draw
				return true
			ok
		ok

		return false
