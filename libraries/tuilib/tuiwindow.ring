# Frame with a border and a title

class TUIWindow from TUIFrame

	cTitle = ""
	nBorderColor = LIGHTCYAN  # Cyan

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH, cNewTitle
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		cTitle = cNewTitle
		return self

	func draw
		if not lVisible
			return
		ok

		# Draw border
		oKernel.setTermColor(nBorderColor, nBgColor)
		oKernel.drawRect(nX, nY, nWidth, nHeight)

		# Draw title
		if len(cTitle) > 0
			cTitleText = " " + cTitle + " "
			if len(cTitleText) < nWidth - 2
				oKernel.printAt(nX + 2, nY, cTitleText)
			ok
		ok

		# Draw content area background
		oKernel.setTermColor(nFgColor, nBgColor)
		for nRow = nY + 1 to nY + nHeight - 2
			oKernel.printAt(nX + 1, nRow, copy(" ", nWidth - 2))
		next

		# Draw all children
		for oChild in aChildren
			if oChild.lVisible
				oChild.draw()
			ok
		next

		oKernel.resetTermColor()
