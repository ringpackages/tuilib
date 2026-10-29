# Base widget class: position, size, colors, draw() and handleEvent()

class TUIWidget

	nX = 0
	nY = 0
	nWidth = 10
	nHeight = 1
	cText = ""
	lVisible = true
	lEnabled = true
	lFocused = false
	lFocusable = true      # Whether this widget can receive focus (TUILabel sets this to false)
	oKernel = NULL
	nFgColor = WHITE
	nBgColor = BLUE

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		oKernel = ref(oTUIKernel)
		nX = nPosX
		nY = nPosY
		nWidth = nSizeW
		nHeight = nSizeH
		return self

	func draw
		# Override in subclasses

	func handleEvent oEvent
		# Override in subclasses

	func setText cValue
		cText = cValue
		# Don't auto-draw - let parent control handle drawing

	func show
		lVisible = true
		draw()

	func hide
		lVisible = false
