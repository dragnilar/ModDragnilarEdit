function SSS_IsManualCfg(): bool
{
	var useGUI : bool;
	useGUI = false;

	// README! if you resolve conflict make sure that the line from mody_SSS5_gui_menu was used here 
	// CLICK buttons with blue letters A and B on the panel above
	// the next line in the output window should look like this: useGUI = true;

	return !useGUI;
}
