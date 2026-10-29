# Page in a TUITabControl (holds child widgets)

class TUITabPage

	cTitle = ""
	aChildren = []
	aChildRelX = []
	aChildRelY = []
	vData = NULL

	func init cNewTitle
		cTitle = cNewTitle
		aChildren = []
		aChildRelX = []
		aChildRelY = []
		return self

	func addChild oWidget, nRelX, nRelY
		add(aChildren, ref(oWidget))
		add(aChildRelX, nRelX)
		add(aChildRelY, nRelY)
		# Hide widget initially (will be shown when page is active)
		oWidget.lVisible = false
		return self

	func removeChild oWidget
		for nIndex = 1 to len(aChildren)
			if aChildren[nIndex] = oWidget
				del(aChildren, nIndex)
				del(aChildRelX, nIndex)
				del(aChildRelY, nIndex)
				exit
			ok
		next
		return self
