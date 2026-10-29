/*
	TUILib Sample - Data grid with in-place cell editing
*/

load "tuilib.ring"

# Global variables
oAppKernel = NULL
oAppEventManager = NULL

oAppKernel = new TUIKernel()
oAppKernel.clear()
oAppKernel.enableMouse()
oAppEventManager = new TUIEventManager(oAppKernel)

runGridDemo()

oAppKernel.restoreTerminal()

func runGridDemo

	# Create main window
	oWin = new TUIWindow(oAppKernel, 2, 2, 76, 23, "Grid/Table Demo - ESC: Exit")

	# Create grid
	# Width calculation: border(2) + rowNum(4) + sep(1) + ID(5) + sep(1) + Name(15) + sep(1) + Email(22) + sep(1) + Age(4) + sep(1) + City(10) = 67
	oGrid = new TUIGrid(oAppKernel, 4, 4, 68, 16)
	oGrid.lShowHeaders = true
	oGrid.lShowRowNumbers = true
	oGrid.nRowNumberWidth = 4
	oGrid.lEditable = true

	# Add columns (total content width should be grid width - 2 for borders - rowNumWidth - 1 for separator)
	# Available: 68 - 2 - 4 - 1 = 61, with 4 separators between 5 columns = 57 for data
	oGrid.addColumn("ID", 5)
	oGrid.addColumn("Name", 15)
	oGrid.addColumn("Email", 22)
	oGrid.addColumn("Age", 4)
	oGrid.addColumn("City", 10)

	# Add sample data
	oGrid.addRow(["001", "User 1", "user1@example.com", "28", "City A"])
	oGrid.addRow(["002", "User 2", "user2@example.com", "34", "City B"])
	oGrid.addRow(["003", "User 3", "user3@example.com", "45", "City C"])
	oGrid.addRow(["004", "User 4", "user4@example.com", "29", "City D"])
	oGrid.addRow(["005", "User 5", "user5@example.com", "52", "City E"])
	oGrid.addRow(["006", "User 6", "user6@example.com", "31", "City F"])
	oGrid.addRow(["007", "User 7", "user7@example.com", "27", "City G"])
	oGrid.addRow(["008", "User 8", "user8@example.com", "38", "City H"])
	oGrid.addRow(["009", "User 9", "user9@example.com", "42", "City I"])
	oGrid.addRow(["010", "User 10", "user10@example.com", "36", "City J"])

	# Create info label
	oLblInfo = new TUILabel(oAppKernel, 4, 21, 72, 1)
	oLblInfo.setText("Arrows: Navigate | ENTER: Edit | ESC: Exit")
	oLblInfo.nFgColor = LIGHTGREEN

	# Add controls to window
	oWin.addChild(oGrid)
	oWin.addChild(oLblInfo)

	# Draw window (draws all children automatically)
	oWin.draw()

	# Status bar (outside window)
	oStatusBar = new TUILabel(oAppKernel, 2, 25, 76, 1)
	oStatusBar.setText(oAppKernel.fixedWidth("Grid Demo - Click cells or use arrows to navigate, press ENTER to edit", 76))
	oStatusBar.nFgColor = BLACK
	oStatusBar.nBgColor = GREY
	oStatusBar.draw()

	oAppEventManager.registerWidget(oGrid)
	oAppEventManager.setFocus(oGrid)

	# Run event loop
	oAppEventManager.run()
