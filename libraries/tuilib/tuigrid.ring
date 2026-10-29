# Data grid with column headers, row numbers and in-place cell editing

class TUIGrid from TUIWidget

	aColumns = []           # Column definitions: [[name, width], ...]
	aRows = []             # Data rows: [[cell1, cell2, ...], ...]
	nCurrentRow = 0        # Current selected row (0-based)
	nCurrentCol = 0        # Current selected column (0-based)
	nScrollY = 0           # Vertical scroll offset
	nScrollX = 0           # Horizontal scroll offset
	lShowHeaders = true    # Show column headers
	lShowRowNumbers = true # Show row numbers
	lEditable = true       # Allow editing cells
	lEditing = false       # Currently in edit mode
	cEditText = ""         # Text being edited
	nEditCursorPos = 0     # Cursor position in edit mode
	nRowNumberWidth = 4    # Width of row number column
	nGridFgColor = WHITE      # Grid lines color
	nGridBgColor = BLACK       # Grid background
	nHeaderFgColor = BLACK     # Header text color
	nHeaderBgColor = GREY     # Header background
	nSelectedFgColor = BLACK   # Selected cell text
	nSelectedBgColor = LIGHTCYAN  # Selected cell background (cyan)
	nEditFgColor = BLACK       # Edit mode text
	nEditBgColor = YELLOW      # Edit mode background (yellow)
	# Pending mouse click info (for click-away during edit)
	lPendingMouseClick = false
	nLastClickX = 0
	nLastClickY = 0
	vLastClickData = NULL

	func init oTUIKernel, nPosX, nPosY, nSizeW, nSizeH
		super.init(oTUIKernel, nPosX, nPosY, nSizeW, nSizeH)
		return self

	func addColumn cColName, nColWidth
		add(aColumns, [cColName, nColWidth])

	func addRow aRowData
		add(aRows, aRowData)

	func setCell nRow, nCol, cValue
		# row and col are 0-based indices
		# Ring arrays are 1-based, so we add 1
		if nRow >= 0 and nRow < len(aRows)
			nRowIndex = nRow + 1
			# Ensure row has enough columns
			while len(aRows[nRowIndex]) <= nCol
				add(aRows[nRowIndex], "")
			end
			nColIndex = nCol + 1
			if nColIndex >= 1 and nColIndex <= len(aRows[nRowIndex])
				aRows[nRowIndex][nColIndex] = cValue
			ok
		ok

	func getCell nRow, nCol
		# row and col are 0-based indices
		# Ring arrays are 1-based, so we add 1
		if nRow >= 0 and nRow < len(aRows)
			nRowIndex = nRow + 1
			nColIndex = nCol + 1
			if nColIndex >= 1 and nColIndex <= len(aRows[nRowIndex])
				return aRows[nRowIndex][nColIndex]
			ok
		ok
		return ""

	func clearData
		aRows = []
		nCurrentRow = 0
		nCurrentCol = 0
		nScrollY = 0
		nScrollX = 0

	func draw
		if not lVisible
			return
		ok

		oKernel.setTermColor(nGridFgColor, nGridBgColor)

		# Calculate visible area
		nVisibleHeight = nHeight - 2  # Minus borders
		if lShowHeaders
			nVisibleHeight = nVisibleHeight - 1  # One line for headers
		ok

		# Draw border
		oKernel.drawRect(nX, nY, nWidth, nHeight)

		# Draw headers if enabled
		nCurrentY = nY + 1
		if lShowHeaders
			drawHeaders(nCurrentY)
			nCurrentY++
			# Draw separator line between headers and data
			drawHeaderSeparator(nCurrentY)
			nCurrentY++
			nVisibleHeight = nVisibleHeight - 1  # Account for separator line
		ok

		# Draw rows
		drawRows(nCurrentY, nVisibleHeight)

		oKernel.resetTermColor()

	func drawHeaderSeparator nPosY
		# Draw a separator line between headers and data
		oKernel.setTermColor(nGridFgColor, nGridBgColor)

		cSeparatorLine = "|"

		if lShowRowNumbers
			cSeparatorLine = cSeparatorLine + copy("-", nRowNumberWidth) + "+"
		ok

		for nIndex = 1 to len(aColumns)
			nColWidth = aColumns[nIndex][2]
			cSeparatorLine = cSeparatorLine + copy("-", nColWidth)
			if nIndex < len(aColumns)
				cSeparatorLine = cSeparatorLine + "+"
			ok
		next

		# Pad to fill width-1 (leave space for right border from drawRect)
		nCurrentLen = len(cSeparatorLine)
		nTargetLen = nWidth - 1  # -1 because drawRect already has right border |
		if nCurrentLen < nTargetLen
			cSeparatorLine = cSeparatorLine + copy("-", nTargetLen - nCurrentLen)
		ok

		oKernel.printAt(nX, nPosY, cSeparatorLine)

	func drawHeaders nPosY
		# Draw header content (borders are handled by drawRect)
		nCurrentX = nX + 1

		# Row number column header
		if lShowRowNumbers
			oKernel.setTermColor(nHeaderFgColor, nHeaderBgColor)
			cHeaderText = "#"
			cHeaderText = cHeaderText + copy(" ", nRowNumberWidth - len(cHeaderText))
			oKernel.printAt(nCurrentX, nPosY, cHeaderText)
			nCurrentX = nCurrentX + nRowNumberWidth

			# Separator after row numbers
			oKernel.setTermColor(nGridFgColor, nGridBgColor)
			oKernel.printAt(nCurrentX, nPosY, "|")
			nCurrentX++
		ok

		# Column headers
		for nIndex = 1 to len(aColumns)
			cColName = aColumns[nIndex][1]
			nColWidth = aColumns[nIndex][2]

			# Truncate or pad header text
			oKernel.setTermColor(nHeaderFgColor, nHeaderBgColor)
			if len(cColName) > nColWidth
				cColName = substr(cColName, 1, nColWidth)
			else
				cColName = cColName + copy(" ", nColWidth - len(cColName))
			ok

			oKernel.printAt(nCurrentX, nPosY, cColName)
			nCurrentX = nCurrentX + nColWidth

			# Column separator (not after last column - drawRect handles right border)
			if nIndex < len(aColumns)
				oKernel.setTermColor(nGridFgColor, nGridBgColor)
				oKernel.printAt(nCurrentX, nPosY, "|")
				nCurrentX++
			ok
		next

	func drawRows nStartY, nVisibleHeight
		if len(aRows) = 0
			return
		ok

		for nIndex = 1 to nVisibleHeight
			nRowIndex = nScrollY + nIndex - 1
			if nRowIndex >= len(aRows)
				exit
			ok

			nCurrentY = nStartY + nIndex - 1
			nCurrentX = nX + 1

			# Draw row number if enabled
			if lShowRowNumbers
				if nRowIndex = nCurrentRow and not lEditing
					oKernel.setTermColor(nSelectedFgColor, nSelectedBgColor)
				else
					oKernel.setTermColor(nGridFgColor, nGridBgColor)
				ok

				cRowNumText = "" + (nRowIndex + 1)
				cRowNumText = copy(" ", nRowNumberWidth - len(cRowNumText)) + cRowNumText
				oKernel.printAt(nCurrentX, nCurrentY, cRowNumText)
				nCurrentX = nCurrentX + nRowNumberWidth

				# Add separator after row numbers
				oKernel.setTermColor(nGridFgColor, nGridBgColor)
				oKernel.printAt(nCurrentX, nCurrentY, "|")
				nCurrentX++
			ok

			# Draw cells
			for nColIndex = 0 to len(aColumns) - 1
				nColWidth = aColumns[nColIndex + 1][2]
				cCellValue = ""

				if nColIndex < len(aRows[nRowIndex + 1])
					cCellValue = aRows[nRowIndex + 1][nColIndex + 1]
				ok

				# Determine cell colors
				if nRowIndex = nCurrentRow and nColIndex = nCurrentCol
					if lEditing
						oKernel.setTermColor(nEditFgColor, nEditBgColor)
						cCellValue = cEditText
					else
						oKernel.setTermColor(nSelectedFgColor, nSelectedBgColor)
					ok
				else
					oKernel.setTermColor(nGridFgColor, nGridBgColor)
				ok

				# Format cell text
				if len(cCellValue) > nColWidth
					cCellValue = substr(cCellValue, 1, nColWidth)
				else
					cCellValue = cCellValue + copy(" ", nColWidth - len(cCellValue))
				ok

				oKernel.printAt(nCurrentX, nCurrentY, cCellValue)
				nCurrentX = nCurrentX + nColWidth

				# Draw column separator (not after last column - drawRect handles right border)
				if nColIndex < len(aColumns) - 1
					oKernel.setTermColor(nGridFgColor, nGridBgColor)
					oKernel.printAt(nCurrentX, nCurrentY, "|")
					nCurrentX++
				ok
			next
		next

	func drawEditCell
		# Draw only the cell being edited (to reduce flicker)
		if not lEditing
			return
		ok

		# Calculate visible row position
		nVisibleRow = nCurrentRow - nScrollY
		if nVisibleRow < 0
			return
		ok

		nVisibleHeight = nHeight - 2
		if lShowHeaders
			nVisibleHeight--
		ok

		if nVisibleRow >= nVisibleHeight
			return
		ok

		# Calculate Y position
		# Start after top border
		nCurrentY = nY + 1
		if lShowHeaders
			nCurrentY = nCurrentY + 2  # +1 for header row, +1 for separator line
		ok
		nCurrentY = nCurrentY + nVisibleRow

		# Calculate X position of current column
		nCurrentX = nX + 1
		if lShowRowNumbers
			nCurrentX = nCurrentX + nRowNumberWidth + 1  # +1 for separator
		ok

		for nIndex = 0 to nCurrentCol - 1
			nCurrentX = nCurrentX + aColumns[nIndex + 1][2] + 1  # +1 for separator
		next

		# Get column width
		nColWidth = aColumns[nCurrentCol + 1][2]

		# Draw cell with edit colors
		oKernel.setTermColor(nEditFgColor, nEditBgColor)

		# Format edit text
		cDisplayText = cEditText
		if len(cDisplayText) > nColWidth
			cDisplayText = substr(cDisplayText, 1, nColWidth)
		else
			cDisplayText = cDisplayText + copy(" ", nColWidth - len(cDisplayText))
		ok

		oKernel.printAt(nCurrentX, nCurrentY, cDisplayText)

		# Position cursor
		nCursorX = nCurrentX + nEditCursorPos
		if nEditCursorPos > nColWidth
			nCursorX = nCurrentX + nColWidth
		ok
		oKernel.gotoXY(nCursorX, nCurrentY)
		oKernel.setCursorVisible(1)

		oKernel.resetTermColor()

	func drawCell nRow, nCol
		# Draw only a single cell (to reduce flicker during navigation)
		# row and col are 0-based indices

		# Check if cell is visible
		nVisibleRow = nRow - nScrollY
		if nVisibleRow < 0
			return
		ok

		nVisibleHeight = nHeight - 2
		if lShowHeaders
			nVisibleHeight = nVisibleHeight - 2  # -1 for header, -1 for separator
		ok

		if nVisibleRow >= nVisibleHeight
			return
		ok

		# Calculate Y position
		nCurrentY = nY + 1
		if lShowHeaders
			nCurrentY = nCurrentY + 2  # +1 for header row, +1 for separator line
		ok
		nCurrentY = nCurrentY + nVisibleRow

		# Calculate X position of the column
		nCurrentX = nX + 1
		if lShowRowNumbers
			nCurrentX = nCurrentX + nRowNumberWidth + 1  # +1 for separator
		ok

		for nIndex = 0 to nCol - 1
			nCurrentX = nCurrentX + aColumns[nIndex + 1][2] + 1  # +1 for separator
		next

		# Get column width and cell value
		nColWidth = aColumns[nCol + 1][2]
		cCellValue = ""

		if nCol < len(aRows[nRow + 1])
			cCellValue = aRows[nRow + 1][nCol + 1]
		ok

		# Determine cell colors
		if nRow = nCurrentRow and nCol = nCurrentCol
			if lEditing
				oKernel.setTermColor(nEditFgColor, nEditBgColor)
				cCellValue = cEditText
			else
				oKernel.setTermColor(nSelectedFgColor, nSelectedBgColor)
			ok
		else
			oKernel.setTermColor(nGridFgColor, nGridBgColor)
		ok

		# Format cell text
		if len(cCellValue) > nColWidth
			cCellValue = substr(cCellValue, 1, nColWidth)
		else
			cCellValue = cCellValue + copy(" ", nColWidth - len(cCellValue))
		ok

		oKernel.printAt(nCurrentX, nCurrentY, cCellValue)
		oKernel.resetTermColor()

	func drawRowNumber nRow
		# Draw only the row number for a specific row
		# row is 0-based index

		if not lShowRowNumbers
			return
		ok

		# Check if row is visible
		nVisibleRow = nRow - nScrollY
		if nVisibleRow < 0
			return
		ok

		nVisibleHeight = nHeight - 2
		if lShowHeaders
			nVisibleHeight = nVisibleHeight - 2
		ok

		if nVisibleRow >= nVisibleHeight
			return
		ok

		# Calculate Y position
		nCurrentY = nY + 1
		if lShowHeaders
			nCurrentY = nCurrentY + 2
		ok
		nCurrentY = nCurrentY + nVisibleRow

		# Calculate X position (row numbers start at x + 1)
		nCurrentX = nX + 1

		# Determine colors - highlight if this is the current row
		if nRow = nCurrentRow and not lEditing
			oKernel.setTermColor(nSelectedFgColor, nSelectedBgColor)
		else
			oKernel.setTermColor(nGridFgColor, nGridBgColor)
		ok

		# Format and draw row number
		cRowNumText = "" + (nRow + 1)
		cRowNumText = copy(" ", nRowNumberWidth - len(cRowNumText)) + cRowNumText
		oKernel.printAt(nCurrentX, nCurrentY, cRowNumText)

		oKernel.resetTermColor()

	func handleEvent oEvent
		if oEvent.cType = TUI_EVENT_KEYBOARD
			nKey = oEvent.nKey

			if not lEditing
				handleNavigationMode(nKey)
			ok
		ok

		if oEvent.cType = TUI_EVENT_MOUSE
			if not lEditing
				handleMouseClick(oEvent.nX, oEvent.nY)
			ok
		ok

	func hasPendingMouseClick
		return lPendingMouseClick

	func getPendingMouseClick
		if lPendingMouseClick
			lPendingMouseClick = false
			return [nLastClickX, nLastClickY, vLastClickData]
		ok
		return NULL

	func startEditing
		# Get current cell value using proper 0-based indices
		cEditText = getCell(nCurrentRow, nCurrentCol)
		nEditCursorPos = len(cEditText)
		lEditing = true

		# Calculate edit cell bounds for mouse detection
		nEditCellX = nX + 1
		if lShowRowNumbers
			nEditCellX = nEditCellX + nRowNumberWidth + 1  # +1 for separator
		ok
		for nIndex = 0 to nCurrentCol - 1
			nEditCellX = nEditCellX + aColumns[nIndex + 1][2] + 1  # +1 for separator
		next
		nEditCellWidth = aColumns[nCurrentCol + 1][2]

		# Calculate Y position of edit cell
		# Start after top border
		nEditCellY = nY + 1
		if lShowHeaders
			nEditCellY = nEditCellY + 2  # +1 for header row, +1 for separator line
		ok
		nEditCellY = nEditCellY + (nCurrentRow - nScrollY)

		# Initial draw of edit cell
		drawEditCell()

		# Dedicated edit loop
		while lEditing
			oInput = oKernel.pollEvent()
			if oInput = NULL
				oKernel.sleep(1)  # Small delay to prevent CPU overuse
				loop
			ok

			if oInput.cType = TUI_EVENT_KEYBOARD
				nKey = oInput.nKey

				# Exit edit mode - save (check both ASCII 13 and KEY_ENTER constant)
				if nKey = 13 or nKey = KEY_ENTER
					saveEdit()
					lEditing = false
					oKernel.setCursorVisible(0)
					# Only redraw the edited cell and row number instead of entire grid
					drawCell(nCurrentRow, nCurrentCol)
					drawRowNumber(nCurrentRow)
					exit
				ok

				# Exit edit mode - cancel (check both ASCII 27 and KEY_ESCAPE constant)
				if nKey = 27 or nKey = KEY_ESCAPE
					lEditing = false
					oKernel.setCursorVisible(0)
					# Only redraw the edited cell and row number instead of entire grid
					drawCell(nCurrentRow, nCurrentCol)
					drawRowNumber(nCurrentRow)
					exit
				ok

				# Get column width
				nColWidth = aColumns[nCurrentCol + 1][2]

				# Backspace
				if nKey = TUI_KEY_BACKSPACE and nEditCursorPos > 0
					cEditText = substr(cEditText, 1, nEditCursorPos - 1) + substr(cEditText, nEditCursorPos + 1)
					nEditCursorPos--
					drawEditCell()
				ok

				# Delete
				if nKey = KEY_DELETE and nEditCursorPos < len(cEditText)
					cEditText = substr(cEditText, 1, nEditCursorPos) + substr(cEditText, nEditCursorPos + 2)
					drawEditCell()
				ok

				# Left arrow
				if nKey = KEY_LEFT and nEditCursorPos > 0
					nEditCursorPos--
					drawEditCell()
				ok

				# Right arrow
				if nKey = KEY_RIGHT and nEditCursorPos < len(cEditText)
					nEditCursorPos++
					drawEditCell()
				ok

				# Home key
				if nKey = KEY_HOME
					nEditCursorPos = 0
					drawEditCell()
				ok

				# End key
				if nKey = KEY_END
					nEditCursorPos = len(cEditText)
					drawEditCell()
				ok

				# Regular character - only printable ASCII
				if nKey >= 32 and nKey <= 126 and len(cEditText) < nColWidth
					cEditText = substr(cEditText, 1, nEditCursorPos) + char(nKey) + substr(cEditText, nEditCursorPos + 1)
					nEditCursorPos++
					drawEditCell()
				ok

			# Mouse click during editing
			but oInput.nAction = TUI_MOUSE_PRESS and oInput.nButton = TUI_BUTTON_LEFT
				nMouseX = oInput.nX
				nMouseY = oInput.nY
				# Check if click is inside the edit cell
				if nMouseX >= nEditCellX and nMouseX < nEditCellX + nEditCellWidth and nMouseY = nEditCellY
					# Click inside edit cell - move cursor
					nRelativeX = nMouseX - nEditCellX
					if nRelativeX >= 0 and nRelativeX <= len(cEditText)
						nEditCursorPos = nRelativeX
					but nRelativeX > len(cEditText)
						nEditCursorPos = len(cEditText)
					ok
					drawEditCell()
				else
					# Click outside edit cell - save and exit edit mode
					saveEdit()
					lEditing = false
					oKernel.setCursorVisible(0)
					# Only redraw the edited cell and row number instead of entire grid
					drawCell(nCurrentRow, nCurrentCol)
					drawRowNumber(nCurrentRow)

					# Store the click so the main event loop can handle it
					nLastClickX = nMouseX
					nLastClickY = nMouseY
					vLastClickData = true
					lPendingMouseClick = true
					exit
				ok
			ok
		end

	func handleNavigationMode nKey
		# Enter edit mode
		if (nKey = 13 or nKey = KEY_ENTER) and lEditable  # Enter
			startEditing()
			return
		ok

		# Store old position for selective redraw
		nOldRow = nCurrentRow
		nOldCol = nCurrentCol
		nOldScrollY = nScrollY

		# Navigation
		if nKey = KEY_UP and nCurrentRow > 0
			nCurrentRow--
			adjustScrollY()
			if nScrollY != nOldScrollY
				# Scrolling occurred, need full redraw
				draw()
			else
				# No scroll, just redraw old and new cells + row numbers
				drawCell(nOldRow, nOldCol)
				drawRowNumber(nOldRow)
				drawCell(nCurrentRow, nCurrentCol)
				drawRowNumber(nCurrentRow)
			ok
		ok

		if nKey = KEY_DOWN and nCurrentRow < len(aRows) - 1
			nCurrentRow++
			adjustScrollY()
			if nScrollY != nOldScrollY
				# Scrolling occurred, need full redraw
				draw()
			else
				# No scroll, just redraw old and new cells + row numbers
				drawCell(nOldRow, nOldCol)
				drawRowNumber(nOldRow)
				drawCell(nCurrentRow, nCurrentCol)
				drawRowNumber(nCurrentRow)
			ok
		ok

		if nKey = KEY_LEFT and nCurrentCol > 0
			nCurrentCol--
			# Same row, just redraw old and new cells
			drawCell(nOldRow, nOldCol)
			drawCell(nCurrentRow, nCurrentCol)
		ok

		if nKey = KEY_RIGHT and nCurrentCol < len(aColumns) - 1
			nCurrentCol++
			# Same row, just redraw old and new cells
			drawCell(nOldRow, nOldCol)
			drawCell(nCurrentRow, nCurrentCol)
		ok

		if nKey = KEY_HOME
			nCurrentCol = 0
			# Same row, just redraw old and new cells
			drawCell(nOldRow, nOldCol)
			drawCell(nCurrentRow, nCurrentCol)
		ok

		if nKey = KEY_END
			nCurrentCol = len(aColumns) - 1
			# Same row, just redraw old and new cells
			drawCell(nOldRow, nOldCol)
			drawCell(nCurrentRow, nCurrentCol)
		ok

		if nKey = KEY_PGUP
			nVisibleHeight = nHeight - 2
			if lShowHeaders
				nVisibleHeight = nVisibleHeight - 2  # -1 for header, -1 for separator
			ok
			nCurrentRow = nCurrentRow - nVisibleHeight
			if nCurrentRow < 0
				nCurrentRow = 0
			ok
			adjustScrollY()
			draw()
		ok

		if nKey = KEY_PGDOWN
			nVisibleHeight = nHeight - 2
			if lShowHeaders
				nVisibleHeight = nVisibleHeight - 2  # -1 for header, -1 for separator
			ok
			nCurrentRow = nCurrentRow + nVisibleHeight
			if nCurrentRow >= len(aRows)
				nCurrentRow = len(aRows) - 1
			ok
			adjustScrollY()
			draw()
		ok

	func handleMouseClick nMouseX, nMouseY
		# Check if click is inside grid
		if nMouseX < nX or nMouseX >= nX + nWidth or nMouseY < nY or nMouseY >= nY + nHeight
			return false
		ok

		# Calculate starting Y for data rows
		nDataStartY = nY + 1  # After top border
		if lShowHeaders
			nDataStartY = nDataStartY + 2  # +1 for header row, +1 for separator line
		ok

		# Check if click is in data area
		if nMouseY < nDataStartY
			return false  # Clicked on header, separator, or border
		ok

		# Calculate which row was clicked
		nClickedRow = nScrollY + (nMouseY - nDataStartY)

		if nClickedRow < 0 or nClickedRow >= len(aRows)
			return false
		ok

		# Calculate which column was clicked
		nClickX = nMouseX - nX - 1
		if lShowRowNumbers
			nClickX = nClickX - nRowNumberWidth - 1  # -1 for separator
		ok

		if nClickX < 0
			return false
		ok

		nClickedCol = -1
		nCurrentX = 0
		for nColIndex = 0 to len(aColumns) - 1
			nColWidth = aColumns[nColIndex + 1][2]
			if nClickX >= nCurrentX and nClickX < nCurrentX + nColWidth
				nClickedCol = nColIndex
				exit
			ok
			nCurrentX = nCurrentX + nColWidth + 1  # +1 for separator
		next

		if nClickedCol < 0
			return false
		ok

		# Check if clicking on already selected cell
		if nCurrentRow = nClickedRow and nCurrentCol = nClickedCol
			# Click on already selected cell - start editing
			if lEditable
				startEditing()
			ok
		else
			# Different cell - select it
			nOldRow = nCurrentRow
			nOldCol = nCurrentCol
			nCurrentRow = nClickedRow
			nCurrentCol = nClickedCol
			# Redraw old and new cells
			drawCell(nOldRow, nOldCol)
			drawCell(nCurrentRow, nCurrentCol)
			# If row changed, also redraw row numbers
			if nOldRow != nCurrentRow
				drawRowNumber(nOldRow)
				drawRowNumber(nCurrentRow)
			ok
		ok

		return true

	func saveEdit
		setCell(nCurrentRow, nCurrentCol, cEditText)

	func adjustScrollY
		nVisibleHeight = nHeight - 2  # Minus top and bottom borders
		if lShowHeaders
			nVisibleHeight = nVisibleHeight - 2  # -1 for header row, -1 for separator line
		ok

		# Scroll down if current row is below visible area
		if nCurrentRow >= nScrollY + nVisibleHeight
			nScrollY = nCurrentRow - nVisibleHeight + 1
		ok

		# Scroll up if current row is above visible area
		if nCurrentRow < nScrollY
			nScrollY = nCurrentRow
		ok
