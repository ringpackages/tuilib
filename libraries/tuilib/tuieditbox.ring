# Multi-line text editor

class TUIEditBox from TUIWidget

	aLines = []
	nCursorX = 0  # Column position in current line
	nCursorY = 0  # Line number
	nScrollY = 0  # Vertical scroll offset
	nMaxLength = 1000  # Max chars per line
	lEnterMovesDown = true  # If true, Enter moves to next line; if false, creates new line

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		aLines = [""]
		return self

	func setText cValue
		# Split text into lines
		aLines = split(cValue, nl)
		if len(aLines) = 0
			aLines = [""]
		ok
		nCursorX = 0
		nCursorY = 0
		nScrollY = 0
		# Don't auto-draw - let parent control handle drawing

	func getText
		cResult = ""
		for nIndex = 1 to len(aLines)
			cResult = cResult + aLines[nIndex]
			if nIndex < len(aLines)
				cResult = cResult + nl
			ok
		next
		return cResult

	func draw
		if not lVisible
			return
		ok

		# Draw border
		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)  # Yellow when focused
		else
			oKernel.setTermColor(GREY, BLACK)   # Gray when not focused
		ok

		oKernel.drawRect(nX, nY, nWidth, nHeight)

		# Draw text content
		nVisibleLines = nHeight - 2
		for nIndex = 1 to nVisibleLines
			drawLineAt(nIndex)
		next

		# Show cursor if focused
		if lFocused
			showCursor()
		else
			oKernel.setCursorVisible(0)
		ok

		oKernel.resetTermColor()

	func drawLineAt nVisibleLineNum
		# Draw a single line at the given visible line number (1-based)
		if nVisibleLineNum < 1 or nVisibleLineNum > nHeight - 2
			return
		ok

		oKernel.setTermColor(WHITE, BLACK)

		nLineIndex = nScrollY + nVisibleLineNum
		cDisplayText = ""

		if nLineIndex <= len(aLines)
			cDisplayText = aLines[nLineIndex]
			if len(cDisplayText) > nWidth - 4
				cDisplayText = substr(cDisplayText, 1, nWidth - 4)
			else
				cDisplayText = cDisplayText + copy(" ", nWidth - 4 - len(cDisplayText))
			ok
		else
			cDisplayText = copy(" ", nWidth - 4)
		ok

		oKernel.printAt(nX + 2, nY + nVisibleLineNum, cDisplayText)
		oKernel.resetTermColor()

	func drawLineAtIndex nLineIndex
		# Draw a line by its index in the lines array (0-based)
		nVisibleLines = nHeight - 2

		# Check if line is visible
		if nLineIndex < nScrollY or nLineIndex >= nScrollY + nVisibleLines
			return  # Line not visible
		ok

		nVisibleLineNum = nLineIndex - nScrollY + 1
		drawLineAt(nVisibleLineNum)

	func showCursor
		# Position and show the cursor
		nVisibleLines = nHeight - 2
		nVisibleCursorY = nCursorY - nScrollY
		if nVisibleCursorY >= 0 and nVisibleCursorY < nVisibleLines
			oKernel.gotoXY(nX + 2 + nCursorX, nY + 1 + nVisibleCursorY)
			oKernel.setCursorVisible(1)
		ok

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			nKey = oEvent.nKey
			nOldScrollY = nScrollY

			# Backspace
			if nKey = 8
				if nCursorX > 0
					# Delete character in current line
					cCurrentLine = aLines[nCursorY + 1]
					aLines[nCursorY + 1] = substr(cCurrentLine, 1, nCursorX - 1) + substr(cCurrentLine, nCursorX + 1)
					nCursorX--
					drawLineAtIndex(nCursorY)  # Only redraw current line
					showCursor()
				but nCursorY > 0
					# Join with previous line - needs full redraw
					cPrevLine = aLines[nCursorY]
					cCurrentLine = aLines[nCursorY + 1]
					nCursorX = len(cPrevLine)
					aLines[nCursorY] = cPrevLine + cCurrentLine
					del(aLines, nCursorY + 1)
					nCursorY--
					adjustScroll()
					draw()
				ok
				return true
			ok

			# Delete
			if nKey = KEY_DELETE
				cCurrentLine = aLines[nCursorY + 1]
				if nCursorX < len(cCurrentLine)
					aLines[nCursorY + 1] = substr(cCurrentLine, 1, nCursorX) + substr(cCurrentLine, nCursorX + 2)
					drawLineAtIndex(nCursorY)  # Only redraw current line
					showCursor()
				but nCursorY < len(aLines) - 1
					# Join with next line - needs full redraw
					cNextLine = aLines[nCursorY + 2]
					aLines[nCursorY + 1] = cCurrentLine + cNextLine
					del(aLines, nCursorY + 2)
					draw()
				ok
				return true
			ok

			# Enter/Return - move to next line or create new line
			if nKey = 13 or nKey = KEY_ENTER
				if lEnterMovesDown
					# Move to next line (create if doesn't exist)
					if nCursorY < len(aLines) - 1
						nCursorY++
						nCursorX = 0
					else
						# Add new empty line at end
						add(aLines, "")
						nCursorY++
						nCursorX = 0
					ok
					adjustScroll()
					if nScrollY != nOldScrollY
						draw()
					else
						showCursor()
					ok
				else
					# Create new line and split current line - needs full redraw
					cCurrentLine = aLines[nCursorY + 1]
					cLeftPart = substr(cCurrentLine, 1, nCursorX)
					cRightPart = substr(cCurrentLine, nCursorX + 1)
					aLines[nCursorY + 1] = cLeftPart
					insert(aLines, nCursorY + 2, cRightPart)
					nCursorY++
					nCursorX = 0
					adjustScroll()
					draw()
				ok
				return true
			ok

			# Up arrow
			if nKey = KEY_UP and nCursorY > 0
				nCursorY--
				# Adjust cursorX if new line is shorter
				if nCursorX > len(aLines[nCursorY + 1])
					nCursorX = len(aLines[nCursorY + 1])
				ok
				adjustScroll()
				if nScrollY != nOldScrollY
					draw()
				else
					showCursor()  # Just move cursor, no redraw needed
				ok
				return true
			ok

			# Down arrow
			if nKey = KEY_DOWN
				if nCursorY < len(aLines) - 1
					nCursorY++
					# Adjust cursorX if new line is shorter
					if nCursorX > len(aLines[nCursorY + 1])
						nCursorX = len(aLines[nCursorY + 1])
					ok
				else
					# At last line, add new line and move to it
					add(aLines, "")
					nCursorY++
					nCursorX = 0
				ok
				adjustScroll()
				if nScrollY != nOldScrollY
					draw()
				else
					showCursor()  # Just move cursor, no redraw needed
				ok
				return true
			ok

			# Left arrow
			if nKey = KEY_LEFT
				if nCursorX > 0
					nCursorX--
					showCursor()  # Just move cursor, no redraw needed
				but nCursorY > 0
					# Move to end of previous line
					nCursorY--
					nCursorX = len(aLines[nCursorY + 1])
					adjustScroll()
					if nScrollY != nOldScrollY
						draw()
					else
						showCursor()
					ok
				ok
				return true
			ok

			# Right arrow
			if nKey = KEY_RIGHT
				cCurrentLine = aLines[nCursorY + 1]
				if nCursorX < len(cCurrentLine)
					nCursorX++
					showCursor()  # Just move cursor, no redraw needed
				else
					# At end of line
					if nCursorY < len(aLines) - 1
						# Move to beginning of next line
						nCursorY++
						nCursorX = 0
					else
						# At end of last line, add new line
						add(aLines, "")
						nCursorY++
						nCursorX = 0
					ok
					adjustScroll()
					if nScrollY != nOldScrollY
						draw()
					else
						showCursor()
					ok
				ok
				return true
			ok

			# Home key
			if nKey = KEY_HOME
				nCursorX = 0
				showCursor()  # Just move cursor, no redraw needed
				return true
			ok

			# End key
			if nKey = KEY_END
				nCursorX = len(aLines[nCursorY + 1])
				showCursor()  # Just move cursor, no redraw needed
				return true
			ok

			# Regular character
			if nKey >= 32 and nKey <= 126
				cCurrentLine = aLines[nCursorY + 1]
				if len(cCurrentLine) < nMaxLength
					aLines[nCursorY + 1] = substr(cCurrentLine, 1, nCursorX) + char(nKey) + substr(cCurrentLine, nCursorX + 1)
					nCursorX++
					drawLineAtIndex(nCursorY)  # Only redraw current line
					showCursor()
				ok
				return true
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			# Click to position cursor
			nMouseX = oEvent.nX
			nMouseY = oEvent.nY

			# Calculate position within edit box
			nRelativeX = nMouseX - nX - 2  # Account for border (2 chars)
			nRelativeY = nMouseY - nY - 1  # Account for border (1 line)

			# Calculate actual line based on scroll
			nClickedLine = nScrollY + nRelativeY

			nVisibleLines = nHeight - 2

			# Check if click is within bounds
			if nRelativeY >= 0 and nRelativeY < nVisibleLines
				# Move to clicked line
				if nClickedLine >= 0 and nClickedLine < len(aLines)
					nCursorY = nClickedLine

					# Position cursor at clicked column
					cCurrentLine = aLines[nCursorY + 1]
					if nRelativeX >= 0
						if nRelativeX <= len(cCurrentLine)
							nCursorX = nRelativeX
						else
							nCursorX = len(cCurrentLine)
						ok
					else
						nCursorX = 0
					ok

					# Just show cursor at new position, no redraw needed
					lFocused = true
					showCursor()
					return true
				ok
			ok
		ok

		return false

	func adjustScroll
		nVisibleLines = nHeight - 2

		# Scroll down if cursor is below visible area
		if nCursorY >= nScrollY + nVisibleLines
			nScrollY = nCursorY - nVisibleLines + 1
		ok

		# Scroll up if cursor is above visible area
		if nCursorY < nScrollY
			nScrollY = nCursorY
		ok

	func setEnterMode lMovesDown
		# Set whether Enter key moves to next line (true) or creates new line (false)
		lEnterMovesDown = lMovesDown
