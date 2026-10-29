# TUILib Package

## Overview

TUILib package for the Ring programming language

TUILib is a Terminal User Interface (TUI) library written in Ring. It provides windows, widgets, menus, tab pages, a data grid, a tree view and a window manager that run inside the console.

It uses the RogueUtil extension (distributed with Ring) for the screen, colors, keyboard and mouse, and works on Windows, Linux, and macOS (in terminals that support xterm mouse reporting, such as GNOME Terminal, Konsole, xterm, iTerm2 and Terminal.app).

## Features

- Event manager with keyboard focus (TAB), mouse clicks, custom handlers and a timer
- Widgets: label, button, text box, multi-line edit box, check box, list box, combo box, rectangle
- Progress bar, spinner, horizontal and vertical scroll bars
- Data grid with column headers, row numbers and in-place cell editing
- Tree view with expandable nodes
- Tab control with child widgets on each page
- Menu bar with drop-down menus, shortcuts, check box items, separators and nested submenus
- Window manager: movable, resizable windows with minimize, maximize and close buttons
- Mouse support (click to focus, select, drag and resize, menu hover)
- The same keyboard and mouse events on Windows, Linux and macOS (`TUIKernel.pollEvent()`)
- Redraws only the changed parts of the screen to reduce flicker

## Installation

	ringpm install tuilib from ringpackages

## Screen Shots

![Screen Shot 1](https://raw.githubusercontent.com/ringpackages/tuilib/main/images/tuilib_shot1.png)

![Screen Shot 2](https://raw.githubusercontent.com/ringpackages/tuilib/main/images/tuilib_shot2.png)

![Screen Shot 3](https://raw.githubusercontent.com/ringpackages/tuilib/main/images/tuilib_shot3.png)

![Screen Shot 4](https://raw.githubusercontent.com/ringpackages/tuilib/main/images/tuilib_shot4.png)

![Screen Shot 5](https://raw.githubusercontent.com/ringpackages/tuilib/main/images/tuilib_shot5.png)

![Screen Shot 6](https://raw.githubusercontent.com/ringpackages/tuilib/main/images/tuilib_shot6.png)

## Quick Start

```ring
load "tuilib.ring"

# Global variables (used by the event handlers)
oAppKernel = NULL
oAppTxtName = NULL
oAppStatusBar = NULL

oAppKernel = new TUIKernel()
oAppKernel.clear()
oAppKernel.enableMouse()
oAppEventManager = new TUIEventManager(oAppKernel)

oAppWindow = new TUIWindow(oAppKernel, 2, 2, 50, 10, "Hello - ESC: Exit")

oAppLabel = new TUILabel(oAppKernel, 4, 4, 10, 1)
oAppLabel.setText("Name:")

oAppTxtName = new TUITextBox(oAppKernel, 12, 4, 30, 1)
oAppTxtName.setText("Sample User")

oAppButton = new TUIButton(oAppKernel, 12, 6, 12, 1)
oAppButton.setText("Say Hello")
oAppButton.setOnClick(func {
	oAppStatusBar.setText(oAppKernel.fixedWidth("Hello, " + oAppTxtName.cText, 50))
	oAppStatusBar.draw()
})

oAppStatusBar = new TUILabel(oAppKernel, 2, 12, 50, 1)
oAppStatusBar.nFgColor = BLACK
oAppStatusBar.nBgColor = GREY
oAppStatusBar.setText(oAppKernel.fixedWidth("TAB: Next widget | Enter: Click", 50))

oAppWindow.addChild(oAppLabel)
oAppWindow.addChild(oAppTxtName)
oAppWindow.addChild(oAppButton)
oAppWindow.draw()
oAppStatusBar.draw()

oAppEventManager.registerWidget(oAppTxtName)
oAppEventManager.registerWidget(oAppButton)
oAppEventManager.setFocus(oAppTxtName)
oAppEventManager.run()		# Returns when ESC is pressed

oAppKernel.restoreTerminal()
```

### Notes

- Positions are console columns and rows (starting from 1); sizes are in characters
- Each widget takes the kernel as the first parameter: `new TUIButton(oKernel, nX, nY, nWidth, nHeight)`
- Event handlers are anonymous functions (`func { ... }`); they can't see the local variables of the function that created them, so use global variables for the widgets they change
- Give global variables names that the library doesn't use (the samples use the `oApp` prefix): a library method that assigns a local variable with the same name would change the global variable
- Container methods (`addChild()`, `registerWidget()`, etc.) keep a reference to the widget (not a copy), so pass the widget variable itself, not a list item like `[oWidget1, oWidget2][1]`
- Colors are the RogueUtil color constants: `BLACK`, `BLUE`, `GREEN`, `CYAN`, `RED`, `MAGENTA`, `BROWN`, `GREY`, `DARKGREY`, `LIGHTBLUE`, `LIGHTGREEN`, `LIGHTCYAN`, `LIGHTRED`, `LIGHTMAGENTA`, `YELLOW`, `WHITE`
- Key codes are the RogueUtil key constants (`KEY_UP`, `KEY_ENTER`, `KEY_F2`, etc.) and the character codes; Backspace is `TUI_KEY_BACKSPACE` (8) and TAB is `TUI_KEY_TAB` (9) on all platforms
- Call `restoreTerminal()` before the program ends: on Linux/macOS it also stops the mouse reports and restores the terminal settings
- If a program stops with a runtime error on Linux/macOS, the terminal keeps the program settings (no echo, mouse reports); type `reset` and press Enter to restore it

---

## API Reference

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `TUI_EVENT_KEYBOARD` | "keyboard" | Keyboard event type (`TUIEvent.cType`) |
| `TUI_EVENT_MOUSE` | "mouse" | Mouse event type |
| `TUI_MENUITEM_NORMAL` | "normal" | Normal menu item (`TUIMenuItem.cItemType`) |
| `TUI_MENUITEM_CHECKBOX` | "checkbox" | Check box menu item |
| `TUI_MENUITEM_SEPARATOR` | "separator" | Separator line |
| `TUI_MENUITEM_SUBMENU` | "submenu" | Item that opens a submenu |
| `TUI_MOUSE_PRESS` | 1 | Mouse button pressed (`TUIEvent.nAction`) |
| `TUI_MOUSE_RELEASE` | 2 | Mouse button released |
| `TUI_MOUSE_MOVE` | 3 | Mouse moved without a button |
| `TUI_MOUSE_DRAG` | 4 | Mouse moved with a button down |
| `TUI_MOUSE_WHEELUP`, `TUI_MOUSE_WHEELDOWN` | 5, 6 | Mouse wheel (Linux/macOS) |
| `TUI_BUTTON_NONE`, `TUI_BUTTON_LEFT`, `TUI_BUTTON_RIGHT`, `TUI_BUTTON_MIDDLE` | 0, 1, 2, 3 | Mouse button (`TUIEvent.nButton`) |
| `TUI_KEY_BACKSPACE`, `TUI_KEY_TAB` | 8, 9 | Key codes |
| `TUI_ESCAPE_WAIT` | 30 | Linux/macOS: milliseconds to wait for the rest of an escape sequence before reporting ESC |

---

### TUIKernel Class

Terminal abstraction layer over RogueUtil. Creating the kernel hides the cursor and disables the echo of typed characters (on Linux/macOS it also switches the terminal to read the keys one by one).

#### Screen and Colors

| Method | Description |
|--------|-------------|
| `clear()` | Clear the screen |
| `getRows()` / `getCols()` | Terminal size (rows and columns) |
| `gotoXY(nX, nY)` | Move the cursor |
| `printAt(nX, nY, cText)` | Print text at a position |
| `setTermColor(nFg, nBg)` | Set the foreground and background colors (all 16 colors on every platform; on Linux/macOS it sends the ANSI codes because RogueUtil supports only 8 background colors there) |
| `resetTermColor()` | Reset the colors |
| `setDefaultColors(nFg, nBg)` | Colors used by `clearRegion()` (default: white on black) |
| `setCursorVisible(lVisible)` | Show or hide the cursor |
| `setTitle(cTitle)` | Set the console window title |
| `restoreTerminal()` | Disable the mouse, clear the screen and restore the colors, cursor, echo and terminal settings (call it before the program ends) |
| `flush()` | Send the buffered output to the terminal (Linux/macOS buffer the output; `sleep()` and the event loops flush it) |

#### Drawing

| Method | Description |
|--------|-------------|
| `drawRect(nX, nY, nSizeW, nSizeH)` | Draw a box using `+`, `-` and `\|` (the inside is filled with spaces) |
| `drawBox(nX, nY, nSizeW, nSizeH, nChar)` | Draw a box border using one character code |
| `fillRect(nX, nY, nSizeW, nSizeH, nChar)` | Fill an area with one character code |
| `fixedWidth(cText, nSize)` | Return the text padded with spaces or cut to exactly `nSize` characters |
| `rectanglesIntersect(nX1, nY1, nW1, nH1, nX2, nY2, nW2, nH2)` | Check if two rectangles intersect |

#### Keyboard, Mouse and Time

| Method | Description |
|--------|-------------|
| `pollEvent()` | Return the next keyboard or mouse event (`TUIEvent`), or `NULL` if there is no input (doesn't wait) |
| `checkKeyHit()` | Return true if input (keyboard or mouse) is waiting |
| `getKey()` | Wait for a key and return its code (mouse events are skipped) |
| `getChar()` / `nbGetch()` | RogueUtil `getch()` and non-blocking `getch()` (raw bytes; prefer `pollEvent()`) |
| `waitForKey(cMessage)` | Print a message and wait for any key |
| `enableEcho()` / `disableEcho()` | Show or hide the typed characters |
| `enableMouse()` / `disableMouse()` | Enable or disable mouse events (`lMouseEnabled`); on Linux/macOS this also switches to/from the alternate screen and clears it |
| `sleep(nMilliseconds)` | Flush the output and wait |

```ring
# Custom event loop
while true
	oAppEvent = oAppKernel.pollEvent()
	if oAppEvent = NULL
		oAppKernel.sleep(1)
		loop
	ok
	if oAppEvent.cType = TUI_EVENT_KEYBOARD
		if oAppEvent.nKey = KEY_ESCAPE exit ok
	but oAppEvent.nAction = TUI_MOUSE_PRESS and oAppEvent.nButton = TUI_BUTTON_LEFT
		oAppKernel.printAt(oAppEvent.nX, oAppEvent.nY, "*")
	ok
end
```

On Windows the mouse is read from the console state, and the changes are reported as press, release, move and drag events. On Linux/macOS the terminal sends the keys and the mouse reports as escape sequences: `pollEvent()` decodes them (function keys, Home/End, Page Up/Down, Insert/Delete, keys with modifiers, and the SGR, urxvt and X10 mouse reports), so mouse movements never reach the widgets as typed keys and unknown sequences are ignored instead of being read as ESC.

#### Screen Widgets

Screen widgets are redrawn when a menu closes over them (used by the menu bar).

| Method | Description |
|--------|-------------|
| `registerScreenWidget(oWidget)` | Register a widget |
| `unregisterScreenWidget(oWidget)` | Remove a widget |
| `clearScreenWidgets()` | Remove all the widgets |
| `clearRegion(nRegionX, nRegionY, nRegionW, nRegionH)` | Fill an area with the default background color |
| `redrawRegion(nRegionX, nRegionY, nRegionW, nRegionH)` | Redraw the visible screen widgets that intersect an area |

---

### TUIEventManager Class

The main event loop. Create it with `new TUIEventManager(oKernel)`.

| Method | Description |
|--------|-------------|
| `registerWidget(oWidget)` | Add a widget to the TAB order and mouse handling |
| `unregisterWidget(oWidget)` | Remove a widget |
| `clearWidgets()` | Remove all the widgets and clear the focus |
| `setFocus(oWidget)` | Focus a widget (`NULL` to clear the focus) |
| `focusNext()` | Move the focus to the next visible, focusable widget |
| `setMenuBar(oMenuBar)` | Use a menu bar (F2 or a click opens it); `NULL` removes it |
| `setTabControl(oTabControl)` | Use a tab control (F3 switches pages, TAB moves between the page widgets); `NULL` removes it |
| `setStatusBar(oLabel)` | Use a label as the status bar; `NULL` removes it |
| `setStatus(cText)` | Show a text in the status bar |
| `setOnKeyboard(cHandler)` | Custom keyboard handler `func oEvent { ... }`; return true when the key is handled |
| `setOnMouse(cHandler)` | Custom mouse handler (left click), same as `setOnKeyboard()` |
| `setOnTimer(cHandler, nInterval)` | Call a handler `func { ... }` every `nInterval` loop iterations (each iteration waits at least 1 ms); 0 disables it |
| `addEventListener(cEventType, cHandler)` | Call `func oEvent { ... }` after each event of this type |
| `run()` | Run the loop until ESC is pressed (or `stop()` is called) |
| `stop()` | End the loop |
| `drawAll()` | Draw the visible widgets, the menu bar, the tab control and the status bar |
| `findWidgetAt(nMouseX, nMouseY)` | Return the registered widget at a position (`NULL` if none) |

Only left button presses are clicks (mouse moves and releases are ignored). The loop handles the keys in this order: ESC (removes the focus from a tab page widget, otherwise ends the loop), F2 (menu bar), F3 (next tab page), the custom keyboard handler, TAB (next widget), then the focused widget.

The `oFocusedWidget` attribute holds the focused widget.

---

### TUIEvent Class

| Attribute | Description |
|-----------|-------------|
| `cType` | `TUI_EVENT_KEYBOARD` or `TUI_EVENT_MOUSE` |
| `nKey` | Key code (keyboard events) |
| `cChar` | Character (keyboard events) |
| `nX`, `nY` | Mouse position |
| `nAction` | Mouse action (`TUI_MOUSE_*`) |
| `nButton` | Mouse button (`TUI_BUTTON_*`) |
| `oTarget` | Target widget |
| `vData` | Extra data (true for a left click) |

---

### TUIWidget Class

The base class of the widgets: `new TUIWidget(oKernel, nX, nY, nWidth, nHeight)`.

| Attribute | Description |
|-----------|-------------|
| `nX`, `nY`, `nWidth`, `nHeight` | Position and size |
| `cText` | Text |
| `nFgColor`, `nBgColor` | Colors (default: white on blue) |
| `lVisible` | Visible (default: true) |
| `lEnabled` | Enabled (default: true) |
| `lFocused` | Has the focus |
| `lFocusable` | Can receive the focus (false for labels, rectangles and progress bars) |

| Method | Description |
|--------|-------------|
| `draw()` | Draw the widget |
| `handleEvent(oEvent)` | Handle a keyboard or mouse event; returns true if handled |
| `setText(cValue)` | Set the text (call `draw()` to show it) |
| `show()` | Show and draw the widget |
| `hide()` | Hide the widget |

### TUIFrame and TUIWindow Classes

`TUIFrame` is a container with a background; `TUIWindow` adds a border and a title: `new TUIWindow(oKernel, nX, nY, nWidth, nHeight, cTitle)`.

Children keep their own screen positions.

| Method | Description |
|--------|-------------|
| `addChild(oWidget)` / `removeChild(oWidget)` | Add or remove a child widget |
| `clearChildren()` | Remove all the children |
| `draw()` | Draw the frame and its visible children |
| `drawBackground()` | Draw only the background (`TUIFrame`) |
| `redrawRegion(nRegionX, nRegionY, nRegionW, nRegionH)` | Redraw the background and children inside an area (`TUIFrame`) |
| `getIntersectingWidgets(nRegionX, nRegionY, nRegionW, nRegionH)` | Return the visible children inside an area (`TUIFrame`) |

Attributes: `cTitle`, `nBorderColor` (`TUIWindow`), `cBgChar` (background character).

### TUILabel Class

Single line text, cut to the label width. Labels can't receive the focus.

### TUIButton Class

Activated by Enter, Space or a mouse click.

| Member | Description |
|--------|-------------|
| `setOnClick(cHandler)` | Set the click handler `func { ... }` |
| `nNormalFgColor`, `nNormalBgColor` | Colors (black on grey) |
| `nFocusedFgColor`, `nFocusedBgColor` | Colors when focused (white on light blue) |
| `nPressedFgColor`, `nPressedBgColor` | Colors while pressed (white on blue) |

### TUITextBox Class

Single line input. Keys: printable characters, Backspace, Delete, Left, Right, Home, End.

| Member | Description |
|--------|-------------|
| `cText` | The text |
| `nCursorPos` | Cursor position (0 = before the first character) |
| `nMaxLength` | Maximum length (default: 50) |
| `showCursor()` | Move the terminal cursor to the text box |

### TUIEditBox Class

Multi-line text editor with scrolling.

| Member | Description |
|--------|-------------|
| `setText(cValue)` | Set the text (lines are separated by `nl`) |
| `getText()` | Return the text |
| `setEnterMode(lMovesDown)` | true: Enter moves to the next line (default); false: Enter splits the line |
| `aLines` | The lines |
| `nCursorX`, `nCursorY` | Cursor column and line (0-based) |
| `nMaxLength` | Maximum line length (default: 1000) |

### TUICheckBox Class

Toggled by Space, Enter or a mouse click.

| Member | Description |
|--------|-------------|
| `setChecked(lValue)` | Check or uncheck (call `draw()` to show it) |
| `lChecked` | Checked state |

### TUIListBox Class

Scrollable list. Keys: Up, Down, Home, End, Page Up, Page Down.

| Member | Description |
|--------|-------------|
| `addItem(cItem)` | Add an item |
| `getSelected()` | Return the selected item (empty string if none) |
| `aItems` | The items |
| `nSelectedIndex` | Selected item (1-based, 0 = none) |

### TUIComboBox Class

Selector that shows one item. Up/Down/Home/End change the item; a mouse click selects the next item.

| Member | Description |
|--------|-------------|
| `addItem(cItem)` | Add an item |
| `getSelected()` | Return the selected item |
| `aItems`, `nSelectedIndex` | The items and the selected item (1-based) |

### TUIRectangle Class

Display-only rectangle.

| Member | Description |
|--------|-------------|
| `setBorderStyle(cStyle)` | `"single"` or `"double"` (`+`, `-`, `\|`), `"thick"` (`#`), or `"none"` |
| `setFilled(lIsFilled, nChar)` | Fill the inside with a character code (`NULL` keeps the current character) |
| `setCornerChar(nChar)` | Character code for the corners (0 = default) |

These methods draw the rectangle.

### TUIProgressBar Class

Display-only progress bar: `[=====-----] 50%`.

| Member | Description |
|--------|-------------|
| `setValue(nNewValue)` / `getValue()` | Value (limited to the range) |
| `setRange(nMin, nMax)` | Range (default: 0 to 100) |
| `getPercentage()` | Percentage (0 to 100) |
| `lShowPercentage` | Show the percentage (default: true) |
| `cFillChar`, `cEmptyChar` | Bar characters (`=` and `-`) |
| `nBarFgColor`, `nBarBgColor` | Bar colors |

### TUISpinner Class

Numeric input: `[-] 10 [+]`. Keys: Left/`-` (decrement), Right/`+` (increment), digits or Enter (edit the value, Enter confirms, ESC cancels).

| Member | Description |
|--------|-------------|
| `setValue(nNewValue)` / `getValue()` | Value (limited to the range) |
| `setRange(nMin, nMax)` | Range (default: 0 to 100) |
| `increment()` / `decrement()` | Change the value by `nStep` |
| `nStep` | Step (default: 1) |

### TUIHScrollBar and TUIVScrollBar Classes

Scroll bars (the horizontal bar is one row high, the vertical bar is one column wide). Keys: arrows, Home, End, Page Up, Page Down; click the arrows or the track.

| Member | Description |
|--------|-------------|
| `setValue(nNewValue)` / `getValue()` | Value (limited to the range) |
| `setRange(nMin, nMax)` | Range (default: 0 to 100) |
| `setOnChange(cHandler)` | Handler `func nValue { ... }` called when the value changes |
| `nPageSize` | Page Up/Page Down step (default: 10) |

### TUIGrid Class

Data grid. Keys: arrows, Home, End, Page Up, Page Down, Enter (edit the cell; Enter saves, ESC cancels). A click selects a cell; a click on the selected cell edits it.

| Member | Description |
|--------|-------------|
| `addColumn(cColName, nColWidth)` | Add a column |
| `addRow(aRowData)` | Add a row (list of strings) |
| `setCell(nRow, nCol, cValue)` / `getCell(nRow, nCol)` | Cell value (0-based indexes) |
| `clearData()` | Remove all the rows |
| `nCurrentRow`, `nCurrentCol` | Selected cell (0-based) |
| `lShowHeaders`, `lShowRowNumbers` | Show the column headers and the row numbers (default: true) |
| `lEditable` | Allow editing (default: true) |
| `nRowNumberWidth` | Row number column width (default: 4) |
| `aColumns`, `aRows` | Columns (`[name, width]`) and rows |

Colors: `nGridFgColor`, `nGridBgColor`, `nHeaderFgColor`, `nHeaderBgColor`, `nSelectedFgColor`, `nSelectedBgColor`, `nEditFgColor`, `nEditBgColor`.

### TUITreeNode and TUITreeView Classes

Tree view. Keys: Up, Down, Left (collapse or go to the parent), Right (expand or go to the first child), Enter/Space (toggle), Home, End, Page Up, Page Down. A click on `[+]`/`[-]` toggles a node.

| TUITreeNode Member | Description |
|--------------------|-------------|
| `new TUITreeNode(cText)` | Create a node |
| `addChild(oNode)` | Add a child node; returns it |
| `addChildText(cText)` | Create and add a child node; returns it |
| `hasChildren()` | Check if the node has children |
| `expand()` / `collapse()` / `toggle()` | Expand or collapse the node |
| `expandAll()` / `collapseAll()` | Expand or collapse the node and its descendants |
| `cText`, `aChildren`, `oParent`, `nLevel`, `lExpanded` | Node data |
| `vData` | Custom data |

| TUITreeView Member | Description |
|--------------------|-------------|
| `addRootNode(oNode)` / `addRootText(cText)` | Add a root node; returns it |
| `updateVisibleNodes()` | Update the tree after changing nodes directly |
| `getSelectedNode()` | Return the selected node (`NULL` if none) |
| `expandAll()` / `collapseAll()` | Expand or collapse all the nodes and draw the tree |
| `nSelectedIndex` | Selected node index in the visible nodes (0-based) |

Colors: `nNodeFgColor`, `nNodeBgColor`, `nSelectedFgColor`, `nSelectedBgColor`, `nExpanderFgColor`.

### TUITabControl and TUITabPage Classes

Tabbed pages. The tab bar is on the first row; the page content starts two rows below. Keys: Left, Right, Home, End; click a tab to select it.

| Member | Description |
|--------|-------------|
| `addPage(cTitle)` | Add a page; returns the `TUITabPage` |
| `removePage(nPageIndex)` | Remove a page |
| `setActivePage(nPageIndex)` | Select a page (1-based) and draw the control |
| `nextPage()` / `previousPage()` | Select the next/previous page (wraps around) |
| `getActivePage()` | Return the active page |
| `TUITabPage.addChild(oWidget, nRelX, nRelY)` | Add a widget at a position relative to the page content |
| `TUITabPage.removeChild(oWidget)` | Remove a widget |

Colors: `nTabFgColor`, `nTabBgColor`, `nActiveTabFgColor`, `nActiveTabBgColor`, `nContentFgColor`, `nContentBgColor`, `nBorderFgColor`.

### TUIMenuBar, TUIMenu and TUIMenuItem Classes

Menu bar: `new TUIMenuBar(oKernel, nX, nY, nWidth)`. Use it with `TUIEventManager.setMenuBar()`; F2 or a click opens the menus. Keys: arrows, Enter/Space, ESC. Moving the mouse over an open menu selects the item under it.

| TUIMenuBar Method | Description |
|-------------------|-------------|
| `createMenu(cTitle)` | Create and add a menu; returns it |
| `addMenu(oMenu)` | Add a menu |
| `getMenuByTitle(cTitle)` | Return a menu (`NULL` if not found) |
| `activate()` / `deactivate()` | Select the first menu title / close the menus |
| `openMenu(nMenuIndex)` / `closeMenu()` | Open or close a menu |
| `runMenuLoop()` | Handle the keyboard and mouse until the menus close |

| TUIMenu Method | Description |
|----------------|-------------|
| `new TUIMenu(oKernel)` | Create a menu (for submenus) |
| `addNormalItem(cText, cHandler)` | Add an item; the handler is `func oItem { ... }` |
| `addCheckboxItem(cText, lChecked, cHandler)` | Add a check box item (the handler sees the new `oItem.lChecked`) |
| `addSeparator()` | Add a separator |
| `addSubmenu(cText, oSubmenu)` | Add an item that opens a submenu |
| `addItem(oItem)` | Add a `TUIMenuItem` |
| `getItemAt(nItemIndex)` / `getItemById(cID)` / `getSelectedItem()` | Return an item (`NULL` if not found) |
| `show(nX, nY)` / `hide()` | Show or hide the menu |

The `add...Item()` methods return the new item, so `setShortcut()` can be chained:

```ring
oAppFileMenu = oAppMenuBar.createMenu("File")
oAppFileMenu.addNormalItem("Save", func oItem { ? "Save" }).setShortcut("Ctrl+S")
```

| TUIMenuItem Method | Description |
|--------------------|-------------|
| `setText(cValue)` | Item text |
| `setShortcut(cKeys)` | Shortcut text shown at the right side (display only) |
| `setChecked(lValue)` / `toggle()` | Check box state |
| `setEnabled(lValue)` | Enable or disable the item |
| `setOnClick(cHandler)` | Click handler |
| `setSubmenu(oMenu)` | Make the item open a submenu |
| `setId(cIDValue)` | Identifier (see `getItemById()`) |

The `set...()` methods and `toggle()` return `self`.

### TUIManagedWindow and TUIWindowManager Classes

Movable, resizable windows on a desktop. `TUIWindowManager` has its own loop: drag a title bar to move a window, drag the right edge, bottom edge or the `=#` corner to resize, click `[_]`, `[O]` or `[X]`, F12 cycles the windows and ESC ends the loop.

```ring
oAppWM = new TUIWindowManager(oAppKernel)
oAppWin = new TUIManagedWindow(oAppKernel, 3, 3, 40, 12, "Information")
oAppLabel = new TUILabel(oAppKernel, 0, 0, 30, 1)
oAppLabel.setText("Hello")
oAppLabel.nBgColor = BLACK
oAppWin.addChild(oAppLabel, 1, 0)		# Position relative to the content area
oAppWM.addWindow(oAppWin)
oAppWM.run()
```

| TUIManagedWindow Member | Description |
|-------------------------|-------------|
| `addChild(oWidget, nRelX, nRelY)` / `removeChild(oWidget)` | Add or remove a child widget (TAB moves between them) |
| `setTitle(cTitle)` | Window title |
| `minimize()` / `maximize()` / `restore()` / `close()` | Window state |
| `getContentX()` / `getContentY()` / `getContentWidth()` / `getContentHeight()` | Content area |
| `setOnClose`, `setOnMinimize`, `setOnMaximize`, `setOnRestore`, `setOnMove`, `setOnResize` | Handlers `func oWindow { ... }` |
| `lShowMinimize`, `lShowMaximize`, `lShowClose` | Show the title bar buttons (default: true) |
| `nMinWidth`, `nMinHeight` | Minimum size (default: 20 x 6) |

Colors: `nTitleFgColor`, `nActiveTitleBgColor`, `nInactiveTitleBgColor`, `nBorderFgColor`, `nBorderBgColor`, `nContentBgColor`.

| TUIWindowManager Method | Description |
|-------------------------|-------------|
| `addWindow(oWin)` / `removeWindow(oWin)` | Add a window (on top) or remove it |
| `bringToFront(nWinIndex)` / `cycleWindows()` | Change the window order |
| `getActiveWindow()` | Return the top window (`NULL` if none) |
| `addDesktopWidget(oWidget)` / `removeDesktopWidget(oWidget)` | Widgets drawn on the desktop (title bar, task bar, etc.) |
| `setDesktopColors(nFg, nBg)` / `setDesktopPattern(cPattern)` | Desktop colors and fill pattern |
| `setOnExit(cHandler)` | Handler `func { ... }` called when the loop ends |
| `run()` / `stop()` | Run or end the loop |
| `drawAll()` | Draw the desktop and the windows |

---

## Samples

The samples are in the `samples/UsingTUILib` folder:

| Sample | Description |
|--------|-------------|
| `test01_form.ring` | Labels, text boxes, check boxes, list box, combo box, edit box, buttons and rectangles |
| `test02_grid.ring` | Data grid with in-place cell editing |
| `test03_menubar.ring` | Menu bar with shortcuts, check box items, separators and nested submenus |
| `test04_window_manager.ring` | Movable, resizable windows on a desktop |
| `test05_treeview.ring` | Two tree views with custom keyboard and mouse handlers |
| `test06_tabcontrol.ring` | Tab control with widgets on each page |
| `test07_controls.ring` | Progress bars, spinners and scroll bars (with a timer) |
| `test08_menubar_tabs.ring` | Menu bar and tab control together |
| `test09_demo_launcher.ring` | Menu that runs the other samples |

---

## License

MIT License
