/*
	TUILib Sample - Demo launcher (runs the other samples)
*/

load "tuilib.ring"

aDemos = [
	["Form Demo",           "test01_form.ring"],
	["Grid/Table Demo",     "test02_grid.ring"],
	["Menu Bar Demo",       "test03_menubar.ring"],
	["Window Manager Demo", "test04_window_manager.ring"],
	["Tree View Demo",      "test05_treeview.ring"],
	["Tab Control Demo",    "test06_tabcontrol.ring"],
	["Controls Demo",       "test07_controls.ring"],
	["Menu + Tabs Demo",    "test08_menubar_tabs.ring"]
]

cRing = exefilename()
if substr(cRing, " ") cRing = '"' + cRing + '"' ok
chdir(JustFilePath(filename()))

oAppKernel = new TUIKernel()
nDemos = len(aDemos)

while true
	drawLauncher()
	nPressedKey = oAppKernel.getKey()
	if nPressedKey = 57 or nPressedKey = 27		# '9' or ESC
		exit
	ok
	nChoice = nPressedKey - 48			# '1' = 49
	if nChoice >= 1 and nChoice <= nDemos
		oAppKernel.restoreTerminal()
		system(cRing + " " + aDemos[nChoice][2])
		oAppKernel = new TUIKernel()
	ok
end

oAppKernel.restoreTerminal()
? "Thank you for trying TUILib!"

func drawLauncher
	oAppKernel.clear()
	oAppKernel.setTermColor(WHITE, BLUE)
	cClearLine = copy(" ", 80)
	for nRow = 1 to 25
		oAppKernel.printAt(1, nRow, cClearLine)
	next

	oAppKernel.setTermColor(YELLOW, BLUE)
	oAppKernel.printAt(25, 3, "+------------------------------+")
	oAppKernel.printAt(25, 4, "|        TUILIB SAMPLES        |")
	oAppKernel.printAt(25, 5, "+------------------------------+")

	oAppKernel.setTermColor(WHITE, BLUE)
	oAppKernel.printAt(25, 6, "|                              |")
	for nDemo = 1 to nDemos
		oAppKernel.printAt(25, 6 + nDemo, "|   " + oAppKernel.fixedWidth("" + nDemo + ". " + aDemos[nDemo][1], 27) + "|")
	next
	oAppKernel.printAt(25, 7 + nDemos, "|                              |")
	oAppKernel.printAt(25, 8 + nDemos, "|   9. Exit                    |")
	oAppKernel.printAt(25, 9 + nDemos, "+------------------------------+")

	oAppKernel.setTermColor(LIGHTCYAN, BLUE)
	oAppKernel.printAt(25, 11 + nDemos, "  Enter choice (1-9): ")
	oAppKernel.setTermColor(WHITE, BLUE)
