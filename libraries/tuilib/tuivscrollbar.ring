# Vertical scroll bar

class TUIVScrollBar from TUIWidget

	nMinValue = 0
	nMaxValue = 100
	nValue = 0
	nPageSize = 10
	cOnChange = NULL

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, 1, nSizeH)  # Vertical scrollbar is always 1 column wide
		if nSizeH < 5
			nHeight = 5
		ok
		return self

	func setValue nNewValue
		nOldValue = nValue
		if nNewValue < nMinValue
			nValue = nMinValue
		but nNewValue > nMaxValue
			nValue = nMaxValue
		else
			nValue = nNewValue
		ok
		if nValue != nOldValue and cOnChange != NULL
			call cOnChange(nValue)
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

	func setOnChange cHandler
		cOnChange = cHandler
		return self

	func draw
		if not lVisible
			return
		ok

		# Don't draw if height is too small
		if nHeight < 3
			return
		ok

		# Calculate track height
		nTrackHeight = nHeight - 2
		if nTrackHeight < 1
			nTrackHeight = 1
		ok

		# Calculate thumb position
		if nMaxValue > nMinValue
			nThumbPos = floor(((nValue - nMinValue) * (nTrackHeight - 1)) / (nMaxValue - nMinValue))
		else
			nThumbPos = 0
		ok

		# Draw up arrow button
		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)
		else
			oKernel.setTermColor(GREY, BLACK)
		ok
		oKernel.printAt(nX, nY, "^")

		# Draw track with thumb
		for nIndex = 1 to nTrackHeight
			if nIndex - 1 = nThumbPos
				if lFocused
					oKernel.setTermColor(WHITE, BLACK)
				else
					oKernel.setTermColor(GREY, BLACK)
				ok
				oKernel.printAt(nX, nY + nIndex, "#")
			else
				oKernel.setTermColor(DARKGREY, BLACK)
				oKernel.printAt(nX, nY + nIndex, "|")
			ok
		next

		# Draw down arrow button
		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)
		else
			oKernel.setTermColor(GREY, BLACK)
		ok
		oKernel.printAt(nX, nY + nHeight - 1, "v")

		oKernel.resetTermColor()

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			nKey = oEvent.nKey

			if nKey = KEY_UP
				setValue(nValue - 1)
				draw()
				return true
			ok

			if nKey = KEY_DOWN
				setValue(nValue + 1)
				draw()
				return true
			ok

			if nKey = KEY_HOME
				setValue(nMinValue)
				draw()
				return true
			ok

			if nKey = KEY_END
				setValue(nMaxValue)
				draw()
				return true
			ok

			if nKey = KEY_PGUP
				setValue(nValue - nPageSize)
				draw()
				return true
			ok

			if nKey = KEY_PGDOWN
				setValue(nValue + nPageSize)
				draw()
				return true
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			return handleMouseClick(oEvent.nX, oEvent.nY)
		ok

		return false

	func handleMouseClick nMouseX, nMouseY
		if nMouseX != nX
			return false
		ok

		# Up arrow button
		if nMouseY = nY
			setValue(nValue - 1)
			draw()
			return true
		ok

		# Down arrow button
		if nMouseY = nY + nHeight - 1
			setValue(nValue + 1)
			draw()
			return true
		ok

		# Track area - jump to position
		if nMouseY > nY and nMouseY < nY + nHeight - 1
			nTrackHeight = nHeight - 2
			nClickPos = nMouseY - nY - 1
			if nMaxValue > nMinValue and nTrackHeight > 1
				# Calculate percentage based on click position
				nPercentage = (nClickPos * 100) / (nTrackHeight - 1)
				if nPercentage > 100
					nPercentage = 100
				ok
				if nPercentage < 0
					nPercentage = 0
				ok
				nNewValue = nMinValue + floor((nPercentage * (nMaxValue - nMinValue)) / 100)
				setValue(nNewValue)
				draw()
			ok
			return true
		ok

		return false
