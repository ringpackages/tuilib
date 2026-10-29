/*
	TUILib Sample - Progress bars, spinners and scroll bars (with a timer)
*/

load "tuilib.ring"

# Global variables (used by the event handlers)
oAppKernel = NULL
oAppEventManager = NULL
oAppStatusBar = NULL
oAppProgress1 = NULL
oAppProgress2 = NULL
oAppProgress3 = NULL
oAppSpinner1 = NULL
oAppSpinner2 = NULL
oAppHScroll = NULL
oAppVScroll = NULL
oAppLblHValue = NULL
oAppLblVValue = NULL

oAppKernel = new TUIKernel()
oAppKernel.clear()
oAppKernel.enableMouse()
oAppEventManager = new TUIEventManager(oAppKernel)

runControlsDemo()

oAppKernel.restoreTerminal()

func runControlsDemo
	# Create main window
	oWin = new TUIWindow(oAppKernel, 2, 2, 76, 23, "Controls Demo - ESC: Exit")

	# === Progress Bars Section ===
	oLblProgress = new TUILabel(oAppKernel, 4, 4, 25, 1)
	oLblProgress.setText("Progress Bars:")
	oLblProgress.nFgColor = YELLOW

	# Progress bar 1 - with percentage
	oLblProg1 = new TUILabel(oAppKernel, 4, 6, 15, 1)
	oLblProg1.setText("Download:")
	oLblProg1.nFgColor = GREY

	oAppProgress1 = new TUIProgressBar(oAppKernel, 20, 6, 40, 1)
	oAppProgress1.setValue(75)
	oAppProgress1.nBarFgColor = LIGHTGREEN  # Green

	# Progress bar 2 - different color
	oLblProg2 = new TUILabel(oAppKernel, 4, 8, 15, 1)
	oLblProg2.setText("Upload:")
	oLblProg2.nFgColor = GREY

	oAppProgress2 = new TUIProgressBar(oAppKernel, 20, 8, 40, 1)
	oAppProgress2.setValue(30)
	oAppProgress2.nBarFgColor = LIGHTCYAN  # Cyan

	# Progress bar 3 - no percentage
	oLblProg3 = new TUILabel(oAppKernel, 4, 10, 15, 1)
	oLblProg3.setText("Processing:")
	oLblProg3.nFgColor = GREY

	oAppProgress3 = new TUIProgressBar(oAppKernel, 20, 10, 40, 1)
	oAppProgress3.setValue(50)
	oAppProgress3.lShowPercentage = false
	oAppProgress3.nBarFgColor = YELLOW  # Yellow

	# === Spinners Section ===
	oLblSpinners = new TUILabel(oAppKernel, 4, 12, 25, 1)
	oLblSpinners.setText("Spinners:")
	oLblSpinners.nFgColor = YELLOW

	oLblSpin1 = new TUILabel(oAppKernel, 4, 14, 15, 1)
	oLblSpin1.setText("Quantity:")
	oLblSpin1.nFgColor = GREY

	oAppSpinner1 = new TUISpinner(oAppKernel, 20, 14, 15, 1)
	oAppSpinner1.setValue(10)
	oAppSpinner1.setRange(0, 100)
	oAppSpinner1.nStep = 1

	oLblSpin2 = new TUILabel(oAppKernel, 40, 14, 15, 1)
	oLblSpin2.setText("Percent:")
	oLblSpin2.nFgColor = GREY

	oAppSpinner2 = new TUISpinner(oAppKernel, 56, 14, 15, 1)
	oAppSpinner2.setValue(50)
	oAppSpinner2.setRange(0, 100)
	oAppSpinner2.nStep = 5

	# === Scroll Bars Section ===
	oLblScrolls = new TUILabel(oAppKernel, 4, 16, 25, 1)
	oLblScrolls.setText("Scroll Bars:")
	oLblScrolls.nFgColor = YELLOW

	# Horizontal scroll bar
	oLblHScroll = new TUILabel(oAppKernel, 4, 18, 15, 1)
	oLblHScroll.setText("Horizontal:")
	oLblHScroll.nFgColor = GREY

	oAppHScroll = new TUIHScrollBar(oAppKernel, 20, 18, 30, 1)
	oAppHScroll.setValue(25)

	oAppLblHValue = new TUILabel(oAppKernel, 52, 18, 10, 1)
	oAppLblHValue.setText(oAppKernel.fixedWidth("Val: 25", 10))
	oAppLblHValue.nFgColor = WHITE

	# Vertical scroll bar
	oLblVScroll = new TUILabel(oAppKernel, 4, 20, 15, 1)
	oLblVScroll.setText("Vertical:")
	oLblVScroll.nFgColor = GREY

	oAppVScroll = new TUIVScrollBar(oAppKernel, 74, 4, 1, 18)
	oAppVScroll.setValue(50)

	oAppLblVValue = new TUILabel(oAppKernel, 63, 20, 10, 1)
	oAppLblVValue.setText(oAppKernel.fixedWidth("Val: 50", 10))
	oAppLblVValue.nFgColor = WHITE

	# Info label
	oLblInfo = new TUILabel(oAppKernel, 4, 22, 70, 1)
	oLblInfo.setText("TAB: Navigate | Arrows/Click: Adjust | ENTER: Edit spinner | ESC: Exit")
	oLblInfo.nFgColor = LIGHTGREEN

	# Add all controls to window
	oWin.addChild(oLblProgress)
	oWin.addChild(oLblProg1)
	oWin.addChild(oAppProgress1)
	oWin.addChild(oLblProg2)
	oWin.addChild(oAppProgress2)
	oWin.addChild(oLblProg3)
	oWin.addChild(oAppProgress3)
	oWin.addChild(oLblSpinners)
	oWin.addChild(oLblSpin1)
	oWin.addChild(oAppSpinner1)
	oWin.addChild(oLblSpin2)
	oWin.addChild(oAppSpinner2)
	oWin.addChild(oLblScrolls)
	oWin.addChild(oLblHScroll)
	oWin.addChild(oAppHScroll)
	oWin.addChild(oAppLblHValue)
	oWin.addChild(oLblVScroll)
	oWin.addChild(oAppVScroll)
	oWin.addChild(oAppLblVValue)
	oWin.addChild(oLblInfo)

	# Draw window (draws all children automatically)
	oWin.draw()

	# Status bar (outside window)
	oAppStatusBar = new TUILabel(oAppKernel, 2, 25, 76, 1)
	oAppStatusBar.setText(oAppKernel.fixedWidth("Controls Demo - TAB: Navigate controls", 76))
	oAppStatusBar.nFgColor = BLACK
	oAppStatusBar.nBgColor = GREY
	oAppStatusBar.draw()

	# Register widgets for focus navigation
	oAppEventManager.registerWidget(oAppSpinner1)
	oAppEventManager.registerWidget(oAppSpinner2)
	oAppEventManager.registerWidget(oAppHScroll)
	oAppEventManager.registerWidget(oAppVScroll)

	oAppEventManager.setFocus(oAppSpinner1)

	# Set up keyboard handler
	oAppEventManager.setOnKeyboard(func oEvent {
		nKey = oEvent.nKey

		# TAB to switch focus (handled by default, but update status)
		if nKey = 9		# TAB
			oAppEventManager.focusNext()
			oAppStatusBar.setText(oAppKernel.fixedWidth("Focused: " + getFocusedControlName(oAppEventManager.oFocusedWidget), 76))
			oAppStatusBar.draw()
			return true
		ok

		# Pass to focused widget
		if oAppEventManager.oFocusedWidget != NULL
			oAppEventManager.oFocusedWidget.handleEvent(oEvent)
			updateControlsDisplay()
		ok

		return true
	})

	# Set up mouse handler
	oAppEventManager.setOnMouse(func oEvent {
		# Check each control
		if oAppSpinner1.handleEvent(oEvent)
			oAppEventManager.setFocus(oAppSpinner1)
		but oAppSpinner2.handleEvent(oEvent)
			oAppEventManager.setFocus(oAppSpinner2)
		but oAppHScroll.handleEvent(oEvent)
			oAppEventManager.setFocus(oAppHScroll)
		but oAppVScroll.handleEvent(oEvent)
			oAppEventManager.setFocus(oAppVScroll)
		ok

		updateControlsDisplay()
		return true
	})

	# Set up timer for animation (every 20 iterations = ~200ms)
	oAppEventManager.setOnTimer(func {
		# Animate progress1
		nNewValue = oAppProgress1.getValue() + 2
		if nNewValue > 100
			nNewValue = 0
		ok
		oAppProgress1.setValue(nNewValue)
		oAppProgress1.draw()

		# Animate progress3
		nNewValue = oAppProgress3.getValue() + 3
		if nNewValue > 100
			nNewValue = 0
		ok
		oAppProgress3.setValue(nNewValue)
		oAppProgress3.draw()

		# Link spinner1 to progress2
		oAppProgress2.setValue(oAppSpinner1.getValue())
		oAppProgress2.draw()
	}, 20)

	# Run event loop
	oAppEventManager.run()

func getFocusedControlName oWidget
	if oWidget = NULL
		return "None"
	ok
	switch classname(oWidget)
	on "tuispinner"
		return "Spinner"
	on "tuihscrollbar"
		return "Horizontal ScrollBar"
	on "tuivscrollbar"
		return "Vertical ScrollBar"
	off
	return classname(oWidget)

func updateControlsDisplay
	oAppLblHValue.setText(oAppKernel.fixedWidth("Val: " + oAppHScroll.getValue(), 10))
	oAppLblHValue.draw()
	oAppLblVValue.setText(oAppKernel.fixedWidth("Val: " + oAppVScroll.getValue(), 10))
	oAppLblVValue.draw()
