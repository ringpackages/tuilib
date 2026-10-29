# Container with a background that can redraw the children inside a region

class TUIFrame from TUIWidget

	aChildren = []           # List of child widgets
	cBgChar = " "           # Background character

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		aChildren = []
		return self

	func addChild oWidget
		add(aChildren, ref(oWidget))
		return self

	func removeChild oWidget
		for nIndex = 1 to len(aChildren)
			if aChildren[nIndex] = oWidget
				del(aChildren, nIndex)
				exit
			ok
		next
		return self

	func clearChildren
		aChildren = []
		return self

	func draw
		if not lVisible
			return
		ok

		# Draw background
		oKernel.setTermColor(nFgColor, nBgColor)
		cBgLine = copy(cBgChar, nWidth)
		for nRow = nY to nY + nHeight - 1
			oKernel.printAt(nX, nRow, cBgLine)
		next

		# Draw all children
		for oChild in aChildren
			if oChild.lVisible
				oChild.draw()
			ok
		next

		oKernel.resetTermColor()

	func drawBackground
		# Draw only the background (not children)
		if not lVisible
			return
		ok

		oKernel.setTermColor(nFgColor, nBgColor)
		cBgLine = copy(cBgChar, nWidth)
		for nRow = nY to nY + nHeight - 1
			oKernel.printAt(nX, nRow, cBgLine)
		next
		oKernel.resetTermColor()

	func redrawRegion nRegionX, nRegionY, nRegionW, nRegionH
		# Redraw the background for a specific region, then redraw any children that intersect
		if not lVisible
			return
		ok

		# First, draw background for the region (clipped to frame bounds)
		nStartX = max(nRegionX, nX)
		nStartY = max(nRegionY, nY)
		nEndX = min(nRegionX + nRegionW, nX + nWidth)
		nEndY = min(nRegionY + nRegionH, nY + nHeight)

		if nStartX < nEndX and nStartY < nEndY
			oKernel.setTermColor(nFgColor, nBgColor)
			nRegionWidth = nEndX - nStartX
			cBgLine = copy(cBgChar, nRegionWidth)
			for nRow = nStartY to nEndY - 1
				oKernel.printAt(nStartX, nRow, cBgLine)
			next
		ok

		# Then redraw children that intersect with the region
		for oChild in aChildren
			if oChild.lVisible and rectanglesIntersect(oChild.nX, oChild.nY, oChild.nWidth, oChild.nHeight, nRegionX, nRegionY, nRegionW, nRegionH)
				oChild.draw()
			ok
		next

		oKernel.resetTermColor()

	func getIntersectingWidgets nRegionX, nRegionY, nRegionW, nRegionH
		# Return a list of widgets that intersect with the given rectangle
		aResult = []
		for oChild in aChildren
			if oChild.lVisible and rectanglesIntersect(oChild.nX, oChild.nY, oChild.nWidth, oChild.nHeight, nRegionX, nRegionY, nRegionW, nRegionH)
				add(aResult, ref(oChild))
			ok
		next
		return aResult

	func rectanglesIntersect nX1, nY1, nW1, nH1, nX2, nY2, nW2, nH2
		# Check if two rectangles intersect
		if nX1 >= nX2 + nW2 or nX2 >= nX1 + nW1
			return false
		ok
		if nY1 >= nY2 + nH2 or nY2 >= nY1 + nH1
			return false
		ok
		return true
