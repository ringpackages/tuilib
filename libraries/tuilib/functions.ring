# RogueUtil wrappers
# Note: TUIKernel has methods with the same names (gotoXY(), getKey(), etc.) and methods
# are called before functions inside classes, so the kernel calls these functions instead

func tuiGotoXY nX, nY
	gotoxy(nX, nY)

func tuiGetKey
	return getkey()

func tuiEnableMouse
	return enablemouse()

func tuiDisableMouse
	return disablemouse()
