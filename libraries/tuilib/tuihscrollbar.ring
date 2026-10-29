# Horizontal scroll bar

class TUIHScrollBar from TUIWidget

	nMinValue = 0
	nMaxValue = 100
	nValue = 0
	nPageSize = 10         # Size of the visible "page"
	cOnChange = NULL       # Callback when value changes
	lDragging = false

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, 1)  # Horizontal scrollbar is always 1 row high
		if nSizeW < 5
			nWidth = 5  # Minimum: [<]=[>]
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

		# Don't draw if width is too small
		if nWidth < 5
			return
		ok

		# Build the full display string
		nTrackWidth = nWidth - 2  # Minus arrow buttons
		if nTrackWidth < 1
			nTrackWidth = 1
		ok

		# Calculate thumb position
		if nMaxValue > nMinValue
			nThumbPos = floor(((nValue - nMinValue) * (nTrackWidth - 1)) / (nMaxValue - nMinValue))
		else
			nThumbPos = 0
		ok

		# Build track with thumb
		cTrack = copy("-", nTrackWidth)
		if nThumbPos >= 0 and nThumbPos < nTrackWidth
			cTrack = substr(cTrack, 1, nThumbPos) + "#" + substr(cTrack, nThumbPos + 2)
		ok

		cFullDisplay = "<" + cTrack + ">"

		# Clip to width
		if len(cFullDisplay) > nWidth
			cFullDisplay = substr(cFullDisplay, 1, nWidth)
		ok

		# Draw with appropriate colors
		if lFocused
			oKernel.setTermColor(YELLOW, BLACK)
		else
			oKernel.setTermColor(GREY, BLACK)
		ok
		oKernel.printAt(nX, nY, cFullDisplay)

		oKernel.resetTermColor()

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			nKey = oEvent.nKey

			if nKey = KEY_LEFT
				setValue(nValue - 1)
				draw()
				return true
			ok

			if nKey = KEY_RIGHT
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
		if nMouseY != nY
			return false
		ok

		# Left arrow button
		if nMouseX = nX
			setValue(nValue - 1)
			draw()
			return true
		ok

		# Right arrow button
		if nMouseX = nX + nWidth - 1
			setValue(nValue + 1)
			draw()
			return true
		ok

		# Track area - jump to position
		if nMouseX > nX and nMouseX < nX + nWidth - 1
			nTrackWidth = nWidth - 2
			nClickPos = nMouseX - nX - 1
			if nMaxValue > nMinValue and nTrackWidth > 1
				# Calculate percentage based on click position
				nPercentage = (nClickPos * 100) / (nTrackWidth - 1)
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
