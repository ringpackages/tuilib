# Rectangle with a border style and an optional fill character (display only)

class TUIRectangle from TUIWidget

	lFocusable = false     # Rectangles cannot receive focus (display only)
	cBorderStyle = "single"  # "single", "double", "thick", "none"
	lFilled = false
	nFillChar = 32  # Space by default
	nCornerChar = 0  # 0 means use the default corners of the border style

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		return self

	func draw
		if not lVisible
			return
		ok

		oKernel.setTermColor(nFgColor, nBgColor)

		if cBorderStyle = "none"
			# Just fill the area if filled
			if lFilled
				cFillLine = ""
				for nCol = 1 to nWidth
					cFillLine = cFillLine + char(nFillChar)
				next
				for nRow = nY to nY + nHeight - 1
					oKernel.printAt(nX, nRow, cFillLine)
				next
			ok
		else
			# Draw border based on style
			drawBorder()

			# Fill interior if needed
			if lFilled
				cFillLine = ""
				for nCol = 1 to nWidth - 2
					cFillLine = cFillLine + char(nFillChar)
				next
				for nRow = nY + 1 to nY + nHeight - 2
					oKernel.printAt(nX + 1, nRow, cFillLine)
				next
			ok
		ok

		oKernel.resetTermColor()

	func drawBorder
		# Use simple ASCII characters for compatibility
		# All styles use the same simple characters now
		cTopLeftChar = "+"
		cTopRightChar = "+"
		cBottomLeftChar = "+"
		cBottomRightChar = "+"
		cHorizontalChar = "-"
		cVerticalChar = "|"

		# For "thick" style, use different characters
		if cBorderStyle = "thick"
			cTopLeftChar = "#"
			cTopRightChar = "#"
			cBottomLeftChar = "#"
			cBottomRightChar = "#"
			cHorizontalChar = "#"
			cVerticalChar = "#"
		ok

		# Custom corner character (see setCornerChar())
		if nCornerChar != 0
			cTopLeftChar = char(nCornerChar)
			cTopRightChar = cTopLeftChar
			cBottomLeftChar = cTopLeftChar
			cBottomRightChar = cTopLeftChar
		ok

		# Build and draw top line
		cTopLine = cTopLeftChar
		for nIndex = 1 to nWidth - 2
			cTopLine = cTopLine + cHorizontalChar
		next
		cTopLine = cTopLine + cTopRightChar
		oKernel.printAt(nX, nY, cTopLine)

		# Draw middle lines (just the vertical borders)
		for nRow = nY + 1 to nY + nHeight - 2
			oKernel.printAt(nX, nRow, cVerticalChar)
			oKernel.printAt(nX + nWidth - 1, nRow, cVerticalChar)
		next

		# Build and draw bottom line
		cBottomLine = cBottomLeftChar
		for nIndex = 1 to nWidth - 2
			cBottomLine = cBottomLine + cHorizontalChar
		next
		cBottomLine = cBottomLine + cBottomRightChar
		oKernel.printAt(nX, nY + nHeight - 1, cBottomLine)

	func setBorderStyle cStyle
		# Set border style: "single", "double", "thick", "none"
		cBorderStyle = cStyle
		draw()

	func setFilled lIsFilled, nChar
		lFilled = lIsFilled
		if nChar != NULL
			nFillChar = nChar
		ok
		draw()

	func setCornerChar nChar
		nCornerChar = nChar
		draw()
