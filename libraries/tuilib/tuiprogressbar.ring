# Progress indicator with an optional percentage (display only)

class TUIProgressBar from TUIWidget

	lFocusable = false     # ProgressBars cannot receive focus (display only)
	nMinValue = 0
	nMaxValue = 100
	nValue = 0
	lShowPercentage = true
	cFillChar = "="            # Fill character
	cEmptyChar = "-"           # Empty character
	nBarFgColor = LIGHTGREEN           # Green
	nBarBgColor = BLACK            # Black
	nEmptyFgColor = DARKGREY          # Dark gray

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
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

	func getPercentage
		if nMaxValue = nMinValue
			return 0
		ok
		return floor(((nValue - nMinValue) * 100) / (nMaxValue - nMinValue))

	func draw
		if not lVisible
			return
		ok

		# Don't draw if width is too small
		if nWidth < 5
			return
		ok

		# Calculate fill width
		nBarWidth = nWidth - 2  # Account for brackets
		if lShowPercentage
			nBarWidth = nBarWidth - 5  # Space for " 100%"
		ok
		if nBarWidth < 1
			nBarWidth = 1
		ok

		nPercentage = getPercentage()
		nFillWidth = floor((nBarWidth * nPercentage) / 100)
		nEmptyWidth = nBarWidth - nFillWidth

		# Build the full display string
		cDisplay = "["

		# Add filled portion
		if nFillWidth > 0
			cDisplay = cDisplay + copy(cFillChar, nFillWidth)
		ok

		# Add empty portion
		if nEmptyWidth > 0
			cDisplay = cDisplay + copy(cEmptyChar, nEmptyWidth)
		ok

		cDisplay = cDisplay + "]"

		# Add percentage
		if lShowPercentage
			cPercText = "" + nPercentage + "%"
			cPercText = copy(" ", 4 - len(cPercText)) + cPercText
			cDisplay = cDisplay + cPercText
		ok

		# Clip to width
		if len(cDisplay) > nWidth
			cDisplay = substr(cDisplay, 1, nWidth)
		ok

		# Draw with colors - simplified to single print for clipping
		oKernel.setTermColor(nBarFgColor, nBarBgColor)
		oKernel.printAt(nX, nY, cDisplay)

		oKernel.resetTermColor()

	func handleEvent oEvent
		# ProgressBar doesn't handle events directly
		return false
