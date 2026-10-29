# Terminal abstraction layer over RogueUtil (screen, colors, keyboard, mouse)

class TUIKernel

	# Terminal state
	nRows = 0
	nCols = 0
	lMouseEnabled = false

	# Screen management - list of widgets to redraw when a region is cleared
	aScreenWidgets = []

	# Input (see pollEvent())
	lUnix = false			# Linux/macOS: keys and mouse reports arrive as escape sequences
	aEventQueue = []
	nPendingBytes = 0		# Bytes counted by kbhit() and not read yet (Linux/macOS)
	cTermState = ""			# Terminal settings to restore (Linux/macOS)
	nMouseLastX = 0			# Last mouse state (Windows reports the state, not events)
	nMouseLastY = 0
	nMouseLastButtons = 0

	# Default colors used by clearRegion() (see setDefaultColors())
	nDefaultFgColor = WHITE
	nDefaultBgColor = BLACK

	func init
		nRows = trows()
		nCols = tcols()
		lUnix = ! isWindows()
		if lUnix
			# Read the keys one by one, without echo (Ctrl+C still works)
			cTermState = trim(systemCmd("stty -g 2>/dev/null"))
			system("stty -icanon -echo min 1 time 0 2>/dev/null")
		ok
		hidecursor()
		echooff()  # Disable automatic echo of typed characters
		aScreenWidgets = []
		aEventQueue = []
		nDefaultFgColor = WHITE
		nDefaultBgColor = BLACK
		return self

	func getRows
		return trows()

	func getCols
		return tcols()

	func setDefaultColors nFg, nBg
		nDefaultFgColor = nFg
		nDefaultBgColor = nBg
		return self

	# ========================================
	# Screen Widget Management
	# ========================================

	func registerScreenWidget oWidget
		# Register a widget for automatic redrawing when regions are cleared
		add(aScreenWidgets, ref(oWidget))
		return self

	func unregisterScreenWidget oWidget
		# Remove a widget from screen management
		for nIndex = 1 to len(aScreenWidgets)
			if aScreenWidgets[nIndex] = oWidget
				del(aScreenWidgets, nIndex)
				exit
			ok
		next
		return self

	func clearScreenWidgets
		aScreenWidgets = []
		return self

	func redrawRegion nRegionX, nRegionY, nRegionW, nRegionH
		# Redraw all registered widgets that intersect with the given region
		# This is called when a menu closes to restore the background
		for oWidget in aScreenWidgets
			if oWidget.lVisible
				if rectanglesIntersect(oWidget.nX, oWidget.nY, oWidget.nWidth, oWidget.nHeight, nRegionX, nRegionY, nRegionW, nRegionH)
					oWidget.draw()
				ok
			ok
		next

	func clearRegion nRegionX, nRegionY, nRegionW, nRegionH
		# Clear a rectangular region with the default background color
		setTermColor(nDefaultFgColor, nDefaultBgColor)
		cClearLine = copy(" ", nRegionW)
		for nRow = nRegionY to nRegionY + nRegionH - 1
			printAt(nRegionX, nRow, cClearLine)
		next
		resetTermColor()

	func rectanglesIntersect nX1, nY1, nW1, nH1, nX2, nY2, nW2, nH2
		# Check if two rectangles intersect
		if nX1 >= nX2 + nW2 or nX2 >= nX1 + nW1
			return false
		ok
		if nY1 >= nY2 + nH2 or nY2 >= nY1 + nH1
			return false
		ok
		return true

	func gotoXY nX, nY
		tuiGotoXY(nX, nY)

	func clear
		cls()

	func setCursorVisible lVisible
		setCursorVisibility(lVisible)

	func setTermColor nFg, nBg
		setColor(nFg)
		setBackgroundColor(nBg)

	func resetTermColor
		resetColor()

	# ========================================
	# Input
	# ========================================

	func pollEvent
		# Return the next keyboard/mouse event (TUIEvent) or NULL if there is no input
		# Keyboard: cType = TUI_EVENT_KEYBOARD, nKey (RogueUtil key code or character code)
		# Mouse: cType = TUI_EVENT_MOUSE, nAction (TUI_MOUSE_*), nButton (TUI_BUTTON_*), nX, nY
		if len(aEventQueue) = 0
			readInput()
		ok
		if len(aEventQueue) = 0
			return NULL
		ok
		oEvent = aEventQueue[1]
		del(aEventQueue, 1)
		return oEvent

	func checkKeyHit
		# Return true if input (keyboard or mouse) is waiting
		if len(aEventQueue) > 0
			return true
		ok
		if lUnix
			return unixInputAvailable()
		ok
		return kbhit()

	func getKey
		# Wait for a key and return its code (mouse events are skipped)
		while true
			oEvent = pollEvent()
			if oEvent = NULL
				sleep(1)
			but oEvent.cType = TUI_EVENT_KEYBOARD
				return oEvent.nKey
			ok
		end

	func flush
		# Send the buffered output to the terminal
		fflush(stdout)

	func readInput
		# Read the waiting input and add the events to the queue
		if lUnix
			# Linux/macOS: keys and mouse reports are byte sequences
			nCount = 0
			while nCount < 32 and unixInputAvailable()
				unixReadEvent()
				nCount++
			end
			return
		ok
		# Windows: keys from kbhit()/getkey(), mouse from the console state
		if kbhit()
			addKeyEvent(tuiGetKey())
		ok
		if lMouseEnabled
			windowsReadMouse()
		ok

	func addKeyEvent nKeyCode
		oEvent = new TUIEvent(TUI_EVENT_KEYBOARD)
		oEvent.nKey = nKeyCode
		if nKeyCode >= 32 and nKeyCode <= 126
			oEvent.cChar = char(nKeyCode)
		ok
		add(aEventQueue, oEvent)

	func addMouseEvent nAction, nButton, nPosX, nPosY
		oEvent = new TUIEvent(TUI_EVENT_MOUSE)
		oEvent.nAction = nAction
		oEvent.nButton = nButton
		oEvent.nX = nPosX
		oEvent.nY = nPosY
		# vData is true for a left click (widgets use it as the "clicking" flag)
		oEvent.vData = (nAction = TUI_MOUSE_PRESS and nButton = TUI_BUTTON_LEFT)
		add(aEventQueue, oEvent)

	func windowsReadMouse
		addMouseState(getMouseInfo())

	func addMouseState aMouse
		# Windows reports the current mouse state: compare it with the last state
		if ! aMouse[MOUSEINFO_ACTIVE]
			return
		ok
		nPosX = aMouse[MOUSEINFO_X]
		nPosY = aMouse[MOUSEINFO_Y]
		nButtons = aMouse[MOUSEINFO_BUTTONS]
		if aMouse[MOUSEINFO_EVENTS] = MOUSEINFO_WHEELEVENT
			# The wheel state stays in the console input, so it can't be reported once
			nButtons = nMouseLastButtons
		ok
		lLeftNow = nButtons & 1
		lLeftBefore = nMouseLastButtons & 1
		lRightNow = nButtons & 2
		lRightBefore = nMouseLastButtons & 2
		if nPosX != nMouseLastX or nPosY != nMouseLastY
			if lLeftNow and lLeftBefore
				addMouseEvent(TUI_MOUSE_DRAG, TUI_BUTTON_LEFT, nPosX, nPosY)
			but ! lLeftNow and ! lLeftBefore
				addMouseEvent(TUI_MOUSE_MOVE, TUI_BUTTON_NONE, nPosX, nPosY)
			ok
		ok
		if lLeftNow and ! lLeftBefore
			addMouseEvent(TUI_MOUSE_PRESS, TUI_BUTTON_LEFT, nPosX, nPosY)
		but lLeftBefore and ! lLeftNow
			addMouseEvent(TUI_MOUSE_RELEASE, TUI_BUTTON_LEFT, nPosX, nPosY)
		ok
		if lRightNow and ! lRightBefore
			addMouseEvent(TUI_MOUSE_PRESS, TUI_BUTTON_RIGHT, nPosX, nPosY)
		but lRightBefore and ! lRightNow
			addMouseEvent(TUI_MOUSE_RELEASE, TUI_BUTTON_RIGHT, nPosX, nPosY)
		ok
		nMouseLastX = nPosX
		nMouseLastY = nPosY
		nMouseLastButtons = nButtons

	func unixInputAvailable
		if nPendingBytes > 0
			return true
		ok
		nPendingBytes = kbhit()
		return nPendingBytes > 0

	func unixReadByte
		# getch() reads from the C input buffer, so we count the bytes reported by kbhit()
		if nPendingBytes > 0
			nPendingBytes--
		ok
		return getch()

	func unixReadEvent
		# Decode one key or mouse report
		nByte = unixReadByte()
		if nByte = 27
			unixReadEscape()
		but nByte = 13 or nByte = 10
			addKeyEvent(KEY_ENTER)
		but nByte = 127 or nByte = 8
			addKeyEvent(TUI_KEY_BACKSPACE)
		else
			addKeyEvent(nByte)
		ok

	func unixReadEscape
		# ESC alone, or the start of an escape sequence (CSI "ESC [" or SS3 "ESC O")
		if nPendingBytes = 0
			nPendingBytes = kbhit()		# The rest of a sequence may arrive a bit later
		ok
		if nPendingBytes = 0
			addKeyEvent(KEY_ESCAPE)
			return
		ok
		nByte = unixReadByte()
		if nByte = ascii("[")
			unixReadCSI()
		but nByte = ascii("O")
			nByte = unixReadByte()
			unixAddFinalKey(char(nByte), "")
		but nByte = 27
			addKeyEvent(KEY_ESCAPE)
			unixReadEscape()
		else
			addKeyEvent(nByte)		# Alt+Key: report the key
		ok

	func unixReadCSI
		# Parameters then a final byte (@ to ~); "<" starts the SGR mouse parameters
		cParams = ""
		while true
			nByte = unixReadByte()
			if nByte >= 64 and nByte <= 126 and ! (len(cParams) = 0 and nByte = ascii("<"))
				exit
			ok
			cParams += char(nByte)
		end
		cFinal = char(nByte)
		if left(cParams, 1) = "<" and (cFinal = "M" or cFinal = "m")
			unixAddMouseEvent(substr(cParams, 2), cFinal = "m", 0)		# SGR mouse report
		but cFinal = "M" and cParams = ""
			# X10 mouse report: three bytes (button, x, y) + 32
			nB = unixReadByte() - 32
			nPosX = unixReadByte() - 32
			nPosY = unixReadByte() - 32
			unixAddMouseEvent("" + nB + ";" + nPosX + ";" + nPosY, (nB & 3) = 3, 0)
		but cFinal = "M" and substr(cParams, ";") > 0
			unixAddMouseEvent(cParams, false, 32)		# urxvt mouse report
		else
			unixAddFinalKey(cFinal, cParams)
		ok

	func unixAddFinalKey cFinal, cParams
		# Keys: ESC [ A, ESC O P, ESC [ 1 ; 5 A (with modifiers), ESC [ 3 ~, etc.
		nParam = 0
		nSep = substr(cParams, ";")
		if nSep > 0
			cParams = left(cParams, nSep - 1)
		ok
		if len(cParams) > 0 and isDigit(cParams)
			nParam = 0 + cParams
		ok
		switch cFinal
		on "A" addKeyEvent(KEY_UP)
		on "B" addKeyEvent(KEY_DOWN)
		on "C" addKeyEvent(KEY_RIGHT)
		on "D" addKeyEvent(KEY_LEFT)
		on "H" addKeyEvent(KEY_HOME)
		on "F" addKeyEvent(KEY_END)
		on "P" addKeyEvent(KEY_F1)
		on "Q" addKeyEvent(KEY_F2)
		on "R" addKeyEvent(KEY_F3)
		on "S" addKeyEvent(KEY_F4)
		on "Z" addKeyEvent(TUI_KEY_TAB)		# Shift+TAB
		on "~"
			# Home = 1/7, Insert = 2, Delete = 3, End = 4/8, PgUp = 5, PgDn = 6
			# F1 = 11 .. F5 = 15, F6 = 17 .. F10 = 21, F11 = 23, F12 = 24
			aKeys = [[1, KEY_HOME], [7, KEY_HOME], [2, KEY_INSERT], [3, KEY_DELETE],
				 [4, KEY_END], [8, KEY_END], [5, KEY_PGUP], [6, KEY_PGDOWN],
				 [11, KEY_F1], [12, KEY_F2], [13, KEY_F3], [14, KEY_F4], [15, KEY_F5],
				 [17, KEY_F6], [18, KEY_F7], [19, KEY_F8], [20, KEY_F9], [21, KEY_F10],
				 [23, KEY_F11], [24, KEY_F12]]
			nPos = find(aKeys, nParam, 1)
			if nPos > 0
				addKeyEvent(aKeys[nPos][2])
			ok
		off
		# Unknown sequences are ignored (they are never reported as ESC)

	func unixAddMouseEvent cReport, lRelease, nOffset
		# cReport: "button;x;y"
		aParts = split(cReport, ";")
		if len(aParts) < 3
			return
		ok
		nB = (0 + aParts[1]) - nOffset
		nPosX = 0 + aParts[2]
		nPosY = 0 + aParts[3]
		nButton = TUI_BUTTON_NONE
		switch nB & 3
		on 0 nButton = TUI_BUTTON_LEFT
		on 1 nButton = TUI_BUTTON_MIDDLE
		on 2 nButton = TUI_BUTTON_RIGHT
		off
		if nB & 64
			if nB & 1
				addMouseEvent(TUI_MOUSE_WHEELDOWN, TUI_BUTTON_NONE, nPosX, nPosY)
			else
				addMouseEvent(TUI_MOUSE_WHEELUP, TUI_BUTTON_NONE, nPosX, nPosY)
			ok
		but nB & 32
			if nButton = TUI_BUTTON_NONE
				addMouseEvent(TUI_MOUSE_MOVE, TUI_BUTTON_NONE, nPosX, nPosY)
			else
				addMouseEvent(TUI_MOUSE_DRAG, nButton, nPosX, nPosY)
			ok
		but lRelease or nButton = TUI_BUTTON_NONE
			# SGR reports the released button; the old protocols don't (3 = released)
			if nButton = TUI_BUTTON_NONE
				nButton = TUI_BUTTON_LEFT
			ok
			addMouseEvent(TUI_MOUSE_RELEASE, nButton, nPosX, nPosY)
		else
			addMouseEvent(TUI_MOUSE_PRESS, nButton, nPosX, nPosY)
		ok

	func getChar
		return getch()

	func nbGetch
		return nb_getch()

	func printAt nX, nY, cText
		printXY(nX, nY, cText)

	func setTitle cTitle
		setConsoleTitle(cTitle)

	func enableMouse
		# Linux/macOS: also switches to the alternate screen and clears it
		tuiEnableMouse()
		lMouseEnabled = true
		if ! lUnix
			# Start from the current state (an old click must not be reported)
			aMouse = getMouseInfo()
			if aMouse[MOUSEINFO_ACTIVE]
				nMouseLastX = aMouse[MOUSEINFO_X]
				nMouseLastY = aMouse[MOUSEINFO_Y]
				nMouseLastButtons = aMouse[MOUSEINFO_BUTTONS]
			ok
		ok

	func disableMouse
		tuiDisableMouse()
		lMouseEnabled = false

	func sleep nMilliseconds
		fflush(stdout)		# Show the output before waiting
		msleep(nMilliseconds)

	func waitForKey cMessage
		anykey(cMessage)

	func enableEcho
		echoon()

	func disableEcho
		echooff()

	func restoreTerminal
		# Restore the terminal state (call it before the program ends)
		if lMouseEnabled
			disableMouse()		# Linux/macOS: stop the mouse reports and leave the alternate screen
		ok
		if lUnix and cTermState != ""
			system("stty " + cTermState + " 2>/dev/null")
		ok
		cls()
		resetColor()
		setCursorVisibility(1)
		echoon()
		tuiGotoXY(0, 0)
		fflush(stdout)

	func drawBox nX, nY, nSizeW, nSizeH, nChar
		# Draw horizontal lines
		cHLine = ""
		for nIndex = 1 to nSizeW
			cHLine = cHLine + char(nChar)
		next
		self.printAt(nX, nY, cHLine)
		self.printAt(nX, nY + nSizeH - 1, cHLine)

		# Draw vertical lines
		cVChar = char(nChar)
		for nRow = nY + 1 to nY + nSizeH - 2
			self.printAt(nX, nRow, cVChar)
			self.printAt(nX + nSizeW - 1, nRow, cVChar)
		next

	func drawRect nX, nY, nSizeW, nSizeH
		# Use simple ASCII characters for compatibility
		# + for corners, - for horizontal, | for vertical

		# Build top line: +----+
		cTopLine = "+"
		for nIndex = 1 to nSizeW - 2
			cTopLine = cTopLine + "-"
		next
		cTopLine = cTopLine + "+"
		self.printAt(nX, nY, cTopLine)

		# Middle lines: |    |
		cMiddleLine = "|" + copy(" ", nSizeW - 2) + "|"
		for nRow = nY + 1 to nY + nSizeH - 2
			self.printAt(nX, nRow, cMiddleLine)
		next

		# Bottom line: +----+
		cBottomLine = "+"
		for nIndex = 1 to nSizeW - 2
			cBottomLine = cBottomLine + "-"
		next
		cBottomLine = cBottomLine + "+"
		self.printAt(nX, nY + nSizeH - 1, cBottomLine)

	func fillRect nX, nY, nSizeW, nSizeH, nChar
		cFillLine = ""
		for nCol = 1 to nSizeW
			cFillLine = cFillLine + char(nChar)
		next
		for nRow = nY to nY + nSizeH - 1
			self.printAt(nX, nRow, cFillLine)
		next

	func fixedWidth cText, nSize
		# Returns a string of exactly nSize characters
		# Pads with spaces if text is shorter, truncates if longer
		# Useful for fixed-width display to avoid visual interference
		nTextLen = len(cText)
		if nTextLen = nSize
			return cText
		but nTextLen < nSize
			# Pad with spaces on the right
			return cText + copy(" ", nSize - nTextLen)
		else
			# Truncate to fit
			return left(cText, nSize)
		ok
