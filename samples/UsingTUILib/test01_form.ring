/*
	TUILib Sample - Form widgets: labels, text boxes, check boxes, list box, combo box, edit box, buttons and rectangles
	Keys: TAB (next widget), Arrows (interact), Enter/Space (buttons and check boxes), ESC (exit)
*/

load "tuilib.ring"

# Global variables (used by the button handlers)
oAppKernel = NULL
oAppEventManager = NULL
oAppStatusBar = NULL
oAppTxtName = NULL
oAppTxtEmail = NULL
oAppChk1 = NULL
oAppChk2 = NULL
oAppEditComments = NULL

oAppKernel = new TUIKernel()
oAppKernel.clear()
oAppKernel.enableMouse()
oAppEventManager = new TUIEventManager(oAppKernel)

runFormDemo()

oAppKernel.restoreTerminal()

func runFormDemo

	# Create main window
	oWin = new TUIWindow(oAppKernel, 2, 2, 76, 23, "TUILib Form Demo - ESC: Exit")

	# Create labels
	oLbl1 = new TUILabel(oAppKernel, 4, 4, 30, 1)
	oLbl1.setText("Name:")

	oLbl2 = new TUILabel(oAppKernel, 4, 6, 30, 1)
	oLbl2.setText("Email:")

	# Create text boxes
	oAppTxtName = new TUITextBox(oAppKernel, 12, 4, 30, 1)
	oAppTxtName.setText("Sample User")
	oAppTxtName.nCursorPos = len(oAppTxtName.cText)

	oAppTxtEmail = new TUITextBox(oAppKernel, 12, 6, 30, 1)
	oAppTxtEmail.setText("user@example.com")
	oAppTxtEmail.nCursorPos = len(oAppTxtEmail.cText)

	# Create check boxes
	oAppChk1 = new TUICheckBox(oAppKernel, 4, 8, 36, 1)
	oAppChk1.setText("Subscribe to newsletter")

	oAppChk2 = new TUICheckBox(oAppKernel, 4, 9, 36, 1)
	oAppChk2.setText("Accept terms and conditions")
	oAppChk2.setChecked(true)

	# Create list box
	oLbl3 = new TUILabel(oAppKernel, 45, 4, 30, 1)
	oLbl3.setText("Select Country:")

	oLstCountries = new TUIListBox(oAppKernel, 45, 5, 30, 8)
	oLstCountries.addItem("Country A")
	oLstCountries.addItem("Country B")
	oLstCountries.addItem("Country C")
	oLstCountries.addItem("Country D")
	oLstCountries.addItem("Country E")
	oLstCountries.addItem("Country F")
	oLstCountries.addItem("Country G")
	oLstCountries.nSelectedIndex = 1

	# Create combo box
	oLbl4 = new TUILabel(oAppKernel, 4, 11, 30, 1)
	oLbl4.setText("Preferred Language:")

	oCmbLanguage = new TUIComboBox(oAppKernel, 4, 12, 30, 1)
	oCmbLanguage.addItem("English")
	oCmbLanguage.addItem("Arabic")
	oCmbLanguage.addItem("French")
	oCmbLanguage.addItem("German")
	oCmbLanguage.addItem("Spanish")

	# Create multi-line edit box
	oLbl5 = new TUILabel(oAppKernel, 45, 14, 30, 1)
	oLbl5.setText("Comments:")

	oAppEditComments = new TUIEditBox(oAppKernel, 45, 15, 30, 5)
	oAppEditComments.setText("Enter your comments here..." + nl + "Multiple lines supported!")

	# Create buttons
	oBtnSubmit = new TUIButton(oAppKernel, 4, 16, 12, 1)
	oBtnSubmit.setText("Submit")
	oBtnSubmit.setOnClick(func {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Form submitted! Name: " + oAppTxtName.cText + ", Email: " + oAppTxtEmail.cText, 76))
		oAppStatusBar.draw()
	})

	oBtnCancel = new TUIButton(oAppKernel, 18, 16, 12, 1)
	oBtnCancel.setText("Cancel")
	oBtnCancel.setOnClick(func {
		oAppStatusBar.setText(oAppKernel.fixedWidth("Form cancelled!", 76))
		oAppStatusBar.draw()
	})

	oBtnReset = new TUIButton(oAppKernel, 32, 16, 12, 1)
	oBtnReset.setText("Reset")
	oBtnReset.setOnClick(func {
		oAppTxtName.setText("")
		oAppTxtName.nCursorPos = 0
		oAppTxtName.draw()
		oAppTxtEmail.setText("")
		oAppTxtEmail.nCursorPos = 0
		oAppTxtEmail.draw()
		oAppChk1.setChecked(false)
		oAppChk1.draw()
		oAppChk2.setChecked(false)
		oAppChk2.draw()
		oAppEditComments.setText("")
		oAppEditComments.draw()
		oAppStatusBar.setText(oAppKernel.fixedWidth("Form reset!", 76))
		oAppStatusBar.draw()
	})

	# Create info label
	oLblInfo = new TUILabel(oAppKernel, 4, 14, 38, 1)
	oLblInfo.setText("TAB: Focus | Arrows: Interact")
	oLblInfo.nFgColor = LIGHTGREEN

	# Rectangles - Bottom section
	oRect1 = new TUIRectangle(oAppKernel, 4, 18, 22, 5)
	oRect1.setBorderStyle("double")
	oRect1.nFgColor = LIGHTMAGENTA

	oRectLabel1 = new TUILabel(oAppKernel, 6, 19, 18, 1)
	oRectLabel1.setText("Rectangle Examples:")
	oRectLabel1.nFgColor = WHITE

	oRect1a = new TUIRectangle(oAppKernel, 6, 20, 6, 2)
	oRect1a.setBorderStyle("single")
	oRect1a.nFgColor = LIGHTCYAN

	oRect1b = new TUIRectangle(oAppKernel, 13, 20, 6, 2)
	oRect1b.setBorderStyle("thick")
	oRect1b.nFgColor = YELLOW

	oRect1c = new TUIRectangle(oAppKernel, 20, 20, 5, 2)
	oRect1c.setBorderStyle("none")
	oRect1c.setFilled(true, ascii("="))
	oRect1c.nFgColor = LIGHTGREEN

	# Add all controls to window
	oWin.addChild(oLbl1)
	oWin.addChild(oLbl2)
	oWin.addChild(oAppTxtName)
	oWin.addChild(oAppTxtEmail)
	oWin.addChild(oAppChk1)
	oWin.addChild(oAppChk2)
	oWin.addChild(oLbl3)
	oWin.addChild(oLstCountries)
	oWin.addChild(oLbl4)
	oWin.addChild(oCmbLanguage)
	oWin.addChild(oLbl5)
	oWin.addChild(oAppEditComments)
	oWin.addChild(oBtnSubmit)
	oWin.addChild(oBtnCancel)
	oWin.addChild(oBtnReset)
	oWin.addChild(oLblInfo)
	oWin.addChild(oRect1)
	oWin.addChild(oRectLabel1)
	oWin.addChild(oRect1a)
	oWin.addChild(oRect1b)
	oWin.addChild(oRect1c)

	# Draw window (draws all children automatically)
	oWin.draw()

	# Status bar (outside window)
	oAppStatusBar = new TUILabel(oAppKernel, 2, 25, 76, 1)
	oAppStatusBar.setText(oAppKernel.fixedWidth("Ready - TAB: Navigate fields | Arrows: Interact | ESC: Exit", 76))
	oAppStatusBar.nFgColor = BLACK
	oAppStatusBar.nBgColor = GREY
	oAppStatusBar.draw()

	# Register the widgets that can receive focus (TAB order)
	oAppEventManager.registerWidget(oAppTxtName)
	oAppEventManager.registerWidget(oAppTxtEmail)
	oAppEventManager.registerWidget(oAppChk1)
	oAppEventManager.registerWidget(oAppChk2)
	oAppEventManager.registerWidget(oLstCountries)
	oAppEventManager.registerWidget(oCmbLanguage)
	oAppEventManager.registerWidget(oAppEditComments)
	oAppEventManager.registerWidget(oBtnSubmit)
	oAppEventManager.registerWidget(oBtnCancel)
	oAppEventManager.registerWidget(oBtnReset)

	# Set initial focus
	oAppEventManager.setFocus(oAppTxtName)

	# Run event loop
	oAppEventManager.run()
