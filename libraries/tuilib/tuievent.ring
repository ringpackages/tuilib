# Event data (keyboard or mouse)

class TUIEvent

	cType = ""      # TUI_EVENT_KEYBOARD or TUI_EVENT_MOUSE
	nKey = 0        # Key code
	cChar = ""      # Character
	nX = 0          # Mouse X
	nY = 0          # Mouse Y
	nAction = 0     # Mouse action (TUI_MOUSE_*)
	nButton = 0     # Mouse button (TUI_BUTTON_*)
	oTarget = NULL  # Target widget
	vData = NULL    # Additional data (true for a left click)

	func init cEventType
		cType = cEventType
		return self
