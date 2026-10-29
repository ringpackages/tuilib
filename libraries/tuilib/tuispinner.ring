# Numeric input with decrement/increment buttons

class TUISpinner from TUIWidget

	nMinValue = 0
	nMaxValue = 100
	nValue = 0
	nStep = 1
	lEditing = false
	cEditText = ""
	nEditCursorPos = 0

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		if nSizeW < 7
			nWidth = 7  # Minimum width: [<]XXX[>]
		ok
		return self

	func setValue nNewValue
		if nNewValue < nMinValue
			nValue = nMinValue
		but nNewValue > nMaxValue
			nValue = nMaxValue
		else
			nValue = nNewValue
		ok

	func getValue
		return nValue

	func setRange nMin, nMax
		nMinValue = nMin
		nMaxValue = nMax
		if nValue < nMinValue
			nValue = nMinValue
		ok
		if nValue > nMaxValue
			nValue = nMaxValue
		ok

	func increment
		if nValue + nStep <= nMaxValue
			nValue = nValue + nStep
		else
			nValue = nMaxValue
		ok

	func decrement
		if nValue - nStep >= nMinValue
			nValue = nValue - nStep
		else
			nValue = nMinValue
		ok

	func draw
		if not lVisible
			return
		ok

		# Don't draw if width is too small
		if nWidth < 7
			return
		ok

		# Build the full display string
		nValueWidth = nWidth - 6  # Subtract buttons width
		if nValueWidth < 1
			nValueWidth = 1
		ok

		cValueStr = "" + nValue
		if len(cValueStr) > nValueWidth
			cValueStr = left(cValueStr, nValueWidth)
		ok

		# Center the value
		nPadding = nValueWidth - len(cValueStr)
		nLeftPad = floor(nPadding / 2)
		nRightPad = nPadding - nLeftPad

		# Build display
		if lEditing
			cDisplayValue = cEditText + copy(" ", nValueWidth - len(cEditText))
		else
			cDisplayValue = copy(" ", nLeftPad) + cValueStr + copy(" ", nRightPad)
		ok

		cFullDisplay = "[-]" + cDisplayValue + "[+]"

		# Clip to width
		if len(cFullDisplay) > nWidth
			cFullDisplay = substr(cFullDisplay, 1, nWidth)
		ok

		# Draw with appropriate colors
		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)  # Yellow when focused
		else
			oKernel.setTermColor(GREY, BLACK)
		ok
		oKernel.printAt(nX, nY, cFullDisplay)

		oKernel.resetTermColor()

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			nKey = oEvent.nKey

			if lEditing
				return handleEditMode(nKey)
			ok

			# Left arrow or minus - decrement
			if nKey = KEY_LEFT or nKey = 45  # '-' key
				decrement()
				draw()
				return true
			ok

			# Right arrow or plus - increment
			if nKey = KEY_RIGHT or nKey = 43 or nKey = 61  # '+' or '=' key
				increment()
				draw()
				return true
			ok

			# Enter - start editing
			if nKey = 13 or nKey = KEY_ENTER
				startEditing()
				return true
			ok

			# Direct number input
			if nKey >= 48 and nKey <= 57  # 0-9
				startEditing()
				cEditText = char(nKey)
				nEditCursorPos = 1
				draw()
				return true
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			return handleMouseClick(oEvent.nX, oEvent.nY)
		ok

		return false

	func handleEditMode nKey
		# Escape - cancel editing
		if nKey = 27 or nKey = KEY_ESCAPE
			lEditing = false
			draw()
			return true
		ok

		# Enter - confirm editing
		if nKey = 13 or nKey = KEY_ENTER
			confirmEdit()
			return true
		ok

		# Backspace
		if nKey = 8 and nEditCursorPos > 0
			cEditText = left(cEditText, nEditCursorPos - 1) + substr(cEditText, nEditCursorPos + 1)
			nEditCursorPos--
			draw()
			return true
		ok

		# Number keys only
		if nKey >= 48 and nKey <= 57  # 0-9
			nValueWidth = nWidth - 6
			if len(cEditText) < nValueWidth
				cEditText = left(cEditText, nEditCursorPos) + char(nKey) + substr(cEditText, nEditCursorPos + 1)
				nEditCursorPos++
				draw()
			ok
			return true
		ok

		# Minus sign (only at beginning)
		if nKey = 45 and nEditCursorPos = 0 and substr(cEditText, 1, 1) != "-"
			cEditText = "-" + cEditText
			nEditCursorPos++
			draw()
			return true
		ok

		return false

	func startEditing
		lEditing = true
		cEditText = "" + nValue
		nEditCursorPos = len(cEditText)
		draw()

	func confirmEdit
		lEditing = false
		if cEditText = "" or cEditText = "-"
			# Empty or just minus - keep old value
		else
			nNewValue = number(cEditText)
			setValue(nNewValue)
		ok
		draw()

	func handleMouseClick nMouseX, nMouseY
		if nMouseY != nY
			return false
		ok

		# Check decrement button
		if nMouseX >= nX and nMouseX < nX + 3
			decrement()
			draw()
			return true
		ok

		# Check increment button
		if nMouseX >= nX + nWidth - 3 and nMouseX < nX + nWidth
			increment()
			draw()
			return true
		ok

		# Check value field - start editing
		if nMouseX >= nX + 3 and nMouseX < nX + nWidth - 3
			if not lEditing
				startEditing()
			ok
			return true
		ok

		return false
