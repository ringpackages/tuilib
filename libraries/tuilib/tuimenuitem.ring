# Menu item data (normal, checkbox, separator or submenu)

class TUIMenuItem

	cText = ""              # Display text
	cShortcut = ""          # Keyboard shortcut display (e.g., "Ctrl+S")
	cItemType = TUI_MENUITEM_NORMAL    # TUI_MENUITEM_* constant
	lChecked = false        # For checkbox items
	lEnabled = true         # Is item enabled?
	cOnClick = NULL         # Click handler function
	oSubmenu = NULL         # Submenu (TUIMenu) for TUI_MENUITEM_SUBMENU items
	cID = ""                # Optional identifier

	func init cNewText, cType
		cText = cNewText
		if cType != NULL
			cItemType = cType
		ok
		return self

	func setText cValue
		cText = cValue
		return self

	func setShortcut cKeys
		cShortcut = cKeys
		return self

	func setChecked lValue
		lChecked = lValue
		return self

	func toggle
		if cItemType = TUI_MENUITEM_CHECKBOX
			lChecked = not lChecked
		ok
		return self

	func setEnabled lValue
		lEnabled = lValue
		return self

	func setOnClick cHandler
		cOnClick = cHandler
		return self

	func setSubmenu oMenu
		oSubmenu = oMenu
		cItemType = TUI_MENUITEM_SUBMENU
		return self

	func setId cIDValue
		cID = cIDValue
		return self

	func getDisplayWidth
		if cItemType = TUI_MENUITEM_SEPARATOR
			return 0
		ok
		nSizeW = len(cText)
		if cItemType = TUI_MENUITEM_CHECKBOX
			nSizeW = nSizeW + 4  # For "[X] " or "[ ] "
		ok
		if cItemType = TUI_MENUITEM_SUBMENU
			nSizeW = nSizeW + 2  # For " ►"
		ok
		if len(cShortcut) > 0
			nSizeW = nSizeW + len(cShortcut) + 2  # For "  shortcut"
		ok
		return nSizeW
