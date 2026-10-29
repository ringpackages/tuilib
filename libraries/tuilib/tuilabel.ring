# Single line text (cannot receive focus)

class TUILabel from TUIWidget

	lFocusable = false     # Labels cannot receive focus

	func draw
		if not lVisible
			return
		ok

		oKernel.setTermColor(nFgColor, nBgColor)
		cDisplayText = cText

		if len(cDisplayText) > nWidth
			cDisplayText = substr(cDisplayText, 1, nWidth)
		ok

		oKernel.printAt(nX, nY, cDisplayText)
		oKernel.resetTermColor()
